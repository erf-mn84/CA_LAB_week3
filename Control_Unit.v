`timescale 1ns/1ns

module Control_Unit(
    input [1:0] mode,
    input [3:0] Opcode,
    input S,
    output reg [3:0] EXE_CMD,
    output reg uncond_MEM_R_EN,
    output reg uncond_MEM_W_EN,
    output reg uncond_WB_EN,
    output reg B,
    output reg S_out
);

    always @(*) begin
        
        EXE_CMD = 4'b0000;
        uncond_MEM_R_EN = 1'b0;
        uncond_MEM_W_EN = 1'b0;
        uncond_WB_EN = 1'b0;
        B = 1'b0;
        S_out = 1'b0;

        case (mode)
            2'b00: begin 
                S_out = S; 
                
                
                case (Opcode)
                    4'b1101: begin EXE_CMD = 4'b0001; uncond_WB_EN = 1'b1; end // MOV
                    4'b1111: begin EXE_CMD = 4'b1001; uncond_WB_EN = 1'b1; end // MVN
                    4'b0100: begin EXE_CMD = 4'b0010; uncond_WB_EN = 1'b1; end // ADD
                    4'b0101: begin EXE_CMD = 4'b0011; uncond_WB_EN = 1'b1; end // ADC
                    4'b0010: begin EXE_CMD = 4'b0100; uncond_WB_EN = 1'b1; end // SUB
                    4'b0110: begin EXE_CMD = 4'b0101; uncond_WB_EN = 1'b1; end // SBC
                    4'b0000: begin EXE_CMD = 4'b0110; uncond_WB_EN = 1'b1; end // AND
                    4'b1100: begin EXE_CMD = 4'b0111; uncond_WB_EN = 1'b1; end // ORR
                    4'b0001: begin EXE_CMD = 4'b1000; uncond_WB_EN = 1'b1; end // EOR
                    
                    
                    4'b1010: begin EXE_CMD = 4'b0100; uncond_WB_EN = 1'b0; end // CMP
                    4'b1000: begin EXE_CMD = 4'b0110; uncond_WB_EN = 1'b0; end // TST
                    
                    default: begin EXE_CMD = 4'b0000; uncond_WB_EN = 1'b0; end
                endcase
            end
            
            2'b01: begin 
                
                EXE_CMD = 4'b0010; 
                
                if (S == 1'b1) begin 
                    uncond_MEM_R_EN = 1'b1;
                    uncond_WB_EN = 1'b1;
                end 
                else begin
                    uncond_MEM_W_EN = 1'b1;
                end
            end
            
            2'b10: begin
                B = 1'b1;
                
                EXE_CMD = 4'b0000; 
            end
            
            default: begin
                
            end
        endcase
    end

endmodule