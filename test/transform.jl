using Test
using Expronicon
using Expronicon.Transform

@testset "name_only" begin
    @test name_only(:(x::Int)) == :x
    @test name_only(:(T <: Int)) == :T
    @test name_only(:(Foo{T} where T)) == :Foo
    @test name_only(:(Foo{T})) == :Foo
    @test_throws ErrorException name_only(Expr(:fake))
end

@testset "rm_lineinfo" begin
    ex = quote
        1 + 1
        2 + 2
    end
    
    @test rm_lineinfo(ex) == Expr(:block, :(1 + 1), :(2 + 2))

    ex = quote
        Base.@kwdef mutable struct D
            field1::Union{ID, Missing, Nothing} = nothing
        end
        StructTypes.StructType(::Type{D}) = begin
            StructTypes.Mutable()
        end
        StructTypes.omitempties(::Type{D}) = begin
            true
        end
    end

    @test rm_lineinfo(ex).args[1].args[end] == rm_lineinfo(:(mutable struct D
        field1::Union{ID, Missing, Nothing} = nothing
    end))
    @test rm_lineinfo(ex).args[2] == rm_lineinfo(:(StructTypes.StructType(::Type{D}) = begin
        StructTypes.Mutable()
    end))
    @test rm_lineinfo(ex).args[3] == rm_lineinfo(:(StructTypes.omitempties(::Type{D}) = begin
        true
    end))
end

@testset "flatten_blocks" begin
    ex = quote
        1 + 1
        begin
            2 + 2
        end
    end
    
    @test rm_lineinfo(flatten_blocks(ex)) == Expr(:block, :(1+1), :(2+2))        
end

@testset "rm_annotations" begin
    ex = quote
        x :: Int
        begin
            y::Float64
        end
    end
    
    @test rm_lineinfo(rm_annotations(ex)) == quote
        x
        begin
            y
        end
    end|>rm_lineinfo
    
    ex = :(sin(::Float64; x::Int=2))
    ex = rm_annotations(ex)
    @test ex.head === :call
    @test ex.args[1] === :sin
    @test ex.args[2].head === :parameters
    @test ex.args[2].args[1] === :x
    @test ex.args[3] isa Symbol
end

@testset "prettify" begin
    ex = quote
        x :: Int
        begin
            y::Float64
        end
    end

    @test prettify(ex) == quote
        x::Int
        y::Float64
    end|>rm_lineinfo
end
