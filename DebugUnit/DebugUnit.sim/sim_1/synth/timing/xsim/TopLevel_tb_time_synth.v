// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sat Oct 14 17:58:12 2023
// Host        : DESKTOP-N36DDLV running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               C:/Users/UserTest1/College/CompArq/DebugUnit/DebugUnit.sim/sim_1/synth/timing/xsim/TopLevel_tb_time_synth.v
// Design      : TopLevel
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module BaudRateGenerator
   (w_tickSource,
    i_clock_fromPin_IBUF_BUFG,
    i_reset_fromPin_IBUF);
  output w_tickSource;
  input i_clock_fromPin_IBUF_BUFG;
  input i_reset_fromPin_IBUF;

  wire i_clock_fromPin_IBUF_BUFG;
  wire i_reset_fromPin_IBUF;
  wire o_reg_tick_i_1_n_0;
  wire o_reg_tick_i_2_n_0;
  wire [9:0]p_0_in;
  wire \reg_pulseCounter[6]_i_2_n_0 ;
  wire \reg_pulseCounter[9]_i_1_n_0 ;
  wire \reg_pulseCounter[9]_i_3_n_0 ;
  wire \reg_pulseCounter[9]_i_4_n_0 ;
  wire \reg_pulseCounter[9]_i_5_n_0 ;
  wire [9:0]reg_pulseCounter_reg;
  wire w_tickSource;

  LUT3 #(
    .INIT(8'hB8)) 
    o_reg_tick_i_1
       (.I0(w_tickSource),
        .I1(i_reset_fromPin_IBUF),
        .I2(o_reg_tick_i_2_n_0),
        .O(o_reg_tick_i_1_n_0));
  LUT5 #(
    .INIT(32'hFEAA0000)) 
    o_reg_tick_i_2
       (.I0(reg_pulseCounter_reg[8]),
        .I1(reg_pulseCounter_reg[6]),
        .I2(\reg_pulseCounter[9]_i_3_n_0 ),
        .I3(reg_pulseCounter_reg[7]),
        .I4(reg_pulseCounter_reg[9]),
        .O(o_reg_tick_i_2_n_0));
  FDRE #(
    .INIT(1'b0)) 
    o_reg_tick_reg
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(o_reg_tick_i_1_n_0),
        .Q(w_tickSource),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \reg_pulseCounter[0]_i_1 
       (.I0(reg_pulseCounter_reg[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \reg_pulseCounter[1]_i_1 
       (.I0(reg_pulseCounter_reg[0]),
        .I1(reg_pulseCounter_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \reg_pulseCounter[2]_i_1 
       (.I0(reg_pulseCounter_reg[2]),
        .I1(reg_pulseCounter_reg[0]),
        .I2(reg_pulseCounter_reg[1]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \reg_pulseCounter[3]_i_1 
       (.I0(reg_pulseCounter_reg[3]),
        .I1(reg_pulseCounter_reg[0]),
        .I2(reg_pulseCounter_reg[1]),
        .I3(reg_pulseCounter_reg[2]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \reg_pulseCounter[4]_i_1 
       (.I0(reg_pulseCounter_reg[4]),
        .I1(reg_pulseCounter_reg[2]),
        .I2(reg_pulseCounter_reg[1]),
        .I3(reg_pulseCounter_reg[0]),
        .I4(reg_pulseCounter_reg[3]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \reg_pulseCounter[5]_i_1 
       (.I0(reg_pulseCounter_reg[5]),
        .I1(reg_pulseCounter_reg[3]),
        .I2(reg_pulseCounter_reg[0]),
        .I3(reg_pulseCounter_reg[1]),
        .I4(reg_pulseCounter_reg[2]),
        .I5(reg_pulseCounter_reg[4]),
        .O(p_0_in[5]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \reg_pulseCounter[6]_i_1 
       (.I0(reg_pulseCounter_reg[6]),
        .I1(reg_pulseCounter_reg[4]),
        .I2(reg_pulseCounter_reg[2]),
        .I3(\reg_pulseCounter[6]_i_2_n_0 ),
        .I4(reg_pulseCounter_reg[3]),
        .I5(reg_pulseCounter_reg[5]),
        .O(p_0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \reg_pulseCounter[6]_i_2 
       (.I0(reg_pulseCounter_reg[1]),
        .I1(reg_pulseCounter_reg[0]),
        .O(\reg_pulseCounter[6]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hB8CC)) 
    \reg_pulseCounter[7]_i_1 
       (.I0(\reg_pulseCounter[9]_i_4_n_0 ),
        .I1(reg_pulseCounter_reg[7]),
        .I2(\reg_pulseCounter[9]_i_5_n_0 ),
        .I3(reg_pulseCounter_reg[6]),
        .O(p_0_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hBC8CCCCC)) 
    \reg_pulseCounter[8]_i_1 
       (.I0(\reg_pulseCounter[9]_i_4_n_0 ),
        .I1(reg_pulseCounter_reg[8]),
        .I2(reg_pulseCounter_reg[6]),
        .I3(\reg_pulseCounter[9]_i_5_n_0 ),
        .I4(reg_pulseCounter_reg[7]),
        .O(p_0_in[8]));
  LUT6 #(
    .INIT(64'hFFFFFFFFAAAA8880)) 
    \reg_pulseCounter[9]_i_1 
       (.I0(reg_pulseCounter_reg[9]),
        .I1(reg_pulseCounter_reg[7]),
        .I2(\reg_pulseCounter[9]_i_3_n_0 ),
        .I3(reg_pulseCounter_reg[6]),
        .I4(reg_pulseCounter_reg[8]),
        .I5(i_reset_fromPin_IBUF),
        .O(\reg_pulseCounter[9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hBC8CCCCCCCCCCCCC)) 
    \reg_pulseCounter[9]_i_2 
       (.I0(\reg_pulseCounter[9]_i_4_n_0 ),
        .I1(reg_pulseCounter_reg[9]),
        .I2(reg_pulseCounter_reg[7]),
        .I3(\reg_pulseCounter[9]_i_5_n_0 ),
        .I4(reg_pulseCounter_reg[6]),
        .I5(reg_pulseCounter_reg[8]),
        .O(p_0_in[9]));
  LUT6 #(
    .INIT(64'hFFFFFFFFFEEEAAAA)) 
    \reg_pulseCounter[9]_i_3 
       (.I0(reg_pulseCounter_reg[4]),
        .I1(reg_pulseCounter_reg[2]),
        .I2(reg_pulseCounter_reg[1]),
        .I3(reg_pulseCounter_reg[0]),
        .I4(reg_pulseCounter_reg[3]),
        .I5(reg_pulseCounter_reg[5]),
        .O(\reg_pulseCounter[9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \reg_pulseCounter[9]_i_4 
       (.I0(reg_pulseCounter_reg[4]),
        .I1(reg_pulseCounter_reg[2]),
        .I2(reg_pulseCounter_reg[0]),
        .I3(reg_pulseCounter_reg[1]),
        .I4(reg_pulseCounter_reg[3]),
        .I5(reg_pulseCounter_reg[5]),
        .O(\reg_pulseCounter[9]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \reg_pulseCounter[9]_i_5 
       (.I0(reg_pulseCounter_reg[4]),
        .I1(reg_pulseCounter_reg[2]),
        .I2(reg_pulseCounter_reg[1]),
        .I3(reg_pulseCounter_reg[0]),
        .I4(reg_pulseCounter_reg[3]),
        .I5(reg_pulseCounter_reg[5]),
        .O(\reg_pulseCounter[9]_i_5_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[0] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[0]),
        .Q(reg_pulseCounter_reg[0]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[1] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[1]),
        .Q(reg_pulseCounter_reg[1]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[2] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[2]),
        .Q(reg_pulseCounter_reg[2]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[3] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[3]),
        .Q(reg_pulseCounter_reg[3]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[4] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[4]),
        .Q(reg_pulseCounter_reg[4]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[5] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[5]),
        .Q(reg_pulseCounter_reg[5]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[6] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[6]),
        .Q(reg_pulseCounter_reg[6]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[7] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[7]),
        .Q(reg_pulseCounter_reg[7]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[8] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[8]),
        .Q(reg_pulseCounter_reg[8]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \reg_pulseCounter_reg[9] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(p_0_in[9]),
        .Q(reg_pulseCounter_reg[9]),
        .R(\reg_pulseCounter[9]_i_1_n_0 ));
endmodule

module DebugUnit
   (o_tx_fromPin_OBUF,
    i_clock_fromPin_IBUF_BUFG,
    i_reset_fromPin_IBUF);
  output o_tx_fromPin_OBUF;
  input i_clock_fromPin_IBUF_BUFG;
  input i_reset_fromPin_IBUF;

  wire i_clock_fromPin_IBUF_BUFG;
  wire i_reset_fromPin_IBUF;
  wire o_tx_fromPin_OBUF;
  wire w_tickSource;

  BaudRateGenerator u_BaudRateGenerator
       (.i_clock_fromPin_IBUF_BUFG(i_clock_fromPin_IBUF_BUFG),
        .i_reset_fromPin_IBUF(i_reset_fromPin_IBUF),
        .w_tickSource(w_tickSource));
  TxUART u_TxUART
       (.i_clock_fromPin_IBUF_BUFG(i_clock_fromPin_IBUF_BUFG),
        .i_reset_fromPin_IBUF(i_reset_fromPin_IBUF),
        .o_tx_fromPin_OBUF(o_tx_fromPin_OBUF),
        .w_tickSource(w_tickSource));
endmodule

(* DATMEM_ADDR_LEN = "32" *) (* DAT_LEN = "32" *) (* EXMEM_REG_LEN = "97" *) 
(* IDEX_REG_LEN = "128" *) (* IFID_REG_LEN = "64" *) (* INSMEM_ADDR_LEN = "4" *) 
(* INSMEM_DAT_LEN = "8" *) (* INS_LEN = "32" *) (* MEMWB_REG_LEN = "64" *) 
(* REGFILE_ADDR_LEN = "5" *) (* REGFILE_LEN = "32" *) 
(* NotValidForBitStream *)
module TopLevel
   (i_clock_fromPin,
    i_reset_fromPin,
    i_rx_fromPin,
    o_tx_fromPin);
  input i_clock_fromPin;
  input i_reset_fromPin;
  input i_rx_fromPin;
  output o_tx_fromPin;

  wire i_clock_fromPin;
  wire i_clock_fromPin_IBUF;
  wire i_clock_fromPin_IBUF_BUFG;
  wire i_reset_fromPin;
  wire i_reset_fromPin_IBUF;
  wire o_tx_fromPin;
  wire o_tx_fromPin_OBUF;

initial begin
 $sdf_annotate("TopLevel_tb_time_synth.sdf",,,,"tool_control");
end
  BUFG i_clock_fromPin_IBUF_BUFG_inst
       (.I(i_clock_fromPin_IBUF),
        .O(i_clock_fromPin_IBUF_BUFG));
  IBUF #(
    .CCIO_EN("TRUE")) 
    i_clock_fromPin_IBUF_inst
       (.I(i_clock_fromPin),
        .O(i_clock_fromPin_IBUF));
  IBUF #(
    .CCIO_EN("TRUE")) 
    i_reset_fromPin_IBUF_inst
       (.I(i_reset_fromPin),
        .O(i_reset_fromPin_IBUF));
  OBUF o_tx_fromPin_OBUF_inst
       (.I(o_tx_fromPin_OBUF),
        .O(o_tx_fromPin));
  DebugUnit u_DebugUnit
       (.i_clock_fromPin_IBUF_BUFG(i_clock_fromPin_IBUF_BUFG),
        .i_reset_fromPin_IBUF(i_reset_fromPin_IBUF),
        .o_tx_fromPin_OBUF(o_tx_fromPin_OBUF));
endmodule

module TxUART
   (o_tx_fromPin_OBUF,
    i_clock_fromPin_IBUF_BUFG,
    i_reset_fromPin_IBUF,
    w_tickSource);
  output o_tx_fromPin_OBUF;
  input i_clock_fromPin_IBUF_BUFG;
  input i_reset_fromPin_IBUF;
  input w_tickSource;

  wire \FSM_sequential_reg_actualState[0]_i_1_n_0 ;
  wire \FSM_sequential_reg_actualState[0]_i_2_n_0 ;
  wire \FSM_sequential_reg_actualState[1]_i_1_n_0 ;
  wire \FSM_sequential_reg_actualState[1]_i_2_n_0 ;
  wire i_clock_fromPin_IBUF_BUFG;
  wire i_reset_fromPin_IBUF;
  wire o_tx_fromPin_OBUF;
  wire [1:0]reg_actualState;
  wire [2:0]reg_bitsTxCounter;
  wire \reg_bitsTxCounter[0]_i_1_n_0 ;
  wire \reg_bitsTxCounter[1]_i_1_n_0 ;
  wire \reg_bitsTxCounter[2]_i_1_n_0 ;
  wire \reg_bitsTxCounter[2]_i_2_n_0 ;
  wire [3:0]reg_ticksCounter;
  wire \reg_ticksCounter[0]_i_1_n_0 ;
  wire \reg_ticksCounter[1]_i_1_n_0 ;
  wire \reg_ticksCounter[2]_i_1_n_0 ;
  wire \reg_ticksCounter[3]_i_1_n_0 ;
  wire \reg_ticksCounter[3]_i_2_n_0 ;
  wire tx_reg_i_1_n_0;
  wire w_tickSource;

  LUT6 #(
    .INIT(64'h8A8A8A8A9A8A8A8A)) 
    \FSM_sequential_reg_actualState[0]_i_1 
       (.I0(reg_actualState[0]),
        .I1(\FSM_sequential_reg_actualState[1]_i_2_n_0 ),
        .I2(w_tickSource),
        .I3(reg_actualState[1]),
        .I4(reg_bitsTxCounter[2]),
        .I5(\FSM_sequential_reg_actualState[0]_i_2_n_0 ),
        .O(\FSM_sequential_reg_actualState[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \FSM_sequential_reg_actualState[0]_i_2 
       (.I0(reg_bitsTxCounter[0]),
        .I1(reg_bitsTxCounter[1]),
        .O(\FSM_sequential_reg_actualState[0]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'hDF20)) 
    \FSM_sequential_reg_actualState[1]_i_1 
       (.I0(reg_actualState[0]),
        .I1(\FSM_sequential_reg_actualState[1]_i_2_n_0 ),
        .I2(w_tickSource),
        .I3(reg_actualState[1]),
        .O(\FSM_sequential_reg_actualState[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h7FFF)) 
    \FSM_sequential_reg_actualState[1]_i_2 
       (.I0(reg_ticksCounter[2]),
        .I1(reg_ticksCounter[0]),
        .I2(reg_ticksCounter[1]),
        .I3(reg_ticksCounter[3]),
        .O(\FSM_sequential_reg_actualState[1]_i_2_n_0 ));
  (* FSM_ENCODED_STATES = "iSTATE:01,iSTATE0:10,iSTATE1:00,iSTATE2:11" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_sequential_reg_actualState_reg[0] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .CLR(i_reset_fromPin_IBUF),
        .D(\FSM_sequential_reg_actualState[0]_i_1_n_0 ),
        .Q(reg_actualState[0]));
  (* FSM_ENCODED_STATES = "iSTATE:01,iSTATE0:10,iSTATE1:00,iSTATE2:11" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_sequential_reg_actualState_reg[1] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .CLR(i_reset_fromPin_IBUF),
        .D(\FSM_sequential_reg_actualState[1]_i_1_n_0 ),
        .Q(reg_actualState[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h0FD0)) 
    \reg_bitsTxCounter[0]_i_1 
       (.I0(reg_actualState[0]),
        .I1(reg_actualState[1]),
        .I2(\reg_bitsTxCounter[2]_i_2_n_0 ),
        .I3(reg_bitsTxCounter[0]),
        .O(\reg_bitsTxCounter[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h0BFFB000)) 
    \reg_bitsTxCounter[1]_i_1 
       (.I0(reg_actualState[1]),
        .I1(reg_actualState[0]),
        .I2(reg_bitsTxCounter[0]),
        .I3(\reg_bitsTxCounter[2]_i_2_n_0 ),
        .I4(reg_bitsTxCounter[1]),
        .O(\reg_bitsTxCounter[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7707FFFF88080000)) 
    \reg_bitsTxCounter[2]_i_1 
       (.I0(reg_bitsTxCounter[0]),
        .I1(reg_bitsTxCounter[1]),
        .I2(reg_actualState[0]),
        .I3(reg_actualState[1]),
        .I4(\reg_bitsTxCounter[2]_i_2_n_0 ),
        .I5(reg_bitsTxCounter[2]),
        .O(\reg_bitsTxCounter[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000D000F000000)) 
    \reg_bitsTxCounter[2]_i_2 
       (.I0(reg_bitsTxCounter[2]),
        .I1(\FSM_sequential_reg_actualState[0]_i_2_n_0 ),
        .I2(\FSM_sequential_reg_actualState[1]_i_2_n_0 ),
        .I3(w_tickSource),
        .I4(reg_actualState[0]),
        .I5(reg_actualState[1]),
        .O(\reg_bitsTxCounter[2]_i_2_n_0 ));
  FDCE #(
    .INIT(1'b0)) 
    \reg_bitsTxCounter_reg[0] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_bitsTxCounter[0]_i_1_n_0 ),
        .Q(reg_bitsTxCounter[0]));
  FDCE #(
    .INIT(1'b0)) 
    \reg_bitsTxCounter_reg[1] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_bitsTxCounter[1]_i_1_n_0 ),
        .Q(reg_bitsTxCounter[1]));
  FDCE #(
    .INIT(1'b0)) 
    \reg_bitsTxCounter_reg[2] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_bitsTxCounter[2]_i_1_n_0 ),
        .Q(reg_bitsTxCounter[2]));
  LUT3 #(
    .INIT(8'h0E)) 
    \reg_ticksCounter[0]_i_1 
       (.I0(reg_actualState[1]),
        .I1(reg_actualState[0]),
        .I2(reg_ticksCounter[0]),
        .O(\reg_ticksCounter[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h0EE0)) 
    \reg_ticksCounter[1]_i_1 
       (.I0(reg_actualState[0]),
        .I1(reg_actualState[1]),
        .I2(reg_ticksCounter[0]),
        .I3(reg_ticksCounter[1]),
        .O(\reg_ticksCounter[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h0EEEE000)) 
    \reg_ticksCounter[2]_i_1 
       (.I0(reg_actualState[0]),
        .I1(reg_actualState[1]),
        .I2(reg_ticksCounter[1]),
        .I3(reg_ticksCounter[0]),
        .I4(reg_ticksCounter[2]),
        .O(\reg_ticksCounter[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBC00)) 
    \reg_ticksCounter[3]_i_1 
       (.I0(\FSM_sequential_reg_actualState[1]_i_2_n_0 ),
        .I1(reg_actualState[1]),
        .I2(reg_actualState[0]),
        .I3(w_tickSource),
        .O(\reg_ticksCounter[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7F7F7F0080808000)) 
    \reg_ticksCounter[3]_i_2 
       (.I0(reg_ticksCounter[1]),
        .I1(reg_ticksCounter[0]),
        .I2(reg_ticksCounter[2]),
        .I3(reg_actualState[1]),
        .I4(reg_actualState[0]),
        .I5(reg_ticksCounter[3]),
        .O(\reg_ticksCounter[3]_i_2_n_0 ));
  FDCE #(
    .INIT(1'b0)) 
    \reg_ticksCounter_reg[0] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(\reg_ticksCounter[3]_i_1_n_0 ),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_ticksCounter[0]_i_1_n_0 ),
        .Q(reg_ticksCounter[0]));
  FDCE #(
    .INIT(1'b0)) 
    \reg_ticksCounter_reg[1] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(\reg_ticksCounter[3]_i_1_n_0 ),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_ticksCounter[1]_i_1_n_0 ),
        .Q(reg_ticksCounter[1]));
  FDCE #(
    .INIT(1'b0)) 
    \reg_ticksCounter_reg[2] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(\reg_ticksCounter[3]_i_1_n_0 ),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_ticksCounter[2]_i_1_n_0 ),
        .Q(reg_ticksCounter[2]));
  FDCE #(
    .INIT(1'b0)) 
    \reg_ticksCounter_reg[3] 
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(\reg_ticksCounter[3]_i_1_n_0 ),
        .CLR(i_reset_fromPin_IBUF),
        .D(\reg_ticksCounter[3]_i_2_n_0 ),
        .Q(reg_ticksCounter[3]));
  LUT2 #(
    .INIT(4'h9)) 
    tx_reg_i_1
       (.I0(reg_actualState[1]),
        .I1(reg_actualState[0]),
        .O(tx_reg_i_1_n_0));
  FDPE #(
    .INIT(1'b1)) 
    tx_reg_reg
       (.C(i_clock_fromPin_IBUF_BUFG),
        .CE(1'b1),
        .D(tx_reg_i_1_n_0),
        .PRE(i_reset_fromPin_IBUF),
        .Q(o_tx_fromPin_OBUF));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
