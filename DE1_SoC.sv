module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic done_b, done_p, done_o;
	
	logic up, down;
	
	logic color, color_b, color_p;
	
	logic [10:0] x, x_b, x_p, y, y_b, y_p;
	
	logic pixel_write;
	
	//different drawing states
	
	typedef enum { background, player } state;
	
	state state_n, state_c;
	
	//drawing state logic
	always_comb begin
		case (state_c)
			background : if (done_b) state_n = player;
							 else state_n = background;
			player : if (done_p) state_n = background;
						else state_n = player;
			default : state_n = background;
		endcase
	end
	
	always_comb begin
		case (state_c)
			background : begin 
								x = x_b; 
								y = y_b;
								color = color_b;
							 end
			player : begin 
							y = y_p + 11'd159;
							x = x_p;
							color = color_p;
						end
			default : begin
							x = x_b;
							y = y_b;
							color = color_b;
						 end
		endcase
	end

	always_ff @(posedge CLOCK_50) begin
		if (SW[9]) begin
			state_c <= background;
		end else begin
			state_c <= state_n;
		end
		if (state_c != player && state_n == player) begin
			up <= KEY[0];
			down <= KEY[1];
		end
	end
	
	VGA_framebuffer fb(.clk50(CLOCK_50), .reset(SW[9]), .x, .y,
				.pixel_color(color), .pixel_write(1'b1),
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
				
	background_drawer b_d
		(.clk50(CLOCK_50)
		,.reset(SW[9]   )
		,.color(color_b )
		,.x    (x_b     )
		,.y    (y_b     )
		,.done (done_b  )
		);
		
	player_drawer p_d
		(.clk50(CLOCK_50)
		,.reset(SW[9]   )
		,.start(VGA_VS  )
		,.up   (up      )
		,.down (down    )
		,.speed(5'd20 - tens)
		,.color(color_p )
		,.x    (x_p     )
		,.y    (y_p     )
		,.done (done_p  )
		,.pass (pass    )
		,.hit  (hit     )
		);
	
	logic pass, hit;
	logic [6:0] count;
	logic [4:0] ones, tens;
	
	assign ones = count % (5'b01010);
	assign tens = (count - ones) / (5'b01010);
	
	always_ff @(posedge CLOCK_50) begin
		if (SW[9] || count > 7'd99 || hit) count <= 7'b0;
		else if (pass) count <= count + 7'b1;
		else count <= count;
	end
	
	//calculate HEX0
	always_comb begin
		case (ones)
			5'b00000 : HEX0 = 7'b1000000;
			5'b00001 : HEX0 = 7'b1111001;
			5'b00010 : HEX0 = 7'b0100100;
			5'b00011 : HEX0 = 7'b0110000;
			5'b00100 : HEX0 = 7'b0011001;
			5'b00101 : HEX0 = 7'b0010010;
			5'b00110 : HEX0 = 7'b0000010;
			5'b00111 : HEX0 = 7'b1111000;
			5'b01000 : HEX0 = 7'b0000000;
			5'b01001 : HEX0 = 7'b0010000;
			default  : HEX0 = 7'b1111111;
		endcase
	end
	
	//calculate HEX0
	always_comb begin
		case (tens)
			5'b00000 : HEX1 = 7'b1000000;
			5'b00001 : HEX1 = 7'b1111001;
			5'b00010 : HEX1 = 7'b0100100;
			5'b00011 : HEX1 = 7'b0110000;
			5'b00100 : HEX1 = 7'b0011001;
			5'b00101 : HEX1 = 7'b0010010;
			5'b00110 : HEX1 = 7'b0000010;
			5'b00111 : HEX1 = 7'b1111000;
			5'b01000 : HEX1 = 7'b0000000;
			5'b01001 : HEX1 = 7'b0010000;
			default  : HEX1 = 7'b1111111;
		endcase
	end
endmodule
