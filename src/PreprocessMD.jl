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
using MLJ: coerce!
using MLJ: OrderedFactor

export add_label_column!, pivot, set_label_column!, subsetMD, top_n_values

const COLUMN_TYPES = Union{String, Symbol}
const OPTIONAL_COLUMN_TYPES = Union{COLUMN_TYPES, Nothing}
const OPTIONAL_INT_TYPES = Union{Int,Nothing}

"""
	function add_label_column!(feature_df, source_df, new_column[, id])

Add column to a DataFrame based on symbol presence in the target DataFrame

# Arguments
- `
- `feature_df::AbstractDataFrame`: feature DataFrame to which label column is added
- `source_df::AbstractDataFrame`: DataFrame containing the label column
- `new_column::Union{String, Symbol}`: name assigned to label column
- `id::Union{Nothing, String, Symbol}`: row IDs (Default: first column)

# Examples
```jldoctest
julia> using DataFrames

julia> X = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], blue = [true, false, false, true], red  = [false, true, false, false], green = [false, false, true, false])
4×4 DataFrame
 Row │ name            blue   red    green
     │ String          Bool   Bool   Bool
─────┼─────────────────────────────────────
   1 │ Cookie Monster   true  false  false
   2 │ Elmo            false   true  false
   3 │ Oscar           false  false   true
   4 │ Grover           true  false  false

julia> Y = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], lovable = [true, true, false, true], furry = [true, true, true, true], old = [false, false, true, true])
4×4 DataFrame
 Row │ name            lovable  furry  old
     │ String          Bool     Bool   Bool
─────┼───────────────────────────────────────
   1 │ Cookie Monster     true   true  false
   2 │ Elmo               true   true  false
   3 │ Oscar             false   true   true
   4 │ Grover             true   true   true

julia> add_label_column!(X,Y,:furry)

julia> X
4×5 DataFrame
 Row │ name            blue   red    green  furry
     │ String          Bool   Bool   Bool   Cat…
─────┼────────────────────────────────────────────
   1 │ Cookie Monster   true  false  false  true
   2 │ Elmo            false   true  false  true
   3 │ Oscar           false  false   true  true
   4 │ Grover           true  false  false  true

```
"""
function add_label_column!(
	feature_df::AbstractDataFrame, 
	source_df::AbstractDataFrame, 
	new_column::COLUMN_TYPES,
	id::OPTIONAL_COLUMN_TYPES=nothing,
	)::Nothing

	# Error checks
	for arg in [feature_df, source_df]
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
		id = names(feature_df)[1]
	end

	# Add column
	#insertcols!(feature_df, new_column => [x[id] in source_df[!,id] for x in eachrow(feature_df)])
	insertcols!(feature_df, new_column => map(x -> x in source_df[!, id], feature_df[!, id]))

	coerce!(feature_df, new_column => OrderedFactor{2})
	return nothing
end

"""
	function pivot()

Express the long format DataFrame `df` as a wide format DataFrame `B`.

Optional arguments `x` and `y` are columns of `df`.
The single column `x` (the first column of `df`, by default) becomes the row names of `B`.
Column(s) `y` (all columns besides `x`, by default) become the column names of `B`.

# Examples
```jldoctest
julia> using DataFrames

julia> df = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], fur_color=["blue", "red", "green", "blue"])
4×2 DataFrame
 Row │ name            fur_color
     │ String          String
─────┼───────────────────────────
   1 │ Cookie Monster  blue
   2 │ Elmo            red
   3 │ Oscar           green
   4 │ Grover          blue

julia> pivot(df)
4×4 DataFrame
 Row │ name            blue   red    green
     │ String          Bool   Bool   Bool
─────┼─────────────────────────────────────
   1 │ Cookie Monster   true  false  false
   2 │ Elmo            false   true  false
   3 │ Oscar           false  false   true
   4 │ Grover           true  false  false

```
"""
function pivot(
	df::AbstractDataFrame,
	newcols::OPTIONAL_COLUMN_TYPES=nothing,
	y::OPTIONAL_COLUMN_TYPES=nothing,
	)::AbstractDataFrame

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
		newcols = names(df)[1]
	end
	if isnothing(y)
		#y = Symbol.(names(select(df, Not(newcols))))
		y = names(df)[2]

		# Ensure types match if only one argument is provided
		# NOTE: convert(typeof(::Symbol), ::String) doesn't work
		newcols_ = Symbol.(newcols)
		y_ = Symbol.(y)
	else
		newcols_=newcols
		y_=y
	end

	# Pivot
	B = unstack(
		combine(groupby(df, [newcols_, y_]), nrow => :count), newcols_, y_, :count; fill=0
	)
	for q in names(select(B, Not(newcols)))
		B[!, q] = B[!, q] .!= 0
	end
	return B
end

