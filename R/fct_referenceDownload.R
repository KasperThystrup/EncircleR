#' Find links for reference files
#'
#' @param meta
#' @param organism 
#' @param build 
#' @param release 
#'
#' @return
#' Named list with GTF and FA URLs
#' 
#' @export
#'
#' @examples
getDownloadLinks <- function(meta, organism, build, release) {
  gtf_ptrn <- paste(organism, build, release, "gtf", sep = ".")
  fa_ptrn <- paste0(
    paste("release", release, sep = "-"),
    "\\D+",
    paste(organism, build, "dna", "primary_assembly", sep = ".")
  )
  
  gtf_url <- dplyr::filter(.data = meta, grepl(x = sourceurl, pattern = gtf_ptrn)) %>%
    dplyr::pull(sourceurl)
  
  fa_url <- dplyr::filter(.data = meta, grepl(x = sourceurl, pattern = fa_ptrn)) %>%
    dplyr::pull(sourceurl)
  
  list(gtf = gtf_url, fa = fa_url)
}


#' Download and decompress reference files
#'
#' @param url 
#' @param out_dir 
#'
#' @return
#' Downloaded and unzipped file name
#' 
#' @export
#'
#' @examples
downloadFile <- function(url, out_dir) {
  # Split url elements
  url_split <- strsplit(x = url, split = "/") %>%
    unlist
  
  # Define target filename
  url_file <- tail(x = url_split, 1)
  
  # 
  ext_split <- strsplit(x = url_file, split = "\\.") %>%
    unlist
  
  ext_tail <- tail(x = ext_split, 1)
  gz = FALSE
  if (ext_tail == "gz") {
    type <- tail(ext_split, 2)[1]
    gz = TRUE
  } else {
    type = ext_tail
    gz = FALSE
  }
  
  path <- file.path(out_dir, type)
  destination <- file.path(path, url_file)
  destination_unzipped <- gsub(x = destination, pattern = ".gz$", replacement = "")
  
  if (!file.exists(destination_unzipped)) {
    # Ensure that file path is generated
    system(paste("mkdir -p", path))
    
    # Download file
    download.file(url = url, destfile = destination)
  
    if (gz) 
      # Unzip target file
      system(paste("gunzip", destination))
  }
  
  destination_unzipped
  
}
