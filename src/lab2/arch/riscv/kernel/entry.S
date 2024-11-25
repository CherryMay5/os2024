    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-264

    sd x0,0(sp)     #0
    sd x1,8(sp)     #ra
    sd x2,16(sp)    #sp
    sd x3,24(sp)    #gp
    sd x4,32(sp)    #tp
    sd x5,40(sp)    #t0
    sd x6,48(sp)
    sd x7,56(sp)
    sd x8,64(sp)    #s0/fp
    sd x9,72(sp)    #s1
    sd x10,80(sp)   #a0
    sd x11,88(sp)
    sd x12,96(sp)
    sd x13,104(sp)
    sd x14,112(sp)
    sd x15,120(sp)
    sd x16,128(sp)
    sd x17,136(sp)
    sd x18,144(sp)  #s2
    sd x19,152(sp)
    sd x20,160(sp)
    sd x21,168(sp)
    sd x22,176(sp)
    sd x23,184(sp)
    sd x24,192(sp)
    sd x25,200(sp)
    sd x26,208(sp)
    sd x27,216(sp)
    sd x28,224(sp)  #t3
    sd x29,232(sp)
    sd x30,240(sp)
    sd x31,248(sp)
    
    csrr t0,sepc        # store sepc
    sd t0,256(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
    csrr a1,sepc
    call trap_handler
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,256(sp)
    csrw sepc,t0
    
    ld x0,0(sp)
    ld x1,8(sp)
    ld x3,24(sp)
    ld x4,32(sp)
    ld x5,40(sp)
    ld x6,48(sp)
    ld x7,56(sp)
    ld x8,64(sp)
    ld x9,72(sp)
    ld x10,80(sp)
    ld x11,88(sp)
    ld x12,96(sp)
    ld x13,104(sp)
    ld x14,112(sp)
    ld x15,120(sp)
    ld x16,128(sp)
    ld x17,136(sp)
    ld x18,144(sp)
    ld x19,152(sp)
    ld x20,160(sp)
    ld x21,168(sp)
    ld x22,176(sp)
    ld x23,184(sp)
    ld x24,192(sp)
    ld x25,200(sp)
    ld x26,208(sp)
    ld x27,216(sp)
    ld x28,224(sp)
    ld x29,232(sp)
    ld x30,240(sp)
    ld x31,248(sp)

    ld x2,16(sp)

    addi sp,sp,264

    # 4. return from trap:从 trap 中返回
    sret


    .extern dummy
    .globl __dummy
__dummy:
    # YOUR CODE HERE
    la t0,dummy
    csrw sepc,t0
    sret
    

    .globl __switch_to
__switch_to:
    # __switch_to 接受两个 task_struct 指针作为参数；

    # save state to prev process
    # YOUR CODE HERE
    # 保存当前线程的 ra,sp,s0~s11 到当前线程的 thread_struct 中；
    # 因为 task_struct = state -> counter -> priority -> pid -> (thread_struct)thread
    # 所以 thread 的起始地址 = prev + 4*8 = prev + 32

    add t0,a0,32
    sd ra,0(t0)
    sd sp,8(t0)
    sd s0,16(t0)
    sd s1,24(t0)
    sd s2,32(t0)
    sd s3,40(t0)
    sd s4,48(t0)
    sd s5,56(t0)
    sd s6,64(t0)
    sd s7,72(t0)
    sd s8,80(t0)
    sd s9,88(t0)
    sd s10,96(t0)
    sd s11,104(t0)

    # restore state from next process
    # YOUR CODE HERE
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra,sp,s0~s11 中进行恢复：
    add t1,a1,32
    ld ra,0(t1)
    ld sp,8(t1)
    ld s0,16(t1)
    ld s1,24(t1)
    ld s2,32(t1)
    ld s3,40(t1)
    ld s4,48(t1)
    ld s5,56(t1)
    ld s6,64(t1)
    ld s7,72(t1)
    ld s8,80(t1)
    ld s9,88(t1)
    ld s10,96(t1)
    ld s11,104(t1)

    ret