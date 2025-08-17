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
#' ■ code source: https://github.com/agronomy4future/datacooks
#'
datacooks= function(model, threshold = 4, clean = FALSE) {

  # Get the original dataset used by the model
  data_name= as.character(model$call$data)
  df= eval(parse(text = data_name))

  # Model parameters
  p= length(coef(model)) # number of parameters (incl. intercept)
  n= nrow(df) # number of observations

  # Predictions and diagnostics
  df$prediction= predict(model)
  df$residual= residuals(model)
  df$leverage= hatvalues(model)

  # RMSE
  RMSE= sqrt(sum(df$residual^2) / (n - p))

  # Internal Studentized Residuals
  df$ISR= df$residual / (RMSE * sqrt(1 - df$leverage))

  # Cook's Distance
  df$CooksD= (1/p) * df$ISR^2 * (df$leverage / (1 - df$leverage))

  # Outlier classification
  cutoff= threshold / (n - p)
  df$category= ifelse(df$CooksD > cutoff, "outlier", "normal")

  # If user wants only normal rows (i.e., cleaned data)
  if (clean) {
    cleaned= df[df$category != "outlier", ]
    return(cleaned)
  }

  # Otherwise return everything with diagnostics
  return(df)
}
