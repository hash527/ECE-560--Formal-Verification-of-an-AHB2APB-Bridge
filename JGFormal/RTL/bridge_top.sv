
// AHB to APG Bridge
//
//
//
// Bridge Top
// Date:01-29-2025
//
// By - Lokarjun


`include "../CLASS/APB_Controller.sv"
`include "../CLASS/APB_Interface.sv"
`include "../CLASS/AHB_Slave_Interface.sv"
`include "../CLASS/AHB_Master.sv"

module bridge_top (
input logic Hclk,Hresetn,Hwrite,Hreadyin,
input logic [31:0] Hwdata,Haddr,Prdata,
input logic [1:0] Htrans,
output logic Penable, Pwrite, Hreadyout,
output logic [1:0] Hresp,
output logic [2:0] Pselx,
output logic [31:0] Paddr, Pwdata,
output logic [31:0] Hrdata
);

logic valid;
logic [31:0] Haddr1, Haddr2, Hwdata1, Hwdata2;
logic Hwritereg;
logic [2:0] tempselx;


AHB_slave_interface AHBSlave (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Htrans(Htrans),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Prdata(Prdata),
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Hrdata(Hrdata),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    .Hresp(Hresp)
);

APB_FSM_Controller APBControl (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Prdata(Prdata),
    .Hwrite(Hwrite),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    .Pwrite(Pwrite),
    .Penable(Penable),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Hreadyout(Hreadyout)
);

endmodule
