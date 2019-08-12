/*
  Code from @mcgodfrey
  https://gist.github.com/mcgodfrey/b94acfc796c240a4a164
	
  Takes an 8-bit position as an input
  Output a single pwm signal with period of ~20ms
   Pulse width = 1ms -> 2ms full scale. 1.5ms is center position
*/
module Servo_Controller (
  input clk,
  input rst,
  input [7:0] position,
  output servo
  );
	
  reg pwm_q, pwm_d;
  reg [19:0] ctr_q, ctr_d;
  assign servo = pwm_q;
  //position (0-255) maps to 50,000-100,000 (which corresponds to 1ms-2ms @ 50MHz)
  //this is approximately (position+165)<<8
  //The servo output is set by comparing the position input with the value of the counter (ctr_q)
  always @(*) begin
    ctr_d = ctr_q + 1'b1;
    if (position + 9'd165 > ctr_q[19:8]) begin
      pwm_d = 1'b1;
    end else begin
      pwm_d = 1'b0;
    end
  end
	
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
    end
    pwm_q <= pwm_d;
  end
endmodule
