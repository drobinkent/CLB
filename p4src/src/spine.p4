/*
 * Copyright 2019-present Open Networking Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Any P4 program usually starts by including the P4 core library and the
// architecture definition, v1model in this case.
// https://github.com/p4lang/p4c/blob/master/p4include/core.p4
// https://github.com/p4lang/p4c/blob/master/p4include/v1model.p4
#include <core.p4>
#include <v1model.p4>
#include "CONSTANTS.p4"
#include "headers.p4"
#include "parser.p4"
#include "debug.p4"
#include "ingress_queue_depth_monitor.p4"
#include "egress_queue_depth_monitor.p4"
#include "ingress_rate_monitor.p4"
#include "egress_rate_monitor.p4"
#include "int_delay_processor.p4"
#include "upstream_routing.p4"
#include "ndp.p4"
#include "l2_ternary.p4"
#include "my_station.p4"
#include "l2_ternary.p4"
#include "spine_downstream_routing.p4"
#include "cp_assisted_multicriteria_upstream_routing_tables.p4"
#include "cp_assisted_multicriteria_upstream_policy_routing.p4"
#include "metrics_level_calculator.p4"
#include "rate_control.p4"

// *** V1MODEL
//
// V1Model is a P4_16 architecture that defines 7 processing blocks.
//
//   +------+  +------+  +-------+  +-------+  +------+  +------+  +--------+
// ->|PARSER|->|VERIFY|->|INGRESS|->|TRAFFIC|->|EGRESS|->|UPDATE|->+DEPARSER|->
//   |      |  |CKSUM |  |PIPE   |  |MANAGER|  |PIPE  |  |CKSUM |  |        |
//   +------+  +------+  +-------+  +--------  +------+  +------+  +--------+
//
// All blocks are P4 programmable, except for the Traffic Manager, which is
// fixed-function. In the rest of this P4 program, we provide an implementation
// for each one of the 6 programmable blocks.




//------------------------------------------------------------------------------
// 2. CHECKSUM VERIFICATION
//
// Used to verify the checksum of incoming packets.
//------------------------------------------------------------------------------
control VerifyChecksumImpl(inout parsed_headers_t hdr,
                           inout local_metadata_t meta)
{
    // Not used here. We assume all packets have valid checksum, if not, we let
    // the end hosts detect errors.
    apply { /* EMPTY */ }
}
//------------------------------------------------------------------------------
// 3. INGRESS PIPELINE IMPLEMENTATION

