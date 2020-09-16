attachSTARGenome <- function(star, genome_dir) {
  tmp_load <- file.path(genome_dir, "tmp")
  cmd_makedir <- paste("mkdir -p", tmp_load)
  system(cmd_makedir)

  cmd_arguments <- list(
    systemCall = star,
    genomeDir = paste("--genomeDir", genome_dir),
    outFileNamePrefix = paste("--outFileNamePrefix", tmp_load, "tmp-"),
    genomeLoad = "--genomeLoad LoadAndExit",
    outSAMtype = "--outSAMtype None"
  )

  # Running command
  cmd_attach <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_attach)
}


callSTAR <- function(
  star, genome_dir, threads, sample, meta, paired, out_dir, RAM_limit,
  chim_segMin, compression = "gz"
) {

  cmd_makedir <- paste("mkdir -p", out_dir)
  system(cmd_makedir)

  mate1 <- subset(meta, Mate == 1) %>%
    dplyr::pull(var = Filepath)
  mate2 <- ""
  if (paired)
    mate2 <- subset(meta, Mate == 2) %>%
    dplyr::pull(var = Filepath)

  readFilesCommand = ""
  if (compression == "gz")
    readFilesCommand = "--readFilesCommand zcat"

  cmd_arguments <- list(
    systemCall = star,
    runMode = "--runMode alignReads",
    genomeLoad = "--genomeLoad LoadAndKeep",
    runThreadN = paste("--runThreadN", threads),
    readFilesIn = paste("--readFilesIn", mate1, mate2),
    outFileNamePrefix = paste("--outFileNamePrefix", file.path(out_dir, paste0(smpl, "."))),
    limitBAMsortRAM = paste("--limitBAMsortRAM", RAM_limit),
    outReadsUnmapped = "--outReadsUnmapped Fastq",
    outSAMtype = "--outSAMtype BAM SortedByCoordinate",
    outSAMunmapped = "--outSAMunmapped Within KeepPairs",
    outBAMsortingThreadN = paste("--outBAMsortingThreadN", round(threads/2, digits = 0)),
    chimSegmentMin = paste("--chimSegmentMin", chim_segMin),
    quantMode = "--quantMode GeneCounts",
    bamRemoveDuplicatesType = "--bamRemoveDuplicatesType UniqueIdentical",
    readFilesCommand = readFilesCommand
  )


  cmd_report <- tibble::tibble(Argument = names(cmd_arguments), Input = unlist(cmd_arguments))

  readr::write_tsv(
    x = cmd_report,
    path = file.path(
      out_dir,
      paste(
        dplyr::pull(meta, Sample) %>% unique,"STAR_call.tsv"
      )
    )
  )

  cmd_call <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_call)
}


dettachSTARGenome <- function(star, genome_dir) {
  tmp_load <- file.path(genome_dir, "tmp")
  cmd_arguments <- list(
    systemCall = star,
    genomeDir = paste("--genomeDir", genome_dir),
    genomeLoad = "--genomeLoad Remove",
    outFileNamePrefix = paste("--outFileNamePrefix", tmp_load),
    outSAMtype = "--outSAMtype None"
  )

  # Running command
  cmd_dettach <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_dettach)

  # cmd_remove <- paste("rm -R", dirname(tmp_load))
  # 
  # system(cmd_remove)
}
