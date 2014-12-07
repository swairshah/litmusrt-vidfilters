#!/bin/bash

# Set Directory Variables
FT_DIR=/home/rts/litmus-rt/liblitmus/ft_tools
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
FT_FILE_CPU_0=trace_$DTG_cpu0
FT_FILE_CPU_1=trace_$DTG_cpu1

# Move to Feather Trace Directory
cd $FT_DIR
# Launch FT on each CPU
sudo ./ftcat /dev/litmus/ft_cpu_trace0 CXS_START CXS_END SCHED_START SCHED_END SCHED2_START SCHED2_END QUANTUM_BOUNDARY_START QUANTUM_BOUNDARY_END PLUGIN_SCHED_START PLUGIN_SCHED_END RELEASE_START RELEASE_END RELEASE_LATENCY > $FT_FILE_CPU_0 &
ft0_pid=$!
sudo ./ftcat /dev/litmus/ft_cpu_trace1 CXS_START CXS_END SCHED_START SCHED_END SCHED2_START SCHED2_END QUANTUM_BOUNDARY_START QUANTUM_BOUNDARY_END PLUGIN_SCHED_START PLUGIN_SCHED_END RELEASE_START RELEASE_END RELEASE_LATENCY > $FT_FILE_CPU_1 &
ft1_pid=$!

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


# Wait for completion
wait $v1_pid
echo video01 completed pid = $v1_pid
wait $v2_pid
echo video02 completed pid = $v2_pid
wait $v3_pid
echo video03 completed pid = $v3_pid
wait $v4_pid
echo video03 completed pid = $v4_pid


# Kill FeatherTrace Job
kill -TERM $ft0_pid
kill -TERM $ft1_pid
#kill -TERM $st_pid
wait

#Combine all FeatherTrace Results
cd $FT_DIR
cat $FT_FILE_CPU_0 $FT_FILE_CPU_1 > all_events_$DTG
./ft2csv CXS_START all_events_$DTG > CXS_START_$DTG.csv
./ft2csv CXS_END all_events_$DTG > CXS_END_$DTG.csv
./ft2csv SCHED_START all_events_$DTG > SCHED_START_$DTG.csv
./ft2csv SCHED_END all_events_$DTG > SCHED_END_$DTG.csv
./ft2csv SCHED2_START all_events_$DTG > SCHED2_START_$DTG.csv
./ft2csv SCHED2_END all_events_$DTG > SCHED2_END_$DTG.csv
./ft2csv QUANTUM_BOUNDARY_START all_events_$DTG > QUANTUM_BOUNDARY_START_$DTG.csv
./ft2csv QUANTUM_BOUNDARY_END all_events_$DTG > QUANTUM_BOUNDARY_END_$DTG.csv
./ft2csv PLUGIN_SCHED_START all_events_$DTG > PLUGIN_SCHED_START_$DTG.csv
./ft2csv PLUGIN_SCHED_END all_events_$DTG > PLUGIN_SCHED_END_$DTG.csv
./ft2csv RELEASE_START all_events_$DTG > RELEASE_START_$DTG.csv
./ft2csv RELEASE_END all_events_$DTG > RELEASE_END_$DTG.csv
./ft2csv RELEASE_LATENCY all_events_$DTG > RELEASE_LATENCY_$DTG.csv
echo 'FeatherTrace Results' >> all_events_post_$DTG 
echo -e 'Plug-in = $PLUGIN' >> all_events_post_$DTG 
echo -e 'Date = $DTG' >> all_events_post_$DTG 
echo -e '\nCXS_START' >> all_events_post_$DTG
cat CXS_START_$DTG.csv >> all_events_post_$DTG
echo -e '\nCXS_END' >> all_events_post_$DTG
cat CXS_END_$DTG.csv >> all_events_post_$DTG
echo -e '\nSCHED_START' >> all_events_post_$DTG
cat SCHED_START_$DTG.csv >> all_events_post_$DTG
echo -e '\nSCHED_END' >> all_events_post_$DTG
cat SCHED_END_$DTG.csv >> all_events_post_$DTG
echo -e '\nQUANTUM_BOUNDARY_START' >> all_events_post_$DTG
cat QUANTUM_BOUNDARY_START_$DTG.csv >> all_events_post_$DTG
echo -e '\nQUANTUM_BOUNDARY_END' >> all_events_post_$DTG
cat QUANTUM_BOUNDARY_END_$DTG.csv >> all_events_post_$DTG
echo -e '\nPLUGIN_START' >> all_events_post_$DTG
cat PLUGIN_SCHED_START_$DTG.csv >> all_events_post_$DTG
echo -e '\nPLUGIN_END' >> all_events_post_$DTG
cat PLUGIN_SCHED_END_$DTG.csv >> all_events_post_$DTG
echo -e '\nRELEASE_START' >> all_events_post_$DTG
cat RELEASE_START_$DTG.csv >> all_events_post_$DTG
echo -e '\nRELEASE_END' >> all_events_post_$DTG
cat RELEASE_END_$DTG.csv >> all_events_post_$DTG
echo -e '\nRELEASE_LATENCY' >> all_events_post_$DTG
cat RELEASE_LATENCY_$DTG.csv >> all_events_post_$DTG

# Create a Directory and Move the results there
NEW_FOLDER=$DTG"_"$PLUGIN

mkdir $NEW_FOLDER
mv all_events_post_$DTG $NEW_FOLDER
mv CXS_START_$DTG.csv $NEW_FOLDER
mv CXS_END_$DTG.csv $NEW_FOLDER
mv SCHED_START_$DTG.csv $NEW_FOLDER
mv SCHED_END_$DTG.csv $NEW_FOLDER
mv SCHED2_START_$DTG.csv $NEW_FOLDER
mv SCHED2_END_$DTG.csv $NEW_FOLDER
mv QUANTUM_BOUNDARY_START_$DTG.csv $NEW_FOLDER
mv QUANTUM_BOUNDARY_END_$DTG.csv $NEW_FOLDER
mv PLUGIN_SCHED_START_$DTG.csv $NEW_FOLDER
mv PLUGIN_SCHED_END_$DTG.csv $NEW_FOLDER
mv RELEASE_START_$DTG.csv $NEW_FOLDER
mv RELEASE_END_$DTG.csv $NEW_FOLDER
mv RELEASE_LATENCY_$DTG.csv $NEW_FOLDER

# Clean up
#rm all_events_$DTG
#rm $FT_FILE_CPU_0
#rm $FT_FILE_CPU_1

#exit
exit 0
