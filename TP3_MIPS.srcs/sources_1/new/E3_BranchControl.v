`include "Macros.v"

module E3_BranchControl
    (
        input wire i_zeroBit,
        input wire i_isBNEQ,//branch not equal
        input wire i_isBranch,//branch ==> esto lo pensamos por el BEQ
        output reg o_controlBranchAddressMux
    );
    
    //interface
    /*
        E3_BranchControl#()
        u1_E3_BranchControl(
            .i_zeroBit(),
            .i_isBNEQ(),
            .i_isBranch(),
            .o_controlBranchAddressMux()
        );
    */    
    
    always@(*) begin
        if(i_isBranch) begin
            if(i_isBNEQ)begin
                o_controlBranchAddressMux=~i_zeroBit;
            end
            else begin
                o_controlBranchAddressMux=i_zeroBit;
            end
        end
        else begin
            o_controlBranchAddressMux=0;
        end
    end
endmodule
