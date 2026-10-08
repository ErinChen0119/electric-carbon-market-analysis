# Electricity–Carbon Market Empirical Analysis in R

This repository contains a reproducible R-based empirical analysis of provincial electricity and carbon market data in China from 2013 to 2023.

The project reproduces selected empirical results from research on carbon-price transmission to generator-side electricity tariffs. The workflow includes data validation, descriptive statistics, baseline regression analysis, and heteroskedasticity-robust inference.

## Research Question

How is the carbon price associated with generator-side electricity tariffs across Chinese carbon-trading pilot regions?

## Data

The analysis uses a balanced panel of 88 province-year observations covering eight carbon-trading pilot regions from 2013 to 2023.

Variables used in the regression include:

- generator-side electricity price
- carbon price
- GDP
- share of the secondary sector
- share of thermal power generation

The script validates variable types, missing values, duplicate province-year observations, and sample coverage before estimation.

## Empirical Analysis

The baseline specification is:

Electricity Price = Carbon Price + GDP + Secondary-Sector Share + Thermal-Power Share

The analysis includes:

1. Data validation and cleaning
2. Descriptive statistics
3. Baseline OLS regression
4. HC1 heteroskedasticity-robust standard errors

## Main Results

The baseline regression uses 88 observations and produces an R-squared of approximately 0.169.

The estimated coefficient on the scaled carbon-price variable is approximately 0.773.

Using HC1 robust standard errors:

- Carbon price: coefficient = 0.773, robust SE = 0.306
- GDP: coefficient = 0.040, robust SE = 0.012
- Secondary-sector share: coefficient = 0.133, robust SE = 0.059
- Thermal-power share: coefficient = -0.033, robust SE = 0.025

The results closely reproduce the reported baseline and robust-inference estimates.

## Repository Structure

```text
electric-carbon-market-replication/
├── analysis.R
├── data/
├── output/
│   ├── descriptive_statistics.csv
│   ├── table3_baseline_regression.csv
│   ├── table4_robust_se.csv
│   └── session_info.txt
└── README.md
```
## Software

The analysis was conducted in R / RStudio.

Required packages:

- readxl
- dplyr
- lmtest
- sandwich

## Reproduction

Place the analysis dataset at:

`data/carbon_data.xlsx`

Then run:

`analysis.R`

The script validates the dataset, estimates the models, and automatically generates the files in the `output/` directory.

## Reference

Wu, J., Shen, Y., Yang, R., Fan, H., & Duan, Y. (2026). *Electric-carbon market coupling and price transmission mechanism in China: An empirical analysis and development barriers study*. Journal of Cleaner Production, 544, 147692.

DOI: 10.1016/j.jclepro.2026.147692