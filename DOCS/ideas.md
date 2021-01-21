# Some Ideas

1) RACKCC with CCP. 
2) queue depth threshold, delay thgresold, -- what if we make them register bvased and update them dynamically from cp



# Some real easy but may be significant ideas

* DCTCP -- setting the ECN mark of DCTCP by the parameters of our frameworks. Attaining the Promise and Avoiding the Pitfalls
                                                                              of TCP in the Datacenter -- this paper can be used as a base
* RCP rate control by our algorithm
* Search in google with "buffer sharing + data center" and see the first bvest paper. 


# Policy based routing in PDP

* Assume we have few policy. For example, any host that have more than c kbps bandwidth consumed, that should not be priorotised. or
that should be sent over a low prioroty path. How we can tranlate that to our system. 

How: assume we have a table for policy. here any flow that matches some ciriteria (example traffic color rate based, or queu depth based)
will set some fields on the metadata. based these metadata we will search paths for that flow in next steps. for exmplae
: one field for delay based paths range, one field for queue depth and so on. so from policy table we will set what
should be the desired range for that flow. then based on those fields we will search paths in our step based routing tables.


At first we may not implement the policy based routing, so we will set the policy staticlally through the metadata. If we 
set the desired level to lowest proioryt matrix. for example 1 for delay. so it will match the rmt with all 1-4, 1-3, 1-2, 1-1. 
And if we give highest priority to 1-4 so this will select path from 1-4 group. If there are no suitable path in this group, it will 
match lower prioroty group. so this is in fact a best effort based service. 

If we want to implement string policy then, we have to make another table where at start of a flow, we have to find 
the sedires level of QoS metrices and need to find paths with that levels. That part is not done yet. 



# Server processing 

Hotnet 2019 mackeown paper: they proposed a nic where we can start the processing within 150us and so on. what if we can 
use this cpu as local cpu? is it posssible. what kind of solution is posssible.    


# hardware sorter
main issue is memory. so if we have a hardware sorter designed in bamboo. and then if ti runs in slow speed, then no problem. 
we only maintain this sorted in seprate thread. compare with L-nic concepts. 

Say that several efforts are ongoing for doing comoutations in cpu from nic . wha tif we add a sorter in asic. 


# scheduling : can we implement a version of fair queing in p4 and test
implement shivaram's queue and a new paper calender queueu in our framerwork 


# Broadcom smart-buffer technology
  in data center switches for cost-effective performance scaling of cloud
  applications -- look into its details
  
  --- https://people.ucsc.edu/~warner/Bufs/Extreme-Buffer-WP.pdf -- read this doc and understand ut for buffer
  
  