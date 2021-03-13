using Test
using Expronicon
using Expronicon.Types
using Expronicon.Analysis
using Expronicon.CodeGen
using Expronicon.Transform

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
    ex = :(function foo(x::Int, y::Type{T}) where {T <: Real}
        return x
    end)

    jlfn = JLFunction(ex)
    @test jlfn.head === :function
    @test jlfn.name === :foo
    @test jlfn.args == Any[:(x::Int), :(y::Type{T})]
    @test jlfn.kwargs === nothing
    @test jlfn.whereparams == Any[:(T <: Real)]
    @test jlfn.body == ex.args[2]
    @test codegen_ast(jlfn) == ex
    @test is_kw_fn(jlfn) == false

    ex = :(function (x, y)
        return 2
    end)

    jlfn = JLFunction(ex)
    println(jlfn)
    @test jlfn.head === :function
    @test jlfn.args == [:x, :y]
    @test jlfn.name === nothing
    @test jlfn.whereparams === nothing
    @test codegen_ast(jlfn) == ex

    ex = :(function (x, y; kw=2)
        return "aaa"
    end)

    jlfn = JLFunction(ex)
    println(jlfn)
    @test jlfn.head === :function
    @test jlfn.args == Any[:x, :y]
    @test jlfn.kwargs == Any[Expr(:kw, :kw, 2)]
    @test jlfn.name === nothing
    @test codegen_ast(jlfn) == ex
    @test is_kw_fn(jlfn) == true

    ex = :((x, y)->sin(x))

    jlfn = JLFunction(ex)
    println(jlfn)
    @test jlfn.head === :(->)
    @test jlfn.args == Any[:x, :y]
    @test jlfn.kwargs === nothing
    @test jlfn.name === nothing
    @test codegen_ast(jlfn) == ex

    # canonicalize head when it's a block
    ex = :(function (x::Int; kw=1) end)
    jlfn = JLFunction(ex)
    println(jlfn)
    @test jlfn.head === :function
    @test jlfn.args == Any[:(x::Int)]
    @test jlfn.kwargs == Any[Expr(:kw, :kw, 1)]
    @test codegen_ast(jlfn) == Expr(:function, Expr(:tuple, Expr(:parameters, Expr(:kw, :kw, 1)), :(x::Int)), jlfn.body)
end

@testset "JLStruct(ex)" begin
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

        abc
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
    @test jlstruct.doc == "    Foo\nabc\n"
    @test jlstruct.fields[1].doc == "xyz"
    @test jlstruct.fields[2].type === Any
    @test jlstruct.constructors[1].name === :Foo
    @test jlstruct.constructors[1].args[1] === :x
    @test jlstruct.misc[1] == :(1 + 1)
end

@testset "JLKwStruct" begin
    ex = :(struct Foo{N, T}
        x::T = 1
    end)

    def = JLKwStruct(ex)
    println(def)

    @test rm_lineinfo(codegen_ast(def)) == rm_lineinfo(quote
        struct Foo{N, T}
            x::T
        end
        function Foo{N}(; x::T = 1) where {N, T}
            Foo{N, T}(x)
        end
    end)

    ex = :(struct Foo <: AbstractFoo
        x = 1
        y::Int
    end)

    def = JLKwStruct(ex)

    @test rm_lineinfo(codegen_ast(def)) == rm_lineinfo(quote
        struct Foo <: AbstractFoo
            x
            y::Int
        end
        function Foo(; x = 1, y::Int)
            Foo(x, y)
        end
    end)

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
