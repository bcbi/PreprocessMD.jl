"""
Medically informed data transformations
"""
module PreprocessMD

using DataFrames: AbstractDataFrame
using DataFrames: combine
using DataFrames: DataFrame
using DataFrames: groupby
using DataFrames: insertcols!
using DataFrames: Not
using DataFrames: nrow
using DataFrames: select
using DataFrames: unstack
using MLJ: @load
using MLJ: accuracy
using MLJ: coerce!
using MLJ: evaluate
using MLJ: f1score
using MLJ: fit!
using MLJ: machine
using MLJ: mode
using MLJ: OrderedFactor
using MLJ: partition
using MLJ: predict
using MLJDecisionTreeInterface: DecisionTreeClassifier
using Tables: istable
using Tables: getcolumn

```@meta
DocTestSetup = quote
	using DataFrames
end
```

export add_label_column!, MLDemo, pivot, top_n_values


"""
    function add_label_column!(to_df::AbstractDataFrame, from_df::AbstractDataFrame, id=nothing, new_col_name=nothing)::Nothing

Add column to a DataFrame based on symbol presence in the target DataFrame

# Examples
```jldoctest
julia> df = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], 
             fur_color=["blue", "red", "green", "blue"]);

```
"""
function add_label_column!(to_df::AbstractDataFrame, from_df::AbstractDataFrame, id=nothing, new_col_name=nothing)::Nothing

#julia> using PreprocessMD: pivot
#julia> pivot(df)
#4×4 DataFrame
# Row │ name            blue   red    green 
#     │ String          Bool   Bool   Bool  
#─────┼─────────────────────────────────────
#   1 │ Cookie Monster   true  false  false
#   2 │ Elmo            false   true  false
#   3 │ Oscar           false  false   true
#   4 │ Grover           true  false  false

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
	if isnothing(id)
		id = Symbol(names(to_df)[1])
	end
	if isnothing(new_col_name)
		new_col_name = :LABEL
	end

	# Add column
	#insertcols!(to_df, new_col_name => [x[id] in from_df[!,id] for x in eachrow(to_df)])
	insertcols!(to_df, new_col_name => map(x -> x in from_df[!, id], to_df[!, id]))

	coerce!(to_df, new_col_name => OrderedFactor{2})
	return nothing
end
function add_label_column!(to_table, from_table, id=nothing, new_col_name=nothing
)::Nothing
	assert_is_table(to_table)
	assert_is_table(from_table)

	to_df = DataFrame(to_table)::DataFrame
	from_df = DataFrame(to_table)::DataFrame

	to_df::DataFrame
	from_df::DataFrame

	return add_label_column!(to_df, from_df, id, new_col_name)
end

function assert_is_table(x)
	if !istable(x)
		msg = "Input must be a table, but $(typeof(x)) is not a table"
		throw(ArgumentError(msg))
	end
	return nothing
end

"""
    function pivot()

Express the long format DataFrame `df` as a wide format DataFrame `B`.

Optional arguments `x` and `y` are columns of `df`.
The single column `x` (the first column of `df`, by default) becomes the row names of `B`.
Column(s) `y` (all columns besides `x`, by default) become the column names of `B`.
"""
function pivot(obj, newcols=nothing, y=nothing)::AbstractDataFrame

	assert_is_table(obj)
	df = DataFrame(obj)::DataFrame
	df::DataFrame

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
		combine(groupby(df, [newcols, y]), nrow => :count), newcols, y, :count; fill=0
	)
	for q in names(select(B, Not(newcols)))
		B[!, q] = B[!, q] .!= 0
	end
	return B
end
#=
function pivot!(df::AbstractDataFrame, x=nothing, y=nothing)::Nothing
	df = pivot(df,x,y)
	return nothing
end
=#

#=
"""
    function repr(df::AbstractDataFrame)::Nothing
Print Julia-readable definition of a DataFrame
"""
function repr(df::AbstractDataFrame)::Nothing
	# https://discourse.julialang.org/t/given-an-object-return-julia-code-that-defines-the-object/80579/12
	invoke(show, Tuple{typeof(stdout),Any}, stdout, df)
	return nothing
end
=#

"""
    function top_n_values(df::AbstractDataFrame, col::Symbol, n::Int)::AbstractDataFrame
Find top n values by occurence
Useful for initial feasibility checks, but medical codes are not considered
"""
function top_n_values(df::AbstractDataFrame, col::Symbol, n::Int)::AbstractDataFrame
	return first(sort(combine(nrow, groupby(df, col)), "nrow"; rev=true), n)
end

"""
    function MLDemo(df::AbstractDataFrame, output::Symbol, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
Decision tree classifier on a DataFrame over a given output
"""
function MLDemo(df::AbstractDataFrame, output::Symbol, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
               y = df[:, output]
               X = select(df, Not([:person_id, output]))
               
               train, test = partition(eachindex(y), 0.8, shuffle = true, rng = RNG_VALUE)

               # Evaluate model
               Tree = @load DecisionTreeClassifier pkg=DecisionTree verbosity=0
               tree_model = Tree(max_depth = 3)
               evaluate(tree_model, X, y) |> display

               # Return scores
               tree = machine(tree_model, X, y)
               fit!(tree, rows = train)
               yhat = predict(tree, X[test, :])
               acc = accuracy(mode.(yhat), y[test])
               f1_score = f1score(mode.(yhat), y[test])

               return acc, f1_score
       end

end #module PreprocessMD

#=

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

=#
