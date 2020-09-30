
<!-- README.md is generated from README.Rmd. Please edit that file -->

EncircleR
=========

The goal of EncircleR is to automate and streamline circRNA analysis, by
providing a graphical interface for selecting and downloading reference
files, Perform read trimming and read mapping, and finally to perform
circRNA detection by exploring backsplice junction contents.

Installation
------------

First install the circRNA detection algorithm

    devtools::install_github("https://github.com/KasperThystrup/circulaR")

You can then install the latest release of EncircleR from Github with:

    devtools::install_github("https://github.com/KasperThystrup/EncircleR")

### Dependencies

-   STAR aligner
    (<a href="https://github.com/alexdobin/STAR" class="uri">https://github.com/alexdobin/STAR</a>)
-   fastp
    (<a href="https://github.com/OpenGene/fastp" class="uri">https://github.com/OpenGene/fastp</a>)

Example
-------

This is a basic example which shows you how to solve a common problem:

    library(EncircleR)

    # Run
    EncircleR::run_app()
    ## basic example code

How to run
==========

Clone the repository and open `EncircleR.Rproj` with Rstudio. First up
open `R/utils_DEFUALTS.R` and set the appropriate values

Next: Try to run the entire script in `dev/run_dev.R`, install any
packages that is missing.

The process is stepwise, where options by default are hidden, until the
appropriate steps have been taken. Note that STAR\_idx takes ALOT of RAM
and FASTP and STAR alignment takes a lot of cpu time as well.

The app requires gz compressed (or uncompressed) fastq files, a metadata
file with the following columns:

1.  Sample name
2.  Full filepath
3.  Read Mate

The app currently copies (option to move instead) fastq files to a
experimental directory (default set in `R/utils_DEFAULTS.R` fastp and
STAR is run on each sample, and relocated systematically Finally, the
circulaR algorithm is used to run circRNA analysis (circulaR must be
installed, but have not yet been uplaoded to github)
