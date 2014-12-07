#!/bin/bash

# Set Directory Variables
ST_DIR=/home/rts/litmus-rt/liblitmus/ft_tools
FILTER_DIR=/home/rts/proj/tut01
ST_TOOLS_DIR=/home/rts/litmus-rt/sched-trace-tools-master
LIBLITMUS_DIR=/home/rts/litmus-rt/liblitmus

# Get Current Scheduler
PLUGIN=`eval $LIBLITMUS_DIR/showsched`
# Set program to run based on scheduler
if [ "$PLUGIN" = "PSN-EDF" -o "$PLUGIN" = "P-FP" -o "$PLUGIN" = "PFAIR" ]; then
	FILTER_PROG_0=filter_part_0
	FILTER_PROG_1=filter_part_1
elif [ "$PLUGIN" = "GSN-EDF" ]; then
	FILTER_PROG_0=filter
	FILTER_PROG_1=filter
elif [ "$PLUGIN" = "C-EDF" ]; then
	FILTER_PROG_0=filter_clust_0
	FILTER_PROG_1=filter_clust_1
else
	FILTER_PROG_0=filter
	FILTER_PROG_1=filter
fi

# Get Current Date Time Group
DTG=`eval date +%Y%m%d_%H_%M`

# Launch Sched Trace on each CPU
#sudo nohup ./st_trace &
#st_pid=$!
#echo st pid = $st_pid

# Move to Filter Directory
cd $FILTER_DIR

COUNTER=0
# Launch Tasks
while [ $COUNTER -lt 5 ]; do
	sudo ./$FILTER_PROG_0 video01.mp4 video01.mkv &
	v1_pid=$!
	echo video01 pid = $v1_pid filter_prog = $FILTER_PROG_0
	
	sudo ./$FILTER_PROG_1 video02.mp4 video02.mkv &
	v2_pid=$!
	echo video02 pid = $v2_pid filter_prog = $FILTER_PROG_1
	
	sudo ./$FILTER_PROG_0 video03.mp4 video03.mkv &
	v3_pid=$!
	echo video03 pid = $v3_pid filter_prog = $FILTER_PROG_0
	
	sudo ./$FILTER_PROG_1 video04.mp4 video04.mkv &
	v4_pid=$!
	echo video04 pid = $v4_pid filter_prog = $FILTER_PROG_1
	
	# Wait for completion
	wait $v1_pid
	echo video01 completed pid = $v1_pid
	wait $v2_pid
	echo video02 completed pid = $v2_pid
	wait $v3_pid
	echo video03 completed pid = $v3_pid
	wait $v4_pid
	echo video04 completed pid = $v4_pid

	let COUNTER=COUNTER+1
done

# Copy st_trace output to st-trace-tools
#cp st--0.bin $ST_TOOLS_DIR
#cp st--1.bin $ST_TOOLS_DIR
wait

#exit
#cd $ST_TOOLS_DIR
exit 0
