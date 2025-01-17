"""
    P = permutation_paige(k)

Return the sparse (2k) × (2k) matrix

    [e₁    •    eₖ   ]
    [   e₁    •    eₖ]
"""
function permutation_paige(k)
  P = spzeros(Float64, 2k, 2k)
  for i = 1:k
    P[i,2i-1] = 1.0
    P[i+k,2i] = 1.0
  end
  return P
end

@testset "processes" begin
  m = 250
  n = 500
  k = 20
  
  for FC in (Float64, ComplexF64)
    R = real(FC)
    nbits_FC = sizeof(FC)
    nbits_R = sizeof(R)
    nbits_I = sizeof(Int)

    @testset "Data Type: $FC" begin
      
      @testset "Hermitian Lanczos" begin
        A, b = symmetric_indefinite(n, FC=FC)
        V, T = hermitian_lanczos(A, b, k)

        @test A * V[:,1:k] ≈ V * T

        storage_hermitian_lanczos_bytes(n, k) = 4k * nbits_I + (3k-1) * nbits_R + n*(k+1) * nbits_FC

        expected_hermitian_lanczos_bytes = storage_hermitian_lanczos_bytes(n, k)
        actual_hermitian_lanczos_bytes = @allocated hermitian_lanczos(A, b, k)
        @test expected_hermitian_lanczos_bytes ≤ actual_hermitian_lanczos_bytes ≤ 1.02 * expected_hermitian_lanczos_bytes
      end

      @testset "Non-Hermitian Lanczos" begin
        A, b = nonsymmetric_definite(n, FC=FC)
        c = -b
        V, T, U, Tᴴ = nonhermitian_lanczos(A, b, c, k)

        @test T[1:k,1:k] ≈ Tᴴ[1:k,1:k]'
        @test A  * V[:,1:k] ≈ V * T
        @test A' * U[:,1:k] ≈ U * Tᴴ

        storage_nonhermitian_lanczos_bytes(n, k) = 4k * nbits_I + (6k-2) * nbits_FC + 2*n*(k+1) * nbits_FC

        expected_nonhermitian_lanczos_bytes = storage_nonhermitian_lanczos_bytes(n, k)
        actual_nonhermitian_lanczos_bytes = @allocated nonhermitian_lanczos(A, b, c, k)
        @test expected_nonhermitian_lanczos_bytes ≤ actual_nonhermitian_lanczos_bytes ≤ 1.02 * expected_nonhermitian_lanczos_bytes
      end

      @testset "Arnoldi" begin
        A, b = nonsymmetric_indefinite(n, FC=FC)
        V, H = arnoldi(A, b, k)

        @test A * V[:,1:k] ≈ V * H

        function storage_arnoldi_bytes(n, k)
          return k*(k+1) * nbits_FC + n*(k+1) * nbits_FC
        end

        expected_arnoldi_bytes = storage_arnoldi_bytes(n, k)
        actual_arnoldi_bytes = @allocated arnoldi(A, b, k)
        @test expected_arnoldi_bytes ≤ actual_arnoldi_bytes ≤ 1.02 * expected_arnoldi_bytes
      end

      @testset "Golub-Kahan" begin
        A, b = under_consistent(m, n, FC=FC)
        V, U, L = golub_kahan(A, b, k)
        B = L[1:k+1,1:k]

        @test A  * V[:,1:k] ≈ U * B
        @test A' * U ≈ V * L'
        @test A' * A  * V[:,1:k] ≈ V * L' * B
        @test A  * A' * U[:,1:k] ≈ U * B * L[1:k,1:k]'

        storage_golub_kahan_bytes(m, n, k) = 3*(k+1) * nbits_I + (2k+1) * nbits_R + (n+m)*(k+1) * nbits_FC

        expected_golub_kahan_bytes = storage_golub_kahan_bytes(m, n, k)
        actual_golub_kahan_bytes = @allocated golub_kahan(A, b, k)
        @test expected_golub_kahan_bytes ≤ actual_golub_kahan_bytes ≤ 1.02 * expected_golub_kahan_bytes
      end

      @testset "Saunders-Simon-Yip" begin
        A, b = under_consistent(m, n, FC=FC)
        _, c = over_consistent(n, m, FC=FC)
        V, T, U, Tᴴ = saunders_simon_yip(A, b, c, k)

        @test T[1:k,1:k] ≈ Tᴴ[1:k,1:k]'
        @test A  * U[:,1:k] ≈ V * T
        @test A' * V[:,1:k] ≈ U * Tᴴ
        @test A' * A  * U[:,1:k-1] ≈ U * Tᴴ * T[1:k,1:k-1]
        @test A  * A' * V[:,1:k-1] ≈ V * T * Tᴴ[1:k,1:k-1]

        K = [zeros(FC,m,m) A; A' zeros(FC,n,n)]
        Pₖ = permutation_paige(k)
        Wₖ = [V[:,1:k] zeros(FC,m,k); zeros(FC,n,k) U[:,1:k]] * Pₖ
        Pₖ₊₁ = permutation_paige(k+1)
        Wₖ₊₁ = [V zeros(FC,m,k+1); zeros(FC,n,k+1) U] * Pₖ₊₁
        G = Pₖ₊₁' * [zeros(FC,k+1,k) T; Tᴴ zeros(FC,k+1,k)] * Pₖ
        @test K * Wₖ ≈ Wₖ₊₁ * G

        storage_saunders_simon_yip_bytes(m, n, k) = 4k * nbits_I + (6k-2) * nbits_FC + (n+m)*(k+1) * nbits_FC

        expected_saunders_simon_yip_bytes = storage_saunders_simon_yip_bytes(m, n, k)
        actual_saunders_simon_yip_bytes = @allocated saunders_simon_yip(A, b, c, k)
        @test expected_saunders_simon_yip_bytes ≤ actual_saunders_simon_yip_bytes ≤ 1.02 * expected_saunders_simon_yip_bytes
      end

      @testset "Montoison-Orban" begin
        A, b = under_consistent(m, n, FC=FC)
        B, c = over_consistent(n, m, FC=FC)
        V, H, U, F = montoison_orban(A, B, b, c, k)

        @test A * U[:,1:k] ≈ V * H
        @test B * V[:,1:k] ≈ U * F
        @test B * A * U[:,1:k-1] ≈ U * F * H[1:k,1:k-1]
        @test A * B * V[:,1:k-1] ≈ V * H * F[1:k,1:k-1]

        K = [zeros(FC,m,m) A; B zeros(FC,n,n)]
        Pₖ = permutation_paige(k)
        Wₖ = [V[:,1:k] zeros(FC,m,k); zeros(FC,n,k) U[:,1:k]] * Pₖ
        Pₖ₊₁ = permutation_paige(k+1)
        Wₖ₊₁ = [V zeros(FC,m,k+1); zeros(FC,n,k+1) U] * Pₖ₊₁
        G = Pₖ₊₁' * [zeros(FC,k+1,k) H; F zeros(FC,k+1,k)] * Pₖ
        @test K * Wₖ ≈ Wₖ₊₁ * G

        function storage_montoison_orban_bytes(m, n, k)
          return 2*k*(k+1) * nbits_FC + (n+m)*(k+1) * nbits_FC
        end

        expected_montoison_orban_bytes = storage_montoison_orban_bytes(m, n, k)
        actual_montoison_orban_bytes = @allocated montoison_orban(A, B, b, c, k)
        @test expected_montoison_orban_bytes ≤ actual_montoison_orban_bytes ≤ 1.02 * expected_montoison_orban_bytes
      end
    end
  end
end
