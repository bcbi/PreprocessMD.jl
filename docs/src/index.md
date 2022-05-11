```@meta
CurrentModule = PreprocessMD
```

# PreprocessMD

Documentation for [PreprocessMD](https://github.com/bcbi/PreprocessMD.jl).

```@contents
```

#=
(example)
using CSV
using DataFrames
using Downloads
using MLJ
using MLJDecisionTreeInterface

using PreprocessMD

CONDITION = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/condition_occurrence.csv") |> CSV.File |> DataFrame;
DRUG = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/drug_exposure.csv") |> CSV.File |> DataFrame;

# Pivot feature data (1 person per row, 1 Concept per column, 1 value per cell)
p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);
p_DRUG = pivot(DRUG, :person_id, :drug_concept_id);

# Combine feature data
p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);

# Add label data
DEATH = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/death.csv") |> CSV.File |> DataFrame;
add_label_column!(p_AGGREGATE, DEATH, :person_id, :death)

# Machine learning model
MLDemo(p_AGGREGATE, :death, 1234) |> display
=#

```@docs
PreprocessMD
MLDemo
add_label_column!
pivot
top_n_values
```

```@index
```
