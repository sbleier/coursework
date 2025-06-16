#!/bin/bash

# filter original 1gram file googlebooks-eng-all-1gram-20120701-1.gz to only lines where the ngram exactly matches a year (18xx, 19xx, or 20xx, where x is a digit)
#   decompress the first using gunzip, zless, zcat or similar
gunzip googlebooks-eng-all-1gram-20120701-1.gz
#   then filter out rows that match using grep -E, egrep, awk, or similar
 grep -E '[1-2][8,9,0][0-9][0-9]'  googlebooks-eng-all-1gram-20120701-1 > year_counts.tsv
#   write results to year_counts.tsv


