* http://www.jb.man.ac.uk/~jcullen/code
A potential place for iperf code

* If we do testing with iperf3 -c 2001:1:1:1:0:1:1:1 -n 10240K -b
 204800K -w 256k
    1) at 100 queue raate it takes 72 second
    2) at unlimited queue rate it takes 18 second
* We will create 2 flows from each host to some other host. This will make these flows to compete with each other. We wil also keep queue rate limited
at each host. 
* then we will do the testing
* Try to replicate the tests using scapy.


Queue Rate

At start, start iprrf3 server in each host. 
Do a test to check impact of window size in iperf test. 

Que rate us x. That means if pkt size is p. Then the switch line rate is  x*p.  That is the ultimate rate supported by a device port. So we can suppport a percentage of this. So we have to setup theeter rate according to this. 


For test, set a fixed MSS. And do testing. From each host we  we need to setup the queu rate in a global constant file. And based on that we can set the link bw. Though it is unnecessary. So instead of bw we will tesr ratw based on queue rate. Queue depth is basocally the peak burar rate. 

Do a test in iperf with MSs 1800, queu depath 20,  quue rate 10. So link bw is 10*1800 byte = 18 KB. 
And queue depth is 20. So CIR is 18 KB,
pir is 36 KB. 


So we need 2 param. Queue rate and queue depth. Based on these 2 param set meter rate. 
And do the testing.  


# Oversubscription
Assume we have half port connected to down stream and half ports connected to upstream. So if every link is activated then in every ;layer 
we have 1:1 oversubscription ratio. But if we have lower speed in host to leaf, then we do not need all the uplinks to be activated. Or at least,
if we can maximize link utilization we can keep some link off. which can contribute to energy saving. Consider this as a possible research direction;

* Test scenario 1:
Now assume in a leaf switch 2 hosts connected. and they can send traffic at a rate of 10 gbps. on the other hand 2 connection to spine. if the connection to 
spine are also 10 gpbs. then 1:1 oversubscription. which is wasteful. But to simulate path diversity we will use queue rate and queue depth. 
Exampple: assume a 2:1 oversubscription ratio. so that means hosts can send 2x packets per second. where leaf switch can send only x packets perseond to
upstream spine switches. Our ultimate goal is to create a situation where contention can happen. That's why we will use that. (Assume we have 1:1 
oversubscription ration then we may want to maximize the link utilization so that few upstream links can be turned of for energy saving. based on 
ultimate gosl we can create many more variotations). 
     
     Now assume the 2:1 oversubscription ratio. How to create the testing environment with link contention: 
     
     Assume 4 port switch. each of the host facing port will have queue depth 40 and queue rate 20. so max 40 pps packet from host is supported.
     Remember, if we increase the max queue depth that means we are allowing more bursts to be accomodated from hosts. which will create congestion in 
     upper layer. So our goal is to keep the queue depth ni control. Now in spine facing 2 ports we will set also 40 maz queue depth but queue rate 10.
     so from hosts we can accomodate 40 pps while we can send only 20 pps to upper side. so there is contention; Now our task is to send 40 pps 
     from 2 hosts and send them to 2 diffrent hosts in 2 differnt pod. Then test 2 solutions 1) Normal ECMP and 2) our solution
     
     special point hear, queue depth have to be set up according to tcp BW * RTT equation. This way we can also do experimentation with TCP buffer size.
       
       
# How to write code for testing

* a config file with following format
    * src dest data volume data_speeed distribution etc
    * each host will have a send and recieive thread
    * each host will be started with their own hostname and test_case_config file
    * If their hostname exists in the config file then they will send the data. 
    
    
    
# TEST code for iperf3   

* h0p0l0 iperf3 --client 2001:1:1:1:0:0001:0001:0001 --port 22002 --cport 32015 -f K  -w 32M -n 1024K  -b 256K -l 256K


if windows size is too small then ther will be trouble. so make window size big in hosts 
Remeber iperf always send chunks in 128 KB. SO if you want to send 127K it will send 128. If you want to send 129 it will send 256 KBytes of data

# important note on iperf3 
* a sample commad is : iperf3 --client 2001:1:1:1:0:0001:0001:0001 --port 22002 --cport 32015 -f K  -w 32M  -n 16M  -b 256K  -l 128K

1) here -b is in bits. so to get a 1 MBPS we ned to pass 8M here
2) the chunk size is 128 K here. whenever bw (-b) is less than the chunk size it makes some delay in test
3) so ultimately make chuck size 256K, set bandwidth in M scale, assume 1M minimum (256 KBPS). and total data to send (-n ) alsi in M scale 

The end part in IPErfResult Object contains all the necessary infos

## Testing Scenarios 
1) All small flows
1) All small flows
2) All large flows
3) mix of small and large flow
3) mix of small and large flow
3) mix of small and large flow
4) Among all large flow start a medium flow and a small flow
5) among all small flow start a large flow, chekc how it performs
6) https://dl-acm-org.proxy.library.kent.edu/doi/pdf/10.1145/2658260.2658266 -- this paper have good info on test case generation.
look at that. 



1) for delay, for each host we can plot a graph using total data sent vs time required for that or vice versa
2) for each link, counter value in cdf
3) total retriansmit 
4) Fairness:: compare the fct and bw curve of each host. each host 2 flow compare them. 



# For queue depth comparison, instead of keeping isolated queue depth, we can make a counter and each time we add get a packet in egress 
we can increase it. Thus it will be a cdf of queu depth. then we can compare various algorithm. this reduces the requirement of reading the
queue depth at real time from CP. 


# Traffic Scenario for maximize throughput traffic -- 

Assume the case where we are using per port traffic type based rate-- so table will be (ingress_port, traffic_type_rate)
Now we want to test 3 types of traffic 1) low_delay small flows, 2) medium flows -- we want to maximize throughput 
3) maximize profit -- assume we have a configuration where if we can pass a flow through a specific port will be 
maximize profit. On 3 rd category will assume traffic flows are either equal to maximize_throughout flow volume (let's 
assume 5 mb for our example)

* for ** link utilization control, we need to use a traffic that not saturates all the link. 

# different policy use korle different type er flow r jonno ki rokom result pai seta o dekhte hobe


# link utilization er jonno load dite hobe upward flow er kom -- seta diye link utilization maximize er result dekhte hobe