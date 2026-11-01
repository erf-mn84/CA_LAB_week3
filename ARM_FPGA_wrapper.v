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
        .probe1(ARM_inst.IF_PC),
        .probe2(ARM_inst.ID_PC),
        .probe3(ARM_inst.EXE_PC),
        .probe4(ARM_inst.MEM_PC),
        .probe5(ARM_inst.WB_PC),
        .probe6(ARM_inst.IF_Instruction),
        
        // --- پروب‌های جدید اضافه شده برای مرحله ID ---
        .probe7(ARM_inst.ID_WB_EN),       // 1 bit
        .probe8(ARM_inst.ID_MEM_R_EN),    // 1 bit
        .probe9(ARM_inst.ID_MEM_W_EN),    // 1 bit
        .probe10(ARM_inst.ID_EXE_CMD),    // 4 bits
        .probe11(ARM_inst.ID_Val_Rn),     // 32 bits
        .probe12(ARM_inst.ID_Val_Rm)      // 32 bits
    );

endmodule