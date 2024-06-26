`include "Macros.v"

module E2_HazardUnit
    #(
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN
    )
    (
        output wire o_stallPC_fromHUToE1,
        output wire o_stallIFID_fromHUToE1,
        output wire o_stallIDEX_fromHUToE2,
        output reg o_reset_fromHUToCU,
        output wire o_flushEXMEM_fromHUToE3,
        output reg  o_post_bloqueo_1,
        
        input wire i_takeJumpR_fromE2ToHU,  
        input wire i_controlBranch_fromE2ToHU,
        
        input wire                          i_MemToReg_fromE4ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rs_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rt_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE4ToHU,
        input wire                          i_RegDst_fromE3ToHU,
        input wire                          i_controlIsJump,
        
        input wire                          i_post_bloqueo_1,
        input wire                          i_isZero,
        input wire                          i_controlIsBNQ,
        

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


    always @(*) begin

        if(i_reset) begin
            
            stall_PC_a      <= LOW;
            stall_IFID_a    <= LOW;
            stall_IDEX_a    <= LOW;
            flush_EXMEM_a   <= LOW;

            stall_PC_b      <= LOW;
            stall_IFID_b    <= LOW;

            o_reset_fromHUToCU <= LOW;
            
            o_post_bloqueo_1 <= LOW;

        end else begin
           //if(i_mem_to_reg & ((i_rd == i_rs) | (i_reg_dst & (i_rd == i_rt))))  // Idea
            if ( i_MemToReg_fromE4ToHU  & ((i_rd_fromE4ToHU == i_rs_fromE3ToHU) | ( i_RegDst_fromE3ToHU & (i_rd_fromE4ToHU == i_rt_fromE3ToHU )))) begin
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

            if(!i_post_bloqueo_1) begin
                o_reset_fromHUToCU<=LOW;
                if(i_takeJumpR_fromE2ToHU) begin // | i_controlBranch_fromE2ToHU)begin//JR JALR y para BEQ y BNE
                    stall_PC_b  <= LOW;
                    stall_IFID_b <= HIGH;
                    o_post_bloqueo_1<=HIGH;
                end
                else if (i_controlBranch_fromE2ToHU==1'b1 && i_isZero==1'b1 && i_controlIsBNQ==1'b0) begin //ok debe de entrar solo para BEQ
                    stall_PC_b  <= LOW;
                    stall_IFID_b <= HIGH;
                    o_post_bloqueo_1<=HIGH;
                end
                else if (i_controlBranch_fromE2ToHU==1'b1 && i_isZero==1'b0 && i_controlIsBNQ==1'b1) begin //debe de entrar para BNQ
                    stall_PC_b  <= LOW;
                    stall_IFID_b <= HIGH;
                    o_post_bloqueo_1<=HIGH;
                end
                else if (i_controlIsJump) begin //ok debe de entrar para J y JAL
                    stall_PC_b  <= LOW;
                    stall_IFID_b <= HIGH;
                    o_post_bloqueo_1<=HIGH;
                end
                else begin //si o si tuve que poner esto xq si no en BNQ cuando era un caso negativo... entraba lo mismo como si fuera positivo.. no se xq...
                    stall_PC_b  <= LOW;
                    stall_IFID_b <= LOW;
                    o_post_bloqueo_1<=LOW;
                end
                
            end     
            else begin 
                stall_PC_b  <= LOW;
                stall_IFID_b <= LOW;
                o_post_bloqueo_1<=LOW;
                o_reset_fromHUToCU<=LOW;
            end       
        end
    end

    /*
        Continuous Assignment      
    */
    assign o_stallPC_fromHUToE1 =  stall_PC_a |  stall_PC_b;
    assign o_stallIFID_fromHUToE1 = stall_IFID_a | stall_IFID_b;
    assign o_stallIDEX_fromHUToE2 = stall_IDEX_a;
    assign o_flushEXMEM_fromHUToE3 = flush_EXMEM_a ;


endmodule