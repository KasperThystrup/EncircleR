#' Generate STAR index
#'
#' @param star
#' @param out_dir
#' @param fa_file
#' @param gtf_file
#' @param read_length
#' @param threads
#'
#' @examples
#'
#' @return
#' @export
#' @importFrom readr write_tsv
#' @importFrom tibble tibble
generateSTARidx <- function(star, out_dir, fa_file, gtf_file, read_length, threads) {
  # tmp_load <- file.path(out_dir, "tmp")

  # cmd_makedir <- paste("mkdir -p", tmp_load)
  # system(cmd_makedir)

  cmd_arguments <- list(
    systemCall = star,
    runMode = "--runMode genomeGenerate",
    # outTmpDir = paste("--outTmpDir", tmp_load),
    genomeDir = paste("--genomeDir", out_dir),
    genomeFastaFiles = paste("--genomeFastaFiles", fa_file),
    sjdbGTFfile = paste("--sjdbGTFfile", gtf_file),
    sjdbOverhang = paste("--sjdbOverhang", read_length - 1),
    runThreadN = paste("--runThreadN", threads)
  )

  # Generate output dir
  cmd_makedir <- paste("mkdir -p", out_dir)
  system(cmd_makedir)

  # Generating a command report
  cmd_report <- tibble::tibble(Argument = names(cmd_arguments), Input = unlist(cmd_arguments))
  readr::write_tsv(x = cmd_report, path = file.path(out_dir, "STAR_idx.tsv"))

  # Running index command
  cmd <- unlist(cmd_arguments) %>%
    paste(collapse = " ")

  system(cmd)

}


