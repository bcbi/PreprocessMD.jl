# Run this make file to check doctests locally

#using PreprocessMD: PreprocessMD

#using Documenter: HTML
#using Documenter: makedocs
#using Documenter: deploydocs

using PreprocessMD, Documenter
DocMeta.setdocmeta!(PreprocessMD, :DocTestSetup, :(using DataFrames, PreprocessMD); recursive=true)

makedocs(;
	modules=[PreprocessMD],
	authors="Ashlin Harris, Brown Center for Biomedical Informatics, and contributors",
	repo="https://github.com/bcbi/PreprocessMD.jl/blob/{commit}{path}#L{line}",
	sitename="PreprocessMD",
	pages=["Home" => "index.md"],
	strict=true,
	doctest = true
)

#deploydocs(; repo="github.com/bcbi/PreprocessMD.jl", devbranch="main")
