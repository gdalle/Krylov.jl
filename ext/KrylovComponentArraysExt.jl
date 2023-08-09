module KrylovComponentArraysExt

using Krylov: Krylov
using ComponentArrays: ComponentVector

"""
    Krylov.ktypeof(::ComponentVector{T,V}) where {T,V}

Return the corresponding (non-static) `V` type.
"""
Krylov.ktypeof(::ComponentVector{T,V}) where {T,V} = V

end
