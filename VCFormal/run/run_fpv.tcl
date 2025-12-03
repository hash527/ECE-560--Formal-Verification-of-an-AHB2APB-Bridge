set_fml_appmode FPV 
set design bridge_top 

read_file -top bridge_top -format sverilog -sva -vcs {-f ../RTL/filelist +incdir+../RTL}

create_clock Hclk -period 10
create_reset Hresetn -sense low

sim_run -stable
sim_save_reset