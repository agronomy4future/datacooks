<!-- README.md is generated from README.Rmd. Please edit that file -->
# datacooks
<!-- badges: start -->
<!-- badges: end -->

The goal of the datacooks package is to add diagnostic statistics (predicted values, residuals, leverage, studentized residuals, and Cook's distance) to the original dataset used in a linear regression model, and flags influential observations as outliers.

□ Code explained: https://agronomy4future.com/archives/24556

## Installation

You can install datacooks() like so:

Before installing, please download Rtools (https://cran.r-project.org/bin/windows/Rtools)

``` r
if(!require(remotes)) install.packages("remotes")
if (!requireNamespace("datacooks", quietly = TRUE)) {
  remotes::install_github("agronomy4future/datacooks", force= TRUE)
}
library(remotes)
library(datacooks)
```

## Example

This is a basic code for datacooks()

``` r
datacooks(model, threshold = 4, clean = FALSE)
```

## Let’s practice with actual dataset

``` r
# data upload 
if(!require(readr)) install.packages("readr")
library(readr)
github="https://raw.githubusercontent.com/agronomy4future/raw_data_practice/refs/heads/main/fruit_size.csv"
df=data.frame(read_csv(url(github),show_col_types = FALSE))
set.seed(100)
print(df[sample(nrow(df),5),])
    treatment block weight_g length_cm diameter_mm area_cm2
102         B   III     39.4       9.0          30    58.35
112         B   III     78.9      10.0          44    72.23
151         B    II     57.5      10.5          50   110.89
4           A     I     28.9       8.0          34    42.67
55          A     I     92.2      10.5          65    93.56
.
.
.

# model structure
model= lm(area_cm2 ~ weight_g, data= df)

# datacooks() 
df1= datacooks(model, threshold= 4, clean= FALSE)
set.seed(100)
print(df1[sample(nrow(df1),5),])

    treatment block weight_g length_cm diameter_mm area_cm2 prediction   residual
102         B   III     39.4       9.0          30    58.35   56.75088   1.599123
112         B   III     78.9      10.0          44    72.23   95.58915 -23.359147
151         B    II     57.5      10.5          50   110.89   74.54765  36.342346
4           A     I     28.9       8.0          34    42.67   46.42678  -3.756780
55          A     I     92.2      10.5          65    93.56  108.66634 -15.106337
       leverage        ISR        CooksD category
102 0.006556083  0.1101403 0.00004002795   normal
112 0.015726165 -1.6163482 0.02087116663   normal
151 0.007732711  2.5045778 0.02444230614   normal
4   0.008219032 -0.2589666 0.00027788328   normal
55  0.024298731 -1.0498727 0.01372492493   normal

# datacooks() removing outliers from the dataset
df2= datacooks(model, threshold= 4, clean= TRUE)
set.seed(100)
print(df2[sample(nrow(df2),5),])

    treatment block weight_g length_cm diameter_mm area_cm2 prediction  residual
110         B   III     28.6       7.5          30    40.75   46.13181 -5.381806
120         B   III     23.4       6.5          31    35.17   41.01892 -5.848919
4           A     I     28.9       8.0          34    42.67   46.42678 -3.756780
56          A     I     65.6      10.0          50   101.53   82.51196 19.018043
76          B     I     22.0       6.5          22    35.33   39.64237 -4.312373
       leverage        ISR       CooksD category
110 0.008291851 -0.3709983 0.0005754155   normal
120 0.009777434 -0.4035015 0.0008038080   normal
4   0.008219032 -0.2589666 0.0002778833   normal
56  0.009916835  1.3120968 0.0086219038   normal
76  0.010249568 -0.2975702 0.0004584887   normal




