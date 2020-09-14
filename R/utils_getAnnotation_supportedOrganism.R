#' List of organisms available in Ensembl. 
#' Lists must be manually updated.
#' 
#' supported_organisms: Vector names are presented in the shiny app,
#' while values are used for internal function, and must thus be underscored
#' 
#' supported_builds: Vector names correspond to vector values of supported organisms,
#' while vector values correspond to genome builds
supported_organisms <- c(
  "Homo sapiens" = "Homo_sapiens",
  "Mus musculus" = "Mus_musculus"
)

supported_builds <- c(
  "Homo_sapiens" = "GRCh38",
  "Mus_musculus" = "GRCm38"
)