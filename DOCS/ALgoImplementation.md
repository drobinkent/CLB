# For each Algorithm there will be a single file where all confugurable parameters will be kept. Utlimtely they will be the parameters foir tuning our system. 
For example queue threshold, time delay threshold


Actual path implementation algorithm should be like

 if (local_metadata.flow_inter_packet_gap < FLOWLET_INTER_PACKET_GAP_THRESHOLD)
            //verify path old path
           if path still valid:
               is_new_path_finding_required = false
           else
               is_new_path_finding_required = true
if is_new_path_finding_required == true
            //find path according to policy
            
            
But as this is not possible a this moement. Our current algo will be 

 if (local_metadata.flow_inter_packet_gap < FLOWLET_INTER_PACKET_GAP_THRESHOLD)
    check whther the selected port is already crossng the rate or not. 
    if crossed then pass to a path (seleccted through multi criteria tables) that is not the old path
    and execute the meter of egress port 
 else 
    select path according to policy
 
 
 update the flowlet table 
    
===================== 

How to select a fresh path using policy table 

1) low delay -- direct low delay path 

2) max_throughput --   (what if we set the flowlet gap for max_throughout flows much higher instead of fixed threshold for all 
types of flows)

3) minimize cost -- assume we have some paths that are premium/platinum. may be dedicated path. Not handling at this momnent.


For recalibratiing path : 

look at the upper section. implement this algorithm
    
    
    
