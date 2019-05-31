module N_FIR
	#(parameter N = 8)
	
	( input signed [23:0] Data_in
	, input clk
	, output signed [23:0] Data_out
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
	
	always_ff @(posedge clk) begin
		regist[0] <= Data_in_t;
		Data_out <= Data_out + Data_in_t - regist[N - 1];
	end
	
endmodule