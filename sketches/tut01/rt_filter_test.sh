#!/bin/bash

# Set Directory Variables
FT_DIR=/home/rts/litmus-rt/liblitmus/ft_tools
FILTER_DIR=/mnt/hgfs/debian_share/rts_project/litmusrt-vidfilters/sketches/tut01
ST_TOOLS_DIR=/home/rts/litmus-rt/sched-trace-tools-master
LIBLITMUS_DIR=/home/rts/litmus-rt/liblitmus

# Get Current Scheduler
PLUGIN=`eval $LIBLITMUS_DIR/showsched`
# Get Current Date Time Group
DTG=`eval date +%Y%m%d_%H_%M`
FT_FILE_CPU_0=trace_$DTG_cpu0
FT_FILE_CPU_1=trace_$DTG_cpu1

# Move to Feather Trace Directory
cd $FT_DIR
# Launch FT on each CPU
sudo ./ftcat /dev/litmus/ft_cpu_trace0 CXS_START CXS_END SCHED_START SCHED_END SCHED2_START SCHED2_END RELEASE_START RELEASE_END RELEASE_LATENCY > $FT_FILE_CPU_0 &
ft0_pid=$!
sudo ./ftcat /dev/litmus/ft_cpu_trace1 CXS_START CXS_END SCHED_START SCHED_END SCHED2_START SCHED2_END RELEASE_START RELEASE_END RELEASE_LATENCY > $FT_FILE_CPU_1 &
ft1_pid=$!

# Launch Sched Trace on each CPU

#sudo nohup ./st_trace &
#st_pid=$!
#echo st pid = $st_pid

# Move to Filter Directory
cd $FILTER_DIR

# Launch Tasks
sudo ./filter video01.mp4 video01.mkv &
v1_pid=$!
sudo ./filter video02.mp4 video02.mkv &
v2_pid=$!
sudo ./filter video03.mp4 video03.mkv &
v3_pid=$!

# Wait for completion
wait $v1_pid
echo video01 completed pid = $v1_pid
wait $v2_pid
echo video02 completed pid = $v2_pid
wait $v3_pid
echo video03 completed pid = $v3_pid

# Copy st_trace output to st-trace-tools
#cp st--0.bin $ST_TOOLS_DIR
#cp st--1.bin $ST_TOOLS_DIR

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
./ft2csv RELEASE_START all_events_$DTG > RELEASE_START_$DTG.csv
./ft2csv RELEASE_END all_events_$DTG > RELEASE_END_$DTG.csv
./ft2csv RELEASE_LATENCY all_events_$DTG > RELEASE_LATENCY_$DTG.csv
echo 'FeatherTrace Results' >> all_events_post_$DTG 
echo -e 'Plug-in = $PLUGIN' >> all_events_post_$DTG 
echo -e 'Date = $DTG' >> all_events_post_$DTG 
echo -e '\nCXS_START' >> all_events_post_$DTG
cat CXS_START_$DTG >> all_events_post_$DTG
echo -e '\nCXS_END' >> all_events_post_$DTG
cat CXS_END_$DTG >> all_events_post_$DTG
echo -e '\nSCHED_START' >> all_events_post_$DTG
cat SCHED_START_$DTG >> all_events_post_$DTG
echo -e '\nSCHED_END' >> all_events_post_$DTG
cat SCHED_END_$DTG >> all_events_post_$DTG
echo -e '\nRELEASE_START' >> all_events_post_$DTG
cat RELEASE_START_$DTG >> all_events_post_$DTG
echo -e '\nRELEASE_END' >> all_events_post_$DTG
cat RELEASE_END_$DTG >> all_events_post_$DTG
echo -e '\nRELEASE_LATENCY' >> all_events_post_$DTG
cat RELEASE_LATENCY_$DTG >> all_events_post_$DTG

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
mv RELEASE_START_$DTG.csv $NEW_FOLDER
mv RELEASE_END_$DTG.csv $NEW_FOLDER
mv RELEASE_LATENCY_$DTG.csv $NEW_FOLDER

# Clean up
rm all_events_$DTG
rm $FT_FILE_CPU_0
rm $FT_FILE_CPU_1

#exit
#cd $ST_TOOLS_DIR
exit 0