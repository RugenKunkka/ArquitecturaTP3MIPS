`include "Macros.v"

module E3_ALU
    // Parameters 
    #(
        parameter   DATA_LENGTH = `ALU_LEN,//32
                    OPERATORS_INPUT_SIZE = `OPERATORS_INPUT_SIZE 
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
		    6'b00_0000: o_ALUResult = i_dataB << i_dataA; //SLL SLLV (shift left) // ok
		    6'b00_0001: o_ALUResult = i_dataB >> i_dataA; //SRL SRLV (right logico) // ok
		    6'b00_0010: o_ALUResult = i_dataB >>> i_dataA; //SRA SRAV(right aritmetico) // ok
		    6'b00_0011: o_ALUResult = i_dataB << 16; //LUI //PROBAR QUE NO SEA CIRCULAR SI NO CONCATENAR 00 //ok
		    6'b00_0100: o_ALUResult = reg_signedDataA + reg_signedDataB; //ADDI //no tengo
		    6'b00_0110: o_ALUResult = i_dataA + i_dataB; //ADDU //ver
			6'b00_0111: //resta SUBU
			begin
			     o_ALUResult = i_dataA - i_dataB; //SUBU
			     o_Zero = (i_dataA==i_dataB) ? 1'b1 : 1'b0; //BRANCH
            end
			6'b00_1000: o_ALUResult = i_dataA & i_dataB; //AND //ANDI
			6'b00_1001: o_ALUResult = i_dataA | i_dataB; //OR //ORI
			6'b00_1010: o_ALUResult = i_dataA ^ i_dataB; // XOR //XORI
			6'b00_1011: o_ALUResult = ~(i_dataA | i_dataB); //NOR		
			6'b00_1100: o_ALUResult = reg_signedDataA < reg_signedDataB; //SLT SLTI //lo tengo en resta.. no se xq.. XD
			default: o_ALUResult = 0;
		endcase	
	end

    
endmodule

