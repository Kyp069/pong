//-------------------------------------------------------------------------------------------------
module pong
//-------------------------------------------------------------------------------------------------
(
	input  wire      clock,
	input  wire      ce,

	input  wire      reset,
	input  wire[7:0] joy1,
	input  wire[7:0] joy2,

	output wire      blank,
	output wire      hsync,
	output wire      vsync,
	output wire      pixel,
	output wire      sound
);
//-------------------------------------------------------------------------------------------------

reg[15:0] pCount = 0;
wire pCountReset = pCount == 128*311+127;
always @(posedge clock) if(ce) if(pCountReset) pCount <= 1'd0; else pCount <= pCount+1'd1;

wire[8:0] vCount = pCount[15:7];
wire[6:0] hCount = pCount[ 6:0];

//-------------------------------------------------------------------------------------------------

reg[4:0] padSize = 28;

reg[8:0] lPadY = 9'd127;
always @(posedge clock) if(ce) if(pCountReset)
	if(joy1[3]) lPadY <= lPadY-9'd4; else if(joy1[2]) lPadY = lPadY+9'd4;

reg[8:0] rPadY = 9'd127;
always @(posedge clock) if(ce) if(pCountReset)
	if(joy2[3]) rPadY <= rPadY-9'd4; else if(joy2[2]) rPadY = rPadY+9'd4;

//-------------------------------------------------------------------------------------------------

reg[1:0] ballDir = 2'b11;

reg turnL = 0;
always @(posedge clock) if(ce) if(pCountReset)
	if(game) turnL <=  ballDir[0] && ballX == 96 && ballY >= rPadY-1 && ballY < rPadY+padSize;

reg turnR = 0;
always @(posedge clock) if(ce) if(pCountReset)
	if(game) turnR <= !ballDir[0] && ballX == 30 && ballY >= lPadY-1 && ballY < lPadY+padSize;

reg turnU = 0;
always @(posedge clock) if(ce) if(pCountReset)
	turnU <= ballDir[1] && ballY == 268;

reg turnD = 0;
always @(posedge clock) if(ce) if(pCountReset)
	turnD <= !ballDir[1] && ballY ==  46;

reg[6:0] ballX = 7'd0;
reg[8:0] ballY = 9'd46;

always @(posedge clock) if(ce) if(pCountReset) begin
	if(turnL) ballDir[0] = 1'b0;
	if(turnR) ballDir[0] = 1'b1;
	if(turnU) ballDir[1] = 1'b0;
	if(turnD) ballDir[1] = 1'b1;
	if(ballDir[0]) ballX = ballX+1'd1; else ballX = ballX-1'd1;
	if(ballDir[1]) ballY = ballY+9'd2; else ballY = ballY-9'd2;
end

reg[1:0] point = 2'b00;
always @(posedge clock) if(ce) if(pCountReset)
	point <= { ballDir[0] && ballX == 99, !ballDir[0] && ballX == 27 };

reg game = 0;
always @(posedge clock) if(ce) if(pCountReset)
	if(&up1 || &up2) game <= 1'b0; else if(reset) game <= 1'b1;

reg[3:0] up1 = 4'd0;
always @(posedge clock) if(ce) if(pCountReset)
	if(reset) up1 <= 1'd0; else if(point[0] && game) up1 <= up1+1'd1;

reg[3:0] up2 = 4'd0;
always @(posedge clock) if(ce) if(pCountReset)
	if(reset) up2 <= 1'd0; else if(point[1] && game) up2 <= up2+1'd1;

//-------------------------------------------------------------------------------------------------

reg[4:0] font[0:79];
initial $readmemb("font.bin", font);

reg[4:0] number;
always @(posedge clock) if(ce) begin
	if(hCount == 48) number
		= vCount >= 50 && vCount < 56 ? font[up1*5+0]
		: vCount >= 56 && vCount < 62 ? font[up1*5+1]
		: vCount >= 62 && vCount < 68 ? font[up1*5+2]
		: vCount >= 68 && vCount < 74 ? font[up1*5+3]
		: vCount >= 74 && vCount < 80 ? font[up1*5+4] : 5'b00000;

	if(hCount == 67) number
		= vCount >= 50 && vCount < 56 ? font[up2*5+0]
		: vCount >= 56 && vCount < 62 ? font[up2*5+1]
		: vCount >= 62 && vCount < 68 ? font[up2*5+2]
		: vCount >= 68 && vCount < 74 ? font[up2*5+3]
		: vCount >= 74 && vCount < 80 ? font[up2*5+4] : 5'b00000;

	if(hCount >= 49 && hCount < 59 && !hCount [0]) number = { number[3:0], 1'b0 };
	if(hCount >= 68 && hCount < 78 &&  hCount [0]) number = { number[3:0], 1'b0 };
end

//-------------------------------------------------------------------------------------------------

reg[8:0] cc4K0 = 0;
wire cc4K0Reset = cc4K0 == 499;
always @(posedge clock) if(ce) if(cc4K0Reset) cc4K0 <= 1'd0; else cc4K0 <= cc4K0+1'd1;

wire playPoint = point[0] || point[1];
wire playWall = display && (turnU || turnD);
wire playPad = turnL || turnR;
wire playAny = playPoint || playWall || playPad;

reg[7:0] ccPlay = 0;
wire play = !ccPlay[7];
always @(posedge clock, posedge playAny)
	if(playAny) ccPlay <= 1'd0; else
	if(ce) if(cc4K0Reset) if(play) ccPlay <= ccPlay+1'd1;

reg[2:0] tone;
always @(posedge clock) if(ce) if(cc4K0Reset) tone <= tone+1'd1;

reg[1:0] toneSel;
always @(posedge clock) if(ce) if(cc4K0Reset)
	if(playPoint) toneSel <= 2'd2; else
	if(playWall) toneSel <= 2'd1; else
	if(playPad) toneSel <= 2'd0;

//-------------------------------------------------------------------------------------------------

wire net = vCount[2] && (hCount == 63 && vCount >= 44 && vCount < 276);
wire top = hCount[0] && (hCount >= 27 && hCount < 100 && vCount >= 44 && vCount < 46);
wire bottom = hCount[0] && (hCount >= 27 && hCount < 100 && vCount >= 274 && vCount < 276);

wire ball = hCount == ballX && vCount >= ballY && vCount < ballY+5;
wire padL = hCount == 29 && vCount >= lPadY && vCount < lPadY+padSize;
wire padR = hCount == 97 && vCount >= rPadY && vCount < rPadY+padSize;

wire display = hCount >= 27 && hCount < 100 && vCount >= 44 && vCount < 276;

//-------------------------------------------------------------------------------------------------

assign blank = hCount >= 116 || vCount >= 306;
assign hsync = hCount >= 116 && hCount < 116+8;
assign vsync = vCount >= 306 && vCount < 306+2;
assign pixel = display & (net | top | bottom | ball | padL | padR | number[4]);
assign sound = game && play && tone[toneSel];

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
