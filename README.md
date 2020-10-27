
<!-- README.md is generated from README.Rmd. Please edit that file -->

EncircleR
=========

The goal of EncircleR is to automate and streamline circRNA analysis, by
providing a graphical interface for selecting and downloading reference
files, Perform read trimming and read mapping, and finally to perform
circRNA detection by exploring backsplice junction contents.

Installation and startup
========================

Dependencies
------------

The package requires the following external software to be installed

-   STAR aligner
    (<a href="https://github.com/alexdobin/STAR" class="uri">https://github.com/alexdobin/STAR</a>),
    Alignment and chimeric read detection
-   fastp
    (<a href="https://github.com/OpenGene/fastp" class="uri">https://github.com/OpenGene/fastp</a>),
    Read trimming and quality parametrics
-   R
    (<a href="https://cran.rstudio.com/" class="uri">https://cran.rstudio.com/</a>),
    Statistical programming language for running EncircleR
-   Rstudio
    (<a href="https://rstudio.com/products/rstudio/download/#download" class="uri">https://rstudio.com/products/rstudio/download/#download</a>),
    Graphical R interface which simplifies executing and openning
    EncircleR

#### Locate the binary execution files

In order to make EncircleR call the STAR aligner and fastp software, you
must provide the absolute path to their binary execution files.

For STAR aligner on linux, this can be located in:

    /path/to/STAR/bin/Linux_x86_64/STAR

For fastp (when installed through Bioconda (Miniconda3)):

    /path/to/bioconda/bin/fastp

### R packages

After Rstudio has been successfully installed a few R packages must be
installed, to make this process easier, open Rstudio and follow the
steps below.

Most official R package dependencies should be installed during
installation of EncircleR, however there are a few packages that needs
to be installed manually first:

    install.packages(c("devtools", "BiocManager"))

Once BiocManager has been installed, the following Bioconductor packages
will have to be installed as well.

    BiocManager::install(c("AnnotationHub", "plyranges"))

The circRNA detection algorithm (circulaR) used by EncircleR are
installed via GitHub:

    devtools::install_github("https://github.com/KasperThystrup/circulaR")

Finally, you can then install EncircleR via Github:

    devtools::install_github("https://github.com/KasperThystrup/EncircleR")

### How to run

After EncricleR has been successfully installed, it can be executed by
opening RStudio and execute:

    EncircleR::run_app()

If package will not execute with above code
-------------------------------------------

Clone the repository and open `EncircleR.Rproj` with Rstudio, first
enter: File &gt; New project &gt; Version control &gt; Git

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
