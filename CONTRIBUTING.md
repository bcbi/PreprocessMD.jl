# Contributing

Any preprocessing function that takes a DataFrame as input is a good candidate for inclusion in `src/PreprocessMD.jl`.
Functions for data scrubbing (further upstream) and data preparing (further downstream) might also be a good fit. 
Branches with additions may be submitted in a pull request, but issues with specific feature requests are also appreciated!

`PreprocessMD.jl` needs to run on a secure system (no internet access, fixed registry).
Until we can make significant changes to our Julia environment maintenance pipeline (planned for Fall 2022), adding additional dependencies might not be feasible.
