#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "defs.h"
#include "syscall.h"
#include "string.h"

extern create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);
extern char _sramdisk[];

void do_page_fault(struct pt_regs *regs) {
    // 1.通过 stval 获得访问出错的虚拟内存地址（Bad Address）
    uint64_t stval = regs->stval; // 取指时的虚拟地址
    uint64_t scause = csr_read(scause);
    printk(GREEN"[trap.c,do_page_fault] [PID = %d PC = 0x%lx] valid page fault at `0x%lx` with cause %d\n"CLEAR,current->pid,regs->sepc,stval,scause);

    // 2.通过 find_vma() 查找 bad address 是否在某个 vma 中
    struct vm_area_struct *vma = find_vma(&current->mm, stval);
    
    if (!vma) { // 如果不在，则出现非预期错误，可以通过 Err 宏输出错误信息
        Err("[S] Page Fault: Bad Address 0x%lx\n", stval);
        return;
    } else { // 如果在，则根据 vma 的 flags 权限判断当前 page fault 是否合法
        if ((scause == 0xc && !(vma->vm_flags & VM_EXEC)) ||  // instruction
            (scause == 0xd && !(vma->vm_flags & VM_READ)) ||  // load
            (scause == 0xf && !(vma->vm_flags & VM_WRITE))) { // store
            Err("[S] Page Fault: Illegal page fault to Bad Address 0x%lx\n", stval);
            return;
        }
    }

    // 其他情况合法，按接下来的流程创建映射
    // 3.分配一个页，接下来要将这个页映射到对应的用户地址空间
    uint64_t page = alloc_page();

    // 4.初始化匿名页
    if (vma->vm_flags & VM_ANON) { // 如果是匿名空间，则清零并直接映射即可
        memset((void *)page, 0, PGSIZE);
    } else { // 如果不是匿名空间，则需要从 ELF 中读取数据，填充后映射到用户空间
        uint64_t seg_start = (uint64_t)_sramdisk + vma->vm_pgoff; // 段在物理内存中的起始地址
        uint64_t seg_end = seg_start + vma->vm_filesz;           // 段在物理内存中的结束地址
        uint64_t stval_start = seg_start + PGROUNDDOWN(stval) - vma->vm_start; // 错误发生页的起始地址

        uint64_t offset = 0; // 偏移 -- 确定从当前页的哪个位置开始填充
        if (PGROUNDDOWN(stval) == PGROUNDDOWN(seg_start)) { // 同页，从 stval 错误发生的地方开始复制
            offset = stval & (PGSIZE - 1);
        }

        uint64_t valid_seg = 0; // 计算有效段大小
        if (seg_end > stval_start && seg_end <= stval_start + PGSIZE) {
            valid_seg = seg_end - stval_start - offset;
        } else if (seg_end > stval_start + PGSIZE) {
            valid_seg = PGSIZE - offset;
        }

        if (valid_seg > 0) { // 进行数据拷贝
            memcpy((void *)(page + offset), (void *)stval_start, valid_seg);
        }
    }

    // 5.映射页面到用户地址空间
    uint64_t perm = (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) | (1 << 0) | (1 << 4); // 添加权限
    create_mapping(current->pgd, PGROUNDDOWN(stval), page - PA2VA_OFFSET, PGSIZE, perm);
}

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    // uint64_t scause = csr_read(scause);
    // printk("scause: %lx\n", scause);
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
                case SYS_CLONE:
                    regs->x[10]=do_fork(regs);
                default:
                    break;
            }

            // 手动完成 sepc + 4
            regs->sepc += 4;
        }else if(((scause<<1)>>1)==0||((scause<<1)>>1)==1||((scause<<1)>>1)==2)
        {
            Err("Instruction exception\n");
        }else if(((scause<<1)>>1)==3)
        {
            Err("Breakpoint\n");
        }else if(((scause<<1)>>1)==4||((scause<<1)>>1)==5)
        {
            Err("Load exception\n");
        }else if(((scause<<1)>>1)==6||((scause<<1)>>1)==7)
        {
            Err("Store/AMO exception\n");
        }else if(((scause<<1)>>1)==8||((scause<<1)>>1)==9)
        {
            printk("Environment call exception\n");
        }else if(((scause<<1)>>1)==12)
        {
            printk(RED"Instruction page fault\n"CLEAR);
            do_page_fault(regs);
        }else if(((scause<<1)>>1)==13)
        {
            printk(RED"Load page fault\n"CLEAR);
            do_page_fault(regs);
        }else if(((scause<<1)>>1)==15)
        {
            printk(RED"Store/AMO page fault\n"CLEAR);
            do_page_fault(regs);
        }else if(((scause<<1)>>1)==18)
        {
            Err("Software check\n");
        }else if(((scause<<1)>>1)==19)
        {
            Err("Hardware error\n");
        }else
        {
            Err("Reserved\n");
        }
    }
    return;
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
}