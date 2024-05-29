`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2024 02:00:05 AM
// Design Name: 
// Module Name: E2_ControlUnitAluOP
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


module E2_ControlUnitAluOP(
    input wire i_reset,
    
    //6 bits MSB
    input wire [6-1:0]  i_operationCode,// bits del 31-26 esto te indica el tipo de operacion por ejemplo si es R o de branch etc..
    input wire [6-1:0]  i_bits20_16,//se usa en algunas instrucciones como JALR
    input wire [6-1:0]  i_bits10_6,//se usa en algunas instrucciones como JALR
    input wire [15-1:0] i_bits20_6,//este rango de bits se usa para un registro en especifico (JR) 
    //6 bits LSB
    input wire [6-1:0]  i_functionCode,//bits del 5-0 este te dice que operacion es por ejemplo si es suma, un salto, resta, desplazamiento etc...
    
    output reg [5:0] o_controlALUOp
    );
    /*
    i_reset,
    i_op_code,
    
    o_alu_op
    */
    /*E2_ControlUnitAluOP
    #(
        
    )
    u_E2_ControlUnitAluOP
    (
        .i_reset        (),
    
        .i_operationCode(),
        .i_bits20_16    (),
        .i_bits10_6     (),
        .i_bits20_6     (),
        .i_functionCode (),
        
        .o_controlALUOp()
    );
    */
    
    
    always @(*) begin
        if(i_reset) begin
            o_controlALUOp <= 6'b000000;
        end 
        //JALR ok
        else if (i_operationCode==6'b000000 && i_bits20_16==5'b00000 && i_bits10_6==5'b00000 && i_functionCode==6'b001001) begin
            o_controlALUOp<=6'b000000;
        end
        //JR ok
        else if (i_operationCode==6'b000000 && i_bits20_6==15'b000000000000000) begin
            o_controlALUOp<=6'b000000;
        end
        
        else if(i_operationCode==6'b000000) begin //TIPO - R y a partir de ahora me queda verificar el func code
        //VER SLL Y SRL a que grupo pertenecen xq se me armo quilombo ahi
            case (i_functionCode)
                6'b000100: begin//SLLV
                    o_controlALUOp<=6'b100000;
                end
                6'b000110: begin//SRLV
                    o_controlALUOp<=6'b010000;
                end
                6'b000111: begin//SRAV
                    o_controlALUOp<=6'b001000;
                end
                6'b100001: begin//ADDU
                    o_controlALUOp<=6'b000001;
                end
                6'b100011: begin//SUBU
                    o_controlALUOp<=6'b000010;
                end
                6'b100100: begin//AND
                    o_controlALUOp<=6'b000011;
                end
                6'b100101: begin//OR
                    o_controlALUOp<=6'b000100;
                end
                6'b100110: begin//XOR
                    o_controlALUOp<=6'b000101;
                end
                6'b100111: begin//NOR
                    o_controlALUOp<=6'b000110;
                end
                6'b101010: begin//SLT
                    o_controlALUOp<=6'b111111;
                end
                6'b000000: begin//SLL
                    o_controlALUOp<=6'b011100;
                end
                6'b000010: begin//SRL
                    o_controlALUOp<=6'b010000;
                end
                6'b000011: begin//SRA
                    o_controlALUOp<=6'b001000;
                end
                
                default: begin
                    o_controlALUOp<=6'b000000;
                end
            endcase
        end
        else begin
            case (i_operationCode)
                6'b000010: begin//J OK
                    o_controlALUOp<=6'b000000;
                end
                6'b000011: begin//JAL OK
                    o_controlALUOp<=6'b000000;
                end
                6'b100000: begin//LB
                    o_controlALUOp<=6'b000001;
                end
                6'b100001: begin//LH
                    o_controlALUOp<=6'b000001;
                end
                6'b100011: begin//LW
                    o_controlALUOp<=6'b000001;
                end
                //6'b100111: begin//LWU
                //end
                6'b100100: begin//LBU
                    o_controlALUOp<=6'b000001;
                end
                6'b100101: begin//LHU
                    o_controlALUOp<=6'b000001;
                end
                6'b101000: begin//SB
                    o_controlALUOp<=6'b000001;
                end
                6'b101001: begin//SH
                    o_controlALUOp<=6'b000001;
                end
                6'b101011: begin//SW
                    o_controlALUOp<=6'b000001;
                end
                6'b001010: begin//SLTI
                    o_controlALUOp<=6'b111111;
                end
                6'b000100: begin//BEQ
                    o_controlALUOp<=6'b000010;
                end
                6'b000101: begin//BNE
                    o_controlALUOp<=6'b000010;
                end
                //-------------------------------------------
                //a partir de aca van las isntrucciones que son tipo I y tienen el mismo output
                //SUBI ver que ponemos para esto....
                6'b011110: begin//SUBI
                    o_controlALUOp<=6'b000010;
                end
                6'b001000: begin//ADDI
                    o_controlALUOp<=6'b000001;
                end
                6'b001100: begin//ANDI
                    o_controlALUOp<=6'b000011;
                end
                6'b001101: begin//ORI
                    o_controlALUOp<=6'b000100;
                end
                6'b001110: begin//XORI
                    o_controlALUOp<=6'b000101;
                end
                6'b001111: begin//LUI
                    o_controlALUOp<=6'b000111;
                end
                default: begin
                    o_controlALUOp<=6'b000000;
                end
            endcase
        end
    end
endmodule
