	module read_state(
	Clk,
	Rst_n,
   Cs_n,      //SDRAM片选信号
	Ras_n,     //SDRAM行地址选通
	Cas_n,    //SDRAM列地址选通
	We_n,     //SDRAM写使能  
	Sa,
	Ba,
	read_en,
	real_raddr_rr,
	real_caddr_rr,
	Rd_data_vaild,
	Rdata_done
	);	
	
	`include "Sdram_Params.h"

	localparam
		rd_ACT_TIME  = 1'b1,              //激活行时刻
		rd_READ_TIME = SC_RCD+1,          //读命令时刻
		rd_PRE_TIME  = SC_RCD+SC_BL+2,    //预充电时刻
		rd_END_TIME  = SC_RCD+SC_CL+SC_BL;//读操作结束时刻
 
    input Clk;
	input Rst_n;
	reg [15:0]      rd_cnt;          //一次突发读操作过程时间计数器	
	reg             rd_opt_done;     //一次突发读操作完成标志位
	output  Rdata_done;
	output                Cs_n;      //SDRAM片选信号
	output                Ras_n;     //SDRAM行地址选通
	output                Cas_n;     //SDRAM列地址选通
	output                We_n;      //SDRAM写使能    
	//SDRAM命令信号组合
   reg [3:0]       Command;	      //操作命令，等于{CS_N,Ras_n,CAS_N,WE}
   assign {Cs_n,Ras_n,Cas_n,We_n} = Command;

	output reg[`ASIZE-1:0]Sa;        //SDRAM地址总线
	output reg[`BSIZE-1:0]Ba;        //SDRAMBank地址 
	input  [`ASIZE-1:0] real_raddr_rr;   //同样这个待会也有总代码的文件里头的real_raddr给它，这个我定义为input
	reg [`BSIZE-1:0]baddr_rr;         //读写bank地址寄存器		

	input  [`ASIZE-1:0] real_caddr_rr;         //读写列地址寄存器,同样定义为输入，待会由caddr给它就行了
	reg             wr_opt_done;     //一次突发写操作完成标志位

	input read_en;
	
	output reg        Rd_data_vaild; //读SDRAM时数据有效区
	
	 //一次突发读操作过程中数据读完标志位
	assign Rdata_done = (rd_cnt == rd_END_TIME)?1'b1:1'b0;

	//读数据操作，数据有效区
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			Rd_data_vaild <= 1'b0;
		else if((rd_cnt > SC_RCD+SC_CL)&&(rd_cnt <= SC_RCD+SC_CL+SC_BL))
			Rd_data_vaild <= 1'b1;
		else
			Rd_data_vaild <= 1'b0;
	end
	
	//一次突发读操作过程时间计数器
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			rd_cnt <= 16'd0;
		else if((rd_cnt == rd_END_TIME))  //同样这里的计数器被我简化掉了
			rd_cnt <= 16'd0;
		else if(read_en == 0)
		    rd_cnt <= 16'd0;
		else 
			rd_cnt <= rd_cnt + 16'd1;
	end

	//一次突发读操作过程完成标志位	
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			rd_opt_done <= 1'b0;
		else if(rd_cnt == rd_END_TIME)
			rd_opt_done <= 1'b1;
		else
			rd_opt_done <= 1'b0;
	end




	
	//一次突发读操作任务,类似线性序列机方法，同样还是不带自动预充电
 
    always@(posedge Clk or negedge Rst_n)  begin 
    if(!Rst_n)  
    Command <= 4'bx;
    else 	
  	begin
		case(rd_cnt)
			rd_ACT_TIME:begin			     
				Command <= C_ACT;
				Sa <= real_raddr_rr; 
				Ba <= baddr_rr;
			end

			rd_READ_TIME:begin			 
				Command <= C_RD;
				Sa <= {1'b0,real_caddr_rr[8:0]};
				Ba <= baddr_rr;
			end

			rd_PRE_TIME:begin
				Command <= C_PRE;        
				Sa[10] <= 1'b1;
			end
			
			rd_END_TIME:begin
				Command <= C_NOP;
			end
			
			default:
				Command <= C_NOP;
		endcase
		end
	  end 
	 endmodule
	//---------------------------------