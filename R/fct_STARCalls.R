attachSTARGenome <- function(star, genome_dir) {
  tmp_load <- file.path(genome_dir, "tmp/")
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

  mate1_raw <- subset(meta, Mate == 1 & Sample == sample) %>%
    dplyr::pull(var = Filepath)
  
  mate1_dir <- dirname(mate1_raw)
  mate1_split <- strsplit(x = mate1_raw, split = "/") %>%
    unlist %>%
    tail(1)
  
  mate1_file <- strsplit(x = mate1_split, split = "\\.") %>%
    unlist %>%
    head(1)
  mate1_ext <- fileExt(mate1_split)
  
  mate1 <- file.path(
    out_dir, sample, "fastp",
    paste(
      paste(mate1_file, "trimmed", sep = "_"),
      paste(mate1_ext, collapse = "."),
      sep = "."
    )
  )
  
  mate2 <- ""
  if (paired){
    mate2_raw <- subset(meta, Mate == 2 & Sample == sample) %>%
      dplyr::pull(var = Filepath)
    
    mate2_dir <- dirname(mate2_raw)
    mate2_split <- strsplit(x = mate2_raw, split = "/") %>%
      unlist %>%
      tail(1)
    
    mate2_file <- strsplit(x = mate2_split, split = "\\.") %>%
      unlist %>%
      head(1)
    mate2_ext <- fileExt(mate2_split)
    
    mate2 <- file.path(
      out_dir, sample, "fastp",
      paste(
        paste(mate2_file, "trimmed", sep = "_"),
        paste(mate2_ext, collapse = "."),
        sep = "."
      )
    )
  }

  readFilesCommand = ""
  if (compression == "gz")
    readFilesCommand = "--readFilesCommand zcat"

  cmd_arguments <- list(
    systemCall = star,
    runMode = "--runMode alignReads",
    genomeDir = paste("--genomeDir", genome_dir),
    genomeLoad = "--genomeLoad NoSharedMemory",
    # genomeLoad = "--genomeLoad LoadAndKeep",
    runThreadN = paste("--runThreadN", threads),
    readFilesIn = paste("--readFilesIn", paste(mate1, mate2, collapse = " ")),
    outFileNamePrefix = paste("--outFileNamePrefix", file.path(out_dir, sample, "STAR", paste0(sample, "."))),
    # limitBAMsortRAM = paste("--limitBAMsortRAM", RAM_limit),
    outReadsUnmapped = "--outReadsUnmapped Fastq",
    # outSAMtype = "--outSAMtype BAM SortedByCoordinate",
    outSAMtype = "--outSAMtype None",
    outSAMunmapped = "--outSAMunmapped Within KeepPairs",
    outBAMsortingThreadN = paste("--outBAMsortingThreadN", round(threads/2, digits = 0)), # BAM not used Disable!
    chimSegmentMin = paste("--chimSegmentMin", chim_segMin),
    quantMode = "--quantMode GeneCounts",
    bamRemoveDuplicatesType = "--bamRemoveDuplicatesType UniqueIdentical", # BAM not used Disable!
    readFilesCommand = readFilesCommand
  )

  
  cmd_report <- tibble::tibble(Argument = names(cmd_arguments), Input = unlist(cmd_arguments))

  readr::write_tsv(
    x = cmd_report,
    path = file.path(
      out_dir,
      paste(sample, "STAR", "STAR_call.tsv")
    )
  )

  cmd_call <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_call)
}


dettachSTARGenome <- function(star, genome_dir) {
  tmp_load <- file.path(genome_dir, "tmp/")
  cmd_arguments <- list(
    systemCall = star,
    genomeDir = paste("--genomeDir", genome_dir),
    genomeLoad = "--genomeLoad Remove",
    outFileNamePrefix = paste("--outFileNamePrefix", tmp_load, "tmp-"),
    outSAMtype = "--outSAMtype None"
  )

  # Running command
  cmd_dettach <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd_dettach)

  cmd_remove <- paste("rm -R", tmp_load)

  system(cmd_remove)
}
