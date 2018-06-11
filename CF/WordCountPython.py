import re
import sys
from pyspark import SparkConf, SparkContext

conf = SparkConf()
sc = SparkContext(conf=conf)

# Load the data
data = sc.textFile(sys.argv[1])

# Parse the data into words
words = data.flatMap(lambda line: re.split(r'[^\w]+', line))

# Deal with case
caps = words.map(lambda word: word.upper())

# Remove empty words
final = caps.filter(lambda word: word != '')

# Convert each word into a tuple of its first letter and 1
pairs = final.map(lambda word: (word[0], 1))

# Sum the counts for each character and save them to disk
pairs.reduceByKey(lambda c1, c2: c1 + c2).sortByKey().saveAsTextFile(sys.argv[2])

sc.stop()