
"""
	struct ExtractDict{S} <: AbstractExtractor
		dict::S
	end

extracts all items in `dict` and return them as a `Mill.ProductNode`.
If a key is missing in extracted dict, `nothing` is passed to the child extractors.

# Examples

```jldoctest
julia> e = ExtractDict(Dict(:a=>ExtractScalar(Float32, 2, 3), :b=>ExtractCategorical(1:5)))
Dict
  ├── a: Float32
  └── b: Categorical d = 6

julia> res1 = e(Dict("a"=>1, "b"=>1))
ProductNode with 1 obs
  ├── a: ArrayNode(1×1 Array with Union{Missing, Float32} elements) with 1 obs
  └── b: ArrayNode(6×1 MaybeHotMatrix with Union{Missing, Bool} elements) with 1 obs

julia> res1[:a].data
1×1 Array{Union{Missing, Float32},2}:
 -3.0f0

julia> res1[:b].data
6×1 Mill.MaybeHotMatrix{Union{Missing, Int64},Int64,Union{Missing, Bool}}:
  true
 false
 false
 false
 false
 false

julia> res2 = e(Dict("a"=>0))
ProductNode with 1 obs
  ├── a: ArrayNode(1×1 Array with Union{Missing, Float32} elements) with 1 obs
  └── b: ArrayNode(6×1 MaybeHotMatrix with Union{Missing, Bool} elements) with 1 obs

julia> res2[:a].data
1×1 Array{Union{Missing, Float32},2}:
 -6.0f0

julia> res2[:b].data
6×1 Mill.MaybeHotMatrix{Union{Missing, Int64},Int64,Union{Missing, Bool}}:
 missing
 missing
 missing
 missing
 missing
 missing
```
"""
struct ExtractDict{S} <: AbstractExtractor
	dict::S
	function ExtractDict(d::S) where {S<:Dict}
		new{typeof(d)}(d)
	end
end

function Base.getindex(m::ExtractDict, s::Symbol)
	!isnothing(m.dict) && haskey(m.dict, s) && return m.dict[s]
	nothing
end

Base.keys(e::ExtractDict) = keys(e.dict)

replacebyspaces(pad) = map(s -> (s[1], " "^length(s[2])), pad)
(s::ExtractDict)(v::MissingOrNothing; store_input=false) = s(Dict{String,Any}())
(s::ExtractDict)(v; store_input=false)  = s(nothing)


function (s::ExtractDict{S})(v::Dict; store_input=false) where {S<:Dict}
	o = [Symbol(k) => f(get(v,String(k),nothing); store_input) for (k,f) in s.dict]
	ProductNode((; o...))
end

function (s::ExtractDict{S})(ee::ExtractEmpty; store_input=false) where {S<:Dict}
	o = [Symbol(k) => f(ee; store_input) for (k,f) in s.dict]
	ProductNode((; o...))
end

extractbatch(extractor, samples) = mapreduce(extractor, catobs, samples)

Base.hash(e::ExtractDict, h::UInt) = hash(e.dict, h)
Base.:(==)(e1::ExtractDict, e2::ExtractDict) = e1.dict == e2.dict
