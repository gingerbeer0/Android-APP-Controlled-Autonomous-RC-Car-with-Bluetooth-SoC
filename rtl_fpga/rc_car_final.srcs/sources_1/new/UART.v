module UART(/*AUTOARG*/
            // Outputs
            ready, tx, rx_data, rcv,
            // Inputs
            clk, rst, rx, start, tx_data
            );
   input clk; 
   input rst; 
   input rx; 
   input start; 
   input [7:0] tx_data; 
   output      ready; 
   output      tx; 
   output [7:0] rx_data; 
   output       rcv; 
   UART_TX 
     UTX
       (/**/
        // Outputs
        .tx (tx),
        .ready (ready),
        // Inputs
        .clk (clk),
        .rst (rst),
        .start (start),
        .data (tx_data[7:0]));
   UART_RX 
     URX
       (/**/
        // Outputs
        .rcv (rcv),
        .data (rx_data[7:0]),
        // Inputs
        .clk (clk),
        .rst (rst),
        .rx (rx));
endmodule

