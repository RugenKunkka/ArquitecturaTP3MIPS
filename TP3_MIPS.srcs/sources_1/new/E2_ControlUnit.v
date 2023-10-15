`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2023 08:29:24 AM
// Design Name: 
// Module Name: E2_ControlUnit
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


module E2_ControlUnit(
        input wire i_clock,
        input wire i_reset,
        //6 bits MSB
        input wire [6-1:0] i_operationCode,// bits del 31-26 esto te indica el tipo de operacion por ejemplo si es R o de branch etc..
        input wire [6-1:0] i_bits20_16,//se usa en algunas instrucciones como JALR
        input wire [6-1:0] i_bits10_6,//se usa en algunas instrucciones como JALR
        input wire [15-1:0] i_bits20_6,//este rango de bits se usa para un registro en especifico (JR) 
        //6 bits LSB
        input wire [6-1:0]i_functionCode,//bits del 5-0 este te dice que operacion es por ejemplo si es suma, un salto, resta, desplazamiento etc...
        
        //control el libro indica estos 9
        output reg o_controlRegDst,
        output reg o_controlJump,
        output reg o_controlBranch,
        output reg o_controlMemRead,
        output reg o_controlMemtoReg,
        output reg [6-1:0]o_controlALUOp,//este no se si lo vamos a sacar afuera
        output reg o_controlMemWrite,
        output reg o_controlALUSrc,
        output reg o_controlRegWrite
    );
    //interface
    /*
        E2_ControlUnit#()
        u_ControlUnit(
            .i_clock(),
            .i_reset(),
            .i_operationCode(),
            .i_bits20_16(),
            .i_bits10_6(),
            .i_bits20_6(),
            .i_functionCode(),
            
            .o_controlRegDst(),
            .o_controlJump(),
            .o_controlBranch(),
            .o_controlMemRead(),
            .o_controlMemtoReg(),
            .o_controlALUOp(),
            .o_controlMemWrite(),
            .o_controlALUSrc(),
            .o_controlRegWrite()
        )
    */
    /*
    o_controlRegDst=0;
    o_controlJump=0;
    o_controlBranch=0;
    o_controlMemRead=0;
    o_controlMemtoReg=0;
    o_controlALUOp=0;
    o_controlMemWrite=0;
    o_controlALUSrc=0;
    o_controlRegWrite=0;
    */
    
    always@(*) begin
        if(i_reset) begin
            o_controlRegDst=0;
            o_controlJump=0;
            o_controlBranch=0;
            o_controlMemRead=0;
            o_controlMemtoReg=0;
            o_controlALUOp=0;
            o_controlMemWrite=0;
            o_controlALUSrc=0;
            o_controlRegWrite=0;
        end
        
        //JALR
        else if (i_operationCode==6'b000000 && i_bits20_16==5'b00000 && i_bits10_6==5'b00000 && i_functionCode==6'b001001) begin
        end
        //JR
        else if (i_operationCode==6'b000000 && i_bits20_6==15'b000000000000000) begin
        end
        
        else if(i_operationCode==6'b000000) begin //TIPO - R y a partir de ahora me queda verificar el func code
            case (i_functionCode)  
                6'b000000: begin//SLL
                //REVISAR!!
                    o_controlRegDst=1;//
                    o_controlJump=0;
                    o_controlBranch=0;
                    o_controlMemRead=0;//
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;//
                    o_controlALUSrc=0;// ==> uno dice 1 y otro dice 0 XD 
                    o_controlRegWrite=1;//
                end
                6'b000010: begin//SRL
                end
                6'b000011: begin//SRA
                end
                6'b000100: begin//SLLV
                end
                6'b000110: begin//SRLV
                end
                6'b000111: begin//SRAV
                end
                6'b100001: begin//ADDU
                end
                6'b100011: begin//SUBU
                end
                6'b100100: begin//AND
                end
                6'b100101: begin//OR
                end
                6'b100110: begin//XOR
                end
                6'b100111: begin//NOR
                end
                6'b101010: begin//STL
                end
                default: begin
                    o_controlRegDst=0;
                    o_controlJump=0;
                    o_controlBranch=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0;
                    o_controlRegWrite=0;
                end
            endcase  
        end
        else begin
            case (i_operationCode)
                6'b000010: begin//J
                end
                6'b000011: begin//JAL
                end
                6'b100000: begin//LB
                end
                6'b100001: begin//LH
                end
                6'b100011: begin//LW
                end
                6'b100111: begin//LWU
                end
                6'b100100: begin//LBU
                end
                6'b100101: begin//LHU
                end
                6'b101000: begin//SB
                end
                6'b101001: begin//SH
                end
                6'b101011: begin//SW
                end
                6'b0010000: begin//ADDI
                end
                6'b001100: begin//ANDI
                end
                6'b001101: begin//ORI
                end
                6'b001110: begin//XORI
                end
                6'b001111: begin//LUI
                end
                6'b001010: begin//SLTI
                end
                6'b000100: begin//BEQ
                    o_controlRegDst=1;
                    o_controlJump=0;
                    o_controlBranch=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0; 
                    o_controlRegWrite=0;
                end
                6'b000101: begin//BNE
                    o_controlRegDst=1;
                    o_controlJump=0;
                    o_controlBranch=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0; 
                    o_controlRegWrite=0;
                end
                default: begin
                    o_controlRegDst=0;
                    o_controlJump=0;
                    o_controlBranch=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0;
                    o_controlRegWrite=0;
                end
            endcase
        end
        
    end
endmodule
