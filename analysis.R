library(readxl)
library(dplyr)
library(lmtest)
library(sandwich)

df <- read_excel("data/carbon_data.xlsx")

dim(df)

names(df)

head(df)

str(df)
# ------------------------------------------------------------
# Convert variables to numeric format
# ------------------------------------------------------------

df <- df %>%
  mutate(
    province = as.character(province),
    year = as.integer(year),
    
    carbon_price =
      suppressWarnings(as.numeric(trimws(carbon_price))),
    
    electricity_price =
      suppressWarnings(as.numeric(trimws(electricity_price))),
    
    gdp =
      as.numeric(gdp),
    
    secondary_share =
      suppressWarnings(as.numeric(trimws(secondary_share))),
    
    thermal_share =
      as.numeric(thermal_share)
  )
# Convert province names from Chinese to English
df <- df %>%
  mutate(
    province = recode(
      province,
      "北京" = "Beijing",
      "上海" = "Shanghai",
      "广东" = "Guangdong",
      "湖北" = "Hubei",
      "天津" = "Tianjin",
      "重庆" = "Chongqing",
      "福建" = "Fujian",
      "深圳" = "Shenzhen"
    )
  )

# Check variable types again
str(df)

# Find rows with missing or invalid regression values
problem_rows <- df %>%
  filter(
    is.na(carbon_price) |
      is.na(electricity_price) |
      is.na(gdp) |
      is.na(secondary_share) |
      is.na(thermal_share)
  )

problem_rows

nrow(problem_rows)
# ------------------------------------------------------------
# Final sample checks
# ------------------------------------------------------------

# Check duplicate province-year observations
duplicates <- df %>%
  count(province, year) %>%
  filter(n > 1)

duplicates

# Check final sample size and coverage
nrow(df)

n_distinct(df$province)

range(df$year)
# ------------------------------------------------------------
# Prepare variables in the units used in the paper
# ------------------------------------------------------------

df <- df %>%
  arrange(province, year) %>%
  mutate(
    carbon_price_scaled = carbon_price / 1000,
    gdp_scaled = gdp / 100000
  )

# Quick check
summary(df$carbon_price_scaled)
summary(df$gdp_scaled)
# ------------------------------------------------------------
# Table 2: Descriptive statistics
# ------------------------------------------------------------

analysis_vars <- c(
  "electricity_price",
  "carbon_price_scaled",
  "gdp_scaled",
  "secondary_share",
  "thermal_share"
)

descriptive_stats <- data.frame(
  Variable = analysis_vars,
  Mean = sapply(df[analysis_vars], mean),
  Median = sapply(df[analysis_vars], median),
  SD = sapply(df[analysis_vars], sd),
  Min = sapply(df[analysis_vars], min),
  Max = sapply(df[analysis_vars], max)
)

rownames(descriptive_stats) <- NULL

descriptive_stats
# ------------------------------------------------------------
# Table 3: Baseline regression
# ------------------------------------------------------------

model_table3 <- lm(
  electricity_price ~
    carbon_price_scaled +
    gdp_scaled +
    secondary_share +
    thermal_share,
  data = df
)

summary_table3 <- summary(model_table3)

summary_table3
# ------------------------------------------------------------
# Table 4 Column (1): HC1 robust standard errors
# ------------------------------------------------------------

robust_results <- coeftest(
  model_table3,
  vcov. = vcovHC(model_table3, type = "HC1")
)

robust_results
# ------------------------------------------------------------
# Export results
# ------------------------------------------------------------

# Table 3 results
table3_results <- data.frame(
  Variable = rownames(summary_table3$coefficients),
  Estimate = summary_table3$coefficients[, 1],
  Std_Error = summary_table3$coefficients[, 2],
  t_value = summary_table3$coefficients[, 3],
  p_value = summary_table3$coefficients[, 4],
  row.names = NULL
)

# Table 4 robust-SE results
table4_results <- data.frame(
  Variable = rownames(robust_results),
  Estimate = robust_results[, 1],
  Robust_SE = robust_results[, 2],
  t_value = robust_results[, 3],
  p_value = robust_results[, 4],
  row.names = NULL
)

# Export all results
write.csv(
  descriptive_stats,
  "output/descriptive_statistics.csv",
  row.names = FALSE
)

write.csv(
  table3_results,
  "output/table3_baseline_regression.csv",
  row.names = FALSE
)

write.csv(
  table4_results,
  "output/table4_robust_se.csv",
  row.names = FALSE
)

cat("\nAnalysis complete.\n")
cat("Observations =", nobs(model_table3), "\n")
cat("R-squared =", round(summary_table3$r.squared, 4), "\n")
# Save software/session information for reproducibility
writeLines(
  capture.output(sessionInfo()),
  "output/session_info.txt"
)
