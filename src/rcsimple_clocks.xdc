set_clock_groups -asynchronous -group [get_clocks -of_objects [get_ports icape2_clk]] -group [get_clocks -of_objects [get_ports AXI_aclk]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_ports AXI_aclk]] -group [get_clocks -of_objects [get_ports icape2_clk]]
set_false_path -to [get_pins -hier *cdc*/D]
