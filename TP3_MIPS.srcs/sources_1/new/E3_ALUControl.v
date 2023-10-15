`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2023 03:01:28 PM
// Design Name: 
// Module Name: E3_ALUControl
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

//este modulo en base al tipo de instruccion va a invocar o setear que operación debe de efectuar la ALU
module E3_ALUControl(
        input wire [6-1:0] i_operationCode,//6 bits MSB de la isntruccion
        input wire [6-1:0] i_functionCode,//6 bits LSB de la instruccion
        input wire [2-1:0] i_controlAluOp,//libro, viene desde la unidad de control en la etapa 2 ID(instruction decode)
        output reg [6-1:0] o_ALUBitsControl
    );
    //interface
    /*
        E3_ALUControl#()
        u_ALUControl
        (
            .i_operationCode(),
            .i_functionCode(),
            .i_AluOp(),
            .o_ALUBitsControl()
        );
    */
    
    always @(*)begin
        case(i_controlAluOp) 2'b00: begin //ld o sw
            o_ALUBitsControl = 4'b0110; //addu
        end
        
        2'b01: begin//branch
            o_ALUBitsControl = 4'b0111; //subu
        end
        
        2'b10: begin//Tipo-R
            case(i_functionCode)
                6'b000000: o_ALUBitsControl = 4'b0000; //sll
                6'b000010: o_ALUBitsControl = 4'b0001; //srl
                6'b000011: o_ALUBitsControl = 4'b0010; //sra
                6'b000100: o_ALUBitsControl = 4'b0000; //sllv
                6'b000110: o_ALUBitsControl = 4'b0001; //srlv
                6'b000111: o_ALUBitsControl = 4'b0010; //srav
                6'b100001: o_ALUBitsControl = 4'b0110; //addu
                6'b100011: o_ALUBitsControl = 4'b0111; //subu
                6'b100100: o_ALUBitsControl = 4'b1000; //and
                6'b100101: o_ALUBitsControl = 4'b1001; //or
                6'b100110: o_ALUBitsControl = 4'b1010; //xor
                6'b100111: o_ALUBitsControl = 4'b1011; //nor
                6'b101010: o_ALUBitsControl = 4'b1100; //slt
                default: o_ALUBitsControl = 4'b0110;
            endcase
        end
        2'b11: begin // son operaciones inmediatas
            case(i_operationCode)
                6'b001000: o_ALUBitsControl=4'b0100; //addi
                6'b001100: o_ALUBitsControl=4'b1000; //andi
                6'b001101: o_ALUBitsControl=4'b1001; //ori
                6'b001110: o_ALUBitsControl=4'b1010; //xori
                6'b001111: o_ALUBitsControl=4'b0011; //lui
                6'b001010: o_ALUBitsControl=4'b1100; //slti
                default: o_ALUBitsControl = 4'b1000; 
            endcase
        end
        default: o_ALUBitsControl = 4'b0110;
    endcase
     
    end
    
endmodule
