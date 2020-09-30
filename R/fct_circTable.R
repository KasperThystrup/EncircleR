library(rtracklayer)
library(circulaR)
object <- readRDS("~/.EncircleR/Saves/HeLa_NoFilt_trimmed.RData")

bsids <- c("GRCh38:1:100061950:100049908:+",
           "GRCh38:1:100102954:100110484:-",
           "GRCh38:1:100442997:100424221:+")

circbase <- rtracklayer::import.bed(con = "cache/HeLa/circbase/hsa_hg38_circRNA_lifted.bed") %>%
  keepStandardChromosomes(pruning.mode = "coarse")

map <- mapSeqlevels(seqnames = seqlevels(circbase), style = "NCBI")

circbase <- renameSeqlevels(x = circbase, value = map)

unique(circbase)

overlaps <- findOverlaps(query = bsj.counts(object, returnAs = "gr"), subject = circbase)

baseIDs <- circbase[subjectHits(overlaps)]$name

links <- paste0("http://circbase.org/cgi-bin/singlerecord.cgi?id=", baseIDs)

circLinks <- rep(NA, queryLength(overlaps))
circLinks[queryHits(overlaps)] <-

circbase <- readr::read_tsv(file = "cache/HeLa/circbase/hsa_hg19_CircBase.txt")

ah <- AnnotationHub::AnnotationHub()[["AH79689"]]
parent_genes <- circulaR::annotateByOverlap(bsids = bsids, db = ah) %>%
  dplyr::group_by(bsID) %>%
  summarize(`Parent gene` = paste(GENENAME, collapse = ", "))




function(object, ah) {
  smpls <- circulaR::samples(object)
  circs <- circulaR::bsj.counts(object, returnAs = "list") %>%
    lapply(function(x) dplyr::mutate(x, Sample = circulaR::sample.id(object)))
  
  
  
  circID <- circs$bsID
  
  parent_genes <- circulaR::annotateByOverlap(bsids = circID, db = ah) %>%
    dplyr::group_by(bsID) %>%
    summarize(Symbol = paste(GENENAME, collapse = ", "))
  
  tibble::tibble(
    "circRNA" = circID,
    "Count" = circs$count,
    `Parent gene` = parent_genes$Symbol
  )

}
  


aim <- tibble(
  "circRNA" = bsids,
  "Count" = c(1,1,2),
  `Parent genes` = parent_genes
)

