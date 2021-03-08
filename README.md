
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EncircleR

The goal of EncircleR is to automate and streamline circRNA analysis, by
providing a graphical interface for selecting and downloading reference
files, Perform read trimming and read mapping, and finally to perform
circRNA detection by exploring backsplice junction contents.

### Software

In order to use the tools provided in this guide, and to install the
required dependencies, the following external software must be
installed:

-   libgit2: [Ubuntu 20.04
    LTS](https://packages.ubuntu.com/source/focal/libgit2) [Arch
    Linux](https://archlinux.org/packages/extra/x86_64/libgit2), [Mac
    Homebrew](https://formulae.brew.sh/formula/libgit2)
-   gcc-fortran: [Ubuntu 20.04
    LTS](https://packages.ubuntu.com/focal/gfortran) [Arch
    Linux](https://archlinux.org/packages/core/x86_64/gcc-fortran) [Mac
    installation
    instructions](https://gcc.gnu.org/wiki/GFortranBinariesMacOS)
-   R: [Ubuntu](https://cran.r-project.org/bin/linux/ubuntu/) \[Arch
    linux\] (<https://archlinux.org/packages/extra/x86_64/r/>)
    [Mac](https://cran.r-project.org/)
-   RStudio: [Ubuntu &
    Mac](https://rstudio.com/products/rstudio/download/) [Arch
    linux](https://aur.archlinux.org/packages/rstudio-desktop-bin/)

## The circulaR package

EncircleR uses the `circulaR R` package for performing circRNA
detection. Therefore, in order to install `EncircleR`, the `circulaR`
pacakge along with its dependencies, must be installed.

### R package dependencies

The following Biocodncutor packages are dependencies of both the
`circulaR` and the `EncircleR` package:

circulaR:

-   AnnotationDbi
-   BiocGenerics
-   BSgenome
-   DESeq2
-   ensembldb
-   GenomeInfoDb
-   GenomicFeatures
-   GenomicRanges
-   Gviz
-   IRanges
-   Rsamtools
-   S4Vectors

EncircleR \* AnnotationHub \* S4Vectors \* plyranges

``` r
install.packages("BiocManager")
BiocManager::install(c("AnnotationDbi", "BiocGenerics", "BSgenome", "DESeq2", "ensembldb", "GenomeInfoDb", "GenomicFeatures", "GenomicRanges", "Gviz", "IRanges", "Rsamtools", "S4Vectors", "AnnotationHub", "S4Vectors", "plyranges"))
```

The `devtools` R package must be installed, to enable easy installation
of `circulaR` and `EncircleR` from github.

``` r
install.packages("devtools", dependencies = TRUE)
devtools::install_github("https://github.com/KasperThystrup/circulaR")
devtools::install_github("https://github.com/KasperThystrup/EncircleR")
```

## Troubleshooting

This should install all dependencies from the official CRAN repository.
However, if something does not work out, try to install these CRAN
dependencies manually with `install.pacakges` before running the install
github command again:

-   dplyr
-   ggplot2
-   parallel
-   pbmcapply
-   plyr
-   readr
-   RSQLite
-   stringi
-   tibble
-   tidyr
-   logger
-   config
-   ggplot2
-   golem
-   shinyjs
-   shiny
-   processx
-   attempt
-   DT
-   glue
-   htmltools
-   shinydashboard
-   scales

# Execution

To starting the graphical interface up, the following commands should be
executed.

``` r
library(EncircleR)
run_app()
```
