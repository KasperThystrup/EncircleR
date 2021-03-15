listReferences <- function(cache_dir) {
  genome_dir <- file.path(cache_dir, "Genome")
  release_dirs <- list.dirs(
    path = genome_dir, full.names = TRUE, recursive = FALSE
  )
  
  ref <- list.dirs(
    path = release_dirs, full.names = TRUE, recursive = FALSE
  )
  
  ref_names <- lapply(release_dirs, function(rls) {
    sub_dirs <- list.dirs(path = rls, recursive = TRUE, full.names = FALSE)
    # Check if there are any STAR indices
    if (any(grepl(pattern = "STAR", x = sub_dirs))) {
      release_split <- strsplit(x = rls, split = "/")
      release <- unlist(release_split) %>%
        tail(1) %>%
        gsub(pattern = "-", replacement = " ")
      
      organism <- list.dirs(path = rls, full.names = T, recursive = F)
      organism_names <- strsplit(x = organism, split = "/") %>%
        lapply(tail, 1) %>%
        unlist %>%
        gsub(pattern = "_", replacement = " ")
      
      paste(organism_names, "Ensembl", release)
    }
  }) %>%
    unlist
  
  names(ref) <- ref_names
  ref_idx <- !is.na(names(ref))
  ref <- ref[ref_idx]
  
  return(ref)
}
