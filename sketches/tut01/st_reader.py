#!/usr/bin/python
import csv
import numpy as np
import matplotlib.pyplot as plt

st_vals = []
with open('stjobs.csv', 'rb') as f:
	reader = csv.reader(f)
	for row in reader:
		st_vals.append(row)

numSamples = len(st_vals) - 2
respTimes=[]
missedDL=0
for time in range(2, len(st_vals)):
	respTimes.append(float(st_vals[time][3])/1000)
	if (st_vals[time][4] == 1):
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
title = "Histogram of Response Times"
subtitle = ("min={:.2f}us max={:.2f}us avg={:.2f}us median={:.2f}us stdev={:.2f}us".format(minTime, maxTime, meanTime, medTime, stdev))
plt.figtext(.5,.95, title, fontsize=16, ha='center')
plt.figtext(.5,.91,subtitle,fontsize=10,ha='center')
plt.xlabel('Response Time in us (bin size = 100 us)')
plt.ylabel('Number of Samples')
plt.hist(respTimes, bins=np.arange(min(respTimes), max(respTimes) + 100, 100))
plt.show()

