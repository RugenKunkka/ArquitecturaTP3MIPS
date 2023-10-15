`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2023 03:01:52 PM
// Design Name: 
// Module Name: E3_ALU
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


module E3_ALU
    // Parameters 
    #(
        parameter   DATA_LENGTH = 32,//32
                    OPERATORS_INPUT_SIZE = 4 
    )
    // Ports
    (
        // Input Ports
        input wire signed [DATA_LENGTH-1:0] i_dataA,
        input wire signed [DATA_LENGTH-1:0] i_dataB,
        input wire [OPERATORS_INPUT_SIZE-1:0] i_controlOperationCode,
  
        // Output Ports
        output reg signed [DATA_LENGTH-1:0] o_ALUResult,
        output reg o_Zero
    );
    //interfaz
    /*
    E3_ALU#(32,4)
    u1_ALU(
        .i_dataA(),
        .i_dataB(),
        .i_controlOperationCode(),
        
        .o_ALUResult(),
        .o_Zero()
    )
    */

    reg signed [DATA_LENGTH-1:0] reg_signedDataA;
    reg signed [DATA_LENGTH-1:0] reg_signedDataB;

    always @(*) begin
        reg_signedDataA = i_dataA;
        reg_signedDataB = i_dataB;
    end

    always @(*) begin
		o_Zero = 0;

		case (i_controlOperationCode)
		    4'b 0000: o_ALUResult = i_dataB << i_dataA; //SLL SLLV (shift left) // ok
		    4'b 0001: o_ALUResult = i_dataB >> i_dataA; //SRL SRLV (right logico) // ok
		    4'b 0010: o_ALUResult = i_dataB >>> i_dataA; //SRA SRAV(right aritmetico) // ok
		    4'b 0011: o_ALUResult = i_dataB << 16; //LUI //PROBAR QUE NO SEA CIRCULAR SI NO CONCATENAR 00 //ok
		    4'b 0100: o_ALUResult = reg_signedDataA + reg_signedDataB; //ADDI //no tengo
		    4'b 0110: o_ALUResult = i_dataA + i_dataB; //ADDU //ver
			4'b 0111: //resta SUBU
			begin
			     o_ALUResult = i_dataA - i_dataB; //SUBU
			     o_Zero = (i_dataA==i_dataB) ? 1'b1 : 1'b0; //BRANCH
            end
			4'b 1000: o_ALUResult = i_dataA & i_dataB; //AND //ANDI
			4'b 1001: o_ALUResult = i_dataA | i_dataB; //OR //ORI
			4'b 1010: o_ALUResult = i_dataA ^ i_dataB; // XOR //XORI
			4'b 1011: o_ALUResult = ~(i_dataA | i_dataB); //NOR		
			4'b 1100: o_ALUResult = reg_signedDataA < reg_signedDataB; //SLT SLTI //lo tengo en resta.. no se xq.. XD
			default: o_ALUResult = 0;
		endcase	
	end

    
endmodule

