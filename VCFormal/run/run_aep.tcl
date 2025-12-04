set_fml_appmode AEP
set design bridge_top
set_fml_var fml_aep_unique_name true

##enable VC Formal to dump FSM report
set_app_var fml_enable_fsm_report_complexity true
set_app_var fml_trace_auto_fsm_state_extraction true

read_file -top $design -format sverilog -aep all+fsm_deadlock -sva -vcs {-f ../RTL/filelist}


create_clock clk -period 100 
create_reset rst -sense high

sim_run -stable 
sim_save_reset

aep_generate -type fsm_fairness