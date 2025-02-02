#!/bin/bash
#SBATCH --job-name=fasterq_dump
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 6
#SBATCH --mem=30G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=crclouser@gmail.com
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

#################################################################
# Download fastq files from SRA 
#################################################################

# load software
module load parallel/20180122
module load sratoolkit/3.0.1

# The data are from this study:
    # https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE156460
    # https://www.ncbi.nlm.nih.gov/bioproject/PRJNA658029


OUTDIR=../../data/fastq
    mkdir -p ${OUTDIR}
METADATA=../../metadata/SraRunTable.txt

# Get a list of SRA accession numbers to download, put them in a file

# there are 8 populations and 75 samples. 
# the metadata table was downloaded from the SRA's "Run Selector" page. 

# extract rows matching our population names, pull out the SRA accession number (the first column)
ACCLIST=../../metadata/accessionlist.txt
tail -n +2 $METADATA | cut -f 1 -d "," >$ACCLIST

# use parallel to download 2 accessions at a time. 
cat $ACCLIST | parallel -j 2 "fasterq-dump -O ${OUTDIR} {}"

# compress the files 
ls ${OUTDIR}/*fastq | parallel -j 12 gzip


echo "download all the tiny letters"
