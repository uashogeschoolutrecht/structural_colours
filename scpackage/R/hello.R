#' Hello name function
#'
#' @param n Name of person to say hello to
#'
#' @return The output from \code{\link{print}}
#' @export
#'
#' @examples
#' hello("John")
hello <- function(n) {
  print(paste("Hello,", n))
}
