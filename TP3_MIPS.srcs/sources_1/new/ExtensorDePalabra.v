`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 09:07:52 PM
// Design Name: 
// Module Name: ExtensorDePalabra
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

//le agrega 16 ceros a la izquierda (MSB) a la data que entra
module ExtensorDePalabra(
        input wire [16-1:0] i_data,
        
        output wire [32-1:0]o_extendedData

    );
    //interface
    /*
    
    ExtensorDePalabra#()
    u1_ExtensorDePalabra(
        .i_data(),
        
        .o_extendedData()
    );
    
    */
    
    assign o_extendedData = {{16{1'b0}}, i_data} ;
    
endmodule
