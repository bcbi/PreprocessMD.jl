#push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(;
	authors="Ashlin Harris",
	sitename="PreprocessMD.jl",
	modules=[PreprocessMD],
	pages=[
		"home" => "index.md",
	]
)

deploydocs(;
	repo="github.com/ashlinharris/PreprocessMD.jl",
)

