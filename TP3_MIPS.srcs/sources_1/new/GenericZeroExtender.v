`include "Macros.v"

//le agrega LENTOFILL ceros a la izquierda (MSB) a la data que entra

module GenericZeroExtender
    #(
        parameter ZEXT_IN_LEN  = `ZEXT_IN_LEN,
        parameter ZEXT_OUT_LEN = `ZEXT_OUT_LEN
    )
    (
        input wire  [ZEXT_IN_LEN-1:0]   i_data,        
        output wire [ZEXT_OUT_LEN-1:0]  o_extendedData

    );
    localparam LENTOFILL =  ZEXT_OUT_LEN - ZEXT_IN_LEN;
        
    assign o_extendedData = { { LENTOFILL{`ZERO} }, i_data} ;
    
endmodule
