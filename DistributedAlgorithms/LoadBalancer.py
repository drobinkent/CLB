



class LoadBalanacer:

    def __init__(self, totalLevel, allLinksAsList, totalLevels, bitMaskLength):
        self.linkToCurrentLevel={}
        self.totalLevels = totalLevels
        self.bitMaskLength = bitMaskLength
        self.bitMaskArray = []
        for l in allLinksAsList:
            self.linkToCurrentLevel[l] = 0
        for i in range(0,int(self.totalLevels/self.bitMaskLength)):
            #Initializing all the bit masks with 0
            self.bitMaskArray[i] = 0

    def installDistribution(self, weightDistribution):
        '''
        This function process the whole distribution and generates all the pcaket_out messages to be sent to DP
        and store them in a list. And return the list
        :param weightDistribution:
        :return:
        '''
        for e in weightDistribution:
            link = e[0]
            oldLevel = self.linkToCurrentLevel.get(link)
            index = int(oldLevel / self.bitMaskLength)
            position = oldLevel % self.bitMaskLength
            #make a packet_out message now and insert In List parallely modify the self.bitMaskArray[index]
            newLevel = e[1]
            self.linkToCurrentLevel[link] = newLevel
            index = int(newLevel / self.bitMaskLength)
            position = newLevel % self.bitMaskLength
            #make a packet_out message now and insert In List parallely modify the self.bitMaskArray[index]


        pass