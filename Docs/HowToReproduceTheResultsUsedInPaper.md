1) traffic generator : we created flow informations according to websearch workload with 80% flow 50 KB and 20% flow 256KB
2) closconstant 
3) then select algorithm in config constnant
4) compile the p4 program 
5) now you will hvae results for multiple algorithms in multiple folder run the fct analyzer
and may be the load imbalance analyser
   

Why our simplified version of hula is the actual hula here. 

hula monitors the link utiliuzation of each path toward a tor switch. 
now as we are simulating leaf=spine fabric, then here a tor-tor path means leaf-spine-leaf : only 3 hop path. 
now when a the first leaf switch keeps the utilization for each destination that means, that exact same 
utilization is across the rest of the path. because we have used stride pattern traffic. so that means flows from other competing 
tor s are not using this path. 

we have used this to reduce motnioring cost