# Contributing

Any preprocessing function that takes a DataFrame as input is a good candidate for inclusion in `src/PreprocessMD.jl`.
Functions for data scrubbing (further upstream) and data preparing (further downstream) might also be a good fit. 
Branches with additions may be submitted in a pull request, but issues with specific feature requests are also greatly appreciated!

At BCBI, `PreprocessMD.jl` is run on a secure enclave (no internet access, fixed registry).
The local Julia package environment is managed with [SIEGE-internal](https://github.com/bcbi/SIEGE-internal), so all dependencies should be included here
(A [public version of SIEGE](https://github.com/bcbi/SIEGE) is also available).

## Doctests

Generate missing doctest output:
```
$ cd PreprocessMD/docs/
$ julia --project
julia> using Pkg, Documenter
julia> Pkg.develop(path="..")
julia> using PreprocessMD
julia> DocMeta.setdocmeta!(PreprocessMD, :DocTestSetup, :(using DataFrames, PreprocessMD); recursive=true)
julia> doctest(PreprocessMD; fix=true)
```
