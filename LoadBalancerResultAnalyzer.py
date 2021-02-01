import math

import ConfigConst as CC
from testAndMeasurement.ResultParsers import ConfigLoader
import  testAndMeasurement.ResultProcessor as resProc




def upwardLinkUtilizationVisualizerProcessor(folderPath="/home/deba/Desktop/CLB/result/",deviceName="p0l0"):

    controllerStatistics = resProc.controllerSidePortStatisticsProcessor(folderPath+deviceName+".json")
    # s= rp.SwitchPortStatistics()
    portVsCounterValueListMap = {}


    for stats in controllerStatistics:
        for portId in stats.port_stats.upward_port_egress_packet_counter.keys():   # this is a port vs counter map
            if(portVsCounterValueListMap.get(portId) == None) :
                portVsCounterValueListMap[portId] = []
                portVsCounterValueListMap[portId].append(stats.port_stats.upward_port_egress_packet_counter[portId])
            else:
                portVsCounterValueListMap[portId].append(stats.port_stats.upward_port_egress_packet_counter[portId])
    for e in portVsCounterValueListMap.keys():
        print("Values for port "+str(e)+ "are follwoing ")
        print(portVsCounterValueListMap.get(e))

    processedPortVsCounterValueListMap = {}
    listLengths=[]
    for portId in portVsCounterValueListMap.keys():   # this is a port vs counter map
        if(processedPortVsCounterValueListMap.get(portId) == None) :
            processedPortVsCounterValueListMap[portId] = []
        listLengths.append(len(portVsCounterValueListMap.get(portId)))

    min = 99999999999
    for i in range(0, len(listLengths)):
        if listLengths[i]<=min:
            min = listLengths[i]


    for i in range(1, min):  #len(portVsCounterValueListMap.get(portId))
        iThValueList = []
        for portId in portVsCounterValueListMap.keys():
            iThValueList.append(abs(portVsCounterValueListMap[portId][i] - portVsCounterValueListMap[portId][i-1]))
        minValue = 9999999
        for j in range(0, len(iThValueList)):
            if iThValueList[j]<=minValue:
                minValue = iThValueList[j]
        for portId in portVsCounterValueListMap.keys():
            if minValue ==0:
                processedPortVsCounterValueListMap[portId].append(0)
            else:
                processedPortVsCounterValueListMap[portId].append((portVsCounterValueListMap[portId][i] - portVsCounterValueListMap[portId][i-1])/minValue)
    for e in processedPortVsCounterValueListMap.keys():
        print("Values for port "+str(e)+ "are follwoing ")
        print(processedPortVsCounterValueListMap.get(e))





def processResults( topologyConfigFile=CC.TOPOLOGY_CONFIG_FILE):
    #testFunction()
    # Generate axis. then pass file and axes to the function
    config = ConfigLoader(topologyConfigFile)
    totalNumOfSwitches = len(config.nameToSwitchMap)
    switch = config.nameToSwitchMap.get(CC.CLB_TESTER_DEVICE_NAME)
    upwardLinkUtilizationVisualizerProcessor()

processResults()
