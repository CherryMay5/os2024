#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "defs.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    // uint64_t sstatus_val1 = csr_read(scause);
    // printk("scause: %lx\n", sstatus_val1);
    // 通过 `scause` 判断 trap 类型
    if((scause>>63)==1)
    {
        // 如果是 interrupt 判断是否是 timer interrupt
        if(((scause<<1)>>1)==5)
        {
            // 通过 `clock_set_next_event()` 设置下一次时钟中断
            clock_set_next_event();
            do_timer();
            // 如果是 timer interrupt 则打印输出相关信息
            // printk("%s\n","[S] Supervisor Mode Timer Interrupt");
        }else if(((scause<<1)>>1)==1)
        {
            printk("%s\n","[S] Supervisor Mode Software Interrupt");
        }else if(((scause<<1)>>1)==9)
        {
            printk("%s\n","[S] Supervisor Mode External Interrupt");
        }else if(((scause<<1)>>1)==13)
        {
            printk("%s\n","[S] Counter-overflow Interrupt");
        }
    }
    
    return;
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
}