`timescale 1ns/1ns

module RegisterFile(
    input clk,
    input rst,
    input [3:0] src_1,
    input [3:0] src_2,
    input [3:0] Dest_WB,
    input [31:0] Result_WB,
    input writeBackEN,
    output [31:0] reg_out_1,
    output [31:0] reg_out_2
);

    reg [31:0] reg_file [0:14];
    
    integer i;

    
    assign reg_out_1 = reg_file[src_1];
    assign reg_out_2 = reg_file[src_2];

    
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            
            for (i = 0; i < 15; i = i + 1) begin
                reg_file[i] <= i;
            end
        end 
        else if (writeBackEN) begin
            
            if (Dest_WB < 15) begin
                reg_file[Dest_WB] <= Result_WB;
            end
        end
    end

endmodule