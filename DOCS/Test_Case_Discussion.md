# Very Important take away: there is no point in testing more than 8k data rate. it eventually doesn't work in simulation. Because so much data loss happens
it doesn't mean anything. Just bcz simulation env is not prepared for this.WE have to keep all data rate around 8K and then we will 
do some testing to show results. 


# For testing effectiveness of link utilization. 
For checking link utilization if the incoming load is more than egress then there is not too much to understand. We can understand 
link utilization when the load is not too much high. For achieiving high link utilization we need 

* ingress traffic load < egress capacity
* Assume we have 2 upward link, ECMP either a) assign too much traffic on one link if the traffic hash is un balanced. Or
b) it will have balanced traffic on both the link. Assume we have ingress traffic load at 70% of total egress capacity. In our
algorithm we should achieve configurable load on any link. Our configuration parameter for this is the egress traffic rate. If we assign 
traffic rate 70% for a link, then the link utilization should be around 70% for that link. if we change it to 80% then link 
utilization should be around 80%. 
* assume at a switch there are n ingress port and n egress port (for m port switch , n = m/2 in our system). If we have 2:1 
oversubscription ratio, then maximum ingress traffic can be 2 times of the egress link capacity. Assume, 2 ingress ports have 
been configured for packet processing rate of 10 packets per second. And the 2 egress ports are configured with 5 packets per second. 
Now for link utilization checking we want to send 8 packets per second ingress load. For passing exact 8 packet per second, we 
need to send  exactly 8 packets per second. Which is not really possible from iperf. So we use a large flow from a host, and 
send that flow from a host to another host in another pod. 

2 test case 
1) to check link utilization of one leaf. only one host send traffic to another host in another pod.
2) from one host 2 flow of 2 traffic class to another host of another pod
2) to check link utilization at spine, we send traffic from 2 hosts of 2 different leaf of same pod to 2 host of 2 different 
leaf of another pod. 
also we need to test withj traffic mix

But the problem with Iperf3 is that, even though we set data rate as 4K. it tries to passes a lot more than that.
So we have to go for reverse strategy. We will set the link packet processsing rate too high. and we will send a 
small volume of data with small rate. then from controller we will set the link egreess rate to assume 50%. so after 50% 
a link should be not used frequently. traffic should be sent to other link


Example test case config: 

{
  "TESTS": [
    {
      "testCaseName": "LeafLinkUtilizationCheckerFlowFromOneHost-ecmp-e-rate-50p",
      "src-dst-pairs": [
        {
          "src": "h0p0l0",
          "dest": "h1p1l1",
          "pattern": "one-to-one",
          "flows": [
            {
              "flow_type": "tcp",
              "flow_traffic_class" : "0x10",
              "flow-volume": "2M",
              "src-window-size": "256K",
              "src-data-rate": "128K",
              "pkt-size":  "1400",
              "repeat" : "1",
              "repeat_interval": "5",
              "is-interactive" : "true"
            }
          ]
        }
      ]
    }
  ]
}

* Here data rate is 128K bits. if we consider  1400 byte MSS, we need 
approximately 12 packets per second processing rate. 

For this traffic we are setting the bottleneck links rate (spine to superspine links, considering 2:1 oversubscription ratio) as 15 pps. which is more than our requirement 
of 12 pps. 

p4ctrlr.initialDeviceRouteAndRateSetup( queueRateForHostFacingPortsOfLeafSwitch = 60 , queueRateForSpineFacingPortsOfLeafSwitch = 30,
queueRateForLeafSwitchFacingPortsOfSpineSwitch= 30, queueRateForSuperSpineSwitchFacingPortsOfSpineSwitch=15,
queueRateForSpineSwitchFacingPortsOfSuperSpineSwitch=5, queueRateForExternalInternetFacingPortsOfSuperSpineSwitch=100,
#testScenario = None
)

We are setting egress link ratios as

EGRESS_STATS_METER_CIR_THRESHOLD_FACTOR = 0.60  # This means each port will color packet yellow when it reaches 70% of the queu rate and red when
EGRESS_STATS_METER_CBURST_FACTOR = 0.05
EGRESS_STATS_METER_PIR_FACTOR = 0.8
EGRESS_STATS_METER_PBURST_FACTOR = 0.1


We have to create few flow from a host so that it creates a traffic load that crosses the safe mark of a single link. so that we can be sure that
our algorithm distributes traffic. We have to test this wih traffci mix and also with same kind of traffic. Same way we have to 
create traffic from 2 hosts of 2 leaf such that it creates same type of load on the spine links.


# For traffic pattern follow Hedera paper section 6.1. 3 types of traffic pattern


#iperf can not write the results in relative path file. So in the testConfigConstant give absolute path for the storing test results