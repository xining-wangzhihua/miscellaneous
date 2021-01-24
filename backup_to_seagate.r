#! /usr/bin/Rscript
# license: BSD 3-Clause License
# author: https://github.com/ywd5


# This version is stable, but not good. Revision in the future is:
# Remove the path of "backup table.txt" in script, and make the user specify it like "Rscript backup.r x='backup table.txt'" in the shell.
# add .sh scripts, with the same function as r scripts
# add --noatime?s?, try --quiet, in x$args
# although --human-readable already take effect, try --human-readable=1 and --human-readable=3


# get dependencies--------------------------------------------------------------
library(magrittr); library(tibble); library(dplyr); library(stringr); library(parallel);
if(Sys.which(names="rsync")[1] == ""){stop("rsync isn't available in the shell");}


# parameters that may need to be modified in each occasion----------------------
if(system2(command="sudo", args="cryptsetup status luks1-seagate", stdout=NULL) != 0){
  message("decrypting the disk\n")
  system2(command="sudo", args="cryptsetup open UUID=ec1357d9-7259-4807-9e8c-bfdecca69a39 --type luks1 luks1-seagate")
}
if(system2(command="findmnt", args="/mnt/seagate", stdout=NULL) != 0){
  message("mounting the disk\n")
  system2(command="sudo", args="mount /dev/mapper/luks1-seagate /mnt/seagate")
}
destination_prefix <- "/mnt/seagate/backup_zm/"
#
source_prefix <- "/mnt/"
log_file <- paste0(destination_prefix, "backup log.xml")
x <- readLines(con="/home/gray/Documents/backup table.txt") %>% str_trim(side="both") %>%
  {.[. != ""]} %>% grep(pattern="^#", x=., invert=TRUE, value=TRUE) %>% strsplit(split=" {5,}")


# prepare rsync commands--------------------------------------------------------
lengths(x) %>% {. == 2} %>% {if(!all(.)){stop("not all lines contain 2 fileds");}}
unlist(x) %>% grepl(pattern="^\'(.+)\'$") %>% {if(!all(.)){stop("not all items are quoted by \'");}}
x %<>% lapply(FUN=base::sub, pattern="^\'(.+)\'$", replacement="\\1") %>%
  simplify2array() %>% base::t() %>%
  as_tibble(.name_repair="minimal") %>% setNames(nm=c("source", "destination")) %>%
  dplyr::mutate(source=paste0(source_prefix, source),
                destination=paste0(destination_prefix, destination),
                log=paste0(tempfile(), " ", 1:length(x)), args="")
x$args <- paste0("--recursive --delete-before --preallocate --times --human-readable",
                 if(FALSE){" --modify-window=1"}else{" --checksum"},
                 " --log-file=\'", x$log, "\' --links --verbose \'",
                 x$source, "\' \'", x$destination, "\'")
remove(source_prefix, destination_prefix)
x$source %>% {.[!file.exists(.)]} %>% paste0(collapse="\n") %>%
  {if(. != ""){stop("the following source directories don't exist:\n", .);}}
x$destination %>% unique() %>% {.[!dir.exists(.)]} %>% lapply(FUN=dir.create, recursive=TRUE)
x$destination %>% unique() %>% {.[!dir.exists(.)]} %>% paste0(collapse="\n") %>%
  {if(. != ""){stop("can't create the following destination directories:\n", .);}}


# run rsync, merge logs into one file-------------------------------------------
message("\n\n\nbegin synchronizing\n\n\n"); base::Sys.sleep(time=3);
tulip <- parallel::makeCluster(spec=2)
parallel::clusterApplyLB(cl=tulip, x=x$args, fun=base::system2, command="rsync")
parallel::stopCluster(cl=tulip)
remove(tulip)
#
"<root time=\"%Y%m%d-%H%M%S\">\n" %>% strftime(x=Sys.time(),format=.) %>%
  cat(sep="", file=log_file, append=FALSE)
for(i in 1:nrow(x)){
  if(i != 1){cat("\n\n\n\n\n", sep="", file=log_file, append=TRUE);}
  cat("<trunk command=\"rsync ", x$args[i], "\">\n", sep="", file=log_file, append=TRUE)
  file.append(file1=log_file, file2=x$log[i])
  cat("</trunk>\n", sep="", file=log_file, append=TRUE)
}; remove(i);
cat("</root>\n\n", sep="", file=log_file, append=TRUE)
message("\nthe log is written to: ", log_file, "\n")


# clean environment and leave log_file only (maybe useless)---------------------
remove(x)
log_file

