// AHB to APG Bridge
//
//
//
// Bridge Top
// Date:01-29-2025
//
// By - Harsha vardhan duvvuru


module APB_Interface (
input logic Pwrite, Penable,
input logic [2:0] Pselx,
input logic [31:0] Pwdata, Paddr,
output logic Pwriteout, Penableout,
output logic [2:0] Pselxout,
output logic [31:0] Pwdataout, Paddrout,
output reg [31:0] Prdata);

assign Penableout = Penable;
assign Pselxout = Pselx;
assign Pwriteout = Pwrite;
assign Paddrout = Paddr;
assign Pwdataout = Pwdata;

always @(*)
begin
if (~Pwrite && Penable)
Prdata = ($random)%256;
else
Prdata = 0;
end

endmodule
