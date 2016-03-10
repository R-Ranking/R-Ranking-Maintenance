# This is the very initial step of the work-flow of R-Ranking
# To download the data files 
# Acknowledgment: This code is modified from the sample code provided ono cran-logs.rstudio.com


# USAGE:
# "Rscript 1_download_raw_data.R "2015-01-01" "2015-01-31" /Users/nus/test/"


# Pass the arguments
args = commandArgs(trailingOnly=TRUE)


# easy way to get all the URLs of period of interest
start <- as.Date(args[1])
end <- as.Date(args[2])

# get the path to save the downloaded data file 
dest_path = args[3]

all_days <- seq(start, end, by = 'day')

year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')


# Dowload files
# note that the index starts from 2 as we already have done one above.
for (i in 1:length(urls)){
	download.file(urls[i],
	              destfile = paste(dest_path, "/", all_days[i],".csv.gz", sep=""),
	              quiet = TRUE)
  
  cat(i, "/", length(urls), " files have been downloaded.\n")
  
}

