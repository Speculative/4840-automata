/*
 * Basic 20-bit wide mux 
 * with 3 inputs. 
 */


module mux20 (
input wire [19:0] din_0,
input wire [19:0] din_1,
input wire [19:0] din_2,
input wire [1:0] sel,
output reg [19:0] dout);

  always_comb begin
    case (sel)
      2'b00: dout = din_0;
      2'b01: dout = din_1;
      2'b10: dout = din_2;
      2'b11: dout = din_0;
    endcase  
  end

endmodule
