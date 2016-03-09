# December 5, 2015
# This is a script helping generate JavaScirpt data script for the R-Ranking website
# the data format is generated according to the requirement of Geo charts (Google Charts, https://developers.google.com/chart/interactive/docs/gallery/geochart?hl=zh-cn)

# Input: an ORDERED data frame about country ranking in format like
#               country   Downloads_count
#                US           1000
#                CN         900
#                IN           750
#                ......          ....

# Output:  Write out the data frame into a Javascript file which helps generate the map with Geo Charts in Google Charts

args = commandArgs(trailingOnly=TRUE)

path_to_save_summarized_data <- args[1]

period <- paste(args[2],
                " to ",
                args[3],
                sep="")

# load the data
dat <- read.csv(paste(path_to_save_summarized_data,
                                                 "/Country_ranking_",
                                                 period,
                                                 ".csv",
                                                 sep=""))

header = "var map_data = google.visualization.arrayToDataTable([ 
	  ['country', 'Downloads'],"

temp_paste <- function(i){
	body=paste( 
		"['", dat[i,1], "',",
		dat[i,2], "]"
		,sep='')	
}

temp_body <- sapply(1:dim(dat)[1], temp_paste)
body <- paste(temp_body, collapse=",")


ender = "]);"

cat(paste(header, body, ender, sep=" "), file=paste(args[4], "/map_data", sep=""))
