module signext(in1,out1,ORIidentifierSignal);
input [15:0] in1;
input ORIidentifierSignal;
output [31:0] out1;
assign 	 out1 = ORIidentifierSignal ? {{ 16 {1'b0}}, in1}:{{ 16 {in1[15]}}, in1};
endmodule