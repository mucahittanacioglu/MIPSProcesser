module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
reg  statusReg[2:0];


wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,		//output of mux connected to write data port of register file
out7,       //Adder operand for (pc+4 )+out7
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad;	//Output of shift left 2 unit
wire out8; //regwrite mux selcted
wire[25:0] jump_26;
wire[27:0] jumpExt_28;
wire[31:0] jump_total_32;


wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write register input of Register File
out6,  //output of register adrees port of re.f
out9; //output of second mux of reg. file address port

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)
wire[5:0] function_code=instruc[5:0];//100000

wire [2:0] gout;	//Output of ALU control unit
wire [3:0] branch_and_jump_identifier;
wire function_code_lmsb,
jmadd_ident,
branch_and_jump_identifier_single,
jpc_identifier;

wire zout,nout,overflowout,//Zero output of ALU and negative output of alu
//Control signals
ORIidentifierSignal,//our custom ORI instruction identify signal
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,statusRegWrite;
wire s1,s0;//output of j_b controller
wire memToregInvert=~memtoreg;//jmadd
//wire bneal_ident = (~&branch_and_jump_identifier)&branch_and_jump_identifier[2];
//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];
wire z_stored, 
n_stored,overflowout_stored;
reg first_time_flag=1'b0;
integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];

end
 

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];




assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)begin
 registerfile[out9]= regwrite ? out5:registerfile[out9];//Write data to register
 if(statusRegWrite)
 begin
	statusReg[0] = zout;// deneme
	statusReg[1] = nout;
	statusReg[2] = overflowout;
 end
first_time_flag=1'b1; 
end
//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};
assign function_code_lmsb=function_code[5];
assign jpc_identifier = (~branch_and_jump_identifier[3])&(~branch_and_jump_identifier[2])&(branch_and_jump_identifier[1])&(~branch_and_jump_identifier[0]);
assign jmadd_ident=(function_code_lmsb & (~|function_code[4:0]) & (~|branch_and_jump_identifier));
assign branch_and_jump_identifier_single =  jmadd_ident | (~(branch_and_jump_identifier[3])&(branch_and_jump_identifier[0]|branch_and_jump_identifier[1]|branch_and_jump_identifier[2]));//r type(13,jmadd) or other 3
assign jump_26 = instruc[25:0];
assign z_stored = statusReg[0];
assign n_stored = statusReg[1];
assign overflowout_stored = statusReg[2];
//multiplexers
//mux with RegDst control
shiftForJump shift2(jumpExt_28,jump_26);

assign jump_total_32 = {{adder1out[31:28]},jumpExt_28};

mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

mult2_to_1_32 mult7(out7,sextad,jump_total_32,jpc_identifier);

mult2_to_1_5 mult9(out9,out6,inst20_16,jpc_identifier);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

mult2_to_1_1 mult8(out8,memtoreg,memToregInvert,branch_and_jump_identifier_single);

//mux with MemToReg control
mult2_to_1_32 mult3(out3,sum,dpack,out8);

mult2_to_1_32 mult5(out5,out3,adder1out,branch_and_jump_identifier_single);

mult2_to_1_5 mult6(out6,out1,5'b11111,branch_and_jump_identifier_single);


//mux with (Branch&ALUZero) control

J_and_B_controller jb(s1,s0,branch_and_jump_identifier,jmadd_ident,z_stored,n_stored);

mult4_to_1_32 mult4(out4,adder2out,out3,jump_total_32,adder1out,s1,s0);

// load pc
 


// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,nout,overflowout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,out7,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch_and_jump_identifier,
aluop1,aluop0,ORIidentifierSignal,statusRegWrite);

//Sign extend unit
signext sext(instruc[15:0],extad,ORIidentifierSignal);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,ORIidentifierSignal,branch_and_jump_identifier_single,gout);

//Shift-left 2 unit
shift shift3(sextad,extad);


//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
always @(negedge clk &first_time_flag)
pc=out4;
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

