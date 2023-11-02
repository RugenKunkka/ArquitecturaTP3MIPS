`include "Macros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 06:21:54 PM
// Design Name: 
// Module Name: Mux
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

//siempre va a tener de salida i_dataA al menos que el bit de control sea 1
module Mux#(
        parameter BUS_LEN = 32
    )
    (
        input wire [BUS_LEN-1:0] i_bus0,
        input wire [BUS_LEN-1:0] i_bus1,
        input wire i_muxSel,
        output reg [BUS_LEN-1:0] o_bus
    );

    always @(*) begin
        if(i_muxSel) begin 
            o_bus = i_bus1;
        end 
        else begin 
            o_bus = i_bus0;
        end
    end
    
endmodule