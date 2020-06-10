module J_and_B_controller(out1,out0,j_b,jmadd_ident,zerin,negin);
input[3:0] j_b;
input wire zerin,negin,jmadd_ident;
wire j_b_0=j_b[0],j_b_1=j_b[1],j_b_2=j_b[2],j_b_3=j_b[3];
output reg out0,out1;

always@(jmadd_ident or j_b_0 or j_b_1 or j_b_2 or negin or zerin)
	begin

	if(jmadd_ident)
	begin
		out0=1'b0;//adress
		out1=1'b1;
	end
	else if(negin&j_b_0&~j_b_1)
	begin
		out0=1'b1;//jump
		out1=1'b1;
	end
	else if(~zerin&~j_b_3&j_b_2)
	begin
		out0=1'b1;
		out1=1'b0;//brench
	end
	else if(~j_b_0&j_b_1)
	begin
		out0=1'b1;//brench
		out1=1'b0;
	end
	else
	begin
		out0=1'b0;//default pc=pc+4
		out1=1'b0;
	end
			
	/*
	case({jmadd_ident,j_b,negin,zerocurrent})
		7'b1xxxxxx:begin//adress
		 out0=1'b0;
		 out1=1'b1;
		end
		7'b0xx10xx:begin//jump
		 out0=1'b1;
		 out1=1'b1;
		end
		7'b0x10xxx:begin//brecnh

		 out0=1'b1;
		 out1=1'b0;
		end
		 7'b0x10xx1:begin//brench
		 out0=1'b1;
		 out1=1'b0;
		end
		default:begin//default pc=pc+4

		 out0=1'b0;
		 out1=1'b0;
		end
	endcase*/
end
endmodule