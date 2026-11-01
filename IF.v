`timescale 1ns/1ns
module IF_Stage (
    input clk, rst, freeze, Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC, Instruction
);
    wire [31:0] PC_Next;
    wire [31:0] PC_in;
    reg [31:0] PC_reg;

    assign PC_Next = PC_reg + 32'b1;
    assign PC_in = Branch_taken ? BranchAddr : PC_Next;

    always @(posedge clk or posedge rst ) begin
        if(rst) begin
            PC_reg <= 32'b0;
        end  
        else if (!freeze) begin
            PC_reg <= PC_in;
        end

    end

    assign PC = PC_reg;

    dist_mem_gen_1 inst_mem_inst (
        .a(PC[10:0]), .spo(Instruction)
    );

endmodule

module IF_Stage_Reg (
    input clk, rst, freeze, flush,
    input [31:0] PC_in , Instruction_in,
    output reg [31:0] PC, Instruction
);
    always @(posedge clk or posedge rst ) begin
        if(rst) begin
            PC <= 32'b0;
            Instruction <= 32'b0;
        end 
        else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
        end
    end
endmodule