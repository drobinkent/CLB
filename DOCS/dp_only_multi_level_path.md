# Data strcuture : look at rhe dp_only_multi_criteria_upstream_routing.p4 file 

# initialization:
* all paths will be in highest level 
* write hi_index of all level to 0
* for i = 1 to MAX_PORT 

    for each path write current level register array's i'th location with value max (for our case 4)
    
    insert i to level_max_list --> this needs increasing hi_index each time. and inserting next values to that index. As P4 arithmatic addition
    wraps arround, so we can make the index register exact same bitwidth required for number of distinct paths. for 256 paths, only 8 bits
    
    write i to level_max_index register array 's i th location 
    


Problem description: 

we have n ip prefixes and m paths. In worst case, if we want to implement k-shortest path (here k=m) .  we need a data structure for each p
prefix. For each priority queue we need an mlogm algorithm. This is not possible in PISa switches. But in fat-tree based data center,
we do not need to keep all the prefix for upstream routing. on such cases we can implement an approximate version of k-shortest path for 
traffic engineering. Then our solution is usable.

1) We need to be able to delete a path if it is down. this can be easily done from CP
2) we can add a path any time
3) if someone needs such k-shortest path for each prefix they can develope a higher level abstraction then with adding one extra table
(that table will map prefix to some id using hash) then for prefix replicating our solution n times. clearly this is not a preffereed solution.
it lacks scalability. 


Path query:

assume we want to find a path that will have delay within a certain range. so we can convert this range to correposnding levels. this levels are consecutinve as they are in 
range. so from that we can convert on which level we have to search for path. after that we can convert them into the bitmap. then 
from that bitmap we can find whether there are some path's within that range or not using that map. 

we already know how to convert the data plane bitmap (the bit map that represents whthether a lvel is empty or not) to membership according to 
priority with ternary match. 


k-shortest path -- in the bitmap based matching table. if we want we can keep only 1 ternary match entry for each level. and in the action
we can do necessary things. 

But if we add another range field, and match that with the value the hi index of a specific level, that will give us the number of memebers 
in the group. bcz low index is always 0, and hi index gives total path in that group. 


#comparison to other algo:

there are various queue based data srtucture for sorting. look at wiki pedia. make a table for how many memory read write we need 
for each one of them. and compare with our algorithm. we need fixed number of read write. tell this. 

make comparison


@can we use one data strcuture for multiple metrics? 

possibly yes. idea assume 1-4 level for delay, 5-8 for queue depth and so on. when we calculate their level we add the base. for 
example for delay base is 0, queue depth is 4 etc.

removal from existing group is same.
inserting is also same
onyl diff is query. 

for normal bitmap based query we have used 4 bit based query. to support multiple metrics in one data structure, just shift the bit map base times
left. for example delay 0 bitmes shift. queue depth 4 time left shift. 


Clearing the data strcuture: 

each packet needs to clear one of n ports. at 100 ghz this is realy chalenging. each normal packet needs to do extra 9 
memory read write. so we can use CP generated packets to clear them. 


# why do we really need the dp based given that cp based control available and even recirculation based techniques have delay also. 

reason 1) cp need to reconfigure the table. but tcam write is slow. moreover changing one metrics priority needs to readjust another one or more 
entry. this is a concern moreover there is no one shot technique to modify multiple entry. also deleting one entry and re entering another entry;; betn this 2 there is a delay. 
betn thius delay congestion can occur.

2) example delay feedback. we have to create copy of the packet then process it. which adds a small delay. then we send it back to
previous hop. then previous needs to send it to control plane. then control plane modifues table. so huge delay. 
to avoid this delay only way is to handle in data plane. 

3) sharing data between imngress and egress may not be possible for line rate performance. why? bcz, assume
we have stage where we have kept a data strucuture. in ingress we want to use for keeping track about path
statistics. Now for real traffic engineering we need to update information about the path in egress. that means we need to access 
the data strcture both in ingress and egress. so in line rate we need to access the data strcuture 
from both ingress and egress. this may not be possible to do in line rate. because memory ports are 
limited and most importantly there is a race condition. so it may be a viable solution to get feedback from egress 
to ingress. 

# This paper is a must read to understnad how we can show our work is implementable in hardware

https://homes.cs.washington.edu/~arvind/papers/flexswitch.pdf


# As an example usage of DP-only algorithm we can do follwoing

in the metrics level calculator-- use the weight. then find some paper that uses 
Utility function (schapira jackobson paper paper) to calculate the total path weight then
DP -only algo for ranking the paths and use our framework. 

# Advantage of DP -only algo -- as we use tcam we can not search a lowest delay and also highest delay port. But if we use 
dp-only algo, then we can do this. use this concept in use case of DP-only implementation. 

