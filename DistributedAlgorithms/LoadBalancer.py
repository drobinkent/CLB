import json
import logging
import threading
import time

import ConfigConst as ConfConst
logger = logging.getLogger('LoadBalancer')
logger.handlers = []
hdlr = logging.handlers.RotatingFileHandler(ConfConst.CONTROLLER_LOG_FILE_PATH, maxBytes = ConfConst.MAX_LOG_FILE_SIZE , backupCount= ConfConst.MAX_LOG_FILE_BACKUP_COUNT)
hdlr.setLevel(logging.INFO)
formatter = logging.Formatter('[%(asctime)s] p%(process)s {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s','%m-%d %H:%M:%S')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logging.StreamHandler(stream=None)
logger.setLevel(logging.INFO)
def modifyBit( n,  p,  b):
    '''
    # Python3 program to modify a bit at position
# p in n to b.

# Returns modified n.
    :param n:
    :param p:
    :param b:
    :return:
    '''
    mask = 1 << p
    return (n & ~mask) | ((b << p) & mask)

class LoadBalanacer:

    def __init__(self,  allLinksAsList, totalLevels, bitMaskLength):
        self.linkToCurrentLevel={}
        self.totalLevels = totalLevels
        self.bitMaskLength = bitMaskLength
        self.bitMaskArray = []
        for l in allLinksAsList:
            self.linkToCurrentLevel[l] = 0
        for i in range(0,int(self.totalLevels/self.bitMaskLength)):
            #Initializing all the bit masks with 0
            self.bitMaskArray[i] = 0
        x = threading.Thread(target=self.load_balancer_config_thread_function, args=())
        x.start()
        logger.info("load_balancer_config_thread_function thread started")


    def load_balancer_config_thread_function(self):
        logger.info("Thread %s: starting", "load_balancer_config_thread_function")
        while(self.isRunning):
            accumulatedDistribution = self.getAccumulatedDistribution(ConfConst.LOAD_DISTRIBUTION_1)
            print("Old distrib was "+str(json.dumps(ConfConst.LOAD_DISTRIBUTION_1)))
            print("accumulated distrib is "+str(json.dumps(accumulatedDistribution)))
            hostObject = self.nameToSwitchMap.get(ConfConst.CLB_TESTER_DEVICE_NAME)
            time.sleep(1000000)
        pass


    def buildRawPacket(self, clabFlag, bitmaskArrayIndex, bitmaskPosition, linkID, bitmask, level_to_link_id_store_index ):
        '''
        port_num_t  egress_port;
        bit<7>      _pad;
        //Previous all fields are not necessary for CLB. TODO  at sometime we will trey to clean up them. But at this moment we are not focusing on that
        bit<8> clb_flags; //Here we will keep various falgs for CLB //--------bit-7--------|| If this bit is set then reet the counter//--------bit-6--------|| If this bit is set then this is a port delete packet
        bit<32> bitmask_array_index;  //
        bit<32> bitmask_position;
        bit<32> link_id;
        bit<32> bitmask; //Here we are keeping all 32 bit to avoid compile time configuration complexity. At apply blo0ck we will slice necesssary bits.
        bit<32> level_to_link_id_store_index;  //
        :return:
        '''
        rawPktContent = (255).to_bytes(2,'big') # first 2 byte egressport and padding
        rawPktContent = rawPktContent + (clabFlag).to_bytes(1,'big')
        rawPktContent = rawPktContent + (bitmaskArrayIndex).to_bytes(4,'big')
        rawPktContent = rawPktContent + (bitmaskPosition).to_bytes(4,'big')
        rawPktContent = rawPktContent + (linkID).to_bytes(4,'big')
        rawPktContent = rawPktContent + (bitmask).to_bytes(4,'big')
        rawPktContent = rawPktContent + (level_to_link_id_store_index).to_bytes(4,'big')
        return rawPktContent

    def installDistributionInCPAndGeneratePacketOutMessages(self, weightDistribution):
        '''
        This function process the whole distribution and generates all the pcaket_out messages to be sent to DP
        and store them in a list. And return the list
        :param weightDistribution:
        :return:
        '''
        packetOutList = []
        for e in weightDistribution:
            link = e[0]
            oldLevel = self.linkToCurrentLevel.get(link)
            index = int(oldLevel / self.bitMaskLength)
            position = oldLevel % self.bitMaskLength
            #modify the bitmask
            self.bitMaskArray[index] = modifyBit(self.bitMaskArray[index], position, 0)
            #make a packet_out message
            # 64 = 01000000--> pkt delete
            pktForDeletelink = self.buildRawPacket(self, clabFlag=64, bitmaskArrayIndex = index, bitmaskPosition=position, linkID=link,
                                                   bitmask=self.bitMaskArray[index], level_to_link_id_store_index = oldLevel)
            packetOutList.append(pktForDeletelink)
            newLevel = e[1]
            self.linkToCurrentLevel[link] = newLevel
            index = int(newLevel / self.bitMaskLength)
            position = newLevel % self.bitMaskLength
            #make a packet_out message now and insert In List parallely modify the self.bitMaskArray[index]
            self.bitMaskArray[index] = modifyBit(self.bitMaskArray[index], position, 1)
            pktForInsertlink = self.buildRawPacket(self, clabFlag=64, bitmaskArrayIndex = index, bitmaskPosition=position, linkID=link,
                                                   bitmask=self.bitMaskArray[index], level_to_link_id_store_index = newLevel)
            packetOutList.append(pktForInsertlink)
        return packetOutList



    def getAccumulatedDistribution(self, disrtibution):
        accumulatedDistribution = []
        sum =0
        for e in disrtibution:
            sum = sum + e[1]
            accumulatedDistribution.append((e[0],sum-1))
        return accumulatedDistribution

    def sendControlMessagesToDataPlane(self, cntrolMessagesList, dev):
        '''
        This function will send the messsages to DP
        :param cntrolMessagesList:
        :param dev:
        :return:
        '''
        pass