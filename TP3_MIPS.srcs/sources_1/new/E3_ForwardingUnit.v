`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 10:04:38 AM
// Design Name: 
// Module Name: E3_ForwardingUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module E3_ForwardingUnit(
        input wire [5-1:0] i_rs,
        input wire [5-1:0] i_rt,
        
        input wire [5-1:0] i_rdFromEtapa4RegEX_MEM,
        input wire [5-1:0] i_rdFromEtapa5RegMEM_WB,
        
        input wire i_controlRegWriteFromEtapa4RegEX_MEM,
        input wire i_controlRegWriteFromEtapa5RegMEM_WB,
        
        input wire i_controlRegDst,
        input wire i_controlMemWrite,
        
        
        output reg [2-1:0] o_forwardA,
        output reg [2-1:0] o_forwardB,
        output reg [2-1:0] o_forwardC

    );
    
    //interface
    /*
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
    */
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
        //instrucción que la debe de guardar en un registro...
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
endmodule
