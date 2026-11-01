`timescale 1ns/1ns

module tb();

    reg clk=0,rst=0;
    ARM arm(.clk(clk),.rst(rst));
    always begin
        #10 clk = ~clk;
    end
    initial begin
        #40 rst = 1;
        #40 rst =0;
    end


endmodule