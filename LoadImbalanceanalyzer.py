import numpy as np

import ConfigConst


def getAVGFCTByFolder(filePath, algorithmName, loadfactor):
    deviceToNewPortUtilizationDataMap = {}
    deviceToOldPortUtilizationDataMap = {}
    print("\n\n\nAnalysis of load imbalance with algorithm "+algorithmName+" at loadfactor: ",loadfactor)
    try:
        f =open(filePath , 'r')
        lines = f.readlines()
        for line in lines:
            # all port statistics will start with this
            #"[06-08 11:32:01] p19196 {/home/deba/Desktop/CLB/P4Runtime/StatisticsPuller.py:96} INFO - CLB ALGORITHM: For switch device:p0l1new Utilization data is  [37, 37, 37, 37, 357, 331, 317, 329, 84, 1268, 92, 437, 0, 0, 0, 0, 0, 0, 0, 0, 105, 119, 131, 113, 0, 0, 0, 0, 0, 0, 0, 0]
            prefix = "INFO - "+ str(algorithmName)+" ALGORITHM: For switch device"
            prefixLength = len(prefix)
            indexOfAlgoPrefixEnd = line.find(prefix)
            if(indexOfAlgoPrefixEnd >0 ):
                indexOfAlgoPrefixEnd = indexOfAlgoPrefixEnd+ prefixLength
            else:
                continue
            indexOfForSwitchDevicePrefixEnd = line.find("For switch device:") + len("For switch device:")
            newUtilPrefix = "new Utilization data is  "
            oldUtilPrefix = "old Utilization data is  "
            newUtilDataPrefixIndex = line.find(newUtilPrefix)
            oldUtilDataPrefixIndex = line.find(newUtilPrefix)
            if (newUtilDataPrefixIndex >0):
                deviceName = line[indexOfForSwitchDevicePrefixEnd:newUtilDataPrefixIndex]
                newUtilDataEndIndex = newUtilDataPrefixIndex + len(newUtilPrefix)
                newUtilDataAsString = line[newUtilDataEndIndex+1: line.rindex("]")]
                intList = [int(s) for s in newUtilDataAsString.split(',')]
                # print(deviceName+"--"+str(intList))
                deviceToNewPortUtilizationDataMap[deviceName] = intList
            if (oldUtilDataPrefixIndex >0):
                deviceName = line[indexOfForSwitchDevicePrefixEnd:oldUtilDataPrefixIndex]
                oldUtilDataEndIndex = oldUtilDataPrefixIndex + len(oldUtilPrefix)
                oldUtilDataAsString = line[oldUtilDataEndIndex+1: line.rindex("]")]
                intList = [int(s) for s in oldUtilDataAsString.split(',')]
                # print("old"+deviceName+"--"+str(intList))
                deviceToOldPortUtilizationDataMap[deviceName] = intList

        # print(len(deviceToNewPortUtilizationDataMap))
        #We will only consider the leaf switch's  switch-to-switch links load
        switchToImbalanceCDFMap = {}
        for switch in deviceToNewPortUtilizationDataMap:
            if switch.find("l") > -1: # this means leaf switch
                print("Switch name "+switch)
                portToLoadMap = {}
                utilData = deviceToNewPortUtilizationDataMap.get(switch)
                # print(utilData)

                for i in range (0,ConfigConst.MAX_TOR_SUBNET):
                    for j in range(int(ConfigConst.MAX_PORTS_IN_SWITCH/2), ConfigConst.MAX_PORTS_IN_SWITCH): # Only later half ports of a switch is connected to spines
                        port = i * ConfigConst.MAX_PORTS_IN_SWITCH + j
                        util = utilData[port]
                        if(portToLoadMap.get(j+1) ==None):
                            portToLoadMap[j+1] = util
                        else:
                            portToLoadMap[j+1] = portToLoadMap.get(j+1) + util
                # print(portToLoadMap)
                portLoadAsList = list(portToLoadMap.values())
                min = np.min(portLoadAsList)
                totalImbalance = 0

                for i in range(len(portLoadAsList)):
                    portLoadAsList[i] = portLoadAsList[i] - min
                    totalImbalance = totalImbalance + portLoadAsList[i]
                packetcountVsImbalanceCDF = {}
                portImbalanceCDF = 0
                portLoadAsList = np.sort(portLoadAsList) # Sorting to put in cdf graph
                # print(np.sort(portLoadAsList))
                # print(totalImbalance)
                for i in range(len(portLoadAsList)):
                    portImbalanceCDF = portImbalanceCDF + (portLoadAsList[i]/totalImbalance)
                    packetcountVsImbalanceCDF[portLoadAsList[i]] = portImbalanceCDF
                print(packetcountVsImbalanceCDF)
                # for k in packetcountVsImbalanceCDF.keys():
                #     print("",k,", ",packetcountVsImbalanceCDF.get(k))
                switchToImbalanceCDFMap[switch] = packetcountVsImbalanceCDF
        print(switchToImbalanceCDFMap)

    except Exception as e:
        print("Exception occcured in processing load imbalance analyzer from file "+filePath+ ". Exception is ",e.with_traceback())


getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/STATISTICS_load_factor_0.8.log", "ECMP", 0.8)
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/STATISTICS_load_factor_0.8.log", "HULA", 0.8)
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/STATISTICS_load_factor_0.8.log", "CLB", 0.8)