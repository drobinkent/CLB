# How controller collects statistics

1) After loading all the devices using "LoadCFG" function. and After doing all initial setup relted tasks. Now we have info 
about all the devices and their management console (through thrift server). Now we can will start a thread for each of the device. 
This thread will pull the counter values after a specific interval. 


# Packet Processor Part

1) For each device we start a thread for processing packet-ins. 


# algorithm thread

1) this May be called from packet processor . This wil use the statistics collected by the statistics collector thread. 

