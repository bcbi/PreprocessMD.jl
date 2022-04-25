push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(
	sitename="PreprocessMD",
	# root = PreprocessMD.package_directory("docs",),
)

deploydocs(
	repo = "github.com/ashlinharris/PreprocessMD.jl",
	versions = nothing,
)

