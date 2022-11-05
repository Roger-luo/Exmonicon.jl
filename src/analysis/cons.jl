"""
    JLFunction(ex::Expr)

Create a `JLFunction` object from a Julia function `Expr`.

# Example

```julia
julia> JLFunction(:(f(x) = 2))
f(x) = begin
    #= REPL[37]:1 =#    
    2    
end
```
"""
function JLFunction(ex::Expr)
    line, doc, expr = split_doc(ex)
    head, call, body = split_function(expr)
    name, args, kw, whereparams, rettype = split_function_head(call)
    JLFunction(head, name, args, kw, rettype, whereparams, body, line, doc)
end

"""
    JLStruct(ex::Expr)

Create a `JLStruct` object from a Julia struct `Expr`.

# Example

```julia
julia> JLStruct(:(struct Foo
           x::Int
       end))
struct Foo
    #= REPL[38]:2 =#
    x::Int
end
```
"""
function JLStruct(ex::Expr)
    line, doc, expr = split_doc(ex)
    ismutable, typename, typevars, supertype, body = split_struct(expr)

    fields, constructors, misc = JLField[], JLFunction[], []
    field_doc, field_line = nothing, nothing

    body = flatten_blocks(body)

    for each in body.args
        m = split_field_if_match(typename, each)
        if m isa String
            field_doc = m
        elseif m isa LineNumberNode
            field_line = m
        elseif m isa NamedTuple
            push!(fields, JLField(;m..., doc=field_doc, line=field_line))
            field_doc, field_line = nothing, nothing
        elseif m isa JLFunction
            push!(constructors, m)
        else
            push!(misc, m)
        end
    end
    JLStruct(typename, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLKwStruct(ex::Expr, typealias=nothing)

Create a `JLKwStruct` from given Julia struct `Expr`, with an option to attach
an alias to this type name.

# Example

```julia
julia> JLKwStruct(:(struct Foo
           x::Int = 1
       end))
#= kw =# struct Foo
    #= REPL[39]:2 =#
    x::Int = 1
end
```
"""
function JLKwStruct(ex::Expr, typealias=nothing)
    line, doc, expr = split_doc(ex)
    ismutable, typename, typevars, supertype, body = split_struct(expr)

    fields, constructors, misc = JLKwField[], JLFunction[], []
    field_doc, field_line = nothing, nothing
    body = flatten_blocks(body)
    for each in body.args
        m = split_field_if_match(typename, each, true)
        if m isa String
            field_doc = m
        elseif m isa LineNumberNode
            field_line = m
        elseif m isa NamedTuple
            field = JLKwField(;m..., doc=field_doc, line=field_line)
            push!(fields, field)
            field_doc, field_line = nothing, nothing
        elseif m isa JLFunction
            push!(constructors, m)
        else
            push!(misc, m)
        end
    end
    JLKwStruct(typename, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLIfElse(ex::Expr)

Create a `JLIfElse` from given Julia ifelse `Expr`.

# Example

```julia
julia> ex = :(if foo(x)
             x = 1 + 1
         elseif goo(x)
             y = 1 + 2
         else
             error("abc")
         end)
:(if foo(x)
      #= REPL[41]:2 =#
      x = 1 + 1
  elseif #= REPL[41]:3 =# goo(x)
      #= REPL[41]:4 =#
      y = 1 + 2
  else
      #= REPL[41]:6 =#
      error("abc")
  end)

julia> JLIfElse(ex)
if foo(x)
    begin
        #= REPL[41]:2 =#        
        x = 1 + 1        
    end
elseif begin
    #= REPL[41]:3 =#    
    goo(x)    
end
    begin
        #= REPL[41]:4 =#        
        y = 1 + 2        
    end
else
    begin
        #= REPL[41]:6 =#        
        error("abc")        
    end
end
```
"""
function JLIfElse(ex::Expr)
    ex.head === :if || error("expect an if ... elseif ... else ... end expression")
    conds, stmts, otherwise = split_ifelse(ex)
    return JLIfElse(conds, stmts, otherwise)
end

"""
    JLFor(ex::Expr)

Create a `JLFor` from given Julia for loop expression.

# Example

```julia
julia> ex = @expr for i in 1:10, j in 1:j
           M[i, j] += 1
       end
:(for i = 1:10, j = 1:j
      #= REPL[3]:2 =#
      M[i, j] += 1
  end)

julia> jl = JLFor(ex)
for i in 1 : 10,
    j in 1 : j
    #= loop body =#
    begin
        #= REPL[3]:2 =#        
        M[i, j] += 1        
    end
end

julia> jl.vars
2-element Vector{Any}:
 :i
 :j

julia> jl.iterators
2-element Vector{Any}:
 :(1:10)
 :(1:j)
```
"""
function JLFor(ex::Expr)
    vars, itrs, body = split_forloop(ex)
    return JLFor(vars, itrs, body)
end
