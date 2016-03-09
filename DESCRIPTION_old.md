In this file, the objectives and how-to of all the scripts are stated.

# Scripts

## Summarize_for_DB.R

This script helps extract summarized data of a specific month from Database and generate the corresponding .RData file as well as .CSV file.

The generated files will give information like [1] the rankings and download counts of all packages having records in the specified month; [2] the rankings and download counts of all countries.


## generate_data_for_map.R

This script helps generate JavaScript which will be used show a Geo chart.

The input it requires is a R data frame containing two columns: country codes, and the corresponding download counts.

The javascript generated will be used for the "show on map" feature on R-Ranking website.


## People_of_impact.R

This script supports the "people of impact" feature on the R-Ranking website.

## summarize_HTML_for_package.R


# Sample Data

## Nov_country_ranking.RData
This is for script `generate_dat_for_map.R`.

## Nov_package_ranking.RData
This is for script  `people_of_impact.R`