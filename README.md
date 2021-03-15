
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EncircleR

The goal of EncircleR is to automate and streamline circRNA analysis, by
providing a graphical interface for selecting and downloading reference
files, Perform read trimming and read mapping, and finally to perform
circRNA detection by exploring backsplice junction contents.

## Third party software

In order to use the tools provided in this guide, and to install the
required dependencies, the following external software must be
installed:

### Dependencies

-   libgit2: \[[Ubuntu 20.04
    LTS](https://packages.ubuntu.com/source/focal/libgit2)\], \[[Arch
    Linux](https://archlinux.org/packages/extra/x86_64/libgit2)\],
    \[[Mac Homebrew](https://formulae.brew.sh/formula/libgit2)\]
-   gcc-fortran: \[[Ubuntu 20.04
    LTS](https://packages.ubuntu.com/focal/gfortran)\], \[[Arch
    Linux](https://archlinux.org/packages/core/x86_64/gcc-fortran)\],
    \[[Mac installation
    instructions](https://gcc.gnu.org/wiki/GFortranBinariesMacOS)\]
-   R: \[[Ubuntu](https://cran.r-project.org/bin/linux/ubuntu/)\],
    \[[Arch linux](https://wiki.archlinux.org/index.php/R)\],
    \[[Mac](https://cran.r-project.org/)\]
-   RStudio: \[[Ubuntu &
    Mac](https://rstudio.com/products/rstudio/download/)\], \[[Arch
    linux](https://wiki.archlinux.org/index.php/R#RStudio_IDE)\]

### Tools

EncircleR envokes different bioinformatic tools in order to process raw
reads and quantify genes and circRNAs. These tools must be installed and
the path to their binary execution file must be noted.

The following tools are evoked during the pipeline:

-   STAR-aligner \[[GitHub](https://github.com/alexdobin/STAR)\]
-   fastp \[[GitHub](https://github.com/OpenGene/fastp)\]

In this guide, I utilize Miniconda to install these tools, as it easily
handles the depedenencies of these tools. Also, the path to the local
binary execution files are easy to locate.

Miniconda depends on Python3 so in order to make sure it is installed,
the following command should determine its installation path. If you
yield an error message, it is not installed.

``` bash
which python3
```

Install Python3, if it is not installed. \[[Ubuntu
20.04](https://packages.ubuntu.com/focal/python3)\], \[[Arch
Linux](https://wiki.archlinux.org/index.php/python)\],
\[[Mac](https://www.python.org/downloads/mac-osx/)\]

Next, download and install Miniconda, following their own guide.
[Download](https://docs.conda.io/en/latest/miniconda.html) and
[Installation
instructions](https://conda.io/projects/conda/en/latest/user-guide/install/index.html).

Note the installation folder (Defaults to:
`/home/[YOUR USER]/miniconda3`), it is relevant for the next step. Also,
if chosing `[yes]` to initialise conda on terminal startup, make sure to
restart the terminal to ensure that it is initialized.

#### Installing Tools with Miniconda

Install the fastp and STAR-aligner by executing the following command.

``` bash
conda install -c bioconda fastp
conda install -c bioconda star
```

Finally, we need to note the path to the binary execution file, when
installed through Miniconda, these can be located from the Miniconda
installation folder.

The tools should be located at:

-   `/home/[YOUR USER]/miniconda3/bin/STAR`
-   `/home/[YOUR USER]/miniconda3/bin/fastp`

Now we are set up for installing the R packages.

## R package dependencies

EncircleR uses the `circulaR` R package for performing circRNA
detection. Therefore, in order to install `EncircleR`, the `circulaR`
pacakge along with its dependencies, must be installed.

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

EncircleR:

-   AnnotationHub
-   S4Vectors
-   plyranges

``` r
install.packages("BiocManager")
BiocManager::install(c("AnnotationDbi", "BiocGenerics", "BSgenome", "DESeq2", "ensembldb", "GenomeInfoDb", "GenomicFeatures", "GenomicRanges", "Gviz", "IRanges", "Rsamtools", "S4Vectors", "AnnotationHub", "S4Vectors", "plyranges"))
```

### Installation

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

# How to use

## Setup

In this example four Paired end Total RNA samples are downloaded from
the ENA browser. These can be found and downloaded from [ENA
Browser](https://www.ebi.ac.uk/ena/browser/view/):

-   [SRR10037664](https://www.ebi.ac.uk/ena/browser/view/SRR10037664)
-   [SRR10545428](https://www.ebi.ac.uk/ena/browser/view/SRR10545428)
-   [SRR10991486](https://www.ebi.ac.uk/ena/browser/view/SRR10991486)
-   [SRR12927182](https://www.ebi.ac.uk/ena/browser/view/SRR12927182)

After downloading, a metadata sheet containing sample information must
be set up. The pipeline takes the following format:

-   A sample name column
-   A file path column
-   A Read mate column
-   A Name column

``` r
knitr::kable(x = EncircleR::meta_example, caption = "An example metadata sheet")
```

| Sample      | Filename                                                          | Mate | Name          |
|:------------|:------------------------------------------------------------------|-----:|:--------------|
| SRR12927182 | \~/Demonstration/Samples/SRR12927182/rawdata/SRR12927182\_1.fq.gz |    1 | Experiment\_A |
| SRR12927182 | \~/Demonstration/Samples/SRR12927182/rawdata/SRR12927182\_2.fq.gz |    2 | Experiment\_A |
| SRR10991486 | \~/Demonstration/Samples/SRR10991486/rawdata/SRR10991486\_1.fq.gz |    1 | Experiment\_A |
| SRR10991486 | \~/Demonstration/Samples/SRR10991486/rawdata/SRR10991486\_2.fq.gz |    2 | Experiment\_A |
| SRR10545428 | \~/Demonstration/Samples/SRR10545428/rawdata/SRR10545428\_1.fq.gz |    1 | Experiment\_B |
| SRR10545428 | \~/Demonstration/Samples/SRR10545428/rawdata/SRR10545428\_2.fq.gz |    2 | Experiment\_B |
| SRR10037664 | \~/Demonstration/Samples/SRR10037664/rawdata/SRR10037664\_1.fq.gz |    1 | Experiment\_C |
| SRR10037664 | \~/Demonstration/Samples/SRR10037664/rawdata/SRR10037664\_2.fq.gz |    2 | Experiment\_C |

An example metadata sheet

## Execution

To starting the graphical interface up, the following commands should be
executed.

``` r
library(EncircleR)
run_app()
```
