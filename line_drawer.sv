
module line_drawer
	( input  logic        clk
	, input  logic        reset
	
	, input  logic [10:0] x0
	, input  logic [10:0] y0
	, input  logic [10:0] x1
	, input  logic [10:0] y1
	
	, output logic [10:0] x
	, output logic [10:0] y
	);
	
	logic [10:0] x0_s, x0_s_n;
	logic [10:0] x1_s, x1_s_n;
	logic [10:0] y0_s, y0_s_n;
	logic [10:0] y1_s, y1_s_n;
	
	logic [10:0] x_n;
	logic [10:0] y_n;
	logic [10:0] y_step;
	
	logic [14:0] deltay, deltax;
	logic signed [14:0] error, error_n;

	logic state, state_n;
	
	logic is_steep, is_steep_n;
	
	logic [10:0] y_temp, x_temp;
	
	//abs(y1 - y0), abs(x1 - x0)
	assign y_temp = (y1 >= y0) ? (y1 - y0) : (y0 - y1);
	assign x_temp = (x1 >= x0) ? (x1 - x0) : (x0 - x1);
		
	//calculate or hold is_steep
	assign is_steep_n = (state) ? is_steep : (y_temp > x_temp);
	
	//calculate endpoints
	always_comb begin
		if (state) begin
			y1_s_n = y1_s; //keep the endpoints the same during computation
			y0_s_n = y0_s;
			x1_s_n = x1_s;
			x0_s_n = x0_s;
		end else begin
			if (is_steep) begin //Initialization of the input x's and y's
				if (x0 > x1) begin
					y1_s_n = x0;
					y0_s_n = x1;
					x1_s_n = y0;
					x0_s_n = y1;
				end else begin
					y1_s_n = x1;
					y0_s_n = x0;
					x1_s_n = y1;
					x0_s_n = y0;
				end
			end else begin
				if (x0 > x1) begin
					y1_s_n = y0;
					y0_s_n = y1;
					x1_s_n = x0;
					x0_s_n = x1;
				end else begin
					y1_s_n = y1;
					y0_s_n = y0;
					x1_s_n = x1;
					x0_s_n = x0;
				end
			end
		end
	end
	
	//calculate deltax and deltay
	assign deltax = ((x1_s_n - x0_s_n) << 3) + ((x1_s_n - x0_s_n) << 1);
	assign deltay = (y1_s_n >= y0_s_n) ? ((y1_s_n - y0_s_n) << 3) + ((y1_s_n - y0_s_n) << 1): ((y0_s_n - y1_s_n) << 3) + ((y0_s_n - y1_s_n) << 1);
	
	assign y_step = (y1_s_n > y0_s_n) ? 11'b00000000001 : 11'b11111111111;
	
	//calculate error
	always_comb begin
		if (state) begin
			if(error >= -deltay) begin
				error_n = error + deltay - deltax;
			end else begin
				error_n = error + deltay;
			end
		end else begin
			error_n = -{deltax[10], deltax[10], deltax[10:1]};
		end
	end
	
	//calculate next pixel
	always_comb begin
		if (state) begin
			if (is_steep) begin
				x_n = (error >= -deltay) ? y + y_step : y;
				y_n = x + 11'b1;
			end else begin
				x_n = x + 11'b1;
				y_n = (error >= -deltay) ? y + y_step : y;
			end
		end else begin
			x_n = x0_s_n;
			y_n = y0_s_n;
		end
	end
	
	//calculate next state
	always_comb begin
		if (reset) begin
			state_n = 1'b0;
		end else begin
			case (state) 
				1'b0 : state_n = 1'b1;
				1'b1 : if ((x + 1) == x1_s_n) state_n = 1'b0;
						 else state_n = 1'b1;
			endcase
		end
	end
	
	//save data
	always_ff @(posedge clk) begin
		if (is_steep) begin
			y <= x_n;
			x <= y_n;
		end else begin
			y <= y_n;
			x <= x_n;
		end
		
		state <= state_n;
		is_steep <= is_steep_n;
		y1_s <= y1_s_n;
		y0_s <= y0_s_n;
		x1_s <= x1_s_n;
		x0_s <= x0_s_n;
		error <= error_n;
	end  
   
endmodule

module line_drawer_tesbench 
	(
	);
	
	logic        clk;
	logic        reset;
	
	logic [10:0] x0;
	logic [10:0] y0;
	logic [10:0] x1;
	logic [10:0] y1;

	logic [10:0] x;
	logic [10:0] y;
	
	line_drawer dut
		(.clk(clk)
		,.reset(reset)
		,.x0(x0)
		,.x1(x1)
		,.y0(y0)
		,.y1(y1)
		,.x(x)
		,.y(y)
		);
		
	initial begin
		x0 <= 1; x1 <= 12; y0 <= 1; y1 <= 5; reset <= 1; 
																		 clk <= 0; #10;
		x0 <= 1; x1 <= 12; y0 <= 1; y1 <= 5; reset <= 0; clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
		x0 <= 0; x1 <= 120; y0 <= 50; y1 <= 75; 			 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 clk <= 0; #10;
																		 clk <= 1; #10;
																		 	
		
		$stop;
	end
endmodule	
