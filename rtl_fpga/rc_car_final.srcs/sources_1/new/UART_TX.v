`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2018 10:16:43
// Design Name: 
// Module Name: UART_TX
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
// a 12MHz clock
`define B230400  52
`define B115200 104
`define B9600   1250

// a 16MHz clock
//`define B115200 140
//`define B9600   1667

// a 8MHz clock
//`define B115200 69
//`define B9600   1667
//////////////////////////////////////////////////////////////////////////////////
// serial transmitter unit module
//////////////////////////////////////////////////////////////////////////////////

module UART_TX #(
            parameter BAUDRATE = `B9600  //-- Default baudrate
            )(
            input wire clk,        //-- System clcok (12MHz in the ICEstick)
            input wire rst,       //-- rst  (Active high)
            input wire start,      //-- Set to 1 for starting the transmission
            input wire [7:0] data, //-- Byte to transmit
            output reg tx,         //-- Serial data output
            output reg ready      //-- Transmitter ready (1) / busy (0)
            );

    wire clk_baud;      // Transmission clock
    reg [3:0] bitc;     // Bitcounter
    reg [7:0] data_r;   // Registered data

    //control signals
    reg load;           //Load the shifter register / rst
    reg baud_en;        //Enable the baud generator

//-- fsm states
reg [1:0] state;
reg [1:0] next_state;

localparam IDLE  = 0;  //-- Idle state
localparam START = 1;  //-- Start transmission
localparam TRANS = 2;  //-- Transmitting data
//-------------------------------------
//-- DATAPATH
//-------------------------------------

//-- Register the input data
always @(posedge clk)
  if (start == 1 && state == IDLE)
    data_r <= data;

//-- 1 bit start + 8 bits datos + 1 bit stop
//-- Shifter register. It stored the frame to transmit:
//-- 1 start bit + 8 data bits + 1 stop bit
reg [9:0] shifter;

//-- When the control signal load is 1, the frame is loaded
//-- when load = 0, the frame is shifted right to send 1 bit,
//--   at the baudrate determined by clk_baud
//--  1s are introduced by the left
always @(posedge clk)
  //-- rst
  if (rst == 1)
    shifter <= 10'b11_1111_1111;

  //-- Load mode
  else if (load == 1)
    shifter <= {data_r,2'b01};

  //-- Shift mode
  else if (load == 0 && clk_baud == 1)
    shifter <= {1'b1, shifter[9:1]};

//-- Sent bit counter
//-- When load (=1) the counter is rst
//-- When load = 0, the sent bits are counted (with the raising edge of clk_baud)
always @(posedge clk)
  if (rst)
    bitc <= 0;

  else if (load == 1)
    bitc <= 0;
  else if (load == 0 && clk_baud == 1)
    bitc <= bitc + 1;

//-- The less significant bit is transmited through tx
//-- It is a registed output, because tx is connected to an Asynchronous bus
//--  and the glitches should be avoided
always @(posedge clk)
  tx <= shifter[0];

//-- Baud generator
BAUDGEN_TX #( .BAUDRATE(BAUDRATE))
BAUD0 (
    .rst(rst),
    .clk(clk),
    .clk_ena(baud_en),
    .clk_out(clk_baud)
  );

//------------------------------
//-- CONTROLLER
//------------------------------


//-- Registers for storing the states

//-- Transition between states
always @(posedge clk)
  if (rst) 
    state <= IDLE;
  else
    state <= next_state;

//-- Control signal generation and next states
always @(*) begin

  //-- Default values
  next_state = state;      //-- Stay in the same state by default
  load = 0;
  baud_en = 0;

  case (state)

    //-- Idle state
    //-- Remain in this state until start is 1
    IDLE: begin
      ready = 1;
      if (start == 1)
        next_state = START;
    end

    //-- 1 cycle long
    //-- turn on the baudrate generator and the load the shift register
    START: begin
      load = 1;
      baud_en = 1;
      ready = 0;
      next_state = TRANS;
    end

    //-- Stay here until all the bits have been sent
    TRANS: begin
      baud_en = 1;
      ready = 0;
      if (bitc == 11)
        next_state = IDLE;
    end

    default:
      ready = 0;

  endcase
end

endmodule


