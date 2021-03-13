"""
Expronicon type pretty printings.
"""
module Printings

export with_marks, with_parathesis, with_curly, with_brackets, with_begin_end

using Markdown
using MLStyle
using ..Types

const INDENT=4

"julia Expr printing color schema"
module Color
using Crayons.Box

kw(x) = LIGHT_MAGENTA_FG(Base.string(x))
fn(x) = LIGHT_BLUE_FG(Base.string(x))
line(x) = DARK_GRAY_FG(Base.string(x))
literal(x) = YELLOW_FG(Base.string(x))
type(x) = LIGHT_GREEN_FG(Base.string(x))
string(x::String) = Box.CYAN_FG(x)
string(x) = Box.CYAN_FG(Base.string(x))

end

no_indent(io::IO) = IOContext(io, :indent=>0)
no_indent_first_line(io::IO) = IOContext(io, :no_indent_first_line=>true)

function print(io::IO, xs...)
    indent = get(io, :indent, 0)
    tab = get(io, :tab, " ")
    Base.print(io, tab^indent, xs...)
end

function println(io::IO, xs...)
    if get(io, :no_indent_first_line, false)
        print(no_indent(io), xs..., "\n")
    else
        print(io, xs..., "\n")
    end
end

function indent(io)
    IOContext(io, :indent => get(io, :indent, 0) + INDENT)
end

"""
    with_marks(f, io, lhs, rhs)

Print using `f` with marks specified on LHS and RHS by `lhs` and `rhs`.
See also [`with_parathesis`](@ref), [`with_curly`](@ref), [`with_brackets`](@ref),
[`with_begin_end`](@ref).
"""
function with_marks(f, io::IO, lhs, rhs)
    print(io, lhs)
    f()
    print(io, rhs)
end

"""
    with_parathesis(f, io::IO)

Print with parathesis. See also [`with_marks`](@ref),
[`with_curly`](@ref), [`with_brackets`](@ref),
[`with_begin_end`](@ref).

# Example

```julia
julia> with_parathesis(stdout) do
        print(1, ", ", 2)
    end
(1, 2)
```
"""
with_parathesis(f, io::IO) = with_marks(f, io, "(", ")")

"""
    with_curly(f, io::IO)

Print with curly parathesis. See also [`with_marks`](@ref), [`with_parathesis`](@ref),
[`with_brackets`](@ref), [`with_begin_end`](@ref).
"""
with_curly(f, io::IO) = with_marks(f, io, "{", "}")

"""
    with_brackets(f, io::IO)

Print with brackets. See also [`with_marks`](@ref), [`with_parathesis`](@ref),
[`with_curly`](@ref), [`with_begin_end`](@ref).
"""
with_brackets(f, io::IO) = with_marks(f, io, "[", "]")

"""
    with_triple_quotes(f, io::IO)

Print with triple quotes.
"""
with_triple_quotes(f, io::IO) = with_marks(f, io, Color.string("\"\"\"\n"), Color.string("\"\"\""))

"""
    with_double_quotes(f, io::IO)

Print with double quotes.
"""
with_double_quotes(f, io::IO) = with_marks(f, io, Color.string("\""), Color.string("\""))

"""
    with_begin_end(f, io::IO)

Print with begin ... end. See also [`with_marks`](@ref), [`with_parathesis`](@ref),
[`with_curly`](@ref), [`with_brackets`](@ref).
"""
with_begin_end(f, io::IO) = with_marks(f, io, "begin", "end")

"""
    print_collection(io, xs; delim=",")

Print a collection `xs` with deliminator `delim`, default is `","`.
"""
function print_collection(io, xs; delim=",")
    tab = get(io, :tab, " ")
    for i in 1:length(xs)
        print_ast(io, xs[i])
        if i !== length(xs)
            print(io, delim, tab)
        end
    end
end

"""
    print_ast(io::IO, xs...)

Print Julia AST. This is a custom implementation of
`Base.show(io, ::Expr)`.
"""
function print_ast(io::IO, xs...)
    foreach(xs) do x
        print_ast(io, x)
    end
end

