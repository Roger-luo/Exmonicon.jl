using Test
using Expronicon

def = @expr JLKwStruct struct Foo{N, T}
    x::T = 1
end

codegen_ast_kwfn_plain(def)

@testset "is_fn" begin
    @test is_fn(:(foo(x) = x))
    @test is_fn(:(x -> 2x))
end

@testset "is_kw_fn" begin
    @test is_kw_fn(:(
        function foo(x::Int; kw=1)
        end
    ))

    ex = :(function (x::Int; kw=1) end)
    @test is_kw_fn(ex)
    @test !is_kw_fn(true)

    @test !is_kw_fn(:(
        function foo(x::Int)
        end
    ))

    @test !is_kw_fn(:(
        function (x::Int)
        end
    ))
end

@testset "JLFunction(ex)" begin
    jlfn = JLFunction()
    @test jlfn.name === nothing

    @test_expr JLFunction function foo(x::Int, y::Type{T}) where {T <: Real}
        return x
    end

    def = @test_expr JLFunction function (x, y)
        return 2
    end
    @test is_kw_fn(def) == false

    def = @test_expr JLFunction function (x, y; kw=2)
        return "aaa"
    end
    @test is_kw_fn(def) == true

    @test_expr JLFunction (x, y)->sin(x)

    # canonicalize head when it's a block
    @test_expr JLFunction function (x::Int; kw=1) end

    ex = :(struct Foo end)
    @test_throws AnalysisError JLFunction(ex)
    ex = :(@foo(2, 3))
    @test_throws AnalysisError split_function_head(ex)

    ex = :(Foo(; a = 1) = new(a))
    @test JLFunction(ex).kwargs[1] == Expr(:kw, :a, 1)
end

@testset "JLStruct(ex)" begin
    @test JLField(;name=:x).name === :x
    @test JLField(;name=:x).type === Any
    @test JLStruct(;name=:Foo).name === :Foo

    ex = :(struct Foo
        x::Int
    end)

    jlstruct = JLStruct(ex)
    println(jlstruct)
    @test jlstruct.name === :Foo
    @test jlstruct.ismutable === false
    @test length(jlstruct.fields) == 1
    @test jlstruct.fields[1].name === :x
    @test jlstruct.fields[1].type === :Int
    @test jlstruct.fields[1].line isa LineNumberNode
    @test codegen_ast(jlstruct) == ex

    ex = :(mutable struct Foo{T, S <: Real} <: AbstractArray
        a::Float64

        function foo(x, y, z)
            new(1)
        end
    end)

    jlstruct = JLStruct(ex)
    println(jlstruct)
    @test jlstruct.ismutable == true
    @test jlstruct.name === :Foo
    @test jlstruct.typevars == Any[:T, :(S <: Real)]
    @test jlstruct.supertype == :AbstractArray
    @test jlstruct.misc[1] == ex.args[3].args[end]
    @test rm_lineinfo(codegen_ast(jlstruct)) == rm_lineinfo(ex)

    ex = quote
        """
        Foo
        """
        struct Foo
            "xyz"
            x::Int
            y

            Foo(x) = new(x)
            1 + 1
        end
    end
    ex = ex.args[2]
    jlstruct = JLStruct(ex)
    @test jlstruct.doc == "Foo\n"
    @test jlstruct.fields[1].doc == "xyz"
    @test jlstruct.fields[2].type === Any
    @test jlstruct.constructors[1].name === :Foo
    @test jlstruct.constructors[1].args[1] === :x
    @test jlstruct.misc[1] == :(1 + 1)
    ast = codegen_ast(jlstruct)
    @test ast.args[1] == GlobalRef(Core, Symbol("@doc"))
    @test ast.args[3] == "Foo\n"
    @test ast.args[4].head === :struct
    @test is_fn(ast.args[4].args[end].args[end-1])
    println(jlstruct)

    @test_throws AnalysisError split_struct_name(:(function Foo end))
end

