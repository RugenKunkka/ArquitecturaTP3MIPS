`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 01:36:08 PM
// Design Name: 
// Module Name: E1_PC
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


module E1_PC
    (
        input i_clock,
        input i_reset,
        input [32-1:0] i_pcAddressIn,
    
        output reg [32-1:0] o_pcAddressOut
    );
    //interface
    /*
    E1_PC#()
    u1_PC( 
        .i_clock(),
        .i_reset(),
        .i_pcAddressIn(),
        
        .o_pcAddressOut()
    );
    */
    //lo hacemos en el negedge para estar seguros que en el proximo posedge, los circuitos tienen un valor estable en todo
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_pcAddressOut<=0;
        end
        else begin
            o_pcAddressOut<=i_pcAddressIn;
        end
    end

endmodule
