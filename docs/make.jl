using Documenter, PreprocessMD

makedocs(;
    authors="Ashlin Harris",
    sitename="PreprocessMD.jl",
    pages=["home" => "index.md"],
    strict=true,
)

#https://juliadocs.github.io/Documenter.jl/stable/lib/public/#Documenter.deploydocs
deploydocs(;
    repo="github.com/bcbi/PreprocessMD.jl.git",
    versions=["stable" => "v^", "latest" => "v#.#"],
)
