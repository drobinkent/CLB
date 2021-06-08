import glob
from os import listdir
from os.path import isfile, join

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
            print("Exception occcured in processing results from folder "+folderName+ ". Excemtion is "+str(e))
    for f in flowTypeVsFCTMap:
        print(str(f) + " -- ",flowTypeVsFCTMap.get(f))
        print(str(f) + " -- ",flowTypeVsFlowCountMap.get(f))
        print(str(f) + " -- ",flowTypeVsFCTMap.get(f)/flowTypeVsFlowCountMap.get(f))
    pass

getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.8")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.8")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/WebSearchWorkLoad_load_factor_0.8")
print("\n\n")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.4")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.4")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/ECMP_RESULTS/WebSearchWorkLoad_load_factor_0.4")
print("\n\n")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/HULA_RESULTS/WebSearchWorkLoad_load_factor_0.2")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/CLB_RESULTS/WebSearchWorkLoad_load_factor_0.2")
getAVGFCTByFolder("/home/deba/Desktop/CLB/testAndMeasurement/TEST_RESULTS/WebSearchWorkLoad_load_factor_0.2")
