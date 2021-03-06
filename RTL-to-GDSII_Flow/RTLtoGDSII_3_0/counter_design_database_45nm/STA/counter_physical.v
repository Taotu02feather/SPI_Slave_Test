/*
###############################################################
#  Generated by:      Cadence Encounter 14.10-p003_1
#  OS:                Linux x86_64(Host ID lnx-gauravks)
#  Generated on:      Mon Sep  8 20:46:04 2014
#  Design:            counter
#  Command:           saveNetlist counter_physical.v
###############################################################
*/
// Generated by Cadence Encounter(R) RTL Compiler RC13.10 - v13.10-p005_1
// Verification Directory fv/counter 
module counter (
	clk, 
	rst, 
	count, 
	SE, 
	scan_in, 
	scan_out);
   input clk;
   input rst;
   output [7:0] count;
   input SE;
   input scan_in;
   output scan_out;

   // Internal wires
   wire clk__L2_N0;
   wire clk__L1_N0;
   wire n_0;
   wire n_1;
   wire n_2;
   wire n_3;
   wire n_4;
   wire n_5;
   wire n_6;
   wire n_7;
   wire n_20;
   wire n_21;
   wire n_22;
   wire n_23;
   wire n_24;
   wire n_25;

   assign scan_out = count[7] ;

   CLKINVX2 clk__L2_I0 (.Y(clk__L2_N0),
	.A(clk__L1_N0));
   CLKINVX2 clk__L1_I0 (.Y(clk__L1_N0),
	.A(clk));
   SDFFRHQX1 \count_reg[0]  (.SI(scan_in),
	.SE(SE),
	.RN(rst),
	.Q(count[0]),
	.D(n_6),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[1]  (.SI(count[0]),
	.SE(SE),
	.RN(rst),
	.Q(count[1]),
	.D(n_7),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[2]  (.SI(count[1]),
	.SE(SE),
	.RN(rst),
	.Q(count[2]),
	.D(n_25),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[3]  (.SI(count[2]),
	.SE(SE),
	.RN(rst),
	.Q(count[3]),
	.D(n_24),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[4]  (.SI(count[3]),
	.SE(SE),
	.RN(rst),
	.Q(count[4]),
	.D(n_23),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[5]  (.SI(count[4]),
	.SE(SE),
	.RN(rst),
	.Q(count[5]),
	.D(n_22),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[6]  (.SI(count[5]),
	.SE(SE),
	.RN(rst),
	.Q(count[6]),
	.D(n_21),
	.CK(clk__L2_N0));
   SDFFRHQX1 \count_reg[7]  (.SI(count[6]),
	.SE(SE),
	.RN(rst),
	.Q(count[7]),
	.D(n_20),
	.CK(clk__L2_N0));
   INVX1 g769 (.Y(n_6),
	.A(count[0]));
   XNOR2X1 g839 (.Y(n_20),
	.B(n_5),
	.A(count[7]));
   XNOR2X1 g840 (.Y(n_21),
	.B(n_4),
	.A(count[6]));
   NAND2BX1 g841 (.Y(n_5),
	.B(count[6]),
	.AN(n_4));
   XNOR2X1 g842 (.Y(n_22),
	.B(n_3),
	.A(count[5]));
   NAND2BX1 g843 (.Y(n_4),
	.B(count[5]),
	.AN(n_3));
   XNOR2X1 g844 (.Y(n_23),
	.B(n_2),
	.A(count[4]));
   NAND2BX1 g845 (.Y(n_3),
	.B(count[4]),
	.AN(n_2));
   XNOR2X1 g846 (.Y(n_24),
	.B(n_1),
	.A(count[3]));
   NAND2BX1 g847 (.Y(n_2),
	.B(count[3]),
	.AN(n_1));
   XNOR2X1 g848 (.Y(n_25),
	.B(n_0),
	.A(count[2]));
   NAND2BX1 g849 (.Y(n_1),
	.B(count[2]),
	.AN(n_0));
   XOR2XL g850 (.Y(n_7),
	.B(count[1]),
	.A(count[0]));
   NAND2X1 g851 (.Y(n_0),
	.B(count[0]),
	.A(count[1]));
endmodule

