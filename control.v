module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch_and_jump_identifier,aluop1,aluop2,ORIidentifierSignal,statusRegWrite);
input [5:0] in;//001101
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,aluop1,aluop2,ORIidentifierSignal,statusRegWrite;
output [3:0] branch_and_jump_identifier;
wire rformat,lw,sw,register31_write,beq;
assign register31_write=(~in[5])&(in[4])&(in[3])&(~in[2])&(in[1])&(in[0])|((in[5])&(in[4])&(in[3])&(in[2])&(in[1])&(~in[0]))|((in[5])&(~in[4])&(in[3])&(in[2])&(~in[1])&(in[0]));
assign ORIidentifierSignal=(~in[5]) & (~in[4])&(in[3])&(in[2])&(~in[1])&in[0];//001101 13
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign regdest=rformat;
assign statusRegWrite = ~(((~in[5])& (in[4])&(in[3])&(~in[2])&(in[1])&(in[0])) | ((~in[5])& (in[4])&(in[3])&in[2]&(in[1])&(~in[0])));
assign alusrc=ORIidentifierSignal ? 1:lw|sw;
assign memtoreg=lw;
assign regwrite= (ORIidentifierSignal) ?  1:(register31_write ? 1:rformat|lw);
assign memread=lw;
assign memwrite=sw;
assign branch_and_jump_identifier= ((~in[5])&(in[4])&(in[3])&(~in[2])&(in[1])&(in[0])) ? 4'b0001:(((in[5])&(in[4])&(in[3])&(in[2])&(in[1])&(~in[0])) ? 4'b0010:(((in[5])&(~in[4])&(in[3])&(in[2])&(~in[1])&(in[0])) ? 4'b0100:(rformat ? 4'b0000:4'b1111)));
assign aluop1=rformat;
assign aluop2=beq;
endmodule
