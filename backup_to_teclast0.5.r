#! /usr/bin/Rscript
# license: BSD 3-Clause License
# author: https://github.com/ywd5

# revision to be done-----------------------------------------------------------
# Remove the path of "backup table.txt" in script, and make the user specify it like "Rscript backup.r x='backup table.txt'" in the shell.
# add .sh scripts, with the same function as r scripts
# add --noatime?s?, try --quiet --stats, in x$args
# for remote synchronization, try: --compress --skip-compress=tar,zip,rar,xz,gz,bz2
# although --human-readable already take effect, try --human-readable=1 and --human-readable=3
# merge "teclast1.0" and "teclast0.5" scripts
# get dependencies--------------------------------------------------------------
library(magrittr); library(tibble); library(dplyr); library(stringr); library(parallel);
if(Sys.which(names="rsync")[1] == ""){stop("rsync isn't available in the shell");}
# may need modification: mount disk---------------------------------------------
if(system2(command="cryptsetup", args="status teclast0.5", stdout=NULL) != 0){
  message("decrypting the disk\n")
  system2(command="cryptsetup", args="open UUID=aeefc3f1-2ca9-4399-ab6c-5c85c0c66d98 --type luks2 teclast0.5")
}
if(system2(command="findmnt", args="--source UUID=5ecb7176-a61d-4619-a6b0-a7f572668dad", stdout=NULL) != 0){
  message("mounting the disk\n")
  system2(command="mount", args="--source UUID=5ecb7176-a61d-4619-a6b0-a7f572668dad --target /mnt/teclast0.5")
  # system2(command="mount", args="--source /dev/mapper/teclast0.5 --target /mnt/teclast0.5")
}
# may need modification: specify source, destination and log--------------------
destination_prefix <- "/mnt/teclast0.5/backup_zm/"
#
source_prefix <- "/mnt/"
x <- readLines(con="/home/user1/synchronization/backup table.txt") %>% str_trim(side="both") %>%
  {.[. != ""]} %>% grep(pattern="^#", x=., invert=TRUE, value=TRUE) %>% strsplit(split=" {5,}")
log_file <- c("/home/user1/synchronization/backup log.xml", "/mnt/c/Users/wangz/Downloads/backup log.xml")
# control input-----------------------------------------------------------------
if(!dir.exists(source_prefix)){stop("source_prefix doesn't exist");}
if(!dir.exists(destination_prefix)){stop("destination_prefix doesn't exist");}
if(length(log_file) != 0) if(any(nchar(log_file) == 0)){
  stop("log_file can't contain empty strings, but cat be character().")
}
lengths(x) %>% {. == 2} %>% {if(!all(.)){stop("not all lines contain 2 fileds");}}
unlist(x) %>% grepl(pattern="^\'(.+)\'$") %>% {if(!all(.)){stop("not all items are quoted by \'");}}
# add default log file----------------------------------------------------------
log_file %<>% c(paste0(destination_prefix, "backup log.xml"), .)
# prepare rsync commands--------------------------------------------------------
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
x$destination %>% unique() %>% {.[!dir.exists(.)]} %>%
  {if(length(.) != 0){lapply(X=., FUN=dir.create, recursive=TRUE);}}
x$destination %>% unique() %>% {.[!dir.exists(.)]} %>% paste0(collapse="\n") %>%
  {if(. != ""){stop("can't create the following destination directories:\n", .);}}
# run rsync---------------------------------------------------------------------
message("\n\n\nbegin synchronizing\n\n\n"); base::Sys.sleep(time=3);
tulip <- parallel::makeCluster(spec=2)
parallel::clusterApplyLB(cl=tulip, x=x$args, fun=base::system2, command="rsync")
parallel::stopCluster(cl=tulip)
remove(tulip)
# get log(s)--------------------------------------------------------------------
"<root time=\"%Y%m%d-%H%M%S\">\n" %>% strftime(x=Sys.time(),format=.) %>%
  cat(sep="", file=log_file[1], append=FALSE)
for(i in 1:nrow(x)){
  if(i != 1){cat("\n\n\n\n\n", sep="", file=log_file[1], append=TRUE);}
  cat("<trunk command=\"rsync ", x$args[i], "\">\n", sep="", file=log_file[1], append=TRUE)
  file.append(file1=log_file[1], file2=x$log[i])
  cat("</trunk>\n", sep="", file=log_file[1], append=TRUE)
}; remove(i);
cat("</root>\n\n", sep="", file=log_file[1], append=TRUE)
if(length(log_file) > 1) for(i in 2:length(log_file)){
  file.copy(from=log_file[1], to=log_file[i], overwrite=TRUE)
}; i <- 0; remove(i);
message("the log(s) is(are) written to:\n", paste0(log_file, collapse="\n"))
# may need modification: clean environment and un-mount disk--------------------
remove(x, log_file)
system2(command="umount", args="UUID=5ecb7176-a61d-4619-a6b0-a7f572668dad")
system2(command="cryptsetup", args="close teclast0.5")

