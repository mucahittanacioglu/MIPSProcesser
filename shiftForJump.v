module shiftForJump(shout,shin);
output [27:0] shout;
input [25:0] shin;
//wire [27:0] shin_28 = {{ 2 {shin[25]}}, shin};
assign shout={shin,2'b00};
endmodule