#! /usr/bin/Rscript
# license: BSD 3-Clause License
# author: https://github.com/ywd5


# usage of Rscript (a command line tool):
# echo -e 'z=3\n4\n5' | Rscript /opt/rscripts/learn_Rscript.r x=1 y="2" # if /opt/rscripts isn't in $PATH
# echo -e 'z=3\n4\n5' | learn_Rscript.r x=1 y="2" # if /opt/rscripts is in $PATH
stop("this script is undone, and need further test.")


x <- as.numeric(Sys.getenv(x="x"))
x
y <- as.numeric(Sys.getenv(x="y"))
y
z <- as.numeric(Sys.getenv(x="z"))
cat("length of z is: ", length(z), "\nz is: ",paste0(z, collapse=", "), "\n")
z <- x + y + z
return(z) # this will generate an error, and stop the script
z
