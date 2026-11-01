`timescale 1ns/1ns

module Condition_Check(
    input [3:0] Cond,
    input [3:0] SR, 
    output reg Cond_is_true
);

    wire N = SR[3];
    wire Z = SR[2];
    wire C = SR[1];
    wire V = SR[0];

    always @(*) begin
        Cond_is_true = 1'b0;

        case (Cond)
            4'b0000: Cond_is_true = Z;                      // EQ: Z set
            4'b0001: Cond_is_true = ~Z;                     // NE: Z clear
            4'b0010: Cond_is_true = C;                      // CS/HS: C set
            4'b0011: Cond_is_true = ~C;                     // CC/LO: C clear
            4'b0100: Cond_is_true = N;                      // MI: N set
            4'b0101: Cond_is_true = ~N;                     // PL: N clear
            4'b0110: Cond_is_true = V;                      // VS: V set
            4'b0111: Cond_is_true = ~V;                     // VC: V clear
            4'b1000: Cond_is_true = (C && ~Z);              // HI: C set and Z clear
            4'b1001: Cond_is_true = (~C || Z);              // LS: C clear or Z set
            4'b1010: Cond_is_true = (N == V);               // GE: N == V
            4'b1011: Cond_is_true = (N != V);               // LT: N != V
            4'b1100: Cond_is_true = (~Z && (N == V));       // GT: Z == 0, N == V
            4'b1101: Cond_is_true = (Z || (N != V));        // LE: Z == 1 or N != V
            4'b1110: Cond_is_true = 1'b1;                   // AL: Always (unconditional)
            default: Cond_is_true = 1'b1;                   // حالت 1111 یا سایر موارد پیش‌فرض
        endcase
    end

endmodule