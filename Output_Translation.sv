// this module is the Output_Translation for the count into the correct HEX outputs
// count is the input from the counter module 
// HEX0 - HEX5 are the output outputs to display the correct numbers and full and clear
module Output_Translation
	( input  logic [4:0] count
	, output logic [6:0] HEX0
	, output logic [6:0] HEX1
	, output logic [6:0] HEX2
	, output logic [6:0] HEX3
	, output logic [6:0] HEX4
	, output logic [6:0] HEX5
	);
	
	logic [4:0] ones, tens;
	
	assign ones = count % (5'b01010);
	assign tens = (count - ones) / (5'b01010);
	
	
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

	//calculate HEX1
	always_comb begin
		case (tens)
			5'b00000 : if (ones == 5'b00000) HEX1 = 7'b0101111;
						  else 						HEX1 = 7'b1111111;
			5'b00001 :								HEX1 = 7'b1111001;
			5'b00010 :								HEX1 = 7'b0100100;
			5'b00011 :								HEX1 = 7'b0110000;
			default  :								HEX1 = 7'b1111111;
		endcase	
	end

	//calculate HEX2 - HEX5
	always_comb begin
		if (count == 5'b00000) begin
			HEX5 = 7'b1000110;
			HEX4 = 7'b1000111;
			HEX3 = 7'b0000110;
			HEX2 = 7'b0001000;
		end else if (count >= 5'b11001) begin
			HEX5 = 7'b0001110;
			HEX4 = 7'b1000001;
			HEX3 = 7'b1000111;
			HEX2 = 7'b1000111;
		end else begin
			HEX5 = 7'b1111111;
			HEX4 = 7'b1111111;
			HEX3 = 7'b1111111;
			HEX2 = 7'b1111111;			
		end
	end
	
endmodule

module Output_Translation_testbench
	(
	);
	
	logic [4:0] count;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	Output_Translation dut
		(.count(count)
		,.HEX0 ( HEX0)
		,.HEX1 ( HEX1)
		,.HEX2 ( HEX2)
		,.HEX3 ( HEX3)
		,.HEX4 ( HEX4)
		,.HEX5 ( HEX5)
		);
		
	initial begin
	
	count = 5'b00000; #10;
	count = 5'b00001; #10;
	count = 5'b00010; #10;
	count = 5'b00011; #10;
	count = 5'b00100; #10;
	count = 5'b00101; #10;
	count = 5'b00110; #10;
	count = 5'b00111; #10;
	count = 5'b01000; #10;
	count = 5'b01001; #10;
	count = 5'b01010; #10;
	count = 5'b01011; #10;
	count = 5'b01100; #10;
	count = 5'b01101; #10;
	count = 5'b01110; #10;
	count = 5'b01111; #10;
	count = 5'b10000; #10;
	count = 5'b10001; #10;
	count = 5'b10010; #10;
	count = 5'b10011; #10;
	count = 5'b10100; #10;
	count = 5'b10101; #10;
	count = 5'b10110; #10;
	count = 5'b10111; #10;
	count = 5'b11000; #10;
	count = 5'b11001; #10;
	count = 5'b11010; #10;
	count = 5'b11011; #10;
	count = 5'b11100; #10;
	count = 5'b11101; #10;
	count = 5'b11110; #10;
	count = 5'b11111; #10;
	
	$stop;
	
	end
		
endmodule
