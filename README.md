
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EncircleR

The goal of EncircleR is to automate and streamline circRNA analysis, by
providing a graphical interface for selecting and downloading reference
files, Perform read trimming and read mapping, and finally to perform
circRNA detection by exploring backsplice junction contents.

### Dependencies

Install the latest version of R and R-studio

-   R (<https://cran.rstudio.com/>), Statistical programming language
    for running EncircleR
-   Rstudio (<https://rstudio.com/products/rstudio/download/#download>),
    Graphical R interface which simplifies executing and openning
    EncircleR.

Install the `circulaR` package from github, following its readme:
<https://github.com/KasperThystrup/circulaR>

In order to install the `EncirclaR` R package, you must ensure to
install the following Biocodncutor packages:

-   AnnotationHub
-   S4Vectors
-   plyranges

``` r
install.packages("BiocManager")
BiocManager::install(c("AnnotationDbi", "BiocGenerics", "BSgenome", "DESeq2", "ensembldb", "GenomeInfoDb", "GenomicFeatures", "GenomicRanges", "Gviz", "IRanges", "Rsamtools", "S4Vectors"))
```

In addition, `devtools` r package must be installed, to enable easy
installation of `EncirclaR` from github.

``` r
install.packages("devtools")
devtools::install_github("https://github.com/KasperThystrup/EncircleR")
```

This should install all dependencies from the official CRAN repository.
However, if something does not work out, try to install the CRAN
dependencies manually before running the install github command again:

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
-   readr
-   tibble
-   tidyr
-   scales
-   stringr
-   dplyr

``` r
install.packages(c("logger", "config", "ggplot2", "golem", "shinyjs", "shiny", "processx", "attempt", "DT", "glue", "htmltools", "shinydashboard", "readr", "tibble", "tidyr", "scales", "stringr", "dplyr", "circulaR"))
```
