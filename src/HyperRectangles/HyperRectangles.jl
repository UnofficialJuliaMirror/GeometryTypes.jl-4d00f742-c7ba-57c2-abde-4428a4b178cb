module HyperRectangles
using Compat

VERSION < v"0.4-" && using Docile

export AbstractHyperRectangle, HyperRectangle

abstract AbstractHyperRectangle{T, N}

type HyperRectangle{T, N} <: AbstractHyperRectangle{T, N}
    min::Vector{T}
    max::Vector{T}
end

function HyperRectangle{T}(min::Vector{T}, max::Vector{T})
    n = length(max)
    m = length(min)
    n == m || error("min and max vector lengths are different!")
    HyperRectangle{T, n}(min, max)
end

Base.max(b::HyperRectangle) = b.max
Base.min(b::HyperRectangle) = b.min
Base.length(b::HyperRectangle) = length(b.min)

function (==){T1, T2, N}(b1::HyperRectangle{T1, N}, b2::HyperRectangle{T2, N})
    b1.min == b2.min && b1.max == b2.max
end

isequal(b1::HyperRectangle, b2::HyperRectangle) = b1 == b2

@doc """
Check if HyperRectangles are contained in each other. This does not use
strict inequality, so HyperRectangles may share faces and this will still
return true.
""" ->
function Base.contains{T1, T2, N}(b1::HyperRectangle{T1,N}, b2::HyperRectangle{T2, N})
    for i = 1:N
        b2.max[i] <= b1.max[i] && b2.min[i] >= b1.min[i] || return false
    end
    true
end

@doc """
Check if a point is contained in a HyperRectangle. This will return true if
the point is on a face of the HyperRectangle.
""" ->
function Base.contains{T1, N}(b1::HyperRectangle{T1,N}, pt::AbstractVector)
    for i = 1:N
        pt[i] <= b1.max[i] && pt[i] >= b1.min[i] || return false
    end
    true
end

@doc """
Check if HyperRectangles are contained in each other. This does not use
strict inequality, so HyperRectangles may share faces and this will still
return true.
""" ->
Base.in(b1::HyperRectangle, b2::HyperRectangle) = contains(b2, b1)

@doc """
Check if a point is contained in a HyperRectangle. This will return true if
the point is on a face of the HyperRectangle.
""" ->
Base.in(pt::AbstractVector, b1::HyperRectangle) = contains(b1, pt)

@doc """
Splits an HyperRectangle into two new ones along an axis at a given axis value
""" ->
function Base.split{T, N}(b::HyperRectangle{T,N}, axis::Int, value::T)
    b1max = copy(b.max)
    b1max[axis] = value

    b2min = copy(b.min)
    b2min[axis] = value

    return HyperRectangle{T, N}(copy(b.min), b1max),
           HyperRectangle{T, N}(b2min, copy(b.max))
end

@doc """
Perform a union between two HyperRectangles.
""" ->
function Base.union{T,N}(h1::HyperRectangle{T,N}, h2::HyperRectangle{T,N})
    mins = zeros(T, N)
    maxs = zeros(T, N)
    for i = 1:N
        mins[i] = min(h1.min[i], h2.min[i])
        maxs[i] = max(h1.max[i], h2.max[i])
    end
    HyperRectangle{T,N}(mins, maxs)
end

@doc """
Perform a difference between two HyperRectangles.
""" ->
function Base.diff(h1::HyperRectangle, h2::HyperRectangle)
    h1
end

@doc """
Perform a intersection between two HyperRectangles.
""" ->
function Base.intersect{T,N}(h1::HyperRectangle{T,N}, h2::HyperRectangle{T,N})
    mins = zeros(T, N)
    maxs = zeros(T, N)
    for i = 1:N
        mins[i] = max(h1.min[i], h2.min[i])
        maxs[i] = min(h1.max[i], h2.max[i])
    end
    HyperRectangle{T,N}(mins, maxs)
end

if VERSION >= v"0.4.0-"
    function Base.call{T,N}(::Type{HyperRectangle{T,N}})
        max = fill(typemin(T), N)
        min = fill(typemax(T), N)
        HyperRectangle{T,N}(min, max)
    end
end

# submodules
include("Relations.jl")
include("Operations.jl")

end # module
