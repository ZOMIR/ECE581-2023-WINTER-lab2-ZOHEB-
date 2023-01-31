if { [info exists synopsys_program_name ] && ($synopsys_program_name == "icc2_shell") } {
    puts " Creating ICC2 MCMM "
    create_mode func
    create_corner slow
    create_scenario -mode func -corner slow -name func_slow
    current_scenario func_slow
    set_operating_conditions ss0p75v125c
    set_operating conditions ss0p75v125c_i0p75v
    read_parasitic_tech -tlup $tlu_dir/saed32nm_1p9m_Cmax.tluplus -layermap $tlu_dir/saed32nm_tf_itf_tluplus.map -name Cmax
    read_parasitic_tech -tlup $tlu_dir/saed32nm_1p9m_Cmin.tluplus -layermap $tlu_dir/saed32nm_tf_itf_tluplus.map -name Cmin
    set_parasitic_parameters -early_spec Cmax -early_temperature 125
    set_parasitic_parameters -late_spec Cmax -late_temperature 125
    #set_parasitic_parameters -early_spec 1p9m_Cmax -early_temperature 125 -corner default
    #set_parasitic_parameters -late_spec 1p9m_Cmax -late_temperature 125 -corner default

    #set_scenario_status  default -active false
    set_scenario_status func_slow -active true -hold true -setup true
}
set wclk_period 1.05
set rclk_period 0.98
set wclk2x_period [ expr $wclk_period / 2 ]

create_clock -name "wclk" -period $wclk_period  wclk

create_clock -name "rclk" -period $rclk_period rclk

#Add the new clock.  Make it 1/2 the wclk period since it is called wclk2x
create_clock -name "wclk2x" -period $wclk2x_period wclk2x

set_false_path -from [get_clocks wclk ] -to [get_clocks rclk]
set_false_path -from [get_clocks rclk ] -to [ get_clocks wclk]

# Add input/output delays in relation to related clocks
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[7]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[6]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[5]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[4]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[3]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[2]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[1]}]
set_input_delay -clock wclk2x 0.23 [get_ports {wdata_in[0]}]
set_input_delay -clock wclk 0.46 [get_ports {winc}]
set_input_delay -clock rclk 0.45 [get_ports {rinc}]

set_output_delay -clock rclk 0.45 [get_ports {rdata[7]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[6]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[5]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[4]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[3]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[2]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[1]}]
set_output_delay -clock rclk 0.45 [get_ports {rdata[0]}]
set_output_delay -clock rclk 0.45 [get_ports {rempty}]
set_output_delay -clock wclk 0.46 [get_ports {wfull}]


# driving cell
#set_driving_cell -lib_cell NBUFFX4_RVT [get_ports -filter "direction==in&&full_name!~*clk*"]
set_drive 0.00001 [ get_ports -filter "direction==in&&full_name!~*clk*"]
# Can tell the related clock by doing report_timing -group INPUTS  or -group OUTPUTS after using group_path
# External delay should be some percentage of clock period.
# Tune/relax if violating; most concerned about internal paths.

#clock details
et_clock_uncertainty -setup 4 rclk
set_clock_uncertainty -hold 1 rclk
set_clock_latency 0.17 rclk
set_clock_transition 0.17 rclk 

set_clock_uncertainty -setup 0.07 wclk
set_clock_uncertainty -hold 0.01 wclk
set_clock_latency 0.17 wclk
set_clock_transition 0.17 wclk 

set_clock_uncertainty -setup 0.07 wclk2x
set_clock_uncertainty -hold 0.017 wclk2x
set_clock_latency 0.17 wclk2x
set_clock_transition 0.17 wclk2x 

# I like set_driving_cell to a std cell from the library.  set_drive works to.

# set_load
set_load 0.4 [ get_ports -filter "direction==out" ]
#group_path -name INTERNAL -from [all_clocks] -to [all_clocks ]
group_path -name INPUTS -from [ get_ports -filter "direction==in&&full_name!~*clk*"]
group_path -name OUTPUTS -to [ get_ports -filter "direction==out" ]

