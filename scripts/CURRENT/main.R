rm(list=ls())


# Load configuration information ------------------------------------------

configuration_info <- scan(file = "configuration",
                           what = "text",
                           sep = "\n",
                           quiet = TRUE)

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
cores_PARALLEL <- configuration_info[grep("cores_PARALLEL", configuration_info)]
cores_PARALLEL <- as.integer(strsplit(cores_PARALLEL, split = ":")[[1]][2])



# Check if the paths & files from configuration exist -----------------------------
# If the path required doesn't exist, give a warning message and stop the program

path_to_check <- c(path_to_save_raw_data, 
                   path_to_save_summarized_data,
                   path_to_save_package_HTML,
                   path_to_save_map_JS_data)
file_to_check <- c(path_pyspark)


num_of_missing_path <- 0
for(path in path_to_check){
  if(dir.exists(path) == FALSE){
    cat("ERROR: The path '", path, "' you configured doesn't exist.\n", sep="")
    num_of_missing_path <- num_of_missing_path + 1
  }
}

num_of_missing_file <- 0
for(f in file_to_check){
  if(file.exists(f) == FALSE){
    cat("ERROR: The file '", f, "' you configured doesn't exist.\n", sep="")
    num_of_missing_file <- num_of_missing_file + 1
  }
}

# if there is any missing path or file, stop the program.
if(num_of_missing_file + num_of_missing_path >0){
  stop("\nSome path or file you configured can not be found on your machine.\n
       Please check the ERROR messages above and configure again.\n\n")
}



# Download the raw data ---------------------------------------------------

cat(rep("=", 18), "\n")
cat("Step-1: Downloading the raw data\n")
cat(as.character(Sys.time()), "\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 1_download_raw_data.R", 
                       start_date, 
                       end_date, 
                       path_to_save_raw_data))


# Process the data with Apache Spark --------------------------------------

cat(rep("=", 18), "\n")
cat("Step-2: Summarizing raw data with Apache Spark\n")
cat(as.character(Sys.time()), "\n")
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
cat(as.character(Sys.time()), "\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 3_summarize_HTML_for_package_PARALLEL.R",
                       path_to_save_raw_data,
                       path_to_save_package_HTML,
                       path_to_save_summarized_data,
                       start_date,
                       end_date,
                       cores_PARALLEL))

# Generate Javascript data file for "View on Map".

cat(rep("=", 18), "\n")
cat("Step-4: Generate JS data file for 'View on Map'\n")
cat(as.character(Sys.time()), "\n")
cat(rep("=", 18), "\n\n")

system(command = paste("Rscript 4_generate_JS_data_for_map.R",
                       path_to_save_summarized_data,
                       start_date,
                       end_date,
                       path_to_save_map_JS_data))
