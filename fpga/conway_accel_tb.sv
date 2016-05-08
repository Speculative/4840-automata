module conway_accel_tb (
); 

logic clk, reset;
logic halp, ready_sig;
logic [15:0] address_b;
logic wait_request;
logic [19:0] q_b;

assign address_b = 0;
assign ready_sig = 0;

Conway_Accel test(.*);

initial begin
clk = 0;
reset = 1;
#2
reset = 0;
end


always 
  #5 clk = ~clk;


endmodule

