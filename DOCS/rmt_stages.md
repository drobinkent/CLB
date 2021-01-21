# Ingress Stage

1) Int delay processor -- as it is 

2) Ingress rate monitor

* table structure:  port Id -- flow type -- 
    2 actions a) default action with no match -- 
              b) match with param -- add meter
              Merge ingress rate monitor and ingreess queue depth monitor here
          
3) Flowlet switching --  

4) if we want to implement our policy based routing or som intelligent routing , then we need to make one tricky thing
we have to, make a flowlet table, at very first step we have to mark whther the packet is the first packet of the flow or not. 
We have to do this at very first step. this is needed to be done through hashing 5 touple. we will maintain a flow id to last_pkts_time_of_this_flow
register array. here wil will record the flow's  last packet's ingress time.  At first we will read this and store in a variable in metadata. 
then we will write current packet's ingress_timestamp as the flow's last_packet_seent_time. 

(one important point here. If hash collision occurs, then we need to check whther the current packet's timestamp
and last_packet_seent_time crosses inter_flow_gap_threshold time. IF crosses then it means it is a new flow. )

Now read the flow's assigned port -- this may be either zero or non zero. 
then we use the follwoing if-else system

if the flow's last_packet_seen_time and current packet's time gap is within threshold:   --- 1
     then check whether the existing assigned port violates any of our heuristics
     if violates tag needs_path_recalculation_flag in metadata as true else false 
     
 if this is the first packet or  if the flow's last_packet_seent_time and current packet's time gap is not within threshold
    or the needs_path_recalculation_flag is false  
    
    assign port from routing tables
    This is  assigning new port as the first packet of the flow
 else 
    Just set old  assigned port for the flow  as the egress port 

instead of using true false  in the flag, we should use 1,2, 3 values. this will help in optimzing the if-else loop



        if violates then we will again calculate path for the packet

update the port asssigned for the flow  
    
    
==============

the trick should be complete processing of a parameter, which is actually checking in a array of register together.
so that we can say that this is done inside one stage. 


delay based processing:
few tips: 106*1k *112b sram available in one stage. so all of our memory requireent is possible to be done in one stage. 
now the question arises comparison. for each field one comparison can be done. so if we cchekc the fields as 
seperate possible without dependancy then it will help in achieving line rate. for 2013 paper, 2 port 
were assigned per stage. ekhan theke hishab koro koyta stage lagbe process er jonno

Assume for a flow we want to find the path with lowest delay. 
for a new flow --- we have already got few ports where we can send the packet based on some metrices. 
But if  the flow is old then now we whave to check it's old path validyty. 

(So when we got a delay feedback from a neighbour switch we come to it's port_delay_delay_level_reigster_array
we will update here. )

for other metrices, we already have them in packet's metadata. we only need to check the egress ports rate, which we will 
calculate here. and mark it to here. if it violates the safe mark only then we will 




==================
policy path selection table 

Assume we have found 4 paths for 4 metrices and they are stored in metadata. Now from policy table we will map 
DSCP points to some action. assume we want to find low delay path, so for that specific dscp code point, we will 
set loest delay path to be the first priority. and so on. so basically there will be 4 more variable v1, v2, v3, v4. 
Depending on dscp code point and matching action, we will fill uip v1-4. and 1 to 4 will mean path priority in descending order. 

example policy : 
1) a flow is crossing the desired ingress rate, then we will send it to slower path
    a throughput oriented but not low_delay oriented flow can be sent to slower path
    a low delay oriented flow whosh incoming traffic color is not green 
2) a flow is low delay but ingress queue depth is high then route it to a faster path, even though it's already setup path is slower one
3) egress queue depth besi hole oi patha  pathano jabena. so reverse order  a priority hobe , ekhane important point holo
egree queue depth er info egress theke clone kore then cp te pthate ekta delay ache. kintu unless dp theke packet table edit kora jay, 
ei delay erano somvob na
4) ingress ekebare last stage a amra jokhon egress rate calculate korbo, tokhon jodi dekhui egress rate RED hoye jacche,
tokhon metadata te select kora onno ekta port diye pathabo. 


flowlet switch er jonno :

first a jokhon ekebare first packet er jonno path select korbo tokhon seta ekta register array te thakbe. abar last a ekebare ingress stage er sheshe
jokhon  

Without Verification direct Policy based path selection

1) Ingress rate
    low_delay  ------Crosses safe ingress rate  
    high_throughput--
    maximize_profit--

2) ingress queue depth 
    low_delay
    high_throughput
    maximize_profit

3) delay  
    low_delay
    high_throughput
    maximize_profit
    
4) egress rate


4) egress depth


ingress_queue_depth, delay, ingress_rate , delay_based path selection, egress_queue_depth_based path selection, flowlet_id read

policy and ingress situation based path selection, 

egress rate and egress depth feedback in egress


  












































































