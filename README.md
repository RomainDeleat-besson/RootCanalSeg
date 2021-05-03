# RootCanalSeg
Root canal segmentation


to build the docker use this command line:

docker build -t dockerrootcanal .


to run the code use this command line:

./RootCanalSeg.sh -i My/input/file.nii


to run the docker use this command line:

docker run --rm \
    -v ${inputdir}:/app/src/scan/$(basename ${inputdir}) \
    -v $(dirname ${inputdir}):/app/src/OutputData \
    dockerrootcanal:latest \
    /app/src/RootCanal/RCS_main.sh
