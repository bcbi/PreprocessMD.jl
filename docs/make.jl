push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(;
	authors="Ashlin Harris",
	sitename="PreprocessMD.jl",
	# root = PreprocessMD.package_directory("docs",),
	format=Documenter.HTML(;
		prettyurls=get(ENV, "CI", "false") == "true",
		canonical="https://ashlinharris.github.io/AddLatest.jl",
		assets=String[],
	),
	pages=[
		"Home" => "index.md",
	],
	strict=true,
)

deploydocs(
	repo = "github.com/ashlinharris/PreprocessMD.jl",
	versions = nothing,
)

