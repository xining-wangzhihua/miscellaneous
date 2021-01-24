#a function to install commonly used r packages

InstallRPackages <- function(install_rarely_used = FALSE){
  #ensure "R.home()/site-library" exist-----------------------------------------
  if(!dir.exists(paths=R.home(component="site-library"))){
    dir.create(path=R.home(component="site-library"))
  }
  #install and require "installr" and "BiocManager"-----------------------------
  if( !("installr" %in% rownames(installed.packages())) ){
    install.packages(pkgs="installr", lib=R.home(component="site-library"))
  }
  if(!require(installr)){stop("can't install the required package \"installr\"");}
  if( !("BiocManager" %in% rownames(installed.packages())) ){
    install.packages(pkgs="BiocManager", lib=R.home(component="site-library"))
  }
  if(!require(BiocManager)){stop("can't install the required package \"BiocManager\"");}
  #control the input of "install_rarely_used"-----------------------------------
  if(!is.logical(install_rarely_used)){stop("install_rarely_used must be TRUE or FALSE");}
  if(length(install_rarely_used) != 1){stop("length(install_rarely_used) must be 1");}
  install_rarely_used <- as.logical(install_rarely_used)
  if(!( install_rarely_used %in% c(TRUE, FALSE) )){stop("install_rarely_used must be TRUE or FALSE");}
  #if in windows os, set path to "rtools" to enable installing from source------
  if(.Platform$OS.type == "windows"){
    #using "base::Sys.which()" is also ok, but more complex than "installr::system.PATH()"
    ans <- grep(pattern="rtools", x=installr::system.PATH(), value=TRUE, ignore.case=TRUE)
    if(length(ans) != 1){
      warning("can't find path of rtools. installing from source may not be available", immediate.=TRUE)
    }else{
      ans <- sub(pattern="rtools\\usr\\bin", replacement="rtools\\mingw$(WIN)\\bin", x=ans, fixed=TRUE)
      ans <- gsub(pattern="\\", replacement="/", x=ans, fixed=TRUE)
      Sys.setenv(BINPREF=ans)
    }
    remove(ans)
  }
  #give some messages-----------------------------------------------------------
  message("package rJava need jre (java runtime environment) to be installed and available in shell.")
  message("package gdata need perl to be installed and available in shell.")
  #"magick" may need "ImageMagick" to be installed
  #update packages--------------------------------------------------------------
  update.packages()
  BiocManager::install()
  #package lists----------------------------------------------------------------
  l.common <- c("data.table", "devtools", "digest", "dplyr", "gtools", "Hmisc",
                "installr", "magrittr", "network", "openssl", "purrr", "questionr",
                "R.utils", "readxl", "rlang", "stringr", "tibble", "tidyverse")
  #"Hmisc" may be installed only for `%nin%`
  #"installr" may be installed only for "system.PATH()"
  l.embed.other.languages <- c("Rcpp", "rJava", "rstan")
  l.oo <- c("R.methodsS3", "R.oo", "R6")
  l.web <- c("curl", "RCurl", "RSelenium", "rvest", "shiny", "XML", "xml2")
  l.bioinfo <- c("ade4", "adegenet", "adespatial", "ape", "apex", "Biodem",
                 "diveRsity", "genetics", "haplo.stats", "haplotypes",
                 "hierfstat", "homologene", "ips", "pegas", "phangorn",
                 "phylobase", "PopGenome", "PopGenReport", "read.gb", "rentrez",
                 "seqinr", "vegan")
  #l.bioinfo doesn't include packages in bioconductor
  l.map <- c("ggmap", "ggsn", "mapdata", "mapproj", "maps", "maptools",
             "OpenStreetMap", "OSMscale", "rgdal", "rgeos", "sf")
  l.graphics <- c("admixturegraph", "Cairo", "devEMF", "emojifont", "ggforce",
                  "ggimage", "ggnewscale", "ggplot2", "ggraph", "ggrepel",
                  "magick", "munsell", "qpdf", "RColorBrewer", "scatterpie",
                  "viridis", "viridisLite", "wesanderson")
  l.graphics.bioc <- "EBImage"
  l.common <- c(l.common, l.embed.other.languages, l.oo, l.web, l.bioinfo, l.map,
                l.graphics)
  l.bioc <- c("AnnotationDbi", "Biobase", "BiocGenerics", "DECIPHER",
              "genbankr", "IRanges", "GenomicFeatures", "GenomicRanges",
              "ggtree", "S4Vectors", "XVector", "Biostrings", "sangerseqR",
              "snpStats", "msa", "VariantAnnotation")
  l.bioc <- c(l.bioc, l.graphics.bioc)
  remove(l.embed.other.languages, l.oo, l.web, l.bioinfo, l.map, l.graphics, l.graphics.bioc)
  l.rare <- c("beepr", "dirmult", "fastmap", "fastmatch", "ff",
              "gdata", "ggplot2movies", "measurements", "numbers", "statnet",
              "plyr", "pryr", "readr", "reshape", "reshape2", "rlist", "rncl",
              "RNeXML", "splancs", "stringi", "tidyr", "utf8", "vctrs", "vroom",
              "XiMpLe", "xlsx")
  #
  if(anyDuplicated(c(l.common, l.bioc, l.rare)) != 0){
    ans <- c(l.common, l.bioc, l.rare)
    ans <- ans[duplicated(ans)]
    ans <- unique(ans)
    warning("the following package names are duplicated: ",paste0(ans,collapse=", "),"\nplease revise the codes")
    remove(ans)
  }
  #remove installed package names from the lists--------------------------------
  ans <- rownames(installed.packages())
  l.common <- setdiff(x=l.common, y=ans)
  l.bioc <- setdiff(x=l.bioc, y=ans)
  l.rare <- setdiff(x=l.rare, y=ans)
  remove(ans)
  #install packages-------------------------------------------------------------
  if(length(l.common) != 0){
    install.packages(pkgs=l.common, lib=R.home(component="site-library"))
  }
  if(length(l.bioc) != 0){
    BiocManager::install(pkgs=l.bioc, lib=R.home(component="site-library"))
  }
  if((length(l.rare) != 0) & install_rarely_used){
    install.packages(pkgs=l.rare, lib=R.home(component="site-library"))
  }
  #end--------------------------------------------------------------------------
  rm(install_rarely_used, l.common, l.bioc, l.rare)
  invisible(NULL)
}

#here are the test codes
if(FALSE){
  Sys.setenv(BINPREF="D:/app/rtools40/mingw$(WIN)/bin/")
  #Sys.setenv(BINPREF="D:/app/rtools40/mingw64/bin/")
  update.packages()
  BiocManager::install()
  #
  InstallRPackages()#InstallRPackages(install_rarely_used=TRUE)
  remove(InstallRPackages)
}
