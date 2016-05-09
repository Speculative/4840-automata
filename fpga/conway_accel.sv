// Management surrounding the Conway accelerator including buffers
module Conway_Accel(
 // need end-of-screen logic from the VGA controller
 
 input clk, reset,
 // VGA controller will access memory exclusively on B ports, through this module.
 input ready_sig,
 input  [15:0] address_b, 
 output [19:0] q_b,
 output wait_request,
 output logic halp

);

  // for memories, data_b should be unused (never writing through the data ports)
  // clocks can *probably* be the same? implement buffering in the VGA controller?
  // 
  assign wait_request = 0;
  
  logic [15:0] address_a_1, address_a_2;
  logic [19:0] data_b, q_a_1, q_a_2;
  logic [0:0] wren_a_1, wren_a_2, wren_b;
  wire [19:0] q_b_1, q_b_2;
  
  assign data_b = 20'd0;
  assign wren_b = 1'd0; // never write over B port
  wire [19:0] result;

  tmemory m1( 
					.address_a(address_a_1),
					.address_b(address_b),
					.data_a(result),
					.data_b(data_b),
					.q_a(q_a_1),
					.q_b(q_b_1),
					.wren_a(wren_a_1),
					.wren_b(wren_b),
					.clock_a(clk), .clock_b(clk)
					);
	/*
	input	[15:0]  address_a;
	input	[15:0]  address_b;
	input	  clock_a;
	input	  clock_b;
	input	[19:0]  data_a;
	input	[19:0]  data_b;
	input	  wren_a;
	input	  wren_b;
	output	[19:0]  q_a;
	output	[19:0]  q_b;
   */

  tmemory m2 (  
					.address_a(address_a_2),
					.address_b(address_b),
					.data_a(result),
					.data_b(data_b),
					.q_a(q_a_2),	
					.q_b(q_b_2),					
					.wren_a(wren_a_2),
					.wren_b(wren_b),
					.clock_a(clk), .clock_b(clk)
					);

  logic [19:0] zeros = 20'd0;
  wire [19:0] dout;
  logic [1:0] sel;
  assign halp = q_b_2[0];
  
  mux20 memmux (.din_0(zeros), .din_1(q_a_1), .din_2(q_a_2), .sel(sel), .dout(dout));
  // TODO: this needs to be somewhere in an alwaysff or else it won't change					
  logic direction; //when 0, m1 is t, when 1, m2 is t


  // reads from memory will go into here. 
  // necessary so that the shift registers are able to read from
  // both m1 and m2 (can't directly wire them up to different memories
  // so the different memories will go here first.)
  // logic [19:0] memory_buffer; 
  logic oob;
  
  // wires connecting shift output to conway input
  wire [21:0] top_out;
  wire [21:0] middle_out;
  wire [21:0] bottom_out;
  
  // control logic for the shift registers
  logic shift_enable_t, shift_enable_m, shift_enable_b, clear;

  // instantiate shift register  
  shift_buffer top    (.din(dout), .dout(top_out),    .shift_enable(shift_enable_t), .clear(clear), .clk(clk));
  shift_buffer middle (.din(dout), .dout(middle_out), .shift_enable(shift_enable_m), .clear(clear), .clk(clk));
  shift_buffer bottom (.din(dout), .dout(bottom_out), .shift_enable(shift_enable_b), .clear(clear), .clk(clk));

// deal with requests from the VGA controller

assign q_b = (direction) ? q_b_2:q_b_1;
/*always_comb begin
if (direction == 0)
	q_b = q_b_1;
else if (direction == 1)
	q_b = q_b_2;
end
  */
  
// instatiate conway module, wire together.


  Conway_Multiple cm (.top_row(top_out), 
							 .middle_row(middle_out),
							 .bottom_row(bottom_out),
							 .result(result),
							 .clk(clk));							 
				 

enum logic [1:0] {TOP, MID, BOT, EOR} state;
logic [0:0] frame_complete;
reg [5:0] word_count;
logic [2:0] eorstall;

