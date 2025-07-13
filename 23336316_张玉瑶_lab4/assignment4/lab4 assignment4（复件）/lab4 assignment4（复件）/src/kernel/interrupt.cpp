#include "interrupt.h"
#include "os_type.h"
#include "os_constant.h"
#include "asm_utils.h"
#include "stdio.h"
#include <cstdint>  // 添加这行

extern STDIO stdio;
uint32_t seconds = 0;  // 移除static
uint32_t ticks = 0;    // 改为全局变量
int times = 0;
bool id_shown=false;

struct Jump {
    int x = 0;       
    int y = 0;       
    int dir = 0;      // 0=右,1=下,2=左,3=上
    int charIdx = 0;
    int colorIdx = 0;
    
    const char* chars = "0123456789";
    const uint8_t colors[9] = {0x87,0x34,0x56,0x78,0x9a,0xab,0xec,0x3e,0x4d};
};


InterruptManager::InterruptManager()
{
    initialize();
}

void InterruptManager::initialize()
{
    // 初始化中断计数变量
    times = 0;
    
    // 初始化IDT
    IDT = (uint32 *)IDT_START_ADDRESS;
    asm_lidt(IDT_START_ADDRESS, 256 * 8 - 1);

    for (uint i = 0; i < 256; ++i)
    {
        setInterruptDescriptor(i, (uint32)asm_unhandled_interrupt, 0);
    }

    // 初始化8259A芯片
    initialize8259A();
}

void InterruptManager::setInterruptDescriptor(uint32 index, uint32 address, byte DPL)
{
    IDT[index * 2] = (CODE_SELECTOR << 16) | (address & 0xffff);
    IDT[index * 2 + 1] = (address & 0xffff0000) | (0x1 << 15) | (DPL << 13) | (0xe << 8);
}

void InterruptManager::initialize8259A()
{
    // ICW 1
    asm_out_port(0x20, 0x11);
    asm_out_port(0xa0, 0x11);
    // ICW 2
    IRQ0_8259A_MASTER = 0x20;
    IRQ0_8259A_SLAVE = 0x28;
    asm_out_port(0x21, IRQ0_8259A_MASTER);
    asm_out_port(0xa1, IRQ0_8259A_SLAVE);
    // ICW 3
    asm_out_port(0x21, 4);
    asm_out_port(0xa1, 2);
    // ICW 4
    asm_out_port(0x21, 1);
    asm_out_port(0xa1, 1);

    // OCW 1 屏蔽主片所有中断，但主片的IRQ2需要开启
    asm_out_port(0x21, 0xfb);
    // OCW 1 屏蔽从片所有中断
    asm_out_port(0xa1, 0xff);
}

void InterruptManager::enableTimeInterrupt()
{
    uint8 value;
    // 读入主片OCW
    asm_in_port(0x21, &value);
    // 开启主片时钟中断，置0开启
    value = value & 0xfe;
    asm_out_port(0x21, value);
}

void InterruptManager::disableTimeInterrupt()
{
    uint8 value;
    asm_in_port(0x21, &value);
    // 关闭时钟中断，置1关闭
    value = value | 0x01;
    asm_out_port(0x21, value);
}

void InterruptManager::setTimeInterrupt(void *handler)
{
    setInterruptDescriptor(IRQ0_8259A_MASTER, (uint32)handler, 0);
}


extern "C" void c_time_interrupt_handler()
{
    static Jump jump;
    ++ticks;
    
   
    if(ticks % 18 == 0) {
        ++seconds;
        
        
        char timeStr[9] = "00:00";
        uint32_t minutes = seconds / 60;
        uint32_t secs = seconds % 60;
        
        // 分钟十位和个位
        timeStr[0] = '0' + minutes / 10;
        timeStr[1] = '0' + minutes % 10;
        
        // 秒数十位和个位
        timeStr[3] = '0' + secs / 10;
        timeStr[4] = '0' + secs % 10;
        

        stdio.moveCursor(13,35);  
        
        // 打印完整时间字符串
        for(int i = 0; i < 5; ++i) {
            stdio.print(timeStr[i]);
        }
        
        
        if(!id_shown){
            const int center_row = 12;
            const int center_col = (80 - 8)/2; 
            

            stdio.moveCursor(center_row, center_col);
            const char* student_id = "23336316";
            for(int i = 0; i < 8; ++i) {
                stdio.print(student_id[i]);  
            }
            
           id_shown = true;
        }    
    }   
    

    
        if(id_shown){
            stdio.moveCursor(0, 0);
        }
        // 更新位置
        switch(jump.dir) {
            case 0: 
                if(++jump.x >= 24) { 
                    jump.x=23; 
                    jump.dir=1; 
                  } break;
            case 1: 
                if(++jump.y >= 79) { 
                    jump.y=78; 
                    jump.dir=2; 
                   } break;
            case 2: 
                if(--jump.x < 0) {
                    jump.x=0; 
                    jump.dir=3; 
                  } break;
            case 3: 
                if(--jump.y < 0) { 
                    jump.y=0; 
                    jump.dir=0; 
                  } break;
        }
        
        // 更新字符和颜色
        jump.charIdx = (jump.charIdx + 1) % 10;
        jump.colorIdx = (jump.colorIdx + 1) % 11;
        

        stdio.print(jump.x, jump.y, 
                   jump.chars[jump.charIdx],
                   jump.colors[jump.colorIdx]);
    
    
    asm_out_port(0x20, 0x20); // EOI
}
    
