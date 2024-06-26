`include "Macros.v"

module Etapa1_InstructionFetch
    #(
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
        parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN,   // Instruction Legth
        parameter INS_LEN           = `INS_LEN,
        parameter INSMEM_DEPTH      = `INSMEM_DEPTH
    )
    ( 
        // To  the next stage
        output wire [INS_LEN-1:0] o_pcMas4,
        output wire [INS_LEN-1:0] o_instruction,
        
        // For J, JAL, JR, JALR, BEQ, BNEQ
        input wire                  i_controlMux1JumpAddress,   
        input wire                  i_controlMux2JumpRAddress, 
        input wire                  i_controlMux3BranchAddress,
        input wire [INS_LEN-1:0]    i_dataPCJumpAddressToMux1,
        input wire [INS_LEN-1:0]    i_dataPCJumpAddressRToMux2, 
        input wire [INS_LEN-1:0]    i_dataPCBranchAddressToMux3,
        
        // From Hazard Unit
        input wire i_stallPC_fromHU,
        input wire i_stallIFID_fromHU,

        // From/For Debug Unit
        input wire                      i_we_fromDUToInsMem,       
        input wire [INSMEM_ADDR_LEN-1:0]i_addr_fromDUToInsMem,     
        input wire [INSMEM_DAT_LEN-1:0] i_data_fromDUToInsMem,     
        input wire                      i_muxSel_fromDUToInsMemMux,
        output wire [INS_LEN-1:0]       o_pc_fromPcToDU,           
        input wire                      i_clockIgnore_fromDUToPcAndLatch,
        input wire                      i_clockIgnore_fromDUToInsMem, 

        input wire i_clock,
        input wire i_reset

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
        .o_pcAddressOut(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4),
        .i_stallPC_fromHU(i_stallPC_fromHU),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDUToPcAndLatch)
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
        .i_writeEnable_fromDU   (i_we_fromDUToInsMem),
        .i_data_fromDU          (i_data_fromDUToInsMem), 
        .i_clockIgnore_fromDU   (i_clockIgnore_fromDUToInsMem)

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

        .i_stallIFID_fromHU(i_stallIFID_fromHU),
        
        .i_clockIgnore_fromDU (i_clockIgnore_fromDUToPcAndLatch),
        
        .o_instruction(o_instruction),
        .o_pcMas4(o_pcMas4)
    );
    
    assign o_pc_fromPcToDU = wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4;
    
endmodule
