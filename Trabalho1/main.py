import numpy
import matplotlib.pyplot as plt

f = open("outputtimesKeepAlive.txt", "r")
keepAliveSizes = []
keepAliveTimes = []

line = f.readline()
while line :
    tokens = line.split(";")
    keepAliveSizes.append(int(tokens[0]))
    keepAliveTimes.append(float(tokens[1].rstrip()))

    line = f.readline()

f.close()

f = open("outputtimesClose.txt", "r")
closeSizes = []
closeTimes = []

line = f.readline()
while line:
    tokens = line.split(";")
    closeSizes.append(int(tokens[0]))
    closeTimes.append(float(tokens[1].rstrip()))

    line = f.readline()

f.close()

plt.plot(keepAliveSizes, keepAliveTimes, "ro", label="KeepAlive")
plt.plot(closeSizes, closeTimes, "bo", label="Close")
plt.xscale('log')
plt.yscale('log')
plt.title("Request times by number of requests")
plt.xlabel("Number of Requests")
plt.ylabel("Total Request Time in seconds")
plt.legend()
plt.show()

