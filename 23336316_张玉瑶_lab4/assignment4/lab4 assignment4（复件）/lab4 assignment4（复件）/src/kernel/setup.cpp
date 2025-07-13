#include "asm_utils.h"
#include "interrupt.h"
#include "stdio.h"

// 屏幕IO处理器
STDIO stdio;
// 中断管理器
InterruptManager interruptManager;


// 在setup_kernel中设置
extern "C" void setup_kernel()
{
    interruptManager.initialize();
    stdio.initialize();
    
    // 设置时钟中断处理程序
    interruptManager.setTimeInterrupt((void *)asm_time_interrupt_handler);
    interruptManager.enableTimeInterrupt();
    
    asm_enable_interrupt();
    asm_halt();
}
