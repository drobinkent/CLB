# Memory limitation:
If a clos dcn is built from n port switch then it can accomodate n^3/4 hosts and n^2/2 subnets. 
So if we want to keep 25 butes of record for each host in each switch then it is not scalable. But if we keep subnet level info
then it is resonable. 
For example, if n = 256, totoal subnets are 256* 256/2 = 32768
If we keep 40 bytes for statictics, then 1.25 MB data are required for monitoring. --> resonable for a single stage 
If we keep 25 bytes for statictics, then 0.78 MB data are required for monitoring. --> resonalble for a single stage 

In fact inside a pod we need info on each subnet. but outside pod we do not need to keep info on each subnet. Because the path diversity is limited by
the number of paths to superspines. So for each leaf switch it is enough tp keep track of the paths through each spine and 
for spines it is enough for 

# for delay stats
in stndarad_metadata there will be 2 fields
1) is_pkt_frm_host --> For poacket from host to leaf switch 
2) is_okt_to_host  -->For poacket from leaf switch to host. 

There will be a header in each packet:
1) struct dcn_int


at src leafswitch (the switch directly connected to host) we tag each packet with the timestamp. when the pkt reached to destination leafswitch,
the leafswitch stips the dcn_int metadata and also calculate total path delay. Now the leaf switch have a table that will map
the subnet of the src packet and will keep record of the path delay with which port the packet is coming. When replying the packet 
if the leaf switch finds that a certain port has more delay then others then it will select other path. 
* (basically we will implement a movinf average or threshold to find the correct path. If we do not use threshold there will be too many 
updates from cp to dp table. so we use either threshold and )

Obviously, this is indirect sensing. Becuasin we are getting delay info of a packet while incoming this may not be accurate 
for sending the packet in reply. but tcp also works in this way.  

###################################### We are not using that MB calculation

# ingres and egress communication gap
As PDP are basically devided in stagges and ingress can not talk with egress stage, only way to propagate event happening in output port
queue is to achieve through recirculate the packet to ingress. As a result there is a gap, in the meantime situation may change. this is 
an inherent limitation in all existing works (burst radar, rexford zero queue etc).
To deal with we will only report some event to a peer if there is a threshold change. For example if a packet comes and finds there 
it is creating the queue to grow up more than 10% or shrink by 10% of the previous value then it will report the event tp re;evant neighbour


Assume we have 4 paths from one hop to another hop. now at each time we collect metrics for each of the path. There may be n metrics. As an exmaple consider 
delay is the only metrics. At some period DP may observe there is a .0001 ms delay incrase for a path to reach next  
 
# No support of lopp
* so no sorting and direct search

# Stateful data strucutres are per stage in available hardwares. Though drMt like hardwares can support ehm but they are not realized . 
So that means , registers and counters declared in one stage are no easily in sonsistency with other stages. So , we will collect result of a 
packet processing in one stage, and pass it to next stage through metadata. For example, we will collect the ingress queue depth and rate
relaed info in one stage and save it to metadata. then in next stage we will use them to store in some data strcuture. 

# no event based processing. though some proposal are there but they are not yet available in avai;lable switches


# We are using weighthed moving average. Bcz , if we use direct threshold based checking then DP can not adapt with dynamic behavior. Assume at start when there are nmot too many flow in the networl
queu depth will be always low. but when load increases then a smalleer valur for threshold can not  reflect the network situation. That's why we are using 
moving average

# There is a gap for resubmit . We do not use those egress to ingress resubmit at this momnt. New featuers are coming. We beleieve they can remedy this


#there is no scope of sorting. So assume we want to select the path with already have utilization withn range 60-90 %. 
this is not possible . We have to design algorithm in sucha way that it ultimately leads to high utilization of 
the links. 

# memory at first stage can not be accessed from next stage. in forwarding metamorphosis paper they have told the bus is
only for placing header fields. moreover memoery access needs ports to each stages memory from each stages. DRMT solves that through 
crossbar switch. So we will write another paper based on dRMT and will implement the TE for dRMT.  

# Once a table is visited it can not be revisited in the pipeline. 
# Also, a table can not be searched dynamically based requirements. For example sometime we may want to visit a table for path with l owest dealy
. but if sometimes we see that we should select a path with not lowest delay then it is not possible in tcam. we need l shortest path to do this. 
Which is not possible in RMT. 

