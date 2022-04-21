module PreprocessMD

export long_to_wide, wide_to_long

using DataFrames
using ConfParser

function long_to_wide(df::AbstractDataFrame, x=nothing, y=nothing)::AbstractDataFrame

	if size(df)[2] < 2
		#@warn "ReformatMD: DataFrame must have at lease 2 columns"
		throw(DomainError(df))
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

wide_to_long = stack

end # module PreprocessMD

module PreprocessCSV

"""
	function get_data(file_name::String)::AbstractDataFrame
Return the contents of a CSV file as a DataFrame
"""
function get_data(file_name::String)::AbstractDataFrame
	conf = ConfParse("./config.ini")
	parse_conf!(conf)
	path = retrieve(conf, "local", "med_code_directory")
	
	file = joinpath(path, file_name)
	return File(file, header = 1) |> DataFrame
end

end #module PreprocessCSV
































































