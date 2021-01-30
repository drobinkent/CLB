import json
import logging
import threading
import time

from p4.v1 import p4runtime_pb2

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

    def __init__(self,  allLinksAsList, totalLevels, bitMaskLength, nameToSwitchMap ):
        self.linkToCurrentLevel={}
        self.totalLevels = totalLevels
        self.bitMaskLength = bitMaskLength
        self.bitMaskArray = []
        self.nameToSwitchMap = nameToSwitchMap
        for l in allLinksAsList:
            self.linkToCurrentLevel[l] = 0
        for i in range(0,int(self.totalLevels/self.bitMaskLength)):
            #Initializing all the bit masks with 0
            self.bitMaskArray.append(0)
        self.isRunning =True
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
            packetOutList = self.installDistributionInCPAndGeneratePacketOutMessages(accumulatedDistribution, firstTimeFlag=True)
            for p in packetOutList:
                hostObject.send_already_built_control_packet_for_load_balancer(p)
            time.sleep(20)
            accumulatedDistribution = self.getAccumulatedDistribution(ConfConst.LOAD_DISTRIBUTION_2)
            print("Old distrib was "+str(json.dumps(ConfConst.LOAD_DISTRIBUTION_2)))
            print("accumulated distrib is "+str(json.dumps(accumulatedDistribution)))
            packetOutList = self.installDistributionInCPAndGeneratePacketOutMessages(accumulatedDistribution)
            for p in packetOutList:
                hostObject.send_already_built_control_packet_for_load_balancer(p)
            time.sleep(200000000)
        pass



    def buildMetadataBasedPacketOut(self,  clabFlag, bitmaskArrayIndex, bitmaskPosition, linkID, bitmask, level_to_link_id_store_index , port = 255):
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

        packet_out_req = p4runtime_pb2.StreamMessageRequest()
        port_hex = port.to_bytes(length=2, byteorder="big")
        packet_out = p4runtime_pb2.PacketOut()
        egress_physical_port = packet_out.metadata.add()
        egress_physical_port.metadata_id = 1
        egress_physical_port.value = port_hex

        clb_flag_metadata_field = packet_out.metadata.add()
        clb_flag_metadata_field.metadata_id = 3
        clb_flag_metadata_field.value = (clabFlag).to_bytes(1,'big')

        bitmaskArrayIndex_metadata_field = packet_out.metadata.add()
        bitmaskArrayIndex_metadata_field.metadata_id = 4
        bitmaskArrayIndex_metadata_field.value = (bitmaskArrayIndex).to_bytes(4,'big')

        bitmaskPosition_metadata_field = packet_out.metadata.add()
        bitmaskPosition_metadata_field.metadata_id = 5
        bitmaskPosition_metadata_field.value = (bitmaskPosition).to_bytes(4,'big')

        linkID_metadata_field = packet_out.metadata.add()
        linkID_metadata_field.metadata_id = 6
        linkID_metadata_field.value = (linkID).to_bytes(4,'big')

        bitmask_metadata_field = packet_out.metadata.add()
        bitmask_metadata_field.metadata_id = 7
        bitmask_metadata_field.value = (bitmask).to_bytes(4,'big')

        level_to_link_id_store_index_metadata_field = packet_out.metadata.add()
        level_to_link_id_store_index_metadata_field.metadata_id = 8
        level_to_link_id_store_index_metadata_field.value = (level_to_link_id_store_index).to_bytes(4,'big')

        packet_out.payload = rawPktContent
        packet_out_req.packet.CopyFrom(packet_out)
        return packet_out_req

    def installDistributionInCPAndGeneratePacketOutMessages(self, weightDistribution, firstTimeFlag=False):
        '''
        This function process the whole distribution and generates all the pcaket_out messages to be sent to DP
        and store them in a list. And return the list
        :param weightDistribution:
        :return:
        '''
        packetOutList = []
        for e in weightDistribution:
            link = e[0]
            if(firstTimeFlag == False): # At the first time we do not need to delete any distribution. If we delte link i+1 may delete Link i th newly installed distribution
                oldLevel = self.linkToCurrentLevel.get(link)
                index = int(oldLevel / self.bitMaskLength)
                position = oldLevel % self.bitMaskLength
                #modify the bitmask
                self.bitMaskArray[index] = modifyBit(self.bitMaskArray[index], position, 0)
                #make a packet_out message
                # 64 = 01000000--> pkt delete
                pktForDeletelink = self.buildMetadataBasedPacketOut( clabFlag=64, bitmaskArrayIndex = index, bitmaskPosition=position, linkID=0,
                                                       bitmask=self.bitMaskArray[index], level_to_link_id_store_index = oldLevel)
                packetOutList.append(pktForDeletelink)
            newLevel = e[1]
            self.linkToCurrentLevel[link] = newLevel
            index = int(newLevel / self.bitMaskLength)
            position = newLevel % self.bitMaskLength
            #make a packet_out message now and insert In List parallely modify the self.bitMaskArray[index]
            self.bitMaskArray[index] = modifyBit(self.bitMaskArray[index], position, 1)
            pktForInsertlink = self.buildMetadataBasedPacketOut( clabFlag=64, bitmaskArrayIndex = index, bitmaskPosition=position, linkID=link,
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