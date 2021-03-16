#' File extensions
#'
#' @param filename
#'
#' @return
#' @export
#'
#' @examples
#'
#' @importFrom dplyr `%>%`
#' @importFrom stringr str_split
fileExt <- function(filename) {
  file_elements <- stringr::str_split(string = filename, pattern = "\\.") %>%
    unlist

  tail(x = file_elements, n = length(file_elements) - 1)
}


setupSampleFiles <- function(meta_row) {
  sample <- dplyr::pull(meta_row, Sample)
  old_path <- dplyr::pull(meta_row, Filepath)
  mate <- dplyr::pull(meta_row, Mate)
  filename <- basename(old_path)
  file_ext <- fileExt(filename)

  compression = ""
  if (length(file_ext) > 1) {
    compression = tail(file_ext, 1)
  } else if (length(file_ext) != 1) {
    stop("No file extension detected, please reconsult the input file names.")
  }
  if (!(compression %in% supported_compressions))
    stop(paste(
      "Unkown compression (.", compression,
      ") used, please reconsult the input file names."
    ))

  new_filename <- paste(
    paste(sample, mate, sep = "_"),
    ifelse(compression == "", "fq", paste("fq", compression, sep = ".")),
    sep = "."
  )

  new_path <- file.path(dirname(old_path), new_filename)

  cmd_rename <- paste("mv", old_path, new_path)
  system(cmd_rename)

  dplyr::mutate(meta_row, Filepath = new_path) %>%
    return
}


setupSamplePaths <- function(exp_dir, meta_row, cmd_os) {

    sample <- dplyr::pull(meta_row, Sample)
    mate <- dplyr::pull(meta_row, Mate)
    old_path <- dplyr::pull(meta_row, Filepath)
    filename <- basename(old_path)

    new_dir <- file.path(exp_dir, "Samples", sample, "rawdata")
    new_path <- file.path(new_dir, filename)

    cmd_makedir <- paste("mkdir -p", new_dir)
    system(cmd_makedir)

    cmd_mv <- paste(cmd_os, old_path, file.path(new_dir, filename))
    system(cmd_mv)

    dplyr::mutate(meta_row, Filepath = new_path) %>%
      return
}


reassignSampleFiles <- function(exp_dir, meta, copy) {

  cmd_os <- "mv"
  if (copy)
    cmd_os <- "cp"

  for (i in 1:nrow(meta)) {

    # Extract sample information
    meta_row <- meta[i, ]

    # Rename and relocate sample files
    meta_row <- setupSamplePaths(exp_dir, meta_row, cmd_os)
    meta_row <- setupSampleFiles(meta_row)

    # Update metadata
    meta[i, ] <- meta_row
  }

  readr::write_tsv(x = meta, file = file.path(exp_dir, "metadata.tsv"))
  meta
}
