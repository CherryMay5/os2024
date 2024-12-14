    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:

    # sscratch == 0 -----> in kernel
    csrr t0,sscratch
    bne t0,zero,_u_traps

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-35*8

    sd x0,0*8(sp)     #0
    sd x1,1*8(sp)     #ra
    sd x2,2*8(sp)    #sp
    sd x3,3*8(sp)    #gp
    sd x4,4*8(sp)    #tp
    sd x5,5*8(sp)    #t0
    sd x6,6*8(sp)
    sd x7,7*8(sp)
    sd x8,8*8(sp)    #s0/fp
    sd x9,9*8(sp)    #s1
    sd x10,10*8(sp)   #a0
    sd x11,11*8(sp)
    sd x12,12*8(sp)
    sd x13,13*8(sp)
    sd x14,14*8(sp)
    sd x15,15*8(sp)
    sd x16,16*8(sp)
    sd x17,17*8(sp)
    sd x18,18*8(sp)  #s2
    sd x19,19*8(sp)
    sd x20,20*8(sp)
    sd x21,21*8(sp)
    sd x22,22*8(sp)
    sd x23,23*8(sp)
    sd x24,24*8(sp)
    sd x25,25*8(sp)
    sd x26,26*8(sp)
    sd x27,27*8(sp)
    sd x28,28*8(sp)  #t3
    sd x29,29*8(sp)
    sd x30,30*8(sp)
    sd x31,31*8(sp)
    
    csrr t0,sepc        # store sepc
    sd t0,32*8(sp)

    csrr t0,sstatus
    sd t0,33*8(sp)

    csrr t0,stval
    sd t0,34*8(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
    csrr a1,sepc
    mv a2,sp
    call trap_handler
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,34*8(sp)
    csrw stval,t0
    ld t0,33*8(sp)
    csrw sstatus,t0
    ld t0,32*8(sp)
    csrw sepc,t0
    
    ld x0,0*8(sp)
    ld x1,1*8(sp)
    ld x3,3*8(sp)
    ld x4,4*8(sp)
    ld x5,5*8(sp)
    ld x6,6*8(sp)
    ld x7,7*8(sp)
    ld x8,8*8(sp)
    ld x9,9*8(sp)
    ld x10,10*8(sp)
    ld x11,11*8(sp)
    ld x12,12*8(sp)
    ld x13,13*8(sp)
    ld x14,14*8(sp)
    ld x15,15*8(sp)
    ld x16,16*8(sp)
    ld x17,17*8(sp)
    ld x18,18*8(sp)
    ld x19,19*8(sp)
    ld x20,20*8(sp)
    ld x21,21*8(sp)
    ld x22,22*8(sp)
    ld x23,23*8(sp)
    ld x24,24*8(sp)
    ld x25,25*8(sp)
    ld x26,26*8(sp)
    ld x27,27*8(sp)
    ld x28,28*8(sp)
    ld x29,29*8(sp)
    ld x30,30*8(sp)
    ld x31,31*8(sp)

    ld x2,2*8(sp)

    addi sp,sp,35*8
    # 4. return from trap:从 trap 中返回
    sret


# lab4 new ---------------------------------
    .globl _u_traps
_u_traps:
    
    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
    csrw sscratch,sp
    mv sp,t1

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-35*8

    sd x0,0*8(sp)     #0
    sd x1,1*8(sp)     #ra
    sd x2,2*8(sp)    #sp
    sd x3,3*8(sp)    #gp
    sd x4,4*8(sp)    #tp
    sd x5,5*8(sp)    #t0
    sd x6,6*8(sp)
    sd x7,7*8(sp)
    sd x8,8*8(sp)    #s0/fp
    sd x9,9*8(sp)    #s1
    sd x10,10*8(sp)   #a0
    sd x11,11*8(sp)
    sd x12,12*8(sp)
    sd x13,13*8(sp)
    sd x14,14*8(sp)
    sd x15,15*8(sp)
    sd x16,16*8(sp)
    sd x17,17*8(sp)
    sd x18,18*8(sp)  #s2
    sd x19,19*8(sp)
    sd x20,20*8(sp)
    sd x21,21*8(sp)
    sd x22,22*8(sp)
    sd x23,23*8(sp)
    sd x24,24*8(sp)
    sd x25,25*8(sp)
    sd x26,26*8(sp)
    sd x27,27*8(sp)
    sd x28,28*8(sp)  #t3
    sd x29,29*8(sp)
    sd x30,30*8(sp)
    sd x31,31*8(sp)
    
    csrr t0,sepc        # store sepc
    sd t0,32*8(sp)

    csrr t0,sstatus
    sd t0,33*8(sp)

    csrr t0,stval
    sd t0,34*8(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
    csrr a1,sepc
    mv a2,sp
    call trap_handler
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,34*8(sp)
    csrw stval,t0
    
    ld t0,33*8(sp)
    csrw sstatus,t0

    ld t0,32*8(sp)
    csrw sepc,t0
    
    ld x0,0*8(sp)
    ld x1,1*8(sp)
    ld x3,3*8(sp)
    ld x4,4*8(sp)
    ld x5,5*8(sp)
    ld x6,6*8(sp)
    ld x7,7*8(sp)
    ld x8,8*8(sp)
    ld x9,9*8(sp)
    ld x10,10*8(sp)
    ld x11,11*8(sp)
    ld x12,12*8(sp)
    ld x13,13*8(sp)
    ld x14,14*8(sp)
    ld x15,15*8(sp)
    ld x16,16*8(sp)
    ld x17,17*8(sp)
    ld x18,18*8(sp)
    ld x19,19*8(sp)
    ld x20,20*8(sp)
    ld x21,21*8(sp)
    ld x22,22*8(sp)
    ld x23,23*8(sp)
    ld x24,24*8(sp)
    ld x25,25*8(sp)
    ld x26,26*8(sp)
    ld x27,27*8(sp)
    ld x28,28*8(sp)
    ld x29,29*8(sp)
    ld x30,30*8(sp)
    ld x31,31*8(sp)

    ld x2,2*8(sp)

    addi sp,sp,35*8

    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
    csrw sscratch,sp
    mv sp,t1

    # 4. return from trap:从 trap 中返回
    sret
    
# ------------------------------------------


    .extern dummy
    .globl __dummy
__dummy:
    # YOUR CODE HERE
    # la t0,dummy
    # csrw sepc,t0

    # lab4 new ---------------------------------
    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
    csrw sscratch,sp
    mv sp,t1
    # ------------------------------------------

    sret
    

    .globl __switch_to
__switch_to:
    # __switch_to 接受两个 task_struct 指针作为参数；
    # a0 -> prev task   a1 -> next task
    # save state to prev process
    # YOUR CODE HERE
    # 保存当前线程的 ra,sp,s0~s11 到当前线程的 thread_struct 中；
    # 因为 task_struct = state -> counter -> priority -> pid -> (thread_struct)thread -> *pgd
    # 所以 thread 的起始地址 = prev + 4*8 = prev + 32

    add t0,a0,32
    sd ra,0*8(t0)
    sd sp,1*8(t0)
    sd s0,2*8(t0)
    sd s1,3*8(t0)
    sd s2,4*8(t0)
    sd s3,5*8(t0)
    sd s4,6*8(t0)
    sd s5,7*8(t0)
    sd s6,8*8(t0)
    sd s7,9*8(t0)
    sd s8,10*8(t0)
    sd s9,11*8(t0)
    sd s10,12*8(t0)
    sd s11,13*8(t0)

    # lab4 new ---------------------------------
    # 保存sepc,sstatus,sscratch
    csrr t2,sepc
    sd t2,14*8(t0)
    csrr t2,sstatus
    sd t2,15*8(t0)
    csrr t2,sscratch
    sd t2,16*8(t0)
    # ------------------------------------------

    # restore state from next process
    # YOUR CODE HERE
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra,sp,s0~s11 中进行恢复：
    add t1,a1,32
    ld ra,0*8(t1)
    ld sp,1*8(t1)
    ld s0,2*8(t1)
    ld s1,3*8(t1)
    ld s2,4*8(t1)
    ld s3,5*8(t1)
    ld s4,6*8(t1)
    ld s5,7*8(t1)
    ld s6,8*8(t1)
    ld s7,9*8(t1)
    ld s8,10*8(t1)
    ld s9,11*8(t1)
    ld s10,12*8(t1)
    ld s11,13*8(t1)

    # lab4 new ---------------------------------
    # 恢复sepc,sstatus,sscratch
    ld t2,14*8(t1)
    csrw sepc,t2
    ld t2,15*8(t1)
    csrw sstatus,t2
    ld t2,16*8(t1)
    csrw sscratch,t2

    # 切换页表
    ld t3,17*8(t1)
    li t4,0xffffffdf80000000    # PA2VA_OFFSET
    sub t3,t3,t4                # t3=t3-t4
    srli t3,t3,12               # 12-bit offset
    addi t2,x0,8                # x0:zero   t0=0+8=8
    slli t2,t2,60               # set MODE
    or t2,t2,t3
    csrw satp,t2                # set satp

    # 刷新TLB和ICache
    sfence.vma zero, zero
    # ------------------------------------------

    ret