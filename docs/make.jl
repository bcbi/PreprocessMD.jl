#push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(;
	authors="Ashlin Harris",
	sitename="PreprocessMD.jl",
	pages=[
		"home" => "index.md",
	]
)

deploydocs(;
	repo="github.com/AshlinHarris/PreprocessMD.jl.git",
)

