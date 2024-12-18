#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "string.h"
#include "vm.h"
#include "stddef.h"

#include "fs.h" // lab6 fs added

extern void __dummy();
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

// lab6 add-----------------------
int nr_tasks=2; // idle+process 1
// -------------------------------

// lab5 add----------------
/*
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr)
{
    // 获取VMA链表头
    struct vm_area_struct *vma = mm->mmap;

    // 遍历VMA链表
    while (vma) 
    {
        // 检查addr是否在当前VMA的范围内
        if (addr >= vma->vm_start && addr < vma->vm_end) 
        {
            return vma; // 找到目标VMA，返回指针
        }
        vma = vma->vm_next; // 移动到下一个VMA
    }

    // 没有找到匹配的VMA
    return NULL;
}

/*
* @mm       : current thread's mm_struct
* @addr     : the suggested va to map
* @len      : memory size to map
* @vm_pgoff : phdr->p_offset
* @vm_filesz: phdr->p_filesz
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags)
{
    // 1. 分配一个vm_area_struct
    struct vm_area_struct *new_vma=(struct vm_area_struct *)kalloc(sizeof(struct vm_area_struct));
    if(!new_vma)
    {
        printk("do_mmap: kalloc failed\n");
        return 0;
    }

    // 2. 初始化new_vma
    new_vma->vm_mm = mm;
    new_vma->vm_start = addr;
    new_vma->vm_end = addr + len;
    new_vma->vm_next = NULL;
    new_vma->vm_prev = NULL;
    new_vma->vm_flags = flags;
    new_vma->vm_pgoff = vm_pgoff;
    new_vma->vm_filesz = vm_filesz;

    // 3. 将new_vma插入到mm->mmap链表中
    struct vm_area_struct *curr = mm->mmap;
    struct vm_area_struct *prev = NULL;

    // 找到插入点，链表按vm_start排序
    while(curr && curr->vm_start < addr) 
    {
        prev = curr;
        curr = curr->vm_next;
    }

    // 更新new_vma的next和prev
    new_vma->vm_next = curr;
    new_vma->vm_prev = prev;
    if(prev) 
    {
        prev->vm_next = new_vma;
    }else
    {
        mm->mmap = new_vma; // new_vma是链表的第一个节点
    }
    if(curr)
    {
        curr->vm_prev = new_vma;
    }

    // 4. 返回新分配区域的起始地址
    return new_vma->vm_start;
}

// -------------------------

extern char _sramdisk[];
extern char _sbss[];
extern uint64_t swapper_pg_dir[];

void *memcpy(void *dest, void *src, size_t n) {
    char *d = dest;
    char *s = src;
    while (n--) {
        *(d++) = *(s++);
    }
    return dest;
}

void load_bin_program(struct task_struct *task) {
    // 将 uapp 所在的页面映射到每个进程的页表中-------------------------------
    // copy first
    void *user_uapp = alloc_pages(((uint64_t)_sbss-(uint64_t)_sramdisk)/PGSIZE+1);
    uint64_t uapp_size = (uint64_t)_sbss - (uint64_t)_sramdisk;
    memcpy(user_uapp,_sramdisk,uapp_size);

    uint64_t uapp_va = USER_START;
    uint64_t uapp_pa = (uint64_t)user_uapp - PA2VA_OFFSET;
    create_mapping(task->pgd,uapp_va,uapp_pa,uapp_size,PERM_USER_UAPP);
}

void load_elf_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
            uint64_t start_vpg=PGROUNDDOWN(phdr->p_vaddr);
            uint64_t end_vpg=PGROUNDUP(phdr->p_vaddr+phdr->p_memsz);
            uint64_t offset=phdr->p_paddr-start_vpg;
            uint64_t pg_num=(end_vpg-start_vpg)/PGSIZE;
            
            #define PTE_V  (1 << 0)  // Valid
            #define PTE_R  (1 << 1)  // Readable
            #define PTE_W  (1 << 2)  // Writable
            #define PTE_X  (1 << 3)  // Executable
            #define PTE_U  (1 << 4)  // User accessible
            // 权限转换
            uint64_t perm = PTE_V | PTE_U; // 基础权限：有效和用户态访问
            if (phdr->p_flags & PF_R) perm |= PTE_R; // 可读
            if (phdr->p_flags & PF_W) perm |= PTE_W; // 可写
            if (phdr->p_flags & PF_X) perm |= PTE_X; // 可执行

            // 为段分配物理页
            void *uapp_mem = alloc_pages(pg_num);
            if (!uapp_mem) {
                printk("Failed to allocate memory for ELF segment %d\n", i);
                return;
            }

            // 拷贝段内容
            memcpy((void *)(uapp_mem + offset), (void *)(_sramdisk + phdr->p_offset), phdr->p_filesz);

            // do mapping
            // 映射段到进程的页表
            uint64_t va = start_vpg;
            uint64_t pa = (uint64_t)uapp_mem - PA2VA_OFFSET;
            create_mapping((uint64_t *)task->pgd, va, pa, pg_num * PGSIZE, perm);

        }
    }
}

void load_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // 获取段信息
            uint64_t addr=phdr->p_vaddr;
            uint64_t len=phdr->p_memsz;
            uint64_t offset=phdr->p_offset; 
            uint64_t filesz=phdr->p_filesz;

            // 权限转换
            uint64_t vma_flags=0;
            if (phdr->p_flags & PF_R) vma_flags |= VM_READ; // 可读
            if (phdr->p_flags & PF_W) vma_flags |= VM_WRITE; // 可写
            if (phdr->p_flags & PF_X) vma_flags |= VM_EXEC; // 可执行

            do_mmap(&task->mm,addr,len,offset,filesz,vma_flags);
        }
    }

    // user stack
    do_mmap(&task->mm,USER_END-PGSIZE,PGSIZE,0,0,VM_READ|VM_WRITE|VM_ANON);
}

void task_init() {
    srand(2024);

    // 1. 调用 kalloc() 为 idle 分配一个4Kib物理页
    idle=(struct task_struct *)kalloc();
    if (!idle) {
        // 如果内存分配失败，则退出
        printk("Failed to allocate memory for idle task\n");
        return;
    }
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state=TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter=0;
    idle->priority=0;
    // 4. 设置 idle 的 pid 为 0
    idle->pid=0;
    // 5. 将 current 和 task[0] 指向 idle
    current=idle;
    task[0]=idle;

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
    //     - counter  = 0;
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    // for(int i=1;i<NR_TASKS;i++)  // lab6 fork delete
    // for(int i=1;i<nr_tasks;i++)    // 初始化1个进程 lab6 added
    for(int i=1;i<NR_TASKS;i++) // lab7 added
    {
        task[i]=(struct task_struct *)kalloc();
        if (!task[i]) {
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d\n", i);
            return;
        }
        task[i]->state=TASK_RUNNING;
        task[i]->counter=0;
        task[i]->priority=rand()%(PRIORITY_MAX - PRIORITY_MIN + 1)+PRIORITY_MIN;
        task[i]->pid=i;

        task[i]->thread.ra=(uint64_t)__dummy;
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;

        // lab5 ------------------------------------
        task[i]->mm.mmap=NULL;
        // -----------------------------------------

        // lab4 ---------------------------------------------------------
        
        // 对于每个进程，创建属于它自己的页表----------------------------------
        task[i]->pgd = (uint64_t *)alloc_page();
        if (!task[i]->pgd) {
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d's page directory\n", i);
            return;
        }
        // 将内核页表 swapper_pg_dir 复制到每个进程的页表中
        memcpy((void *)task[i]->pgd,(void *)swapper_pg_dir,PGSIZE);

        // 设置用户态栈----------------------------------------------------
        // 为用户态栈申请一个空的页面
        // void *user_stack = alloc_page();
        // if (!user_stack) {
        //     // 如果内存分配失败，则退出
        //     printk("Failed to allocate user stack for task %d\n", i);
        //     return;
        // }
        // 映射到进程的页表中
        // uint64_t user_stack_va = USER_END - PGSIZE;
        // uint64_t user_stack_pa = (uint64_t)user_stack - PA2VA_OFFSET;
        // create_mapping(task[i]->pgd,user_stack_va,user_stack_pa,PGSIZE,PERM_USER_USTACK);

        Elf64_Ehdr *ehdr = (Elf64_Ehdr*)_sramdisk;

        // check magic number
        if ((ehdr->e_ident[0]  == 0x7f &&ehdr->e_ident[1]  == 0x45 &&ehdr->e_ident[2]  == 0x4c &&
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
            ehdr->e_ident[15] == 0x00)) 
        {
            printk("elf\n");
            // load_elf_program(task[i]);
            load_program(task[i]);  // vma
            task[i]->thread.sepc = ehdr->e_entry;
        }else
        {
            printk("bin\n");
            // load_bin_program(task[i]);
            // 1.将 sepc 设置为 USER_START U-Mode程序入口地址
            task[i]->thread.sepc = USER_START;
        }
        

        // 2.set sstatus 
        uint64_t set_sstatus=0;
        // SPP（使得 sret 返回至 U-Mode）--- bit[8]=0
        set_sstatus = set_sstatus & 0xfffffffffffffeff; 
        // SPIE（sret 之后开启中断）--- bit[5]=1
        set_sstatus = set_sstatus | (1<<5);
        // SUM（S-Mode 可以访问 User 页面）--- bit[18]=1
        set_sstatus = set_sstatus | (1<<18);        
        task[i]->thread.sstatus = set_sstatus;
        // 3.sscratch 设置为 U-Mode 的 sp，其值为 USER_END
        task[i]->thread.sscratch = USER_END;
        
        // ----------------------------------------------------------------------------

        // lab6 fs added-------------------------
        task[i]->files = file_init();
        // --------------------------------------
    }
    
    printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    printk("dummy\n");
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk(BLUE"[PID = %d] is running. auto_inc_local_var = %d\n"CLEAR, current->pid, auto_inc_local_var);
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

/* 线程切换入口函数 */
void switch_to(struct task_struct *next)
{
    // YOUR CODE HERE
    if(current==next)
    {
        return;
    }else
    {
        printk(YELLOW"\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,next->pid,next->priority,next->counter);
        struct task_struct *temp=current;
        current=next;
        __switch_to(temp,next);  //调用 __switch_to 函数进行线程切换
        // printk("ok\n");
    }
    return;
}

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer()
{
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE
    if(current==idle||current->counter<=0)
    {
        schedule();
    }else
    {
        current->counter=current->counter-1;
        if(current->counter>0)
        {
            return;
        }else
        {
            schedule();
        }
    }
    return;
}

/* 调度程序，选择出下一个运行的线程 */
void schedule()
{
    int i;
    // 调度时选择 counter 最大的线程运行
    int max_index=0;
    int max_counter=0;
    for(i=1;i<NR_TASKS;i++)
    // for(i=1;i<nr_tasks;i++)
    {
        if(task[i]->counter>max_counter&&task[i]->state==TASK_RUNNING)
        {
            max_index=i;
            max_counter=task[i]->counter;
        }else if(task[i]->counter==max_counter) // 即优先级越高，运行的时间越长，且越先运行
        {
            if(task[i]->priority>task[max_index]->priority)
            {
                max_index=i;
            }
        }
    }

    // next=task[choice];
    // 如果所有线程 counter 都为 0，则令所有线程 counter = priority
    bool all_zero=true;
    for(i=1;i<NR_TASKS;i++)
    // for(i=1;i<nr_tasks;i++)
    {
        if(task[i]->counter!=0)
        {
            all_zero=0;
            break;
        }
    }
    if(all_zero)
    {
        printk("\n");
        for(i=1;i<NR_TASKS;i++)
        // for(i=1;i<nr_tasks;i++)
        {
            task[i]->counter=task[i]->priority;
            printk(PURPLE"SET [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,i,task[i]->priority,task[i]->counter);
        }
        schedule();     // 设置完后需要重新进行调度
    }else{
        // 最后通过 switch_to 切换到下一个线程
        // printk("sssswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",task[max_index]->pid,task[max_index]->priority,task[max_index]->counter);
        switch_to(task[max_index]);
    }

    return;
}