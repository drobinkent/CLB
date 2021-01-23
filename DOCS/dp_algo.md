##4 stage algorithm in data plane
1) Ingress Monitoring -- This generates some local events. They keep all the event info in **local_metadata.control_packet**.
2) Event Packet Processing -- This step processes locally generated events and also events reported by neighbour switches
3) Packet Forwarding -- sub steps are 

    a) NDP NS processing 
    b) PACKET-IN processing
    c) data packet forwarding
    
4) Egress Monitoring -- This also generates some events and needed to be resubmitted to Ingress stage  






For each Packet p

    event processsing part in   in ingress { 
        a) calculate path delay, if delay increased or decreased save event_info to local_metadata also update path delay (weighted avg)
        b) if pkt created spike in ingress_queue_depth mark the event_info in local_metadata
        c) if pkt violates rate, same way mark the event info in local_metadata
        ---For all kind of events we will set a boolean field in local_metadata -- is_control_pcaket
    }
    
    Add timestamp to  each packet header hdr.mdn_int.src.eng_timestamp
    
    if(is_control_packet){
    -- p can trigger a control event , but p need to be forwarded according to it's own behavior. Bcz it is the packet from src
    --So we have to build a control packet using the data we gathered from p. So we will ise clone,recirculate and resubmit
    Build a control packet using the event info
    Clone P and forward it to both its original port acording to routin glogic  and also forward the control packet
        
    }
    
    For Leaf Switch {
        if the destination is a host, mark the hdr.mdn.int as invalid and forward packet to host
        otherwise mark it as valid  and forward pkt to neighbour hop
    }
    
    
# Egress

If the pkt's egress port is CPU_PORT
    that means, this is the result of a local event. and switch is sendiong the pkt to CP for chaing some table. 
    Now obviously this was generated by a data packet and the data packet was cloned to CPU_PORT__SESSION
    So pkt for cpu port can be send to cp with all data. 
    And the correspoding data pkt is handled by later part of the egress pipeline. there we need to remove the extra headers.
    
    
    
# Our ingress rate monitoring only monitors total traffic rate for a specific class per port. if we want to send 
the feedback to previous hop we need to just change the in_control_packet_to_cP macr. 

but importnat point is, we also need to handle those feedbacks in previous hop. at this moment these is not of too much use.
Because, assume traffic flow from s1 to s2. and on identifying rate crossing, s2 sends feedback to s1 for specific port. 
on that case to handle this we also need to use the traffic class in our routing. we nned to use that. otherwise ingress info
feedback is not of too much use. 