`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2023 07:27:42 PM
// Design Name: 
// Module Name: E2_RegisterMemory
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

//la unidad solo tiene un tamaño de 32 registros y el registro 0 no se puede escribir!!!!!!!!!!!! segun el libro
module E2_RegisterMemory#(
        parameter REGISTER_LENGTH=5,
        parameter REGISTERS_QUANTITY=32
    )
    (
        input wire i_clock,
        input wire i_reset,
        
        input wire [5-1:0] i_AddressLecturaA,
        input wire [5-1:0] i_AddressLecturaB,
        input wire [5-1:0] i_AddressEscritura,
        input wire [32-1:0] i_DatoAEscribir,
        
        input wire i_controlRegWrite,
        
        output reg [32-1:0] o_dataA,
        output reg [32-1:0] o_dataB

    );
    //interface
    /*
    E2_RegisterMemory#()
    u_RegisterMemory(
        .i_clock(),
        .i_reset(),
        
        .i_AddressLecturaA(),
        .i_AddressLecturaB(),
        .i_AddressEscritura(),
        .i_DatoAEscribir(),
        
        .i_controlRegWrite(),
        
        .o_dataA(),
        .o_dataB()
    );
    
    */
    
    //reg [32-1:0] registers [5-1:0];
    reg [REGISTERS_QUANTITY-1:0] registers [REGISTER_LENGTH-1:0];
    
    reg [5-1 : 0] reg_contador_reset;
    
    //inicializo todo los registros en 0 cuando se instancie el módulo para garantizarme que tienen un valor estable digamos...
    generate
        integer indexRegister;		
	        initial
        for (indexRegister = 0; indexRegister < 32; indexRegister = indexRegister + 1) begin
            registers[indexRegister] = {32 {1'b0} };
        end
    endgenerate
    
    
    //en el libro dice que en un mismo ciclo de reloj se puede leer y escribir al mismo tiempo asi que vamos a hacer primero la escritura
    //y después la lectura porque si yo escribo en el 1er semiciclo, puedo leerlo al dato en el siguiente semiciclo
    always @(posedge i_clock)
	begin
	   if(i_reset)begin
           for (indexRegister = 0; indexRegister < 32; indexRegister = indexRegister + 1) begin
                registers[indexRegister] = {32 {1'b0} };
            end
       end
       else begin
           if(i_controlRegWrite && i_AddressEscritura!=5'b00000) begin
               registers[i_AddressEscritura]<=i_DatoAEscribir;
           end
	   end
	end
	
	always @(negedge i_clock)
	begin
	   if(i_reset)begin
	       o_dataA<=0;
	       o_dataB<=0;
	   end
	   else begin
	       o_dataA<=registers[i_AddressLecturaA];
	       o_dataB<=registers[i_AddressLecturaB];
	   end
	end
    
    
    
    
endmodule
