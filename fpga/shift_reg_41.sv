/*
 * Shift register that holds 41 bits.
 * 22 of those are availble on the output.
 * A shift moves in 20 bits of data.
 * Available with a synchronous clear.
 *
 * Built with guidance from:
 * https://courses.cs.washington.edu/courses/cse467/05wi/pdfs/lectures/07-SequentialVerilog.pdf
 */

module shift_buffer(input logic clk, clear,
input logic shift_enable, // do shift when enabled, else hold
input [19:0] din, // 20 bits in
output [21:0] dout // 22 bits out
);

logic [40:0] sregisters;
assign dout = sregisters[40:19];
	
	always @(posedge clk) begin
		if (clear)
			sregisters = 41'd0;

		else if (shift_enable) begin
			sregisters[19:0] <= din;
			
			sregisters[40:20] <= sregisters[20:0];
			
		end else
			sregisters[40:19] <= dout;
	end

endmodule
