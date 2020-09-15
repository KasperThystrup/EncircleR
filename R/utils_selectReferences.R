genome_dir <- "~/.EncircleR/Genome"

releases <- list.dirs(path = genome_dir, full.names = TRUE, recursive = FALSE)

available_references <- list.dirs(
  path = releases, full.names = TRUE, recursive = FALSE
)

i <- available_references[1]
ref_name <- strsplit(x = i, split = "/") %>%
  unlist %>%
  tail(2) %>%
  gsub(pattern = "_", replacement = " ") %>%
  paste(collapse = " ")

names(input$ref_select) <- paste("Ensembl", ref_name)

available_references <- lapply(releases, function(rls) {
  names(rls) <- strsplit(x = rls, split = "/") %>%
    lapply(tail, 1) %>%
    unlist %>%
    gsub(pattern = "-", replacement = " ") 
  organisms <- list.dirs(path = rls, full.names = T, recursive = F)
  organisms_names <- strsplit(x = organisms, , split = "/") %>%
    lapply(tail, 1) %>%
    unlist %>%
    gsub(pattern = "_", replacement = " ")
  
  names(organisms) <- paste(organisms_names, "Ensembl", names(rls))
  organisms
}) %>%
  unname %>%
  unlist
