`include "Macros.v"

module GenericSignExtender //Former "ExtensorDeSigno"
    #(
        parameter SIGNEXT_IN_LEN =`SIGNEXT_IN_LEN,
        parameter SIGNEXT_OUT_LEN =`SIGNEXT_OUT_LEN
    )
    (
        input wire [SIGNEXT_IN_LEN-1:0]     i_data,
        output wire [SIGNEXT_OUT_LEN-1:0]   o_extendedSignedData
    );
    localparam ONE = `ONE;
    localparam ZERO = `ZERO; 
    localparam LENTOFILL = SIGNEXT_OUT_LEN - SIGNEXT_IN_LEN;
    
    assign o_extendedSignedData =  (i_data[SIGNEXT_IN_LEN-1] == 1 ) ?     
                                    { { LENTOFILL{ONE} }, i_data} : //True    
                                    { { LENTOFILL{ZERO} }, i_data}; //False
endmodule
