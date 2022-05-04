using Documenter, PreprocessMD

makedocs(;
	authors="Ashlin Harris",
	sitename="PreprocessMD.jl",
	pages=[
		"home" => "index.md",
	]
)

#https://juliadocs.github.io/Documenter.jl/stable/lib/public/#Documenter.deploydocs
deploydocs(
	repo="github.com/AshlinHarris/PreprocessMD.jl.git",
	versions=[
		"stable" => "v^",
		"latest" => "v#.#",
	],
)

