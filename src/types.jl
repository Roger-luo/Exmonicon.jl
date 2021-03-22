"""
intermediate types for Julia expression objects.
"""
module Types

using OrderedCollections

export NoDefault, JLExpr, JLIfElse, JLMatch, JLFunction, JLField, JLKwField, JLStruct, JLKwStruct,
    no_default

const Maybe{T} = Union{Nothing, T}

"""
    NoDefault

Type describes a field should have no default value.
"""
struct NoDefault end

"""
    const no_default = NoDefault()

Constant instance for [`NoDefault`](@ref) that
describes a field should have no default value.
"""
const no_default = NoDefault()

abstract type JLExpr end

"""
    JLFunction <: JLExpr

Type describes a Julia function declaration expression.
"""
mutable struct JLFunction <: JLExpr
    head::Symbol  # function def must have a head
    name::Any  # name can be nothing, Symbol, Expr
    args::Vector{Any} 
    kwargs::Maybe{Vector{Any}} 
    whereparams::Maybe{Vector{Any}} 
    body::Any
    line::Maybe{LineNumberNode} 
    doc::Maybe{String} 
end

function JLFunction(;
        head=:function, name=nothing,
        args=[], kwargs=nothing,
        whereparams=nothing, body=Expr(:block),
        line=nothing, doc=nothing
    )
    JLFunction(head, name, args, kwargs, whereparams, body, line, doc)
end

"""
    JLField <: JLExpr
    JLField(name, type, line)

Type describes a Julia field in a Julia struct.
"""
mutable struct JLField <: JLExpr
    name::Symbol
    type::Any
    doc::Maybe{String}
    line::Maybe{LineNumberNode}
end

function JLField(;name, type=Any, doc=nothing, line=nothing)
    JLField(name, type, doc, line)
end

"""
    JLKwField <: JLExpr
    JLKwField(name, type, line, default=no_default)

Type describes a Julia field that can have a default value in a Julia struct.
"""
mutable struct JLKwField <: JLExpr
    name::Symbol
    type::Any
    doc::Maybe{String}
    line::Maybe{LineNumberNode}
    default::Any
end

function JLKwField(;name, type=Any, doc=nothing, line=nothing, default=no_default)
    JLKwField(name, type, doc, line, default)
end

"""
    JLStruct <: JLExpr

Type describes a Julia struct.
"""
mutable struct JLStruct <: JLExpr
    name::Symbol
    ismutable::Bool
    typevars::Vector{Any}
    supertype::Any
    fields::Vector{JLField}
    constructors::Vector{JLFunction}
    line::Maybe{LineNumberNode}
    doc::Maybe{String}
    misc::Any
end

function JLStruct(;
    name, ismutable=false,
    typevars=[], supertype=nothing,
    fields=JLField[], constructors=JLFunction[],
    line=nothing, doc=nothing, misc=nothing)
    JLStruct(name, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLKwStruct <: JLExpr

Type describes a Julia struct that allows keyword definition of defaults.
"""
mutable struct JLKwStruct <: JLExpr
    name::Symbol
    typealias::Maybe{String}
    ismutable::Bool
    typevars::Vector{Any}
    supertype::Any
    fields::Vector{JLKwField}
    constructors::Vector{JLFunction}
    line::Maybe{LineNumberNode}
    doc::Maybe{String}
    misc::Any
end

function JLKwStruct(;name, typealias=nothing,
    ismutable=false, typevars=[], supertype=nothing,
    fields=JLField[], constructors=JLFunction[],
    line=nothing, doc=nothing, misc=nothing)
    JLKwStruct(name, typealias, ismutable, typevars, supertype, fields, constructors, line, doc, misc)
end

"""
    JLIfElse <: JLExpr

`JLIfElse` describes a Julia `if ... elseif ... else ... end` expression. It allows one to easily construct
such expression by inserting condition and code block via a map.

# Example

### Construct JLIfElse object

One can construct an `ifelse` as following

```julia
julia> jl = JLIfElse()
nothing

julia> jl.map[:(foo(x))] = :(x = 1 + 1)
:(x = 1 + 1)

julia> jl.map[:(goo(x))] = :(y = 1 + 2)
:(y = 1 + 2)

julia> jl.otherwise = :(error("abc"))
:(error("abc"))

julia> jl
if foo(x)
    x = 1 + 1
elseif goo(x)
    y = 1 + 2
else
    error("abc")
end
```

### Generate the Julia `Expr` object

to generate the corresponding `Expr` object, one can call [`codegen_ast`](@ref).

```julia
julia> codegen_ast(jl)
:(if foo(x)
      x = 1 + 1
  elseif goo(x)
      y = 1 + 2
  else
      error("abc")
  end)
```
"""
mutable struct JLIfElse <: JLExpr
    map::OrderedDict{Any, Any}
    otherwise::Any
end

JLIfElse() = JLIfElse(OrderedDict(), nothing)

"""
    JLMatch <: JLExpr

`JLMatch` describes a Julia pattern match expression defined by
[`MLStyle`](https://github.com/thautwarm/MLStyle.jl). It allows
one to construct such expression by simply assign each code block
to the corresponding pattern expression.

# Example

One can construct a `MLStyle` pattern matching expression
easily by assigning the corresponding pattern and its result
to the `map` field.

```julia
julia> jl = JLMatch(:x)
#= line 0 =#
nothing

julia> jl = JLMatch(:x)
#= line 0 =#
nothing

julia> jl.map[1] = true
true

julia> jl.map[2] = :(sin(x))
:(sin(x))

julia> jl
#= line 0 =#
@match x begin
    1 => true
    2 => sin(x)
    _ =>     nothing
end
```

to generate the corresponding Julia `Expr` object, one can call [`codegen_ast`](@ref).

```julia
julia> codegen_ast(jl)
:(let
      true
      var"##return#263" = nothing
      var"##265" = x
      if var"##265" isa Int64
          #= line 0 =#
          if var"##265" === 1
              var"##return#263" = let
                      true
                  end
              #= unused:1 =# @goto var"####final#264#266"
          end
          #= line 0 =#
          if var"##265" === 2
              var"##return#263" = let
                      sin(x)
                  end
              #= unused:1 =# @goto var"####final#264#266"
          end
      end
      #= line 0 =#
      begin
          var"##return#263" = let
                  nothing
              end
          #= unused:1 =# @goto var"####final#264#266"
      end
      (error)("matching non-exhaustive, at #= line 0 =#")
      #= unused:1 =# @label var"####final#264#266"
      var"##return#263"
  end)
```
"""
struct JLMatch <: JLExpr
    item::Any
    map::OrderedDict{Any, Any}
    fallthrough::Any
    mod::Module
    line::LineNumberNode
end

"""
    JLMatch(item)

Generate an empty `JLMatch` object with given item expression.
`item` can be a `Symbol` or an `Expr`.
"""
JLMatch(item) = JLMatch(item, OrderedDict(), nothing, Main, LineNumberNode(0))

"""
    JLMatch(;item, map=OrderedDict(), fallthrough=nothing, mod=Main, line=LineNumberNode(0))

Create a `JLMatch` object from keyword arguments.

# Kwargs

- `item`: item to match
- `map`: the pattern=>result map, should be an `OrderedDict`.
- `fallthrough`: the result of fallthrough pattern `_`.
- `mod`: module to evaluate the expression.
- `line`: line number `LineNumberNode`.
"""
JLMatch(;item, map=OrderedDict(), fallthrough=nothing, mod=Main, line=LineNumberNode(0)) =
    JLMatch(item, map, fallthrough, mod, line)

end
