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
using PreprocessMD: pivot

# Download synthetic data
url = "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv"

# Read in files as DataFrames
DRUG = DataFrame(File.(download("$url/drug_exposure.csv")));
CONDITION = DataFrame(File.(download("$url/condition_occurrence.csv")));
DEATH = DataFrame(File.(download("$url/death.csv")));

# Convert to wide format
p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);
p_DRUG = pivot(DRUG, :person_id, :drug_concept_id);

# Join tables by patient
p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);

# Add label data to feature set
add_label_column!(p_AGGREGATE, DEATH, :death)

# ... Continue to machine learning pipeline ...

###

PERSON = DataFrame(File.(download("$url/person.csv")));
x = filter(:ethnicity_concept_id => ==(38003563), PERSON);

###

```
# Function index

```@index
```

# Function documentation

```@autodocs
Modules = [PreprocessMD]
Private = false
Order = [:function]
```
