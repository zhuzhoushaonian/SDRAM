`timescale 1ns/1ns
`define CLK100_PERIOD 10
`define WCLK_PERIOD   40
`define RCLK_PERIOD   40

module sdram_control_top_tb;

`include        "Sdram_Params.h"

	reg               Clk;
	reg               Rst_n;

   reg [`DSIZE-1:0]  Wr_data;
   reg               Wr_en;
   reg               Wr_load;
   reg               Wr_clk;

   wire[`DSIZE-1:0]  Rd_data;
   reg					Rd_en;
   reg					Rd_load;
   reg					Rd_clk;


	
	wire[`ASIZE-1:0]  Sa;
	wire[`BSIZE-1:0]  Ba;
	wire              Cs_n;
	wire              Cke;
	wire              Ras_n;
	wire              Cas_n;
	wire              We_n;
	wire[`DSIZE-1:0]  Dq;
	wire[`DSIZE/8-1:0]Dqm;

	wire sdram_clk;
	
	assign sdram_clk = ~Clk;

	sdram_control_top sdram_control_top(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Sd_clk(sdram_clk),

		.Wr_data(Wr_data),
		.Wr_en(Wr_en),
		.Wr_addr(0),        //閸愭瑥鍙嗛惃鍕崳婵缍呯純
		.Wr_max_addr(1000),
		.Wr_load(Wr_load),
		.Wr_clk(Wr_clk),
		.Wr_full(),
		.Wr_use(),

		.Rd_data(Rd_data),
		.Rd_en(Rd_en),
		.Rd_addr(0),             //鐠囪鍤惃鍕崳婵缍呯純
		.Rd_max_addr(1000),
		.Rd_load(Rd_load),
		.Rd_clk(Rd_clk),
		.Rd_empty(),
		.Rd_use(),

		.Sa(Sa),
		.Ba(Ba),
		.Cs_n(Cs_n),
		.Cke(Cke),
		.Ras_n(Ras_n),
		.Cas_n(Cas_n),
		.We_n(We_n),
		.Dq(Dq),
		.Dqm(Dqm)
	
	);

	//SDRAM濡€崇€锋笟瀣
	sdr sdram_model(
		.Dq(Dq),
		.Addr(Sa),
		.Ba(Ba),
		.Clk(sdram_clk),
		.Cke(Cke),
		.Cs_n(Cs_n),
		.Ras_n(Ras_n),
		.Cas_n(Cas_n),
		.We_n(We_n),
		.Dqm(Dqm)
		);

	//SDRAM閹貉冨煑閸ｃ劍妞傞柦
	initial Clk = 1'b1;
	always #(`CLK100_PERIOD/2) Clk = ~Clk;
	//閸愭瑦鏆熼幑顔煎煂SDRAM閺冨爼鎸?
	initial Wr_clk = 1'b1;
	always #(`WCLK_PERIOD/2) Wr_clk = ~Wr_clk;
	//鐠囩粯鏆熼幑顔煎煂SDRAM閺冨爼鎸?
	initial Rd_clk = 1'b1;
	always #(`RCLK_PERIOD/2) Rd_clk = ~Rd_clk;

	initial
	begin     //閸掓繂顫愰崠鏍ㄢ偓璁崇秼閻ㄥ嫮閮寸紒
		Rst_n   = 0;
		Wr_load = 1;
		Rd_load = 1;
		Wr_data = 0;
		Wr_en   = 0;
		Rd_en   = 0;
		#(`CLK100_PERIOD*200+1)
		Rst_n   = 1;
		Wr_load = 0;
		Rd_load = 0;
		

		@(posedge sdram_control_top.sdram_control.init_done)
		#2000;

		//鐠囪鍟撻弫鐗堝祦閿涘苯鍘涘鈧崥顖濆厴婢剁喕顕伴崘姗FO閿涘苯顕甋DRAM閺嗗倹妞傛潻妯荤梾瀵偓闁?		
		Wr_en   = 1;
		Rd_en   = 0;   
		
		//瀵偓闁艾顕甋DRAM閻ㄥ嫭鎼锋担婊€绨?
		repeat(2000)
		begin
			#(`WCLK_PERIOD);
			Wr_data = Wr_data + 1;
      end 
 	  #(`CLK100_PERIOD*2)
		Wr_en   = 1'b0;
		#50000;
		Rd_en   = 1'b0;    //閸忔娊妫寸拠璁冲▏閼?	   
	
		
	      #6000;
			$stop; //鐠囪崵娈戦悩鑸碘偓浣瑰灉閺嗗倹妞傛稉宥囶吀閻?
			end 
endmodule
