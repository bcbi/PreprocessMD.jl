push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(
)

deploydocs(
	repo = "github.com/ashlinharris/PreprocessMD.jl.git",
	versions = nothing,
)



