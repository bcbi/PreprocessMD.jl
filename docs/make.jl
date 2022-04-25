push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(;
	authors="Ashlin Harris",
	sitename="PreprocessMD",
)

deploydocs(
	repo = "github.com/ashlinharris/PreprocessMD.jl",
	versions = nothing,
)

