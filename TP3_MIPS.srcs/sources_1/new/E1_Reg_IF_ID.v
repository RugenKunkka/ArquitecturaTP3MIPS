`include "Macros.v"

module E1_Reg_IF_ID
    #(
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN
    )
    (
        input wire i_clock,
        input wire i_reset,

        input wire [INS_LEN-1:0]            i_instruction,
        input wire [INSMEM_ADDR_LEN-1:0]    i_pcMas4,
        
        output reg [INS_LEN-1:0]            o_instruction,
        output reg [INSMEM_ADDR_LEN-1:0]    o_pcMas4,

        input wire i_stallIFID_fromHU,

        input wire i_clockIgnore_fromDU
    );
    
    //no se si resetear la instruccion pero lo pongo por las dudas
    always @(posedge i_clock) begin
        // pase lo que pase la instruccion no la puedo resetear en cero xq ya con resetear el pc a cero,
        //obtengo la instruccion cero del banco de memoria y 99,9999% que no son 32 ceros consecutivos.. ya el bloque de instrucciones
        //me va a devolver la instruccion que se encuentra en la posicion cero 
        
        if(i_reset) begin
            o_pcMas4<={32{1'b0}};
        end
        else begin
            if (~i_clockIgnore_fromDU) begin
                if (~i_stallIFID_fromHU) begin
                    o_pcMas4 <= i_pcMas4;
                    o_instruction<=i_instruction;
                end 
            end
        end
    end
endmodule
