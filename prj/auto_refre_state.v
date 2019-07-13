	module auto_refre_state(
	Clk,
	Rst_n,
	Cs_n,
	Ras_n,
	Cas_n,
	We_n,
	Sa,
	auto_refre_en,
	ref_opt_done
);	 
	`include "Sdram_Params.h"
	
	input Clk;
	input Rst_n; 
	reg [15:0]     ref_cnt;         //自动刷新过程时间计数器	
   output  reg ref_opt_done;
	reg [3:0]       Command;	      //操作命令，等于{CS_N,Ras_n,CAS_N,WE}

    input auto_refre_en;                       //什么时候开始自动刷新操作的启动信号

  output  Cs_n;      //SDRAM片选信号
  output  Ras_n;     //SDRAM行地址选通
  output  Cas_n;     //SDRAM列地址选通
  output  We_n;      //SDRAM写使能  
	//SDRAM命令信号组合
	assign {Cs_n,Ras_n,Cas_n,We_n} = Command;
	output reg[`ASIZE-1:0]Sa;        //SDRAM地址总线

	
	 localparam 
      ref_PRE_TIME = 1'b1,              //预充电时刻
      ref_REF1_TIME = REF_PRE+1,        //第一次自动刷新时刻
      ref_REF2_TIME = REF_PRE+REF_REF+1,//第二次自动刷新时刻
      ref_END = REF_PRE+REF_REF*2;      //自动刷新结束时刻  
	  
	//自动刷新过程时间计数器
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			ref_cnt <= 16'd0;
		else if (auto_refre_en == 0)
		    ref_cnt <= 16'd0;
		else if ( (ref_cnt == ref_END) )    
			ref_cnt <= 16'd0;
		else 
			ref_cnt <= ref_cnt + 16'd1;
	end	

	//一次刷新操作完成标志位
	always@(posedge Clk or negedge Rst_n) 
	begin
		if(!Rst_n)
			ref_opt_done <= 1'b0;
		else if(ref_cnt == ref_END)
			ref_opt_done <= 1'b1;
		else
			ref_opt_done <= 1'b0;
	end

	

	//自动刷新操作的线性序列机
	//task auto_refre;   
	always@(posedge Clk,negedge Rst_n)
	begin
		if(!Rst_n)
			begin 
				Command <= 4'bx;
			end 
		else begin 
		case(ref_cnt)
			ref_PRE_TIME:begin
				Command <= C_PRE;     //预充电
				Sa[10] <= 1'b1;					
			end				
			
			ref_REF1_TIME:begin
				Command <= C_AREF;    //自动刷新
			end
			
			ref_REF2_TIME:begin
				Command <= C_AREF;    //自动刷新
			end
			
			ref_END:begin
			//	FF <= 1'b1;
				Command <= C_NOP;
			end

			default:
				Command <= C_NOP;			
		endcase	
              end 		
	end
endmodule
	//---------------------------------