@testset "JLKwStruct" begin
    @test JLKwField(;name=:x).name === :x
    @test JLKwField(;name=:x).type === Any
    @test JLKwStruct(;name=:Foo).name === :Foo

    def = @expr JLKwStruct struct Foo1{N, T}
        x::T = 1
    end
    println(def)

    @test_expr codegen_ast_kwfn(def, :create) == quote
        function create(::Type{var"##T#613"}; x = 1) where {N, T, var"##T#613" <: Foo}
            Foo1{N, T}(x)
        end
        function create(::Type{var"##T#614"}; x = 1) where {N, var"##T#614" <: Foo{N}}
            Foo1{N}(x)
        end
    end

    @test_expr codegen_ast(def) == quote
        struct Foo1{N, T}
            x::T
        end
        function Foo1{N, T}(; x = 1) where {N, T}
            Foo1{N, T}(x)
        end
        function Foo1{N}(; x = 1) where N
            Foo1{N}(x)
        end
    end

    def = @expr JLKwStruct struct Foo2 <: AbstractFoo
        x = 1
        y::Int
    end

    @test_expr codegen_ast(def) == quote
        struct Foo2 <: AbstractFoo
            x
            y::Int
        end
        function Foo2(; x = 1, y)
            Foo2(x, y)
        end
    end

    ex = quote
        """
        Foo
        """
        mutable struct Foo
            "abc"
            a::Int = 1
            b

            Foo(x) = new(x)
            1 + 1
        end
    end
    ex = ex.args[2]
    jlstruct = JLKwStruct(ex)
    @test jlstruct.doc == "Foo\n"
    @test jlstruct.fields[1].doc == "abc"
    @test jlstruct.fields[2].name === :b
    @test jlstruct.constructors[1].name === :Foo
    @test jlstruct.misc[1] == :(1 + 1)
    println(jlstruct)

    def = @expr JLKwStruct struct Foo3
        a::Int = 1
        Foo3(;a = 1) = new(a)
    end

    @test_expr codegen_ast(def) == quote
        struct Foo3
            a::Int
            Foo3(; a = 1) = new(a)
        end
    end
end

@testset "codegen_match" begin
    ex = codegen_match(:x) do
        quote
            1 => true
            2 => false
            _ => nothing
        end
    end

    eval(codegen_ast(JLFunction(;name=:test_match, args=[:x], body=ex)))

    @test test_match(1) == true
    @test test_match(2) == false
    @test test_match(3) === nothing
end

@test sprint(print, AnalysisError("a", "b")) == "expect a expression, got b."

@testset "JLIfElse" begin
    jl = JLIfElse()
    jl.map[:(foo(x))] = :(x = 1 + 1)
    jl.map[:(goo(x))] = :(y = 1 + 2)
    jl.otherwise = :(error("abc"))
    println(jl)
    ex = codegen_ast(jl)
    @test ex.head === :if
    @test ex.args[1] == :(foo(x))
    @test ex.args[2].args[1] == :(x = 1 + 1)
    @test ex.args[3].head === :elseif
end

@testset "JLMatch" begin
    jl = JLMatch(:x)
    jl.map[1] = true
    jl.map[2] = :(sin(x))
    println(jl)
    ex = codegen_ast(jl)
    jl = JLFunction(;name=:test_match, args=[:x], body=ex)
    println(jl)
    eval(codegen_ast(jl))

    @test test_match(1) == true
    @test test_match(2) == sin(2)
    @test test_match(3) === nothing
end

@testset "JLFor" begin
    ex = :(for i in 1:10, j in 1:20,
            k in 1:10
        1 + 1
    end)
    jl = JLFor(ex)
    println(jl)
    @test codegen_ast(jl) == ex

    jl = JLFor(;vars=[:x], iterators=[:itr], kernel=:(x + 1))
    ex = codegen_ast(jl)
    @test ex.head === :for
    @test ex.args[1].args[1] == :(x = itr)
    @test ex.args[2] == :(x+1)

    ex = :(for i in 1:10
        1 + 1
    end)
    jl = JLFor(ex)
    println(jl)
    @test jl.vars == [:i]
    @test jl.iterators == [:(1:10)]
end
