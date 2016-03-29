
# read argument from command line
import sys

# the first argument will be file name by default, so even if we only enter 3 arguments, there will be four.
# this is also why we start index from 1 instead of 0.


data_directory=str(sys.argv[1])
path_to_save_summarized_data=str(sys.argv[2])
period = str(sys.argv[3]) + " to " + str(sys.argv[4])

print("Building the Spark Context--------------------------")
from pyspark import SparkContext
sc = SparkContext(appName="R-Ranking")

print("Loading the data------------------------------------")
raw_content = sc.textFile(data_directory)


print("Cleaning the data---------------------------------")
content = raw_content.map(lambda x: x.split(','))

def clean(x):
    for i in range(len(x)):
        x[i]=x[i].replace('"','')
    return(x)
content = content.map(clean)

# to persist the "content" object as it will be called for multiple times later
# This should be able to improve the performance of whole script
content.persist()

print(str(content.count()) + " rows of data loaded.")

print("Calculating the downloads of the packages-----------")
package_count = content.map(lambda x: (x[6], 1)).reduceByKey(lambda a,b: a+b)
country_count = content.map(lambda x: (x[8], 1)).reduceByKey(lambda a,b: a+b)

print("Sorting and collecting into Python------------------")
a_package = package_count.map(lambda x: (x[1], x[0])).sortByKey(0).map(lambda x: (x[1], x[0])).collect()
a_country = country_count.map(lambda x: (x[1], x[0])).sortByKey(0).map(lambda x: (x[1], x[0])).collect()



print("Final process & Save as CSV-------------------------")

# clean the rows derived from the previous header
for i in range(len(a_package)):
    if a_package[i][0] == "package":
        a_package.remove(a_package[i])
        break

for i in range(len(a_country)):
    if a_country[i][0] == "country":
        a_country.remove(a_country[i])
        break

# prepare for writing CSV files
for i in range(len(a_package)):
    a_package[i]=(a_package[i][0], str(a_package[i][1]))
    a_package[i]=','.join(a_package[i])

for i in range(len(a_country)):
    a_country[i]=(a_country[i][0], str(a_country[i][1]))
    a_country[i]=','.join(a_country[i])

package_ranking="\n".join(a_package)
country_ranking="\n".join(a_country)

# add header
package_ranking="package,downloads\n"+package_ranking
country_ranking="country,downloads\n"+country_ranking

# write CSV files
f=open(path_to_save_summarized_data + "/Package_ranking_" + period + ".csv", "w")
f.write(package_ranking)
f.close()

f=open(path_to_save_summarized_data + "/Country_ranking_" + period + ".csv", "w")
f.write(country_ranking)
f.close()

print("Done :-)  ------------------------------------------")