//------------------------------------------------------------------------------
control IngressPipeImpl (inout parsed_headers_t    hdr,
                         inout local_metadata_t    local_metadata,
                         inout standard_metadata_t standard_metadata) {

    //======================= All ingress data structures
      @name("egress_queue_depth_value_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) egress_queue_depth_value_map;
          @name("egress_queue_depth_last_update_time_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) egress_queue_depth_last_update_time_map;
          @name("egress_queue_rate_value_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) egress_queue_rate_value_map;
          @name("egress_queue_rate_last_update_time_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) egress_queue_rate_last_update_time_map;
          @name("port_to_port_delay_value_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) port_to_port_delay_value_map;
          @name("port_to_port_delay_last_update_time_map")register<bit<48>>(MAX_PORTS_IN_SWITCH) port_to_port_delay_last_update_time_map;
    //================================This section will contain all isolated actions=======================================
    action process_port_delay_from_p2p_feedback_pkt(){
    //currently this action's functionality is to track the change in delay for a port reported by a peer switch. In future we may add more kind of feedback from peer. on that case we need to add more acrions.
        //port_to_port_delay_value_map.write(hdr.p2p_feedback.port_id, );

        hdr.p2p_feedback.port_id = standard_metadata.ingress_port;
        hdr.p2p_feedback.delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
        hdr.p2p_feedback.delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
        //flowlet_lasttime_map.write((bit<32>)local_metadata.flowlet_map_index, (bit<32>)standard_metadata.ingress_global_timestamp);
    }
    action init_pkt(){
        local_metadata.delay_info_hdr.setValid();
        local_metadata.delay_info_hdr.event_src_type = INVALID;  //This field is for notifying whther an event is hop to hop or came from a hop more than 1 hop distance
        //Next fields are event data
        //bit<16>
        local_metadata.delay_info_hdr.path_delay_event_type = (INVALID);
        local_metadata.delay_info_hdr.path_delay_event_data=(bit<48>)INVALID;
        local_metadata.ingress_queue_event_hdr.setValid();
        local_metadata.ingress_queue_event_hdr.event_src_type= INVALID;  //This field is for notifying whther an event is hop to hop or came from a hop more than 1 hop distance
        //Next fields are event data
        local_metadata.ingress_queue_event_hdr.ingress_queue_event= INVALID;
        local_metadata.ingress_queue_event_hdr.ingress_queue_event_data = (bit<48>)INVALID;
        local_metadata.egress_queue_event_hdr.setValid();
        local_metadata.egress_queue_event_hdr.event_src_type = INVALID;   //This field is for notifying whther an event is hop to hop or came from a hop more than 1 hop distance
        //Next fields are event data
        local_metadata.egress_queue_event_hdr.egress_queue_event= INVALID;
        local_metadata.egress_queue_event_hdr.egress_queue_event_data = (bit<48>)EVENT_EGR_RATE_UNCHANGED;
        local_metadata.ingress_rate_event_hdr.setValid();
        local_metadata.ingress_rate_event_hdr.event_src_type = INVALID;    //This field is for notifying whther an event is hop to hop or came from a hop more than 1 hop distance
        //Next fields are event data
        local_metadata.ingress_rate_event_hdr.ingress_traffic_color = (bit<32>)GREEN;
        local_metadata.ingress_rate_event_hdr.ingress_rate_event_data = (bit<48>)INVALID;
        local_metadata.egress_rate_event_hdr.setValid();
        local_metadata.egress_rate_event_hdr.event_src_type = INVALID;   //This field is for notifying whther an event is hop to hop or came from a hop more than 1 hop distance
        //Next fields are event data
        local_metadata.egress_rate_event_hdr.egress_traffic_color = (bit<32>)GREEN;
        local_metadata.egress_rate_event_hdr.egress_rate_event_data = (bit<48>)INVALID;
        local_metadata.flag_hdr.setValid();
        local_metadata.pkt_timestamp.setValid();
        local_metadata.pkt_timestamp.src_enq_timestamp = standard_metadata.ingress_global_timestamp;
        local_metadata.pkt_timestamp.src_deq_timestamp = standard_metadata.ingress_global_timestamp;

        //========== Flag headers initialization part
        local_metadata.flag_hdr.downstream_routing_table_hit = false;
        local_metadata.flag_hdr.do_l3_l2 = true;
        local_metadata.flag_hdr.is_control_pkt_from_delay_proc = false;  //Initially this packet is not generating a control packet. But later if this field is true, that means a
        //relevant control packet is needed to be sent to Controll plane or other switch.
        local_metadata.flag_hdr.is_control_pkt_from_ing_queue_rate = false;
        local_metadata.flag_hdr.is_control_pkt_from_ing_queue_depth = false;
        local_metadata.flag_hdr.is_control_pkt_from_egr_queue_depth = false;
        local_metadata.flag_hdr.is_control_pkt_from_egr_queue_rate = false;
        local_metadata.flag_hdr.is_dp_only_multipath_algo_processing_required = false;
        local_metadata.flag_hdr.is_fake_ack_for_rate_ctrl_required = false;
        local_metadata.minimum_group_members_requirement=1; //We want to select path from a routing group with non zero memebers. Because a ny group with zero memebers yields the switch processing pipeline
//        local_metadata.flag_hdr.found_multi_criteria_paths = false;
        local_metadata.delay_value_range = 1;
        local_metadata.egr_queue_depth_value_range  = 1;
        local_metadata.egr_port_rate_value_range  = 1;
        ingressPortCounter.count((bit<32>)standard_metadata.ingress_port);
    }
    // Drop action definition, shared by many tables. Hence we define it on top.
   action drop() {
       // Sets an architecture-specific metadata field to signal that the
       // packet should be dropped at the end of this pipeline.
       mark_to_drop(standard_metadata);
   }
    //===Instantiation of control blocks from other p4 files

    #ifdef ENABLE_DEBUG_TABLES
    debug_std_meta() debug_std_meta_ingress_start;
    debug_std_meta() ingress_end_debug;
    #endif  // ENABLE_DEBUG_TABLES

    int_delay_processor() ingress_delay_processor_control_block;
    ingress_queue_depth_monitor() ingress_queue_depth_monitor_control_block;
    ingress_rate_monitor() ingress_rate_monitor_control_block;
    spine_downstream_routing () spine_downstream_routing_control_block;
    l2_ternary_processing() l2_ternary_processing_control_block;
    my_station_processing() my_station_processing_control_block;
    ndp_processing() ndp_processing_control_block;

    //#ifdef DP_ALGO_ECMP
        //upstream_routing() upstream_ecmp_routing_control_block;
        //#endif
    upstream_routing() upstream_ecmp_routing_control_block;
    cp_assisted_multicriteria_upstream_routing_tables() cp_assisted_multicriteria_upstream_routing_control_block;
    cp_assisted_multicriteria_upstream_policy_routing() cp_assisted_multicriteria_upstream_policy_routing_control_block;

    //metrics level calculator tables
    path_delay_metrics_level_calculator() path_delay_metrics_level_calculator_control_block;
    egress_queue_depth_metrics_level_calculator() egress_queue_depth_metrics_level_calculator_control_block;

    // *** APPLY BLOCK STATEMENT
    apply {
    if(hdr.p2p_feedback.isValid()){
        //log_msg("Received p2p feedback from neighbour switch. Need to process the delay here instead of exiting"); //This is a feedback from peer for change in delay found for a port. call
        if(hdr.p2p_feedback.delay_event_type != EVENT_PATH_DELAY_UNCHANGED){
           path_delay_metrics_level_calculator_control_block.apply(hdr, local_metadata, standard_metadata);
        }
        //if (fake ack ) clone to cpu and and original eggress port of the fake ack. this will be selected at routing part. we have to sert a flag. and then in egress clone and forward to both cp
        //and the intended egress port. we do not need to think about the trouble of ingress to egress clone bcz packet content will be same so parsing will create no trouble
        if (hdr.mdn_int.isValid() && (hdr.tcp.ack_control_flag == FLAG_1 )  && (hdr.mdn_int.rate_control_event  == RATE_CONTROL_EVENT_ALREADY_APPLIED)){
           hdr.mdn_int.rate_control_event  = RATE_CONTROL_EVENT_ALREADY_APPLIED ;
           //technically it is do nothing. the else part is important here. This flag will by default stop applying rate control on this packet
           //In rate control we check iff hdr.mdn_int.rate_control_event  != RATE_CONTROL_EVENT_ALREADY_APPLIED --> then we only apply rate control fake ack generation
        }else{
           standard_metadata.egress_spec = CPU_PORT;
           local_metadata.flag_hdr.do_l3_l2 = false; //thie means . this packet doesn;t need normal forwarding processing. It wil only be used for updating the internal routing related information
           exit;
        }
    }else if (hdr.packet_out.isValid()) {
       // Set the egress port to that found in the packet-out metadata...
       standard_metadata.egress_spec = hdr.packet_out.egress_port;
       // Remove the packet-out header...
       hdr.packet_out.setInvalid();
       // Exit the pipeline here, no need to go through other tables.
       exit;
    }else if (hdr.packet_in.isValid() && IS_RECIRCULATED(standard_metadata)) {  //This means this packet is replicated from egress to setup
        //log_msg("Found a recirculated packet");
        local_metadata.flag_hdr.do_l3_l2 = false; //thie means . this packet doesn;t need normal forwarding processing. It wil only be used for updating the internal routing related information
        egress_queue_depth_metrics_level_calculator_control_block.apply(hdr, local_metadata, standard_metadata);
        egress_queue_rate_value_map.write((bit<32>)hdr.packet_in.path_delay_event_port, (bit<48>)local_metadata.egress_rate_event_hdr.egress_traffic_color );
        egress_queue_rate_last_update_time_map.write((bit<32>)hdr.packet_in.path_delay_event_port, standard_metadata.ingress_global_timestamp);
        mark_to_drop(standard_metadata);
    }else{ //This means these packets are normal packets and they will generate the events
        init_pkt();
        ingress_delay_processor_control_block.apply(hdr, local_metadata, standard_metadata);
        ingress_queue_depth_monitor_control_block.apply(hdr, local_metadata, standard_metadata);;
        ingress_rate_monitor_control_block.apply(hdr, local_metadata, standard_metadata);  //TODO we need to make this hash and meter based to adapt with per flow or some policy based admission control
    }

    #ifdef ENABLE_DEBUG_TABLES
    debug_std_meta_ingress_start.apply(hdr, local_metadata, standard_metadata);
    #endif  // ENABLE_DEBUG_TABLES


    if ((hdr.icmpv6.type == ICMP6_TYPE_NS ) && (hdr.icmpv6.type == ICMP6_TYPE_NS)){
       ndp_processing_control_block.apply(hdr, local_metadata, standard_metadata); //This will set the local_metaata.do_l3_l2 field to true if this is a NDP packet
       exit;
    }
    if (local_metadata.flag_hdr.do_l3_l2) {  //this logic checking is unnecessary . WE can remove this
        l2_ternary_processing_control_block.apply(hdr, local_metadata, standard_metadata);  //If it is a local broadcast packet we have to process it. but for spine and superspine we d not need it
        //my_station_processing_control_block.apply(hdr, local_metadata, standard_metadata);
        if (hdr.ipv6.isValid()) {
            spine_downstream_routing_control_block.apply(hdr, local_metadata, standard_metadata);
            if(local_metadata.flag_hdr.downstream_routing_table_hit){
                //if (local_metadata.m_color >1) {drop();}
                if(hdr.ipv6.hop_limit == 0) { drop(); }
            }else{
            //Route the packet to upstream paths
            local_metadata.flag_hdr.found_multi_criteria_paths = true;
            #ifdef DP_ALGO_ECMP
            local_metadata.flag_hdr.found_multi_criteria_paths = false; // this means we must need to use ecmp path
            #endif
            cp_assisted_multicriteria_upstream_routing_control_block.apply(hdr, local_metadata, standard_metadata);
            cp_assisted_multicriteria_upstream_policy_routing_control_block.apply(hdr, local_metadata, standard_metadata);
            // this bool fields ensure that we do same processing for all algorithm and when ecmp is used we use ecmp path and if no policy path is found then se ecmp path
            bool found_multi_criteria_paths = (local_metadata.flag_hdr.found_multi_criteria_paths) &&
                        (local_metadata.flag_hdr.found_egr_queue_depth_based_path || local_metadata.flag_hdr.found_egr_queue_rate_based_path ||
                         local_metadata.flag_hdr.found_path_delay_based_path);
            if ( found_multi_criteria_paths == false){ // this means in multicriteria table we have not found any paths. This may be due to lack of proper traffic class or IP predix in those tables
                upstream_ecmp_routing_control_block.apply(hdr, local_metadata, standard_metadata);
            }
            //log_msg("egress spec is {} and egress port is {}",{standard_metadata.egress_spec , standard_metadata.egress_port});
            }
        }
    }else{
             //This means. this packet is recevied wither from peer switches or from egress. And these packets will be used for uodating the internal routing informaitons
     }


    #ifdef ENABLE_DEBUG_TABLES
    ingress_end_debug.apply(hdr, local_metadata, standard_metadata);
    #endif  // ENABLE_DEBUG_TABLES
    }
}

//------------------------------------------------------------------------------
// 4. EGRESS PIPELINE
//
// In the v1model architecture, after the ingress pipeline, packets are
// processed by the Traffic Manager, which provides capabilities such as
// replication (for multicast or clone sessions), queuing, and scheduling.
//
// After the Traffic Manager, packets are processed by a so-called egress
// pipeline. Differently from the ingress one, egress tables can match on the
// egress_port intrinsic metadata as set by the Traffic Manager. If the Traffic
// Manager is configured to replicate the packet to multiple ports, the egress
// pipeline will see all replicas, each one with its own egress_port value.
//
// +---------------------+     +-------------+        +----------------------+
// | INGRESS PIPE        |     | TM          |        | EGRESS PIPE          |
// | ------------------- | pkt | ----------- | pkt(s) | -------------------- |
// | Set egress_spec,    |---->| Replication |------->| Match on egress port |
// | mcast_grp, or clone |     | Queues      |        |                      |
// | sess                |     | Scheduler   |        |                      |
// +---------------------+     +-------------+        +----------------------+
//
// Similarly to the ingress pipeline, the egress one operates on the parsed
// headers (hdr), the user-defined metadata (local_metadata), and the
// architecture-specific instrinsic one (standard_metadata) which now
// defines a read-only "egress_port" field.
//------------------------------------------------------------------------------
control EgressPipeImpl (inout parsed_headers_t hdr,
                        inout local_metadata_t local_metadata,
                        inout standard_metadata_t standard_metadata) {

    //=========Actions
    action set_all_header_invalid(){
        hdr.packet_out.setInvalid();
        hdr.packet_in.setInvalid();
        hdr.ethernet.setInvalid();
        hdr.ipv4.setInvalid();
        hdr.ipv6.setInvalid();
        hdr.mdn_int.setInvalid();
        hdr.p2p_feedback.setInvalid();
        hdr.tcp.setInvalid();
        hdr.udp.setInvalid();
        hdr.icmpv6.setInvalid();
        hdr.ndp.setInvalid();
        //hdr.delay_event_feedback.setInvalid();
    }
    action build_p2p_feedback_only(){
        hdr.p2p_feedback.setValid();
        bit<8> temp_next_hdr =   hdr.ipv6.next_hdr;
        hdr.ipv6.next_hdr = CONTROL_PACKET;
        hdr.p2p_feedback.next_hdr = temp_next_hdr;
        hdr.p2p_feedback.port_id = local_metadata.delay_info_hdr.path_delay_event_port;
        hdr.p2p_feedback.delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
        hdr.p2p_feedback.delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
        hdr.mdn_int.setInvalid();
    }
    action build_p2p_feedback_with_fake_ack(){
        hdr.p2p_feedback.setValid();
        bit<8> temp_next_hdr =   hdr.ipv6.next_hdr;
        hdr.ipv6.next_hdr = CONTROL_PACKET;
        hdr.p2p_feedback.port_id = local_metadata.delay_info_hdr.path_delay_event_port;
        hdr.p2p_feedback.delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
        hdr.p2p_feedback.delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
        hdr.p2p_feedback.next_hdr = MDN_INT;
        hdr.mdn_int.setValid();
        //mdn_int values are already set
        hdr.mdn_int.next_hdr = temp_next_hdr;

        hdr.tcp.ack_control_flag = FLAG_1 ;
        bit<128> temp_src_addr = hdr.ipv6.src_addr;
        hdr.ipv6.src_addr = hdr.ipv6.dst_addr;
        hdr.ipv6.dst_addr = temp_src_addr;
        hdr.ipv6.payload_len = 20; //Only the length of tcop header
        // now tcp header eschange
        bit<16> temp_src_port = hdr.tcp.src_port;
        hdr.tcp.src_port = hdr.tcp.dst_port;
        hdr.tcp.dst_port = temp_src_port;
        bit<32>  temp_ack_no = hdr.tcp.ack_no;
        hdr.tcp.ack_no = hdr.tcp.seq_no + 1;
        hdr.tcp.seq_no = temp_ack_no; // this means we are sending the seq number what the sender have acknowledged. that means no new data
        // REst of the fields are find. Just need  calculate the ipv6.payload_len
        bit<16>  new_window = hdr.tcp.window >>WINDOW_DECREASE_RATIO;
        hdr.tcp.window  = hdr.tcp.window - new_window;
        hdr.mdn_int.rate_control_event  = RATE_CONTROL_EVENT_ALREADY_APPLIED ;
        hdr.ipv6.ecn = 3;
    }
    action build_p2p_feedback_with_fake_ack_for_increase(){
            hdr.p2p_feedback.setValid();
            bit<8> temp_next_hdr =   hdr.ipv6.next_hdr;
            hdr.ipv6.next_hdr = CONTROL_PACKET;
            hdr.p2p_feedback.port_id = local_metadata.delay_info_hdr.path_delay_event_port;
            hdr.p2p_feedback.delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
            hdr.p2p_feedback.delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
            hdr.p2p_feedback.next_hdr = MDN_INT;
            hdr.mdn_int.setValid();
            //mdn_int values are already set
            hdr.mdn_int.next_hdr = temp_next_hdr;

            hdr.tcp.ack_control_flag = FLAG_1 ;
            bit<128> temp_src_addr = hdr.ipv6.src_addr;
            hdr.ipv6.src_addr = hdr.ipv6.dst_addr;
            hdr.ipv6.dst_addr = temp_src_addr;
            hdr.ipv6.payload_len = 20; //Only the length of tcop header
            // now tcp header eschange
            bit<16> temp_src_port = hdr.tcp.src_port;
            hdr.tcp.src_port = hdr.tcp.dst_port;
            hdr.tcp.dst_port = temp_src_port;
            bit<32>  temp_ack_no = hdr.tcp.ack_no;
            hdr.tcp.ack_no = hdr.tcp.seq_no + 1;
            hdr.tcp.seq_no = temp_ack_no; // this means we are sending the seq number what the sender have acknowledged. that means no new data
            // REst of the fields are find. Just need  calculate the ipv6.payload_len
            bit<16>  new_window = hdr.tcp.window >>WINDOW_INCREASE_RATIO;
            hdr.tcp.window  = hdr.tcp.window + new_window;
            hdr.mdn_int.rate_control_event  = RATE_CONTROL_EVENT_ALREADY_APPLIED ;
        }
    //========================
    #ifdef ENABLE_DEBUG_TABLES
    debug_std_meta() debug_std_meta_egress_start;
    #endif  // ENABLE_DEBUG_TABLES
    egress_rate_monitor() egress_rate_monitor_control_block;
    egress_queue_depth_monitor() egress_queue_depth_monitor_control_block;
    #ifdef DP_BASED_RATE_CONTROL_ENABLED
    spine_rate_control_processor() spine_rate_control_processor_control_block;
    #endif
    apply {
        //if (local_metadata.is_multicast == true &&
        //      standard_metadata.ingress_port == standard_metadata.egress_port) {
        //    mark_to_drop(standard_metadata);
        //}
        bool is_recirculation_needed = false;

        // we can only do these stuuffs if this packet is a normal packet .
        if(IS_NORMAL(standard_metadata)){

            egress_queue_depth_monitor_control_block.apply(hdr, local_metadata, standard_metadata);
            egress_rate_monitor_control_block.apply(hdr, local_metadata, standard_metadata);

            #ifdef DP_BASED_RATE_CONTROL_ENABLED
            spine_rate_control_processor_control_block.apply(hdr, local_metadata, standard_metadata);
            #elif  DP_ALGO_ECMP
            if(standard_metadata.deq_qdepth > ECN_THRESHOLD) hdr.ipv6.ecn = 3; //setting ecm mark
            #endif
            if (local_metadata.is_multicast == true ) {
                exit;
            }
            #ifdef DP_ALGO_CP_ASSISTED_POLICY_ROUTING
            if(IS_RECIRC_NEEDED(local_metadata)) {
                is_recirculation_needed = true;
            }
            #endif

            //TODO : if everything goes ok. We can convert this if-else to a single MAT
            if(is_recirculation_needed){
                //log_msg("is_recirculation_needed value is true");
            }else{
                //log_msg("is_recirculation_needed value is false");
            }
            if(is_recirculation_needed &&   IS_CONTROL_PKT_TO_NEIGHBOUR(local_metadata) && IS_CONTROL_PKT_TO_CP(local_metadata)){
                //log_msg("clone to session id  ing_port + Max_port * 2 --> this have both ingress port and CPU port and recirculation port");
                clone3(CloneType.E2E, (bit<32>)(standard_metadata.ingress_port)+ ((bit<32>)MAX_PORTS_IN_SWITCH * 2), {standard_metadata, local_metadata});
            }else if(  IS_CONTROL_PKT_TO_NEIGHBOUR(local_metadata) && IS_CONTROL_PKT_TO_CP(local_metadata)){
                //log_msg("clone to session id ing_port + Max_port  --> this have both ingress port and CPU port");
                clone3(CloneType.E2E, (bit<32>)(standard_metadata.ingress_port)+ (bit<32>)MAX_PORTS_IN_SWITCH, {standard_metadata, local_metadata});
            }else if (IS_CONTROL_PKT_TO_CP(local_metadata)) {
                //log_msg("clone to CPU port only");
                clone3(CloneType.E2E, CPU_CLONE_SESSION_ID, {standard_metadata, local_metadata});
            }else if ( IS_CONTROL_PKT_TO_NEIGHBOUR(local_metadata)) {
                 //log_msg("clone to ingress port for feedback to neighbour");
                 clone3(CloneType.E2E, (bit<32>)(standard_metadata.ingress_port), {standard_metadata, local_metadata});
            }else{
                //log_msg("Unhandled logic in cloning control block");
            }
        }
        // ENABLE_DEBUG_TABLES
        #ifdef ENABLE_DEBUG_TABLES
        debug_std_meta_egress_start.apply(hdr, local_metadata, standard_metadata);
        #endif


        if(IS_NORMAL(standard_metadata)){
            egressPortCounter.count((bit<32>)standard_metadata.egress_port);
            if (standard_metadata.egress_port == PORT_ZERO) {
                //log_msg("A normal packet  is decided to be sent on port 0. Which should not be. Debug it"); //this was happening due to lack of defualt path in policy riouting
                recirculate<parsed_headers_t>(hdr);
                mark_to_drop(standard_metadata);
            }else if (standard_metadata.egress_port == CPU_PORT) {  //not reaching this part
                //log_msg("This is a p2p feedback received from some neighbour swithc. and sending it to CP");
                // Add packet_in header and set relevant fields, such as the
                // switch ingress port where the packet was received.
                set_all_header_invalid();
                hdr.packet_in.setValid();
                //hdr.dp_to_cp_feedback_hdr.setValid();
                hdr.packet_in.ingress_port = standard_metadata.ingress_port;
                //log_msg("Found msg for CP from created by p2p feedback ingress port {} with delay event type {}",{standard_metadata.ingress_port, local_metadata.delay_info_hdr.path_delay_event_type});
                //===
                hdr.packet_in.ingress_queue_event = local_metadata.ingress_queue_event_hdr.ingress_queue_event;
                hdr.packet_in.ingress_queue_event_data = local_metadata.ingress_queue_event_hdr.ingress_queue_event_data ;
                hdr.packet_in.ingress_queue_event_port =local_metadata.ingress_queue_event_hdr.ingress_queue_event_port;
                //===
                hdr.packet_in.egress_queue_event = local_metadata.egress_queue_event_hdr.egress_queue_event ;
                hdr.packet_in.egress_queue_event_data = local_metadata.egress_queue_event_hdr.egress_queue_event_data  ;
                hdr.packet_in.egress_queue_event_port = local_metadata.egress_queue_event_hdr.egress_queue_event_port;
                //===
                hdr.packet_in.ingress_traffic_color = local_metadata.ingress_rate_event_hdr.ingress_traffic_color  ;
                hdr.packet_in.ingress_rate_event_data = local_metadata.ingress_rate_event_hdr.ingress_rate_event_data  ;
                hdr.packet_in.ingress_rate_event_port = local_metadata.ingress_rate_event_hdr.ingress_rate_event_port;
                //===
                hdr.packet_in.egress_traffic_color = local_metadata.egress_rate_event_hdr.egress_traffic_color  ;
                //log_msg("In cp feedback msg. egress traffic color is {}",{hdr.packet_in.egress_traffic_color});
                hdr.packet_in.egress_rate_event_data = local_metadata.egress_rate_event_hdr.egress_rate_event_data  ;
                hdr.packet_in.egress_rate_event_port = local_metadata.egress_rate_event_hdr.egress_rate_event_port;
                //============
                hdr.packet_in.path_delay_event_type = hdr.p2p_feedback.delay_event_type ;
                hdr.packet_in.path_delay_event_data = hdr.p2p_feedback.delay_event_data;
                hdr.packet_in.dst_addr = local_metadata.delay_info_hdr.dst_addr;
                hdr.packet_in.path_delay_event_port =  local_metadata.delay_info_hdr.path_delay_event_port;
                ctrlPktToCPCounter.count((bit<32>)standard_metadata.egress_port);
            }else{

                //log_msg("Egress_log: Before sending a packet from leaf switch to non host neighbour. So adding the delay header{} {}", {hdr.ipv6.next_hdr, hdr.mdn_int.next_hdr});
                hdr.mdn_int.setValid();
               // bit<8> temp_next_hdr =   hdr.ipv6.next_hdr;
                //hdr.ipv6.next_hdr = MDN_INT;
                hdr.mdn_int.src_enq_timestamp = local_metadata.pkt_timestamp.src_enq_timestamp;
                hdr.mdn_int.src_deq_timestamp = local_metadata.pkt_timestamp.src_deq_timestamp;
                //hdr.mdn_int.next_hdr = temp_next_hdr;
                //log_msg("Egress_log: After sending a packet from leaf switch to non host neighbour. So adding the delay header{} {}", {hdr.ipv6.next_hdr, hdr.mdn_int.next_hdr});
            }
        }else{ //this is a cloned packet for control events PORT_ZERO
            if (standard_metadata.egress_port == PORT_ZERO) {
                set_all_header_invalid();
                hdr.ethernet.setValid();
                hdr.ethernet.ether_type = 0;
                hdr.packet_in.setValid();
                                //hdr.dp_to_cp_feedback_hdr.setValid();
                hdr.packet_in.ingress_port = standard_metadata.ingress_port;

                //===
                hdr.packet_in.ingress_queue_event = local_metadata.ingress_queue_event_hdr.ingress_queue_event;
                hdr.packet_in.ingress_queue_event_data = local_metadata.ingress_queue_event_hdr.ingress_queue_event_data ;
                hdr.packet_in.ingress_queue_event_port =local_metadata.ingress_queue_event_hdr.ingress_queue_event_port;
                //===
                hdr.packet_in.egress_queue_event = local_metadata.egress_queue_event_hdr.egress_queue_event ;
                hdr.packet_in.egress_queue_event_data = local_metadata.egress_queue_event_hdr.egress_queue_event_data  ;
                hdr.packet_in.egress_queue_event_port = local_metadata.egress_queue_event_hdr.egress_queue_event_port;
                //===
                hdr.packet_in.ingress_traffic_color = local_metadata.ingress_rate_event_hdr.ingress_traffic_color  ;
                hdr.packet_in.ingress_rate_event_data = local_metadata.ingress_rate_event_hdr.ingress_rate_event_data  ;
                hdr.packet_in.ingress_rate_event_port = local_metadata.ingress_rate_event_hdr.ingress_rate_event_port;
                //===
                hdr.packet_in.egress_traffic_color = local_metadata.egress_rate_event_hdr.egress_traffic_color  ;
                //log_msg("In cp feedback msg. egress traffic color is {}",{hdr.packet_in.egress_traffic_color});
                hdr.packet_in.egress_rate_event_data = local_metadata.egress_rate_event_hdr.egress_rate_event_data  ;
                hdr.packet_in.egress_rate_event_port = local_metadata.egress_rate_event_hdr.egress_rate_event_port;
                //============
                hdr.packet_in.path_delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
                hdr.packet_in.path_delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
                hdr.packet_in.dst_addr = local_metadata.delay_info_hdr.dst_addr;
                hdr.packet_in.path_delay_event_port =  local_metadata.delay_info_hdr.path_delay_event_port;
                recirculate<parsed_headers_t>(hdr);
                //log_msg("A cloned packet is being recirculated");
            }else if (standard_metadata.egress_port == CPU_PORT) {
                // Add packet_in header and set relevant fields, such as the
                // switch ingress port where the packet was received.
                set_all_header_invalid();
                hdr.packet_in.setValid();
                //hdr.dp_to_cp_feedback_hdr.setValid();
                hdr.packet_in.ingress_port = standard_metadata.ingress_port;
                // Exit the pipeline here.
                //log_msg("Found msg for CP from ingress port {} with delay event type {}",{standard_metadata.ingress_port, local_metadata.delay_info_hdr.path_delay_event_type});
                    //===
                    hdr.packet_in.ingress_queue_event = local_metadata.ingress_queue_event_hdr.ingress_queue_event;
                    hdr.packet_in.ingress_queue_event_data = local_metadata.ingress_queue_event_hdr.ingress_queue_event_data ;
                    hdr.packet_in.ingress_queue_event_port =local_metadata.ingress_queue_event_hdr.ingress_queue_event_port;
                    //===
                    hdr.packet_in.egress_queue_event = local_metadata.egress_queue_event_hdr.egress_queue_event ;
                    hdr.packet_in.egress_queue_event_data = local_metadata.egress_queue_event_hdr.egress_queue_event_data  ;
                    hdr.packet_in.egress_queue_event_port = local_metadata.egress_queue_event_hdr.egress_queue_event_port;
                    //===
                    hdr.packet_in.ingress_traffic_color = local_metadata.ingress_rate_event_hdr.ingress_traffic_color  ;
                    hdr.packet_in.ingress_rate_event_data = local_metadata.ingress_rate_event_hdr.ingress_rate_event_data  ;
                    hdr.packet_in.ingress_rate_event_port = local_metadata.ingress_rate_event_hdr.ingress_rate_event_port;
                    //===
                    hdr.packet_in.egress_traffic_color = local_metadata.egress_rate_event_hdr.egress_traffic_color  ;
                    //log_msg("In cp feedback msg. egress traffic color is {}",{hdr.packet_in.egress_traffic_color});
                    hdr.packet_in.egress_rate_event_data = local_metadata.egress_rate_event_hdr.egress_rate_event_data  ;
                    hdr.packet_in.egress_rate_event_port = local_metadata.egress_rate_event_hdr.egress_rate_event_port;
                    //============
                    hdr.packet_in.path_delay_event_type = local_metadata.delay_info_hdr.path_delay_event_type ;
                    hdr.packet_in.path_delay_event_data = local_metadata.delay_info_hdr.path_delay_event_data;
                    hdr.packet_in.dst_addr = local_metadata.delay_info_hdr.dst_addr;
                    hdr.packet_in.path_delay_event_port =  local_metadata.delay_info_hdr.path_delay_event_port;

                ////log_msg("chceking feedback values{}", {local_metadata});
            }else{
                //log_msg("This is a peer to peer feedback message in cloned part (for fake ack). At this moment only add delay feedback and feedback ACK. Later we may add more stuffs");
                p2pFeedbackCounter.count((bit<32>)standard_metadata.egress_port);
                #ifdef DP_BASED_RATE_CONTROL_ENABLED
                if (hdr.mdn_int.isValid()   && (hdr.mdn_int.rate_control_event  == RATE_DECREASE_EVENT_NEED_TO_BE_APPLIED_IN_THIS_SWITCH)){
                    build_p2p_feedback_with_fake_ack();
                }else{
                    build_p2p_feedback_only();
                }
                if (hdr.mdn_int.isValid()   && (hdr.mdn_int.rate_control_event  == RATE_INCREASE_EVENT_NEED_TO_BE_APPLIED_IN_THIS_SWITCH)){
                    build_p2p_feedback_with_fake_ack_for_increase();
                }else{
                    build_p2p_feedback_only();
                }
                #else
                build_p2p_feedback_only();
                #endif

            }
        }



    }
}

//------------------------------------------------------------------------------
// 5. CHECKSUM UPDATE
//
// Provide logic to update the checksum of outgoing packets.
//------------------------------------------------------------------------------
control ComputeChecksumImpl(inout parsed_headers_t hdr,
                            inout local_metadata_t local_metadata)
{
    apply {
        // The following function is used to update the ICMPv6 checksum of NDP
        // NA packets generated by the ndp_reply_table in the ingress pipeline.
        // This function is executed only if the NDP header is present.
        update_checksum(hdr.ndp.isValid(),
            {
                hdr.ipv6.src_addr,
                hdr.ipv6.dst_addr,
                hdr.ipv6.payload_len,
                8w0,
                hdr.ipv6.next_hdr,
                hdr.icmpv6.type,
                hdr.icmpv6.code,
                hdr.ndp.flags,
                hdr.ndp.target_ipv6_addr,
                hdr.ndp.type,
                hdr.ndp.length,
                hdr.ndp.target_mac_addr
            },
            hdr.icmpv6.checksum,
            HashAlgorithm.csum16
        );
    }
}


//------------------------------------------------------------------------------
// 6. DEPARSER
//
// This is the last block of the V1Model architecture. The deparser specifies in
// which order headers should be serialized on the wire. When calling the emit
// primitive, only headers that are marked as "valid" are serialized, otherwise,
// they are ignored.
//------------------------------------------------------------------------------
control DeparserImpl(packet_out packet, in parsed_headers_t hdr) {
    apply {
        packet.emit(hdr.packet_in);
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv6);
        packet.emit(hdr.mdn_int);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
        packet.emit(hdr.icmpv6);
        packet.emit(hdr.ndp);
    }
}

//------------------------------------------------------------------------------
// V1MODEL SWITCH INSTANTIATION
//
// Finally, we instantiate a v1model switch with all the control block
// instances defined so far.
//------------------------------------------------------------------------------
V1Switch(
    ParserImpl(),
    VerifyChecksumImpl(),
    IngressPipeImpl(),
    EgressPipeImpl(),
    ComputeChecksumImpl(),
    DeparserImpl()
) main;