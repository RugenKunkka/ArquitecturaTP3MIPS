`include "Macros.v"

module Etapa1_InstructionFetch
    #(
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
        parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN,   // Instruction Legth
        parameter INS_LEN           = `INS_LEN,
        parameter INSMEM_DEPTH      = `INSMEM_DEPTH
    )
    ( 
        input wire i_clock,//resolver el warning este [Synth 8-3848] Net i_clock in module/entity Etapa1_FetchInstruction does not have driver. ["D:/Facultad/Arquitectura de computadoras/MIS_TPS/TP3_MIPS/TP3_MIPS.srcs/sources_1/new/Etapa1FetchInstruction.v":27]
        input wire i_reset,
        
        //input data To muxs
        input wire [INS_LEN-1:0] i_dataPCJumpAddressToMux1,
        input wire [INS_LEN-1:0] i_dataPCJumpAddressRToMux2,
        input wire [INS_LEN-1:0] i_dataPCBranchAddressToMux3,
        
        //controll bits
        //mux controll
        input wire i_controlMux1JumpAddress,
        input wire i_controlMux2JumpRAddress,
        input wire i_controlMux3BranchAddress,
        
        //output de la etapa
        output wire [INS_LEN-1:0] o_pcMas4,
        output wire [INS_LEN-1:0] o_instruction,

        // For Debug Unit
        input wire                          i_clockIgnore_fromDU,
        output wire [INS_LEN-1:0]           o_pc_fromPcToDU, 
        input wire                          i_we_fromDUToInsMem,
        input wire [INSMEM_ADDR_LEN-1:0]    i_addr_fromDUToInsMem,
        input wire [INSMEM_DAT_LEN-1:0]     i_data_fromDUToInsMem, 
        input wire                          i_muxSel_fromDUToInsMemMux

    );
      
    wire [32-1:0] wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID;
    wire [32-1:0] wire_o_dataFromMux1ToMux2;

    GenericMux2to1 
    #(
        .LEN(INS_LEN)
    ) 
    u1_Mux1
    (
        .i_bus0(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID),
        .i_bus1(i_dataPCJumpAddressToMux1),
        .i_muxSel(i_controlMux1JumpAddress),
        .o_bus(wire_o_dataFromMux1ToMux2)
    );
    
    wire [32-1:0] wire_o_dataFromMux2ToMux3;

    GenericMux2to1 
    #(
        .LEN(INS_LEN)
    ) 
    u1_Mux2 
    (
        .i_bus0(wire_o_dataFromMux1ToMux2),
        .i_bus1(i_dataPCJumpAddressRToMux2),
        .i_muxSel(i_controlMux2JumpRAddress),
        .o_bus(wire_o_dataFromMux2ToMux3)
    );
    
    wire [INS_LEN-1:0] wire_o_dataFromMux3ToPC;

    GenericMux2to1 
    #(
        .LEN(INS_LEN)
    )  
    u1_Mux3 
    (
        .i_bus0(wire_o_dataFromMux2ToMux3),
        .i_bus1(i_dataPCBranchAddressToMux3),
        .i_muxSel(i_controlMux3BranchAddress),
        .o_bus(wire_o_dataFromMux3ToPC)
    );
    
    wire [INS_LEN-1:0] wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4;
    
    E1_PC
    #(

    )
    u1_PC
    ( 
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_pcAddressIn(wire_o_dataFromMux3ToPC),
        .o_pcAddressOut(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4)
    );
    
    GenericAdder
    #(
        .LEN(INS_LEN)
    )
    u_SumadorMas4
    (
        .i_dataA(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4),
        .i_dataB(32'd4),
        .o_result(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID)
    );

    wire[INS_LEN-1:0] w_addr_fromDUOrPC;    

    GenericMux2to1 
    #(
        .LEN(INS_LEN)
    )  
    u_MuxDUOrPC
    (
        .i_bus0(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4),
        .i_bus1(i_addr_fromDUToInsMem),
        .i_muxSel(i_muxSel_fromDUToInsMemMux),
        .o_bus(w_addr_fromDUOrPC)
    );


    wire [INS_LEN-1:0] wire_o_intructionFromMemoryToReg_IF_ID;

    E1_InstructionMemory 
    #(
        .INSMEM_DEPTH(INSMEM_DEPTH), // See Macros.v
        .INSMEM_ADDR_LEN(INSMEM_ADDR_LEN),
        .INS_LEN(INS_LEN), // 32
        .INSMEM_DAT_LEN(INSMEM_DAT_LEN) // 8
    ) 
    u1_InstructionMemory 
    (

        .i_clock(i_clock),
        .i_reset(i_reset),

        .i_address(w_addr_fromDUOrPC),
        .o_instruction(wire_o_intructionFromMemoryToReg_IF_ID),

        // For Debug Unit (Programming)
        .i_writeEnable_fromDU(i_writeEnable_fromDU),
        .i_data_fromDU(i_data_fromDUToInsMem), 
        .i_clockIgnore_fromDU(i_clockIgnore_fromDU)

    );
    
    E1_Reg_IF_ID
    #(

    )
    u1_Reg_IF_ID
    (
        .i_clock(i_clock),
        .i_reset(i_reset),

        .i_instruction(wire_o_intructionFromMemoryToReg_IF_ID),
        .i_pcMas4(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID),
        
        .o_instruction(o_instruction),
        .o_pcMas4(o_pcMas4)
    );
    
    
endmodule
