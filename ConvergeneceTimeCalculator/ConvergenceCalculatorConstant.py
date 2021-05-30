import zlib
from netaddr import IPNetwork
import crc16
TOTAL_TOR_SWITCHES=10000 # we want to


experimantTableSize=8192
experimentPrecision=4
experimentTotalPaths=8
experimentIteration = 10
experimentHashTableSize = 524288
experimentDestinationNumbers=10240
experimentIPv6Prefix = "192:0:0:1::/64"
# Assuem a leaf spine topologu where each leaf switch has N upword ports. Hence between each pair of leaf switch
# there will be at least N distinct paths (totaly edge disjoint paths between a pair a leaf siwthc can be much more larger ).
# Now, for each of the destination
#
#
#
#
#     flow tuple to hash --> then destination IP as match field and hashcode as action. these actions will be must filled upto there limit.
#
# look at figure 3 of dash paper. that's how  the wcmp will work. add a picture of it in our paper.
#
# Now in our simulation the wcmp table size is a limiting factor.
# Assume for a single destination total upward ports availalbe is P. and we can assign traffic on these
#     P ports according to some distribution. then we will convert this distribution to feasible path-weight distribution.
# at time t0 , we have to keep record how many weight is assigned on a path. assume it is w0
# at time t1 if the weight assigned on this path is w1. then we have to modify w1-w0 entries.
#
# Now assume we have a table size T. with increase in T the number should obviously change.
#
#
# How to convert to a feasible distribution. Assume we have table sizze T and precision = K .
# Then simple asuem table size as T/K. then generate the values according to some distribution in the range 1 to T/K. then simply multiple by K each value.
# and we are done.

# sum of the values have to be C/K. and each value have to be in range 0 to C/K. -- to accomodate K precision. so that after generation each alue will be multiplied by K.
# we need total tableSize number of entries.
#
#
# def wcmp(tableSize, totalPath, precision, C ):
#     we have to fit total range of C using totalPath number of data with each one multiple of K.
#     so we can say sum will be C/K (to handle precision) and total entry will be totalPath.
#
#     now generate totalpath number of data with their sum = tablesize/k.
#
#     http://sunny.today/generate-random-integers-with-fixed-sum/
#
#     import random
# random.sample(range(low, high), n)
#
# to put the probability in range 0-1. we need to try another case where instead of simply random sample the probabillity ofthe numbers will be drawn from
#     some other distribution
import numpy as np

# def generateWCMPWeights(C, tableSize, precision, totalPaths):
#     mean = C / (tableSize * totalPaths)
#     variance = int(0.85 * mean)
#
#     # min_v = variance
#     # max_v = int(C/(precision*totalPaths))
#     min_v = int(mean - variance)
#     max_v = int(mean + variance)
#     array = [min_v] * (totalPaths)
#
#     diff = int(C/(totalPaths)) - min_v * tableSize
#     while diff > 0:
#         a = np.random.randint(0, tableSize - 1)
#         if array[a] > max_v:
#             continue
#         array[a] = int(array[a]) + 1
#         diff -= 1
#     print (array)

