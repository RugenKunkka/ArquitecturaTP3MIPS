`include "Macros.v"

module Etapa2_InstructionDecode
    #(
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,


        // For Register File
        parameter REGFILE_DEPTH =  `REGFILE_DEPTH,
        parameter REGFILE_ADDR_LEN =  `REGFILE_ADDR_LEN,
        parameter REGFILE_LEN =  `REGFILE_LEN
    )
    (
        input wire i_clock,
        input wire i_reset,

        input wire [INS_LEN-1:0] i_instruction,
        output wire [INS_LEN-1:0] o_instruction,
        
        input wire [REGFILE_ADDR_LEN-1:0] i_addressEscrituraToRegisterMemory, 
        input wire [REGFILE_DEPTH-1:0] i_datoAEscribirToRegisterMemory,
        
        input wire i_controlRegWriteToRegisterMemory,
        
        //outputs wireados a otras etapas sin necesidad de reistro intermedio
        //osea.. NO VA AL REGISTRO.. sale de one
        output wire [32-1:0] o_incoditionalJumpAddress,
        
        //--------------REISTROS RELACIONADOS con el el registro intermedio------------------------ 
        output wire [REGFILE_LEN-1:0] o_dataA,
        output wire [REGFILE_LEN-1:0] o_dataBFromMux,
        
        //control outputs
        output wire o_controlRegDst,
        output wire o_controlJump,
        output wire o_controlBranch,
        output wire o_controlMemRead,
        output wire o_controlMemtoReg,
        output wire [4-1:0] o_controlALUOp,//este no se si lo vamos a sacar afuera
        output wire o_controlMemWrite,
        //output wire o_controlALUSrc, //<- Esto me parece que no va. El Alusrc es interno a la etapa
        output wire o_controlRegWrite,
        output wire o_controlIsJALR,
        output wire o_signedLoad_fromCUToE3,
        
        //For/From Debug Unit
        input wire [REGFILE_ADDR_LEN-1:0]   i_addr_fromDUToRegFile,
        output wire [REGFILE_LEN-1:0]       o_data_fromRegFileToDU, 
        input wire                          i_muxSel_fromDUToRegFileMux,

        output wire [REGFILE_LEN-1:0] o_ReadData2,

        input  wire [INSMEM_ADDR_LEN-1:0]  i_pcMas4,
        output wire [INSMEM_ADDR_LEN-1:0]  o_pcMas4, 

        output wire o_halt_fromCUToE3,

        output wire [3-1:0] o_whbLS_fromCUToE3,

        output wire o_BNEQ_fromCUToE3
        
    );
    
    wire        o_wire_controlRegDst;
    wire        o_wire_controlJump;
    wire        o_wire_controlBranch;
    wire        o_wire_controlMemRead;
    wire        o_wire_controlMemtoReg;
    wire [4-1:0] o_wire_controlALUOp;//este no se si lo vamos a sacar afuera
    wire        o_wire_controlMemWrite;
    wire        o_wire_controlALUSrc;
    wire        o_wire_controlRegWrite;
    wire        o_wire_controlHalt;
    wire [3-1:0]o_wire_control_whbLS ;
    wire        o_wire_controlBNEQ;
    
    E2_ControlUnit
    #(
    )
    u_ControlUnit
    (
        .i_operationCode    (i_instruction[31:26]),
        .i_bits20_16        (i_instruction[20:15]),
        .i_bits10_6         (i_instruction[11:6]), 
        .i_bits20_6         (i_instruction[20:6]),
        
        .i_functionCode(i_instruction[5:0]),
        
        .o_controlRegDst    (o_wire_controlRegDst),
        .o_controlIsJump      (o_controlJump),
        .o_controlIsBranch    (o_wire_controlBranch),
        .o_controlMemRead   (o_wire_controlMemRead),
        .o_controlMemtoReg  (o_wire_controlMemtoReg),
        .o_controlALUOp     (o_wire_controlALUOp),
        .o_controlMemWrite  (o_wire_controlMemWrite),
        .o_controlALUSrc    (o_wire_controlALUSrc),
        .o_controlRegWrite  (o_wire_controlRegWrite),
        .o_controlHalt      (o_wire_controlHalt),
        .o_control_whbLS    (o_wire_control_whbLS),
        .o_controlIsBNEQ      (o_wire_controlBNEQ)
    );
    
    wire [32-1:0] wire_o_dataBFromRegisterMemoryToMuxALU;
    wire [32-1:0] w_dataA;
    //wire o_wire_dataA
    E2_RegisterMemory
    #(
        .REGFILE_LEN        (REGFILE_LEN),
        .REGFILE_DEPTH      (REGFILE_DEPTH),
        .REGFILE_ADDR_LEN   (REGFILE_ADDR_LEN)
    )
    u_RegisterMemory
    (
        .i_clock(i_clock),
        .i_reset(i_reset),  

        .i_RegWrite_fromControl(i_controlRegWriteToRegisterMemory),
        
        .i_AddressLecturaA  (i_instruction[25:21]),
        .i_AddressLecturaB  (i_instruction[20:16]),
        .i_AddressEscritura (i_addressEscrituraToRegisterMemory),
        .i_DatoAEscribir    (i_datoAEscribirToRegisterMemory),
        
        .o_dataA    (o_dataA),
        .o_dataB    (wire_o_dataBFromRegisterMemoryToMuxALU)
    );
    
    wire [32-1:0] wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB;

    GenericZeroExtender
    #(
        .ZEXT_IN_LEN(16),
        .ZEXT_OUT_LEN(32)
    )
    u1_ExtensorDePalabra
    (
        .i_data(i_instruction[16-1:0]),//esto es para operaciones distintos del tipo R xq tiene el campo inmediato ahi... 
        .o_extendedData(wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB)
    );
    
    wire [32-1:0] wire_o_dataMuxAluSrc;
    wire  [32-1:0] w_dataBFromMux;

    GenericMux2to1 
    #(
        .LEN(32)
    ) 
    u1_MuxAluInputB 
    (
        .i_bus0 (wire_o_dataBFromRegisterMemoryToMuxALU),
        .i_bus1 (wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB),
        .i_muxSel(o_wire_controlALUSrc),
        .o_bus  (w_dataBFromMux)
    );
    
    wire [26-1:0] wire_shiftedInconditionalJumpAddress; // Len 26 o 28 ?

    GenericShifter
    #(
        .IN_LEN(26),
        .OUT_LEN(26),
        .NUM_TO_SHIFT(2)
    )
    u1_Shift2Unit
    (
        .i_data(i_instruction[25:0]),
        .o_shiftedData(wire_shiftedInconditionalJumpAddress)
    );
    
    GenericSignExtender
    #(
        .SIGNEXT_IN_LEN(26),
        .SIGNEXT_OUT_LEN(32)
    )
    u1_ExtensorDeSigno
    (
        .i_data(wire_shiftedInconditionalJumpAddress),
        .o_extendedSignedData(o_incoditionalJumpAddress)
    );

    E2_Reg_ID_EX
    #(

    )
    u_Reg_ID_EX
    (
        .i_clock(i_clock),
        .i_reset(i_reset),

        //inputs normales
        .i_instruction(i_instruction),
        .i_dataA(w_dataA),
        .i_dataBFromMux(w_dataBFromMux),
        
        //input control info
        .i_controlRegDst    (o_wire_controlRegDst),
        //.i_controlJump      (o_wire_controlJump),
        .i_controlBranch    (o_wire_controlBranch),
        .i_controlMemRead   (o_wire_controlMemRead),
        .i_controlMemtoReg  (o_wire_controlMemtoReg),
        .i_controlALUOp     (o_wire_controlALUOp),//este no se si lo vamos a sacar afuera
        .i_controlMemWrite  (o_wire_controlMemWrite),
        //.i_controlALUSrc    (),
        .i_controlRegWrite  (o_wire_controlRegWrite),
        
        //outputs normales
        .o_instruction  (o_instruction),//lo vamos a necesitar para sacar el rt y rd  
        .o_dataA        (o_dataA),//va a la ALU
        .o_dataBFromMux (o_dataBFromMux),//va a la ALU
        
        //output control info
        .o_controlRegDst    (o_controlRegDst),
        //.o_controlJump      (o_controlJump),
        .o_controlBranch    (o_controlBranch),
        .o_controlMemRead   (o_controlMemRead),
        .o_controlMemtoReg  (o_controlMemtoReg),
        .o_controlALUOp     (o_controlALUOp),//este no se si lo vamos a sacar afuera
        .o_controlMemWrite  (o_controlMemWrite),
        //.o_controlALUSrc    (),
        .o_controlRegWrite  (o_controlRegWrite),
        .o_signedLoad_fromCU(o_signedLoad_fromCUToE3),

        .i_ReadData2    (wire_o_dataBFromRegisterMemoryToMuxALU),
        .o_ReadData2    (o_ReadData2),

        .i_pcMas4 (i_pcMas4),
        .o_pcMas4 (o_pcMas4),

        .i_halt_fromCU  (o_wire_controlHalt),
        .o_halt_fromCUToE3  (o_halt_fromCUToE3),

        .i_whbLS_fromCU (o_wire_control_whbLS),
        .o_whbLS_fromCUToE3 (o_whbLS_fromCUToE3),

        .i_BNEQ_fromCU (o_wire_controlBNEQ),
        .o_BNEQ_fromCUToE3 (o_BNEQ_fromCUToE3)
    );  
    
    // assign o_data_fromRegFileToDU = 
    
endmodule
