module AHB_slave_interface(
                          input logic Hclk,Hresetn,Hwrite,Hreadyin,
                          input logic [1:0] Htrans,
                          input logic [31:0] Haddr,Hwdata,Prdata,
                          output logic valid,
                          output logic [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,
                          output logic Hwritereg,
                          output logic [2:0] tempselx,
                          output logic [1:0] Hresp);


/// Implementing Pipeline Logic for Address,Data and Control Signal

	always_ff @(posedge Hclk)
		begin
		
			if (~Hresetn)
				begin
					Haddr1<=0;
					Haddr2<=0;
				end
			else
				begin
					Haddr1<=Haddr;
					Haddr2<=Haddr1;
				end
		
		end

	always_ff @(posedge Hclk)
		begin
		
			if (~Hresetn)
				begin
					Hwdata1<=0;
					Hwdata2<=0;
				end
			else
				begin
					Hwdata1<=Hwdata;
					Hwdata2<=Hwdata1;
				end
		
		end
		
	always_ff @(posedge Hclk)
		begin	
			if (~Hresetn)
				Hwritereg<=0;
			else
				Hwritereg<=Hwrite;
		end
		
		
/// Implementing Valid Logic Generation

	always_comb begin
			valid=0;
			if (Hresetn && Hreadyin && (Haddr>=32'h8000_0000 && Haddr<32'h8C00_0000) && (Htrans==2'b10 || Htrans==2'b11) )
				valid=1;
		end
		
/// Implementing Tempselx Logic

	always_comb begin
			tempselx=3'b000;
			if (Hresetn && Haddr>=32'h8000_0000 && Haddr<32'h8400_0000)
				tempselx=3'b001;
			else if (Hresetn && Haddr>=32'h8400_0000 && Haddr<32'h8800_0000)
				tempselx=3'b010;
			else if (Hresetn && Haddr>=32'h8800_0000 && Haddr<32'h8C00_0000)
				tempselx=3'b100;
	end
	

assign Hrdata = Prdata;
assign Hresp = 2'b00;

endmodule
