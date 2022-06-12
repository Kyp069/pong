//-------------------------------------------------------------------------------------------------
`default_nettype none
//-------------------------------------------------------------------------------------------------
module cyc
//-------------------------------------------------------------------------------------------------
(
	input  wire      clock12,

	output wire[7:0] tmds,

	output wire[1:0] dsg,

	input  wire[5:0] joy,

	input  wire      button,
	output wire[7:0] led
);
//-------------------------------------------------------------------------------------------------

wire clock, clock1x, clock5x, power;
pll pll(clock12, clock, clock1x, clock5x, power); // 16 MHz, 32 MHz, 160 MHz

reg ce2M0;
reg[2:0] ce = 1;
always @(negedge clock) if(power) begin
	ce <= ce+1'd1;
	ce2M0 <= ~ce[0] & ~ce[1] & ~ce[2];
end

//-------------------------------------------------------------------------------------------------

wire reset = ~button;
wire blank, vsync, hsync, pixel, sound;

wire[7:0] joy1 = { 2'd0, ~joy };
wire[7:0] joy2 = { 2'd0, ~joy };

pong pong
(
	.clock  (clock  ),
	.ce     (ce2M0  ),
	.reset  (reset  ),
	.joy1   (joy1   ),
	.joy2   (joy2   ),
	.blank  (blank  ),
	.vsync  (vsync  ),
	.hsync  (hsync  ),
	.pixel  (pixel  ),
	.sound  (sound  )
);

//-------------------------------------------------------------------------------------------------

wire[ 1:0] sync = { vsync, hsync };
wire[23:0] rgb = {24{ pixel }};

hdmi HDMI
(
	.clock1x(clock1x),
	.clock5x(clock5x),
	.blank  (blank  ),
	.sync   (sync   ),
	.rgb    (rgb    ),
	.tmds   (tmds   )
);

//-------------------------------------------------------------------------------------------------

dsg #(3) dsg1(clock, power, { 3'd0, sound }, dsg[1]);
dsg #(3) dsg0(clock, power, { 3'd0, sound }, dsg[0]);

assign led = 1'd0;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
