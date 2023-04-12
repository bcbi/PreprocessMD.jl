var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = PreprocessMD","category":"page"},{"location":"#PreprocessMD","page":"Home","title":"PreprocessMD","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for PreprocessMD.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Example-usage","page":"Home","title":"Example usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using CSV: File\nusing DataFrames: innerjoin\nusing DataFrames: DataFrame\nusing Downloads: download\n\nusing PreprocessMD: add_label_column!\nusing PreprocessMD: pivot\n\n# Download synthetic data\nurl = \"https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv\"\n\n# Read in files as DataFrames\nDRUG = DataFrame(File.(download(\"$url/drug_exposure.csv\")));\nCONDITION = DataFrame(File.(download(\"$url/condition_occurrence.csv\")));\nDEATH = DataFrame(File.(download(\"$url/death.csv\")));\n\n# Convert to wide format\np_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);\np_DRUG = pivot(DRUG, :person_id, :drug_concept_id);\n\n# Join tables by patient\np_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);\n\n# Add label data to feature set\nadd_label_column!(p_AGGREGATE, DEATH, :death)\n\n# ... Continue to machine learning pipeline ...\n","category":"page"},{"location":"#Function-index","page":"Home","title":"Function index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Function-documentation","page":"Home","title":"Function documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [PreprocessMD]\nPrivate = false\nOrder = [:module, :function]","category":"page"},{"location":"#PreprocessMD.PreprocessMD","page":"Home","title":"PreprocessMD.PreprocessMD","text":"Description\n\nMedically-informed data preprocessing for machine learning\n\n\n\n\n\n","category":"module"},{"location":"#PreprocessMD.add_label_column!","page":"Home","title":"PreprocessMD.add_label_column!","text":"function add_label_column!(feature_df, source_df, new_column[, id])\n\nAdd a label column to a DataFrame based on symbol presence in the target DataFrame\n\nA column from the target is not copied. Instead, the new column is a CategoricalArray containing true for any ID that is present in the target and false otherwise.\n\nArguments\n\nfeature_df::AbstractDataFrame: feature DataFrame to which label column is added\nsource_df::AbstractDataFrame: DataFrame containing the label column\nnew_column::Union{String, Symbol}: name assigned to label column\nid::Union{Nothing, String, Symbol}: row IDs (Default: first column)\n\nExamples\n\njulia> using DataFrames\n\njulia> X = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], blue = [true, false, false, true], red  = [false, true, false, false], green = [false, false, true, false])\n4×4 DataFrame\n Row │ name            blue   red    green\n     │ String          Bool   Bool   Bool\n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n   3 │ Oscar           false  false   true\n   4 │ Grover           true  false  false\n\njulia> Y = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], lovable = [true, true, false, true], furry = [true, true, true, true], old = [false, false, true, true])\n4×4 DataFrame\n Row │ name            lovable  furry  old\n     │ String          Bool     Bool   Bool\n─────┼───────────────────────────────────────\n   1 │ Cookie Monster     true   true  false\n   2 │ Elmo               true   true  false\n   3 │ Oscar             false   true   true\n   4 │ Grover             true   true   true\n\njulia> add_label_column!(X,Y,:furry)\n\njulia> X\n4×5 DataFrame\n Row │ name            blue   red    green  furry\n     │ String          Bool   Bool   Bool   Cat…\n─────┼────────────────────────────────────────────\n   1 │ Cookie Monster   true  false  false  true\n   2 │ Elmo            false   true  false  true\n   3 │ Oscar           false  false   true  true\n   4 │ Grover           true  false  false  true\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.generate_cohort-Tuple{Any, Any, Any}","page":"Home","title":"PreprocessMD.generate_cohort","text":"Function -> Generatecohort Inputs  Colname -> column name domain_table -> the case table on which your concapts are based on example conditions, onservations, drugs, measurements concepts -> The list of concept id's you want to study Output Unique list of person ids in your cohort whom you want to study\n\nExamples\n\njulia> using DataFrames\n\njulia> df_condition_occurrence = DataFrame(condition_occurrence_id=[123, 5433, 8765, 12345, 6457, 62898], person_id = [1, 2, 3, 4, 5, 6], condition_concept_id = [196523, 436659, 435515, 436096, 440383, 37311319])\n6×3 DataFrame\n Row │ condition_occurrence_id  person_id  condition_concept_id\n     │ Int64                    Int64      Int64\n─────┼──────────────────────────────────────────────────────────\n   1 │                     123          1                196523\n   2 │                    5433          2                436659\n   3 │                    8765          3                435515\n   4 │                   12345          4                436096\n   5 │                    6457          5                440383\n   6 │                   62898          6              37311319\n\njulia> concepts = [196523, 436659, 435515, 436096, 440383]\n5-element Vector{Int64}:\n 196523\n 436659\n 435515\n 436096\n 440383\n\njulia> result = generate_cohort( :condition_concept_id, df_condition_occurrence, concepts)\n5-element Vector{Int64}:\n 1\n 2\n 3\n 4\n 5\n\n\n\n\n\n\n","category":"method"},{"location":"#PreprocessMD.pivot","page":"Home","title":"PreprocessMD.pivot","text":"function pivot()\n\nExpress the long format DataFrame df as a wide format DataFrame B.\n\nOptional arguments x and y are columns of df. The single column x (the first column of df, by default) becomes the row names of B. Column(s) y (all columns besides x, by default) become the column names of B.\n\nExamples\n\njulia> using DataFrames\n\njulia> df = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], fur_color=[\"blue\", \"red\", \"green\", \"blue\"])\n4×2 DataFrame\n Row │ name            fur_color\n     │ String          String\n─────┼───────────────────────────\n   1 │ Cookie Monster  blue\n   2 │ Elmo            red\n   3 │ Oscar           green\n   4 │ Grover          blue\n\njulia> pivot(df)\n4×4 DataFrame\n Row │ name            blue   red    green\n     │ String          Bool   Bool   Bool\n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n   3 │ Oscar           false  false   true\n   4 │ Grover           true  false  false\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.set_label_column!","page":"Home","title":"PreprocessMD.set_label_column!","text":"function set_label_column!(feature_df, source_df, new_column[, id])\n\nDesignate one column within a DataFrame as the label\n\nArguments\n\nfeature_df::AbstractDataFrame: feature DataFrame\ncol_name::Union{String, Symbol}: label column\nid::Union{Nothing, String, Symbol}: row IDs (Default: first column)\n\nExamples\n\njulia> using DataFrames\n\njulia> X = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], lovable = [true, true, false, true], furry = [true, true, true, true], old = [false, false, true, true] )\n4×4 DataFrame\n Row │ name            lovable  furry  old\n     │ String          Bool     Bool   Bool\n─────┼───────────────────────────────────────\n   1 │ Cookie Monster     true   true  false\n   2 │ Elmo               true   true  false\n   3 │ Oscar             false   true   true\n   4 │ Grover             true   true   true\n\njulia> set_label_column!(X,:lovable)\n\njulia> X\n4×4 DataFrame\n Row │ name            lovable  furry  old\n     │ String          Cat…     Bool   Bool\n─────┼───────────────────────────────────────\n   1 │ Cookie Monster  true      true  false\n   2 │ Elmo            true      true  false\n   3 │ Oscar           false     true   true\n   4 │ Grover          true      true   true\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.subsetMD","page":"Home","title":"PreprocessMD.subsetMD","text":"function subsetMD(main_df, check_df, main_id, check_id)\n\nFiltration step\n\nArguments\n\nmain_df::AbstractDataFrame: Rows are selected from this DataFrame...\ncheck_df::AbstractDataFrame: ... if the IDs are present in this DataFrame\nmain_id: ID column from main_df (Default: first column)\ncheck_id: ID column from check_df (Default: same as main_id)\n\nExamples\n\njulia> using DataFrames\n\njulia> X = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], blue = [true, false, false, true], red  = [false, true, false, false], green = [false, false, true, false])\n4×4 DataFrame\n Row │ name            blue   red    green\n     │ String          Bool   Bool   Bool\n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n   3 │ Oscar           false  false   true\n   4 │ Grover           true  false  false\n\njulia> Y = DataFrame(name=[\"Big Bird\", \"Cookie Monster\", \"Elmo\"], fuzzy=[false, true, true])\n3×2 DataFrame\n Row │ name            fuzzy\n     │ String          Bool\n─────┼───────────────────────\n   1 │ Big Bird        false\n   2 │ Cookie Monster   true\n   3 │ Elmo             true\n\njulia> subsetMD(X,Y)\n2×4 DataFrame\n Row │ name            blue   red    green\n     │ String          Bool   Bool   Bool\n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.subset_invalid_year-NTuple{4, Any}","page":"Home","title":"PreprocessMD.subset_invalid_year","text":"function subset_invalid_year\n\nArguments\n\n\n\nExamples\n\njulia> using PreprocessMD, Dates, DataFrames\n\njulia> X = DataFrame(name=[\"Kermit\", \"Big Bird\", \"Herry\", \"Mr. Snuffleupagus\", \"Rosita\", \"Julia\"], first_appearance=Date.([\"1955-05-09\", \"1969-11-10\", \"1970-11-09\", \"1971-11-15\", \"1991-11-26\", \"2017-04-10\"]))\n6×2 DataFrame\n Row │ name               first_appearance\n     │ String             Dates.Date\n─────┼─────────────────────────────────────\n   1 │ Kermit             1955-05-09\n   2 │ Big Bird           1969-11-10\n   3 │ Herry              1970-11-09\n   4 │ Mr. Snuffleupagus  1971-11-15\n   5 │ Rosita             1991-11-26\n   6 │ Julia              2017-04-10\n\njulia> subset_invalid_year(X, :first_appearance, 1969, 2000)\n2×2 DataFrame\n Row │ name    first_appearance\n     │ String  Dates.Date\n─────┼──────────────────────────\n   1 │ Kermit  1955-05-09\n   2 │ Julia   2017-04-10\n\n\n\n\n\n\n","category":"method"},{"location":"#PreprocessMD.top_n_values","page":"Home","title":"PreprocessMD.top_n_values","text":"function top_n_values(df::AbstractDataFrame, col::Union{String, Symbol}, n::Int)::AbstractDataFrame\n\nFind top n values by occurence Useful for initial feasibility checks, but medical codes are not considered\n\nExamples\n\njulia> using DataFrames\n\njulia> df = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\", \"Big Bird\", \"Ernie\", \"Bert\", \"Rosita\"], fur_color=[\"blue\", \"red\", \"green\", \"blue\", \"yellow\", \"orange\", \"yellow\", \"blue\"])\n8×2 DataFrame\n Row │ name            fur_color\n     │ String          String\n─────┼───────────────────────────\n   1 │ Cookie Monster  blue\n   2 │ Elmo            red\n   3 │ Oscar           green\n   4 │ Grover          blue\n   5 │ Big Bird        yellow\n   6 │ Ernie           orange\n   7 │ Bert            yellow\n   8 │ Rosita          blue\n\njulia> top_n_values(df, :fur_color, 4)\n4×2 DataFrame\n Row │ fur_color  nrow\n     │ String     Int64\n─────┼──────────────────\n   1 │ blue           3\n   2 │ yellow         2\n   3 │ red            1\n   4 │ green          1\n\n\n\n\n\n\n","category":"function"}]
}
