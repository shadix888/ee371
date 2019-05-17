module N_FIR
	#(parameter N = 8)
	
	( input signed [23:0] Data_in
	, input clk
	, output logic [23:0] Data_out
	);
	
	logic signed [23:0] regist [0:N - 1];
	logic signed [23:0] Data_in_t, Acc;
	
	genvar i;
	
	generate
		for (i = 0; i < N - 1; i = i + 1) begin : gen
			always_ff @(posedge clk) begin
				regist[i + 1] <= regist[i];
			end
		end
	endgenerate
	
	assign Data_in_t = Data_in >>> $clog2(N);
	
	always_comb begin
		if (Data_out === 24'bx )
			Acc = 24'b0;
		else if (regist[N - 1] === 24'bx) 
			Acc = Data_out + Data_in_t;
		else
			Acc = Data_out + Data_in_t - regist[N - 1];
	end
	
	always_ff @(posedge clk) begin
		regist[0] <= Data_in_t;
		Data_out <= Acc;
	end
	
endmodule

module test
	();
	
	logic signed [23:0] Data_in;
	logic [23:0] Data_out, Data_out2;
	logic clk;
	
	N_FIR dut
		(.Data_in
		,.Data_out
		,.clk
		);
		
	N_FIR #(.N(16)) dut2
		(.Data_in
		,.Data_out(Data_out2)
		,.clk
		);
		
	initial begin
		clk <= 0;
		forever #10 clk <= ~clk;
	end
	
	initial begin
		Data_in = 32; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end
endmodule
