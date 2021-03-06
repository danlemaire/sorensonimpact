#' Extract duplicate rows
#' @description Extract all rows with duplicated values in the given columns
#' @importFrom magrittr "%>%"
#' @param ... Columns to evaluate for duplication. Works via \code{group_by()}.
#' @return Filtered dataframe with duplicates in given columns
#' @examples
#' mtcars %>% duplicates(mpg)
#' @export
duplicates <- function(data, ...) {
  message("This function is deprecated.  Use janitor::get_dupes()")
  columns <- rlang::enquos(...)
  data %>%
    dplyr::group_by(!!!columns) %>%
    dplyr::filter(n() > 1) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(!!!columns)
}


#' Sum selected columns by row
#' @description Sum selected columns within mutate without \code{rowwise()} (which can be very slow).
#' @importFrom magrittr "%>%"
#' @param ... Columns to sum.
#' @param sum_col Name of sum column. Defaults to "sum".
#' @param na.rm Remove NAs? Passed to rowSums
#' @return Vector with rowwise sums.
#' @examples
#' cars %>% sum_rowwise(speed, dist, na.rm = T, sum_col = "mysum"))
#' @export
sum_rowwise <- function(data, ..., sum_col = "sum", na.rm = FALSE) {
  columns <- rlang::enquos(...)

  data %>%
    dplyr::select(!!! columns) %>%
    dplyr::transmute(!!sum_col := rowSums(., na.rm = na.rm)) %>%
    dplyr::bind_cols(data, .)
}


#' Count the NAs in each column
#' @description Count all the NAs in each column of a data frame
#' @importFrom magrittr "%>%"
#' @return NA count for each
#' @export
col_sum_na <- function(data) {
  data %>%
    purrr::map_dfc(is.na) %>%
    purrr::map_dfc(sum)
}

#' Generate a frequency tibble
#' @description Generate a frequency table with marginal values
#' @importFrom magrittr "%>%"
#' @param rows The primary rows of the table (use groups for additional)
#' @param cols The columns of the table
#' @param ... Additional grouping variables that will subdivide rows.
#' @return A tibble
#' @export
freq_tibble <- function(data, rows, cols, ...) {
  rows <- enquo(rows)
  cols <- enquo(cols)
  groups <- rlang::enquos(...)

  if(length(groups) == 0) {

    data %>%
      count(!!rows, !!cols) %>%
      spread(!!cols, n, fill = 0) %>%
      mutate(Total := rowSums(select(., -!!rows))) %>%
      bind_rows(bind_cols(!!quo_name(rows) := "Total", summarize_if(., is.numeric, sum)))

  }
  else{
    groupnum <- data %>% distinct(!!!groups) %>% nrow()

    data %>%
      count(!!rows, !!cols, !!!groups) %>%
      spread(!!cols, n, fill = 0) %>%
      mutate(Total := rowSums(select(., -!!rows, -c(!!!groups)))) %>%
      group_by(!!!groups) %>%
      bind_rows(bind_cols(!!quo_name(rows) := rep("Subtotal", groupnum), summarize_if(., is.numeric, sum)),
                bind_cols(!!quo_name(rows) := "Total", summarize_if(ungroup(.), is.numeric, sum)))
  }
}


# unmix <- function(data, col) {
#   col <- rlang::enquo(col)
#
#   numname <- paste(quo(col), "num", sep = "_")
#   charname <- paste(quo_name(col), "char", sep = "_")
#
#
#
#   data %>%
#     mutate(numname = as.numeric(!!col),
#            charname = case_when(is.na(!!quo(numname)) ~ !!enquo(numname)))
# }
# unmix(x, fu)


#' Tibble Preview
#' @description Show a sample of all tibble data without hiding columns.
#' @importFrom magrittr "%>%"
#' @return A preview of a tibble.
#' @export
tp <- function(data) {
  data <- dplyr::sample_n(data, 5)
  print(data, n = Inf, width = Inf)
}
