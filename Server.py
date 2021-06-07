#!/usr/bin/env python
# takes as arguments: <server_add> <server_port>
import fcntl
import os
import socket
import sys
import _thread
from threading import Thread

if len(sys.argv) < 3 :	# not enough arguments specified
	sys.exit(2)

TCP_IP = sys.argv[1]	# change this to default server address
TCP_PORT = int(sys.argv[2])
BUFFER_SIZE = 1024

# create socket and start listening for incoming connections
s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
# fcntl.fcntl(s, fcntl.F_SETFL, os.O_NONBLOCK)

s.listen(25)

masterFlag = True
def handler(conn,addr):
    # totalSize = 0
    flag= True
    while flag:
        data = conn.recv(BUFFER_SIZE)
        if len(data)<=0 :
            print("Data 0")
            flag = False
            masterFlag = False
        else:
            print("Data s non zero ")
            # totalSize = totalSize + len(data)
            # print("Recevied data "+str((totalSize)))
            # if(len(data)<=0):
            #     print("Connection closed by sender.")
            pass
    conn.close()
    print("Connection closed")
    print("Master flag is "+str(masterFlag))
    # exit(1)
    return

while masterFlag:
    print("Waitin for con")

    conn, addr = s.accept()	# accept incoming connection
    # ct = _thread.start_new_thread(handler,(conn,addr))
    # print("Master flag is "+str(masterFlag))
    #
    # t = Thread(target=handler, args=(conn,addr, ))
    # t.start()
    # print("In main Master flag is "+str(masterFlag))
    # t.join(2)
    while masterFlag:
        data = conn.recv(BUFFER_SIZE)
        if len(data)<=0 :
            masterFlag = False
    conn.close()

s.close()

