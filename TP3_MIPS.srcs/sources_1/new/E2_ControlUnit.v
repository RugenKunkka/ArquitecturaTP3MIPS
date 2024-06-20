`include "Macros.v"

module E2_ControlUnit
    (
        input wire [32-1:0] i_instruction,
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
        output reg          o_controlMemRead,//--------------------------????????????????????? para que lo pusimos???? FALTA ESTE EN TODAS LAS TABLAAAASSS osea.. los switch e ifs de abajo1!!!!!
        output reg          o_controlMemtoReg,//es para ver que dato guardas en el registro, si el resuultado de la ALU o la salida d ela memoria de datos
        output reg          o_controlRegDst,//en base a la instruccion te dice si el registro de destino es rt o rd
        output reg          o_controlPC4WB,
        output reg          o_controlGpr31,//creo que es el jumpR ==> stf // o_controlIsJALBit31
        
        //memwidth de 4 bits reemplazado
        output reg [3-1:0]  o_controlWHBLS,//
        output reg          o_controlSignedLoad,//bit 4 MSB
        
        output reg          o_controlALUSrc,//selecciona la fuente del dato 2 para la ALU, tiene un multiplexor
        output reg          o_controlHalt,
        output reg          o_isSLL_SRL_SRA,           
        //output reg o_controlisJALRBit31,//te dice si es la instruccion JALR especificamente para poder guardar la direccion de retorno (PC+4) en la posicion 31 de la memoria de registros
        input wire i_resetForHazard,
        input wire i_reset
    );
 
    always@(*) begin
        if(i_reset | i_resetForHazard) begin
            o_controlIsBNEQ     <= 0;
            o_controlIsBranch   <= 0;
            o_controlIsJumpTipoR<= 0;
            o_controlIsJump     <= 0;
            o_controlRegWrite   <= 0;
            o_controlMemWrite   <= 0;
            o_controlMemRead    <= 0;
            o_controlMemtoReg   <= 0;
            o_controlRegDst     <= 0;
            o_controlPC4WB      <= 0;
            o_controlGpr31      <= 0;
            o_controlWHBLS      <= 0;
            o_controlSignedLoad <= 0;
            o_controlALUSrc     <= 0;
            o_controlHalt       <= 0;
            o_isSLL_SRL_SRA     <= 0;
        end
        else if(i_instruction==32'b0) begin//NOP
            o_controlIsBNEQ     <= 0;
            o_controlIsBranch   <= 0;
            o_controlIsJumpTipoR<= 0;
            o_controlIsJump     <= 0;
            o_controlRegWrite   <= 0;
            o_controlMemWrite   <= 0;
            o_controlMemRead    <= 0;
            o_controlMemtoReg   <= 0;
            o_controlRegDst     <= 0;
            o_controlPC4WB      <= 0;
            o_controlGpr31      <= 0;
            o_controlWHBLS      <= 0;
            o_controlSignedLoad <= 0;
            o_controlALUSrc     <= 0;
            o_controlHalt       <= 0;
            o_isSLL_SRL_SRA     <= 0;
        end
        
        else if(i_operationCode==6'b111111) begin//HALT
            o_controlRegDst<=0;
            o_controlRegWrite<=0;
            o_controlALUSrc<=0;
            o_controlMemWrite<=0;
            o_controlMemtoReg<=0;
            o_controlPC4WB<=0;
            o_controlGpr31<=0;
            //el memwidth xxxx
            o_controlWHBLS<=3'b000;
            o_controlSignedLoad<=0;
            o_controlIsJump<=0;
            o_controlIsJumpTipoR<=0;//stefanooo fraannn hazard unit ==> estaba en 1
            o_controlIsBranch<=0;
            o_controlIsBNEQ<=0;
            
            o_controlHalt<=1;
            o_isSLL_SRL_SRA<= 0;
        end
        
        //JALR ok
        else if (i_operationCode==6'b000000 && i_bits20_16==5'b00000 && i_bits10_6==5'b00000 && i_functionCode==6'b001001) begin
            o_controlRegDst<=1;//
            o_controlRegWrite<=1;
            o_controlALUSrc<=0;//x
            o_controlMemWrite<=0;
            o_controlMemtoReg<=0;
            o_controlPC4WB<=1;
            o_controlGpr31<= 0;
            //el memwidth xxxx
            o_controlWHBLS<=3'b000;
            o_controlSignedLoad<=0;
            o_controlIsJump<=0;
            o_controlIsJumpTipoR<=1;//stefanooo fraannn hazard unit ==> estaba en 1
            //stefanooo Si se clava el programa es por esto pasarlo a 0 temporalmente
            o_controlIsBranch<=0;
            o_controlIsBNEQ<=0;
            
            o_controlHalt<=0;
            o_isSLL_SRL_SRA<= 0;
        end
        //JR ok
        else if (i_operationCode==6'b000000 && i_bits20_6==15'b000000000000000) begin
            o_controlRegDst<=0;
            o_controlRegWrite<=0;
            o_controlALUSrc<=0;
            o_controlMemWrite<=0;
            o_controlMemtoReg<=0;
            o_controlPC4WB<=0;
            o_controlGpr31<= 0;
            //el memwidth xxxx
            o_controlWHBLS<=3'b000;
            o_controlSignedLoad<=0;
            o_controlIsJump<=0;
            o_controlIsJumpTipoR<=1;//stefanooo fraannn hazard unit ==> estaba en 1
            o_controlIsBranch<=0;
            o_controlIsBNEQ<=0;
            
            o_controlHalt<=0;
            o_isSLL_SRL_SRA<= 0;
        end
        
        else if(i_operationCode==6'b000000) begin //TIPO - R y a partir de ahora me queda verificar el func code
        //VER SLL Y SRL a que grupo pertenecen xq se me armo quilombo ahi
            if(
            i_functionCode==6'b000100 ||//SLLV
            i_functionCode==6'b000110 ||//SRLV
            i_functionCode==6'b000111 ||//SRAV
            i_functionCode==6'b100001 ||//ADDU
            i_functionCode==6'b100011 ||//SUBU
            i_functionCode==6'b100100 ||//AND
            i_functionCode==6'b100101 ||//OR
            i_functionCode==6'b100110 ||//XOR
            i_functionCode==6'b100111 ||//NOR
            i_functionCode==6'b101010 //SLT
            ) begin
                o_controlRegDst<=1;
                o_controlRegWrite<=1;
                o_controlALUSrc<=0;
                o_controlMemWrite<=0;
                o_controlMemtoReg<=0;
                o_controlPC4WB<=0;
                o_controlGpr31<= 0;
                //el memwidth xxxx
                o_controlWHBLS<=3'b000;
                o_controlSignedLoad<=0;
                o_controlIsJump<=0;
                o_controlIsJumpTipoR<=0;
                o_controlIsBranch<=0;
                o_controlIsBNEQ<=0;
                
                o_controlHalt<=0;
                o_isSLL_SRL_SRA<= 0;
            end 
            else if(i_functionCode==6'b000000 || //SLL
            i_functionCode==6'b000010 ||//SRL
            i_functionCode==6'b000011 //SRA
            ) begin 
                o_controlRegDst<=1;
                o_controlRegWrite<=1;
                o_controlALUSrc<=0;
                o_controlMemWrite<=0;
                o_controlMemtoReg<=0;
                o_controlPC4WB<=0;
                o_controlGpr31<= 0;
                //el memwidth xxxx
                o_controlWHBLS<=3'b000;
                o_controlSignedLoad<=0;
                o_controlIsJump<=0;
                o_controlIsJumpTipoR<=0;
                o_controlIsBranch<=0;
                o_controlIsBNEQ<=0;
                
                o_controlHalt<=0;
                o_isSLL_SRL_SRA<=1;
            end
            else begin
                o_controlRegDst<=0;
                o_controlRegWrite<=0;
                o_controlALUSrc<=0;
                o_controlMemWrite<=0;
                o_controlMemtoReg<=0;
                o_controlPC4WB<=0;
                o_controlGpr31<=0;
                //el memwidth xxxx
                o_controlWHBLS<=3'b000;
                o_controlSignedLoad<=0;
                o_controlIsJump<=0;
                o_controlIsJumpTipoR<=0;
                o_controlIsBranch<=0;
                o_controlIsBNEQ<=0;
                
                o_controlHalt<=0;
                o_isSLL_SRL_SRA<=0;
            end
        end
        else begin
            case (i_operationCode)
                6'b000010: begin//J OK
                    o_controlRegDst<=0;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=0;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=1;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b000011: begin//JAL OK
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=0;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=1;
                    o_controlGpr31<=1;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=1;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100000: begin//LB
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<= 0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b001;//1001
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100001: begin//LH
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b010;//1010
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100011: begin//LW
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b100;//1100
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100111: begin//LWU
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b100;//0100
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100100: begin//LBU
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b001;//0001
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b100101: begin//LHU
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=1;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b010;//0010
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b101000: begin//SB
                    o_controlRegDst<=0;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=1;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b001;//1001
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b101001: begin//SH
                    o_controlRegDst<=0;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=1;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b010;//1010
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b101011: begin//SW
                    o_controlRegDst<=0;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=1;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b100;//1100
                    o_controlSignedLoad<=1;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001010: begin//SLTI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b000100: begin//BEQ
                    o_controlRegDst<=1;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=0;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=1;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b000101: begin//BNE
                    o_controlRegDst<=1;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=0;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=1;
                    o_controlIsBNEQ<=1;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                //-------------------------------------------
                //a partir de aca van las isntrucciones que son tipo I y tienen el mismo output
                //SUBI ver que ponemos para esto....
                //no pidieron SUBI!!!!!!!!!!! OJOOO
                6'b011110: begin//SUBI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001000: begin//ADDI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001100: begin//ANDI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001101: begin//ORI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001110: begin//XORI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                6'b001111: begin//LUI
                    o_controlRegDst<=0;
                    o_controlRegWrite<=1;
                    o_controlALUSrc<=1;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
                default: begin
                    o_controlRegDst<=0;
                    o_controlRegWrite<=0;
                    o_controlALUSrc<=0;
                    o_controlMemWrite<=0;
                    o_controlMemtoReg<=0;
                    o_controlPC4WB<=0;
                    o_controlGpr31<=0;
                    //el memwidth xxxx
                    o_controlWHBLS<=3'b000;
                    o_controlSignedLoad<=0;
                    o_controlIsJump<=0;
                    o_controlIsJumpTipoR<=0;
                    o_controlIsBranch<=0;
                    o_controlIsBNEQ<=0;
                    
                    o_controlHalt<=0;
                    o_isSLL_SRL_SRA<=0;
                end
            endcase
        end
        
    end
endmodule
