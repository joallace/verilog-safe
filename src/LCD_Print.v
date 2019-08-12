module	LCD_Print (	
	//Host Side
	input [1:0]MESSAGE,
	input iCLK, iRST_N,
	
	//LCD Side
	output	[7:0]	LCD_DATA,
	output			LCD_RW,LCD_EN,LCD_RS
);

	//	Internal Wires/Registers
	reg	[5:0]	LUT_INDEX;
	reg	[8:0]	LUT_DATA;
	reg	[5:0]	mLCD_ST;
	reg	[17:0]	mDLY;
	reg			mLCD_Start;
	reg	[7:0]	mLCD_DATA;
	reg			mLCD_RS;
	wire		mLCD_Done;

	parameter	LCD_INTIAL	=	0;
	parameter	LCD_LINE1	=	5;
	parameter	LCD_CH_LINE	=	LCD_LINE1+16;
	parameter	LCD_LINE2	=	LCD_LINE1+16+1;
	parameter	LUT_SIZE	=	LCD_LINE1+32+1;

	always@(posedge iCLK or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			LUT_INDEX	<=	0;
			mLCD_ST		<=	0;
			mDLY		<=	0;
			mLCD_Start	<=	0;
			mLCD_DATA	<=	0;
			mLCD_RS		<=	0;
		end
		else
		begin
			if(LUT_INDEX < LUT_SIZE)
			begin
				case(mLCD_ST)
				0:	begin
						mLCD_DATA	<=	LUT_DATA[7:0];
						mLCD_RS		<=	LUT_DATA[8];
						mLCD_Start	<=	1;
						mLCD_ST		<=	1;
					end
				1:	begin
						if(mLCD_Done)
						begin
							mLCD_Start	<=	0;
							mLCD_ST		<=	2;
						end
					end
				2:	begin
						if(mDLY<18'h3FFFE)
						mDLY	<=	mDLY+1;
						else
						begin
							mDLY	<=	0;
							mLCD_ST	<=	3;
						end
					end
				3:	begin
						LUT_INDEX	<=	LUT_INDEX+1;
						mLCD_ST	<=	0;
					end
				endcase
			end
		end
	end

	/*
	-------------------------------------------------------------------
	--                        ASCII HEX TABLE
	--  Hex                        Low Hex Digit
	-- Value  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
	------\----------------------------------------------------------------
	--H  2 |  SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /
	--i  3 |  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
	--g  4 |  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
	--h  5 |  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
	--   6 |  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
	--   7 |  p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ DEL
	-----------------------------------------------------------------------
	-- Example "A" is row 4 column 1, so hex value is 8'h41"
	-- *see LCD Controller's Datasheet for other graphics characters available
	*/

	always @ (iCLK)
	begin
		if(MESSAGE == 2'b00) begin
			case(LUT_INDEX)
				//	Initial
				LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
				LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
				LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
				LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
				LCD_INTIAL+4:	LUT_DATA	<=	9'h080;

				//	Line 1
				LCD_LINE1+14:	LUT_DATA	<=	9'h120;	// Fim
			endcase
		end

				
		if(MESSAGE == 2'b01) begin
			case(LUT_INDEX)
				//	Initial
				LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
				LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
				LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
				LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
				LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
				
				
				//	Line 1
				LCD_LINE1+0:	LUT_DATA	<=	9'h141;	// A
				LCD_LINE1+1:	LUT_DATA	<=	9'h143;	// C
				LCD_LINE1+2:	LUT_DATA	<=	9'h143;	// C
				LCD_LINE1+3:	LUT_DATA	<=	9'h145;	// E
				LCD_LINE1+4:	LUT_DATA	<=	9'h153;	// S
				LCD_LINE1+5:	LUT_DATA	<=	9'h153;	// S
				
				LCD_LINE1+6:	LUT_DATA	<=	9'h120;	// Space
				
				//	Line 1
				LCD_LINE1+7:	LUT_DATA	<=	9'h144;	// D
				LCD_LINE1+8:	LUT_DATA	<=	9'h145;	// E
				LCD_LINE1+9:	LUT_DATA	<=	9'h14E;	// N
				LCD_LINE1+10:	LUT_DATA	<=	9'h149;	// I
				LCD_LINE1+11:	LUT_DATA	<=	9'h145;	// E
				LCD_LINE1+12:	LUT_DATA	<=	9'h144;	// D
				
				LCD_LINE1+13:	LUT_DATA	<=	9'h120;	// Fim
			endcase
		end
			
			
		if(MESSAGE == 2'b10) begin
			case(LUT_INDEX)
				//	Initial
				LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
				LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
				LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
				LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
				LCD_INTIAL+4:	LUT_DATA	<=	9'h080;

				//	Line 1
				LCD_LINE1+0:	LUT_DATA	<=	9'h141;	// A
				LCD_LINE1+1:	LUT_DATA	<=	9'h143;	// C
				LCD_LINE1+2:	LUT_DATA	<=	9'h143;	// C
				LCD_LINE1+3:	LUT_DATA	<=	9'h145;	// E
				LCD_LINE1+4:	LUT_DATA	<=	9'h153;	// S
				LCD_LINE1+5:	LUT_DATA	<=	9'h153;	// S
				
				LCD_LINE1+6:	LUT_DATA	<=	9'h120;	// Space
				
				LCD_LINE1+7:	LUT_DATA	<=	9'h147;	// G
				LCD_LINE1+8:	LUT_DATA	<=	9'h152;	// R
				LCD_LINE1+9:	LUT_DATA	<=	9'h141;	// A
				LCD_LINE1+10:	LUT_DATA	<=	9'h14E;	// N
				LCD_LINE1+11:	LUT_DATA	<=	9'h154;	// T
				LCD_LINE1+12:	LUT_DATA	<=	9'h145;	// E
				LCD_LINE1+13:	LUT_DATA	<=	9'h144;	// D
				
				LCD_LINE1+14:	LUT_DATA	<=	9'h120;	// Fim
			endcase
		end
	end

	LCD_Controller 		u0	(	//	Host Side
								.iDATA(mLCD_DATA),
								.iRS(mLCD_RS),
								.iStart(mLCD_Start),
								.oDone(mLCD_Done),
								.iCLK(iCLK),
								.iRST_N(iRST_N),
								//	LCD Interface
								.LCD_DATA(LCD_DATA),
								.LCD_RW(LCD_RW),
								.LCD_EN(LCD_EN),
								.LCD_RS(LCD_RS)	);

endmodule
