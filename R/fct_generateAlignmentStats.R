subsetAlignmentStatistics <- function(object, stat_select = NULL) {
  stts <- circulaR::alignmentStats(object = object, out_type = "long")
  
  if (!is.null(stat_select))
    stts <- subset(stts, stat %in% stat_select)
  
  return(stts)
}


# @import ggplot2
plotAlignmentPecentages <- function(object, colours = "default") {
  
  if (colours == "default")
    colours <- c(
      "Uniquely mapped reads %" = "#4DAF4A",
      "% of reads mapped to multiple loci" = "#FBB4AE",
      "% of reads mapped to too many loci" =  "#B3CDE3",
      "% of reads unmapped: too many mismatches" =  "#CCEBC5",
      "% of reads unmapped: too short" = "#DECBE4",
      "% of reads unmapped: other" = "#FED9A6"
    )
  
  stat_select <- c(
    "Uniquely mapped reads %", "% of reads mapped to multiple loci",
    "% of reads mapped to too many loci", "% of reads unmapped: too many mismatches",
    "% of reads unmapped: too short", "% of reads unmapped: other"
  )
  
  stts_percentages <- subsetAlignmentStatistics(object, stat_select)
  
  align_plot <- ggplot2::ggplot(
    data = stts_percentages, mapping = aes(x = sample, y = value, fill = stat)
  ) +
    geom_bar(stat = "identity") +
    labs(x = "", y = "Percent") +
    my_theme +
    theme(legend.position = "bottom")
  
  if (!is.null(colours))
    align_plot <- align_plot + scale_fill_manual(name = "Mapping statistics", values = colours)
  
  return(align_plot)
}

# @import ggplot2
# @importfrom tidyr pivot_wider
# @importfrom dplyr rename
plotSpliceLibSize <- function(object) {
  stat_select <- c("Number of input reads", "Number of splices: Total", "Splice sites per read")
  
  stts_SvsLS <- subsetAlignmentStatistics(object, stat_select) %>%
    tidyr::pivot_wider(names_from = stat, values_from = value) %>%
    dplyr::rename(splice_total = "Number of splices: Total", reads_total = "Number of input reads")
  
  if (nrow(stts_SvsLS) < 2)
    return(FALSE)
  
  ggplot(data = stts_SvsLS, mapping = aes(x = splice_total, y = reads_total)) +
    geom_point(alpha = 0.5, size = 2) + 
    stat_smooth(geom = "line", method = "lm", linetype = "dashed") +
    labs(x = "Total splice junctions", y = "Total reads") +
    my_theme
}


chimericReadStats <- function(object) {
  smpls <- circulaR::samples(object)
  
  readStats <- lapply(X = seq_along(smpls), FUN = function(i) {
    smpl <- smpls[[i]]
    
    stats_raw <- dplyr::summarise(
      circulaR::bsj.reads(smpl),
      sample = circulaR::sample.id(smpl),
      Encompassing = sum(X7 == "-1"),
      `Read spanning` = sum(X7 != "-1"),
      `Bad read pairs` = sum(!PEok),
      `Good read pairs` = sum(PEok)
    )
    
    tidyr::pivot_longer(
      data = stats_raw, cols = -sample, names_to = "stat", values_to = "count"
    )
  }) %>%
    do.call(what = rbind)
  
  return(readStats)
}


plotReadStats <- function(object) {
  readStats <- chimericReadStats(object)
  
  ggplot(data = readStats, mapping = aes(x = stat, y = count)) +
    geom_boxplot(outlier.shape = NA) +
    geom_jitter(height = 0, width = 0.05) +
    scale_y_log10(label = scales::number) +
    my_theme
}


