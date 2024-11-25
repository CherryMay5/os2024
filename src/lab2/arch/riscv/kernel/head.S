    .extern start_kernel
    .section .text.init     # 从.text.entry 改为 .text.init
    .globl _start
_start: # entry
    # (previous) initialize stack :set sp(stack pointer) point at the top of the stack
    la sp,boot_stack_top    
    
    # call mm_init function  memory management
    call mm_init

    # 线程初始化
    call task_init

    # set stvec = _traps :将 _traps 所表示的地址写入 stvec
    la t0,_traps
    csrw stvec,t0

    # set sie[STIE] = 1  :开启时钟中断，将 sie[STIE] 置 1
    csrr t0,sie             # 读取sie寄存器的值
    ori t1,t0,1<<5          # 将sie寄存器值的第五位置1，结果写入t1
    csrw sie,t1             # 将更改后的值保存回sie寄存器

    #  set first time interrupt :设置第一次时钟中断
    call sbi_set_timer  #j

    # set sstatus[SIE] = 1 :开启 S 态下的中断响应，将 sstatus[SIE] 置 1
    csrr t0,sstatus
    ori t1,t0,1<<1
    csrw sstatus,t1

    # (previous) jump to start_kernel:jump to main.c start_kernel function
    j start_kernel        

    .section .bss.stack
    .globl boot_stack   # the bottom of the stack
boot_stack:
    .space 4096     # the stack size is 4kb

    .globl boot_stack_top   # the top of the stack
boot_stack_top: