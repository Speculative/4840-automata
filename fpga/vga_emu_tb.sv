module vga_emu_tb (
); 

logic clk108, reset, ready_sig;
logic [15:0] address;
logic [19:0] q_b;

logic [7:0] VGA_R, VGA_G, VGA_B;
logic 	    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n;

VGA_LED_Emulator test(.*);

assign q_b = 20'b10110011100011110000;

initial begin
clk108 = 0;
reset = 1;
#3
reset = 0;
end


always 
  #5 clk108 = ~clk108;

endmodule

