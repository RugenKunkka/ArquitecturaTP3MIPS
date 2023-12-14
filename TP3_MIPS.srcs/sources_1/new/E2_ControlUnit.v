`include "Macros.v"

module E2_ControlUnit
    (
        //6 bits MSB
        input wire [6-1:0]  i_operationCode,// bits del 31-26 esto te indica el tipo de operacion por ejemplo si es R o de branch etc..
        input wire [6-1:0]  i_bits20_16,//se usa en algunas instrucciones como JALR
        input wire [6-1:0]  i_bits10_6,//se usa en algunas instrucciones como JALR
        input wire [15-1:0] i_bits20_6,//este rango de bits se usa para un registro en especifico (JR) 
        //6 bits LSB
        input wire [6-1:0]  i_functionCode,//bits del 5-0 este te dice que operacion es por ejemplo si es suma, un salto, resta, desplazamiento etc...

        output reg          o_controlIsBNEQ,//te dice si es un branch not equal
        output reg          o_controlIsBranch,//te dice si es un branch o no   
        output reg          o_controlIsJumpTipoR,//te dice si es un jump tipo R te sirve para el multiplexor      
        output reg          o_controlIsJump,//te dice si es un Jump nomas para el multiplexor sirve
        output reg          o_controlRegWrite,//te dice si vas a escribir el resultado en la memoria de registros de la etapa 2
        output reg          o_controlMemWrite,//se pone en 1 si la instruccion va a guardar en la memoria de datos.. por ahora son las instrucciones tipo save
        output reg          o_controlMemRead,
        output reg          o_controlMemtoReg,//es para ver que dato guardas en el registro, si el resuultado de la ALU o la salida d ela memoria de datos
        output reg          o_controlRegDst,//en base a la instruccion te dice si el registro de destino es rt o rd
        output reg          o_controlPC4WB,
        output reg          o_controlGpr31,
        output reg [3-1:0]  o_controlWHBLS,
        output reg          o_controlSignedLoad,
        output reg          o_controlALUSrc,//selecciona la fuente del dato 2 para la ALU, tiene un multiplexor
        output reg          o_controlHalt,
        output reg [6-1:0]  o_controlALUOp,//este no se si lo vamos a sacar afuera
           
        //output reg o_controlisJALRBit31,//te dice si es la instruccion JALR especificamente para poder guardar la direccion de retorno (PC+4) en la posicion 31 de la memoria de registros
        input wire i_resetForHazard,
        input wire i_reset
    );
 
    always@(*) begin
        if(i_reset | i_resetForHazard) begin
            o_controlIsBNEQ     = 0;
            o_controlIsBranch   = 0;
            o_controlIsJumpTipoR= 0;
            o_controlIsJump     = 0;
            o_controlRegWrite   = 0;
            o_controlMemWrite   = 0;
            o_controlMemRead    = 0;
            o_controlMemtoReg   = 0;
            o_controlRegDst     = 0;
            o_controlPC4WB      = 0;
            o_controlGpr31      = 0;
            o_controlWHBLS      = 0;
            o_controlSignedLoad = 0;
            o_controlALUSrc     = 0;
            o_controlHalt       = 0;
            o_controlALUOp      = 0;
        end
        
        //JALR
        else if (i_operationCode==6'b000000 && i_bits20_16==5'b00000 && i_bits10_6==5'b00000 && i_functionCode==6'b001001) begin
            o_controlRegDst=1;
            o_controlMemtoReg=0;
            o_controlALUOp=0;
            o_controlMemWrite=0;
            o_controlALUSrc=0;
            o_controlRegWrite=1;
            o_controlIsBNEQ=0;
            o_controlIsBranch=0;
            o_controlIsJump=0;
            o_controlIsJumpTipoR=1;
            o_controlHalt=0;
        end
        //JR
        else if (i_operationCode==6'b000000 && i_bits20_6==15'b000000000000000) begin
            o_controlRegDst=0;
            o_controlMemRead=0;
            o_controlMemtoReg=0;
            o_controlALUOp=0;
            o_controlMemWrite=0;
            o_controlALUSrc=0;
            o_controlRegWrite=0;
            o_controlIsBNEQ=0;
            o_controlIsBranch=0;
            //o_controlIsJumpR=0;
            o_controlIsJump=1;
            o_controlIsJumpTipoR=0;
            o_controlHalt=0;
        end
        
        else if(i_operationCode==6'b000000) begin //TIPO - R y a partir de ahora me queda verificar el func code
            //si es tipo R
            o_controlRegDst=1;
            o_controlMemRead=0;
            o_controlMemtoReg=0;
            o_controlALUOp=0;
            o_controlMemWrite=0;
            o_controlALUSrc=0;
            o_controlRegWrite=1;
            o_controlIsBNEQ=0;
            o_controlIsBranch=0;
            //o_controlIsJumpR=0;
            o_controlIsJump=0;
            o_controlIsJumpTipoR=0;
            o_controlHalt=0;
            case (i_functionCode)  
                6'b000000: begin//SLL
                //REVISAR!!
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
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
            endcase  
        end
        else begin
            case (i_operationCode)
                6'b000010: begin//J
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=1;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b000011: begin//JAL
                end
                6'b100000: begin//LB
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=1;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b100001: begin//LH
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=1;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b100011: begin//LW
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=1;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b100111: begin//LWU
                end
                6'b100100: begin//LBU
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=1;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b100101: begin//LHU
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=1;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b101000: begin//SB
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b101001: begin//SH
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
                6'b101011: begin//SW
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=1;
                    o_controlALUSrc=1;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
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
                end
                6'b000101: begin//BNE
                end
                default: begin
                    o_controlRegDst=0;
                    o_controlMemRead=0;
                    o_controlMemtoReg=0;
                    o_controlALUOp=0;
                    o_controlMemWrite=0;
                    o_controlALUSrc=0;
                    o_controlRegWrite=0;
                    o_controlIsBNEQ=0;
                    o_controlIsBranch=0;
                    //o_controlIsJumpR=0;
                    o_controlIsJump=0;
                    o_controlIsJumpTipoR=0;
                    o_controlHalt=0;
                end
            endcase
        end
        
    end
endmodule
