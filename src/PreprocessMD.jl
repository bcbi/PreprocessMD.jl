

"""
Functions that use medical codes for data transformations
"""
module PreprocessMD

using CSV: File
using DataFrames

export long_to_wide, wide_to_long

"""
    function long_to_wide(df::AbstractDataFrame[, x, y])::AbstractDataFrame

Express the long format DataFrame `df` as a wide format DataFrame `B`.

Optional arguments `x` and `y` are columns of `df`.
The single column `x` (the first column of `df`, by default) becomes the row names of `B`.
Column(s) `y` (all columns besides `x`, by default) become the column names of `B`.
"""
function long_to_wide(df::AbstractDataFrame, x=nothing, y=nothing)::AbstractDataFrame

	if size(df)[2] < 2
		#@warn "DataFrame must have at least 2 columns"
		throw(DomainError(df))
	end

	if isnothing(x)
		x = Symbol(names(df)[1])
	end
	if isnothing(y)
		#y = Symbol.(names(select(df, Not(x))))
		y = Symbol(names(df)[2])
	end

        B = unstack(combine(groupby(df, [x,y]), nrow => :count), x, y, :count, fill=0)
        for q in names(select(B, Not(x)))
                B[!,q] = B[!,q] .!= 0
        end
	sort!(B)
        return B
end

"""
Express a long format DataFrame as a wide format DataFrame.
"""
wide_to_long = stack

end #module PreprocessMD
































































