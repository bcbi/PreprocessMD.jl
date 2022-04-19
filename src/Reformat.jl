module Reformat

export long_to_wide

using DataFrames

greet() = print("Hello World!")

function long_to_wide(df::AbstractDataFrame, x=nothing, y=nothing)::AbstractDataFrame

	if isempty(df)
		@warn "Reformat: DataFrame must not be empty"
		return DataFrame()
	end

	if size(df)[2] == 1
		@warn "Reformat: DataFrame must have more than one column"
		return DataFrame()
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
        return B
end

end # module Reformat
































































