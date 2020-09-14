#' Check filepaths from metadata exists
#'
#' @param meta single row of a metadata data.frame (or tibble)
#'
#' @return
#' A named logical vector containing exisitance
#' @export
#'
#' @examples
setGeneric(name = "checkMetadataFilepaths", def = function(meta) {
  # Define file_name
  file_name <- meta["Filepath"]

  # Determine whether file can be located
  file_located <- FALSE %>%
    `names<-`(file_name)
  if (file.exists(file_name))
    file_located[file_name] <- TRUE

  return(file_located)

})


setMethod(f = "checkMetadataFilepaths", signature = "data.frame", definition = function(meta){
  file_located <- apply(X = meta, MARGIN = 1, FUN = checkMetadataFilepaths)

  names(file_located) <- dplyr::pull(meta, Filepath)

  return(file_located)
})


#' Import metadata
#' Import the uploaded metadata file and updates the colnames of the first three main columns.
#'
#' @param meta_fn Full path to the uploaded metadata location
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom readr read_tsv
importMetadata <- function(meta_fn) {
  invisible({
    meta <- readr::read_tsv(file = meta_fn)
  })

  main_columns <- c("Sample", "Filepath", "Mate")
  colnames(meta)[1:3] <- main_columns

  return(meta)
}
