module background_drawer
	( input  logic        clk50
	, input  logic        reset
	, output logic [10:0] x
	, output logic [10:0] y
	, output logic        color
	, output logic 		 done
	);

	parameter HTOTAL = 640;
	parameter VTOTAL = 480;
	
	logic endOfLine;
	logic endOfField;
	
	always_ff @(posedge clk50 or posedge reset) begin
     if (reset)          x <= 0;
     else if (endOfLine) x <= 0;
     else  	         	 x <= x + 11'd1;
	end
	
	assign endOfLine = x == HTOTAL - 1;
	
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          y <= 0;
     else if (endOfLine)
       if (endOfField)   y <= 0;
		 else if (y == ((VTOTAL / 3) - 1)) y <= (((VTOTAL / 3) * 2) - 1);
		 else              y <= y + 11'd1;

   assign endOfField = (y == (VTOTAL - 1));
	
	assign done = (endOfField && endOfLine);
	
	assign color = 1'b1;
	
endmodule
