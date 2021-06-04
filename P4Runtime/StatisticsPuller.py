import logging
import threading
import time
import os
import subprocess
import InternalConfig
import P4Runtime.shell as sh
from P4Runtime.context import Context
from P4Runtime.p4runtime import P4RuntimeClient, P4RuntimeException, parse_p4runtime_error
import P4Runtime.leafSwitchUtils as leafUtils
import P4Runtime.spineSwitchUtils as spineUtils
import P4Runtime.superSpineSwitchUtils as superSpineUtils
import P4Runtime.SwitchUtils as swUtils
import ConfigConst as ConfConst
import P4Runtime.JsonParser as jp
import P4Runtime.PortStatistics as ps
import P4Runtime.packetUtils as pktUtil
import P4Runtime.StatisticsJsonWrapper as statJsonWrapper
import matplotlib.pyplot as plot
import numpy as np
import math
import json

import logging.handlers

logger = logging.getLogger('StatisticsPuller')
logger.handlers = []
hdlr = logging.handlers.RotatingFileHandler(ConfConst.CONTROLLER_LOG_FILE_PATH, maxBytes = ConfConst.MAX_LOG_FILE_SIZE , backupCount= ConfConst.MAX_LOG_FILE_BACKUP_COUNT)
hdlr.setLevel(logging.INFO)
formatter = logging.Formatter('[%(asctime)s] p%(process)s {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s','%m-%d %H:%M:%S')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logging.StreamHandler(stream=None)
logger.setLevel(logging.INFO)


