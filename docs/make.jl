push!(LOAD_PATH,"../src/")

using Documenter, PreprocessMD

makedocs(
	sitename="PreprocessMD",
)

deploydocs(
    repo = "github.com/ashlinharris/PreprocessMD.jl.git",
)



