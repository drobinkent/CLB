# How we will do testing 

    We will install 2 distribution and 2 different precision
    and we can show our concept of installing paths for first link and buying time

In MyController.py there is a function startMonitoringFromController, here we will start a new thread per device which will install the 
distribution 

In statisticspuller we will pull only the upaward ports counter. all other will be not read to minimize the time 


start a new thread 
then in the therad follow the algorihtm in presentation 
we will prepare all the message and dispatch them together. 
-- obviously if too many packets are sent together then buffer can be overhelmed. to handle that in this experiement wer will 
keep buffer capacity a lot. 

# As out target is only testing algorothm we will only run the CLB from one switch.
#This parameter defines that name. The algorithm will be only run with that device


In data plane program, we will set, if for a switch CLB can not find any path then default action will set 
the path to -1. 

then we will check if no vlaid path is found then use ECMP. As a result only our configured switch will 
use the load balanicng algorohtm. Al other will use ECMP.
    