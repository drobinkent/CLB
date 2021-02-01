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