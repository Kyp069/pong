//-------------------------------------------------------------------------------------------------
`default_nettype none
//-------------------------------------------------------------------------------------------------
module np1
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire[ 1:0] sync,
	output wire[17:0] rgb,

	output wire[ 1:0] dsg,

	output wire       joyCk,
	output wire       joyLd,
	output wire       joyS,
	input  wire       joyD,

	output wire       led,
	output wire       stm
);
//-------------------------------------------------------------------------------------------------

wire clock, power;
pll pll(clock50, clock, power);

reg ce2M0, ce2K5;
reg[5:0] ce = 1;
always @(negedge clock) if(power) begin
	ce <= ce+1'd1;
	ce2M0 <= ~ce[0] & ~ce[1] & ~ce[2];
	ce2K5 <= ~ce[0] & ~ce[1] & ~ce[2] & ~ce[3] & ~ce[4] & ~ce[5];
end

//-------------------------------------------------------------------------------------------------

wire[7:0] joy1, joy2;

joystick joystick
(
	.clock  (clock  ),
	.ce     (ce2K5  ),
	.joyCk  (joyCk  ),
	.joyLd  (joyLd  ),
	.joyS   (joyS   ),
	.joyD   (joyD   ),
	.joy1   (joy1   ),
	.joy2   (joy2   )
);

//-------------------------------------------------------------------------------------------------

wire reset = joy1[4] && joy2[4];
wire blank, hsync, vsync, pixel, sound;

pong pong
(
	.clock  (clock  ),
	.ce     (ce2M0  ),
	.reset  (reset  ),
	.joy1   (joy1   ),
	.joy2   (joy2   ),
	.blank  (blank  ),
	.hsync  (hsync  ),
	.vsync  (vsync  ),
	.pixel  (pixel  ),
	.sound  (sound  )
);

//-------------------------------------------------------------------------------------------------

assign sync = { 1'b1, ~(hsync^vsync) };
assign rgb = blank ? 1'd0 : {18{ pixel }};

dsg #(3) dsg1(clock, power, { 3'd0, sound }, dsg[1]);
dsg #(3) dsg0(clock, power, { 3'd0, sound }, dsg[0]);

assign led = 1'b1;
assign stm = 1'b0;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
