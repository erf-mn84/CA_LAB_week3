`timescale 1ns/1ns

module ID_Stage(
    input clk, rst,
    input [31:0] Instruction,
    input [31:0] PC_in,
    input [3:0] SR,             // وضعیت فلگ‌ها {N, Z, C, V}
    input [3:0] Dest_WB,        // آدرس نوشتن در رجیستر از مرحله WB
    input [31:0] Result_WB,     // دیتای نوشتن در رجیستر از مرحله WB
    input writeBackEN,          // سیگنال فعال‌ساز نوشتن از مرحله WB
    input Hazard,               // سیگنال تشخیص خطر (فعلاً در Top-Level صفر وصل می‌شود)

    output [31:0] PC,
    output WB_EN, MEM_R_EN, MEM_W_EN,
    output [3:0] EXE_CMD,
    output B, S,
    output [31:0] Val_Rn, Val_Rm,
    output imm,
    output [11:0] Shift_operand,
    output [23:0] Signed_imm_24,
    output [3:0] Dest,
    output [3:0] src1, src2     // خروجی برای استفاده در ILA و واحد Hazard
);

    // ۱. استخراج فیلدهای مختلف از دستورالعمل ۳۲ بیتی
    wire [3:0] Cond = Instruction[31:28];
    wire [1:0] Mode = Instruction[27:26];
    wire [3:0] Opcode = Instruction[24:21];
    wire S_bit_inst = Instruction[20];
    wire [3:0] Rn = Instruction[19:16];
    wire [3:0] Rd = Instruction[15:12];
    wire [3:0] Rm = Instruction[3:0];
    
    // انتقال مستقیم برخی سیگنال‌ها به خروجی
    assign PC = PC_in;
    assign imm = Instruction[25];
    assign Shift_operand = Instruction[11:0];
    assign Signed_imm_24 = Instruction[23:0];
    assign Dest = Rd;
    assign src1 = Rn;

    // ۲. تولید سیگنال‌های خام (Unconditional) توسط Control Unit
    wire [3:0] uncond_EXE_CMD;
    wire uncond_MEM_R_EN, uncond_MEM_W_EN, uncond_WB_EN, uncond_B, uncond_S;

    Control_Unit CU_inst (
        .mode(Mode),
        .Opcode(Opcode),
        .S(S_bit_inst),
        .EXE_CMD(uncond_EXE_CMD),
        .uncond_MEM_R_EN(uncond_MEM_R_EN),
        .uncond_MEM_W_EN(uncond_MEM_W_EN),
        .uncond_WB_EN(uncond_WB_EN),
        .B(uncond_B),
        .S_out(uncond_S)
    );

    // ۳. مالتی‌پلکسر آدرس دوم (src2)
    // اگر دستور STR باشد (نوشتن در حافظه)، مقدار فیلد Rd به پورت src2 متصل می‌شود. در غیر این صورت فیلد Rm متصل می‌شود.
    assign src2 = (uncond_MEM_W_EN) ? Rd : Rm;

    // ۴. رجیستر فایل
    RegisterFile RF_inst (
        .clk(clk),
        .rst(rst),
        .src_1(src1),
        .src_2(src2),
        .Dest_WB(Dest_WB),
        .Result_WB(Result_WB),
        .writeBackEN(writeBackEN),
        .reg_out_1(Val_Rn),
        .reg_out_2(Val_Rm)
    );

    // ۵. بررسی شرط (Condition Check)
    wire Cond_is_true;
    Condition_Check CondCheck_inst (
        .Cond(Cond),
        .SR(SR),
        .Cond_is_true(Cond_is_true)
    );

    // ۶. مالتی‌پلکسر نهایی سیگنال‌های کنترلی (Condition & Hazard Mux)
    // اگر شرط برقرار نباشد یا خطری (Hazard) رخ داده باشد، تمام سیگنال‌های کنترلی باید صفر شوند.
    wire control_mux_sel = (~Cond_is_true) | Hazard;

    assign WB_EN    = control_mux_sel ? 1'b0 : uncond_WB_EN;
    assign MEM_R_EN = control_mux_sel ? 1'b0 : uncond_MEM_R_EN;
    assign MEM_W_EN = control_mux_sel ? 1'b0 : uncond_MEM_W_EN;
    assign EXE_CMD  = control_mux_sel ? 4'b0 : uncond_EXE_CMD;
    assign B        = control_mux_sel ? 1'b0 : uncond_B;
    assign S        = control_mux_sel ? 1'b0 : uncond_S;

endmodule

`timescale 1ns/1ns

module ID_Stage_Reg(
    input clk, rst, flush, // پورت flush برای پاک کردن رجیستر هنگام پرش (Branch)
    
    // ورودی‌ها از ماژول ID_Stage
    input [31:0] PC_in,
    input WB_EN_in, MEM_R_EN_in, MEM_W_EN_in,
    input [3:0] EXE_CMD_in,
    input B_in, S_in,
    input [31:0] Val_Rn_in, Val_Rm_in,
    input imm_in,
    input [11:0] Shift_operand_in,
    input [23:0] Signed_imm_24_in,
    input [3:0] Dest_in,
    
    // خروجی‌ها برای رفتن به EXE_Stage
    output reg [31:0] PC,
    output reg WB_EN, MEM_R_EN, MEM_W_EN,
    output reg [3:0] EXE_CMD,
    output reg B, S,
    output reg [31:0] Val_Rn, Val_Rm,
    output reg imm,
    output reg [11:0] Shift_operand,
    output reg [23:0] Signed_imm_24,
    output reg [3:0] Dest
);

    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            // صفر کردن تمام مقادیر هنگام ریست یا فلش شدن پایپ‌لاین
            PC <= 32'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            EXE_CMD <= 4'b0;
            B <= 1'b0;
            S <= 1'b0;
            Val_Rn <= 32'b0;
            Val_Rm <= 32'b0;
            imm <= 1'b0;
            Shift_operand <= 12'b0;
            Signed_imm_24 <= 24'b0;
            Dest <= 4'b0;
        end 
        else begin
            // انتقال داده‌ها در لبه بالارونده کلاک
            PC <= PC_in;
            WB_EN <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            EXE_CMD <= EXE_CMD_in;
            B <= B_in;
            S <= S_in;
            Val_Rn <= Val_Rn_in;
            Val_Rm <= Val_Rm_in;
            imm <= imm_in;
            Shift_operand <= Shift_operand_in;
            Signed_imm_24 <= Signed_imm_24_in;
            Dest <= Dest_in;
        end
    end
    
endmodule