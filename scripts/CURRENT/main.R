rm(list=ls())


# Load configuration information ------------------------------------------

configuration_info <- scan(file = "configuration",
                           what = "text")

start_date <- configuration_info[grep("start_date", configuration_info)]
start_date <- strsplit(start_date, split = ":")[[1]][2]
end_date <- configuration_info[grep("end_date", configuration_info)]
end_date <- strsplit(end_date, split = ":")[[1]][2]
path_to_save_raw_data <- configuration_info[grep("path_to_save_raw_data", configuration_info)]
path_to_save_raw_data <- strsplit(path_to_save_raw_data, split = ":")[[1]][2]
path_pyspark <- configuration_info[grep("path_pyspark", configuration_info)]
path_pyspark <- strsplit(path_pyspark, split = ":")[[1]][2]
path_to_save_summarized_data <- configuration_info[grep("path_to_save_summarized_data", configuration_info)]
path_to_save_summarized_data <- strsplit(path_to_save_summarized_data, split = ":")[[1]][2]
path_to_save_package_HTML <- configuration_info[grep("path_to_save_package_HTML", configuration_info)]
path_to_save_package_HTML <- strsplit(path_to_save_package_HTML, split = ":")[[1]][2]
path_to_save_map_JS_data <- configuration_info[grep("path_to_save_map_JS_data", configuration_info)]
path_to_save_map_JS_data <- strsplit(path_to_save_map_JS_data, split = ":")[[1]][2]


# Download the raw data ---------------------------------------------------

cat(rep("=", 18), "\n")
cat("Step-1: Downloading the raw data\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 1_download_raw_data.R", 
                       start_date, 
                       end_date, 
                       path_to_save_raw_data))


# Process the data with Apache Spark --------------------------------------

cat(rep("=", 18), "\n")
cat("Step-2: Summarizing raw data with Apache Spark\n")
cat(rep("=", 18), "\n\n")

system(command = paste(path_pyspark,
                       "2_summarize_raw_data.py",
                       path_to_save_raw_data,
                       path_to_save_summarized_data,
                       start_date,
                       end_date))


# Generate HTML file for each package

cat(rep("=", 18), "\n")
cat("Step-3: Generating HTML file for each package\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 3_summarize_HTML_for_package.R",
                       path_to_save_raw_data,
                       path_to_save_package_HTML,
                       path_to_save_summarized_data,
                       start_date,
                       end_date))

# Generate Javascript data file for "View on Map".

cat(rep("=", 18), "\n")
cat("Step-4: Generate JS data file for 'View on Map'\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 4_generate_JS_data_for_map.R",
                       path_to_save_summarized_data,
                       start_date,
                       end_date,
                       path_to_save_map_JS_data))
