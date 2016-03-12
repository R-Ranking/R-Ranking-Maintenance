# OBJECTIVE: This script helps look into the dowloads of one package, 
#            and generate a rick-content HTML file.


# INPUT:
  # dat: should be a data.frame containing ALL the downloads of one month (the month of interest) (do pre-extraction to make this data frame only contain the records of this month, so that it's smaller therefore faster)


args = commandArgs(trailingOnly=TRUE)

data_path <- args[1]
path_to_save_HTML <- args[2]
path_to_save_summarized_data <- args[3]
period <- paste(args[4],
                " to ",
                args[5],
                sep="")

summarize_package_ranking_data <- read.csv(paste(path_to_save_summarized_data,
                                                 "/Package_ranking_",
                                                 period,
                                                 ".csv",
                                                 sep=""))


summarize_HTML_for_package <- function(package_of_interest){
  
  
  # Generate # of downloads & Ranking information--------------------------------------
  
  # the country information
  temp = dat[dat$package==package_of_interest,]
  temp_table=table(temp$country)
  temp = data.frame(country = names(temp_table), downloads=as.vector(temp_table))
  total_number_of_download <- sum(temp[,2])
  
  ranking <- min(which(summarize_package_ranking_data$downloads == total_number_of_download))
  
  # generate map JavaScirpt data -----------------------
  header = "var map_data = google.visualization.arrayToDataTable([
  ['country', 'Downloads'],"
  
  temp_paste <- function(i){
    body=paste(
      "['", temp[i,1], "',",
      temp[i,2], "]"
      ,sep='')
  }
  
  temp_body <- sapply(1:dim(temp)[1], temp_paste)
  body <- paste(temp_body, collapse=",")
  
  ender = "]);"
  
  map_data_JS <- paste(header, body, ender, sep=" ")
  
  # generate the linke on CRAN
  link_on_CRAN <- paste("https://cran.r-project.org/web/packages/", package_of_interest, "/index.html", sep="")
  
  # Generate the final HTML file
  result = paste('
                 <!DOCTYPE html>
                 <html>
                 <head>
                 <meta charset="utf-8">
                 <meta http-equiv="X-UA-Compatible" content="chrome=1">
                 <title>How ', package_of_interest, ' Performed in Last Month</title>
                 
                 <link rel="stylesheet" href="/stylesheets/styles.css">
                 <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
                 
                 </head>
                 
                 <body>
                 
                 <table width="800" border="0">
                 <tr>
                 <td colspan="2" >
                 <h1><a href=\'http://R-Ranking.com\'>R-Ranking</a></h1>
                 <h2>How <u>',
                 package_of_interest,
                 '</u> Performed in Last Month</h2>
                 </td>
                 </tr>
                 
                 <tr valign="top">
                 <td style="width:300px;text-align:top;">
                 <b>Summary</b><br />',
                 
                 'Ranking: ', ranking, '<br />
                 Downloads: ', total_number_of_download,'<br />
                 <a href="',link_on_CRAN,'">Link on CRAN</a>
                 </td>
                 
                 
                 <td style="height:200px;width:400px;text-align:top;">

<center>

                 <script type="text/javascript" src="https://www.google.com/jsapi?autoload={\'modules\':[{\'name\':\'visualization\',\'version\':\'1.1\',\'packages\':[\'geochart\']}]}"></script>
                 <div id="map_div" style="width: 800px; height: 500px;"></div>
                 
                 <script type="text/javascript">
                 ',
                 map_data_JS,
                 '
                 </script>
                 
                 <script type="text/javascript">
                 google.setOnLoadCallback(drawRegionsMap);
                 
                 function drawRegionsMap() {
                 
                 var options = {};
                 
                 var chart = new google.visualization.GeoChart(document.getElementById("map_div"));
                 
                 chart.draw(map_data, options);
                 }
                 </script>
                 
                 </center>
                 
                 
                 
                 
                 </td>
                 </tr>
                 
                 </table>
                 
                 </body>

<script>
                 (function(i,s,o,g,r,a,m){i[\'GoogleAnalyticsObject\']=r;i[r]=i[r]||function(){
                 (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                 m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,\'script\',\'//www.google-analytics.com/analytics.js\',\'ga\');

                 ga(\'create\', \'UA-63780621-2\', \'auto\');
                 ga(\'send\', \'pageview\');
                 
                 </script>
                 
                 </html>
                 ',
                 sep="")
  
  cat(result,
      file = paste(path_to_save_HTML,
                   package_of_interest, 
                   ".html", sep="")
  )
}


data_file_list <- dir(data_path)
dat <- NULL
for(a in data_file_list){
  dat <- rbind(dat, read.csv(gzfile(paste(data_path, a, sep = ""))))
}

package_list=unique(dat$package)


# Use parallel algorithm to fasten the procedures of generating HTML files.
#(It takes quite long time to generate HTML files for almost 9000 packages. Do this in parallel should be able to help)
library(parallel)

cat("The parallel computing cluster is built to generate HTML files.\n")

# User can specify how many cores they want to use for paralllel computing cluster.
# if user specified 0 in the configuration file, then all cores will be called.
cores_PARALLEL <- as.integer(args[6])

if(cores_PARALLEL == 0){
  num_of_cores_to_use <- parallel::detectCores()
} else {
  num_of_cores_to_use <- cores_PARALLEL
}

parallelCluster <- parallel::makeCluster(num_of_cores_to_use)
cat(num_of_cores_to_use,
    " cores are called to build the cluster.\n\n",
    sep="")


clusterExport(cl = parallelCluster,
              varlist = c("dat",
                          "summarize_package_ranking_data",
                          "path_to_save_HTML"))
parSapply(parallelCluster, package_list, FUN=summarize_HTML_for_package)

stopCluster(parallelCluster)
cat("The parallel computing cluster is shutted down.\n")