/* jco2127 jat2164 */

/*
 * Avalon memory-mapped peripheral for the VGA LED Emulator
 *
 * Stephen A. Edwards
 * Columbia University
 */

module VGA_LED(input logic        clk, clkmem,
	       input logic 	  reset,
			 output logic read1, 
			 input wait_request,
			 input logic [19:0] q_b,
			 input logic halp,
			 
			 output logic ready_sig,
			 output logic [15:0] address_b, 
	       output logic [7:0] VGA_R, VGA_G, VGA_B,
	       output logic 	  VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
	       output logic 	  VGA_SYNC_n);

   
		//logic [19:0] q_b_test;

	//VGA_LED_Emulator led_emulator(.clk108(clk), .reset(reset), .*);
	VGA_LED_Emulator led_emulator (.clk108(clk), .reset(reset), .VGA_R(VGA_R), 
											.VGA_G(VGA_G), .VGA_B(VGA_B),
											.VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
											.VGA_BLANK_n(VGA_BLANK_n), .VGA_SYNC_n(VGA_SYNC_n), 
											.q_b(q_b), .address(address_b), .ready_sig(ready_sig));
	/*
	always_comb begin									
  if ((0 <= address_b && address_b <16384) || (32768 <= address_b && address_b < 49152))
    q_b_test = 20'hfffff;
  else
    q_b_test = 20'h00000; 
	 end
  */
		//logic [19:0] q_b_test;
		//assign q_b_test = 20'b11111111110000000000;
		logic halpflag;
		assign halpflag = !halp; 
			
		
		endmodule
