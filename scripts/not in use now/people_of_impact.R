# December 5, 2015
# This script helps obtain the list of authors of top 50 packages, and "rank" them based on the "impact" factor

# How we define "impact" factor?
# If one person is involved into one top 50 package, his impact is 1. If involved into 3 packages, his impact is 3

# Input: an ORDERED data frame in format like
#               package   Downloads_count
#                Rcpp           1000
#                ggplot2         900
#                RCurl           750
#                ......          ....

# Output:  (1) A 10-row ORDERED data frame like
#		author     impact_factor
#                 A             12
#                 B              8
#                ...            ...
#
#	AND
#		
#          (2)Write out the data frame into a Javascript file which plotting a word cloud
	
#########################################################################

rm(list=ls())

load("/home/ubuntu/test/demo_data/Nov_package_ranking.RData")
dat <- get(ls())
rm(list=ls()[-which(ls()=='dat')])

package_list <- dat$package[1:50]
link_list <- paste("http://cran.r-project.org/web/packages/", package_list, sep = "")

author_list <- c()
for(i in 1:length(link_list)){
  temp <- scan(link_list[i], what='char', sep='\n')
  author_line <- grep(pattern='Author:', temp) + 1
  author_content <- paste(temp[author_line:length(temp)], collapse = " ")
  author_content <- strsplit(author_content, split = "</td>")[[1]][1]
  author_content <- strsplit(author_content, split = "<td>")[[1]][2]
  
  # remove the parts like [aut] in the "Author" part, so we can have "pure" author name
  author_content = strsplit(author_content, split = "[[]+[a-zA-Z' '',']+[]]")[[1]]
  temp_result=c()
  for(j in 1:length(author_content)){
    temp_result <- c(temp_result, strsplit(author_content[j], split = ", ")[[1]]) 
  }
  
  author_list <- c(author_list, temp_result)
}

author_list <- author_list[which(nchar(author_list) != 0)]

# strip

strip_index_end <- grep(" $", author_list) # those who end with whitespace
if(length(strip_index_end) > 0){
  author_list[strip_index_end] <- sapply(strip_index_end, function(i){substr(author_list[i], 1, nchar(author_list[i])-1)})
}

strip_index_start <- grep("^ ", author_list) # those who start with whitespace
if(length(strip_index_start) > 0){
  author_list[strip_index_start] <- sapply(strip_index_start, function(i){substr(author_list[i], 1, nchar(author_list[i])-1)})
}

author_list <- author_list[which(author_list != "RStudio")] # removed since it's not a person

people_of_impact <- data.frame(rev(sort(table(author_list)))[1:10])

print(people_of_impact)
print(dim(people_of_impact))
header <- "
function createRandomItemStyle() {
    return {
        normal: {
            color: 'rgb(' + [
                Math.round(Math.random() * 200),
                Math.round(Math.random() * 200),
                Math.round(Math.random() * 200)
            ].join(',') + ')'
        }
    };
}

 var myChart = echarts.init(document.getElementById('people_of_impact'));
        myChart.setOption({
    
    title:{
	text: 'People of Impact'
	},
    series: [{
	name: 'People of Impact',
        type: 'wordCloud',
        size: ['80%', '80%'],
        textRotation : [0, 45, -45],
        textPadding: 0,
        autoSize: {
            enable: true,
            minSize: 14
        },
        data: [
"
temp_paste <- function(i){
	body = paste(
		"{ name:'", row.names(people_of_impact)[i],"', value:", people_of_impact[i,1]*1000, 
		", itemStyle: createRandomItemStyle()}"
		, sep="")
}
# here the impacts are timed with 1000. This is to adjust the size in the image generated

temp_body <- sapply(1:dim(people_of_impact)[1], temp_paste)

body <- paste(temp_body, collapse = ',') 

ender = "
        ]
    }]  
        });
"
cat(paste(header, body, ender, sep=" "), file="/var/www/html/data_js/people_of_impact.js")


