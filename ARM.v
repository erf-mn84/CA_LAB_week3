`timescale 1ns/1ns
module ARM (
    input clk,
    input rst
);
    // ---------------- IF Wires ----------------
    wire [31:0] IF_PC, IF_Instruction;
    wire [31:0] IF_Reg_PC, IF_Reg_Instruction;
    
    // ---------------- ID Wires ----------------
    wire [31:0] ID_PC;
    wire ID_WB_EN, ID_MEM_R_EN, ID_MEM_W_EN;
    wire [3:0] ID_EXE_CMD;
    wire ID_B, ID_S;
    wire [31:0] ID_Val_Rn, ID_Val_Rm;
    wire ID_imm;
    wire [11:0] ID_Shift_operand;
    wire [23:0] ID_Signed_imm_24;
    wire [3:0] ID_Dest;
    wire [3:0] ID_src1, ID_src2;

    // ---------------- ID_Reg Wires (To EXE) ----------------
    wire [31:0] ID_Reg_PC;
    wire ID_Reg_WB_EN, ID_Reg_MEM_R_EN, ID_Reg_MEM_W_EN;
    wire [3:0] ID_Reg_EXE_CMD;
    wire ID_Reg_B, ID_Reg_S;
    wire [31:0] ID_Reg_Val_Rn, ID_Reg_Val_Rm;
    wire ID_Reg_imm;
    wire [11:0] ID_Reg_Shift_operand;
    wire [23:0] ID_Reg_Signed_imm_24;
    wire [3:0] ID_Reg_Dest;
    
    // ---------------- EXE Wires ----------------
    wire [31:0] EXE_PC;
    wire [31:0] EXE_Reg_PC;
    
    // ---------------- MEM Wires ----------------
    wire [31:0] MEM_PC;
    wire [31:0] MEM_Reg_PC;
    
    // ---------------- WB Wires ----------------
    wire [31:0] WB_PC;


    // ==========================================
    //                 IF STAGE
    // ==========================================
    IF_Stage IF_inst (
        .clk(clk) , .rst(rst), .freeze(1'b0), .Branch_taken(1'b0), .BranchAddr(32'b0), 
        .PC(IF_PC), .Instruction(IF_Instruction)
    );

    IF_Stage_Reg IF_Reg_inst (
        .clk(clk), .rst(rst), .freeze(1'b0), .flush(1'b0), 
        .PC_in(IF_PC), .Instruction_in(IF_Instruction),
        .PC(IF_Reg_PC), .Instruction(IF_Reg_Instruction)
    );

    // ==========================================
    //                 ID STAGE
    // ==========================================
    ID_Stage ID_inst(
        .clk(clk), 
        .rst(rst), 
        .Instruction(IF_Reg_Instruction), 
        .PC_in(IF_Reg_PC),
        // سیگنال‌هایی که هنوز پیاده‌سازی نشده‌اند به صفر متصل می‌شوند
        .SR(4'b0000),             
        .Dest_WB(4'b0000),        
        .Result_WB(32'b0),        
        .writeBackEN(1'b0),       
        .Hazard(1'b0),            

        .PC(ID_PC),
        .WB_EN(ID_WB_EN), 
        .MEM_R_EN(ID_MEM_R_EN), 
        .MEM_W_EN(ID_MEM_W_EN),
        .EXE_CMD(ID_EXE_CMD),
        .B(ID_B), 
        .S(ID_S),
        .Val_Rn(ID_Val_Rn), 
        .Val_Rm(ID_Val_Rm),
        .imm(ID_imm),
        .Shift_operand(ID_Shift_operand),
        .Signed_imm_24(ID_Signed_imm_24),
        .Dest(ID_Dest),
        .src1(ID_src1), 
        .src2(ID_src2)
    );
    
    ID_Stage_Reg ID_Reg_inst(
        .clk(clk), 
        .rst(rst), 
        .flush(1'b0), // فعلاً صفر تا منطق پرش کامل شود
        
        // ورودی‌ها از ID
        .PC_in(ID_PC),
        .WB_EN_in(ID_WB_EN), 
        .MEM_R_EN_in(ID_MEM_R_EN), 
        .MEM_W_EN_in(ID_MEM_W_EN),
        .EXE_CMD_in(ID_EXE_CMD),
        .B_in(ID_B), 
        .S_in(ID_S),
        .Val_Rn_in(ID_Val_Rn), 
        .Val_Rm_in(ID_Val_Rm),
        .imm_in(ID_imm),
        .Shift_operand_in(ID_Shift_operand),
        .Signed_imm_24_in(ID_Signed_imm_24),
        .Dest_in(ID_Dest),
        
        // خروجی‌ها به EXE
        .PC(ID_Reg_PC),
        .WB_EN(ID_Reg_WB_EN), 
        .MEM_R_EN(ID_Reg_MEM_R_EN), 
        .MEM_W_EN(ID_Reg_MEM_W_EN),
        .EXE_CMD(ID_Reg_EXE_CMD),
        .B(ID_Reg_B), 
        .S(ID_Reg_S),
        .Val_Rn(ID_Reg_Val_Rn), 
        .Val_Rm(ID_Reg_Val_Rm),
        .imm(ID_Reg_imm),
        .Shift_operand(ID_Reg_Shift_operand),
        .Signed_imm_24(ID_Reg_Signed_imm_24),
        .Dest(ID_Reg_Dest)
    );

    // ==========================================
    //                 EXE STAGE
    // ==========================================
    // (در مراحل بعدی، ورودی‌های EXE را به سیم‌های ID_Reg متصل خواهیم کرد)
    EXE_Stage EXE_inst (
        .clk(clk), .rst(rst), .PC_in(ID_Reg_PC), .PC(EXE_PC)
    );

    EXE_Stage_Reg EXE_Reg_inst (
        .clk(clk), .rst(rst), .PC_in(EXE_PC), .PC(EXE_Reg_PC)
    );

    // ==========================================
    //                 MEM STAGE
    // ==========================================
    MEM_Stage MEM_inst (
        .clk(clk), .rst(rst), .PC_in(EXE_Reg_PC), .PC(MEM_PC)
    );

    MEM_Stage_Reg MEM_Reg_inst (
        .clk(clk), .rst(rst), .PC_in(MEM_PC), .PC(MEM_Reg_PC)
    );

    // ==========================================
    //                 WB STAGE
    // ==========================================
    WB_Stage WB_inst (
        .clk(clk), .rst(rst), .PC_in(MEM_Reg_PC), .PC(WB_PC)
    );

endmodule