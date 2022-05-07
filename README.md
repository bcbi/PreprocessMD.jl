# PreprocessMD.jl

Medically-informed data preprocessing for machine learning


[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.bcbi.brown.edu/PreprocessMD.jl/stable/)
[![](https://img.shields.io/badge/docs-development-blue.svg)](https://docs.bcbi.brown.edu/PreprocessMD.jl/dev/)
[![Build Status](https://github.com/AshlinHarris/PreprocessMD.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/bcbi/PreprocessMD.jl/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/AshlinHarris/PreprocessMD.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/bcbi/PreprocessMD.jl)

## Summary

Biomedical data sets are messy! 
Biostatistical pipelines require many iterative stages of data manipulations.
Following the definitions of Hu et al.[^cite], we consider **data preprocessing** to be project-level data manipulations,
as opposed to the upstream **data cleaning** (e.g., error-corrections and standardizations) that is typically performed over an entire database,
and the downstream **data preparing** (e.g., labelling and classification), which might vary across any number of analyses within a project.
Are these categories exclusive?
Let's just say we wouldn't use tree-based methods to separate them...

[^cite]: Wu, Hulin, Jose Miguel Yamal, Ashraf Yaseen, and Vahed Maroufy, eds. Statistics and Machine Learning Methods for EHR Data: From Data Extraction to Data Analytics. CRC Press, 2020.

## Example Usage

```
using CSV
using DataFrames
using Downloads
using PreprocessMD

# Read in data
CONDITION = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/condition_occurrence.csv") |> CSV.File |> DataFrame;
DRUG = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/drug_exposure.csv") |> CSV.File |> DataFrame;

# Pivot data (1 person per row, 1 Concept per column, 1 value per cell)
p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id);
p_DRUG = pivot(DRUG, :person_id, :drug_concept_id);

# Combine data 
p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG, on=:person_id);
```

## Planned features

Planned features for PreprocessMD.jl include:
* Summaries and feasibility checks
* Feature extraction and derivation
* Generate derived variables
* Data imputation
* Dimension reduction

<!--
Draft text

, and sources of bias can't always be known without clinical experience.

using medical codes to cluster the data so we get smaller, more efficient DataFrames with less class imbalance.

-->
