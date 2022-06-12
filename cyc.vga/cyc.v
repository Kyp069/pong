//-------------------------------------------------------------------------------------------------
`default_nettype none
//-------------------------------------------------------------------------------------------------
module cyc
//-------------------------------------------------------------------------------------------------
(
	input  wire      clock12,

	output wire[1:0] sync,
	output wire[5:0] rgb,

	input  wire[5:0] joy,

	input  wire      button,
	output wire[7:0] led
);
//-------------------------------------------------------------------------------------------------

wire clock, power;
pll pll(clock12, clock, power);

reg ce2M0;
reg[5:0] ce = 1;
always @(negedge clock) if(power) begin
	ce <= ce+1'd1;
	ce2M0 <= ~ce[0] & ~ce[1] & ~ce[2];
end

//-------------------------------------------------------------------------------------------------

wire reset = ~button;
wire hsync, vsync, pixel;

wire[7:0] joy1 = { 2'd0, ~joy };
wire[7:0] joy2 = { 2'd0, ~joy };

pong pong
(
	.clock  (clock  ),
	.ce     (ce2M0  ),
	.reset  (reset  ),
	.joy1   (joy1   ),
	.joy2   (joy2   ),
	.hsync  (hsync  ),
	.vsync  (vsync  ),
	.pixel  (pixel  )
);

//-------------------------------------------------------------------------------------------------

assign sync = { 1'b1, ~(hsync^vsync) };
assign rgb = {6{ pixel }};

assign led = 1'd0;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