def getTotalControlMessageForUpdatingWCMPTable(oldPathWeightDistribution, newPathWeightDistribution):
    if (len(oldPathWeightDistribution) != len(newPathWeightDistribution)):
        print("Error: Elngth of 2 path-weight distribution must have to be equal.. Exiting")
        exit(1)
    totalOldEntryDeleteRequiredInWCMPTable = 0
    totalNewEntryInsertRequiredInWCMPTable = 0

    for i in range (0, len(oldPathWeightDistribution)):
        oldWeightOfThePAth = int(oldPathWeightDistribution[i])
        newWeightOfThePath = int(newPathWeightDistribution[i])
        if (oldWeightOfThePAth == newWeightOfThePath):
            print("Old and new weight of the path is same. Hence no entry is required to be deleted or entered in the WCMP Table")
        else:
            if(oldWeightOfThePAth > newWeightOfThePath):
                print("Old weight of the path is ", str(oldWeightOfThePAth)+ " and new weight of the path is ", str(newWeightOfThePath))
                print(str(oldWeightOfThePAth-newWeightOfThePath)+ " entries have to be deleted for the path ")
                totalOldEntryDeleteRequiredInWCMPTable = oldWeightOfThePAth-newWeightOfThePath
            else:
                print("Old weight of the path is ", str(oldWeightOfThePAth)+ " and new weight of the path is ", str(newWeightOfThePath))
                print(str(newWeightOfThePath-oldWeightOfThePAth)+ " entries have to be inserted for the path ")
                totalNewEntryInsertRequiredInWCMPTable = newWeightOfThePath-oldWeightOfThePAth
    print("Total update (both insert and delete) required for the iteration is "+str(totalOldEntryDeleteRequiredInWCMPTable+totalNewEntryInsertRequiredInWCMPTable))
    return totalOldEntryDeleteRequiredInWCMPTable+totalNewEntryInsertRequiredInWCMPTable

def generatePathWeights(tableSize, precision, totalPaths, iteration):
    # mean = C / (tableSize * totalPaths)
    _sum = tableSize / precision
    n = totalPaths

    rnd_array = np.random.multinomial(_sum, np.ones(n)/n, size=iteration)
    rnd_array = rnd_array*precision
    print(rnd_array)
    # print("Sum is ", np.sum(rnd_array))
    print(list(rnd_array))
    return  rnd_array




def wcmpUpdateCalculation():
    pathWeights = list(generatePathWeights(tableSize=experimantTableSize, precision=experimentPrecision, totalPaths=experimentTotalPaths, iteration = experimentIteration))
    oldPathWeightDistribution  = np.zeros(shape = experimentTotalPaths,dtype="int")
    print(oldPathWeightDistribution)
    newPathWeightDistribution =  pathWeights[0]
    total = 0
    for i in range (0, experimentIteration-1):
        total = total + (getTotalControlMessageForUpdatingWCMPTable(oldPathWeightDistribution, newPathWeightDistribution))
        oldPathWeightDistribution = pathWeights[i]
        newPathWeightDistribution =  pathWeights[i+1]
        print("Total is "+str(total))


class CrcHashTable:
    def __init__(self, tableSize):
        self.table = []
        self.tableSize = tableSize
        for i in range (0, self.tableSize):
            self.table.append(-1)

    def insert(self, ipaddress, port):
        self.collisionNumer = 0
        bytesFromIP = bytes(ipaddress)
        bytesFromPort = bytes(port)
        bytesData = bytesFromIP + bytesFromPort
        hashCode = crc16.crc16xmodem(bytesData)
        if(self.table[hashCode] != -1):
            self.collisionNumer = self.collisionNumer+1
        else:
            self.table[hashCode] = port


# for ip in IPNetwork('10:0:1::/64'):
#     print ('%s' % ip)
#     print(zlib.crc32(bytes(ip)))


# generate specific number of ip address. for each one of them calculate a distribution.
#     according to that distribution get what is the weightlevel of the ports.
# then for all of the ip-port combination calculate hashtable collision


def calculateHashCollision():
    ipaddressList = []
    i = 0
    hTable =CrcHashTable(experimentHashTableSize)
    for ip in IPNetwork(experimentIPv6Prefix):
        print ('%s' % ip)
        print(zlib.crc32(bytes(ip)))
        ipaddressList.append(ip)
        i =i+1
        if (i>=experimentDestinationNumbers):
            break
    for ip in ipaddressList:
        pathWeights = list(generatePathWeights(tableSize=experimantTableSize, precision=experimentPrecision, totalPaths=experimentTotalPaths, iteration = 1))
        for pWeight in pathWeights[0]:
            hTable.insert(ip,pWeight*experimentPrecision)
    print("Toal Collision is "+str(hTable.collisionNumer))


calculateHashCollision()
