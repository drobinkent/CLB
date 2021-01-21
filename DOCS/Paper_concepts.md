# Paeper 1 : TE framework

* there are several non P$ centralized TE framrework : microTE, Yates, hedera etc
* there are few P4 based TE frameworks. study them and list why were different from them
* we will also provide policy based control here with both path selection and rate control 
* without much delay implement the CP based implementation. 
* As an use case, we will show how to implement RACKCC in our system 
* and also how our feedback system can help in performance oiptimization of DCTCP
* write a section about why the parameters we have choosen are important from TE perspective
* try to add queueing model application of our framework


# Paper 2 : Load balancing entrirly in data plane (on implementation of k-shortest path in data plane)

* here we will use egress queue depath and rate feedback to ingress and implement our fulyl DP based load balancing
* Assuem for a metrics we have 100 levels. if we implement our level keeping system then to decide from which 
group to select next path, we can keep a 100 bit arrray. if a level is empty then corresponding bt will be 0 else 1. 
and there will be a ternary match table.  where highest level corresponding but will be of highest priority. 
Example: 4 levels. 4 bits. msb will represent highest priorotity. and relevant entry will be with highest prioroty. 
Advantage of this approach: in one stage usually there are multiple tcam. so if we have multuiple metrics, we can find which level 
to use for next path for multiple metrics in just one stage. this will keep resource usage really low. 

Next challenge is to dicide how to define which level to enter a ptah. because there are no division support in RMT. 
so we can keep a range table. same theory as tcam can be applied here. multuiple metrics can be compared in single stage 

 (on implementation of k-shortest path in data plane)-- theme of this can be entirely on k-shortest path. 
 --what are the limitations of pdp
 --why we have choosen k-shortest path-- because this is an algorithm that is immensly important and immensely complex. because 
 if we want to push more tasks in data plane then we have to find how to implement stateful algorithms in data plane. 
 -- what are their implication on k-shortest path algorithm
 -- what is our apprximate k-shortest path program
 

# Paper 3 : rackcc: flow count korar jonno Jennifer rexford er pper style er time window based count korte pari. perfect rate a 
send korle o congestion hober. tokhon amader feedback system use kore rate mdify korte pari


# Paper 4 :
Impact on tcp incast and outcast of our solution. 


# Paper 5 : 
Assume the range is 0-10000. step size 100. then we can save the steps and divided into 100000/100 values and keep them in range based table
example range: 0-100
                101-200
                201-300

       It's up to cp to use this table. so we can use exponential scale here. so lower range will have smalled value and hjigher value will be of exponential  increasin value.
       so, in thi sway we can implement a cost function also.
       
For any metrics we can replicate this concept


Clearing mechanism :

assume for a metrics there are ports in an register arrray. this array is indexed low and hi. now we can keep a counter
and each time packet comes, it checkes the counter port in a metrics and check it's time to clear it or not. so this is 
just a round robin technique based clearing. We can either use this, or random. Or we can use CP based probe packet.  

 

# Paper 6: https://dl-acm-org.proxy.library.kent.edu/doi/pdf/10.1145/2658260.2658266

flow scheduling. this paper keep mico flow using ECMP. and for elephant flow uses different technique. Near to us. but we do not 
left mice flows for separate ECMP. 

# HPCC: High Precision Congestion Control -- need to look on this paper

# Rate control requirement

a) faireness 
b) rate control only in one place. only leaf switch will control the rate. and tags the packet that the rate have been 
reduced or increased. 2 info needs in header. increase//decrease happened and last time this knid of operation happened. 
if any switch finds that already happened then it will not do again if the time_tag of the packet is within a threshold.
this threshold should be the one way rtt of a path. this needs to be configured. 
c) If we have maximum 5 hops. so 5 extra header stacks . each tag for one hop


Our target is to decide about congestion as early as possible and set the rate accordingly. Now to achieve that, there are 2 options.

a) decide about the rate solely from leaf switch. Challenge here is to propagate information about congestion to leaf switch. 
even though we can propagate to leaf switch, it will be not perfect real time.  

b) decide about the rate from any switch- challenge here are a) to where to set the rate and send ack and b) for a single packet 
there should not be more than  one rate increase or decrease. 

if we carefully observe the paths in data center. there are fixed path length. for inside same pod 4 hop and in other pod always 6.
Now there are 2 cases 

a) a packet has still not crossed mid point . Which means crossing the super spine here. Because after crossing the super spine 
it is closer to destination and it may be the case that instead of sending seperate ack it is more proffitable to indicate ecn to 
recivier and reciver will inform the sender according to normal tcp. 

b) a packet has Crossed mid point. 