# why we moved for Policy based routing: In our system we collect path statistics. We can keep per flow staticitics in switch. but that 
is not scalable at due to memory (SRAM) limitation. also if we add enough dram that will downgrade the line rate performance.
We can build algorithms using all the per switch statictics we are keeping. but whatever algorithm we folow we can not build 
an algorithm that can achieve 3 foundamental goals. These goals are 1)line rate  perfroamcne 2) building the optimal path selection algorithm,
For some topology , specially clos ECMP is optimal for only single goal. for multiple goal it is NPC 3) Even if we can design a specific
topologuy for which achieving all the goals is possible in polynomial time, it will be not real time decision. Bcz there is a delay between 2 switch.
So when we get information in one switch(s1), in the mean time the traffic situation in switch2(S2) can be drastically different
from our assumption. Hence we believe it is better to build some policy, switches will follwo those policy. And these policies have 
to be such that they can give us perfrroamnce gurantee withing certain limited / granularity. so we moved to policy routing.    
 
 # Packet generation : https://www.cs.princeton.edu/~xiaoqic/documents/paper-ConQuest-CoNEXT19.pdf
 
 they have reported that (in citation 34) that toffino has packet generator support. 
 
 # you can not create multiple copy of a packet from egress. Becuase only in egress you can get information about a queue situation. 
 if you want to do get that information in ingress that is not possible without recirculation. and there is a delay. you can not do 
 mirroring or multicast in egress. so you can not send information about a egress queue depth change to both ingress and cp at the same time. 
 What we can do is we can recirculate to ingress. and from ingress we can assign that packet to send to cp. So this means adding extra delay 
 while sending info to cp. We can create multiple copy of a packet using multicast (which is replication). But all the copies are identical in egress.
 so not real stateful tasks can be done. 
 
 even if we keep track in stateful memory about the replication, we can not share data between ingress and egress. so no point in keeping stateful data
 
 
 # Why it is not practical to implement an algortihm that involves real time decision making from both data plane and cp?
 
 reasons 1) from dp to cp we need to send information. CP is in differnt thread. and from dp we can not instruct cp to puick a packet 
 from middle of the pipeline and do some tasks. to send some informaition a packet is neeeded to complete it's processing in pipeline
 and then send to cp for further processing based on events. So obviously there is a delay. Traffic changes in scale of very small timesclae. 
 While we  are sneding information to cp traffic may alsready change
 
 
 2) the source of congestion is always the queue in egress.  All qos , aqmp, scheduling algorithm requires information about 
 egress queue to  decide which port to send next packet. So this means we need ocmmunication between ingress and egress. But in current 
 hardware this is not possible directly. only possible if we recirucu;late or resubmit a packet. but the decision of sending info from 
 egress to ingress have to be decided in egress stage. But current hardware (bmv2 in our case) only supports mirring to single extra port.
 So if we want to send egress info to ingress then we have 3 options
 
 a) recirculate a packet. but original data packet recirculation to ingress means changing semantics of whole flow. this can easily hamper 
 and application performance (tcp reordering !!!). So we have to avoid direct recirculation. we have to clone a packet and then recirculate it's cloned version while 
 sending the original data packet to flow as usual. Now in bmv2 we can mirror to only one extra port. in egress we can not make multiple copy
 of a packet onyl 2 is possible. one is copy is to be sent as original packet and another is to be used for recirculation and sending egress 
 queue info to ingress. from ingress then we can again send the packet to cp. but in current hardware there is a scheduler in ingress 
 to select which packet will be shceudled for processing in ingress. as a result we can not gurantee that once a recirculated packet reaches to 
 ingress it will be immediately assigned for processing. only way to handle that is to bring multi explicit multi-threading in data plane 
 program, so that we can tell the hardware to immediately process some important packets in ingress in a separate thread. thgouh local control plane 
 workss in a different thread. but currently in P4 there is no provision to instruct a hardware to tell which packet should be processed in 
 which thread.
 
 b) another way is to do replication in ingress and create multiple packet of each packet. but as our goal is to get information about
 egress queues in ingress, that means in ingress stage we have no idea about whether a packet needs to be replicated for bringing 
 egress info to ingress. so we have to blindly make n copies of each packet. that means, reducing the rate of whole pipeline by a a
 factor or n. this is completely unacceptable. 
 
 c)  this option is to disaggregate compute and memory like drmt. but as per opur knowldege no hardware have this imeplemented this. 
 
 So ultimately we have to either implement a) fully dp based or b) cp+cp based with extra delay to send information to cp.
 
 
 # Can we send  back pressure to an ingress port from ingress stage? 
 
 example: assume we have found a a packet have faced delay while coming from previous hop. now we want to feedback that to the sender.
 if we want to replicate the packet and send one cpopy to original flow and another copy to ingress as back pressure in ingress stage. then we 
 have to configure cloning session for that ingress port. now the trouble is a packet can be actually forwarded to any of the n ports.
 Now if we want to  configure cloning session for each egress port to each ingress port. that means n * n sessions a re needed. for 256 port switch
 256*256 =  65536. Currently bmv2 support only 65536 sessions. that means we will be left with no sessions for other activities. 
 
 # Limitation of INT implementation. it only used inband informations. The trouble of this is that, if assume there is traffic from
 a to b. so a will send traffic to b. but if the traffic flow is assymetrical means there is less flow in b to a direction then INT
 will give information , but that will be delayed. That's why we have used back pressure feeedbacks. 
 
 # Path ranking based on metrics: use our dp only implementation. keep a abit string. assume for a metrics we have n levels. then we need
 a n bit string (which will be kept in register). 1 means there are paths in that group. 0 means no path. a table will be kept
 with ternary match. so highest level (msb) will be of highest priority. and so on. as there are more than 1 tcam available in each stage
 so we can do this matching for multiple metrics in one stage.  
 
 #Ingress and egress we can not share statefulmemories. Look at jennifer rexford paper intro. 