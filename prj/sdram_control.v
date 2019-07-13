module sdram_control(
    Cke,    //SDRAM时钟使能
	Ba,        //SDRAMBank地址 
    Caddr,       //写SDRAM时列地址
	Raddr,        //写SDRAM时行地址
	Baddr,        //写SDRAM时Bank地址
  	 	
	Dqm,      //SDRAM数据掩码
	Clk,          //系统时钟信号
	Rst_n,         //复位信号，低电平有效 
	Dq,       //SDRAM数据总线
    Rd_data,      

 	Cs_n,     //SDRAM片选信号
	Ras_n,     //SDRAM行地址选通
	Cas_n,     //SDRAM列地址选通
	We_n,      //SDRAM写使能         
    Wr,           //写SDRAM使能信号
	Rd,           //读SDRAM使能信号
	Sa,        //SDRAM地址总线

	Wr_data,    //待写入SDRAM数据	
	Rd_data_vaild, //读SDRAM时数据有效区
	Wr_data_vaild, //写SDRAM时数据有效区
	Wdata_done,   //一次写完成的突发长度的标志位
	Rdata_done
);

`include        "Sdram_Params.h"

	//---------------------------------------------------------------------------------------------------------------------
    output               Cke;       //SDRAM时钟使能
	output reg  [`BSIZE-1:0]Ba;        //SDRAMBank地址 
	wire [`BSIZE-1:0]Ba_read;     
	wire [`BSIZE-1:0]Ba_write;

    input [`ASIZE-1:0]Caddr ;         //写SDRAM时列地址
	input [`ASIZE-1:0]Raddr ;         //写SDRAM时行地址
	input [`BSIZE-1:0]Baddr ;         //写SDRAM时Bank地址
    reg [`ASIZE-1:0]raddr_r;         //读写行地址寄存器
	reg [`ASIZE-1:0]caddr_r;         //读写列地址寄存器
	reg [`BSIZE-1:0]baddr_r;         //读写bank地址寄存器		 	
	output[`DSIZE/8-1:0]  Dqm;       //SDRAM数据掩码
	input             Clk;           //系统时钟信号
	input             Rst_n;         //复位信号，低电平有效 
	inout [`DSIZE-1:0]    Dq;        //SDRAM数据总线
    output[`DSIZE-1:0]Rd_data;      

 	output   reg      Cs_n;      //SDRAM片选信号
	output   reg       Ras_n;     //SDRAM行地址选通
	output   reg      Cas_n;     //SDRAM列地址选通
	output   reg      We_n;      //SDRAM写使能         
   //SDRAM命令信号组合
	wire            init_done;       //SDRAM初始化完成标志位
	reg [31:0]      ref_time_cnt;    //刷新定时计数器	
	wire            ref_time_flag;   //刷新定时时间标志位，定时到达时置1
    input             Wr ;            //写SDRAM使能信号
	input             Rd ;            //读SDRAM使能信号
    reg	reme_wri_are  = 1'bx;
	reg	reme_rea_are  = 1'bx;
	reg	reme_wri_wri  = 1'bx;
	reg	reme_aref_wri = 1'bx;
	reg	reme_rea_wri  = 1'bx;
	reg	reme_wri_rea  = 1'bx;
	reg	reme_aref_rea = 1'bx;   
	reg	reme_rea_rea  = 1'bx;
    reg [3:0]       main_state;      //主状态寄存器
	output reg  [`ASIZE-1:0]Sa;        //SDRAM地址总线
	
	output Wdata_done;
	output Rdata_done;
	
	wire [`ASIZE-1:0]Sa_read;        
	wire [`ASIZE-1:0]Sa_ref;        
	wire [`ASIZE-1:0]Sa_write;       

	wire [3:0]      init_cmd;        //SDRAM初始化命令输出
	wire[`ASIZE-1:0]init_addr;       //SDRAM初始化地址输出
    reg auto_refre_en = 1'bx ;
	reg read_en = 1'bx;
	reg write_en = 1'bx;
    wire             ref_opt_done;    //一次刷新操作完成标志位
	wire             wr_opt_done;     //一次突发写操作完成标志位
	reg             rd_opt_done;     //一次突发读操作完成标志位
	input [`DSIZE-1:0]Wr_data;       //待写入SDRAM数据	
	output         Rd_data_vaild; //读SDRAM时数据有效区
	output         Wr_data_vaild; //写SDRAM时数据有效区
	wire cs_n_read;
	wire cs_n_ref;
	wire cs_n_write;
	wire ras_n_read;
	wire ras_n_ref;
	wire ras_n_write;
	wire cas_n_read;
	wire cas_n_ref;
	wire cas_n_write;
	wire we_n_read;
	wire we_n_ref;
	wire we_n_write;
	reg [`ASIZE-1:0] real_caddr_r;  
	//reg [`ASIZE-1:0] real_raddr_r;

	localparam 
		JUDGE  = 4'b0001,  //仲裁状态
	    AREF   = 4'b0010,  //刷新
		WRITE  = 4'b0100,  //写
		READ   = 4'b1000;  //读
	
  //---------------------------------------------------------------------------------------------------------------------
	
	//数据掩码，采用16位数据，掩码为全零
	assign Dqm = 2'b00;	
	assign Cke = Rst_n;

	//自动刷新操作的线性序列机
	auto_refre_state  auto_refre_state(
	.Clk(Clk),
	.Rst_n(Rst_n),
	.Cs_n(cs_n_ref),
	.Ras_n(ras_n_ref),
	.Cas_n(cas_n_ref),
	.We_n(we_n_ref),
	.Sa(Sa_ref),
	.auto_refre_en(auto_refre_en),
	.ref_opt_done(ref_opt_done)
	);
	//---------------------------------	
		
	write_state  write_state(
	.Clk(Clk),
	.Rst_n(Rst_n),
	.baddr_rr(baddr_r),
	.write_en(write_en),   //状态跳转到什么时候，写使能为1呢
	.Cs_n(cs_n_write),
	.Ras_n(ras_n_write),
	.Cas_n(cas_n_write),
	.We_n(we_n_write),
	.Sa(Sa_write),
	.Ba(Ba_write),
	.real_raddr_rr(raddr_r),
	//.real_raddr_rr(real_raddr_r),
	.real_caddr_rr(real_caddr_r),  
   .wr_opt_done(wr_opt_done),
	.Wr_data_vaild(Wr_data_vaild),
	.Wdata_done(Wdata_done)
	);
	

     //SDRAM数据线，采用三态输出
	assign Dq = Wr_data_vaild ? Wr_data:16'bz;
	
	//读数据
    assign Rd_data = Dq;  //这个是为了方便数据类型的转换么？
	
	read_state read_state(
	.Clk(Clk),
	.Rst_n(Rst_n),
	.Cs_n(cs_n_read),
	.Ras_n(ras_n_read),
	.Cas_n(cas_n_read),
	.We_n(we_n_read),
	.Sa(Sa_read),
	.Ba(Ba_read),
	.read_en(read_en),
	//.real_raddr_rr(real_raddr_r),
    .real_raddr_rr(raddr_r),	
	.real_caddr_rr(real_caddr_r),
	.Rd_data_vaild(Rd_data_vaild),  //暂时没有什么用，不过待会用到了FIFO的时候就有用了
	.Rdata_done(Rdata_done)
	);
	//---------------------------------
	

	always@(posedge Clk ,negedge Rst_n)  begin 
	if(!Rst_n) begin 
      Ba <= 0;
	  Sa <= 0;
	  Cs_n <= 0;
	  Ras_n <= 0;
	  Cas_n <= 0;
	  We_n <= 0;
	  end 
	else if(main_state == READ) begin 
	  Ba <= Ba_read;
	  Sa <= Sa_read;
	  Cs_n <=  cs_n_read; 
	  Ras_n <= ras_n_read; 
	  Cas_n <=  cas_n_read;
	  We_n <= we_n_read;
	  end 
	else if(main_state == WRITE) begin 
	  Ba <= Ba_write;
	  Sa <= Sa_write;
	  Cs_n <= cs_n_write;
	  Ras_n <=ras_n_write;
	  Cas_n <=cas_n_write;
	  We_n <= we_n_write;
	  end 
	else if(main_state == AREF) begin 
	  Sa <= Sa_ref;
	  Cs_n <= cs_n_ref;   
	  Ras_n <= ras_n_ref;	  
	  Cas_n <= cas_n_ref;
	  We_n <= we_n_ref;
      end 
	else if(main_state == JUDGE) begin 
	 Sa <= init_addr;
	 {Cs_n,Ras_n,Cas_n,We_n} <= init_cmd;//先写二段状态机，后来再改成三段的
	  end 
	else begin 
	  Ba <= Ba;
	  Sa <= Sa;
	  Cs_n <=  Cs_n;
	  Ras_n <= Ras_n;
	  Cas_n <= Cas_n;
	  We_n <= We_n;
	  end 
	end 
	  
	//---------------------------------	
	//SDRAM前期初始化模块例化	
	sdram_init sdram_init(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Command(init_cmd),
		.Saddr(init_addr),
		.Init_done(init_done)
	);	
	
	
