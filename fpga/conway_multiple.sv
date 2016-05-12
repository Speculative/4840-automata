parameter word_len = 20;

module Conway_Multiple( 
  input wire [21:0] top_row, middle_row, bottom_row, // 22 columns in
  input logic clk,
  output [19:0] result// 20 columns out
);


// Generate and wire together 20
// Conway single modules. 
	generate
		genvar i;
		
		for (i=0; i<word_len; i = i+1) begin:accelerator
			Conway_Cell c (.top_row(top_row[i+2:i]), 
								 .middle_row(middle_row[i+2:i]), 
								 .bottom_row(bottom_row[i+2:i]),
								 .next_state(result[i]));
		end
	endgenerate
endmodule	
