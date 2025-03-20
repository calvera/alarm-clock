# Primary input clock
create_clock -name "clk_in" -period 20.000 [get_ports {clk_in}]

# Generated clock for PLL output
derive_pll_clocks -create_base_clocks

# Create generated clock for counting_clock (refresh)
create_generated_clock -name "refresh_clk" -divide_by 8 \
    -source [get_pins {pll_inst|*|clk[0]}] \
    [get_registers {refresh|count_reg[*]}]

# Create generated clock for 1Hz clock
create_generated_clock -name "seconds_clk" -divide_by 2500 \
    -source [get_pins {pll_inst|*|clk[0]}] \
    [get_registers {secs|count_reg[*]}]

# Create generated clocks for counter chains
create_generated_clock -name "seconds10_clk" -source [get_registers {sl|count_reg[*]}] \
    -divide_by 10 [get_registers {sh|count_reg[*]}]

create_generated_clock -name "minutes_clk" -source [get_registers {sh|count_reg[*]}] \
    -divide_by 6 [get_registers {ml|count_reg[*]}]

create_generated_clock -name "minutes10_clk" -source [get_registers {ml|count_reg[*]}] \
    -divide_by 10 [get_registers {mh|count_reg[*]}]

create_generated_clock -name "hours_clk" -source [get_registers {mh|count_reg[*]}] \
    -divide_by 6 [get_registers {hl|count_reg[*]}]

create_generated_clock -name "hours10_clk" -source [get_registers {hl|count_reg[*]}] \
    -divide_by 10 [get_registers {hh|count_reg[*]}]

# Derive clock uncertainty
derive_clock_uncertainty

# Input delays
set_input_delay -clock clk_in -max 1 [get_ports {reset}]
set_input_delay -clock clk_in -max 1 [get_ports {show_seconds}]

# Output delays
set_output_delay -clock clk_in -max 1 [get_ports {DIG[*]}]
set_output_delay -clock clk_in -max 1 [get_ports {SEG[*]}]

# False paths
set_false_path -from [get_ports {reset}] -to *
set_false_path -from [get_ports {show_seconds}] -to *

# Cut paths for asynchronous reset
set_false_path -from [get_registers *] -to [get_registers *] -setup -hold -through [get_nets *r]

# Multicycle paths for display refresh
set_multicycle_path -setup 2 -from [get_clocks {pll_inst|*}] -to [get_registers {*segment7*}]
set_multicycle_path -hold 1 -from [get_clocks {pll_inst|*}] -to [get_registers {*segment7*}]

# Clock groups
set_clock_groups -asynchronous \
    -group {clk_in} \
    -group {pll_inst|*} \
    -group {refresh_clk} \
    -group {seconds_clk} \
    -group {seconds10_clk} \
    -group {minutes_clk} \
    -group {minutes10_clk} \
    -group {hours_clk} \
    -group {hours10_clk}

# Relax timing requirements for slow clock domains
set_multicycle_path -setup 2500 -from [get_clocks seconds_clk] -to [get_clocks *]
set_multicycle_path -hold 2499 -from [get_clocks seconds_clk] -to [get_clocks *]

# Set false paths for very slow clock domain crossings
set_false_path -from [get_clocks {seconds10_clk minutes_clk minutes10_clk hours_clk hours10_clk}] -to [get_clocks *]

report_clocks
report_clock_transfers