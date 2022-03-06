set_db init_lib_search_path ../lib/
set_db init_hdl_search_path ../rtl/
read_libs slow_vdd1v0_basicCells.lib

read_hdl counter.v
elaborate
read_sdc ../constraints/constraints_top.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

write_hdl > counter_netlist.v
write_sdc > counter_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > delays.sdf
