
"""
Medically informed data transformations
"""
module PreprocessMD

using DataFrames

import ScientificTypes:coerce!
import ScientificTypesBase:OrderedFactor

export add_label_column!, pivot, repr

"""
	function add_label_column!(df::AbstractDataFrame, symb::Symbol, target_df::AbstractDataFrame)::Nothing
Add column to a DataFrame based on symbol presence in the target DataFrame 

"""
function add_label_column!(to_df::AbstractDataFrame, from_df::AbstractDataFrame,
	label_symb_to=nothing, label_symb_from=nothing,
	new_col_name=nothing,
	)::Nothing

	# Error checks
	for arg in [to_df, from_df]
		if size(arg)[1] < 1
			#@warn "DataFrame must have at least 1 row"
			throw(DomainError(arg))
		end
		if size(arg)[2] < 1
			#@warn "DataFrame must have at least 1 column"
			throw(DomainError(arg))
		end
	end

	# Assign missing arguments
	if isnothing(label_symb_to)
		label_symb_to = Symbol(names(to_df)[1])
	end
	if isnothing(label_symb_from)
		label_symb_from = label_symb_to
	end
	if isnothing(new_col_name)
		new_col_name = :LABEL
	end

	# Add column
	insertcols!(to_df, new_col_name => [x[label_symb_to] in from_df[!,label_symb_from] for x in eachrow(to_df)])
	coerce!(to_df, new_col_name => OrderedFactor{2})
	return nothing
end

"""
    function pivot(df::AbstractDataFrame[, x, y])::AbstractDataFrame

Express the long format DataFrame `df` as a wide format DataFrame `B`.

Optional arguments `x` and `y` are columns of `df`.
The single column `x` (the first column of `df`, by default) becomes the row names of `B`.
Column(s) `y` (all columns besides `x`, by default) become the column names of `B`.
"""
function pivot(df::AbstractDataFrame, newcols=nothing, y=nothing)::AbstractDataFrame
	# Error checks
	if size(df)[1] < 1
		#@warn "DataFrame must have at least 1 row"
		throw(DomainError(df))
	end
	if size(df)[2] < 2
		#@warn "DataFrame must have at least 2 columns"
		throw(DomainError(df))
	end

	# Assign missing arguments
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
#=
function pivot!(df::AbstractDataFrame, x=nothing, y=nothing)::Nothing
	df = pivot(df,x,y)
	df |> display
	return nothing
end
=#

"""
	function repr(df::AbstractDataFrame)::Nothing
Print Julia-readable definition of a DataFrame
"""
function repr(df::AbstractDataFrame)::Nothing
	# https://discourse.julialang.org/t/given-an-object-return-julia-code-that-defines-the-object/80579/12
	invoke(show, Tuple{typeof(stdout), Any}, stdout, df)
	return nothing
end
function repr(df::DataFrame)::Nothing
	# https://discourse.julialang.org/t/given-an-object-return-julia-code-that-defines-the-object/80579/12
	invoke(show, Tuple{typeof(stdout), Any}, stdout, df)
	return nothing
end

end #module PreprocessMD


"""
Functions that require significant and breaking changes before release
"""
#=
module EXPERIMENTAL


"""
	function dataframe_subset(df::AbstractDataFrame, check::Any)::AbstractDataFrame
Return a DataFrame subset
For check::DataFrame, including only PATIENTs present in check
Otherwise, Subset DataFrame of PATIENTs with condition
Condition column name is given by symb
"""
function dataframe_subset(df::AbstractDataFrame, check::AbstractDataFrame, symb::Symbol)::DataFrame
	return filter(symb => x -> x in check.PATIENT, df)
end
function dataframe_subset(df::AbstractDataFrame, check::Any, symb::Symbol)::AbstractDataFrame
	return filter(symb => x -> isequal(x, check), df)
end

"""
	function run_decision_tree(df::AbstractDataFrame, output::Symbol, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
Decision tree classifier on a DataFrame over a given output
"""
function run_decision_tree(df::AbstractDataFrame, output::Symbol, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
	y = df[:, output]
	X = select(df, Not([:PATIENT, output]))
	
	train, test = partition(eachindex(y), 0.8, shuffle = true, rng = RNG_VALUE)

	# Evaluate model
	Tree = @load DecisionTreeClassifier pkg=DecisionTree verbosity=0
	tree_model = Tree(max_depth = 3)
	evaluate(tree_model, X, y) |> display

	# Return scores
	tree = machine(tree_model, X, y)
	fit!(tree, rows = train)
	yhat = predict(tree, X[test, :])
	acc = accuracy(MLJ.mode.(yhat), y[test])
	f1_score = f1score(MLJ.mode.(yhat), y[test])

	return acc, f1_score
end

"""
	function top_n_values(df::DataFrame, col::Symbol, n::Int)::DataFrame
Find top n values by occurence
Useful for initial feasibility checks, but medical codes are not considered
"""
function top_n_values(df::DataFrame, col::Symbol, n::Int)::DataFrame
	return first(sort(combine(nrow, groupby(df, col)), "nrow", rev=true), n)
end


end #module EXPERIMENTAL
=#
