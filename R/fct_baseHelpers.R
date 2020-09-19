paste. <- function(..., collapse = NULL, recycle0 = FALSE) {
  string <- base::paste(..., sep = ".", collapse)
  
  substr(x = string, start = 1, stop = nchar(string) - 1)
}


paste_ <- function(..., collapse = NULL, recycle0 = FALSE) {
  string <- base::paste(..., sep = "_", collapse)
  
  substr(x = string, start = 1, stop = nchar(string) - 1)
}


paste_n <- function(..., collapse = NULL, recycle0 = FALSE) {
  string <- base::paste(..., sep = "\n", collapse)
  
  substr(x = string, start = 1, stop = nchar(string) - 1)
}