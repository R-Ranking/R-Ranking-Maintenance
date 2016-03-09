# OBJECTIVE: This script helps look into the dowloads of one package, 
#            and generate a rick-content HTML file.


# INPUT:
  # data: should be a data.frame containing ALL the downloads of one month (the month of interest) (do pre-extraction to make this data frame only contain the records of this month, so that it's smaller therefore faster)


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


summarize_HTML_for_package <- function(package_of_interest, data){
  

  
  # "path to save" is which path to save the generated HTML file
  # NOTE: the format should be like "/home/ubuntu/test/". Do NOT ignore the last slash "/"
  
  
  # Generate # of downloads & Ranking information--------------------------------------
  
  # the country information
  temp = data[data$package==package_of_interest,]
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
                 <title>How ', package_of_interest, ' Behaved in Last Month</title>
                 
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
                 '</u> Behaved in Last Month</h2>
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

n_packages <- length(package_list)

for(i in 1:length(package_list)){
  summarize_HTML_for_package(package_list[i],
                             dat)
  if(i %in% round(quantile(1:n_packages, seq(0, 1, 0.05)), 0)){
    cat("Generating HTML Files. ",
        names(round(quantile(1:n_packages, seq(0, 1, 0.05)), 0))[which(round(quantile(1:n_packages, seq(0, 1, 0.05)), 0)==i)], 
        " done (", i, "/", n_packages, ")",
        ".\n", sep="")
  }
}
