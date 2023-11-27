`include "Macros.v"

module GenericShifter//Former "Shift2Unit"
    #(
        parameter IN_LEN = 26,
        parameter OUT_LEN = 26,
        parameter NUM_TO_SHIFT = 2
    )
    (
        input wire [IN_LEN-1:0] i_data,
        output wire [OUT_LEN-1:0] o_shiftedData
    );
    
    assign o_shiftedData = i_data << NUM_TO_SHIFT;

endmodule
