`timescale 1ns/1ns
module EXE_Stage(
    input clk, rst,
    input [31:0] PC_in,
    output [31:0] PC
);
    assign PC = PC_in;

endmodule

module EXE_Stage_Reg(
    input clk, rst,
    input [31:0] PC_in,
    output reg [31:0] PC
);
    always @(posedge clk or posedge rst) begin
        if(rst)PC <= 32'b0;
        else PC <= PC_in;
    end
endmodule