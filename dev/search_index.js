var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = PreprocessMD","category":"page"},{"location":"#PreprocessMD","page":"Home","title":"PreprocessMD","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for PreprocessMD.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Example-usage","page":"Home","title":"Example usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using CSV: File\nusing DataFrames: innerjoin\nusing DataFrames: DataFrame\nusing Downloads: download\n\nusing PreprocessMD: add_label_column!\nusing PreprocessMD: pivot\n\n# Download synthetic data\nurl = \"https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv\"\n\n# Read in files as DataFrames\nDRUG = DataFrame(File.(download(\"$url/drug_exposure.csv\")));\nCONDITION = DataFrame(File.(download(\"$url/condition_occurrence.csv\")));\nDEATH = DataFrame(File.(download(\"$url/death.csv\")));\n\n# Convert to wide format\np_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);\np_DRUG = pivot(DRUG, :person_id, :drug_concept_id);\n\n# Join tables by patient\np_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);\n\n# Add label data to feature set\nadd_label_column!(p_AGGREGATE, DEATH, :death)\n\n# ... Continue to machine learning pipeline ...\n","category":"page"},{"location":"#Function-index","page":"Home","title":"Function index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Function-documentation","page":"Home","title":"Function documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [PreprocessMD]\nPrivate = false\nOrder = [:function]","category":"page"},{"location":"#PreprocessMD.add_label_column!","page":"Home","title":"PreprocessMD.add_label_column!","text":"function add_label_column!(feature_df, source_df, new_column[, id])\n\nAdd column to a DataFrame based on symbol presence in the target DataFrame\n\nArguments\n\n`\nfeature_df::AbstractDataFrame: feature DataFrame to which label column is added\nsource_df::AbstractDataFrame: DataFrame containing the label column\nnew_column::Union{String, Symbol}: name assigned to label column\nid::Union{Nothing, String, Symbol}: row IDs (Default: first column)\n\nExamples\n\nusing DataFrames\n\nX = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"],\n\tblue = [true, false, false, true],\n\tred  = [false, true, false, false],\n\tgreen = [false, false, true, false]);\n\nY = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"],\n\tlovable = [true, true, false, true],\n\tfurry = [true, true, true, true],\n\told = [false, false, true, true]\n\t);\nadd_label_column!(X,Y,:furry)\nX\n\n# output\n4×5 DataFrame\n Row │ name            blue   red    green  furry \n     │ String          Bool   Bool   Bool   Cat…  \n─────┼────────────────────────────────────────────\n   1 │ Cookie Monster   true  false  false  true\n   2 │ Elmo            false   true  false  true\n   3 │ Oscar           false  false   true  true\n   4 │ Grover           true  false  false  true\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.pivot","page":"Home","title":"PreprocessMD.pivot","text":"function pivot()\n\nExpress the long format DataFrame df as a wide format DataFrame B.\n\nOptional arguments x and y are columns of df. The single column x (the first column of df, by default) becomes the row names of B. Column(s) y (all columns besides x, by default) become the column names of B.\n\nExamples\n\nusing DataFrames\n\ndf = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"], \n               fur_color=[\"blue\", \"red\", \"green\", \"blue\"]);\npivot(df)\n\n# output\n4×4 DataFrame\n Row │ name            blue   red    green \n     │ String          Bool   Bool   Bool  \n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n   3 │ Oscar           false  false   true\n   4 │ Grover           true  false  false\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.set_label_column!","page":"Home","title":"PreprocessMD.set_label_column!","text":"function set_label_column!(feature_df, source_df, new_column[, id])\n\nDesignate one column within a DataFrame as the label\n\nArguments\n\n`\nfeature_df::AbstractDataFrame: feature DataFrame\ncol_name::Union{String, Symbol}: label column\nid::Union{Nothing, String, Symbol}: row IDs (Default: first column)\n\nExamples\n\nusing DataFrames\n\nX = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"],\n\tlovable = [true, true, false, true],\n\tfurry = [true, true, true, true],\n\told = [false, false, true, true]\n\t);\nset_label_column!(X,:lovable)\nX\n\n# output\n4×4 DataFrame\n Row │ name            lovable  furry  old   \n     │ String          Cat…     Bool   Bool  \n─────┼───────────────────────────────────────\n   1 │ Cookie Monster  true      true  false\n   2 │ Elmo            true      true  false\n   3 │ Oscar           false     true   true\n   4 │ Grover          true      true   true\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.subsetMD","page":"Home","title":"PreprocessMD.subsetMD","text":"function subsetMD(main_df, check_df, main_id, check_id)\n\nFiltration step\n\nArguments\n\nmain_df::AbstractDataFrame: Rows are selected from this DataFrame...\ncheck_df::AbstractDataFrame: ... if the IDs are present in this DataFrame\nmain_id: ID column from main_df (Default: first column)\ncheck_id: ID column from check_df (Default: same as main_id)\n\nExamples\n\nusing DataFrames\n\nX = DataFrame(\n\tname=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\"],\n\tblue = [true, false, false, true],\n\tred  = [false, true, false, false],\n\tgreen = [false, false, true, false]);\n\nY = DataFrame(\n\tname=[\"Big Bird\", \"Cookie Monster\", \"Elmo\"],\n\tfuzzy=[false, true, true]\n\t);\nsubsetMD(X,Y)\n\n# output\n2×4 DataFrame\n Row │ name            blue   red    green \n     │ String          Bool   Bool   Bool  \n─────┼─────────────────────────────────────\n   1 │ Cookie Monster   true  false  false\n   2 │ Elmo            false   true  false\n\n\n\n\n\n\n","category":"function"},{"location":"#PreprocessMD.top_n_values-Tuple{DataFrames.AbstractDataFrame, Union{String, Symbol}, Int64}","page":"Home","title":"PreprocessMD.top_n_values","text":"function top_n_values(df::AbstractDataFrame, col::Union{String, Symbol}, n::Int)::AbstractDataFrame\n\nFind top n values by occurence Useful for initial feasibility checks, but medical codes are not considered\n\nExamples\n\nusing DataFrames\n\ndf = DataFrame(name=[\"Cookie Monster\", \"Elmo\", \"Oscar\", \"Grover\", \"Big Bird\", \"Ernie\", \"Bert\", \"Rosita\"],\n\tfur_color=[\"blue\", \"red\", \"green\", \"blue\", \"yellow\", \"orange\", \"yellow\", \"blue\"]);\ndf |> show; println(); top_n_values(df, :fur_color, 4) |> show\n\n# output\n8×2 DataFrame\n Row │ name            fur_color\n     │ String          String\n─────┼───────────────────────────\n   1 │ Cookie Monster  blue\n   2 │ Elmo            red\n   3 │ Oscar           green\n   4 │ Grover          blue\n   5 │ Big Bird        yellow\n   6 │ Ernie           orange\n   7 │ Bert            yellow\n   8 │ Rosita          blue\n4×2 DataFrame\n Row │ fur_color  nrow\n     │ String     Int64\n─────┼──────────────────\n   1 │ blue           3\n   2 │ yellow         2\n   3 │ red            1\n   4 │ green          1\n\n\n\n\n\n\n","category":"method"}]
}
