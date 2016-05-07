module vga_tb (
); 

logic clk, clkmem, reset, ready_sig, write, read1, chipselect, wait_request;
logic [15:0] address_b;
logic [19:0] q_b;
logic [2:0] address;
logic [31:0] writedata;

logic [7:0] VGA_R, VGA_G, VGA_B;
logic 	    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n;

VGA_LED test(.*);

assign q_b = 20'b10110011100011110000;

initial begin
clk = 0;
reset = 1;
#3
reset = 0;
end


always 
  #5 clk = ~clk;

endmodule