function print_ast(io::IO, ex)
    tab = get(io, :tab, " ")

    @match ex begin
        ::Union{Number} => print(io, Color.literal(ex))
        ::String => print(stdout, Color.string(repr(ex)))
        ::Symbol => print(io, ex)

        Expr(:tuple, xs...) => begin
            with_parathesis(io) do 
                print_collection(no_indent(io), xs)
            end
        end

        Expr(:(::), name, type) => begin
            print_ast(io, name)
            print(no_indent(io), "::")
            print_ast(no_indent(io), Color.type(type))
        end

        Expr(:kw, name, value) => begin
            print_ast(io, name)
            print(io, tab, "=", tab)
            print_ast(no_indent(io), value)
        end

        Expr(:call, name, args...) => begin
            print(io, Color.fn(name))
            with_parathesis(no_indent(io)) do
                print_collection(no_indent(io), args)
            end
        end

        Expr(:block, stmts...) => begin
            println(io, Color.kw("begin"))
            for i in 1:length(stmts)
                print_ast(indent(io), stmts[i])
                println(io)
            end
            print(io, Color.kw("end"))
        end

        Expr(:return, xs...) => begin
            print_ast(io, Color.kw("return"))
            print(no_indent(io), tab)
            print_ast(no_indent(io), xs...)
        end

        ::LineNumberNode => print(io, Color.line(ex))
        # fallback to default printing
        _ => print(io, ex)
    end
end

function print_ast(io::IO, def::JLFunction)
    tab = get(io, :tab, " ")

    def.head === :function && print(io, Color.kw("function"), tab)

    # print calls
    def.name === nothing || print(io, Color.fn(def.name))
    with_parathesis(no_indent(io)) do
        print_collection(no_indent(io), def.args)
        if def.kwargs !== nothing
            print(io, "; ")
            print_collection(no_indent(io), def.kwargs)
        end
    end

    if def.whereparams !== nothing
        print(no_indent(io), tab, Color.kw("where"), tab)
        with_curly(no_indent(io)) do
            print_collection(no_indent(io), def.whereparams)    
        end
    end

    def.head === :(=) && print(no_indent(io), tab, "=", tab)
    def.head === :(->) && print(no_indent(io), tab, "->", tab)

    # print body
    if def.head === :function
        @match def.body begin
            Expr(:block, stmts...) => begin
                println(io)
                for i in 1:length(stmts)
                    print_ast(indent(io), stmts[i])
                    println(io)
                end
            end

            _ => print_ast(io, def.body)
        end
        print(io, Color.kw("end"))
    else
        print_ast(no_indent_first_line(io), def.body)
    end
end

function print_ast(io::IO, def::JLStruct)
    print_ast_struct(io, def)
end

function print_ast(io::IO, def::JLKwStruct)
    print_ast_struct(io, def)
end

function print_ast(io::IO, def::JLField)
    print_ast_struct_field(io, def)
end

function print_ast(io::IO, def::JLKwField)
    print_ast_struct_field(io, def)
    def.default === no_default || print(no_indent(io), " = ", def.default)
end

function print_ast_doc(io::IO, def)
    def.doc === nothing && return
    doc = def.doc
    with_triple_quotes(io) do
        print(io, Color.string(doc))
    end
    println(io)
end

function print_ast_struct(io::IO, def)
    def.line === nothing || println(io, Color.line(def.line))
    print_ast_doc(io, def)
    print_ast_struct_head(io, def)
    for each in def.fields
        println(no_indent(io))
        print_ast(indent(io), each)
    end
    println(no_indent(io))

    for each in def.constructors
        print_ast(indent(io), each)
        println(io)
    end

    print(io, Color.kw("end"))
end

function print_ast_struct_field(io::IO, def)
    def.line === nothing || println(io, Color.line(def.line))
    if def.doc !== nothing
        print(io)
        with_double_quotes(no_indent(io)) do
            print(no_indent(io), Color.string(def.doc))
        end
        println(io)
    end
    print(io, def.name)
    def.type === Any || print(no_indent(io), "::", Color.type(def.type))
end

function print_ast_struct_head(io::IO, def)
    tab = get(io, :tab, " ")
    # make sure there is only one indent in the same line 
    printed_indent = false
    if def isa JLKwStruct
        print(io, Color.line("#= kw =#"), tab)
        printed_indent = true
    end

    if def.ismutable
        print(printed_indent ? no_indent(io) : io, Color.kw("mutable"), tab)
    end

    print(printed_indent ? no_indent(io) : io, Color.kw("struct"))
    print(io, tab, def.name)

    isempty(def.typevars) || with_curly(no_indent(io)) do
        print_collection(no_indent(io), def.typevars)
    end

    if def.supertype !== nothing
        print(no_indent(io), tab, "<:", tab, Color.type(def.supertype))
    end
end

print_ast(::IO, def::JLExpr) = error("Printings.print_ast is not defined for $(typeof(def))")
Base.show(io::IO, def::JLExpr) = print_ast(io, def)

end
