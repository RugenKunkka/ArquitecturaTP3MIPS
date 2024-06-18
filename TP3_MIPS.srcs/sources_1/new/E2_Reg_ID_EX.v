`include "Macros.v"

module E2_Reg_ID_EX
    #(
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,
        
        parameter REGFILE_LEN = `REGFILE_LEN
    )
    (
        input wire          i_controlBNEQ,
        input wire          i_controlBranch,
        input wire          i_controlJumpR,
        input wire          i_controlRegWrite,
        input wire          i_controlMemWrite,
        input wire          i_controlMemRead,
        input wire          i_controlMemtoReg,
        input wire          i_controlRegDst,
        input wire          i_controlPC4WB,
        input wire          i_controlGpr31,
        input wire [3-1:0]  i_controlWHBLS,
        input wire          i_controlSignedLoad,
        input wire          i_controlHalt,
        input wire [6-1:0]  i_controlALUOp,

        input wire [INSMEM_ADDR_LEN-1:0]    i_pcMas4,
        input wire [REGFILE_LEN-1:0]        i_dataA,
        input wire [REGFILE_LEN-1:0]        i_dataBFromMux,
        input wire [REGFILE_LEN-1:0]        i_ReadData2,
        input wire [INS_LEN-1:0]            i_instruction,
        input wire          i_post_bloqueo_1,

        output reg          o_controlBNEQ,
        output reg          o_controlBranch,
        output reg          o_controlJumpR,
        output reg          o_controlRegWrite,
        output reg          o_controlMemWrite,
        output reg          o_controlMemRead,
        output reg          o_controlMemtoReg,
        output reg          o_controlRegDst,
        output reg          o_controlPC4WB,
        output reg          o_controlGpr31,
        output reg [3-1:0]  o_controlWHBLS,
        output reg          o_controlSignedLoad,
        output reg          o_controlHalt,
        output reg [6-1:0]  o_controlALUOp,

        output reg [INSMEM_ADDR_LEN-1:0]    o_pcMas4,
        output reg [REGFILE_LEN-1:0]        o_dataA,
        output reg [REGFILE_LEN-1:0]        o_dataBFromMux,
        output reg [REGFILE_LEN-1:0]        o_ReadData2,
        output reg [INS_LEN-1:0]            o_instruction,
        output reg          o_post_bloqueo_1,
                
        // From Hazard Detection Unit        
        input wire i_stall_fromHU,

        // Form Debug Unit
        input wire i_clockIgnore_fromDU,

        input wire i_clock,
        input wire i_reset
    );

    localparam LOW = `LOW;
    
    always@(posedge i_clock) begin
        if(i_reset) begin

            o_controlBNEQ       <= 0;
            o_controlBranch     <= 0;
            o_controlJumpR      <= 0;
            o_controlRegWrite   <= 0;
            o_controlMemWrite   <= 0;
            o_controlMemRead    <= 0;
            o_controlMemtoReg   <= 0;
            o_controlRegDst     <= 0;
            o_controlPC4WB      <= 0;
            o_controlGpr31      <= 0;
            o_controlWHBLS      <= 0;
            o_controlSignedLoad <= 0;
            o_controlHalt       <= 0;
            o_controlALUOp      <= 0;

            o_pcMas4        <= 0;
            o_dataA         <= 0;
            o_dataBFromMux  <= 0;
            o_ReadData2     <= 0;
            o_instruction   <= 0;
            o_post_bloqueo_1<= 0;

        end else begin
            if(i_clockIgnore_fromDU == LOW) begin
                if (i_stall_fromHU == LOW) begin

                    o_controlBNEQ       <= i_controlBNEQ;
                    o_controlBranch     <= i_controlBranch;
                    o_controlJumpR      <= i_controlJumpR;
                    o_controlRegWrite   <= i_controlRegWrite;
                    o_controlMemWrite   <= i_controlMemWrite;
                    o_controlMemRead    <= i_controlMemRead;
                    o_controlMemtoReg   <= i_controlMemtoReg;
                    o_controlRegDst     <= i_controlRegDst;
                    o_controlPC4WB      <= i_controlPC4WB;
                    o_controlGpr31      <= i_controlGpr31;
                    o_controlWHBLS      <= i_controlWHBLS;
                    o_controlSignedLoad <= i_controlSignedLoad;
                    o_controlHalt       <= i_controlHalt;
                    o_controlALUOp      <= i_controlALUOp;

                    o_pcMas4        <= i_pcMas4;
                    o_dataA         <= i_dataA;
                    o_dataBFromMux  <= i_dataBFromMux;
                    o_ReadData2     <= i_ReadData2;
                    o_instruction   <= i_instruction;
                    o_post_bloqueo_1<= i_post_bloqueo_1;
                    
                end
            end
        end
    end
endmodule
