# How we will do testing 

    We will install 2 distribution and 2 different precision
    and we can show our concept of installing paths for first link and buying time

In MyController.py there is a function startMonitoringFromController, here we will start a new thread per device which will install the 
distribution 

In statisticspuller we will pull only the upaward ports counter. all other will be not read to minimize the time 

The statsticspuller thread will have a function to configure the distribution. -- load_balancer_config_thread_function
this function 
start a new thread 
then in the therad follow the algorihtm in presentation 
we will prepare all the message and dispatch them together. 
-- obviously if too many packets are sent together then buffer can be overhelmed. to handle that in this experiement wer will 
keep buffer capacity a lot. 

The statsticspuller thread will pull only  pull statictics from the configured device. all other device will be lleft untouched. 

# As out target is only testing algorothm we will only run the CLB from one switch.
#This parameter defines that name. The algorithm will be only run with that device


In data plane program, we will set, if for a switch CLB can not find any path then default action will set 
the path to -1. 

then we will check if no vlaid path is found then use ECMP. As a result only our configured switch will 
use the load balanicng algorohtm. Al other will use ECMP.
    


# Result Visualization

Repeat the test with statisticpulling interval 3 sec and .5 sec
Then plot a single diagram with 4 ports time vs normalized (with ratio to smallest one) value. 
This plot will show the ratio. We need to take a large gap bcz in small gap synchronizing controller log and data plane vlaues is not possible

another graph we show each ports time vs normalized vlaue in .5 sec interval statictics pulling. 
This plot will have a lot of spike. butwe need to form a curve over these spiked values with some kind of average values to show that, 
overall the ratio is maintained. 
This small interval graph will also show the distribution transition time. 


check same set of graphs with 2 approaches 
a) counter set hard value 16 wrap up
b) counter value reset by CP

If the 2 nd approach gves clear visibility of our algo then we will prefer that one. 



# How to test the K-path system 

All switches will have ecmp --> this will show possiblity of ecmp through our system and also qos group. 

then 

a) best path --> all short flows send through these path -- what of we use high quue rate for this port 
b) worst path --> all large flows through this path ---- low queue rate for this path 
c) K't path --> assume we have configured the path with a sepcific queu rate. now we want a flow to achieve specific bw. then we tag a flow with 
a specific value and based on that tag we use that path. if after test we can achieve the full rate of the link for this flow then we are done 
d) specific range --- m to n th bit on needed.

our whole assumption is lied on that we know the range of the metrics earlier 


-- for all of these 3 tests we need to implement per port rate assignment. 

then we start 3 flows from 3 hosts of same leaf to dfrnt destinations. 
configure the port rates in such a way that, each flow get a disjoint path . destination of the flow will be in 3 dfrnt leaf. 
on the other hand we have 4 dfrnt spine switch. so easily we can do this. 



can we make a table showing 

which paper needs which of our feature? 




===============================================================

# traffic csplitting finalized 

How to do test : 

Assume we want to test 32 packets per second using 4 links. our precision tolerance is 2 packets. So total weight group can be 16

so in make file, DBITMASK_LENGTH = 16 and DPRECISION_FACTOR = 1 
-- here 16 means 16 weight groups and 1 means shofting right 1 times. which is equivalent to divide by 2 that means precision of 2. 
and for representing 16 we need 4 bits (0 to 15)

-DENABLE_DEBUG_TABLES -DDP_ALGO_CLB  -DBITMASK_LENGTH=16  -DBITMASK_POSITION_INDICATOR_BITS_LENGTH=4  -DPRECISION_FACTOR=1


-- This is for P4 program 


for controller we need to open ConfigConst.py and at the bottom we need to change the configs

#=======================configurations for CLB
CPU_PORT = 255
CLB_TESTER_DEVICE_NAME = "p0l0" # As out target is only testing algorithm we will only run the CLB from one switch.
#This parameter defines that name. The algorithm will be only run with that device
LOAD_DISTRIBUTION_1 = [(5,2),(6,6),(7,1),(8,7)]
LOAD_DISTRIBUTION_2 = [(5,7),(6,1),(7,6),(8,2)]

DISTRO1_INSTALL_DELAY = 0   # Weight distribution 1 will be installed after 50 second of the controller thread starts
DISTRO2_INSTALL_DELAY = 125  # Weight distribution 2 will be installed after 50 second of the controller thread starts


BITMASK_LENGTH = 16  # This must match with the P4 program 

And do not forget to configure the packet processing rate of the links in ConfigConst.py

----

Next open CNF and there configure pps = 32 
because we are testing for 32 packets per second

