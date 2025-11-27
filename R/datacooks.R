#' Cook's Distance Diagnostics and Outlier Detection
#'
#' Adds diagnostic statistics (predicted values, residuals, leverage, studentized
#' residuals, and Cook's distance) to the original dataset used in a linear
#' regression model, and flags influential observations as outliers.
#'
#' @param model a fitted \code{lm} model object.
#' @param threshold numeric; the numerator of the Cook's distance cutoff
#'   \eqn{threshold / (n - p)} for identifying outliers. Default is 4.
#' @param clean logical; if \code{TRUE}, only returns rows not flagged as
#'   outliers (i.e., category== "normal"). Default is \code{FALSE}.
#'
#' @returns A data frame containing the original data and diagnostic columns.
#'   If \code{clean = TRUE}, only non-outlier rows are returned.
#'
#' @export
#'
#' @examples
#'## to install datacooks package
#'if(!require(remotes)) install.packages("remotes")
#'if (!requireNamespace("datacooks", quietly= TRUE)) {
#'  remotes::install_github("agronomy4future/datacooks")
#'}
#'library(remotes)
#'library(datacooks)
#'
#'## practice using the actual dataset
#' if(!require(readr)) install.packages("readr")
#' library(readr)
#' github="https://raw.githubusercontent.com/agronomy4future/raw_data_practice/refs/heads/main/fruit_size.csv"
#' df=data.frame(read_csv(url(github),show_col_types = FALSE))
#' model= lm(area_cm2 ~ weight_g, data= df)
#'
#' # Return all data with diagnostics
#' df1= datacooks(model, threshold= 4, clean= FALSE)
#'
#' # Return only non-outlier ("normal") data
#' df1= datacooks(model, threshold= 4, clean= TRUE)
#'
#' # Default: threshold= 4, clean= FALSE
#' df1= datacooks(model)
#'
#' ■ Github: https://github.com/agronomy4future/datacooks
#' ■ Website: https://agronomy4future.com/archives/24565
#'
#' - All Rights Reserved © J.K Kim (kimjk@agronomy4future.com)
#'
datacooks= function(model, threshold= 4, clean= FALSE) {

  # Reconstruct actual dataset used for modeling
  df_model= model.frame(model)

  # Get the original full dataset
  data_name= as.character(model$call$data)
  df_full= eval(parse(text= data_name))   # contains all columns

  # Model parameters
  p= length(coef(model))
  n= nrow(df_model)

  # Predictions and diagnostics (computed on df_model)
  prediction= predict(model)
  residual= residuals(model)
  leverage= hatvalues(model)

  RMSE= sqrt(sum(residual^2) / (n - p))
  ISR= residual / (RMSE * sqrt(1 - leverage))
  CooksD= (1/p) * ISR^2 * (leverage / (1 - leverage))

  cutoff= threshold / (n - p)
  category= ifelse(CooksD > cutoff, "outlier", "normal")

  # Combine diagnostics with original dataset (same row order required)
  df_out= cbind(df_full,
                prediction,
                residual,
                leverage,
                ISR,
                CooksD,
                category)

  # clean option
  if (clean) {
    return(df_out[df_out$category!= "outlier", ])
  }

  return(df_out)
}

# All Rights Reserved © J.K Kim (kimjk@agronomy4future.com). Last updated on 11/26/2025
