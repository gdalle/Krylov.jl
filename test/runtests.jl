using Krylov, LinearAlgebra, SparseArrays, StaticArrays, Printf, Random, Test
import Krylov.KRYLOV_SOLVERS

include("test_utils.jl")
include("test_aux.jl")
include("test_stats.jl")
include("test_processes.jl")

include("test_fgmres.jl")
include("test_gpmr.jl")
include("test_fom.jl")
include("test_gmres.jl")
include("test_bicgstab.jl")
include("test_usymlq.jl")
include("test_tricg.jl")
include("test_bilqr.jl")
include("test_trimr.jl")
include("test_trilqr.jl")
include("test_usymqr.jl")
include("test_qmr.jl")
include("test_lnlq.jl")
include("test_diom.jl")
include("test_cgs.jl")
include("test_dqgmres.jl")
include("test_cg.jl")
include("test_cg_lanczos.jl")
include("test_cg_lanczos_shift.jl")
include("test_minres.jl")
include("test_minres_qlp.jl")
include("test_symmlq.jl")
include("test_bilq.jl")
include("test_cgls.jl")
include("test_crls.jl")
include("test_cgne.jl")
include("test_crmr.jl")
include("test_lslq.jl")
include("test_lsqr.jl")
include("test_lsmr.jl")
include("test_craig.jl")
include("test_craigmr.jl")
include("test_cr.jl")

include("test_allocations.jl")
include("test_mp.jl")
include("test_solvers.jl")
include("test_warm_start.jl")
include("test_verbose.jl")
