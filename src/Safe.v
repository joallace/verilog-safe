module Safe(  
  input CLOCK_50,		//    50 MHz clock
  input [2:0] KEY,  	//   2 Pushbuttons
  input [17:0] SW,  		//   18 Switches
  output [1:0]LEDG, //    LEDs Green
  output LEDR,   	//    LED Red
  
  //GPIO Connections
  input GPIO_I,		
  output GPIO_O,
  
  //LCD Module 16X2
  output LCD_ON,        // LCD Power ON/OFF
  output LCD_BLON,      // LCD Back Light ON/OFF
  output LCD_RW,        // LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,        // LCD Enable
  output LCD_RS,        // LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA  // LCD Data bus 8 bits
);

	//-----------------------VARIABLES_INICIALIZATION-----------------------------
	
	//--------------===============LCD=================-----------------
	// Reset delay gives some time for peripherals to initialize
	wire DLY_RST;
	Reset_Delay r0(.iCLK(CLOCK_50),.oRESET(DLY_RST));

	//----Turn LCD ON----
	assign LCD_ON      =    1'b1;
	assign LCD_BLON    =    1'b1;
	//-------------------
	
	
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
	
	//--------------===================================-----------------

	//reg servo = 1'b0;
	//assign GPIO_O = servo;
	reg [7:0]position = 0;

	reg [1:0]ledG = 2'b00;
	
	assign LEDG = ledG;
	assign LEDR = ~&ledG;
	
	reg correctPass = 1'b0;
	reg correctFacial = 1'b0;
	
	reg [1:0]message = 2'b00;

	parameter PASSWORD = 18'b111111111111111111;
	
	//-----------------------------------------------------------------------------

	always @ (posedge CLOCK_50) begin
		if(!DLY_RST)
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
		
		if(!KEY[0] && SW == PASSWORD)
			correctPass <= 1'b1;
			
		if(GPIO_I == 1'b0)
			correctFacial <= 1'b1;
		
		ledG[1] <= correctFacial;
		ledG[0] <= correctPass;
		
		if(!KEY[0] && (SW != PASSWORD || !correctFacial) )begin
			message <= 2'b01;
			LUT_INDEX	<=	0;
			mLCD_ST		<=	0;
			mDLY		<=	0;
			mLCD_Start	<=	0;
			mLCD_DATA	<=	0;
			mLCD_RS		<=	0;
		end
					
		
		if(!KEY[0] && (correctFacial && correctPass))begin
			//servo <= 1'b1;
			position <= 8'b11001000;
			message <= 2'b10;
			LUT_INDEX	<=	0;
			mLCD_ST		<=	0;
			mDLY		<=	0;
			mLCD_Start	<=	0;
			mLCD_DATA	<=	0;
			mLCD_RS		<=	0;
		end		
		
		if(!KEY[1])begin
			//servo <= 1'b0;
			position <= 0;
			correctPass <= 1'b0;
			correctFacial <= 1'b0;
			message <= 2'b00;
			LUT_INDEX	<=	0;
			mLCD_ST		<=	0;
			mDLY		<=	0;
			mLCD_Start	<=	0;
			mLCD_DATA	<=	0;
			mLCD_RS		<=	0;
		end
			
		if(message == 2'b00) begin
			case(LUT_INDEX)
				//	Initial
				LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
				LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
				LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
				LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
				LCD_INTIAL+4:	LUT_DATA	<=	9'h080;

				//	Line 1
				LCD_LINE1+14:	LUT_DATA	<=	9'h120;	// End
			endcase
		end
                                                                            
				
		if(message == 2'b01) begin
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
				
				LCD_LINE1+13:	LUT_DATA	<=	9'h120;	// End
			endcase
		end
			
			
		if(message == 2'b10) begin
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
				
				LCD_LINE1+14:	LUT_DATA	<=	9'h120;	// End
			endcase
		end
	end
	

	LCD_Controller 		u0	(	//	Host Side
								.iDATA(mLCD_DATA),
								.iRS(mLCD_RS),
								.iStart(mLCD_Start),
								.oDone(mLCD_Done),
								.iCLK(CLOCK_50),
								.iRST_N(DLY_RST),
								//	LCD Interface
								.LCD_DATA(LCD_DATA),
								.LCD_RW(LCD_RW),
								.LCD_EN(LCD_EN),
								.LCD_RS(LCD_RS)	);
								
	Servo_Controller s0(  
		.clk(CLOCK_50),
		.rst(!KEY[2]),
		.position(position),
		.servo(GPIO_O)
	);
	
endmodule
