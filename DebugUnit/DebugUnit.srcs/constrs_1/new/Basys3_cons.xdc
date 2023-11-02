
# Configure I/O Bank 0 for 1.8V operation
set_property CONFIG_VOLTAGE 3.3 [current_design];
# Configure I/O Bank 0 for 3.3V/2.5V operation
set_property CFGBVS VCCO [current_design];

# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clock_fromPin]							
	set_property IOSTANDARD LVCMOS33 [get_ports i_clock_fromPin]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_clock_fromPin]
 
 
set_property PACKAGE_PIN T17 [get_ports i_reset_fromPin]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_reset_fromPin]
	
set_property PACKAGE_PIN T18 [get_ports i_halt_just4tb]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_halt_just4tb]

##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports i_rx_fromPin]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_rx_fromPin]
set_property PACKAGE_PIN A18 [get_ports o_tx_fromPin]						
	set_property IOSTANDARD LVCMOS33 [get_ports o_tx_fromPin]
  
