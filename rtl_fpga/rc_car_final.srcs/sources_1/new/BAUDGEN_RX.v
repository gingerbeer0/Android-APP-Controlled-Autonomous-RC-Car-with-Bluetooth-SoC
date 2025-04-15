`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/25 17:53:58
// Design Name: 
// Module Name: BAUDGEN_RX
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
`define B230400  139 //32MHz
`define B115200 277 //32MHz
`define B9600   1250 //32MHz

module BAUDGEN_RX #(
         parameter BAUDRATE = `B9600  //-- Default baudrate
)(
         input wire rst,         //-- rst (active low)
         input wire clk,          //-- System clock
         input wire clk_ena,      //-- Clock enable
         output wire clk_out      //-- Bitrate Clock output
);

//-- Number of bits needed for storing the baudrate divisor
localparam N = $clog2(BAUDRATE);

//-- Value for generating the pulse in the middle of the period
localparam M2 = (BAUDRATE >> 1);

//-- Counter for implementing the divisor (it is a BAUDRATE module counter)
//-- (when BAUDRATE is reached, it start again from 0)
reg [N-1:0] divcounter = 0;

//-- Contador m?dulo M
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

//-- The output is 1 when the counter is in the middle of the period, if clk_ena is active
//-- It is 1 only for one system clock cycle
assign clk_out = (divcounter == M2) ? clk_ena : 0;


endmodule