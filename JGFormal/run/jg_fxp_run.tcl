clear -all

analyze -sv09 \
  ../RTL/APB_Controller.sv \
  ../RTL/APB_Interface.sv \
  ../RTL/AHB_Slave_Interface.sv \
  ../RTL/AHB_Master.sv \
  ../RTL/bridge_top.sv \
  ../RTL/bridge_assertions.sva \
  ../RTL/bridge_assumptions.sva \
  ../RTL/bridge_cover_properties.sva \
  ../RTL/bridge_xprop_assertions.sva \
  ../RTL/bridge_bind_file.sva

check_xprop -init

elaborate -top bridge_top

clock Hclk
reset -expression {!Hresetn}

set_engine_mode {Hp Ht}

prove -all

report