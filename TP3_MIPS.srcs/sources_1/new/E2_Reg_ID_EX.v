`include "Macros.v"

module E2_Reg_ID_EX
    #(
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN
    )
    (
        input wire i_clock,
        input wire i_reset,
                
        //inputs normales
        input wire [32-1:0] i_instruction,
        input wire [32-1:0] i_dataA,
        input wire [32-1:0] i_dataBFromMux,
        
        //input control info
        input wire i_controlRegDst,
        input wire i_controlJump,
        input wire i_controlBranch,
        input wire i_controlMemRead,
        input wire i_controlMemtoReg,
        input wire [4-1:0] i_controlALUOp,//este no se si lo vamos a sacar afuera
        input wire i_controlMemWrite,
        //input wire i_controlALUSrc,
        input wire i_controlRegWrite,
        
        
        //outputs normales
        output reg [32-1:0] o_instruction,//lo vamos a necesitar para sacar el rt y rd  
        output reg [32-1:0] o_dataA,//va a la ALU
        output reg [32-1:0] o_dataBFromMux,//va a la ALU
        
        //output control info
        output reg o_controlRegDst,
        output reg o_controlJump,
        output reg o_controlBranch,
        output reg o_controlMemRead,
        output reg o_controlMemtoReg,
        output reg [4-1:0]o_controlALUOp,//este no se si lo vamos a sacar afuera
        output reg o_controlMemWrite,
        //output reg o_controlALUSrc,
        output reg o_controlRegWrite,

        output reg o_signedLoad_fromCU,
        
        input wire [32-1:0] i_ReadData2,
        output reg [32-1:0]o_ReadData2,

        input  wire [INSMEM_ADDR_LEN-1:0]  i_pcMas4, 
        output reg [INSMEM_ADDR_LEN-1:0]  o_pcMas4, 

        input wire i_halt_fromCU,
        output reg o_halt_fromCUToE3,

        input wire [3-1:0] i_whbLS_fromCU,
        output reg [3-1:0] o_whbLS_fromCUToE3,

        input wire  i_BNEQ_fromCU,
        output reg o_BNEQ_fromCUToE3
    );
    
    always@(posedge i_clock) begin
        if(i_reset) begin
            o_instruction<=0;
            o_dataA<=0;
            o_dataBFromMux<=0;
            
            o_controlRegDst <=0;
            o_controlJump   <=0;
            o_controlBranch <=0;
            o_controlMemRead    <=0;
            o_controlMemtoReg   <=0;
            o_controlALUOp  <=0;//este no se si lo vamos a sacar afuera
            o_controlMemWrite   <=0;
            //o_controlALUSrc <=0;
            o_controlRegWrite   <=0;

            o_ReadData2 <= 0;

            o_pcMas4 <= 0;

            o_halt_fromCUToE3 <= 0;

            o_whbLS_fromCUToE3 <= 0;
            
            o_BNEQ_fromCUToE3 <= 0;

        end
        else begin
            o_instruction<=i_instruction;
            o_dataA<=i_dataA;
            o_dataBFromMux<=i_dataBFromMux;
            
            o_controlRegDst     <=i_controlRegDst;
            o_controlJump       <=i_controlJump;
            o_controlBranch     <=i_controlBranch;
            o_controlMemRead    <=i_controlMemRead;
            o_controlMemtoReg   <=i_controlMemtoReg;
            o_controlALUOp      <=i_controlALUOp;//este no se si lo vamos a sacar afuera
            o_controlMemWrite   <=i_controlMemWrite;
            //o_controlALUSrc     <=i_controlALUSrc;
            o_controlRegWrite   <=i_controlRegWrite;

            o_ReadData2 <= i_ReadData2;

            o_pcMas4 <= i_pcMas4;

            o_halt_fromCUToE3 <= i_halt_fromCU;

            o_whbLS_fromCUToE3 <= i_whbLS_fromCU;

            o_BNEQ_fromCUToE3 <= i_BNEQ_fromCU;
        end 
    
    end
endmodule
