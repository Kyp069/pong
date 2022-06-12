create_clock -name "clock50" -period 20.000 [get_ports {clock50}]

derive_pll_clocks
derive_clock_uncertainty

set_false_path -to   {sync[*]}
set_false_path -to   {rgb[*]}
set_false_path -to   {joy*}
set_false_path -to   {stm}
set_false_path -to   {led}

set_false_path -from {joy*}
