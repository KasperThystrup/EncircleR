listReferences <- function(genome_dir) {
  release_dirs <- list.dirs(
    path = genome_dir, full.names = TRUE, recursive = FALSE
  )
  
  ref <- list.dirs(
    path = release_dirs, full.names = TRUE, recursive = FALSE
  )
  
  ref_names <- lapply(release_dirs, function(rls) {
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
  }) %>%
    unlist
  
  names(ref) <- ref_names
  return(ref)
}