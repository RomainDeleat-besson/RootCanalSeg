#!/bin/sh


./run_main1.sh "/app/matlab/v98"

python3 ./testing_saving.py

./run_main2.sh "/app/matlab/v98"

