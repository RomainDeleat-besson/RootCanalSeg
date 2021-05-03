#!/bin/sh


while getopts i: flag
do
    case "${flag}" in
        i) inputdir=${OPTARG};;
    esac
done


echo ${inputdir}


docker run --rm \
    -v ${inputdir}:/app/src/scan/$(basename ${inputdir}) \
    -v $(dirname ${inputdir}):/app/src/OutputData \
    dockerrootcanal:latest \
    /app/src/RootCanal/RCS_main.sh


