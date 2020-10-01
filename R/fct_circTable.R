#' Make circRNA tables
#' 
#' This function generates a data table containing detected circRNAs
#'
#' @param object 
#' @param ah 
#'
#' @return
#' @examples
#' ahdb <- AnnotationHub()[["AH79689"]] # Ensembl EnsDb Release 100
#' circs <- makeTable(object= circObject, ah = ahdb)
#' 
#' @importFrom dplyr mutate group_by %>% summarise
#' @importFrom tibble tibble
#' @importFrom plyranges mutate
#' 
#' @export
makeTables <- function(object, ah) {
  smpls <- circulaR::sample.id(object)
  
  circs <- circulaR::bsj.counts(object, returnAs = "gr") %>%
    unlist

  parent_genes <- circulaR::annotateByOverlap(bsids = unique(circs$bsID), db = ah) %>%
    dplyr::group_by(bsID) %>%
    dplyr::summarise(
      Symbol = paste(GENENAME, collapse = ", "),
      Ensembl = paste(paste0("<a target=\"_blank\" href='", "https://www.ensembl.org/Homo_sapiens/Gene/Summary?db=core;g=", GENEID, "' >", GENEID, "</a>"), collapse = ", "),
      Biotype = paste(GENEBIOTYPE, collapse = ", "),
   )
  
  base_tbl <- tibble::tibble(
    "circRNA" = circs$bsID,
    "Count" = circs$count,
    
  )
  
  dplyr::right_join(base_tbl, parent_genes, by = c("circRNA" = "bsID"))
}
