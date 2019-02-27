



parallel -j $1  "makeblastdb -in {} -dbtype nucl" :::: $2
