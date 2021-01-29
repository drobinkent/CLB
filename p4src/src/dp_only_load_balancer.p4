
#include <core.p4>

#include <v1model.p4>
#include "CONSTANTS.p4"
#include "headers.p4"
#include "parser.p4"



control dp_only_load_balancing(inout parsed_headers_t    hdr,
                        inout local_metadata_t    local_metadata,
                        inout standard_metadata_t standard_metadata)
{
    @name("load_counter")register<bit<32>>(1) load_counter;
    @name("bitmask_array")register<bit<BITMASK_LENGTH>>(BITMASK_ARRAY_LENGTH) bitmask_array;
    @name("level_to_link_store")register<bit<32>>(BITMASK_ARRAY_LENGTH) level_to_link_store;

    action nearest_level_finder_mat_action_without_param() {
        local_metadata.link_location_index =0;
    }
    action nearest_level_finder_mat_action_with_param(bit<32> link_location_index) {
        local_metadata.link_location_index = link_location_index;
    }

    table nearest_level_finder_mat {
        key = {
            local_metadata.packet_bitmask_array_index: exact;
            local_metadata.packet_bitmask: ternary;

        }
        actions = {
            nearest_level_finder_mat_action_without_param;
            nearest_level_finder_mat_action_with_param;
        }
        default_action = nearest_level_finder_mat_action_without_param;
        //implementation = delay_based_upstream_path_selector;
        //@name("delay_based_upstream_path_table_counter")
        //counters = direct_counter(CounterType.packets_and_bytes);
    }
    apply {
         if (hdr.packet_out.isValid()) {
            //process control packet here -- header format for ctrtIn --> counterReset= yes or no,
            if(hdr.packet_out.clb_flags[7:7] == (bit<1>)1){
                bit<32> load_counter_value = 0;
                load_counter.write(0, load_counter_value); //Reset the counter
            }
            if(hdr.packet_out.clb_flags[6:6] == (bit<1>)1){ //This is a delete packet
                bitmask_array.write( (bit<32>)(hdr.packet_out.bitmask_array_index), hdr.packet_out.bitmask[BITMASK_LENGTH - 1 :0]);
                level_to_link_store.write(hdr.packet_out.link_id, (bit<32>)hdr.packet_out.level_to_link_id_store_index);

            }if(hdr.packet_out.clb_flags[5:5] == (bit<1>)1){ //This is an insert packet
                bitmask_array.write( (bit<32>)(hdr.packet_out.bitmask_array_index), hdr.packet_out.bitmask[BITMASK_LENGTH - 1 :0]);
                level_to_link_store.write(hdr.packet_out.link_id, (bit<32>)hdr.packet_out.level_to_link_id_store_index);
            }

         }else{
            // process normal data packet here
            bit<32> load_counter_value = 0;
            load_counter.read(load_counter_value, 0); //Read the only value. only one index one value
            load_counter_value = load_counter_value + 1;
            load_counter.write(0, load_counter_value); //Write back the counter value after increasing
            //TODO : Devide by the precision scaler. Precision Scaler will be provided at compile time
            //Find the position and index --> right most
            local_metadata.packet_bitmask = load_counter_value[ BITMASK_LENGTH - 1 : 0 ];
            local_metadata.packet_bitmask_array_index = load_counter_value[ BITMASK_LENGTH + BITMASK_ARRAY_INDEX_INDICATOR_BITS_LENGTH-1 : BITMASK_LENGTH ];
            //Read from the memory the distribution mask
            bit<BITMASK_LENGTH> stored_bitmask = 0;
            bitmask_array.read(stored_bitmask, (bit<32>)(local_metadata.packet_bitmask_array_index));
            //Do and
            local_metadata.packet_bitmask = local_metadata.packet_bitmask & stored_bitmask;
            // Now local_metadata.packet_bitmask_array_index and local_metadata.packet_bitmask  will be matched with MAT
            nearest_level_finder_mat.apply();
            bit<32> temp =0;
            level_to_link_store.read(temp, (bit<32>)local_metadata.link_location_index);
            standard_metadata.egress_spec =  (bit<9>) temp; //Here we are assigning port. If instead of port somoene uses server ID they can do their customized casting.
         }
    }
}











