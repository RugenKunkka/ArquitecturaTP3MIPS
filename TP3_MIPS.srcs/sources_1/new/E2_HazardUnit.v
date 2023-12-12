`include "Macros.v"

module E2_HazardUnit
    #(
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN
    )
    (
        output wire o_stallPC_fromHUToE1,
        output wire o_stallIFID_fromHUToE1,
        output wire o_stallIDEX_fromHUToE2,
        output wire o_reset_fromHUToCU,
        
        input wire i_takeJumpR_fromE2ToHU,  
        input wire i_controlBranch_fromE2ToHU,
        
        input wire                          i_MemToReg_fromE4ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rs_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rt_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE4ToHU,
        input wire                          i_RegDst_fromE3ToHU,

        input wire  i_reset
    );

    /*
        Local parameters
    */
    localparam LOW = `LOW;
    localparam HIGH = `HIGH;

    reg stall_PC_a;
    reg stall_IFID_a;
    reg stall_IDEX_a;
    reg flush_EXMEM_a;

    reg stall_PC_b;
    reg stall_IFID_b;
    reg foo_IDEX_b;

    reg reset_CU;

    always @(*) begin

        if(i_reset) begin
            
            stall_PC_a      <= LOW;
            stall_IFID_a    <= LOW;
            stall_IDEX_a    <= LOW;
            flush_EXMEM_a   <= LOW;

            stall_PC_b      <= LOW;
            stall_IFID_b    <= LOW;
            foo_IDEX_b      <= LOW;

            reset_CU <= LOW;

        end else begin

            if( (i_MemToReg_fromE4ToHU == HIGH && 
                i_rd_fromE4ToHU == i_rs_fromE3ToHU) || 
                (i_RegDst_fromE3ToHU == HIGH && 
                i_rd_fromE4ToHU == i_rt_fromE3ToHU )) begin
                    stall_PC_a      <= HIGH;
                    stall_IFID_a    <= HIGH;
                    stall_IDEX_a    <= HIGH;
                    flush_EXMEM_a   <= HIGH;               
            end else begin
                stall_PC_a      <= LOW;
                stall_IFID_a    <= LOW;
                stall_IDEX_a    <= LOW;
                flush_EXMEM_a   <= LOW;
            end

            if(i_takeJumpR_fromE2ToHU | i_controlBranch_fromE2ToHU )begin
                stall_PC_b  <= HIGH;
                stall_IFID_b <= HIGH;
                foo_IDEX_b <= HIGH;
            end
        end
    end

    /*
        Continuous Assignment      
    */
    assign o_stallPC_fromHUToE1 =  stall_PC_a |  stall_PC_b;
    assign o_stallIFID_fromHUToE1 = stall_IFID_a | stall_IFID_b;
    assign o_reset_fromHUToCU = reset_CU;


endmodule