We will implement each feature as a pluggable thing
Example: 
Ingress stats will be pluggable. When we pass the relevant flag in compilation step only then it will be activated

#Test env setup
To test various bottleneck scenario we have to understand few things
1) To simulate actual switch behavior, we have to set a specific queue rate and queue depth and packet size
2) queue depth alwasy have to be greater than queue rate otherwise queues will always be unederutilized and we can not create 
bottlenech link
3) Pkt size have to fixed for a scenario, because queue rate * packet size is the actual rate a port can support
4) So we need to find a relation between the meter rate and these 3 parameters. 
5) assume we have setup queue rate = x, queue depth = y , (y>x)) and packet size (for udp this is datagram size and for TCP this is 
MSS)= z Bytes. Therefore at most any port can support x * y * z bytes.  This is the INCOMING PIR for a port. 
(Do not think as outgoing. Because we are actually trying to maximize the outgoing rate
6) So besides the 3 parameters we also need a threshold value to set the CIR. So in total there will be 4 param. 

# Sttructure of our Data plane program
## Data plane
a) Tables for rate config and other ingress monitoring
b) tables that will be actually used for path selection
c) tables that will be used for egress monitoring

## Control plane
a) per device thread that will recieve PACKET_IN and do processing
b) we will also keep update which parameter is updated from CP to DP how many times. This is necessary to show that, our program not updates to many time




How we will process delay
a) Tag each packet in leaf siwthc with ingress timestamp and deparse the dcn_int header
b) neighbour switch rcv the packet and calculate pkt.ingress_timestamp - pkt.hdr.int.timesamp_from packet_sender = delay
c) calculate a weighted delay, old delay will be kept in a register. Register will be n form of array. for each port there will be ohn register
d) Ther will be a register written by CP for threshold 
e) if new weighted delay differs from old delay by a threshold (example 10%) then report it to CP
f) CP will update the path property
g) This delay has multiple contributing factor, one is the ingress depth of queue in src switch, another is 

* How CP will process these delay metrics
    a) At first CP creates n groups in the table for delay_metrics. n is the levels we assign for delays. At this moment we do not differ for 
    in pod and out of pod delay. LAter we will add this. All member of a group have the same priority. n means highest priority or best paths, 
    paths with least delay
    
    b) At first all upstream paths will be in n th group. 
    
    c) There will be a old_history_value for each of the group. At start this is 0
    
    d) each time DP reports +ve or -ve change in a path delay, CP process as folloWing   
        
        1) if this is first time CP receving a report from DP, if this is a a +ve change, then the corrresponding path's current group 'c' is identified
        and reported delay/some fixed valus = t, then r= (c-t) % n is calculated. mod n will keep the result in range 1 to n. r is the new group
        so the path will be removed from it's previous group 'c' and it will be added to group 'r'
        
        if this is a negative (-ve) change on that case (c+t) % n is the new group
        
        Or we al so may update by 1 each time.
        
        2) How the DP will process each packet
        
        After DP rcvs a packet, it goes to delay_metrics table, tries to find a path from highest prioroty group. if it doesn't find a path it will select ECMP
        based path from a another table. This ecmp based slection will be used after we check for each of the metrics. 
        
        2) 
        
 Task 1 4 table for 4 leveles
 Packet in handling
 
 
 If std.metadata.some_event =[ = true
 Send to relevant entityy
 
 In this action set a packet for either cp or packet replication or build custom packet
 
 
 if delay event build control packet clone to ingress_port
 
 if control_packet === true
   if (event == x)
        build_pckt for x event
  if (delay_increase or delay_decrease event)
     build a feedback control packet and 
     clone the packet to ingress port
 
 
 
 Create all types of session required in each switch
 
 
 # How to setup ECN threshold
 
 http://conferences2.sigcomm.org/co-next/2012/eproceedings/conext/p25.pdf -- lok at this paper. 
 Avg of RTT * bottlenech link capacity. so assume h0p0l0 to h0p3l0 do ping and find avg rtt. then multiply by the bottleneck link. 
 (130 ms * (10 pps *1500 byte per pckt in bmv2)) / 1500 byte = 1.3 pkt
 
 
 # How fake ack are handled
 There are 2 case. a) fake ack generated in leaf switch b) fake ack generated in non-leaf switch
 
 ## Fake ack generated in leaf switch. 
 if rate control fake ack is generated in leaf switch then it will be handled in the !NORMAL (aka cloned packet part). that will be sent to 
 directly to the ingress port. so in leaf switch 2 cases may happen
 a) Fake aCk triggered by the packet was actually rcvd from downward port (aka host facing ports).  
 On such cases build fake_ack_without_any_custom_header
 b) Fake aCk triggered by the packet rcvd from upward port (aka pkt is coming from upward and it should hit the dowanrd routing table). On such cases build fake_ack_with_other necessary_custom_header
 (like mdn_int, p2p feedback)   
 
 for spine switches both cases are same build fake_ack_with_P2p_feedback. 
 
 
 in leaf switch if both mdn_int and p2p_feedback_exists and also tcp ack is set then
 
 
 
 # Doccument whether from a spine or leaf switch we can send p2p_feedback and mdn_int and tcp all time or only when ack is there without data. 