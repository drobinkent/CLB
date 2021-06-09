import glob
from os import listdir
from os.path import isfile, join

import numpy as np

import ConfigConst


def getAllFilesInDirectory(folderPath):

    # r=root, d=directories, f = files
    onlyfiles = [f for f in listdir(folderPath) if (isfile(join(folderPath, f)))]
    print("Total files in this directory is ", len(onlyfiles))
    return onlyfiles

def getAVGFCTByFolder(folderName):
    files = getAllFilesInDirectory(folderName)
    flowTypeVsFCTMap = {}
    flowTypeVsFlowCountMap = {}
    for flowVolume in ConfigConst.FLOW_TYPE_IDENTIFIER_BY_FLOW_VOLUME_IN_KB:
        flowTypeVsFCTMap[flowVolume]  = 0
        flowTypeVsFlowCountMap[flowVolume] = 0

    for f in files:
        filePath = folderName+"/"+str(f)
        try:
            f =open(filePath , 'r')
            line = f.readline()
            #(sender[0]+'\t'+str(sender[1])+'\t'+receiver[0]+'\t'+str(flow_size)+'\t'+str(start)+'\t'+str(end)+'\t'+str(fct)+'\t'+str(bw))
            #2001:1:1:1::	35466	2001:1:1:1::1:1	51200.0	2021-06-07 21:35:09.471579	2021-06-07 21:35:49.964961	40.493382	0.010115233150938097
            tokens = line.split()
            flowSize = float(tokens[3])
            fct = float(tokens[8])
            for flowVolume in ConfigConst.FLOW_TYPE_IDENTIFIER_BY_FLOW_VOLUME_IN_KB:
                if abs(flowVolume*1024 - flowSize) <= (.1*flowVolume*1024):
                    flowTypeVsFCTMap[flowVolume] = flowTypeVsFCTMap.get(flowVolume) + fct
                    flowTypeVsFlowCountMap[flowVolume] = flowTypeVsFlowCountMap.get(flowVolume) + 1
        except Exception as e:
            print("Exception occcured in processing results from folder "+folderName+ ". Excemtion is "+(e.with_traceback()))
    for f in flowTypeVsFCTMap:
        print(str(f) + " -- ",flowTypeVsFCTMap.get(f))
        print(str(f) + " -- ",flowTypeVsFlowCountMap.get(f))
        print(str(f) + " -- ",flowTypeVsFCTMap.get(f)/flowTypeVsFlowCountMap.get(f))
    pass

def getPercentileFCTByFolder(folderName):
    files = getAllFilesInDirectory(folderName)
    flowTypeVsFCTMap = {}
    flowTypeVsFlowCountMap = {}
    for flowVolume in ConfigConst.FLOW_TYPE_IDENTIFIER_BY_FLOW_VOLUME_IN_KB:
        flowTypeVsFCTMap[flowVolume]  = []
        flowTypeVsFlowCountMap[flowVolume] = 0

    for f in files:
        filePath = folderName+"/"+str(f)
        try:
            f =open(filePath , 'r')
            line = f.readline()
            #(sender[0]+'\t'+str(sender[1])+'\t'+receiver[0]+'\t'+str(flow_size)+'\t'+str(start)+'\t'+str(end)+'\t'+str(fct)+'\t'+str(bw))
            #2001:1:1:1::	35466	2001:1:1:1::1:1	51200.0	2021-06-07 21:35:09.471579	2021-06-07 21:35:49.964961	40.493382	0.010115233150938097
            tokens = line.split()
            flowSize = float(tokens[3])
            fct = float(tokens[8])
            for flowVolume in ConfigConst.FLOW_TYPE_IDENTIFIER_BY_FLOW_VOLUME_IN_KB:
                if abs(flowVolume*1024 - flowSize) <= (.1*flowVolume*1024):
                    flowTypeVsFCTMap.get(flowVolume).append(fct)
                    # flowTypeVsFCTMap[flowVolume] = flowTypeVsFCTMap.get(flowVolume).append(fct)
                    flowTypeVsFlowCountMap[flowVolume] = flowTypeVsFlowCountMap.get(flowVolume) + 1
        except Exception as e:
            print("Exception occcured in processing results from folder "+folderName+ ". Excemtion is ",str(e))
    totalFlowsize = 0
    totalOfFlowSizeMultipliedByAvgFct=0
    for f in flowTypeVsFCTMap:
        # print(str(f) + " -- ",np.percentile(flowTypeVsFCTMap.get(f), 80))
        print(str(f) + " -- ",flowTypeVsFlowCountMap.get(f))
        # print(str(f) + " -- ",flowTypeVsFCTMap.get(f)/flowTypeVsFlowCountMap.get(f))
        print(str(f) + " -- ",np.average(flowTypeVsFCTMap.get(f)))
        totalFlowsize= totalFlowsize+ float(f)
        totalOfFlowSizeMultipliedByAvgFct = totalOfFlowSizeMultipliedByAvgFct + ( float(f) * np.average(flowTypeVsFCTMap.get(f)))
    print("Average FCT = ", totalOfFlowSizeMultipliedByAvgFct/totalFlowsize)

    pass

# getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.8")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.8")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.8")
print("\n\n")
# # getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.7")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.7")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.7")
print("\n\n")
# # getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.5")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.5")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.5")
print("\n\n")
# getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.4")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.4")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.4")
print("\n\n")
# getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.2")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.2")
getPercentileFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.2")
