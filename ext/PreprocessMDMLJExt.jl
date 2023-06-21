module PreprocessMDMLJExt

using Dates, DataFrames, PreprocessMD, MLJ

using PreprocessMD: size_warning

using MLJ: coerce!
using MLJ: OrderedFactor

const COLUMN_TYPES = Union{String, Symbol}
const OPTIONAL_COLUMN_TYPES = Union{COLUMN_TYPES, Nothing}
const OPTIONAL_INT_TYPES = Union{Int,Nothing}

"""
	function add_label_column!(feature_df, source_df, new_column[, id])

Add a label column to a DataFrame based on symbol presence in the target DataFrame

A column from the target is not copied.
Instead, the new column is a `CategoricalArray` containing `true` for any ID that is present in the target and `false` otherwise.

# Arguments
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
function PreprocessMD.add_label_column!(
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

	size_warning(feature_df)
	size_warning(source_df)

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
	function set_label_column!(feature_df, source_df, new_column[, id])

Designate one column within a DataFrame as the label

# Arguments
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
function PreprocessMD.set_label_column!(
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

	size_warning(feature_df)

	# Assign missing arguments
	if isnothing(id)
		id = names(feature_df)[1]
	end

	# Set column as label
	coerce!(feature_df, col_name => OrderedFactor{2})
	return nothing
end

end # module
