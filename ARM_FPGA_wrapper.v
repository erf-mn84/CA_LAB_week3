module ARM_FPGA_wrapper(input clk, input key1);
    wire deb_out ,rst;
    
    debouncer deb_inst(
        .SIGNAL_I(key1),
        .CLK_I(clk),
        .SIGNAL_O(deb_out)
    );
    
    assign rst = ~deb_out;
    
    ARM ARM_inst(
        .clk(clk),
        .rst(rst)
    );

    ila_0 ila_inst(
        .clk(clk),
        .probe0(rst),
        
        // --- پروب‌های جدید اضافه شده برای مرحله ID ---
        .probe1(ARM_inst.ID_WB_EN),       // 1 bit
        .probe2(ARM_inst.ID_MEM_R_EN),    // 1 bit
        .probe3(ARM_inst.ID_MEM_W_EN),    // 1 bit
        .probe4(ARM_inst.ID_EXE_CMD),    // 4 bits
        .probe5(ARM_inst.ID_Val_Rn),     // 32 bits
        .probe6(ARM_inst.ID_Val_Rm)      // 32 bits
        .probe7(ARM_inst.ID_B),          // 1 bit
        .probe8(ARM_inst.ID_S),          // 1 bit
        .probe9(ARM_inst.ID_PC),          // 32 bits
        .probe10(ARM_inst.ID_imm),          // 1 bit
        .probe11(ARM_inst.ID_Shift_operand),          // 12 bit
        .probe12(ARM_inst.ID_Signed_imm_24),          // 24 bit
        .probe13(ARM_inst.ID_Dest),          // 4 bit
        .probe14(ARM_inst.ID_src1),          // 4 bit
        .probe15(ARM_inst.ID_src2)          // 4 bit
        

        
    );

endmodule