#!/bin/bash

# Set Directory Variables
ST_DIR=/home/rts/litmus-rt/liblitmus/ft_tools
FILTER_DIR=/home/rts/proj/tut01
ST_TOOLS_DIR=/home/rts/litmus-rt/sched-trace-tools-master
LIBLITMUS_DIR=/home/rts/litmus-rt/liblitmus

# Get Current Scheduler
PLUGIN=`eval $LIBLITMUS_DIR/showsched`
# Get Current Date Time Group
DTG=`eval date +%Y%m%d_%H_%M`
RESULTS_DIR=$FILTER_DIR/results/$PLUGIN

# Move st_trace output to repo dir
if [ ! -d "$RESULTS_DIR/$DTG" ]; then
	mkdir -p $RESULTS_DIR/$DTG
fi

cd $ST_DIR
cat st--0.bin st--1.bin > st_results.bin
mv st_results.bin $RESULTS_DIR/$DTG/

cd $ST_TOOLS_DIR

# Run the results through st_jobs
./st_job_stats $RESULTS_DIR/$DTG/st_results.bin > $RESULTS_DIR/$DTG/st_jobs_out.csv

cd $FILTER_DIR
# Push the results through the parser and make a chart
python st_reader.py $RESULTS_DIR/$DTG/st_jobs_out.csv

wait

cd

exit 0
