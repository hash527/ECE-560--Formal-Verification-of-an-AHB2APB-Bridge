module AHB_Master(
                  input logic Hclk,Hresetn,Hreadyout,
                  input logic [1:0]Hresp,
                  input logic [31:0] Hrdata,
                  output logic Hwrite,Hreadyin,
                  output logic [1:0] Htrans,
                  output logic [31:0] Hwdata,Haddr
                 );



logic [2:0] Hburst;
logic [2:0] Hsize;



task single_write();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=1;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_0001;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
    Hwdata=8'hA3;
   end 
 end
endtask


task single_read();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=0;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_00A2;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
   end 
 end
endtask

endmodule
