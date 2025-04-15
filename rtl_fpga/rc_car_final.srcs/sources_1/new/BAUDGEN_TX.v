`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2018 11:00:27
// Design Name: 
// Module Name: baudgen_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Baudrate definition
// The calculation for the icestick board is:
// Divisor = 12000000 / BAUDRATE  (and the result is rounded to an integer number)
//////////////////////////////////////////////////////////////////////////////////
`define B230400  139 //32MHz
`define B115200 277 //32MHz
`define B9600   1250 //32MHz

//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//-- baudgen module
//--
//-- INPUTS:
//--     -clk: System clock (12 MHZ in the iceStick board)
//--     -clk_ena: clock enable:
//--            1. Normal working: The squeare signal is generated
//--            0: stoped. Output always 0
//-- OUTPUTS:
//--     - clk_out: Output signal. Pulse width: 1 clock cycle. Output not registered
//--                It tells the uart_tx when to transmit the next bit
//--      __                                                         __
//--   __| |________________________________________________________| |________________
//--   ->  <- 1 clock cycle
//--
//////////////////////////////////////////////////////////////////////////////////

module BAUDGEN_TX #(
            parameter BAUDRATE = `B9600 //-- Default baudrate
            )(
            input wire rst,              //-- rst (active low)
            input wire clk,               //-- System clock
            input wire clk_ena,           //-- Clock enable
            output wire clk_out           //-- Bitrate Clock output
            );

//-- Number of bits needed for storing the baudrate divisor
localparam N = $clog2(BAUDRATE);

//-- Counter for implementing the divisor (it is a BAUDRATE module counter)
//-- (when BAUDRATE is reached, it start again from 0)
reg [N-1:0] divcounter = 0;

always @(posedge clk)

  if (rst)
    divcounter <= 0;

  else if (clk_ena)
    //-- Normal working: counting. When the maximum count is reached, it starts from 0
    divcounter <= (divcounter == BAUDRATE - 1) ? 0 : divcounter + 1;
  else
    //-- Counter fixed to its maximum value
    //-- When it is resumed it start from 0
    divcounter <= BAUDRATE - 1;

//-- The output is 1 when the counter is 0, if clk_ena is active
//-- It is 1 only for one system clock cycle
assign clk_out = (divcounter == 0) ? clk_ena : 0;


endmodule
