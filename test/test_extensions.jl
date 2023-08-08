using StaticArrays
using FillArrays

@testset "extensions" begin
    @testset "StaticArrays" begin
        n = 5
        for T in (Float32, Float64)
            A = rand(T, n, n)

            b = SVector{n}(rand(T, n))
            @test Krylov.ktypeof(b) == Vector{T}
            x, stats = gmres(A, b)
            @test stats.solved

            b = MVector{n}(rand(T, n))
            @test Krylov.ktypeof(b) == Vector{T}
            x, stats = gmres(A, b)
            @test stats.solved

            b = SizedVector{n}(rand(T, n))
            @test Krylov.ktypeof(b) == Vector{T}
            x, stats = gmres(A, b)
            @test stats.solved
        end
    end

    @testset "FillArrays" begin
        n = 5
        for T in (Float32, Float64)
            A = rand(T, n, n)

            b = Ones(T, n)
            @test Krylov.ktypeof(b) == Vector{T}
            x, stats = gmres(A, b)
            @test stats.solved

            b = Zeros(T, n)
            @test Krylov.ktypeof(b) == Vector{T}
            x, stats = gmres(A, b)
            @test stats.solved
        end
    end
end
