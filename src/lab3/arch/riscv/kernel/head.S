    .extern start_kernel
    .section .text.init     # 从.text.entry 改为 .text.init
    .globl _start
_start: # entry

    # (previous) initialize stack :set sp(stack pointer) point at the top of the stack
    la sp,boot_stack_top    

    # virtual memory management : 设置虚拟地址空间
    call setup_vm
    call relocate
    
    # call mm_init function  memory management
    call mm_init

    # call setup_vm_final :完成虚拟地址空间的初始化
    call setup_vm_final

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

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0,0xffffffdf80000000    #PA2VA_OFFSET
    add ra,ra,t0
    add sp,sp,t0

    #-------------------------
    # add stvec to solve trap
    la a0,1f
    add a0,a0,t0
    csrw stvec,a0
    #-------------------------

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    addi t0,x0,8    # x0:zero   t0=0+8=8
    slli t0,t0,60   # set MODE
    la t1,early_pgtbl   # load the address of early_pgtbl
    srli t1,t1,12   # set PPN
    or t0,t1,t0     # combine MODE and PPN
    csrw satp,t0    # set satp

    ret

.align 2
1:
	la a0,.Lsecondary_park
	csrw stvec, a0
    ret

.align 2
.Lsecondary_park:
	wfi
	j .Lsecondary_park

    .section .bss.stack
    .globl boot_stack   # the bottom of the stack
    
boot_stack:    
    .space 4096     # the stack size is 4kb

    .globl boot_stack_top   # the top of the stack
boot_stack_top:
