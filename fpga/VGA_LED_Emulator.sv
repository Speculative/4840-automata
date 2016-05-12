/*
 * Seven-segment LED emulator
 *
 * Stephen A. Edwards, Columbia University
 */

/*
 * Adapted for use with Conway Accelerator.
 * Able to draw a 1280x1024 screen. Computes
 * pixel color based on alive or dead cells
 * received from the Conway module. 
 */

module VGA_LED_Emulator(
 input logic 	    clk108, reset,
 input logic [19:0] q_b,

 output logic ready_sig,
 output logic [15:0]address,
 output logic [7:0] VGA_R, VGA_G, VGA_B,
 output logic 	    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

/*
 * 1280 x 1024 VGA timing for a 108 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *             _______________              ________
 * ___________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */
 
 // values determined with help from:
 // https://eewiki.net/pages/viewpage.action?pageId=15925278
   
   // Parameters for hcount
   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 48,
             HSYNC        = 11'd 112,
             HBACK_PORCH  = 11'd 248,   
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; // 1688
   
   // Parameters for vcount
   parameter VACTIVE      = 11'd 1024,
             VFRONT_PORCH = 11'd 1,
             VSYNC        = 11'd 3,
             VBACK_PORCH  = 11'd 38,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; // 1066

   // Horizontal counter
	logic [10:0]		  hcount;              
   logic 			     endOfLine;
   
	// Vertical counter
   logic [10:0] 		  vcount;
   logic 			     endOfField;
	
   always_ff @(posedge clk108 or posedge reset)
     if (reset)          hcount <= 0;
     else if (endOfLine) hcount <= 0;
     else  	         hcount <= hcount + 11'd 1;
	  
   assign endOfLine = hcount == HTOTAL - 1;
   
   always_ff @(posedge clk108 or posedge reset)
     if (reset)          vcount <= 0;
     else if (endOfLine)
       if (endOfField)   vcount <= 0;
       else              vcount <= vcount + 11'd 1;

   assign endOfField = vcount == VTOTAL - 1;

   // Horizontal sync: from 0x520 to 0x5DF (0x57F)
   // original 101 0010 0000 to 101 1101 1111
	// new      101 0011 0000 to 101 1010 0000
	// should go high again on 101 1010 0001
	
	always_ff @(posedge clk108) begin 
		if (hcount >= 11'b10100110000 && hcount <= 11'b10110100000)
			VGA_HS <= 1;
		else
			VGA_HS <= 0;
		
		
		
		if (vcount >= 11'b10000000001 && vcount <= 11'b10000000100)
			VGA_VS <= 1;
		else
			VGA_VS <= 0;	
		
	  // VGA_BLANK_n turns off screen when not drawing pixels
	  if (hcount < HACTIVE && vcount < VACTIVE )
			VGA_BLANK_n <= 1;
		else 
			VGA_BLANK_n <= 0;
			
		 
	end 


   assign VGA_SYNC_n = 0; // For adding sync to video signals; not used for VGA
   
   // Horizontal active: 0 to 1279     Vertical active: 0 to 479
   // 101 0000 0000  1280	       01 1110 0000  480
   // 110 0011 1111  1599	       10 0000 1100  524
	

   /* VGA_CLK is 108 MHz
    *             __    __    __
    * clk108    __|  |__|  |__|
    *        
    */
   assign VGA_CLK = clk108; // 108 MHz clock: pixel latched on rising edge

	logic [39:0] buffer;
	enum logic [1:0] {START, LT, RT} state;
	logic [5:0] pixel_count;

	
	always_ff @(posedge clk108 or posedge reset) begin
	
		// reset or end of frame
		if(reset) begin
			address <= 16'd0;
			pixel_count <= 6'd0;
			state <= START;
			buffer <= 40'd0;
			ready_sig <= 1'd0;
		end
		// Just drew the last pixel
    else if(address == 16'd65535 && pixel_count == 6'd18) begin
			address <= 16'd0;
			pixel_count <= pixel_count + 6'd1;
			ready_sig <= 1;
		end
    // In any other pixel on screen
		else if (hcount < 11'd1280 && vcount< 11'd1024) begin
			case(state)
				START : begin // Extra set up after a reset
					buffer[19:0] <= q_b; // first word into register
					address <= address + 16'd1;
					state <= RT;
				end
				LT : begin // drawing left(39:20), writing right 
					if(pixel_count == 6'd18) begin
						buffer[19:0] <= q_b;
						address <= address + 16'd1;
					end
					ready_sig <= 0;
					if (pixel_count == 6'd19)
						state <= RT;
				end
				RT: begin // drawing right(19:0), writing left
					if (pixel_count == 6'd18) begin
						buffer[39:20] <= q_b;
						address <= address + 16'd1;
					end
					if (pixel_count == 6'd19)
						state <= LT;
				end
			endcase
			if (pixel_count == 6'd19)
				pixel_count <= 6'd0; // reset at end of word
			else
				pixel_count <= pixel_count + 6'd1;	
				
		end 
	end
	
	always_comb begin
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'h88, 8'h88}; // Not Black
		case(state)
				LT: begin
					if (buffer[6'd39 - pixel_count])
						{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff}; // White			
				end
				RT: begin	
					if (buffer[6'd19 - pixel_count])
						{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff}; // White
				end
		endcase					
   end 
	
endmodule // VGA_LED_Emulator
