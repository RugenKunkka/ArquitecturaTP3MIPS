`include "Macros.v"

module GenericMux3to1_3bits
    #(
        parameter LEN=32
    )
    (
        input  wire [LEN-1:0] i_bus001,
        input  wire [LEN-1:0] i_bus010,
        input  wire [LEN-1:0] i_bus100,
        input  wire [3-1:0] i_muxSel,  
        output reg  [LEN-1:0] o_bus
    );

    always @(*) begin
        if(i_muxSel == 3'b001) begin
            o_bus = i_bus001;
        end
        else if(i_muxSel == 3'b010) begin
            o_bus = i_bus010;
        end
        else if(i_muxSel == 3'b100) begin
            o_bus = i_bus100;  
        end
        else begin
            o_bus = i_bus001;
        end
    end
endmodule

/*
module GenericMux3to1_3bits
    #(
        parameter LEN=32
    )
    (
        input  wire [LEN-1:0] i_pcFromRegister,
        input  wire [LEN-1:0] i_pcBranch,
        input  wire [LEN-1:0] i_pcJump,
        input  wire [LEN-1:0] i_pcNormal,
        input  wire [3-1:0] i_selectPcSourceCode,  
        output reg  [LEN-1:0] o_muxToPC
    );

    always @(*) begin
        if(i_selectPcSourceCode == 3'b001) begin
            o_muxToPC=i_pcFromRegister;
        end
        else if(i_selectPcSourceCode == 3'b010) begin
            o_muxToPC=i_pcBranch;
        end
        else if(i_selectPcSourceCode == 3'b100) begin
            o_muxToPC=i_pcJump;  
        end
        else begin
            o_muxToPC=i_pcNormal;
        end
    end

endmodule
    */
    

