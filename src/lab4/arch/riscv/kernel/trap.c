#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "defs.h"
#include "syscall.h"


void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    // uint64_t sstatus_val1 = csr_read(scause);
    // printk("scause: %lx\n", sstatus_val1);
    // 通过 `scause` 判断 trap 类型
    
    if((scause>>63)==1) // interrupt=1
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
    }else if((scause>>63)==0)  //interrupt=0
    {
        // printk("In exception\n");
        if(((scause<<1)>>1)==8) 
        {
            // printk("x[17]: %d\n",regs->x[17]);
            // printk("%s\n","[S] Environmental call from U-mode");
            switch (regs->x[17])    // a7
            {
                case SYS_WRITE:
                    sys_write(regs->x[10],(const char*)regs->x[11],(size_t)regs->x[12],regs); // a0,a1,a2
                    break;
                case SYS_GETPID:
                    sys_getpid(regs);
                    break;
                default:
                    break;
            }

            // 手动完成 sepc + 4
            regs->sepc += 4;
        }
        // else if(((scause<<1)>>1)==0||((scause<<1)>>1)==1||((scause<<1)>>1)==2)
        // {
        //     printk("Instruction exception\n");
        // }else if(((scause<<1)>>1)==3)
        // {
        //     printk("Breakpoint\n");
        // }else if(((scause<<1)>>1)==4||((scause<<1)>>1)==5)
        // {
        //     printk("Load exception\n");
        // }else if(((scause<<1)>>1)==6||((scause<<1)>>1)==7)
        // {
        //     printk("Store/AMO exception\n");
        // }else if(((scause<<1)>>1)==8||((scause<<1)>>1)==9)
        // {
        //     printk("Environment call exception\n");
        // }else if(((scause<<1)>>1)==12||((scause<<1)>>1)==13||((scause<<1)>>1)==15)
        // {
        //     // uint64_t scause = csr_read(scause);
        //     // uint64_t stval = csr_read(stval); // 取指时的虚拟地址
        //     // printk("SCAUSE: 0x%lx, STVAL: 0x%lx\n", scause, stval);
        //     // uint64_t sepc = csr_read(sepc);
        //     // printk("SEPC: 0x%lx\n", sepc);
        //     printk("Page fault\n");
        // }else if(((scause<<1)>>1)==18)
        // {
        //     printk("Software check\n");
        // }else if(((scause<<1)>>1)==19)
        // {
        //     printk("Hardware error\n");
        // }else
        // {
        //     printk("Reserved\n");
        // }
    }
    return;
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
}