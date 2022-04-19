module Reformat

export long_to_wide

using DataFrames

greet() = print("Hello World!")

function long_to_wide(df::AbstractDataFrame, x=nothing, y=nothing)::AbstractDataFrame
        B = unstack(combine(groupby(df, [x,y]), nrow => :count), x, y, :count, fill=0)
        for q in names(select(B, Not(x)))
                B[!,q] = B[!,q] .!= 0
        end
        return B
end

end # module
