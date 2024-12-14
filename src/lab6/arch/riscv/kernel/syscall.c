#include "syscall.h"
#include "defs.h"

// 将用户态传递的字符串打印到屏幕上
// fd 为标准输出即 1，buf 为用户需要打印的起始地址，count 为字符串长度，返回打印的字符数；
void sys_write(unsigned int fd, const char* buf, size_t count, struct pt_regs *regs)  
{
    if(fd == 1)
    {
        uint64_t result;
        for(size_t i=0;i<count;i++)
        {
            printk("%c", buf[i]);
            result++;
        }
        regs->x[10] = result;
    }
}

// 从 current 中获取当前的 pid 放入 a0 中返回，无参数
void sys_getpid(struct pt_regs *regs)   
{
    regs->x[10] = current->pid;
}

extern struct task_struct *current;        // 指向当前运行线程的 task_struct
extern struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
extern int nr_tasks;
extern uint64_t swapper_pg_dir[];
extern uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags);
extern void __ret_from_fork();

#define PTE_V  (1 << 0)  // Valid
// 判断虚拟地址 addr 对应的 PTE 是否有效
uint64_t isValid_pte(uint64_t *pgd, uint64_t va) {
    uint64_t VPN[3];
    VPN[2] = (va >> 30) & 0x1ff; // 9 bit
    VPN[1] = (va >> 21) & 0x1ff;
    VPN[0] = (va >> 12) & 0x1ff;

    for (int level = 2; level > 0; level--) 
    {
        if ((pgd[VPN[level]] & 0x1) == 0) 
        {
            return 0;
        }else 
        {
            pgd = (uint64_t *)((pgd[VPN[level]] >> 10 << 12) + PA2VA_OFFSET);
        }
    }
    if ((pgd[VPN[0]] & 0x1) == 0) {
        return 0;
    }
    return 1;
}

// handle fork
uint64_t do_fork(struct pt_regs *regs) {
    // 1.创建一个新进程
    // 1.1.拷贝内核栈（包括了task_struct等信息）
    struct task_struct *_task = (struct task_struct *)kalloc();
    if(!_task) {   
        // 如果内存分配失败，则退出
        printk("do_fork : Failed to allocate memory for child's page directory\n");
        return -1;
    }
        // 深拷贝task_struct的页
    memcpy((void *)_task, (void *)current, PGSIZE);
    // printk("copy task_struct\n");
        // 除此之外还要略微修改 task_struct 内容
    _task->state=TASK_RUNNING;
    _task->counter=0;
    _task->priority=rand()%(PRIORITY_MAX - PRIORITY_MIN + 1)+PRIORITY_MIN;
    _task->pid = nr_tasks;    // pid 根据 nr_tasks 来赋值
    
    // 设置新进程的 thread.sp/sscratch/ra
    _task->thread.ra = (uint64_t)__ret_from_fork;
    _task->thread.sp = (uint64_t)_task+PGSIZE-sizeof(struct pt_regs); // 栈顶
    _task->thread.sscratch = csr_read(sscratch);
    _task->thread.sepc= regs->sepc; // 父进程的 sepc  added

    _task->mm.mmap = NULL;      // mm.mmap 为 NULL，因为新进程还没有任何映射

    // 1.2.创建一个新的页表
    _task->pgd = (uint64_t *)alloc_page();  // pgd 为新分配的页表地址
    if(!_task->pgd) {
        // 如果内存分配失败，则退出
        printk("do_fork : Failed to allocate memory for child's pgd\n");
        return -1;
    }
    // 拷贝内核页表 swapper_pg_dir
    memcpy((void *)_task->pgd, (void *)swapper_pg_dir, PGSIZE);
    // printk("copy swapper\n");

    // 遍历父进程 vma，并遍历父进程页表
    struct vm_area_struct *parent_vma = current->mm.mmap;
    while(parent_vma)
    {
        // 将这个 vma 也添加到新进程的 vma 链表中
        do_mmap(&_task->mm,
                parent_vma->vm_start,
                parent_vma->vm_end-parent_vma->vm_start,
                parent_vma->vm_pgoff,
                parent_vma->vm_filesz,
                parent_vma->vm_flags);

        // 遍历页表    
        for(uint64_t addr=parent_vma->vm_start; addr < parent_vma->vm_end; addr+=PGSIZE)
        {
            uint64_t pa=isValid_pte(current->pgd,addr);
            // 如果找不到（PTE V 为 0）则不需要拷贝
            if(!pa) continue;
            // 如果该 vma 项有对应的页表项存在（说明已经创建了映射），则需要深拷贝一整页的内容并映射到新页表中,内核态拷贝内容也需要使用虚拟地址
            uint64_t child_va = (uint64_t )alloc_page();
            if(!child_va) {
                printk("do_fork : Failed to allocate memory for child's page\n");
                return -1;
            }
            memcpy((void *)(child_va),PGROUNDDOWN(addr),PGSIZE);
            // mapping
            uint64_t perm=(parent_vma->vm_flags)|(1<<0)|(1<<4);
            create_mapping(_task->pgd,PGROUNDDOWN(addr),PGROUNDDOWN(child_va)-PA2VA_OFFSET,PGSIZE,perm);
        }
        parent_vma = parent_vma->vm_next;
    }
    
    struct pt_regs *child_regs = (struct pt_regs *)_task->thread.sp;
    memcpy(child_regs, regs, sizeof(struct pt_regs));
    // printk("copy regs\n");
    child_regs->x[2] = _task->thread.sp;
    // 最后就是为子进程 pt_regs 的 a0 设置返回值 0，为 sepc 手动加四
    child_regs->x[10] = 0;
    child_regs->sepc = regs->sepc+4;

    // 2.将新进程加入调度队列
    task[nr_tasks]=_task;
    nr_tasks++;
    
    printk(DEEPGREEN"[do_fork] [PID: %d] forked from [PID: %d]\n"CLEAR,_task->pid,current->pid);
    // 3.处理父子进程的返回值
    // 3.1.父进程通过 do_fork 函数直接返回子进程的 pid，并回到自身运行
    return _task->pid;
    // 3.2.子进程通过被调度器调度后（跳到 thread.ra），开始执行并返回 0
}