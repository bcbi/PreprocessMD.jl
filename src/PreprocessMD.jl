
"""
Medically informed data transformations
"""
module PreprocessMD

using CSV: File
using DataFrames

export pivot

"""
Data transformations that are not directly contingent on medical data
"""

"""
    function pivot(df::AbstractDataFrame[, x, y])::AbstractDataFrame

Express the long format DataFrame `df` as a wide format DataFrame `B`.

Optional arguments `x` and `y` are columns of `df`.
The single column `x` (the first column of `df`, by default) becomes the row names of `B`.
Column(s) `y` (all columns besides `x`, by default) become the column names of `B`.
"""
function pivot(df::AbstractDataFrame, newcols=nothing, y=nothing)::AbstractDataFrame
	# Checks for DomainError
	if size(df)[1] < 1
		#@warn "DataFrame must have at least 1 row"
		throw(DomainError(df))
	end
	if size(df)[2] < 2
		#@warn "DataFrame must have at least 2 columns"
		throw(DomainError(df))
	end

	# Checks for arguments
	if isnothing(newcols)
		newcols = Symbol(names(df)[1])
	end
	if isnothing(y)
		#y = Symbol.(names(select(df, Not(newcols))))
		y = Symbol(names(df)[2])
	end

	# Pivot
        B = unstack(
		combine(groupby(df, [newcols,y]), nrow => :count),
		newcols, y, :count, fill=0,
	)
        for q in names(select(B, Not(newcols)))
                B[!,q] = B[!,q] .!= 0
        end
        return B
end

function pivot!(df::AbstractDataFrame, newcols=nothing, y=nothing)::AbstractDataFrame
	df = pivot(df,x,y)
end

end #module PreprocessMD
