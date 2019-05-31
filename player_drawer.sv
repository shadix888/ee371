//this module draws the player and the obstacles 

module player_drawer
  ( input  logic        clk50 //clock
  , input  logic        reset //reset
  , input  logic        start //start drawing the player and the obstacles
  , input  logic        up // the player moved up
  , input  logic        down // the player moved down
  , input  logic [4:0]  speed // how fst the obstacles move across the screen
  , output logic [10:0] x // x coordinate of one pixel to be drawn
  , output logic [10:0] y // y coordinate of one pixel to be drawn
  , output logic        color // the color of the pixel
  , output logic 		   done //whether or not it is done drawing the player field
  , output logic        pass //whether or not the player made it past the obstacle
  , output logic        hit
  );
		
  parameter HEIGHT = 640;
  parameter WIDTH = 160;
  
  logic [24:0] clock_divider;
  logic [1:0] out;
  logic [1:0] enemy [639:0];
  logic counted, collided;
	
  logic endOfLine;
  logic endOfField;
  
  //go through each pixel in a line
  always_ff @(posedge clk50)
    if (reset || !start) x <= 0;
    else if (endOfLine) x <= 0;
    else x <= x + 11'd1;
  
  assign endOfLine = (x == (HEIGHT - 1));
  
  //go through each line in the player field
  always_ff @(posedge clk50)
	if (reset || !start) y <= 0;
	else if (endOfLine) 
		if (endOfField)   y <= 0;
      else              y <= y + 11'd1;
	
  assign endOfField = (y == (WIDTH - 1));

  assign done = (endOfField && endOfLine);
  
  //color in pixels if they are an obstacle or if they are the player
  always_comb begin
    if ((up == down && x > 11'd160 && x < 11'd224 && y >= 11'd48 && y < 11'd112) || (up && !down && x > 11'd160 && x < 11'd224 && y >= 11'd0 && y < 11'd64) || (down && !up && x > 11'd160 && x < 11'd224 && y >= 11'd96 && y < 11'd160)) color = 1'b1;
	 else if ((enemy[x] == 2'd2 && y >= 11'd0 && y < 11'd80) || (enemy[x] == 2'd1 && y >= 11'd80 && y < 11'd160)) color = 1'b1;
	 else color = 1'b0;
  end
  
  //calculate hits
  always_comb begin
	 if ((x > 11'd160 && x < 11'd224) && ((enemy[x] == 2'd2 && up) || (enemy[x] == 2'd1 && down) || ((up == down) && (enemy[x] == 2'd1 || enemy[x] == 2'd2)))) hit = 1'b1;
	 else hit = 1'b0;
  end
  
  //calculate passed

	
  
  ///////////////////////////////////////////////////////////////
  always_ff @(posedge clk50) begin
	 if (hit) collided <= 1'b1;
	 if (reset) clock_divider <= 0;
	 else clock_divider <= clock_divider + 25'd1;
	 if ((enemy[158] == 2'd1 || enemy[158] == 2'd2) && (enemy[159] == 2'd0 || enemy[159] == 2'd3)) begin
		if (!counted) begin
			if (!collided) pass <= 1'd1;
			collided <= 1'b0;
		end else pass <= 1'd0;
		counted <= 1'b1;
	 end else begin 
		pass <= 1'd0;
		counted <= 1'b0;
	 end
  end
  
  
  ////////////////generation of obstacles///////////////////////
  
  rand_rom lfsr
	(.address(count[11:6]),
	.clock(count[5]),
	.q(out)
	);
 
	genvar i;
  
   generate
		for (i = 639; i > 0; i = i - 1) begin : gen
			always_ff @(posedge clock_divider[speed]) begin
				enemy[i - 1] <= enemy[i];
			end
		end
	endgenerate
	
	logic [11:0] count;
	
	always_ff @(posedge clock_divider[speed]) begin
		if (reset) enemy[639] <= 2'b0;
		else if (count[5]) enemy[639] <= out;
		else enemy[639] <= 2'b0;
	end
	
	always_ff @(posedge clock_divider[speed]) begin
		if (reset) count <= 10'd0;
		else count <= count + 10'd1;
	end
	
///////////////////////////////////////////////////////////////
endmodule
