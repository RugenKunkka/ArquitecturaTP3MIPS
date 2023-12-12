`include "Macros.v"

module E3_Reg_EX_MEM
    #(
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN,
    
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,
        
        parameter ALU_LEN = `ALU_LEN,
        
        parameter DATMEM_LEN = `DAT_LEN
    )
    (
        input wire          i_controlRegWrite,
        input wire          i_controlMemWrite,
        input wire          i_controlMemRead,
        input wire          i_controlMemtoReg,
        input wire          i_controlPC4WB,
        input wire [3-1:0]  i_controlWHBLS,
        input wire          i_controlSignedLoad,
        input wire          i_controlHalt,

        input wire [INSMEM_ADDR_LEN-1:0] i_PcMas4,
        input wire [ALU_LEN-1:0]         i_ALUResult,       
        input wire [DATMEM_LEN-1:0]      i_dataQueQuieroEscribirEnMemoriaDeDatos,
        input wire [REGFILE_ADDR_LEN-1:0]i_addressDeEscrituraRegisterMemory,

        output reg           o_controlRegWrite,
        output reg           o_controlMemWrite,
        output reg           o_controlMemRead,
        output reg           o_controlMemtoReg,
        output reg           o_controlPC4WB,
        output reg [3-1:0]   o_controlWHBLS,
        output reg           o_controlSignedLoad,
        output reg           o_controlHalt,
        
        output reg [INSMEM_ADDR_LEN-1:0] o_PcMas4,
        output reg [ALU_LEN-1:0]         o_ALUResult,
        output reg [DATMEM_LEN-1:0]      o_dataQueQuieroEscribirEnMemoriaDeDatos,
        output reg [REGFILE_ADDR_LEN-1:0]o_addressDeEscrituraRegisterMemory,

        // For Hazard Unit
        input wire i_flushEXMEM_fromHU,

        // For Debug Unit
        input wire i_clockIgnore_fromDU,  
        
        input wire i_clock,
        input wire i_reset

    );
    
    always @(i_clock)begin
        if(i_reset) begin

            o_controlRegWrite = 0;
            o_controlMemWrite = 0;
            o_controlMemRead =  0;
            o_controlMemtoReg = 0;
            o_controlPC4WB =    0;
            o_controlWHBLS =    0;
            o_controlSignedLoad = 0;
            o_controlHalt =     0;

            o_PcMas4 = 0;
            o_ALUResult = 0;
            o_dataQueQuieroEscribirEnMemoriaDeDatos = 0;
            o_addressDeEscrituraRegisterMemory = 0;


        end
        else begin

            o_controlRegWrite   <= i_controlRegWrite;
            o_controlMemWrite   <= i_controlMemWrite;
            o_controlMemRead    <= i_controlMemRead;
            o_controlMemtoReg   <= i_controlMemtoReg;
            o_controlPC4WB      <= i_controlPC4WB;
            o_controlWHBLS      <= i_controlWHBLS;
            o_controlSignedLoad <= i_controlSignedLoad;
            o_controlHalt       <= i_controlHalt;

            o_PcMas4 <= i_PcMas4;
            o_ALUResult <= o_ALUResult;
            o_dataQueQuieroEscribirEnMemoriaDeDatos <= i_dataQueQuieroEscribirEnMemoriaDeDatos;
            o_addressDeEscrituraRegisterMemory <= i_addressDeEscrituraRegisterMemory;

        end
    end
endmodule
