#' Plot filtration stats
#'
#' @param object a circExperiment object
#'
#' @return
#' Statistics on included and excluded reads after filtration
#'
#' @examples
#' #plotFiltrationStats(circObject)
#' @import dplyr
#' @import ggplot2
#' @importFrom scales comma
#' @export
plotFiltrationStats <- function(object) {
  nsampls <- samples(object) %>%
    length
  stats <- arbitrayFilterStats(object)
  
  plot <- ggplot(data = stats, mapping = aes(x = stat, y = Count)) +
    geom_boxplot(outlier.shape = NA) +
    geom_jitter(height = 0, 0.75 / nsampl) +
    scale_y_log10(labels = scales::comma) +
    labs(x = "") +
    my_theme
  
  plot
}

#' Arbitray Filter Statistics
#' 
#' Very simple helper function to import chimeric reads, and record which the quantity of included and excluded backsplice junction covering reads
#'
#' @param object A circExperiment object
#'
#' @return
#' A tibble with filtration statistics
#' @examples
#' #stats <- arbitrayFilterStats(object = circObject)
#' @import dplyr 
#' @importFrom tidyr pivot_longer
#' @export
setGeneric(name = "arbitrayFilterStats", def = function(object) {
  bsj.reads(object) %>%
    dplyr::mutate(
      Sample = sample.id(object)
    ) 
})

setMethod(f = "arbitrayFilterStats", signature = "circExperiment", definition = function(object) {
  smpls <- samples(object)
  
  reads <- lapply(X = smpls, FUN = doStuff) %>%
    do.call(what = rbind)
  
  dplyr::group_by(reads, Sample) %>%
    dplyr::summarise(
      Included = sum(include.read),
      Excluded = sum(!include.read)
    ) %>%
    tidyr::pivot_longer(cols = -Sample, names_to = "stat", values_to = "Count") %>%
    dplyr::mutate(stat = factor(as.factor(stat), levels = c("Included", "Excluded")))
})