class StatisticsPuller:
    '''
    This class contains all the code for pulling various statistics from switch. Mainly using register and counter
    '''


    def __init__(self, nameToSwitchMap, devName):
        self.isRunning = True
        self.nameToSwitchMap = nameToSwitchMap
        self.p4dev  = self.nameToSwitchMap.get(devName)
        f =  open(ConfConst.CONTROLLER_STATISTICS_RESULT_FILE_PATH+self.p4dev .devName+".json", mode='a', buffering=1024)
        self.nameToSwitchMap.get(devName).controllerStatsFile = f
        x = threading.Thread(target=self.thread_function, args=())
        self.statisticPullerthread = x
        logger.info("Stiatisticspuller thread for device: "+str(self.p4dev.devName)+" is being started")
        x.start()
        logger.info("Stiatisticspuller thread for device: "+str(self.p4dev .devName)+" has started")





    def thread_function(self):
        # logger.info("Sta: starting", "StatisticsPuller",str(self.p4dev.devName))
        # totalNumOfSwitches = len(self.nameToSwitchMap)
        # squareRootOftotalNumOfSwitches = math.sqrt(totalNumOfSwitches)
        # nRow = math.ceil(squareRootOftotalNumOfSwitches)
        # nColumn = math.ceil(totalNumOfSwitches/nRow)
        # fig, axes = plot.subplots(nrows=nRow, ncols=nColumn, sharex=True, sharey=True)
        # for dev in self.nameToSwitchMap:
        #     f =  open(ConfConst.CONTROLLER_STATISTICS_RESULT_FILE_PATH+dev+".json", mode='a', buffering=1024)
        #     self.nameToSwitchMap.get(dev).controllerStatsFile = f
        while(self.isRunning):
            time.sleep(ConfConst.STATISTICS_PULLING_INTERVAL)
            index=0
            switchObject = self.p4dev
            linkUtilStats = self.pullStatsFromSwitch(dev=switchObject)
            self.useLinkUtilForPathReconfigure(linkUtilStats)
            # switchObject.controllerStatsFile.write(json.dumps(statJson, cls=statJsonWrapper.PortStatisticsJSONWrapper))
            # switchObject.controllerStatsFile.flush()
        logger.info("Thread %s: finishing", "StatisticsPuller", str(self.p4dev.devName))

    def useLinkUtilForPathReconfigure(self, linkUtilStats):
        if (self.p4dev.dpAlgorithm == ConfConst.DataplnaeAlgorithm.DP_ALGO_BASIC_ECMP) : # do nothing
            return
        if ((self.p4dev.dpAlgorithm == ConfConst.DataplnaeAlgorithm.DP_ALGO_BASIC_HULA) and (self.p4dev.fabric_device_config.switch_type == jp.SwitchType.LEAF)):
            self.p4dev.hulaUtilBasedReconfigureForLeafSwitches(linkUtilStats)
            pass # dohuyla logic
        if ((self.p4dev.dpAlgorithm == ConfConst.DataplnaeAlgorithm.DP_ALGO_BASIC_CLB)  and (self.p4dev.fabric_device_config.switch_type == jp.SwitchType.LEAF)):
            pass # do CLB logic
        pass

    # make hula table
    # configure it at intitl setup
    #
    # use that table to reconfigure depending on link util.

    def indexToRowColumn(self, index, totalColumns):
        row = int(math.floor(index/float(totalColumns)))
        column = index % totalColumns
        return row, column  # TODO we may need to subtract 1 t match the index number(as index starts from zero)

    def pullStatsFromSwitch(self, dev):
        # this method will pull various counter and register values from the switches and plot data accordingly.
        # Also save the collected statistics for each device in corresponding data structure.

        #logger.info("Pulling record from device:"+ str(dev.devName))
        # recordPullingtime = time.time()
        # egressPortStats, ingressPortStats , ctrlPkttoCPStats,  p2pFeedbackStats, lbMissedPackets = swUtils.readAllCounters(dev)
        # # logger.info(egressPortStats)
        # # logger.info(ingressPortStats)
        # # logger.info(ctrlPkttoCPStats)
        # # logger.info(p2pFeedbackStats)
        # # Store records
        # #In port to leaf.spine, super spine map, we can find which port maps to what kind of connected devices. From there we can find relevan ports. And we will
        # #create a obejct for statistics. And we will keep all the info there.
        #
        # portStatistics = ps.PortStatistics()
        #
        # #s = Device()
        # # Keeep data separate data structure for statistics on upward and downward ports
        # # pull records. TODO Instead of pulling record for all the ports, we can pull record for host, leaf or spine switches and collect infos here. And also0 save them
        # # We are already doing the filtering.  So we can actually skip the earlier part  of recording all stats and only call the readcounter function in the
        # #below if-else part
        # #print("If we want to collect the link utilization rate, simple pop the last portStatistics form the que , get diff from current value. let's assume the ")
        # # print("is delta. now if the stats collection interval is t sec. and dev.PortToQueueRateMap.get(port) (this gives the processing rate of the port")
        # # print("(delta)/ (t* p[rocessing rate) is the real link utilizatin rate ")
        # # try:
        # #     lastStats = dev.portStatisticsCollection[-1]
        # #     if(lastStats ==None):
        # #         lastStats = ps.PortStatistics()
        # # except Exception as e:
        # #     lastStats = ps.PortStatistics()
        #
        # # if(dev.devName == "device:p0l0"):
        # #     print("Gotcha")
        # # tempPortStats = ps.PortStatistics()
        # if (dev.fabric_device_config.switch_type == jp.SwitchType.LEAF ):
        #     for sPort in dev.portToSpineSwitchMap:
        #         egressPortCounterValueForSpine =egressPortStats.get(sPort)
        #         portStatistics.setUpwardPortEgressPacketCounter(sPort,egressPortCounterValueForSpine)
        # portStatistics.setLBMissedPackets(lbMissedPackets)
        #
        # statJson = statJsonWrapper.PortStatisticsJSONWrapper()
        # statJson.setData(recordPullingtime,portStatistics, dev.devName)
        # # logger.info("Stat is "+ json.dumps(statJson,cls=statJsonWrapper.PortStatisticsJSONWrapper))
        # # logging.info("Inserted Port Statistics to device history record")
        # return statJson
        # logger.info("Reading LinkUtil for switch "+ (str(dev.devName)))
        val = swUtils.collectDestinationBasedLinkeUtilization(dev, "destination_util_counter")
        # logger.info(val)
        return val




