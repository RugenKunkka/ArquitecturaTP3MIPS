`include "Macros.v"

module E3_ForwardingUnit
    #(
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN   
    )
    (
        // Inputs from Etapa 3
        input wire [REGFILE_ADDR_LEN-1:0]   i_rs_fromE3ToFU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rt_fromE3ToFU,
        input wire                          i_MemWrite_fromE3ToFU,
        input wire                          i_RegDst_fromE3ToFU,

        // Inputs from Etapa 4
        input wire                          i_RegWrite_fromE4ToFU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE4ToFU,
        
        // Inputs from Etapa 5
        input wire                          i_RegWrite_fromE5ToFU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE5ToFU,

        // Output
        output reg [2-1:0] o_forwardA_muxSel,
        output reg [2-1:0] o_forwardB_muxSel,
        output reg [2-1:0] o_forwardC_muxSel
    );

    localparam NO_FORWARD       = 2'b00;
    localparam FORWARD_FROM_E4  = 2'b10;
    localparam FORWARD_FROM_E5  = 2'b01;
    localparam HIGH             = `HIGH ; 

    always @(*) begin
        
        /*
            For Mux A
        */
        if( i_rs_fromE3ToFU == i_rd_fromE4ToFU &&
            i_RegWrite_fromE4ToFU == HIGH &&
            i_rd_fromE4ToFU != 5'b00000 )begin
            o_forwardA_muxSel = FORWARD_FROM_E4;
        end
        else if (i_rs_fromE3ToFU == i_rd_fromE5ToFU &&
                i_RegWrite_fromE5ToFU == HIGH && 
                i_rd_fromE5ToFU != 5'b00000 ) begin
            o_forwardA_muxSel = FORWARD_FROM_E5;
        end
        else begin
            o_forwardA_muxSel = NO_FORWARD;
        end
        
        /*
            For Mux B
        */
        if(i_RegDst_fromE3ToFU) begin
            if( i_rt_fromE3ToFU == i_rd_fromE4ToFU &&
                i_RegWrite_fromE4ToFU == HIGH &&
                i_rd_fromE4ToFU != 5'b00000 )begin
                    o_forwardB_muxSel  = FORWARD_FROM_E4;
            end else if (i_rt_fromE3ToFU == i_rd_fromE5ToFU &&   
                        i_RegWrite_fromE5ToFU == HIGH && 
                        i_rd_fromE5ToFU != 5'b00000) begin
                            o_forwardB_muxSel = FORWARD_FROM_E5;
            end else begin
                o_forwardB_muxSel  = NO_FORWARD;
            end
        end
        else begin
            o_forwardB_muxSel  = NO_FORWARD;
        end


        /*
            For Mux C
        */
        if( i_rt_fromE3ToFU == i_rd_fromE4ToFU &&
            i_MemWrite_fromE3ToFU == HIGH) begin
                o_forwardC_muxSel = FORWARD_FROM_E4;
        end
        else if (i_rt_fromE3ToFU == i_rd_fromE5ToFU &&
                i_MemWrite_fromE3ToFU == HIGH) begin
                    o_forwardC_muxSel = FORWARD_FROM_E5;
        end
        else begin
            o_forwardC_muxSel = NO_FORWARD;
        end
    end
endmodule

    



/*(
        input wire [5-1:0] i_rs,
        input wire [5-1:0] i_rt,
        
        input wire [32-1:0] i_rdFromEtapa4RegEX_MEM, 
        input wire [32-1:0] i_rdFromEtapa5RegMEM_WB, 
        
        input wire i_controlRegWriteFromEtapa4RegEX_MEM,
        input wire i_controlRegWriteFromEtapa5RegMEM_WB,
        
        input wire i_controlRegDst,
        input wire i_controlMemWrite,
        
        
        output reg [2-1:0] o_forwardA,
        output reg [2-1:0] o_forwardB,
        output reg [2-1:0] o_forwardC

    );
    
    //interface
    
    E3_ForwardingUnit#()
    u1_E3_ForwardingUnit(
        .i_rs(),
        .i_rt(),
        
        .i_rdFromEtapa4RegEX_MEM(),
        .i_rdFromEtapa5RegMEM_WB(),
        
        .i_controlRegWriteFromEtapa4RegEX_MEM(),
        .i_controlRegWriteFromEtapa5RegMEM_WB(),
        
        .i_controlRegDst(),
        .i_controlMemWrite(),
        
        
        .o_forwardA(),
        .o_forwardB(),
        .o_forwardC()
    );
    
    always @(*) begin
        //primer mux
        if(i_controlRegWriteFromEtapa4RegEX_MEM && i_rdFromEtapa4RegEX_MEM!=0 && i_rs==i_rdFromEtapa4RegEX_MEM)begin
            o_forwardA=2'b10;
        end
        else if (i_controlRegWriteFromEtapa5RegMEM_WB && i_rdFromEtapa5RegMEM_WB!=0 && i_rs==i_rdFromEtapa5RegMEM_WB) begin
            o_forwardA=2'b01;
        end
        else begin
            o_forwardA=2'b00;
        end
        
        
        //segundo mux
        //i_controlRegDst=1 en instrucciones tipo R, en JALR, en BNE y en BEQ
        //en jalr rd =0 siempre , BEQ no, tiene un rt y BNE tiene rt al igual que BEQ
        if(i_controlRegDst) begin
            if(i_controlRegWriteFromEtapa4RegEX_MEM && i_rdFromEtapa4RegEX_MEM!=0 && i_rt==i_rdFromEtapa4RegEX_MEM)begin
                o_forwardB=2'b10;
            end
            else if (i_controlRegWriteFromEtapa5RegMEM_WB && i_rdFromEtapa5RegMEM_WB!=0 && i_rt==i_rdFromEtapa5RegMEM_WB) begin
                o_forwardB=2'b01;
            end
            else begin
                o_forwardB=2'b00;
            end
        end
        else begin
            o_forwardB=2'b00;
        end
        //tercer mux
        //rt pasa a ser mi registro destino... por lo tanto es el que me interesa comparar
        //si yo soy una instruccion del tipo save (lo hago fijandome en i_controlMemWrite y necesito un dato que esta calculando alguna
        //instrucci�n que la debe de guardar en un registro...
        if(i_controlMemWrite && i_rt==i_rdFromEtapa4RegEX_MEM) begin
            o_forwardB=2'b10;
        end
        else if (i_controlMemWrite && i_rt==i_rdFromEtapa5RegMEM_WB) begin
            o_forwardB=2'b01;
        end
        else begin
            o_forwardB=2'b00;
        end
    end

*/

