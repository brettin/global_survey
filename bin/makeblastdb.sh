# $1 is number of parallel threads, use 72
# $2 is the file list of genomes



parallel -j $1  "makeblastdb -in {} -dbtype nucl" :::: $2
