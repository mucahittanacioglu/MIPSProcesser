module mult4_to_1_32(out,i3,i2,i1,i0,s1,s0);
output [31:0] out;
input [31:0]i0,i1,i2,i3;
input wire s0,s1;
/*
i0=satandart +4
i1=jump
i2=adress
i3=brench
*/
assign out = (s1&s0) ? i1:((s1&(~s0)) ? i2:(((~s1&s0)) ? i3:i0));
/*always @(s1 or s0)
begin

	if(s1&s0)
		assign out = i1;
	else if(s1&(~s0))	
		assign out = i2;
	else if((~s1&s0))
		assign out = i3;
	else
		assign out = i0;
	

end*/
endmodule