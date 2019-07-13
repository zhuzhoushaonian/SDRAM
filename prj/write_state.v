		module write_state(
    Clk,
	Rst_n,
	baddr_rr,
	write_en,
	Cs_n,
	Ras_n,
	Cas_n,
	We_n,
	Sa,
	Ba,
	real_raddr_rr,
	real_caddr_rr,   //
	wr_opt_done,
	Wr_data_vaild,
	Wdata_done
	);
	
    `include "Sdram_Params.h"
	
	localparam 
      wr_ACT_TIME = 1'b1,                       //激活行时刻
      wr_WRITE_TIME = SC_RCD+1,                 //写命令时刻,
      wr_PRE_TIME = SC_RCD+SC_BL+WR_PRE+1,      //预充电时刻
      wr_END_TIME = SC_RCD+SC_BL+WR_PRE+REF_PRE;//写操作结束时刻
	input Clk;
	input Rst_n;
	
	input  [`ASIZE-1:0] real_caddr_rr;         //读写列地址寄存器,同样定义为输入

	reg [15:0]      wr_cnt;          //一次突发写操作过程时间计数器
    input  write_en;
	output reg             wr_opt_done;     //一次突发读操作完成标志位
	
	reg [3:0]       Command;	      //操作命令，等于{CS_N,Ras_n,CAS_N,WE}
	output Cs_n;      //SDRAM片选信号               应该没影响吧，同样的名字的话
	output Ras_n;     //SDRAM行地址选通
	output Cas_n;     //SDRAM列地址选通
	output We_n;      //SDRAM写使能  
	//SDRAM命令信号组合
	assign {Cs_n,Ras_n,Cas_n,We_n} = Command;
	output reg[`ASIZE-1:0]Sa;        //SDRAM地址总线
	output reg[`BSIZE-1:0]Ba;        //SDRAMBank地址 
	
	input  [`BSIZE-1:0]baddr_rr;         //写时候bank地址寄存器，待会在总的那里由Bank给它
	
	
	input  [`ASIZE-1:0] real_raddr_rr;   //同样这个待会也有总代码的文件里头的real_raddr给它，这个我定义为input
	
	
	output reg        Wr_data_vaild; //写SDRAM时数据有效区
	//写数据操作，数据写入(改变)时刻有效区间,这个应该是表明正在写的时候，为了能够将输入的数据在写阶段送到数据总线上
	output Wdata_done;
	//一次突发写操作数据写完成标志位
	assign Wdata_done = (wr_cnt == SC_RCD+SC_BL+1)?1'b1:1'b0;
	
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			Wr_data_vaild <= 1'b0;
		else if((wr_cnt > SC_RCD)&&(wr_cnt < SC_RCD+SC_BL+1))    //这里之所以这个时间段，排除掉了ACT，以免数据丢失,这个额范围是最好的结果,会建立保持时间不够而丢失掉最后一个值
	   // else if((wr_cnt > 1)&&(wr_cnt < SC_RCD+1))            //写命令时刻	
    		Wr_data_vaild <= 1'b1; 
		else
			Wr_data_vaild <= 1'b0;
	end
	
	//一次突发写操作过程时间计数器
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)	
			wr_cnt <= 16'd0;
		else if (write_en == 0)
		    wr_cnt <= 16'b0;
		else if((wr_cnt == wr_END_TIME))
		    wr_cnt <= 16'b0;
		else
			wr_cnt <= wr_cnt + 16'd1;
	end

	//一次写操作过程完成标志位
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			wr_opt_done <= 1'b0;
		else if(wr_cnt == wr_END_TIME)
			wr_opt_done <= 1'b1;
		else
			wr_opt_done <= 1'b0;
	end

	

	
   
	
	
	
	//一次突发写操作任务,类似线性序列机方法，不带自动预充电的写时序
    always@(posedge Clk or negedge Rst_n)   begin 
	if(!Rst_n)
	Command <= 4'dx;
	else 
        begin
			case(wr_cnt)
				wr_ACT_TIME:begin
					Command <= C_ACT;
					Sa <= real_raddr_rr;             //激活行	raddr_r
					Ba <= baddr_rr;
				end

				wr_WRITE_TIME:begin
					Command <= C_WR;
					Sa <= {1'b0,real_caddr_rr[8:0]}; //激活列
					Ba <= baddr_rr;
				end

				wr_PRE_TIME:begin				
					Command <= C_PRE;          //预充电
					Sa[10] <= 1'b1;
				end

				wr_END_TIME:begin
					Command <= C_NOP;
				end

				default:
					Command <= C_NOP;
			endcase
	    end	
	end 

	endmodule
	//---------------------------------	