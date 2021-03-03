#' Make circRNA tables
#' 
#' This function generates a data table containing detected circRNAs
#'
#' @param object 
#' @param ah 
#'
#' @return
#' @examples
#' #ahdb <- AnnotationHub()[["AH79689"]] # Ensembl EnsDb Release 100
#' #circs <- makeTable(object= circObject, ah = ahdb)
#' 
#' @importFrom dplyr mutate group_by %>% summarise right_join filter
#' @importFrom tibble tibble
#' @importFrom plyranges mutate
#' 
#' @export
makeTables <- function(object, ah, circbase) {
  smpls <- circulaR::sample.id(object)
  
  circs <- circulaR::bsj.counts(object, returnAs = "gr") %>%
    unlist

  circbase
  parent_genes <- circulaR::annotateByOverlap(bsids = unique(circs$bsID), db = ah)
  # Clip off last row (it is a accumulation of all hits)
  circOverlaps <- dplyr::right_join(parent_genes, circbase, by = c("GENENAME" = "symbol")) %>%
    dplyr::filter(!is.na(GENENAME), !is.na(bsID)) %>%
    dplyr::group_by(bsID) %>%
    dplyr::summarise(
      Symbol = paste(unique(GENENAME), collapse = ", "),
      Ensembl = paste(unique(paste0("<a target=\"_blank\" href='", "https://www.ensembl.org/Homo_sapiens/Gene/Summary?db=core;g=", GENEID, "' >", GENEID, "</a>")), collapse = ", "),
      Biotype = paste(unique(GENEBIOTYPE), collapse = ", "),
      circBase_Hits = length(circRNAID),
      circBase = paste(unique(paste0("<a target=\"_blank\" href='", "http://www.circbase.org/cgi-bin/singlerecord.cgi?id=", circRNAID, "' >", "[", seq_along(circRNAID), "]" , "</a>")), collapse = " ")
    )
  
  
  base_tbl <- tibble::tibble(
    "circRNA" = circs$bsID,
    "Count" = circs$count,
    
  )
  
  dplyr::right_join(base_tbl, circOverlaps, by = c("circRNA" = "bsID"))
}
