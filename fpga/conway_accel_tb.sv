module conway_accel_tb (
); 

logic clk, reset;
logic [15:0] address_b_1;
logic wait_request;
logic [19:0] q_b_1;

assign address_b_1 = 0;

Conway_Accel test(.*);

initial begin
clk = 0;
reset = 1;
#5
reset = 0;
end


always 
  #5 clk = ~clk;

initial 
#200 $finish;

endmodule

