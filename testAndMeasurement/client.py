# Echo client program
import socket
import sys
import threading
import time

import CNF
HOST = '2001:1:1:1::3:1'    # The remote host
s = None

packetContent = bytes('Hello, world test packet what is content is not important. just send it is it aokay with you. '+
                      'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
                      'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
                      'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
                      'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
                      'Hello, world test packet what is content is not important. just send it is it aokay with you.', 'ascii')
#
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+
# 'Hello, world test packet what is content is not important. just send it is it aokay with you.'+

packetContentLength = len(packetContent)
print("Content length is "+str(packetContentLength))
SEND_BUF_SIZE = 1400
RECV_BUF_SIZE = 1400



class ClientThread:
    def __init__(self, HOST, PORT, index):
        self.host = HOST
        self.port =PORT
        self.index  = index
        x = threading.Thread(target=self.cleintThreadFunction, args=())
        x.start()
        print("Client thread --"+str(index)+ "started")
        pass


    def cleintThreadFunction(self):
        for res in socket.getaddrinfo(self.host, self.port+self.index, socket.AF_INET6, socket.SOCK_STREAM):
            af, socktype, proto, canonname, sa = res
            try:
                s = socket.socket(af, socktype, proto)
                s.setsockopt(
                    socket.SOL_SOCKET,
                    socket.SO_SNDBUF,
                    SEND_BUF_SIZE)
                s.setsockopt(
                    socket.SOL_SOCKET,
                    socket.SO_RCVBUF,
                    RECV_BUF_SIZE)
                #s.setsockopt()
            except socket.error as msg:
                s = None
                continue
            try:
                s.connect(sa)
            except socket.error as msg:
                s.close()
                s = None
                continue
            break
        if s is None:
            print('could not open socket')
            sys.exit(1)
        totalSentbytes = 0

        start = time.time()
        for i in range(0, CNF.TOTAL_DURATION_OF_TEST):
            s.send(packetContent)
            totalSentbytes = totalSentbytes+ packetContentLength
            time.sleep(1)   # If this difference is too much then sending packets in too high speed blocks the tcp stacks.
        end = time.time()
        print("Client-thread-"+str(self.index)+ "--- Total sent byes are "+str(totalSentbytes))
        print("Client-thread-"+str(self.index)+ "--- Total time required to send these much data is "+str(end-start))
        s.close()
        print("Client-thread-"+str(self.index)+ "--- Closing")


def driverFunction():
    for i in range (0,CNF.TOTAL_CONNECTION):
        srvrThrd = ClientThread(HOST=HOST, PORT=CNF.PORT_START, index = i)

driverFunction()