always_ff @(posedge clk or posedge reset) begin

	if (reset) begin
	  address_a_1 <= 16'd0;
	  address_a_2 <= 16'd0;
	  shift_enable_b <= 1'd0;
	  shift_enable_m <= 1'd0;
	  shift_enable_t <= 1'd0;
	  clear <= 1;
	  word_count <= 6'd0;
	  state <= TOP;
	  oob <= 1;
	  wren_a_1 <= 0;
	  wren_a_2 <= 0;
	  frame_complete <= 0;
	  direction <= 0;
	  eorstall <= 3'd0;
	  end
	  
	else if (frame_complete && ready_sig) begin
	  address_a_1 <= 16'd0;
	  address_a_2 <= 16'd0;
	  shift_enable_b <= 1'd0;
	  shift_enable_m <= 1'd0;
	  shift_enable_t <= 1'd0;
	  clear <= 1;
	  word_count <= 6'd0;
	  state <= TOP;
	  oob <= 1;
	  wren_a_1 <= 0;
	  wren_a_2 <= 0;
	  frame_complete <= 0;
	  if (direction == 0)
		direction <= 1;
	  else
		direction <= 0;
	  end
	  
	else if (frame_complete && ~ready_sig) begin end
	  
	else if (direction == 0) begin
	clear <= 0;
	  case (state)
		 TOP : begin
				 if (address_a_1 < 16'd64 && oob == 1) 
					sel = 2'b00; // dead cell buffer at top 
				 else begin
			     sel = 2'b01;	 
				   //address_a_1 <= address_a_1 + 16'd64; //address for MID
				 end
				 //if (address_a_1 > 16'd65407) // in the second-to-last row
				 //oob <= 1;
				// memory address computation
			 	 if (oob == 1 && address_a_1 > 16'd65471)
					address_a_1 <= address_a_1; // Doesn't matter, won't be checked. do not overflow the variable.  
				 else 
				   address_a_1 <= address_a_1 + 16'd64; //address for BOT
				
				 if (word_count == 6'd0 && oob == 1)
               wren_a_2 <= 0; // if looking at first word, EOR zeros still in accelerator, invalid output. 
				 
				 else if (word_count  < 6'd2)
					wren_a_2 <= 0;
				 
				 else wren_a_2 <= 1;
				 if (address_a_1 > 1)
				   address_a_2 <= address_a_1 - 16'd2;  // will write to the MID address in t+1 grid
				 
				 shift_enable_m <= 0;
				 shift_enable_b <= 0;
				 shift_enable_t <= 1;
				 state <= MID;
				 end

		 MID : begin
				 sel = 2'b01; 
				 shift_enable_t <= 0;
				 shift_enable_m <= 1;

         // Compute address for TOP  
         //if (oob == 1 && address_a_1 < 16'd128)
			if (oob == 1)
					address_a_1 = address_a_1 - 16'd64 + 16'd1; // address for TOP; go back one row, move forward one word 
			else begin 
				   address_a_1 <= address_a_1 - 16'd128 + 16'd1; // address for TOP; go back two rows, move forward one word 
			end
         
         state <= BOT;
			if (wren_a_2 == 1)
			   wren_a_2 <= 0;	 
			end

		 BOT : begin
				 shift_enable_m <= 0;
				 shift_enable_b <= 1;

			
         // compute address for mid
			// if we
         if ((oob == 1 && address_a_1 < 16'd64))
            address_a_1 <= address_a_1; // address for mid
			else if ((oob == 1) && (address_a_1 < 16'd65))
				address_a_1 <= 0;
         else if (word_count == 6'd63)
				address_a_1 <= address_a_1; // address for top to account for extra cycle by EOR
			else 
            address_a_1 <= address_a_1+16'd64; // address for mid
				 
         
			if (oob == 1 && address_a_1 < 16'd128) begin
					sel = 2'b01;
				 end
			else if (oob == 1 && address_a_1 > 16'd65471) begin
					sel = 2'b00; // dead cell outline at bottom
			end
			else begin 
				   sel = 2'b01;
			end

			word_count <= word_count + 6'd1;
			
			if(word_count == 6'd63) begin// at end of row
				   state <= EOR;
			end
			else
				   state <= TOP;
			end

		EOR : begin
				if (eorstall == 3'd3) begin
					if (address_a_1 > 16'd65407) // in the second-to-last row
						oob <= 1;
					
					if (oob == 1 && address_a_1 < 16'd129)
					  oob <= 0;
					else if (oob == 1) begin
						frame_complete <= 1;
					end
					// address_a_2 <= address_a_2 - 16'd1;
					address_a_1 <= address_a_1 + 16'd64;
					word_count <= 6'd0; 						
					wren_a_2 <= 0;
					state <= TOP;
					eorstall <= 0;

				end
				else begin
					eorstall <= eorstall+1;
					state <= EOR;
					if (eorstall == 3'd0) begin
						shift_enable_b <= 0;
						address_a_2 <= address_a_2 + 16'd1;
						wren_a_2 <= 1;
					end
					else if (eorstall == 3'd1) begin
						sel = 2'b00;  // when to deassert write enable so this isn't the next thing written?
						shift_enable_b <= 1;
						shift_enable_m <= 1;
						shift_enable_t <= 1;
						wren_a_2 <= 0;
					end
					else if (eorstall == 3'd2) begin
						address_a_2 <= address_a_2 + 16'd1;
						wren_a_2 <= 1;
					end
				end
			end
	  endcase
	  
	end

	else if (direction == 1) begin
	clear <= 0;
	  case (state)
		 TOP : begin
				 if (address_a_2 < 16'd64 && oob == 1) 
					sel = 2'b00; // dead cell buffer at top 
				 else begin
			     sel = 2'b10;	 
				   //address_a_1 <= address_a_1 + 16'd64; //address for MID
				 end
				 //if (address_a_1 > 16'd65407) // in the second-to-last row
				 //oob <= 1;
				// memory address computation
			 	 if (oob == 1 && address_a_2 > 16'd65471)
					address_a_2 <= address_a_2; // Doesn't matter, won't be checked. do not overflow the variable.  
				 else 
				   address_a_2 <= address_a_2 + 16'd64; //address for BOT
				
				 if (word_count == 6'd0 && oob == 1)
               wren_a_1 <= 0; // if looking at first word, EOR zeros still in accelerator, invalid output. 
				 
				 else if (word_count  < 6'd2)
					wren_a_1 <= 0;
				 
				 else wren_a_1 <= 1;
				 if (address_a_2 > 1)
				   address_a_1 <= address_a_2 - 16'd2;  // will write to the MID address in t+1 grid
				 
				 shift_enable_m <= 0;
				 shift_enable_b <= 0;
				 shift_enable_t <= 1;
				 state <= MID;
				 end

		 MID : begin
				 sel = 2'b10; 
				 shift_enable_t <= 0;
				 shift_enable_m <= 1;

         // Compute address for TOP  
         //if (oob == 1 && address_a_1 < 16'd128)
			if (oob == 1)
					address_a_2 = address_a_2 - 16'd64 + 16'd1; // address for TOP; go back one row, move forward one word 
			else begin 
				   address_a_2 <= address_a_2 - 16'd128 + 16'd1; // address for TOP; go back two rows, move forward one word 
			end
         
         state <= BOT;
			if (wren_a_1 == 1)
			  wren_a_1 <= 0;
			end

		 BOT : begin
				 shift_enable_m <= 0;
				 shift_enable_b <= 1;

			
         // compute address for mid
			// if we
         if ((oob == 1 && address_a_2 < 16'd64))
            address_a_2 <= address_a_2; // address for mid
			else if ((oob == 1) && (address_a_2 < 16'd65))
				address_a_2 <= 0;
         else if (word_count == 6'd63)
				address_a_2 <= address_a_2; // address for top to account for extra cycle by EOR
			else 
            address_a_2 <= address_a_2+16'd64; // address for mid
				 
         
			if (oob == 1 && address_a_2 < 16'd128) begin
					sel = 2'b10;
				 end
			else if (oob == 1 && address_a_2 > 16'd65471) begin
					sel = 2'b00; // dead cell outline at bottom
			end
			else begin 
				   sel = 2'b10;
			end

			word_count <= word_count + 6'd1;
			
			if(word_count == 6'd63) begin// at end of row
				   state <= EOR;
			end
			else
				   state <= TOP;
			end

		EOR : begin
				if (eorstall == 3'd3) begin
					if (address_a_2 > 16'd65407) // in the second-to-last row
						oob <= 1;
					
					if (oob == 1 && address_a_2 < 16'd129)
					  oob <= 0;
					else if (oob == 1) begin
						frame_complete <= 1;
					end
					// address_a_2 <= address_a_2 - 16'd1;
					address_a_2 <= address_a_2 + 16'd64;
					word_count <= 6'd0; 						
					wren_a_1 <= 0;
					state <= TOP;
					eorstall <= 0;
				end
				else begin
					eorstall <= eorstall+1;
					state <= EOR;
					if (eorstall == 3'd0) begin
						shift_enable_b <= 0;
						address_a_1 <= address_a_1 + 16'd1;
						wren_a_1 <= 1;
					end
					else if (eorstall == 3'd1) begin
						sel = 2'b00;  // when to deassert write enable so this isn't the next thing written?
						shift_enable_b <= 1;
						shift_enable_m <= 1;
						shift_enable_t <= 1;
						wren_a_1 <= 0;
					end
					else if (eorstall == 3'd2) begin
						address_a_1 <= address_a_1 + 16'd1;
						wren_a_1 <= 1;
					end
				end
			end
			   
	  endcase
	  
	end
	
end
  
endmodule
