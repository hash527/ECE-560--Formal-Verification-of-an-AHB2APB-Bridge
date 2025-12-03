// AHB to APB Bridge - Bind File for VC Formal
// Date: 01-31-2025

bind bridge_top bridge_formal_properties u_formal_props (
    // Clock and Reset
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    
    // AHB Master Interface Inputs
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Hwdata(Hwdata),
    .Haddr(Haddr),
    .Htrans(Htrans),
    
    // APB Slave Interface Inputs
    .Prdata(Prdata),
    
    // Bridge Outputs to APB
    .Penable(Penable),
    .Pwrite(Pwrite),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    
    // Bridge Outputs to AHB
    .Hreadyout(Hreadyout),
    .Hresp(Hresp),
    .Hrdata(Hrdata),
    
    // Internal Signals from AHB Slave Interface
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    
    // FSM State from APB Controller
    .fsm_state(APBControl.PRESENT_STATE)
);
