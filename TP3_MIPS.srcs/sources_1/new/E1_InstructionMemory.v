`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 01:35:33 PM
// Design Name: 
// Module Name: E1_InstructionMemory
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


module E1_InstructionMemory#(
        parameter QUANTITY_REGISTERS=1024,
        parameter REGISTER_LENGTH=8
    )
    (
        input wire i_clock,
        input wire i_reset,
        input wire [32-1:0] i_adressPC,
        
        //despues vemos la parte de cargar los datos hacia la InstructionMemory
        //input wire [32-1:0] i_instructionToWrite
        //input wire i_controlInstructionMemoryWrite
        
        output reg [32-1:0] o_instruction
        
    );
    
    //interface
    /*
    E1_InstructionMemory #(1024, 8) 
    u1_InstructionMemory (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_adressPC(addressPC_signal),
        .o_instruction(output_instruction_signal)
    );
    */
    
    //1024/4 te va a dar la cantidad de instrucciones que puede tener el programa (256)
    reg [8-1:0] reg_memory[QUANTITY_REGISTERS-1:0];//recordemos que los registros son de 8 bits unicamente
    
    integer i;
    
    //OJO LEER! ver si agregamos el bloque para iniciarlizar todos los valores en cero
    
    always@(posedge i_clock) begin
        if(i_reset)begin
            o_instruction<=0;
            for(i=0; i<QUANTITY_REGISTERS; i=i+1) begin
                reg_memory[i] <= 8'b00000000;
            end
        end
        else begin
            //si nos decidimos por escribir tambien, tenemos que poner un flag de write
            
            //ver si vamos a usar un flag para lo que es el debugging step by step que capaz necesitemos bloquear 
        
            //leo los valores en cada pulso de clock
            o_instruction[31:24] <= reg_memory[i_adressPC[8-1:0] + 2'b11];
            o_instruction[23:16] <= reg_memory[i_adressPC[8-1:0] + 2'b10];
            o_instruction[15:8]  <= reg_memory[i_adressPC[8-1:0] + 2'b01];
            o_instruction[7:0]   <= reg_memory[i_adressPC[8-1:0]    ];
            //o_instruction = {reg_memory[i_adressPC[7:0]+2'b11], reg_memory[i_adressPC[7:0]+2'b10], reg_memory[i_adressPC[7:0]+2'b01], reg_memory[i_adressPC[7:0]]};
        end
    end
    
endmodule
