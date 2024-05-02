//////////////////////////////////////////////////////////////////////////////////
// The Cooper Union
// ECE 251 Spring 2024
// Engineer: Prof Rob Marano
// 
//     Create Date: 2023-02-07
//     Module Name: datapath
//     Description: 32-bit RISC-based CPU datapath (MIPS)
//
// Revision: 1.0
//
//////////////////////////////////////////////////////////////////////////////////
`ifndef DATAPATH
`define DATAPATH

`timescale 1ns/100ps

`include "../regfile/regfile.sv"
`include "../alu/alu.sv"
`include "../dff/dff.sv"
`include "../adder/adder.sv"
`include "../sl2/sl2.sv"
`include "../mux2/mux2.sv"
`include "../signext/signext.sv"

module datapath
    #(parameter n = 16)(
    input  logic        clk, reset,
    input  logic        memtoreg, pcsrc,
    input  logic        alusrc, regdst,
    input  logic        regwrite, jump,
    input  logic [3:0]  alucontrol,
    output logic        zero,
    output logic [(15):0] pc,
    input  logic [(15):0] instr,
    output logic [(15):0] aluout, alurem, writedata,
    input  logic [(15):0] readdata
);
    logic [3:0]  writereg;
    logic [(15):0] pcnext, pcnextbr, pcplus2, pcbranch;
    logic [(15):0] signimm, signimmsh;
    logic [(15):0] srca, srcb;
    logic [(15):0] result;

    reg pcplus2_cout, pcplus1_cout, alu_rem;

    // Adjusted logic for 16 bit
    dff #(16)       pcreg(clk, reset, pcnext, pc);
    adder           pcadd1(pc, 16'b10, 1'b0, reset, pcplus2, pcplus1_cout); // Increment PC by 2 for 16-bit instructions
    sl2             immsh(signimm, signimmsh);
    adder           pcadd2(pcplus2, signimmsh, 1'b0, reset, pcbranch, pcplus2_cout);
    mux2 #(16)      pcbrmux(pcplus2, pcbranch, pcsrc, pcnextbr);
    mux2 #(16)      pcmux(pcnextbr, {pcplus2[13:12], instr[11:0], 2'b00}, jump, pcnext);
    //mux2 #(16)      pcmux(pcnextbr, {pcplus2[15:12], instr[11:0], 2'b00}, jump, pcnext);
    
    
    // Simplified register file logic
    regfile     rf(clk, regwrite, instr[(n/2)-1:(n/4)], instr[(n/4)-1:0], writereg, result, srca, writedata);
    mux2 #(4)   wrmux(instr[(n/4)-1:0], instr[(n/2)-1:(n/4)], regdst, writereg);
    mux2 #(16)   resmux(aluout, readdata, memtoreg, result);
    signext     se(instr[(n/2)-1:0], signimm);

    // Simplified ALU logic
    mux2 #(16)   srcbmux(writedata, signimm, alusrc, srcb);
    alu         alu(srca, srcb, alucontrol, aluout, zero, alurem);

endmodule

`endif // DATAPATH
