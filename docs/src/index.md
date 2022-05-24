```@meta
CurrentModule = PreprocessMD
```

# PreprocessMD

Documentation for [PreprocessMD.jl](https://github.com/bcbi/PreprocessMD.jl).

```@contents
```

# Example usage

```@example
using CSV: File
using DataFrames: innerjoin
using DataFrames: DataFrame
using Downloads: download

using PreprocessMD: add_label_column!
using PreprocessMD: MLDemo
using PreprocessMD: pivot

url = "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv"
DRUG = DataFrame(File.(download("$url/drug_exposure.csv")));
CONDITION = DataFrame(File.(download("$url/condition_occurrence.csv")));
DEATH = DataFrame(File.(download("$url/death.csv")));

p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);
p_DRUG = pivot(DRUG, :person_id, :drug_concept_id);

p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);

add_label_column!(p_AGGREGATE, DEATH, :death)

MLDemo(p_AGGREGATE, :death, 1234) |> display
```
# Function index

```@index
```

# Function documentation

```@docs
PreprocessMD
MLDemo
add_label_column!
pivot
subsetMD
top_n_values
```

