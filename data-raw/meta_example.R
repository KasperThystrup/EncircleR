## code to prepare `meta_example` dataset goes here

meta_raw <- "Sample\tFilename\tMate\tName
SRR12927182\t~/Demonstration/Samples/SRR12927182/rawdata/SRR12927182_1.fq.gz\t1\tExperiment_A
SRR12927182\t~/Demonstration/Samples/SRR12927182/rawdata/SRR12927182_2.fq.gz\t2\tExperiment_A
SRR10991486\t~/Demonstration/Samples/SRR10991486/rawdata/SRR10991486_1.fq.gz\t1\tExperiment_A
SRR10991486\t~/Demonstration/Samples/SRR10991486/rawdata/SRR10991486_2.fq.gz\t2\tExperiment_A
SRR10545428\t~/Demonstration/Samples/SRR10545428/rawdata/SRR10545428_1.fq.gz\t1\tExperiment_B
SRR10545428\t~/Demonstration/Samples/SRR10545428/rawdata/SRR10545428_2.fq.gz\t2\tExperiment_B
SRR10037664\t~/Demonstration/Samples/SRR10037664/rawdata/SRR10037664_1.fq.gz\t1\tExperiment_C
SRR10037664\t~/Demonstration/Samples/SRR10037664/rawdata/SRR10037664_2.fq.gz\t2\tExperiment_C"

meta_example <- readr::read_tsv(meta_raw)

# Move manually to EncircleR/inst/extdata
readr::write_tsv(x = meta_example, file = file.path(wd, "inst/extdata", "Metadata_example.tsv"))

usethis::use_data(meta_example, overwrite = TRUE)
