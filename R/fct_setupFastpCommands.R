fastpCommand <- function(
  fastp, sample, meta, exp_dir, compressed, trim_front, trim_tail,
  front_cut, tail_cut, paired, overrep, corr, overwrite, threads
) {

  if (corr & !paired)
    warning("Correction is only for paired end: Correction enabled, but it will be ignored!")

  out_dir = file.path(exp_dir, "Samples", sample, "fastp")

  sample_subset <- dplyr::filter(meta, Sample == sample)

  mate1 <- subset(sample_subset, Mate == 1) %>%
    dplyr::pull(Filepath)

  trimmed1 <- file.path(
    out_dir,
    paste(sample, paste("1_trimmed.fq", compressed, sep = "."),
          sep = "_")
  )

  mate2 <- ""
  trimmed2 <- ""
  if (nrow(sample_subset == 2)) {
    mate2 <- subset(sample_subset, Mate == 2) %>%
      dplyr::pull(Filepath)

    trimmed2 <- file.path(
      out_dir,
      paste(sample, paste("2_trimmed.fq", compressed, sep = "."),
            sep = "_")
    )
  }

  if (all(file.exists(trimmed1), file.exists(trimmed2)) & !overwrite)
    return(TRUE)

  cmd_arguments <- list(
    systemCall = fastp,
    in1 = paste("--in1", mate1),
    in2 = paste("--in2", mate2),
    out1 = paste("--out1", trimmed1),
    out2 = paste("--out2", trimmed2),
    json = paste(
      "--json",
      file.path(out_dir, paste(paste("fastp", sample, sep = "_"), "json", sep = "."))
    ),
    html = paste(
      "--html",
      file.path(out_dir, paste(paste("fastp", sample, sep = "_"), "html", sep = "."))
    ),
    cut_front = ifelse(front_cut, "--cut_front", ""),
    cut_tail = ifelse(tail_cut, "--cut_tail", ""),
    trim_front1 = ifelse(trim_front > 0, paste("--trim_front1", trim_front), ""),
    trim_front2 = ifelse(trim_front > 0 & paired, paste("--trim_front2", trim_front), ""),
    trim_tail1 = ifelse(trim_tail > 0, paste("--trim_tail1", trim_tail), ""),
    trim_tail2 = ifelse(trim_tail > 0 & paired, paste("--trim_tail2", trim_tail), ""),
    thread= paste("--thread", threads),
    overrepresentation_analysis = ifelse(overrep, "--overrepresentation_analysis", ""),
    detect_adapter_for_pe = ifelse(paired, "--detect_adapter_for_pe", ""),
    correction = ifelse(paired & corr, "--correction", "")
  )

  cmd_makedir <- paste("mkdir -p", file.path(out_dir))

  system(cmd_makedir)

  cmd_report <- tibble::tibble(Argument = names(cmd_arguments), Input = unlist(cmd_arguments))

  readr::write_tsv(
    x = cmd_report,
    path = file.path(
      out_dir,
      paste(sample,"fastp_call.tsv", sep = "_")
    )
  )

  cmd_call <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_call)
}