# rate control ack -- 
1) when a switch doesn't find un-congested path for upward packets it will decrease the rate and send ack to sender.  
any further flow of same class will face same result if face congestion. Now obviously, if there were a traffic burst then 
there can be a unfair marking  and rate reduction. on that case we need per flow rate counting instead of traffic class


2) whan a switch 


simple solution:

every switch will send rate reduction ack. leaf (also each switch will keep track blowlet based track and time about whether 
there was a reate decrease ack send within threshold time) will  keep track for each flow whether a rate reduction signal have been sent to the 
sender host within a threshold (this threashold is related to tcp timer). if not sent then it will be sent to sender. otherwose not
also need to add extra filed in header to signal that there was modification of rate. also if a switch sends backward ack 
it will also change the size of window in the original packet. so that rcvr gets notified about the modifies window size. 


rate increase will work as normal tcp procedure. Or we may use same policy as decrease. 

there are 2 cases 
    -- upward -- portion of path from source to super spine -- if congestion found surely send rate decrease
    -- downward --   portion of path from  super spine to rcvr -- if a flow is large and have a big burst. then 
    

------------ ** TCP fast retransmits relies on 3 dup ack. As in DCN env loss is quite low we assume that when we send a 
ack from switch it not interupts the real tcp flow. besides this now-a-days various userspace based tcp stack are 
being used. as a result, there we can easily use logic to detect this kind of ack. or even new variation of tcp can be developed 
where we will have special packets for signalling information about network inside. 
    
# Paper concepts: if we use this kind of rate control. it may not be with exact calculation. write a paper on various strategy regarding 
how to control rate in data plane. Example delay bw product based rate control. 

there can be 2 part of the paper. first part will deal with what is the impact of wringly settging window size in tcp and also 
in data plane. both case needed to be studied. then we will say what is the strategy for solution and testign result.


# INCAST is caused by applications actually. Assume a client have multiple request to mutiple storage or database.
when the reply comes, if the result packet rates are more than ethernet port speed, then incast happens. that means 
the request was actually responsible for this incast to happen. 

also assume  a distributed system, where client requests are sent to a server. now assume for the request to handle there are n
redundant servers. so how we are goigng to schedule the requests to server plays a big role. so scheduling is very important here.
but unfortunately the application layer scheduling is not aware of the network. so network layer scheduling/load balancing 
which is called layer 7 load balancing needs to be in sync with network / layer 2. how to do this?


# Can DP assited protocol stack help in TCP optimization

TCP issues describve them

then tell how we are using feedback and rate control. then tell our system.
then evaluate our system against vanila ECMP, ECN enabled dat aplane and compare with our system. 

if our system performs better then we can cp assisted system can be utilized in dat acenter.  


# Traffic aware flow scheduling

in our system, while selecting path we are considering the path conditions. Wha tif we take these traffic conditions in 
selecting priority? 
Look at resQueue. They have done a simple thing. we can do our system in P$ and also their system in P4
PIAS resqueue ei duita paper o dekhte hobe. information agnostic shheduling kore ejonno. 

# Programmable Calendar Queues for High-speed Packet Scheduling  ---  This paper is very important for 
overall impact of scheduling. understand its every bit. 

# Assume we want to add cost model . So for any specific class of traffic, if it crosses the given rate, 
then add some extra cost. -- We can search for some cost model based work. 

# Exmaple use case of DP-only multupath-- NUMFabric: Fast and Flexible Bandwidth Allocation in Datacenters
look at this paper. 

# assume we set queue depth threshold for egress 10. now we have to calculate at certain line rate what is the required time to 
achieve thaat thresold? same for delay also. this will help us to determine how many time we will face recirculation
and clone. this is necessary for estimating the line rate. 


# microservice : Tales of the Tail: Hardware, OS, and Application-level Sources of Tail Latency -- ei paper k jara cite koreche 2020 te 
tader list dekho

# what problems we are trying to  solve

a) can we reduce the tcp's dependence on 2 RTT. because in the  meantime a lot can change
b) dctcp uses a simple queue threshold based ECN marking. But assume in a port we have sent multiple flows which causing 
congestion on that port, but another flow which have sent only single packet on this path, it finds congestion. that means
queu threshold based mark is not the perfect mark. Either the flow can be sent to other path. or if no other path found then
ingress rate dependent ecn marling is necessary. 
c) can we bring rate control in network. this can help in QUIC like neew protocols and ANI (godfrey 2020) for new generation applications


# can we use scheduling algorithms for scheduling microservice and task scheduling. look at some online scheduling alrotirm


# Rate stability issue related -- http://netlab.caltech.edu/maxnet/XCP_instability.pdf -- see this paper 