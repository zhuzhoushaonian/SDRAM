//注意加入init的初始化模型
/**********************************
如果后期读次数太少的话，此时已经没有了写请求，没有了读请求，就只能等待固定时间来一次的刷新，但由于刷
新被我保持住了（只有读写请求可破保持态），所以会一直刷新（而不是刷一次进入仲裁），从而增大了功率
19.4.29:注意写命令的时候刷新估计还没来到，所以一直不触发刷新请求
**************************************/
`timescale 1ns/1ns
`define CLK100_PERIOD 10

module sdram_control_tb;

`include        "Sdram_Params.h"

	reg                Clk;
	reg                Rst_n;
	
	reg                Wr;
	reg                Rd;	
	reg [`ASIZE-1:0]   Caddr; 
	reg [`ASIZE-1:0]   Raddr; 
	reg [`BSIZE-1:0]   Baddr;	
	reg [`DSIZE-1:0]   Wr_data;
	wire[`DSIZE-1:0]   Rd_data;
	wire               Wr_data_vaild;
	wire               Rd_data_vaild;

	wire               sdram_clk;
	wire               sdram_cke;
	wire               sdram_cs_n;
	wire               sdram_ras_n;
	wire               sdram_cas_n;
	wire               sdram_we_n;
	wire [`BSIZE-1:0]  sdram_bank;
	wire [`ASIZE-1:0]  sdram_addr;
	wire [`DSIZE-1:0]  sdram_dq;
	wire [`DSIZE/8-1:0]sdram_dqm;

	assign sdram_clk = ~Clk;
	
	//wire Rdata_done;
	
	//SDRAM控制器模块例化
	sdram_control sdram_control(		
	
	.Cke(sdram_cke),    //SDRAM时钟使能
	.Ba(sdram_bank),        //SDRAMBank地址 
    .Caddr(Caddr),       //写SDRAM时列地址
	.Raddr(Raddr),        //写SDRAM时行地址
	.Baddr(Baddr),        //写SDRAM时Bank地址 	
	.Dqm(sdram_dqm),      //SDRAM数据掩码
	.Clk(Clk),          //系统时钟信号
	.Rst_n(Rst_n),         //复位信号，低电平有效 
	.Dq(sdram_dq),       //SDRAM数据总线
    .Rd_data(Rd_data),      
 	.Cs_n(sdram_cs_n),     //SDRAM片选信号
	.Ras_n(sdram_ras_n),     //SDRAM行地址选通
	.Cas_n(sdram_cas_n),     //SDRAM列地址选通
	.We_n(sdram_we_n),      //SDRAM写使能         
    .Wr(Wr),           //写SDRAM使能信号
	.Rd(Rd),           //读SDRAM使能信号
	
	//.Wdata_done(),   这两个是送加FIFO后的top层的，用来判断是否需要加上突发长度，暂时不管它
	//.Rdata_done(Rdata_done),
	
	.Sa(sdram_addr),        //SDRAM地址总线
    
	.Wr_data(Wr_data),   //待写入SDRAM数据	
	.Rd_data_vaild(Rd_data_vaild),
	.Wr_data_vaild(Wr_data_vaild)
);

	
	//SDRAM模型例化
	sdr sdram_model(
		.Dq(sdram_dq), 
		.Addr(sdram_addr),
		.Ba(sdram_bank), 
		.Clk(sdram_clk), 
		.Cke(sdram_cke), 
		.Cs_n(sdram_cs_n), 
		.Ras_n(sdram_ras_n), 
		.Cas_n(sdram_cas_n), 
		.We_n(sdram_we_n), 
		.Dqm(sdram_dqm)
	);
	
	initial Clk = 1'b1;
	always #(`CLK100_PERIOD/2) Clk = ~Clk;
	
	initial
	begin
		Rst_n   = 0;
		Wr      = 0;
		Rd      = 0;
		Caddr   = 0;
		Raddr   = 0;
		Baddr   = 0;
		Wr_data = 0;
		#(`CLK100_PERIOD*200+1);
		Rst_n   = 1;
		
		@(posedge sdram_control.sdram_init.Init_done)
		#2000;

		repeat(100)                 //写入100组数据
		begin
			Wr    = 1;
			Baddr = 2;
			#`CLK100_PERIOD;
			Wr    = 0;
			
			if(Caddr == 512-SC_BL)begin
				Caddr = 0; 
				Raddr = Raddr + 1;   //1行写满，行加1
			end
			else
				Caddr = Caddr + SC_BL;

			#5000;                  //延时5us
		end

		Caddr = 0;
		Raddr = 0;
		#5000;
		repeat(100)                //读出100组数据
		begin
			Rd = 1'b1;
			#`CLK100_PERIOD;
			Rd = 1'b0;

			if(Caddr == 512-SC_BL)begin
				Caddr = 0;
				Raddr = Raddr + 1;   //1行读完，行加1
			end
			else
				Caddr = Caddr + SC_BL;
				
			#5000;                  //延时5us
		end

		#5000;
		$stop;
	end
	
	initial
	begin
		forever begin
			@(posedge Wr_data_vaild);
			repeat(SC_BL)            //改变待写入的数据
			begin
				#`CLK100_PERIOD;
				Wr_data = Wr_data + 1;
			end		
		end
	end

endmodule 