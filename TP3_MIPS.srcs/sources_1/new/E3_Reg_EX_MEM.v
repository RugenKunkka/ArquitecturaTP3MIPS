`include "Macros.v"

module E3_Reg_EX_MEM
    #(
        parameter INS_LEN = `INS_LEN
    )
    (

        input wire i_clock,
        input wire i_reset,

        input wire i_controlRegWrite,
        input wire i_controlMemWrite,
        input wire i_controlMemtoReg,

        input wire [INS_LEN-1:0] i_PcMas4,
        input wire [32-1:0] i_ALUResult,
        
        input wire [32-1:0] i_dataQueQuieroEscribirEnMemoriaDeDatos,
        input wire [5-1:0] i_addressDeEscrituraRegisterMemory,
        
        
        output reg o_controlRegWrite,
        output reg o_controlMemWrite,
        output reg o_controlMemtoReg,

        output reg [INS_LEN-1:0] o_PcMas4,
        output reg [32-1:0] o_ALUResult,
        
        output reg [32-1:0] o_dataQueQuieroEscribirEnMemoriaDeDatos,
        output reg [5-1:0] o_addressDeEscrituraRegisterMemory,

        input wire i_signedLoad_fromCUToE3,
        output reg o_signedLoad_fromCUToE4,
        
        input wire i_halt_fromCU,
        output reg o_halt_fromCU

    );
    
    always @(i_clock)begin
        if(i_reset) begin
            o_controlRegWrite <= 0;
            o_controlMemWrite <= 0;
            o_controlMemtoReg <= 0;
            o_PcMas4 <= 0;
            o_ALUResult <= 0;
            o_dataQueQuieroEscribirEnMemoriaDeDatos <= 0;
            o_addressDeEscrituraRegisterMemory <= 0;
            o_signedLoad_fromCUToE4 <= 0;
            o_halt_fromCU <= 0;
        end
        else begin
            o_controlRegWrite <= i_controlRegWrite;
            o_controlMemWrite <= i_controlMemWrite;
            o_controlMemtoReg <= i_controlMemtoReg;
            o_PcMas4 <= i_PcMas4;
            o_ALUResult <= i_ALUResult;
            o_dataQueQuieroEscribirEnMemoriaDeDatos <= i_dataQueQuieroEscribirEnMemoriaDeDatos;
            o_addressDeEscrituraRegisterMemory <= i_addressDeEscrituraRegisterMemory;
            o_signedLoad_fromCUToE4 <= i_signedLoad_fromCUToE3;
            o_halt_fromCU <= i_halt_fromCU;
        end
    end
endmodule
