push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(
	sitename="PreprocessMD",
	# root = PreprocessMD.package_directory("docs",),
        pages = ["Home" => "index.md",]
)

deploydocs(
	repo = "github.com/ashlinharris/PreprocessMD.jl.git",
	versions = nothing,
	target = "build",
	branch = "gh-pages",
	devbranch = "master",
	devurl = "development",
)

