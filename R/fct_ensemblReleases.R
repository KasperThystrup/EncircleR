#' Find available Ensembl releases
#' 
#' This function subsets an AnnotationhHub object according to provided species,
#' and extracts the title of existing EnsDb objects.
#'
#' @param ah An annotationHub object
#' @param organism Target species
#'
#' @return A character vector with the title of available EnsDb objects
#'
#' @examples
#' availableEnsemblReleases()
#' 
#' @importFrom AnnotationHub subset
#' @export
availableEnsemblReleases <- function(ahub, organism){
  
  # Replace underscore
  spe <- gsub(x = organism, pattern = "\\_", replacement = " ")
  
  # Query annotationhub data
  qry <- AnnotationHub::subset(
    ahub, species == spe & dataprovider == "Ensembl" & rdataclass == "EnsDb"
  )
  
  qry$title
}

#' Extract ensembl releases
#' Extracts the numeric value of Ensembl release numbers from the titles of EnsDb objects, as provided by `AnnotationHub`.
#'
#' @param queries A character vector consisting of titles for available EnsDb objects.
#'
#' @return
#'
#' @examples
#' ah <- AnnotationHub()
#' organism <- "Homo_sapiens"
#' queries <- availableEnsemblReleases(ah, organism)
#' releases <- extractEnsemblReleaseNumerics(queries)
#' @export
extractEnsemblReleaseNumerics <- function(queries) {
  releases <- gsub(x = queries, pattern = "\\D", replacement = "")
    
  as.integer(releases)
}


#' Extract reference data from Annotation object
#'
#' @param ahub 
#' @param organism 
#'
#' @return
#' @export
#'
#' @examples
#' ah <- AnnotationHub()
#' organism <- "Homo_sapiens"
#' meta <- extractReferenceMeta(ah, organism)
#' @importFrom S4Vectors mcols
#' @importMethodsFrom AnnotationHub mcols
extractReferenceMeta <- function(ahub, organism, release = NULL) {
  spe <- stringr::str_replace(string = organism, pattern = "_", replacement = " ")
  ah <- subset(ahub, species == spe & dataprovider == "Ensembl" & sourcetype %in% c("GTF", "FASTA"))
  meta <- mcols(ah) %>%
    as.data.frame
  if (!is.null(release))
    meta <- dplyr::filter(
      .data = meta,
      grepl(x = sourceurl, pattern = paste("release", release, sep = "-"))
    )
  meta
}


#' Determine avialable reference files release extermities
#'
#' @param meta 
#'
#' @return
#' A numeric vector of the length two, containing the oldest and latest available reference files
#' @export
#'
#' @examples
#' ah <- AnnotationHub()
#' organism <- "Homo_sapiens"
#' meta <- extractReferenceMeta(ah, organism)
#' referenceExtremities(meta)
referenceExtremities <- function(meta) {
  versions <- stringr::str_extract(
    string = meta$sourceurl,
    pattern = "release\\-\\d+"
  )
  
  releases <- extractEnsemblReleaseNumerics(versions)
  
  mn <- min(releases, na.rm = TRUE)
  mx <- max(releases, na.rm = TRUE)
  
  c(mn, mx)
}


#' Determine Ensembl release extremities
#' Extracts the minimal and maximum Ensembl release number
#'
#' @param queries A character vector consisting of titles for available EnsDb objects.
#'
#' @return
#' A numeric vector of the length two, containing the oldest and latest available Ensembl annotation object
#' @export
#'
#' @examples
#' ah <- AnnotationHub()
#' organism <- "Homo_sapiens"
#' queries <- availableEnsemblReleases(ah, organism)
#' ens_extremes <- EnsDbExtremities(queries)
EnsDbExtremities <- function(queries) {
  releases <- extractEnsemblReleaseNumerics(queries)
  
  mn <- min(releases)
  mx <- max(releases)
  
  c(mn, mx)
}


#' Determine avialable releases based on extremities
#'
#' @param ens_extremes A numeric vector with release numbers of the oldest and newest available annotation object
#' @param ref_extremes A numeric vector with release numbers of the oldest and newest available reference files
#'
#' @return
#' A numeric vector with Ensembl releases, containing both annotation object and reference files
#' @export
#'
#' @examples
#' #' ah <- AnnotationHub()
#' organism <- "Homo_sapiens"
#' meta <- extractReferenceMeta(ah, organism)
#' ref_extremes <- referenceExtremities(meta)
#' ens_extremes <- EnsDbExtremities(queries)
#' extremes <- determineExtremities(ens_extremes, ref_extremes)
#' min_release <- extremes[1]
#' max_release <- extremes[2]
determineExtremities <- function(ens_extremes, ref_extremes) {
  mn <- max(ens_extremes[1], ref_extremes[1])
  mx <- min(ens_extremes[2], ref_extremes[2])
  
  c(mn, mx)
}
