
<!-- README.md is generated from README.Rmd. Please edit that file -->

EncircleR
=========

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of EncircleR is to …

Installation
------------

You can install the released version of EncircleR from
[CRAN](https://CRAN.R-project.org) with:

    install.packages("EncircleR")

Example
-------

This is a basic example which shows you how to solve a common problem:

    library(EncircleR)
    #> Warning: replacing previous import 'IRanges::collapse' by 'dplyr::collapse' when
    #> loading 'circulaR'
    #> Warning: replacing previous import 'IRanges::union' by 'dplyr::union' when
    #> loading 'circulaR'
    #> Warning: replacing previous import 'IRanges::slice' by 'dplyr::slice' when
    #> loading 'circulaR'
    #> Warning: replacing previous import 'IRanges::intersect' by 'dplyr::intersect'
    #> when loading 'circulaR'
    #> Warning: replacing previous import 'IRanges::setdiff' by 'dplyr::setdiff' when
    #> loading 'circulaR'
    #> Warning: replacing previous import 'IRanges::desc' by 'dplyr::desc' when loading
    #> 'circulaR'
    #> Warning: replacing previous import 'BiocGenerics::combine' by 'dplyr::combine'
    #> when loading 'circulaR'
    #> Warning: replacing previous import 'dplyr::select' by 'AnnotationDbi::select'
    #> when loading 'circulaR'
    #> Warning: replacing previous import 'shiny::runExample' by 'shinyjs::runExample'
    #> when loading 'EncircleR'
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
