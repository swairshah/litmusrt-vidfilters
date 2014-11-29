#!/usr/bin/python
import csv
import numpy as np
import matplotlib.pyplot as plt
import sys

st_vals = []

if len(sys.argv) < 2:
	INPUT_FILE = "st_jobs_out.csv"
else:
	INPUT_FILE = sys.argv[1]

with open(INPUT_FILE, 'rb') as f:
	reader = csv.reader(f)
	for row in reader:
		st_vals.append(row)

numSamples = len(st_vals) - 2
respTimes=[]
missedDL=0
print("First Deadline = {}".format(st_vals[4][4]))
for time in range(2, len(st_vals)):
	if ((st_vals[time][0][0] != "#") and (int(st_vals[time][1]) > 2)):
		respTimes.append(float(st_vals[time][3])/1000)
		if (int(st_vals[time][4]) == 1):
			missedDL += 1

meanTime = np.mean(respTimes)
maxTime = max(respTimes)
minTime = min(respTimes)
medTime = np.median(respTimes)
stdev = np.std(respTimes)

print("Maximum Response Time = {}".format(maxTime))
print("Minimum Response Time = {}".format(minTime))
print("Average Response Time = {}".format(meanTime))
print("Median Response Time = {}".format(medTime))
print("Missed Deadlines = {}".format(missedDL))

# Plot a Histogram of Response Times
plt.figure(figsize=(10,6))
title = "Histogram of Response Times"
subtitle = ("min={:.2f}us max={:.2f}us avg={:.2f}us median={:.2f}us stdev={:.2f}us".format(minTime, maxTime, meanTime, medTime, stdev))
plt.figtext(.5,.95, title, fontsize=16, ha='center')
plt.figtext(.5,.91, subtitle, fontsize=10,ha='center')
plt.figtext(.85,.85, "Number of Samples = {}".format(numSamples), fontsize=8, ha='right')
plt.figtext(.85,.80, "Missed Deadlines = {}".format(missedDL), fontsize=8, ha='right')
plt.xlabel('Response Time in us (bin size = 100 us)')
plt.ylabel('Number of Samples')
plt.hist(respTimes, bins=np.arange(min(respTimes), max(respTimes) + 100, 100))
#plt.hist(respTimes, bins=1000)
plt.show()
