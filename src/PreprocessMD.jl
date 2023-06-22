"""
# Description
Medically-informed data preprocessing for machine learning

"""
module PreprocessMD

using Dates: Year
using DataFrames: AbstractDataFrame
using DataFrames: combine
using DataFrames: DataFrame
using DataFrames: groupby
using DataFrames: insertcols!
using DataFrames: Not
using DataFrames: nrow
using DataFrames: select
using DataFrames: unstack

export add_label_column!, subset_invalid_year, pivot, set_label_column!, subsetMD, top_n_values, generate_cohort

add_label_column!() = nothing
set_label_column!() = nothing

const COLUMN_TYPES = Union{String, Symbol}
const OPTIONAL_COLUMN_TYPES = Union{COLUMN_TYPES, Nothing}
const OPTIONAL_INT_TYPES = Union{Int,Nothing}

"""
	function subset_invalid_year
# Arguments
#
# Examples
```jldoctest
julia> using PreprocessMD, Dates, DataFrames

julia> X = DataFrame(name=["Kermit", "Big Bird", "Herry", "Mr. Snuffleupagus", "Rosita", "Julia"], first_appearance=Date.(["1955-05-09", "1969-11-10", "1970-11-09", "1971-11-15", "1991-11-26", "2017-04-10"]))
6×2 DataFrame
 Row │ name               first_appearance
     │ String             Dates.Date
─────┼─────────────────────────────────────
   1 │ Kermit             1955-05-09
   2 │ Big Bird           1969-11-10
   3 │ Herry              1970-11-09
   4 │ Mr. Snuffleupagus  1971-11-15
   5 │ Rosita             1991-11-26
   6 │ Julia              2017-04-10

julia> subset_invalid_year(X, :first_appearance, 1969, 2000)
2×2 DataFrame
 Row │ name    first_appearance
     │ String  Dates.Date
─────┼──────────────────────────
   1 │ Kermit  1955-05-09
   2 │ Julia   2017-04-10

```
"""
function subset_invalid_year(df, col, min, max)
        filter( x-> !(Year(min) <= Year(x[col]) <= Year(max) ), df)
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

	size_warning(df)

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

function size_warning(df::AbstractDataFrame)::Nothing
	WARN_SIZE = 10 ^ 5
	if( size(df)[1] >= WARN_SIZE || size(df)[2] >= WARN_SIZE )
		@warn "This DataFrame is large. Computation may take a while."
	end
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

	size_warning(main_df)
	size_warning(check_df)

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

	size_warning(df)

	# Assign missing arguments
	if isnothing(n)
		n = 10
	end

	return first(sort(combine(nrow, groupby(df, col)), "nrow"; rev=true), n)
end
""" 
Function -> Generate_cohort
Inputs 
Col_name -> column name
domain_table -> the case table on which your concepts are based on example conditions, observations, drugs, measurements
concepts -> The list of concept id's you want to study
Output
Unique list of person ids in your cohort whom you want to study

# Examples
```jldoctest
julia> using DataFrames

julia> df_condition_occurrence = DataFrame(condition_occurrence_id=[123, 5433, 8765, 12345, 6457, 62898], person_id = [1, 2, 3, 4, 5, 6], condition_concept_id = [196523, 436659, 435515, 436096, 440383, 37311319])
6×3 DataFrame
 Row │ condition_occurrence_id  person_id  condition_concept_id
     │ Int64                    Int64      Int64
─────┼──────────────────────────────────────────────────────────
   1 │                     123          1                196523
   2 │                    5433          2                436659
   3 │                    8765          3                435515
   4 │                   12345          4                436096
   5 │                    6457          5                440383
   6 │                   62898          6              37311319

julia> concepts = [196523, 436659, 435515, 436096, 440383]
5-element Vector{Int64}:
 196523
 436659
 435515
 436096
 440383

julia> result = generate_cohort( :condition_concept_id, df_condition_occurrence, concepts)
5-element Vector{Int64}:
 1
 2
 3
 4
 5

```
"""
function generate_cohort(col_name, domain_table, concepts)
    # Filter the domain table by concept IDs
    filtered_table = filter(row -> row[col_name] in concepts, domain_table)

    return unique(filtered_table.person_id)
end

end #module PreprocessMD

