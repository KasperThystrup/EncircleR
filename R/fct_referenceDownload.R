#' Find links for reference files
#'
#' @param meta Dataframe with metadata on queries from AnnotationHub::mcols
#' @param organism Character string with selected organism
#' @param build Character string with the reference genome build
#' @param release Numeric value with selected Ensembl release
#'
#' @return
#' Named list with GTF and FA URLs
#' 
#' @export
#'
#' @examples
#' #ah <- AnnotationHub()
#' #organism <- "Homo_sapiens"
#' #build <- "GRCh38"
#' #release <- 100
#' #qry <- subset(ah, species == "Homo sapiens", rdataprovider == "Ensembl")
#' #meta <- mcols(qry)
#' #getDownloadLinks(meta, organism, build, release)
getDownloadLinks <- function(meta, organism, build, release) {
  gtf_ptrn <- paste(organism, build, release, "gtf", sep = ".")
  fa_ptrn <- paste0(
    paste("release", release, sep = "-"),
    "\\D+",
    paste(organism, build, "dna", "primary_assembly", sep = ".")
  )
  
  gtf_url <- dplyr::filter(.data = meta, grepl(x = sourceurl, pattern = gtf_ptrn)) %>%
    dplyr::pull(sourceurl) %>%
    stringr::str_remove("ftp\\://")
  
  logger::log_info(gtf_url)
  
  fa_url <- dplyr::filter(.data = meta, grepl(x = sourceurl, pattern = fa_ptrn)) %>%
    dplyr::pull(sourceurl) %>%
    stringr::str_remove("ftp\\://")
  
  logger::log_info(fa_url)
  
  list(gtf = gtf_url, fa = fa_url)
}


#' Download and decompress reference files
#'
#' @param url Character with donwload URL
#' @param out_dir Character vector stating the full path to the output directory
#'
#' @return
#' Downloaded and unzipped file name
#' 
#' @export
#'
#' @examples
#' #ah <- AnnotationHub()
#' #organism <- "Homo_sapiens"
#' #build <- "GRCh38"
#' #release <- 100
#' #qry <- subset(ah, species == "Homo sapiens", rdataprovider == "Ensembl")
#' #meta <- mcols(qry)
#' #urls <- getDownloadLinks(meta, organism, build, release)
#' ## Not run
#' #file1 <- downloadFile(url = urls[1], out_dir = "/tmp/file1"
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
    download.file(url = url, destfile = destination, method = "wget", quiet = TRUE)
  
    if (gz) 
      # Unzip target file
      system(paste("gunzip", destination))
  }
  
  destination_unzipped
  
}
