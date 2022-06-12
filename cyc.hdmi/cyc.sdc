create_clock -name "clock12" -period 83.334 [get_ports {clock12}]

derive_pll_clocks
derive_clock_uncertainty

set_false_path -to   {tmds[*]}
set_false_path -to   {joy*}
set_false_path -to   {led*}

set_false_path -from {joy*}