/********接下来的是为了完成四个请求参数,完成优先级判断部分********/
	//刷新定时计数器
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			ref_time_cnt <= 0;
		else if(ref_time_cnt == AUTO_REF)
			ref_time_cnt <= 1;
		else if(init_done || ref_time_cnt > 0)
			ref_time_cnt <= ref_time_cnt + 10'd1;
		else
			ref_time_cnt <= ref_time_cnt;
	end

	//刷新定时时间标志位，定时到达时置1，定时时间到ref_time_flag
	assign ref_time_flag = (ref_time_cnt == AUTO_REF);	
    wire [2:0] request_total; 
    assign request_total = {Wr,Rd,ref_time_flag};  

//权衡wr，rd，ref_time_flag三者是否互相冲突而导致的判断
 reg read_request;
 always@(posedge Clk or negedge Rst_n) begin 
 if(!Rst_n)
 read_request <= 1'b0;
 else if (request_total == 3'b010)
 read_request <= 1'b1;
 else
 read_request <= 1'b0;
 end
 
 reg write_request;
 always@(posedge Clk or negedge Rst_n) begin 
 if(!Rst_n)
 write_request <= 1'b0;
 else if ((request_total == 3'b100)||(request_total == 3'b110))
 write_request <= 1'b1;
 else
 write_request <= 1'b0;
 end
 
  reg aref_request;
  always@(posedge Clk or negedge Rst_n) begin 
 if(!Rst_n)
 aref_request <= 1'b0;
 else if (ref_time_flag)
 aref_request <= 1'b1;
 else
 aref_request <= 1'b0;
 end
   
   reg no_request;
 always@(posedge Clk or negedge Rst_n) begin 
 if(!Rst_n)
 no_request <= 1'b0;
 else if (request_total == 000)
 no_request <= 1'b1;
 else
 no_request <= 1'b0;
 end
 
 

   //主状态机
 always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)begin
			main_state <= JUDGE;  //我认为这个是000状态；
		          end
		else begin
			case(main_state)
				JUDGE:begin
                       write_en <= 0;
					   auto_refre_en <= 0;
					   read_en <= 0;
					   
					if(aref_request == 1)
					   main_state <= AREF;
					else if(read_request == 1)
					   main_state <= READ;
					else if(write_request == 1)
					   main_state <= WRITE;
					else 
					   main_state <= JUDGE;
				end

				AREF:begin
				    auto_refre_en <= 1;
	                read_en <= 0;
					write_en <= 0;
					
					reme_wri_are <= 0;
					reme_rea_are <= 0;
					
                    if(aref_request == 1)
                        main_state <= AREF;
                    else if ((reme_aref_wri == 1) && (ref_opt_done == 1))
					    main_state <= WRITE;
					else if(write_request == 1) 
                        reme_aref_wri <= 1; 
				    else if(read_request == 1) 
					    reme_aref_rea <= 1;
            		else if ((reme_aref_rea == 1)&& (ref_opt_done == 1))
					    main_state <= READ;
					else if ((aref_request == 0)&&(ref_opt_done == 0))
					    ;   //无操作状态，也就是说如果中途刷新中，保持就保持
					else 
					    main_state <= JUDGE;
					 end	
	

				WRITE:begin
				       write_en <= 1;
					   auto_refre_en <= 0;
					   read_en <= 0;
					   
					   reme_wri_wri <= 0;
					   reme_aref_wri <= 0;
					   reme_rea_wri <= 0;
					//记住的操作   
					if(aref_request == 1)
					   reme_wri_are <= 1;  //你记住之后，用完了记得清楚掉啊
					else if(read_request == 1)
					   reme_wri_rea <= 1;
					else if(write_request == 1)
					   reme_wri_wri <= 1;
					   
					//状态跳转
					else if ((reme_wri_are == 1)&&(wr_opt_done == 1))
					   main_state <= AREF;
					else if ((reme_wri_rea == 1)&&(wr_opt_done == 1))
					   main_state <= READ;
					else if ((reme_wri_wri == 1)&&(wr_opt_done == 1))
					   main_state <= WRITE;
					else if(wr_opt_done == 0)
					   ;
					else 
					   main_state <= JUDGE;
					 end 
					
				READ:begin
					read_en <= 1;
					auto_refre_en <= 0;
					write_en <= 0;
					
					reme_wri_rea <= 0;
					reme_aref_rea <= 0;   
					reme_rea_rea <= 0;
					//记住操作
					if(aref_request == 1)
					   reme_rea_are <= 1;
					else if(read_request == 1)
					   reme_rea_rea <= 1;
					else if(write_request == 1)
					   reme_rea_wri <= 1;
					   
					//状态跳转
					else if ((reme_rea_are == 1)&&(rd_opt_done == 1))
					   main_state <= AREF;
					else if ((reme_rea_rea == 1)&&(rd_opt_done == 1))
					   main_state <= READ;
					else if ((reme_rea_wri == 1)&&(rd_opt_done == 1))
					   main_state <= WRITE;
					else if(rd_opt_done == 0)
					   ;
					else 
					   main_state <= JUDGE;
					end 

			endcase
		    end
	end
	//---------------------------------	
	
	
	//---------------------------------	
	//读写行列地址寄存器，能够在原来的读写基础上进行的继续读写的缘故便是这里了
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
		begin
			raddr_r <= 0;
			caddr_r <= 0;
			baddr_r <= 0;
		end
		else if((reme_wri_wri) ||(reme_aref_wri)||(reme_rea_wri)||(reme_wri_rea)||(reme_aref_rea)||(reme_rea_rea))     
		begin
			raddr_r <= Raddr;
			caddr_r <= Caddr;
			baddr_r <= Baddr;
		end
		else
			;
	end	

	//我还是想不到办法解决，我写入数据在后头，然后接下来读出数据前头，然后我接下里再写入，那么应该是从前头写入还是下一行另起写入呢，如何判断数据存储是否为空？
	//你这个是持续的写入读出超出过一个突发长度的思考
	//always@(posedge Clk or negedge Rst_n)
	//begin
	//	if(!Rst_n)
	//	  real_raddr_r <= 0;
	//    else if((512 - real_caddr_r)< SC_BL)  //一行（列数）快完的时候，则另起一行，行标志位加一，但末尾剩下数据还是会读写出（一次性读写出突发长度的数据嘛）
	//    real_raddr_r <= real_raddr_r + 1;
	//	else 
	//	real_raddr_r <= raddr_r;
	//end
	
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
		  real_caddr_r <= 0;
		 else if(wr_opt_done) //每次写完的时候加上突发长度,但是这个写完不是一次突发长度写完的意思，而是彻底换命令的意思
		  real_caddr_r <= real_caddr_r + SC_BL;
		 else if(rd_opt_done)  //每次读完的时候
		  real_caddr_r <= real_caddr_r + SC_BL;
		 else if(Wdata_done)
		  real_caddr_r <= real_caddr_r + SC_BL;
         else if(Rdata_done)
		  real_caddr_r <= real_caddr_r + SC_BL;
		 else if((512 - real_caddr_r)< SC_BL) 
		  real_caddr_r <= 0;
		 else 
		  real_caddr_r <= caddr_r;
	end
	
	//那么bank地址呢？它不做改变，暂时不做判断，直接写入，1写完则写入到2

	
endmodule 