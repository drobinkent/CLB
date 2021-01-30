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





def processResults( topologyConfigFile=CC.TOPOLOGY_CONFIG_FILE):
    #testFunction()
    # Generate axis. then pass file and axes to the function
    config = ConfigLoader(topologyConfigFile)
    totalNumOfSwitches = len(config.nameToSwitchMap)
    switch = config.nameToSwitchMap.get(CC.CLB_TESTER_DEVICE_NAME)
    upwardLinkUtilizationVisualizerProcessor()

processResults()
