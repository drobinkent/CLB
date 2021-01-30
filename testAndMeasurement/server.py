# Echo server program
import socket
import sys
import CNF
# HOST = '2001:1:1:1::'                 # Symbolic name meaning the local host
# PORT = 50007              # Arbitrary non-privileged port
import threading
import time

HOST = '2001:1:1:1::3:1'                 # Symbolic name meaning the local host

SEND_BUF_SIZE = 1400
RECV_BUF_SIZE = 1400


class ServerThread:
    def __init__(self, HOST, PORT, index):
        self.host = HOST
        self.port =PORT
        self.index  = index
        x = threading.Thread(target=self.serverThreadFunction, args=())
        x.start()
        print("Server thread --"+str(index)+ "started")
        pass

    def serverThreadFunction(self):
        s = None
        for res in socket.getaddrinfo(self.host, self.port+self.index, socket.AF_INET6, socket.SOCK_STREAM, 0, socket.AI_PASSIVE):
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
            except socket.error as msg:
                s = None
                continue
            try:
                s.bind(sa)
                s.listen(1)
            except socket.error as msg:
                s.close()
                s = None
                continue
            break
        if s is None:
            print('could not open socket')
            sys.exit(1)
        conn, addr = s.accept()
        print('Connected by', addr)
        totalRcvdBytes = 0
        start = time.time()
        counter = 0
        while 1:
            data = conn.recv(1400)
            start = time.time()
            if not data: break
            counter = counter + 1
            # print("Packet counter is  :", counter)
            totalRcvdBytes = totalRcvdBytes + len(data)

            #conn.send(data)
        end = time.time()
        #s.recv()
        print("Total recvd byes are "+str(totalRcvdBytes))
        print("total time required to transfer these data is "+str(end-start))
        conn.close()


def driverFunction():
    for i in range (0,CNF.TOTAL_CONNECTION):
        srvrThrd = ServerThread(HOST=HOST, PORT=CNF.PORT_START, index = i)


driverFunction()
