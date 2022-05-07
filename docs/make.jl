using PreprocessMD: PreprocessMD

using Documenter: HTML
using Documenter: makedocs
using Documenter: deploydocs

makedocs(;
    modules=[PreprocessMD],
    authors="Ashlin Harris, Brown Center for Biomedical Informatics, and contributors",
    repo="https://github.com/bcbi/PreprocessMD.jl/blob/{commit}{path}#L{line}",
    sitename="PreprocessMD.jl",
    format=HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://bcbi.github.io/PreprocessMD.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
    strict=true,
)

deploydocs(; repo="github.com/bcbi/PreprocessMD.jl", devbranch="main")
