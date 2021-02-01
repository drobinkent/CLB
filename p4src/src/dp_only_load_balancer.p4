
#include <core.p4>

#include <v1model.p4>
#include "CONSTANTS.p4"
#include "headers.p4"
#include "parser.p4"



control dp_only_load_balancing(inout parsed_headers_t    hdr,
                        inout local_metadata_t    local_metadata,
                        inout standard_metadata_t standard_metadata)
{


    action weight_group_finder_action_without_param() {
        local_metadata.link_location_index =0;
        local_metadata.flag_hdr.found_multi_criteria_paths = false;
    }
    action weight_group_finder_action_with_param(bit<32> link_location_index) {
        local_metadata.link_location_index = link_location_index;
        local_metadata.flag_hdr.found_multi_criteria_paths = true;
    }

    table weight_group_finder_mat {
        key = {
            local_metadata.packet_bitmask: ternary;

        }
        actions = {
            weight_group_finder_action_without_param;
            weight_group_finder_action_with_param;
        }
        default_action = weight_group_finder_action_without_param;
        //implementation = delay_based_upstream_path_selector;
        //@name("delay_based_upstream_path_table_counter")
        //counters = direct_counter(CounterType.packets_and_bytes);
    }
    apply {
         {
            // process normal data packet here
            log_msg("LB: the message is not a valid control packet");
            bit<32> load_counter_value = 0;
            bit<32> load_counter_level = 0;
            load_counter.read(load_counter_value, 0); //Read the only value. only one index one value
            // Devide by the precision scaler. Precision Scaler will be provided at compile time
            load_counter_level = load_counter_value >> PRECISION_FACTOR;
            //load_counter_value = (load_counter_value + 1) % 16;
            load_counter_value = (load_counter_value + 1) ;
            load_counter.write(0, load_counter_value); //Write back the counter value after increasing
            log_msg("LB: Counter Value is {}", {load_counter_value});

            log_msg("LB: Counter level is {}", {load_counter_level});
            //Find the position and index --> right most
            local_metadata.packet_bitmask_shift_times = load_counter_level[ BITMASK_POSITION_INDICATOR_BITS_LENGTH - 1 : 0 ] -1;
            log_msg("LB: All 1 bitmask will be left shifted  {} times ", {local_metadata.packet_bitmask_shift_times});
            //Read from the memory the distribution mask
            bit<BITMASK_LENGTH> stored_bitmask_read_value = 0;
            stored_bitmask.read(stored_bitmask_read_value, (bit<32>)0);  //We are reading the 0th entry because we are testing with only 32 bit system
            log_msg("LB: Loaded value sis {}", {stored_bitmask_read_value});
            //Do and
            bit<32> temp1 =ALL_ONE_BIT_MASK << local_metadata.packet_bitmask_shift_times;
            log_msg("LB: all 1 bit bitmask value ofter left shifting is {} ", {temp1});
            local_metadata.packet_bitmask = temp1[ BITMASK_LENGTH - 1 : 0 ] & stored_bitmask_read_value[ BITMASK_LENGTH - 1 : 0 ];
            log_msg("LB: packet bitmask is {}", {local_metadata.packet_bitmask});
            // Now local_metadata.packet_bitmask_array_index and local_metadata.packet_bitmask  will be matched with MAT
            weight_group_finder_mat.apply();
            bit<32> temp =0;
            log_msg("LB: Link location index is {}", {local_metadata.link_location_index});
            level_to_link_store.read(temp, (bit<32>)local_metadata.link_location_index);
            standard_metadata.egress_spec =  (bit<9>) temp; //Here we are assigning port. If instead of port somoene uses server ID they can do their customized casting.
            log_msg("LB: selected link is {}", {temp});
         }
    }
}