"""
	function set_label_column!(feature_df, source_df, new_column[, id])

Designate one column within a DataFrame as the label

# Arguments
- `
- `feature_df::AbstractDataFrame`: feature DataFrame
- `col_name::Union{String, Symbol}`: label column
- `id::Union{Nothing, String, Symbol}`: row IDs (Default: first column)

# Examples
```jldoctest
julia> using DataFrames

julia> X = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], lovable = [true, true, false, true], furry = [true, true, true, true], old = [false, false, true, true] )
4×4 DataFrame
 Row │ name            lovable  furry  old
     │ String          Bool     Bool   Bool
─────┼───────────────────────────────────────
   1 │ Cookie Monster     true   true  false
   2 │ Elmo               true   true  false
   3 │ Oscar             false   true   true
   4 │ Grover             true   true   true

julia> set_label_column!(X,:lovable)

julia> X
4×4 DataFrame
 Row │ name            lovable  furry  old
     │ String          Cat…     Bool   Bool
─────┼───────────────────────────────────────
   1 │ Cookie Monster  true      true  false
   2 │ Elmo            true      true  false
   3 │ Oscar           false     true   true
   4 │ Grover          true      true   true

```
"""
function set_label_column!(
	feature_df::AbstractDataFrame, 
	col_name::COLUMN_TYPES,
	id::OPTIONAL_COLUMN_TYPES=nothing,
	)::Nothing

	# Error checks
	for arg in [feature_df]
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
		id = names(feature_df)[1]
	end

	# Set column as label
	coerce!(feature_df, col_name => OrderedFactor{2})
	return nothing
end

"""
	function subsetMD(main_df, check_df, main_id, check_id)

Filtration step

# Arguments
- `main_df::AbstractDataFrame`: Rows are selected from this DataFrame...
- `check_df::AbstractDataFrame`: ... if the IDs are present in this DataFrame
- `main_id`: ID column from `main_df` (Default: first column)
- `check_id`: ID column from `check_df` (Default: same as `main_id`)

# Examples
```jldoctest
julia> using DataFrames

julia> X = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"], blue = [true, false, false, true], red  = [false, true, false, false], green = [false, false, true, false])
4×4 DataFrame
 Row │ name            blue   red    green
     │ String          Bool   Bool   Bool
─────┼─────────────────────────────────────
   1 │ Cookie Monster   true  false  false
   2 │ Elmo            false   true  false
   3 │ Oscar           false  false   true
   4 │ Grover           true  false  false

julia> Y = DataFrame(name=["Big Bird", "Cookie Monster", "Elmo"], fuzzy=[false, true, true])
3×2 DataFrame
 Row │ name            fuzzy
     │ String          Bool
─────┼───────────────────────
   1 │ Big Bird        false
   2 │ Cookie Monster   true
   3 │ Elmo             true

julia> subsetMD(X,Y)
2×4 DataFrame
 Row │ name            blue   red    green
     │ String          Bool   Bool   Bool
─────┼─────────────────────────────────────
   1 │ Cookie Monster   true  false  false
   2 │ Elmo            false   true  false

```
"""
function subsetMD(
	main_df::AbstractDataFrame,
	check_df::AbstractDataFrame,
	main_id::OPTIONAL_COLUMN_TYPES=nothing,
	check_id::OPTIONAL_COLUMN_TYPES=nothing,
	)::AbstractDataFrame

	# Assign missing arguments
	if isnothing(main_id)
		main_id = names(main_df)[1]
	end
	if isnothing(check_id)
		check_id = main_id
	end

	return filter(main_id => x -> x in check_df[!,check_id], main_df)
end

"""
	function top_n_values(df::AbstractDataFrame, col::Union{String, Symbol}, n::Int)::AbstractDataFrame
Find top n values by occurence
Useful for initial feasibility checks, but medical codes are not considered

# Examples
```jldoctest
julia> using DataFrames

julia> df = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover", "Big Bird", "Ernie", "Bert", "Rosita"], fur_color=["blue", "red", "green", "blue", "yellow", "orange", "yellow", "blue"])
8×2 DataFrame
 Row │ name            fur_color
     │ String          String
─────┼───────────────────────────
   1 │ Cookie Monster  blue
   2 │ Elmo            red
   3 │ Oscar           green
   4 │ Grover          blue
   5 │ Big Bird        yellow
   6 │ Ernie           orange
   7 │ Bert            yellow
   8 │ Rosita          blue

julia> top_n_values(df, :fur_color, 4)
4×2 DataFrame
 Row │ fur_color  nrow
     │ String     Int64
─────┼──────────────────
   1 │ blue           3
   2 │ yellow         2
   3 │ red            1
   4 │ green          1

```
"""
function top_n_values(
	df::AbstractDataFrame,
	col::COLUMN_TYPES,
	n::OPTIONAL_INT_TYPES=nothing
	)::AbstractDataFrame

	# Assign missing arguments
	if isnothing(n)
		n = 10
	end

	return first(sort(combine(nrow, groupby(df, col)), "nrow"; rev=true), n)
end

end #module PreprocessMD

