
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .section .text.init     # 从.text.entry 改为 .text.init
    .globl _start
_start: # entry

    # (previous) initialize stack :set sp(stack pointer) point at the top of the stack
    la sp,boot_stack_top    
ffffffe000200000:	0000a117          	auipc	sp,0xa
ffffffe000200004:	00010113          	mv	sp,sp

    # virtual memory management : 设置虚拟地址空间
    call setup_vm
ffffffe000200008:	2b5020ef          	jal	ffffffe000202abc <setup_vm>
    call relocate
ffffffe00020000c:	030000ef          	jal	ffffffe00020003c <relocate>
    
    # call mm_init function  memory management
    call mm_init
ffffffe000200010:	28d000ef          	jal	ffffffe000200a9c <mm_init>

    # call setup_vm_final :完成虚拟地址空间的初始化
    call setup_vm_final
ffffffe000200014:	38d020ef          	jal	ffffffe000202ba0 <setup_vm_final>

    # 线程初始化
    call task_init
ffffffe000200018:	158010ef          	jal	ffffffe000201170 <task_init>

    # set stvec = _traps :将 _traps 所表示的地址写入 stvec
    la t0,_traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	05428293          	addi	t0,t0,84 # ffffffe000200070 <_traps>
    csrw stvec,t0
ffffffe000200024:	10529073          	csrw	stvec,t0

    # set sie[STIE] = 1  :开启时钟中断，将 sie[STIE] 置 1
    csrr t0,sie             # 读取sie寄存器的值
ffffffe000200028:	104022f3          	csrr	t0,sie
    ori t1,t0,1<<5          # 将sie寄存器值的第五位置1，结果写入t1
ffffffe00020002c:	0202e313          	ori	t1,t0,32
    csrw sie,t1             # 将更改后的值保存回sie寄存器
ffffffe000200030:	10431073          	csrw	sie,t1
    
    #  set first time interrupt :设置第一次时钟中断
    call sbi_set_timer  #j
ffffffe000200034:	505010ef          	jal	ffffffe000201d38 <sbi_set_timer>
    # ori t1,t0,1<<1
    # csrw sstatus,t1
    # -------------------------------------------------------------

    # (previous) jump to start_kernel:jump to main.c start_kernel function
    j start_kernel        
ffffffe000200038:	6bd0206f          	j	ffffffe000202ef4 <start_kernel>

ffffffe00020003c <relocate>:

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0,0xffffffdf80000000    #PA2VA_OFFSET
ffffffe00020003c:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200040:	01f29293          	slli	t0,t0,0x1f
    add ra,ra,t0
ffffffe000200044:	005080b3          	add	ra,ra,t0
    add sp,sp,t0
ffffffe000200048:	00510133          	add	sp,sp,t0
    # add a0,a0,t0
    # csrw stvec,a0
    #----------------------------------

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe00020004c:	12000073          	sfence.vma

    # set satp with early_pgtbl
    addi t0,x0,8    # x0:zero   t0=0+8=8
ffffffe000200050:	00800293          	li	t0,8
    slli t0,t0,60   # set MODE
ffffffe000200054:	03c29293          	slli	t0,t0,0x3c
    la t1,early_pgtbl   # load the address of early_pgtbl
ffffffe000200058:	0000b317          	auipc	t1,0xb
ffffffe00020005c:	fa830313          	addi	t1,t1,-88 # ffffffe00020b000 <early_pgtbl>
    srli t1,t1,12   # set PPN
ffffffe000200060:	00c35313          	srli	t1,t1,0xc
    or t0,t1,t0     # combine MODE and PPN
ffffffe000200064:	005362b3          	or	t0,t1,t0
    csrw satp,t0    # set satp
ffffffe000200068:	18029073          	csrw	satp,t0

    ret
ffffffe00020006c:	00008067          	ret

ffffffe000200070 <_traps>:
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 判断是否从用户态陷入，通过 sscratch 是否为 0 来区分
    csrr t0, sscratch
ffffffe000200070:	140022f3          	csrr	t0,sscratch
    bnez t0, 1f   # 如果不等于 0，说明是从用户态陷入，跳转到标签1
ffffffe000200074:	00029263          	bnez	t0,ffffffe000200078 <_traps+0x8>

1:  # 用户态陷入处理
    # 切换到用户栈并保存上下文
    csrr t1, sscratch
ffffffe000200078:	14002373          	csrr	t1,sscratch
    csrw sscratch, sp
ffffffe00020007c:	14011073          	csrw	sscratch,sp
    mv sp, t1
ffffffe000200080:	00030113          	mv	sp,t1

2:  # 1. 保存 32 个寄存器和 sepc 到栈上
    addi sp, sp, -35*8
ffffffe000200084:	ee810113          	addi	sp,sp,-280 # ffffffe000209ee8 <_sbss+0xee8>

    sd x0, 0*8(sp)    # x0
ffffffe000200088:	00013023          	sd	zero,0(sp)
    sd x1, 1*8(sp)    # ra
ffffffe00020008c:	00113423          	sd	ra,8(sp)
    sd x2, 2*8(sp)    # sp
ffffffe000200090:	00213823          	sd	sp,16(sp)
    sd x3, 3*8(sp)    # gp
ffffffe000200094:	00313c23          	sd	gp,24(sp)
    sd x4, 4*8(sp)    # tp
ffffffe000200098:	02413023          	sd	tp,32(sp)
    sd x5, 5*8(sp)    # t0
ffffffe00020009c:	02513423          	sd	t0,40(sp)
    sd x6, 6*8(sp)
ffffffe0002000a0:	02613823          	sd	t1,48(sp)
    sd x7, 7*8(sp)
ffffffe0002000a4:	02713c23          	sd	t2,56(sp)
    sd x8, 8*8(sp)    # s0/fp
ffffffe0002000a8:	04813023          	sd	s0,64(sp)
    sd x9, 9*8(sp)    # s1
ffffffe0002000ac:	04913423          	sd	s1,72(sp)
    sd x10, 10*8(sp)  # a0
ffffffe0002000b0:	04a13823          	sd	a0,80(sp)
    sd x11, 11*8(sp)
ffffffe0002000b4:	04b13c23          	sd	a1,88(sp)
    sd x12, 12*8(sp)
ffffffe0002000b8:	06c13023          	sd	a2,96(sp)
    sd x13, 13*8(sp)
ffffffe0002000bc:	06d13423          	sd	a3,104(sp)
    sd x14, 14*8(sp)
ffffffe0002000c0:	06e13823          	sd	a4,112(sp)
    sd x15, 15*8(sp)
ffffffe0002000c4:	06f13c23          	sd	a5,120(sp)
    sd x16, 16*8(sp)
ffffffe0002000c8:	09013023          	sd	a6,128(sp)
    sd x17, 17*8(sp)
ffffffe0002000cc:	09113423          	sd	a7,136(sp)
    sd x18, 18*8(sp)  # s2
ffffffe0002000d0:	09213823          	sd	s2,144(sp)
    sd x19, 19*8(sp)
ffffffe0002000d4:	09313c23          	sd	s3,152(sp)
    sd x20, 20*8(sp)
ffffffe0002000d8:	0b413023          	sd	s4,160(sp)
    sd x21, 21*8(sp)
ffffffe0002000dc:	0b513423          	sd	s5,168(sp)
    sd x22, 22*8(sp)
ffffffe0002000e0:	0b613823          	sd	s6,176(sp)
    sd x23, 23*8(sp)
ffffffe0002000e4:	0b713c23          	sd	s7,184(sp)
    sd x24, 24*8(sp)
ffffffe0002000e8:	0d813023          	sd	s8,192(sp)
    sd x25, 25*8(sp)
ffffffe0002000ec:	0d913423          	sd	s9,200(sp)
    sd x26, 26*8(sp)
ffffffe0002000f0:	0da13823          	sd	s10,208(sp)
    sd x27, 27*8(sp)
ffffffe0002000f4:	0db13c23          	sd	s11,216(sp)
    sd x28, 28*8(sp)  # t3
ffffffe0002000f8:	0fc13023          	sd	t3,224(sp)
    sd x29, 29*8(sp)
ffffffe0002000fc:	0fd13423          	sd	t4,232(sp)
    sd x30, 30*8(sp)
ffffffe000200100:	0fe13823          	sd	t5,240(sp)
    sd x31, 31*8(sp)
ffffffe000200104:	0ff13c23          	sd	t6,248(sp)

    csrr t2, sepc     # 保存 sepc
ffffffe000200108:	141023f3          	csrr	t2,sepc
    sd t2, 32*8(sp)
ffffffe00020010c:	10713023          	sd	t2,256(sp)

    csrr t2, sstatus  # 保存 sstatus
ffffffe000200110:	100023f3          	csrr	t2,sstatus
    sd t2, 33*8(sp)
ffffffe000200114:	10713423          	sd	t2,264(sp)

    csrr t2, stval    # 保存 stval
ffffffe000200118:	143023f3          	csrr	t2,stval
    sd t2, 34*8(sp)
ffffffe00020011c:	10713823          	sd	t2,272(sp)

    # 2. 调用 trap_handler 处理
    csrr a0, scause
ffffffe000200120:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe000200124:	141025f3          	csrr	a1,sepc
    mv a2, sp
ffffffe000200128:	00010613          	mv	a2,sp
    call trap_handler
ffffffe00020012c:	508020ef          	jal	ffffffe000202634 <trap_handler>

ffffffe000200130 <__ret_from_fork>:

    .globl __ret_from_fork
__ret_from_fork:
    
    # 3.恢复 sepc 和 32 个寄存器 (x2(sp) 应该最后恢复)
    ld t2, 34*8(sp)
ffffffe000200130:	11013383          	ld	t2,272(sp)
    csrw stval, t2
ffffffe000200134:	14339073          	csrw	stval,t2

    ld t2, 33*8(sp)
ffffffe000200138:	10813383          	ld	t2,264(sp)
    csrw sstatus, t2
ffffffe00020013c:	10039073          	csrw	sstatus,t2

    ld t2, 32*8(sp)
ffffffe000200140:	10013383          	ld	t2,256(sp)
    csrw sepc, t2
ffffffe000200144:	14139073          	csrw	sepc,t2

    ld x0, 0*8(sp)
ffffffe000200148:	00013003          	ld	zero,0(sp)
    ld x1, 1*8(sp)
ffffffe00020014c:	00813083          	ld	ra,8(sp)
    ld x3, 3*8(sp)
ffffffe000200150:	01813183          	ld	gp,24(sp)
    ld x4, 4*8(sp)
ffffffe000200154:	02013203          	ld	tp,32(sp)
    ld x5, 5*8(sp)
ffffffe000200158:	02813283          	ld	t0,40(sp)
    ld x6, 6*8(sp)
ffffffe00020015c:	03013303          	ld	t1,48(sp)
    ld x7, 7*8(sp)
ffffffe000200160:	03813383          	ld	t2,56(sp)
    ld x8, 8*8(sp)
ffffffe000200164:	04013403          	ld	s0,64(sp)
    ld x9, 9*8(sp)
ffffffe000200168:	04813483          	ld	s1,72(sp)
    ld x10, 10*8(sp)
ffffffe00020016c:	05013503          	ld	a0,80(sp)
    ld x11, 11*8(sp)
ffffffe000200170:	05813583          	ld	a1,88(sp)
    ld x12, 12*8(sp)
ffffffe000200174:	06013603          	ld	a2,96(sp)
    ld x13, 13*8(sp)
ffffffe000200178:	06813683          	ld	a3,104(sp)
    ld x14, 14*8(sp)
ffffffe00020017c:	07013703          	ld	a4,112(sp)
    ld x15, 15*8(sp)
ffffffe000200180:	07813783          	ld	a5,120(sp)
    ld x16, 16*8(sp)
ffffffe000200184:	08013803          	ld	a6,128(sp)
    ld x17, 17*8(sp)
ffffffe000200188:	08813883          	ld	a7,136(sp)
    ld x18, 18*8(sp)
ffffffe00020018c:	09013903          	ld	s2,144(sp)
    ld x19, 19*8(sp)
ffffffe000200190:	09813983          	ld	s3,152(sp)
    ld x20, 20*8(sp)
ffffffe000200194:	0a013a03          	ld	s4,160(sp)
    ld x21, 21*8(sp)
ffffffe000200198:	0a813a83          	ld	s5,168(sp)
    ld x22, 22*8(sp)
ffffffe00020019c:	0b013b03          	ld	s6,176(sp)
    ld x23, 23*8(sp)
ffffffe0002001a0:	0b813b83          	ld	s7,184(sp)
    ld x24, 24*8(sp)
ffffffe0002001a4:	0c013c03          	ld	s8,192(sp)
    ld x25, 25*8(sp)
ffffffe0002001a8:	0c813c83          	ld	s9,200(sp)
    ld x26, 26*8(sp)
ffffffe0002001ac:	0d013d03          	ld	s10,208(sp)
    ld x27, 27*8(sp)
ffffffe0002001b0:	0d813d83          	ld	s11,216(sp)
    ld x28, 28*8(sp)
ffffffe0002001b4:	0e013e03          	ld	t3,224(sp)
    ld x29, 29*8(sp)
ffffffe0002001b8:	0e813e83          	ld	t4,232(sp)
    ld x30, 30*8(sp)
ffffffe0002001bc:	0f013f03          	ld	t5,240(sp)
    ld x31, 31*8(sp)
ffffffe0002001c0:	0f813f83          	ld	t6,248(sp)

    ld x2, 2*8(sp)
ffffffe0002001c4:	01013103          	ld	sp,16(sp)

    addi sp, sp, 35*8
ffffffe0002001c8:	11810113          	addi	sp,sp,280

    bnez t0,3f  # 如果不等于 0，说明是从用户态陷入，跳转到标签3
ffffffe0002001cc:	00029263          	bnez	t0,ffffffe0002001d0 <__ret_from_fork+0xa0>

3:  # 恢复用户态栈
    csrr t1, sscratch
ffffffe0002001d0:	14002373          	csrr	t1,sscratch
    csrw sscratch, sp
ffffffe0002001d4:	14011073          	csrw	sscratch,sp
    mv sp, t1
ffffffe0002001d8:	00030113          	mv	sp,t1

4:  # 返回到内核
    sret
ffffffe0002001dc:	10200073          	sret

ffffffe0002001e0 <__dummy>:
    # la t0,dummy
    # csrw sepc,t0

    # lab4 new ---------------------------------
    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
ffffffe0002001e0:	14002373          	csrr	t1,sscratch
    csrw sscratch,sp
ffffffe0002001e4:	14011073          	csrw	sscratch,sp
    mv sp,t1
ffffffe0002001e8:	00030113          	mv	sp,t1
    # ------------------------------------------

    sret
ffffffe0002001ec:	10200073          	sret

ffffffe0002001f0 <__switch_to>:
    # YOUR CODE HERE
    # 保存当前线程的 ra,sp,s0~s11 到当前线程的 thread_struct 中；
    # 因为 task_struct = state -> counter -> priority -> pid -> (thread_struct)thread -> *pgd
    # 所以 thread 的起始地址 = prev + 4*8 = prev + 32

    add t0,a0,32
ffffffe0002001f0:	02050293          	addi	t0,a0,32
    sd ra,0*8(t0)
ffffffe0002001f4:	0012b023          	sd	ra,0(t0)
    sd sp,1*8(t0)
ffffffe0002001f8:	0022b423          	sd	sp,8(t0)
    sd s0,2*8(t0)
ffffffe0002001fc:	0082b823          	sd	s0,16(t0)
    sd s1,3*8(t0)
ffffffe000200200:	0092bc23          	sd	s1,24(t0)
    sd s2,4*8(t0)
ffffffe000200204:	0322b023          	sd	s2,32(t0)
    sd s3,5*8(t0)
ffffffe000200208:	0332b423          	sd	s3,40(t0)
    sd s4,6*8(t0)
ffffffe00020020c:	0342b823          	sd	s4,48(t0)
    sd s5,7*8(t0)
ffffffe000200210:	0352bc23          	sd	s5,56(t0)
    sd s6,8*8(t0)
ffffffe000200214:	0562b023          	sd	s6,64(t0)
    sd s7,9*8(t0)
ffffffe000200218:	0572b423          	sd	s7,72(t0)
    sd s8,10*8(t0)
ffffffe00020021c:	0582b823          	sd	s8,80(t0)
    sd s9,11*8(t0)
ffffffe000200220:	0592bc23          	sd	s9,88(t0)
    sd s10,12*8(t0)
ffffffe000200224:	07a2b023          	sd	s10,96(t0)
    sd s11,13*8(t0)
ffffffe000200228:	07b2b423          	sd	s11,104(t0)

    # lab4 new ---------------------------------
    # 保存sepc,sstatus,sscratch
    csrr t2,sepc
ffffffe00020022c:	141023f3          	csrr	t2,sepc
    sd t2,14*8(t0)
ffffffe000200230:	0672b823          	sd	t2,112(t0)
    csrr t2,sstatus
ffffffe000200234:	100023f3          	csrr	t2,sstatus
    sd t2,15*8(t0)
ffffffe000200238:	0672bc23          	sd	t2,120(t0)
    csrr t2,sscratch
ffffffe00020023c:	140023f3          	csrr	t2,sscratch
    sd t2,16*8(t0)
ffffffe000200240:	0872b023          	sd	t2,128(t0)
    # ------------------------------------------

    # restore state from next process
    # YOUR CODE HERE
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra,sp,s0~s11 中进行恢复：
    add t1,a1,32
ffffffe000200244:	02058313          	addi	t1,a1,32
    ld ra,0*8(t1)
ffffffe000200248:	00033083          	ld	ra,0(t1)
    ld sp,1*8(t1)
ffffffe00020024c:	00833103          	ld	sp,8(t1)
    ld s0,2*8(t1)
ffffffe000200250:	01033403          	ld	s0,16(t1)
    ld s1,3*8(t1)
ffffffe000200254:	01833483          	ld	s1,24(t1)
    ld s2,4*8(t1)
ffffffe000200258:	02033903          	ld	s2,32(t1)
    ld s3,5*8(t1)
ffffffe00020025c:	02833983          	ld	s3,40(t1)
    ld s4,6*8(t1)
ffffffe000200260:	03033a03          	ld	s4,48(t1)
    ld s5,7*8(t1)
ffffffe000200264:	03833a83          	ld	s5,56(t1)
    ld s6,8*8(t1)
ffffffe000200268:	04033b03          	ld	s6,64(t1)
    ld s7,9*8(t1)
ffffffe00020026c:	04833b83          	ld	s7,72(t1)
    ld s8,10*8(t1)
ffffffe000200270:	05033c03          	ld	s8,80(t1)
    ld s9,11*8(t1)
ffffffe000200274:	05833c83          	ld	s9,88(t1)
    ld s10,12*8(t1)
ffffffe000200278:	06033d03          	ld	s10,96(t1)
    ld s11,13*8(t1)
ffffffe00020027c:	06833d83          	ld	s11,104(t1)

    # lab4 new ---------------------------------
    # 恢复sepc,sstatus,sscratch
    ld t2,14*8(t1)
ffffffe000200280:	07033383          	ld	t2,112(t1)
    csrw sepc,t2
ffffffe000200284:	14139073          	csrw	sepc,t2
    ld t2,15*8(t1)
ffffffe000200288:	07833383          	ld	t2,120(t1)
    csrw sstatus,t2
ffffffe00020028c:	10039073          	csrw	sstatus,t2
    ld t2,16*8(t1)
ffffffe000200290:	08033383          	ld	t2,128(t1)
    csrw sscratch,t2
ffffffe000200294:	14039073          	csrw	sscratch,t2

    # 切换页表
    ld t3,17*8(t1)
ffffffe000200298:	08833e03          	ld	t3,136(t1)
    li t4,0xffffffdf80000000    # PA2VA_OFFSET
ffffffe00020029c:	fbf00e9b          	addiw	t4,zero,-65
ffffffe0002002a0:	01fe9e93          	slli	t4,t4,0x1f
    sub t3,t3,t4                # t3=t3-t4
ffffffe0002002a4:	41de0e33          	sub	t3,t3,t4
    srli t3,t3,12               # 12-bit offset
ffffffe0002002a8:	00ce5e13          	srli	t3,t3,0xc
    addi t2,x0,8                # x0:zero   t0=0+8=8
ffffffe0002002ac:	00800393          	li	t2,8
    slli t2,t2,60               # set MODE
ffffffe0002002b0:	03c39393          	slli	t2,t2,0x3c
    or t2,t2,t3
ffffffe0002002b4:	01c3e3b3          	or	t2,t2,t3
    csrw satp,t2                # set satp
ffffffe0002002b8:	18039073          	csrw	satp,t2

    # 刷新TLB和ICache
    sfence.vma zero, zero
ffffffe0002002bc:	12000073          	sfence.vma
    # ------------------------------------------

ffffffe0002002c0:	00008067          	ret

ffffffe0002002c4 <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe0002002c4:	fe010113          	addi	sp,sp,-32
ffffffe0002002c8:	00813c23          	sd	s0,24(sp)
ffffffe0002002cc:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time_get;
    __asm__ volatile (
ffffffe0002002d0:	c01027f3          	rdtime	a5
ffffffe0002002d4:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time_get]"
        :[time_get]"=r"(time_get)
    );
    return time_get;
ffffffe0002002d8:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002dc:	00078513          	mv	a0,a5
ffffffe0002002e0:	01813403          	ld	s0,24(sp)
ffffffe0002002e4:	02010113          	addi	sp,sp,32
ffffffe0002002e8:	00008067          	ret

ffffffe0002002ec <clock_set_next_event>:

void clock_set_next_event() {
ffffffe0002002ec:	fe010113          	addi	sp,sp,-32
ffffffe0002002f0:	00113c23          	sd	ra,24(sp)
ffffffe0002002f4:	00813823          	sd	s0,16(sp)
ffffffe0002002f8:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe0002002fc:	fc9ff0ef          	jal	ffffffe0002002c4 <get_cycles>
ffffffe000200300:	00050713          	mv	a4,a0
ffffffe000200304:	00005797          	auipc	a5,0x5
ffffffe000200308:	cfc78793          	addi	a5,a5,-772 # ffffffe000205000 <TIMECLOCK>
ffffffe00020030c:	0007b783          	ld	a5,0(a5)
ffffffe000200310:	00f707b3          	add	a5,a4,a5
ffffffe000200314:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200318:	fe843503          	ld	a0,-24(s0)
ffffffe00020031c:	21d010ef          	jal	ffffffe000201d38 <sbi_set_timer>
ffffffe000200320:	00000013          	nop
ffffffe000200324:	01813083          	ld	ra,24(sp)
ffffffe000200328:	01013403          	ld	s0,16(sp)
ffffffe00020032c:	02010113          	addi	sp,sp,32
ffffffe000200330:	00008067          	ret

ffffffe000200334 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200334:	fe010113          	addi	sp,sp,-32
ffffffe000200338:	00813c23          	sd	s0,24(sp)
ffffffe00020033c:	02010413          	addi	s0,sp,32
ffffffe000200340:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe000200344:	fe843783          	ld	a5,-24(s0)
ffffffe000200348:	fff78793          	addi	a5,a5,-1
ffffffe00020034c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe000200350:	fe843783          	ld	a5,-24(s0)
ffffffe000200354:	0017d793          	srli	a5,a5,0x1
ffffffe000200358:	fe843703          	ld	a4,-24(s0)
ffffffe00020035c:	00f767b3          	or	a5,a4,a5
ffffffe000200360:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe000200364:	fe843783          	ld	a5,-24(s0)
ffffffe000200368:	0027d793          	srli	a5,a5,0x2
ffffffe00020036c:	fe843703          	ld	a4,-24(s0)
ffffffe000200370:	00f767b3          	or	a5,a4,a5
ffffffe000200374:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe000200378:	fe843783          	ld	a5,-24(s0)
ffffffe00020037c:	0047d793          	srli	a5,a5,0x4
ffffffe000200380:	fe843703          	ld	a4,-24(s0)
ffffffe000200384:	00f767b3          	or	a5,a4,a5
ffffffe000200388:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe00020038c:	fe843783          	ld	a5,-24(s0)
ffffffe000200390:	0087d793          	srli	a5,a5,0x8
ffffffe000200394:	fe843703          	ld	a4,-24(s0)
ffffffe000200398:	00f767b3          	or	a5,a4,a5
ffffffe00020039c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe0002003a0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003a4:	0107d793          	srli	a5,a5,0x10
ffffffe0002003a8:	fe843703          	ld	a4,-24(s0)
ffffffe0002003ac:	00f767b3          	or	a5,a4,a5
ffffffe0002003b0:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe0002003b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b8:	0207d793          	srli	a5,a5,0x20
ffffffe0002003bc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003c0:	00f767b3          	or	a5,a4,a5
ffffffe0002003c4:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe0002003c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003cc:	00178793          	addi	a5,a5,1
}
ffffffe0002003d0:	00078513          	mv	a0,a5
ffffffe0002003d4:	01813403          	ld	s0,24(sp)
ffffffe0002003d8:	02010113          	addi	sp,sp,32
ffffffe0002003dc:	00008067          	ret

ffffffe0002003e0 <buddy_init>:

void buddy_init() {
ffffffe0002003e0:	fd010113          	addi	sp,sp,-48
ffffffe0002003e4:	02113423          	sd	ra,40(sp)
ffffffe0002003e8:	02813023          	sd	s0,32(sp)
ffffffe0002003ec:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe0002003f0:	000087b7          	lui	a5,0x8
ffffffe0002003f4:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe0002003f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003fc:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe000200400:	fe843783          	ld	a5,-24(s0)
ffffffe000200404:	00f777b3          	and	a5,a4,a5
ffffffe000200408:	00078863          	beqz	a5,ffffffe000200418 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe00020040c:	fe843503          	ld	a0,-24(s0)
ffffffe000200410:	f25ff0ef          	jal	ffffffe000200334 <fixsize>
ffffffe000200414:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe000200418:	0000a797          	auipc	a5,0xa
ffffffe00020041c:	c0878793          	addi	a5,a5,-1016 # ffffffe00020a020 <buddy>
ffffffe000200420:	fe843703          	ld	a4,-24(s0)
ffffffe000200424:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200428:	00005797          	auipc	a5,0x5
ffffffe00020042c:	be078793          	addi	a5,a5,-1056 # ffffffe000205008 <free_page_start>
ffffffe000200430:	0007b703          	ld	a4,0(a5)
ffffffe000200434:	0000a797          	auipc	a5,0xa
ffffffe000200438:	bec78793          	addi	a5,a5,-1044 # ffffffe00020a020 <buddy>
ffffffe00020043c:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe000200440:	00005797          	auipc	a5,0x5
ffffffe000200444:	bc878793          	addi	a5,a5,-1080 # ffffffe000205008 <free_page_start>
ffffffe000200448:	0007b703          	ld	a4,0(a5)
ffffffe00020044c:	0000a797          	auipc	a5,0xa
ffffffe000200450:	bd478793          	addi	a5,a5,-1068 # ffffffe00020a020 <buddy>
ffffffe000200454:	0007b783          	ld	a5,0(a5)
ffffffe000200458:	00479793          	slli	a5,a5,0x4
ffffffe00020045c:	00f70733          	add	a4,a4,a5
ffffffe000200460:	00005797          	auipc	a5,0x5
ffffffe000200464:	ba878793          	addi	a5,a5,-1112 # ffffffe000205008 <free_page_start>
ffffffe000200468:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe00020046c:	0000a797          	auipc	a5,0xa
ffffffe000200470:	bb478793          	addi	a5,a5,-1100 # ffffffe00020a020 <buddy>
ffffffe000200474:	0087b703          	ld	a4,8(a5)
ffffffe000200478:	0000a797          	auipc	a5,0xa
ffffffe00020047c:	ba878793          	addi	a5,a5,-1112 # ffffffe00020a020 <buddy>
ffffffe000200480:	0007b783          	ld	a5,0(a5)
ffffffe000200484:	00479793          	slli	a5,a5,0x4
ffffffe000200488:	00078613          	mv	a2,a5
ffffffe00020048c:	00000593          	li	a1,0
ffffffe000200490:	00070513          	mv	a0,a4
ffffffe000200494:	271030ef          	jal	ffffffe000203f04 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe000200498:	0000a797          	auipc	a5,0xa
ffffffe00020049c:	b8878793          	addi	a5,a5,-1144 # ffffffe00020a020 <buddy>
ffffffe0002004a0:	0007b783          	ld	a5,0(a5)
ffffffe0002004a4:	00179793          	slli	a5,a5,0x1
ffffffe0002004a8:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004ac:	fc043c23          	sd	zero,-40(s0)
ffffffe0002004b0:	0500006f          	j	ffffffe000200500 <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe0002004b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002004b8:	00178713          	addi	a4,a5,1
ffffffe0002004bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002004c0:	00f777b3          	and	a5,a4,a5
ffffffe0002004c4:	00079863          	bnez	a5,ffffffe0002004d4 <buddy_init+0xf4>
            node_size /= 2;
ffffffe0002004c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002004cc:	0017d793          	srli	a5,a5,0x1
ffffffe0002004d0:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe0002004d4:	0000a797          	auipc	a5,0xa
ffffffe0002004d8:	b4c78793          	addi	a5,a5,-1204 # ffffffe00020a020 <buddy>
ffffffe0002004dc:	0087b703          	ld	a4,8(a5)
ffffffe0002004e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002004e4:	00379793          	slli	a5,a5,0x3
ffffffe0002004e8:	00f707b3          	add	a5,a4,a5
ffffffe0002004ec:	fe043703          	ld	a4,-32(s0)
ffffffe0002004f0:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002004f8:	00178793          	addi	a5,a5,1
ffffffe0002004fc:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200500:	0000a797          	auipc	a5,0xa
ffffffe000200504:	b2078793          	addi	a5,a5,-1248 # ffffffe00020a020 <buddy>
ffffffe000200508:	0007b783          	ld	a5,0(a5)
ffffffe00020050c:	00179793          	slli	a5,a5,0x1
ffffffe000200510:	fff78793          	addi	a5,a5,-1
ffffffe000200514:	fd843703          	ld	a4,-40(s0)
ffffffe000200518:	f8f76ee3          	bltu	a4,a5,ffffffe0002004b4 <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe00020051c:	fc043823          	sd	zero,-48(s0)
ffffffe000200520:	0180006f          	j	ffffffe000200538 <buddy_init+0x158>
        buddy_alloc(1);
ffffffe000200524:	00100513          	li	a0,1
ffffffe000200528:	1fc000ef          	jal	ffffffe000200724 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe00020052c:	fd043783          	ld	a5,-48(s0)
ffffffe000200530:	00178793          	addi	a5,a5,1
ffffffe000200534:	fcf43823          	sd	a5,-48(s0)
ffffffe000200538:	fd043783          	ld	a5,-48(s0)
ffffffe00020053c:	00c79713          	slli	a4,a5,0xc
ffffffe000200540:	00100793          	li	a5,1
ffffffe000200544:	01f79793          	slli	a5,a5,0x1f
ffffffe000200548:	00f70733          	add	a4,a4,a5
ffffffe00020054c:	00005797          	auipc	a5,0x5
ffffffe000200550:	abc78793          	addi	a5,a5,-1348 # ffffffe000205008 <free_page_start>
ffffffe000200554:	0007b783          	ld	a5,0(a5)
ffffffe000200558:	00078693          	mv	a3,a5
ffffffe00020055c:	04100793          	li	a5,65
ffffffe000200560:	01f79793          	slli	a5,a5,0x1f
ffffffe000200564:	00f687b3          	add	a5,a3,a5
ffffffe000200568:	faf76ee3          	bltu	a4,a5,ffffffe000200524 <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe00020056c:	00004517          	auipc	a0,0x4
ffffffe000200570:	a9450513          	addi	a0,a0,-1388 # ffffffe000204000 <_srodata>
ffffffe000200574:	071030ef          	jal	ffffffe000203de4 <printk>
    return;
ffffffe000200578:	00000013          	nop
}
ffffffe00020057c:	02813083          	ld	ra,40(sp)
ffffffe000200580:	02013403          	ld	s0,32(sp)
ffffffe000200584:	03010113          	addi	sp,sp,48
ffffffe000200588:	00008067          	ret

ffffffe00020058c <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe00020058c:	fc010113          	addi	sp,sp,-64
ffffffe000200590:	02813c23          	sd	s0,56(sp)
ffffffe000200594:	04010413          	addi	s0,sp,64
ffffffe000200598:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe00020059c:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe0002005a0:	00100793          	li	a5,1
ffffffe0002005a4:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe0002005a8:	0000a797          	auipc	a5,0xa
ffffffe0002005ac:	a7878793          	addi	a5,a5,-1416 # ffffffe00020a020 <buddy>
ffffffe0002005b0:	0007b703          	ld	a4,0(a5)
ffffffe0002005b4:	fc843783          	ld	a5,-56(s0)
ffffffe0002005b8:	00f707b3          	add	a5,a4,a5
ffffffe0002005bc:	fff78793          	addi	a5,a5,-1
ffffffe0002005c0:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005c4:	02c0006f          	j	ffffffe0002005f0 <buddy_free+0x64>
        node_size *= 2;
ffffffe0002005c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002005cc:	00179793          	slli	a5,a5,0x1
ffffffe0002005d0:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe0002005d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002005d8:	02078e63          	beqz	a5,ffffffe000200614 <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002005e0:	00178793          	addi	a5,a5,1
ffffffe0002005e4:	0017d793          	srli	a5,a5,0x1
ffffffe0002005e8:	fff78793          	addi	a5,a5,-1
ffffffe0002005ec:	fef43023          	sd	a5,-32(s0)
ffffffe0002005f0:	0000a797          	auipc	a5,0xa
ffffffe0002005f4:	a3078793          	addi	a5,a5,-1488 # ffffffe00020a020 <buddy>
ffffffe0002005f8:	0087b703          	ld	a4,8(a5)
ffffffe0002005fc:	fe043783          	ld	a5,-32(s0)
ffffffe000200600:	00379793          	slli	a5,a5,0x3
ffffffe000200604:	00f707b3          	add	a5,a4,a5
ffffffe000200608:	0007b783          	ld	a5,0(a5)
ffffffe00020060c:	fa079ee3          	bnez	a5,ffffffe0002005c8 <buddy_free+0x3c>
ffffffe000200610:	0080006f          	j	ffffffe000200618 <buddy_free+0x8c>
            break;
ffffffe000200614:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe000200618:	0000a797          	auipc	a5,0xa
ffffffe00020061c:	a0878793          	addi	a5,a5,-1528 # ffffffe00020a020 <buddy>
ffffffe000200620:	0087b703          	ld	a4,8(a5)
ffffffe000200624:	fe043783          	ld	a5,-32(s0)
ffffffe000200628:	00379793          	slli	a5,a5,0x3
ffffffe00020062c:	00f707b3          	add	a5,a4,a5
ffffffe000200630:	fe843703          	ld	a4,-24(s0)
ffffffe000200634:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200638:	0d00006f          	j	ffffffe000200708 <buddy_free+0x17c>
        index = PARENT(index);
ffffffe00020063c:	fe043783          	ld	a5,-32(s0)
ffffffe000200640:	00178793          	addi	a5,a5,1
ffffffe000200644:	0017d793          	srli	a5,a5,0x1
ffffffe000200648:	fff78793          	addi	a5,a5,-1
ffffffe00020064c:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe000200650:	fe843783          	ld	a5,-24(s0)
ffffffe000200654:	00179793          	slli	a5,a5,0x1
ffffffe000200658:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe00020065c:	0000a797          	auipc	a5,0xa
ffffffe000200660:	9c478793          	addi	a5,a5,-1596 # ffffffe00020a020 <buddy>
ffffffe000200664:	0087b703          	ld	a4,8(a5)
ffffffe000200668:	fe043783          	ld	a5,-32(s0)
ffffffe00020066c:	00479793          	slli	a5,a5,0x4
ffffffe000200670:	00878793          	addi	a5,a5,8
ffffffe000200674:	00f707b3          	add	a5,a4,a5
ffffffe000200678:	0007b783          	ld	a5,0(a5)
ffffffe00020067c:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe000200680:	0000a797          	auipc	a5,0xa
ffffffe000200684:	9a078793          	addi	a5,a5,-1632 # ffffffe00020a020 <buddy>
ffffffe000200688:	0087b703          	ld	a4,8(a5)
ffffffe00020068c:	fe043783          	ld	a5,-32(s0)
ffffffe000200690:	00178793          	addi	a5,a5,1
ffffffe000200694:	00479793          	slli	a5,a5,0x4
ffffffe000200698:	00f707b3          	add	a5,a4,a5
ffffffe00020069c:	0007b783          	ld	a5,0(a5)
ffffffe0002006a0:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe0002006a4:	fd843703          	ld	a4,-40(s0)
ffffffe0002006a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002006ac:	00f707b3          	add	a5,a4,a5
ffffffe0002006b0:	fe843703          	ld	a4,-24(s0)
ffffffe0002006b4:	02f71463          	bne	a4,a5,ffffffe0002006dc <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe0002006b8:	0000a797          	auipc	a5,0xa
ffffffe0002006bc:	96878793          	addi	a5,a5,-1688 # ffffffe00020a020 <buddy>
ffffffe0002006c0:	0087b703          	ld	a4,8(a5)
ffffffe0002006c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002006c8:	00379793          	slli	a5,a5,0x3
ffffffe0002006cc:	00f707b3          	add	a5,a4,a5
ffffffe0002006d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002006d4:	00e7b023          	sd	a4,0(a5)
ffffffe0002006d8:	0300006f          	j	ffffffe000200708 <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe0002006dc:	0000a797          	auipc	a5,0xa
ffffffe0002006e0:	94478793          	addi	a5,a5,-1724 # ffffffe00020a020 <buddy>
ffffffe0002006e4:	0087b703          	ld	a4,8(a5)
ffffffe0002006e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002006ec:	00379793          	slli	a5,a5,0x3
ffffffe0002006f0:	00f706b3          	add	a3,a4,a5
ffffffe0002006f4:	fd843703          	ld	a4,-40(s0)
ffffffe0002006f8:	fd043783          	ld	a5,-48(s0)
ffffffe0002006fc:	00e7f463          	bgeu	a5,a4,ffffffe000200704 <buddy_free+0x178>
ffffffe000200700:	00070793          	mv	a5,a4
ffffffe000200704:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200708:	fe043783          	ld	a5,-32(s0)
ffffffe00020070c:	f20798e3          	bnez	a5,ffffffe00020063c <buddy_free+0xb0>
    }
}
ffffffe000200710:	00000013          	nop
ffffffe000200714:	00000013          	nop
ffffffe000200718:	03813403          	ld	s0,56(sp)
ffffffe00020071c:	04010113          	addi	sp,sp,64
ffffffe000200720:	00008067          	ret

ffffffe000200724 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe000200724:	fc010113          	addi	sp,sp,-64
ffffffe000200728:	02113c23          	sd	ra,56(sp)
ffffffe00020072c:	02813823          	sd	s0,48(sp)
ffffffe000200730:	04010413          	addi	s0,sp,64
ffffffe000200734:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe000200738:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe00020073c:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe000200740:	fc843783          	ld	a5,-56(s0)
ffffffe000200744:	00079863          	bnez	a5,ffffffe000200754 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe000200748:	00100793          	li	a5,1
ffffffe00020074c:	fcf43423          	sd	a5,-56(s0)
ffffffe000200750:	0240006f          	j	ffffffe000200774 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe000200754:	fc843783          	ld	a5,-56(s0)
ffffffe000200758:	fff78713          	addi	a4,a5,-1
ffffffe00020075c:	fc843783          	ld	a5,-56(s0)
ffffffe000200760:	00f777b3          	and	a5,a4,a5
ffffffe000200764:	00078863          	beqz	a5,ffffffe000200774 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe000200768:	fc843503          	ld	a0,-56(s0)
ffffffe00020076c:	bc9ff0ef          	jal	ffffffe000200334 <fixsize>
ffffffe000200770:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe000200774:	0000a797          	auipc	a5,0xa
ffffffe000200778:	8ac78793          	addi	a5,a5,-1876 # ffffffe00020a020 <buddy>
ffffffe00020077c:	0087b703          	ld	a4,8(a5)
ffffffe000200780:	fe843783          	ld	a5,-24(s0)
ffffffe000200784:	00379793          	slli	a5,a5,0x3
ffffffe000200788:	00f707b3          	add	a5,a4,a5
ffffffe00020078c:	0007b783          	ld	a5,0(a5)
ffffffe000200790:	fc843703          	ld	a4,-56(s0)
ffffffe000200794:	00e7f663          	bgeu	a5,a4,ffffffe0002007a0 <buddy_alloc+0x7c>
        return 0;
ffffffe000200798:	00000793          	li	a5,0
ffffffe00020079c:	1480006f          	j	ffffffe0002008e4 <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002007a0:	0000a797          	auipc	a5,0xa
ffffffe0002007a4:	88078793          	addi	a5,a5,-1920 # ffffffe00020a020 <buddy>
ffffffe0002007a8:	0007b783          	ld	a5,0(a5)
ffffffe0002007ac:	fef43023          	sd	a5,-32(s0)
ffffffe0002007b0:	05c0006f          	j	ffffffe00020080c <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe0002007b4:	0000a797          	auipc	a5,0xa
ffffffe0002007b8:	86c78793          	addi	a5,a5,-1940 # ffffffe00020a020 <buddy>
ffffffe0002007bc:	0087b703          	ld	a4,8(a5)
ffffffe0002007c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002007c4:	00479793          	slli	a5,a5,0x4
ffffffe0002007c8:	00878793          	addi	a5,a5,8
ffffffe0002007cc:	00f707b3          	add	a5,a4,a5
ffffffe0002007d0:	0007b783          	ld	a5,0(a5)
ffffffe0002007d4:	fc843703          	ld	a4,-56(s0)
ffffffe0002007d8:	00e7ec63          	bltu	a5,a4,ffffffe0002007f0 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe0002007dc:	fe843783          	ld	a5,-24(s0)
ffffffe0002007e0:	00179793          	slli	a5,a5,0x1
ffffffe0002007e4:	00178793          	addi	a5,a5,1
ffffffe0002007e8:	fef43423          	sd	a5,-24(s0)
ffffffe0002007ec:	0140006f          	j	ffffffe000200800 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe0002007f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002007f4:	00178793          	addi	a5,a5,1
ffffffe0002007f8:	00179793          	slli	a5,a5,0x1
ffffffe0002007fc:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200800:	fe043783          	ld	a5,-32(s0)
ffffffe000200804:	0017d793          	srli	a5,a5,0x1
ffffffe000200808:	fef43023          	sd	a5,-32(s0)
ffffffe00020080c:	fe043703          	ld	a4,-32(s0)
ffffffe000200810:	fc843783          	ld	a5,-56(s0)
ffffffe000200814:	faf710e3          	bne	a4,a5,ffffffe0002007b4 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe000200818:	0000a797          	auipc	a5,0xa
ffffffe00020081c:	80878793          	addi	a5,a5,-2040 # ffffffe00020a020 <buddy>
ffffffe000200820:	0087b703          	ld	a4,8(a5)
ffffffe000200824:	fe843783          	ld	a5,-24(s0)
ffffffe000200828:	00379793          	slli	a5,a5,0x3
ffffffe00020082c:	00f707b3          	add	a5,a4,a5
ffffffe000200830:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200834:	fe843783          	ld	a5,-24(s0)
ffffffe000200838:	00178713          	addi	a4,a5,1
ffffffe00020083c:	fe043783          	ld	a5,-32(s0)
ffffffe000200840:	02f70733          	mul	a4,a4,a5
ffffffe000200844:	00009797          	auipc	a5,0x9
ffffffe000200848:	7dc78793          	addi	a5,a5,2012 # ffffffe00020a020 <buddy>
ffffffe00020084c:	0007b783          	ld	a5,0(a5)
ffffffe000200850:	40f707b3          	sub	a5,a4,a5
ffffffe000200854:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe000200858:	0800006f          	j	ffffffe0002008d8 <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe00020085c:	fe843783          	ld	a5,-24(s0)
ffffffe000200860:	00178793          	addi	a5,a5,1
ffffffe000200864:	0017d793          	srli	a5,a5,0x1
ffffffe000200868:	fff78793          	addi	a5,a5,-1
ffffffe00020086c:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200870:	00009797          	auipc	a5,0x9
ffffffe000200874:	7b078793          	addi	a5,a5,1968 # ffffffe00020a020 <buddy>
ffffffe000200878:	0087b703          	ld	a4,8(a5)
ffffffe00020087c:	fe843783          	ld	a5,-24(s0)
ffffffe000200880:	00178793          	addi	a5,a5,1
ffffffe000200884:	00479793          	slli	a5,a5,0x4
ffffffe000200888:	00f707b3          	add	a5,a4,a5
ffffffe00020088c:	0007b603          	ld	a2,0(a5)
ffffffe000200890:	00009797          	auipc	a5,0x9
ffffffe000200894:	79078793          	addi	a5,a5,1936 # ffffffe00020a020 <buddy>
ffffffe000200898:	0087b703          	ld	a4,8(a5)
ffffffe00020089c:	fe843783          	ld	a5,-24(s0)
ffffffe0002008a0:	00479793          	slli	a5,a5,0x4
ffffffe0002008a4:	00878793          	addi	a5,a5,8
ffffffe0002008a8:	00f707b3          	add	a5,a4,a5
ffffffe0002008ac:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe0002008b0:	00009797          	auipc	a5,0x9
ffffffe0002008b4:	77078793          	addi	a5,a5,1904 # ffffffe00020a020 <buddy>
ffffffe0002008b8:	0087b683          	ld	a3,8(a5)
ffffffe0002008bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002008c0:	00379793          	slli	a5,a5,0x3
ffffffe0002008c4:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008c8:	00060793          	mv	a5,a2
ffffffe0002008cc:	00e7f463          	bgeu	a5,a4,ffffffe0002008d4 <buddy_alloc+0x1b0>
ffffffe0002008d0:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe0002008d4:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe0002008d8:	fe843783          	ld	a5,-24(s0)
ffffffe0002008dc:	f80790e3          	bnez	a5,ffffffe00020085c <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe0002008e0:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002008e4:	00078513          	mv	a0,a5
ffffffe0002008e8:	03813083          	ld	ra,56(sp)
ffffffe0002008ec:	03013403          	ld	s0,48(sp)
ffffffe0002008f0:	04010113          	addi	sp,sp,64
ffffffe0002008f4:	00008067          	ret

ffffffe0002008f8 <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe0002008f8:	fd010113          	addi	sp,sp,-48
ffffffe0002008fc:	02113423          	sd	ra,40(sp)
ffffffe000200900:	02813023          	sd	s0,32(sp)
ffffffe000200904:	03010413          	addi	s0,sp,48
ffffffe000200908:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe00020090c:	fd843503          	ld	a0,-40(s0)
ffffffe000200910:	e15ff0ef          	jal	ffffffe000200724 <buddy_alloc>
ffffffe000200914:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200918:	fe843783          	ld	a5,-24(s0)
ffffffe00020091c:	00079663          	bnez	a5,ffffffe000200928 <alloc_pages+0x30>
        return 0;
ffffffe000200920:	00000793          	li	a5,0
ffffffe000200924:	0180006f          	j	ffffffe00020093c <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200928:	fe843783          	ld	a5,-24(s0)
ffffffe00020092c:	00c79713          	slli	a4,a5,0xc
ffffffe000200930:	fff00793          	li	a5,-1
ffffffe000200934:	02579793          	slli	a5,a5,0x25
ffffffe000200938:	00f707b3          	add	a5,a4,a5
}
ffffffe00020093c:	00078513          	mv	a0,a5
ffffffe000200940:	02813083          	ld	ra,40(sp)
ffffffe000200944:	02013403          	ld	s0,32(sp)
ffffffe000200948:	03010113          	addi	sp,sp,48
ffffffe00020094c:	00008067          	ret

ffffffe000200950 <alloc_page>:

void *alloc_page() {
ffffffe000200950:	ff010113          	addi	sp,sp,-16
ffffffe000200954:	00113423          	sd	ra,8(sp)
ffffffe000200958:	00813023          	sd	s0,0(sp)
ffffffe00020095c:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200960:	00100513          	li	a0,1
ffffffe000200964:	f95ff0ef          	jal	ffffffe0002008f8 <alloc_pages>
ffffffe000200968:	00050793          	mv	a5,a0
}
ffffffe00020096c:	00078513          	mv	a0,a5
ffffffe000200970:	00813083          	ld	ra,8(sp)
ffffffe000200974:	00013403          	ld	s0,0(sp)
ffffffe000200978:	01010113          	addi	sp,sp,16
ffffffe00020097c:	00008067          	ret

ffffffe000200980 <free_pages>:

void free_pages(void *va) {
ffffffe000200980:	fe010113          	addi	sp,sp,-32
ffffffe000200984:	00113c23          	sd	ra,24(sp)
ffffffe000200988:	00813823          	sd	s0,16(sp)
ffffffe00020098c:	02010413          	addi	s0,sp,32
ffffffe000200990:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe000200994:	fe843703          	ld	a4,-24(s0)
ffffffe000200998:	00100793          	li	a5,1
ffffffe00020099c:	02579793          	slli	a5,a5,0x25
ffffffe0002009a0:	00f707b3          	add	a5,a4,a5
ffffffe0002009a4:	00c7d793          	srli	a5,a5,0xc
ffffffe0002009a8:	00078513          	mv	a0,a5
ffffffe0002009ac:	be1ff0ef          	jal	ffffffe00020058c <buddy_free>
}
ffffffe0002009b0:	00000013          	nop
ffffffe0002009b4:	01813083          	ld	ra,24(sp)
ffffffe0002009b8:	01013403          	ld	s0,16(sp)
ffffffe0002009bc:	02010113          	addi	sp,sp,32
ffffffe0002009c0:	00008067          	ret

ffffffe0002009c4 <kalloc>:

void *kalloc() {
ffffffe0002009c4:	ff010113          	addi	sp,sp,-16
ffffffe0002009c8:	00113423          	sd	ra,8(sp)
ffffffe0002009cc:	00813023          	sd	s0,0(sp)
ffffffe0002009d0:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe0002009d4:	f7dff0ef          	jal	ffffffe000200950 <alloc_page>
ffffffe0002009d8:	00050793          	mv	a5,a0
}
ffffffe0002009dc:	00078513          	mv	a0,a5
ffffffe0002009e0:	00813083          	ld	ra,8(sp)
ffffffe0002009e4:	00013403          	ld	s0,0(sp)
ffffffe0002009e8:	01010113          	addi	sp,sp,16
ffffffe0002009ec:	00008067          	ret

ffffffe0002009f0 <kfree>:

void kfree(void *addr) {
ffffffe0002009f0:	fe010113          	addi	sp,sp,-32
ffffffe0002009f4:	00113c23          	sd	ra,24(sp)
ffffffe0002009f8:	00813823          	sd	s0,16(sp)
ffffffe0002009fc:	02010413          	addi	s0,sp,32
ffffffe000200a00:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200a04:	fe843503          	ld	a0,-24(s0)
ffffffe000200a08:	f79ff0ef          	jal	ffffffe000200980 <free_pages>

    return;
ffffffe000200a0c:	00000013          	nop
}
ffffffe000200a10:	01813083          	ld	ra,24(sp)
ffffffe000200a14:	01013403          	ld	s0,16(sp)
ffffffe000200a18:	02010113          	addi	sp,sp,32
ffffffe000200a1c:	00008067          	ret

ffffffe000200a20 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200a20:	fd010113          	addi	sp,sp,-48
ffffffe000200a24:	02113423          	sd	ra,40(sp)
ffffffe000200a28:	02813023          	sd	s0,32(sp)
ffffffe000200a2c:	03010413          	addi	s0,sp,48
ffffffe000200a30:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a34:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a38:	fd843703          	ld	a4,-40(s0)
ffffffe000200a3c:	000017b7          	lui	a5,0x1
ffffffe000200a40:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200a44:	00f70733          	add	a4,a4,a5
ffffffe000200a48:	fffff7b7          	lui	a5,0xfffff
ffffffe000200a4c:	00f777b3          	and	a5,a4,a5
ffffffe000200a50:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a54:	01c0006f          	j	ffffffe000200a70 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200a58:	fe843503          	ld	a0,-24(s0)
ffffffe000200a5c:	f95ff0ef          	jal	ffffffe0002009f0 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a60:	fe843703          	ld	a4,-24(s0)
ffffffe000200a64:	000017b7          	lui	a5,0x1
ffffffe000200a68:	00f707b3          	add	a5,a4,a5
ffffffe000200a6c:	fef43423          	sd	a5,-24(s0)
ffffffe000200a70:	fe843703          	ld	a4,-24(s0)
ffffffe000200a74:	000017b7          	lui	a5,0x1
ffffffe000200a78:	00f70733          	add	a4,a4,a5
ffffffe000200a7c:	fd043783          	ld	a5,-48(s0)
ffffffe000200a80:	fce7fce3          	bgeu	a5,a4,ffffffe000200a58 <kfreerange+0x38>
    }
}
ffffffe000200a84:	00000013          	nop
ffffffe000200a88:	00000013          	nop
ffffffe000200a8c:	02813083          	ld	ra,40(sp)
ffffffe000200a90:	02013403          	ld	s0,32(sp)
ffffffe000200a94:	03010113          	addi	sp,sp,48
ffffffe000200a98:	00008067          	ret

ffffffe000200a9c <mm_init>:

void mm_init(void) {
ffffffe000200a9c:	ff010113          	addi	sp,sp,-16
ffffffe000200aa0:	00113423          	sd	ra,8(sp)
ffffffe000200aa4:	00813023          	sd	s0,0(sp)
ffffffe000200aa8:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200aac:	935ff0ef          	jal	ffffffe0002003e0 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200ab0:	00003517          	auipc	a0,0x3
ffffffe000200ab4:	56850513          	addi	a0,a0,1384 # ffffffe000204018 <_srodata+0x18>
ffffffe000200ab8:	32c030ef          	jal	ffffffe000203de4 <printk>
}
ffffffe000200abc:	00000013          	nop
ffffffe000200ac0:	00813083          	ld	ra,8(sp)
ffffffe000200ac4:	00013403          	ld	s0,0(sp)
ffffffe000200ac8:	01010113          	addi	sp,sp,16
ffffffe000200acc:	00008067          	ret

ffffffe000200ad0 <find_vma>:
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr)
{
ffffffe000200ad0:	fd010113          	addi	sp,sp,-48
ffffffe000200ad4:	02813423          	sd	s0,40(sp)
ffffffe000200ad8:	03010413          	addi	s0,sp,48
ffffffe000200adc:	fca43c23          	sd	a0,-40(s0)
ffffffe000200ae0:	fcb43823          	sd	a1,-48(s0)
    // 获取VMA链表头
    struct vm_area_struct *vma = mm->mmap;
ffffffe000200ae4:	fd843783          	ld	a5,-40(s0)
ffffffe000200ae8:	0007b783          	ld	a5,0(a5) # 1000 <PGSIZE>
ffffffe000200aec:	fef43423          	sd	a5,-24(s0)

    // 遍历VMA链表
    while (vma) 
ffffffe000200af0:	0380006f          	j	ffffffe000200b28 <find_vma+0x58>
    {
        // 检查addr是否在当前VMA的范围内
        if (addr >= vma->vm_start && addr < vma->vm_end) 
ffffffe000200af4:	fe843783          	ld	a5,-24(s0)
ffffffe000200af8:	0087b783          	ld	a5,8(a5)
ffffffe000200afc:	fd043703          	ld	a4,-48(s0)
ffffffe000200b00:	00f76e63          	bltu	a4,a5,ffffffe000200b1c <find_vma+0x4c>
ffffffe000200b04:	fe843783          	ld	a5,-24(s0)
ffffffe000200b08:	0107b783          	ld	a5,16(a5)
ffffffe000200b0c:	fd043703          	ld	a4,-48(s0)
ffffffe000200b10:	00f77663          	bgeu	a4,a5,ffffffe000200b1c <find_vma+0x4c>
        {
            return vma; // 找到目标VMA，返回指针
ffffffe000200b14:	fe843783          	ld	a5,-24(s0)
ffffffe000200b18:	01c0006f          	j	ffffffe000200b34 <find_vma+0x64>
        }
        vma = vma->vm_next; // 移动到下一个VMA
ffffffe000200b1c:	fe843783          	ld	a5,-24(s0)
ffffffe000200b20:	0187b783          	ld	a5,24(a5)
ffffffe000200b24:	fef43423          	sd	a5,-24(s0)
    while (vma) 
ffffffe000200b28:	fe843783          	ld	a5,-24(s0)
ffffffe000200b2c:	fc0794e3          	bnez	a5,ffffffe000200af4 <find_vma+0x24>
    }

    // 没有找到匹配的VMA
    return NULL;
ffffffe000200b30:	00000793          	li	a5,0
}
ffffffe000200b34:	00078513          	mv	a0,a5
ffffffe000200b38:	02813403          	ld	s0,40(sp)
ffffffe000200b3c:	03010113          	addi	sp,sp,48
ffffffe000200b40:	00008067          	ret

ffffffe000200b44 <do_mmap>:
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags)
{
ffffffe000200b44:	fa010113          	addi	sp,sp,-96
ffffffe000200b48:	04113c23          	sd	ra,88(sp)
ffffffe000200b4c:	04813823          	sd	s0,80(sp)
ffffffe000200b50:	06010413          	addi	s0,sp,96
ffffffe000200b54:	fca43423          	sd	a0,-56(s0)
ffffffe000200b58:	fcb43023          	sd	a1,-64(s0)
ffffffe000200b5c:	fac43c23          	sd	a2,-72(s0)
ffffffe000200b60:	fad43823          	sd	a3,-80(s0)
ffffffe000200b64:	fae43423          	sd	a4,-88(s0)
ffffffe000200b68:	faf43023          	sd	a5,-96(s0)
    // 1. 分配一个vm_area_struct
    struct vm_area_struct *new_vma=(struct vm_area_struct *)kalloc(sizeof(struct vm_area_struct));
ffffffe000200b6c:	04000513          	li	a0,64
ffffffe000200b70:	e55ff0ef          	jal	ffffffe0002009c4 <kalloc>
ffffffe000200b74:	fca43c23          	sd	a0,-40(s0)
    if(!new_vma)
ffffffe000200b78:	fd843783          	ld	a5,-40(s0)
ffffffe000200b7c:	00079c63          	bnez	a5,ffffffe000200b94 <do_mmap+0x50>
    {
        printk("do_mmap: kalloc failed\n");
ffffffe000200b80:	00003517          	auipc	a0,0x3
ffffffe000200b84:	4b050513          	addi	a0,a0,1200 # ffffffe000204030 <_srodata+0x30>
ffffffe000200b88:	25c030ef          	jal	ffffffe000203de4 <printk>
        return 0;
ffffffe000200b8c:	00000793          	li	a5,0
ffffffe000200b90:	0fc0006f          	j	ffffffe000200c8c <do_mmap+0x148>
    }

    // 2. 初始化new_vma
    new_vma->vm_mm = mm;
ffffffe000200b94:	fd843783          	ld	a5,-40(s0)
ffffffe000200b98:	fc843703          	ld	a4,-56(s0)
ffffffe000200b9c:	00e7b023          	sd	a4,0(a5)
    new_vma->vm_start = addr;
ffffffe000200ba0:	fd843783          	ld	a5,-40(s0)
ffffffe000200ba4:	fc043703          	ld	a4,-64(s0)
ffffffe000200ba8:	00e7b423          	sd	a4,8(a5)
    new_vma->vm_end = addr + len;
ffffffe000200bac:	fc043703          	ld	a4,-64(s0)
ffffffe000200bb0:	fb843783          	ld	a5,-72(s0)
ffffffe000200bb4:	00f70733          	add	a4,a4,a5
ffffffe000200bb8:	fd843783          	ld	a5,-40(s0)
ffffffe000200bbc:	00e7b823          	sd	a4,16(a5)
    new_vma->vm_next = NULL;
ffffffe000200bc0:	fd843783          	ld	a5,-40(s0)
ffffffe000200bc4:	0007bc23          	sd	zero,24(a5)
    new_vma->vm_prev = NULL;
ffffffe000200bc8:	fd843783          	ld	a5,-40(s0)
ffffffe000200bcc:	0207b023          	sd	zero,32(a5)
    new_vma->vm_flags = flags;
ffffffe000200bd0:	fd843783          	ld	a5,-40(s0)
ffffffe000200bd4:	fa043703          	ld	a4,-96(s0)
ffffffe000200bd8:	02e7b423          	sd	a4,40(a5)
    new_vma->vm_pgoff = vm_pgoff;
ffffffe000200bdc:	fd843783          	ld	a5,-40(s0)
ffffffe000200be0:	fb043703          	ld	a4,-80(s0)
ffffffe000200be4:	02e7b823          	sd	a4,48(a5)
    new_vma->vm_filesz = vm_filesz;
ffffffe000200be8:	fd843783          	ld	a5,-40(s0)
ffffffe000200bec:	fa843703          	ld	a4,-88(s0)
ffffffe000200bf0:	02e7bc23          	sd	a4,56(a5)

    // 3. 将new_vma插入到mm->mmap链表中
    struct vm_area_struct *curr = mm->mmap;
ffffffe000200bf4:	fc843783          	ld	a5,-56(s0)
ffffffe000200bf8:	0007b783          	ld	a5,0(a5)
ffffffe000200bfc:	fef43423          	sd	a5,-24(s0)
    struct vm_area_struct *prev = NULL;
ffffffe000200c00:	fe043023          	sd	zero,-32(s0)

    // 找到插入点，链表按vm_start排序
    while(curr && curr->vm_start < addr) 
ffffffe000200c04:	0180006f          	j	ffffffe000200c1c <do_mmap+0xd8>
    {
        prev = curr;
ffffffe000200c08:	fe843783          	ld	a5,-24(s0)
ffffffe000200c0c:	fef43023          	sd	a5,-32(s0)
        curr = curr->vm_next;
ffffffe000200c10:	fe843783          	ld	a5,-24(s0)
ffffffe000200c14:	0187b783          	ld	a5,24(a5)
ffffffe000200c18:	fef43423          	sd	a5,-24(s0)
    while(curr && curr->vm_start < addr) 
ffffffe000200c1c:	fe843783          	ld	a5,-24(s0)
ffffffe000200c20:	00078a63          	beqz	a5,ffffffe000200c34 <do_mmap+0xf0>
ffffffe000200c24:	fe843783          	ld	a5,-24(s0)
ffffffe000200c28:	0087b783          	ld	a5,8(a5)
ffffffe000200c2c:	fc043703          	ld	a4,-64(s0)
ffffffe000200c30:	fce7ece3          	bltu	a5,a4,ffffffe000200c08 <do_mmap+0xc4>
    }

    // 更新new_vma的next和prev
    new_vma->vm_next = curr;
ffffffe000200c34:	fd843783          	ld	a5,-40(s0)
ffffffe000200c38:	fe843703          	ld	a4,-24(s0)
ffffffe000200c3c:	00e7bc23          	sd	a4,24(a5)
    new_vma->vm_prev = prev;
ffffffe000200c40:	fd843783          	ld	a5,-40(s0)
ffffffe000200c44:	fe043703          	ld	a4,-32(s0)
ffffffe000200c48:	02e7b023          	sd	a4,32(a5)
    if(prev) 
ffffffe000200c4c:	fe043783          	ld	a5,-32(s0)
ffffffe000200c50:	00078a63          	beqz	a5,ffffffe000200c64 <do_mmap+0x120>
    {
        prev->vm_next = new_vma;
ffffffe000200c54:	fe043783          	ld	a5,-32(s0)
ffffffe000200c58:	fd843703          	ld	a4,-40(s0)
ffffffe000200c5c:	00e7bc23          	sd	a4,24(a5)
ffffffe000200c60:	0100006f          	j	ffffffe000200c70 <do_mmap+0x12c>
    }else
    {
        mm->mmap = new_vma; // new_vma是链表的第一个节点
ffffffe000200c64:	fc843783          	ld	a5,-56(s0)
ffffffe000200c68:	fd843703          	ld	a4,-40(s0)
ffffffe000200c6c:	00e7b023          	sd	a4,0(a5)
    }
    if(curr)
ffffffe000200c70:	fe843783          	ld	a5,-24(s0)
ffffffe000200c74:	00078863          	beqz	a5,ffffffe000200c84 <do_mmap+0x140>
    {
        curr->vm_prev = new_vma;
ffffffe000200c78:	fe843783          	ld	a5,-24(s0)
ffffffe000200c7c:	fd843703          	ld	a4,-40(s0)
ffffffe000200c80:	02e7b023          	sd	a4,32(a5)
    }

    // 4. 返回新分配区域的起始地址
    return new_vma->vm_start;
ffffffe000200c84:	fd843783          	ld	a5,-40(s0)
ffffffe000200c88:	0087b783          	ld	a5,8(a5)
}
ffffffe000200c8c:	00078513          	mv	a0,a5
ffffffe000200c90:	05813083          	ld	ra,88(sp)
ffffffe000200c94:	05013403          	ld	s0,80(sp)
ffffffe000200c98:	06010113          	addi	sp,sp,96
ffffffe000200c9c:	00008067          	ret

ffffffe000200ca0 <memcpy>:

extern char _sramdisk[];
extern char _sbss[];
extern uint64_t swapper_pg_dir[];

void *memcpy(void *dest, void *src, size_t n) {
ffffffe000200ca0:	fc010113          	addi	sp,sp,-64
ffffffe000200ca4:	02813c23          	sd	s0,56(sp)
ffffffe000200ca8:	04010413          	addi	s0,sp,64
ffffffe000200cac:	fca43c23          	sd	a0,-40(s0)
ffffffe000200cb0:	fcb43823          	sd	a1,-48(s0)
ffffffe000200cb4:	fcc43423          	sd	a2,-56(s0)
    char *d = dest;
ffffffe000200cb8:	fd843783          	ld	a5,-40(s0)
ffffffe000200cbc:	fef43423          	sd	a5,-24(s0)
    char *s = src;
ffffffe000200cc0:	fd043783          	ld	a5,-48(s0)
ffffffe000200cc4:	fef43023          	sd	a5,-32(s0)
    while (n--) {
ffffffe000200cc8:	0240006f          	j	ffffffe000200cec <memcpy+0x4c>
        *(d++) = *(s++);
ffffffe000200ccc:	fe043703          	ld	a4,-32(s0)
ffffffe000200cd0:	00170793          	addi	a5,a4,1
ffffffe000200cd4:	fef43023          	sd	a5,-32(s0)
ffffffe000200cd8:	fe843783          	ld	a5,-24(s0)
ffffffe000200cdc:	00178693          	addi	a3,a5,1
ffffffe000200ce0:	fed43423          	sd	a3,-24(s0)
ffffffe000200ce4:	00074703          	lbu	a4,0(a4)
ffffffe000200ce8:	00e78023          	sb	a4,0(a5)
    while (n--) {
ffffffe000200cec:	fc843783          	ld	a5,-56(s0)
ffffffe000200cf0:	fff78713          	addi	a4,a5,-1
ffffffe000200cf4:	fce43423          	sd	a4,-56(s0)
ffffffe000200cf8:	fc079ae3          	bnez	a5,ffffffe000200ccc <memcpy+0x2c>
    }
    return dest;
ffffffe000200cfc:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200d00:	00078513          	mv	a0,a5
ffffffe000200d04:	03813403          	ld	s0,56(sp)
ffffffe000200d08:	04010113          	addi	sp,sp,64
ffffffe000200d0c:	00008067          	ret

ffffffe000200d10 <load_bin_program>:

void load_bin_program(struct task_struct *task) {
ffffffe000200d10:	fc010113          	addi	sp,sp,-64
ffffffe000200d14:	02113c23          	sd	ra,56(sp)
ffffffe000200d18:	02813823          	sd	s0,48(sp)
ffffffe000200d1c:	04010413          	addi	s0,sp,64
ffffffe000200d20:	fca43423          	sd	a0,-56(s0)
    // 将 uapp 所在的页面映射到每个进程的页表中-------------------------------
    // copy first
    void *user_uapp = alloc_pages(((uint64_t)_sbss-(uint64_t)_sramdisk)/PGSIZE+1);
ffffffe000200d24:	00008717          	auipc	a4,0x8
ffffffe000200d28:	2dc70713          	addi	a4,a4,732 # ffffffe000209000 <_sbss>
ffffffe000200d2c:	00005797          	auipc	a5,0x5
ffffffe000200d30:	2d478793          	addi	a5,a5,724 # ffffffe000206000 <_sramdisk>
ffffffe000200d34:	40f707b3          	sub	a5,a4,a5
ffffffe000200d38:	00c7d793          	srli	a5,a5,0xc
ffffffe000200d3c:	00178793          	addi	a5,a5,1
ffffffe000200d40:	00078513          	mv	a0,a5
ffffffe000200d44:	bb5ff0ef          	jal	ffffffe0002008f8 <alloc_pages>
ffffffe000200d48:	fea43423          	sd	a0,-24(s0)
    uint64_t uapp_size = (uint64_t)_sbss - (uint64_t)_sramdisk;
ffffffe000200d4c:	00008717          	auipc	a4,0x8
ffffffe000200d50:	2b470713          	addi	a4,a4,692 # ffffffe000209000 <_sbss>
ffffffe000200d54:	00005797          	auipc	a5,0x5
ffffffe000200d58:	2ac78793          	addi	a5,a5,684 # ffffffe000206000 <_sramdisk>
ffffffe000200d5c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d60:	fef43023          	sd	a5,-32(s0)
    memcpy(user_uapp,_sramdisk,uapp_size);
ffffffe000200d64:	fe043603          	ld	a2,-32(s0)
ffffffe000200d68:	00005597          	auipc	a1,0x5
ffffffe000200d6c:	29858593          	addi	a1,a1,664 # ffffffe000206000 <_sramdisk>
ffffffe000200d70:	fe843503          	ld	a0,-24(s0)
ffffffe000200d74:	f2dff0ef          	jal	ffffffe000200ca0 <memcpy>

    uint64_t uapp_va = USER_START;
ffffffe000200d78:	fc043c23          	sd	zero,-40(s0)
    uint64_t uapp_pa = (uint64_t)user_uapp - PA2VA_OFFSET;
ffffffe000200d7c:	fe843703          	ld	a4,-24(s0)
ffffffe000200d80:	04100793          	li	a5,65
ffffffe000200d84:	01f79793          	slli	a5,a5,0x1f
ffffffe000200d88:	00f707b3          	add	a5,a4,a5
ffffffe000200d8c:	fcf43823          	sd	a5,-48(s0)
    create_mapping(task->pgd,uapp_va,uapp_pa,uapp_size,PERM_USER_UAPP);
ffffffe000200d90:	fc843783          	ld	a5,-56(s0)
ffffffe000200d94:	0a87b783          	ld	a5,168(a5)
ffffffe000200d98:	01f00713          	li	a4,31
ffffffe000200d9c:	fe043683          	ld	a3,-32(s0)
ffffffe000200da0:	fd043603          	ld	a2,-48(s0)
ffffffe000200da4:	fd843583          	ld	a1,-40(s0)
ffffffe000200da8:	00078513          	mv	a0,a5
ffffffe000200dac:	779010ef          	jal	ffffffe000202d24 <create_mapping>
}
ffffffe000200db0:	00000013          	nop
ffffffe000200db4:	03813083          	ld	ra,56(sp)
ffffffe000200db8:	03013403          	ld	s0,48(sp)
ffffffe000200dbc:	04010113          	addi	sp,sp,64
ffffffe000200dc0:	00008067          	ret

ffffffe000200dc4 <load_elf_program>:

void load_elf_program(struct task_struct *task) {
ffffffe000200dc4:	f8010113          	addi	sp,sp,-128
ffffffe000200dc8:	06113c23          	sd	ra,120(sp)
ffffffe000200dcc:	06813823          	sd	s0,112(sp)
ffffffe000200dd0:	08010413          	addi	s0,sp,128
ffffffe000200dd4:	f8a43423          	sd	a0,-120(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000200dd8:	00005797          	auipc	a5,0x5
ffffffe000200ddc:	22878793          	addi	a5,a5,552 # ffffffe000206000 <_sramdisk>
ffffffe000200de0:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe000200de4:	fd843783          	ld	a5,-40(s0)
ffffffe000200de8:	0207b703          	ld	a4,32(a5)
ffffffe000200dec:	00005797          	auipc	a5,0x5
ffffffe000200df0:	21478793          	addi	a5,a5,532 # ffffffe000206000 <_sramdisk>
ffffffe000200df4:	00f707b3          	add	a5,a4,a5
ffffffe000200df8:	fcf43823          	sd	a5,-48(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200dfc:	fe042623          	sw	zero,-20(s0)
ffffffe000200e00:	1bc0006f          	j	ffffffe000200fbc <load_elf_program+0x1f8>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe000200e04:	fec42703          	lw	a4,-20(s0)
ffffffe000200e08:	00070793          	mv	a5,a4
ffffffe000200e0c:	00379793          	slli	a5,a5,0x3
ffffffe000200e10:	40e787b3          	sub	a5,a5,a4
ffffffe000200e14:	00379793          	slli	a5,a5,0x3
ffffffe000200e18:	00078713          	mv	a4,a5
ffffffe000200e1c:	fd043783          	ld	a5,-48(s0)
ffffffe000200e20:	00e787b3          	add	a5,a5,a4
ffffffe000200e24:	fcf43423          	sd	a5,-56(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000200e28:	fc843783          	ld	a5,-56(s0)
ffffffe000200e2c:	0007a783          	lw	a5,0(a5)
ffffffe000200e30:	00078713          	mv	a4,a5
ffffffe000200e34:	00100793          	li	a5,1
ffffffe000200e38:	16f71c63          	bne	a4,a5,ffffffe000200fb0 <load_elf_program+0x1ec>
            // alloc space and copy content
            uint64_t start_vpg=PGROUNDDOWN(phdr->p_vaddr);
ffffffe000200e3c:	fc843783          	ld	a5,-56(s0)
ffffffe000200e40:	0107b703          	ld	a4,16(a5)
ffffffe000200e44:	fffff7b7          	lui	a5,0xfffff
ffffffe000200e48:	00f777b3          	and	a5,a4,a5
ffffffe000200e4c:	fcf43023          	sd	a5,-64(s0)
            uint64_t end_vpg=PGROUNDUP(phdr->p_vaddr+phdr->p_memsz);
ffffffe000200e50:	fc843783          	ld	a5,-56(s0)
ffffffe000200e54:	0107b703          	ld	a4,16(a5) # fffffffffffff010 <VM_END+0xfffff010>
ffffffe000200e58:	fc843783          	ld	a5,-56(s0)
ffffffe000200e5c:	0287b783          	ld	a5,40(a5)
ffffffe000200e60:	00f70733          	add	a4,a4,a5
ffffffe000200e64:	000017b7          	lui	a5,0x1
ffffffe000200e68:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200e6c:	00f70733          	add	a4,a4,a5
ffffffe000200e70:	fffff7b7          	lui	a5,0xfffff
ffffffe000200e74:	00f777b3          	and	a5,a4,a5
ffffffe000200e78:	faf43c23          	sd	a5,-72(s0)
            uint64_t offset=phdr->p_paddr-start_vpg;
ffffffe000200e7c:	fc843783          	ld	a5,-56(s0)
ffffffe000200e80:	0187b703          	ld	a4,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000200e84:	fc043783          	ld	a5,-64(s0)
ffffffe000200e88:	40f707b3          	sub	a5,a4,a5
ffffffe000200e8c:	faf43823          	sd	a5,-80(s0)
            uint64_t pg_num=(end_vpg-start_vpg)/PGSIZE;
ffffffe000200e90:	fb843703          	ld	a4,-72(s0)
ffffffe000200e94:	fc043783          	ld	a5,-64(s0)
ffffffe000200e98:	40f707b3          	sub	a5,a4,a5
ffffffe000200e9c:	00c7d793          	srli	a5,a5,0xc
ffffffe000200ea0:	faf43423          	sd	a5,-88(s0)
            #define PTE_R  (1 << 1)  // Readable
            #define PTE_W  (1 << 2)  // Writable
            #define PTE_X  (1 << 3)  // Executable
            #define PTE_U  (1 << 4)  // User accessible
            // 权限转换
            uint64_t perm = PTE_V | PTE_U; // 基础权限：有效和用户态访问
ffffffe000200ea4:	01100793          	li	a5,17
ffffffe000200ea8:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_R) perm |= PTE_R; // 可读
ffffffe000200eac:	fc843783          	ld	a5,-56(s0)
ffffffe000200eb0:	0047a783          	lw	a5,4(a5)
ffffffe000200eb4:	0047f793          	andi	a5,a5,4
ffffffe000200eb8:	0007879b          	sext.w	a5,a5
ffffffe000200ebc:	00078863          	beqz	a5,ffffffe000200ecc <load_elf_program+0x108>
ffffffe000200ec0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ec4:	0027e793          	ori	a5,a5,2
ffffffe000200ec8:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_W) perm |= PTE_W; // 可写
ffffffe000200ecc:	fc843783          	ld	a5,-56(s0)
ffffffe000200ed0:	0047a783          	lw	a5,4(a5)
ffffffe000200ed4:	0027f793          	andi	a5,a5,2
ffffffe000200ed8:	0007879b          	sext.w	a5,a5
ffffffe000200edc:	00078863          	beqz	a5,ffffffe000200eec <load_elf_program+0x128>
ffffffe000200ee0:	fe043783          	ld	a5,-32(s0)
ffffffe000200ee4:	0047e793          	ori	a5,a5,4
ffffffe000200ee8:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_X) perm |= PTE_X; // 可执行
ffffffe000200eec:	fc843783          	ld	a5,-56(s0)
ffffffe000200ef0:	0047a783          	lw	a5,4(a5)
ffffffe000200ef4:	0017f793          	andi	a5,a5,1
ffffffe000200ef8:	0007879b          	sext.w	a5,a5
ffffffe000200efc:	00078863          	beqz	a5,ffffffe000200f0c <load_elf_program+0x148>
ffffffe000200f00:	fe043783          	ld	a5,-32(s0)
ffffffe000200f04:	0087e793          	ori	a5,a5,8
ffffffe000200f08:	fef43023          	sd	a5,-32(s0)

            // 为段分配物理页
            void *uapp_mem = alloc_pages(pg_num);
ffffffe000200f0c:	fa843503          	ld	a0,-88(s0)
ffffffe000200f10:	9e9ff0ef          	jal	ffffffe0002008f8 <alloc_pages>
ffffffe000200f14:	faa43023          	sd	a0,-96(s0)
            if (!uapp_mem) {
ffffffe000200f18:	fa043783          	ld	a5,-96(s0)
ffffffe000200f1c:	00079e63          	bnez	a5,ffffffe000200f38 <load_elf_program+0x174>
                printk("Failed to allocate memory for ELF segment %d\n", i);
ffffffe000200f20:	fec42783          	lw	a5,-20(s0)
ffffffe000200f24:	00078593          	mv	a1,a5
ffffffe000200f28:	00003517          	auipc	a0,0x3
ffffffe000200f2c:	12050513          	addi	a0,a0,288 # ffffffe000204048 <_srodata+0x48>
ffffffe000200f30:	6b5020ef          	jal	ffffffe000203de4 <printk>
                return;
ffffffe000200f34:	0a00006f          	j	ffffffe000200fd4 <load_elf_program+0x210>
            }

            // 拷贝段内容
            memcpy((void *)(uapp_mem + offset), (void *)(_sramdisk + phdr->p_offset), phdr->p_filesz);
ffffffe000200f38:	fa043703          	ld	a4,-96(s0)
ffffffe000200f3c:	fb043783          	ld	a5,-80(s0)
ffffffe000200f40:	00f706b3          	add	a3,a4,a5
ffffffe000200f44:	fc843783          	ld	a5,-56(s0)
ffffffe000200f48:	0087b703          	ld	a4,8(a5)
ffffffe000200f4c:	00005797          	auipc	a5,0x5
ffffffe000200f50:	0b478793          	addi	a5,a5,180 # ffffffe000206000 <_sramdisk>
ffffffe000200f54:	00f70733          	add	a4,a4,a5
ffffffe000200f58:	fc843783          	ld	a5,-56(s0)
ffffffe000200f5c:	0207b783          	ld	a5,32(a5)
ffffffe000200f60:	00078613          	mv	a2,a5
ffffffe000200f64:	00070593          	mv	a1,a4
ffffffe000200f68:	00068513          	mv	a0,a3
ffffffe000200f6c:	d35ff0ef          	jal	ffffffe000200ca0 <memcpy>

            // do mapping
            // 映射段到进程的页表
            uint64_t va = start_vpg;
ffffffe000200f70:	fc043783          	ld	a5,-64(s0)
ffffffe000200f74:	f8f43c23          	sd	a5,-104(s0)
            uint64_t pa = (uint64_t)uapp_mem - PA2VA_OFFSET;
ffffffe000200f78:	fa043703          	ld	a4,-96(s0)
ffffffe000200f7c:	04100793          	li	a5,65
ffffffe000200f80:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f84:	00f707b3          	add	a5,a4,a5
ffffffe000200f88:	f8f43823          	sd	a5,-112(s0)
            create_mapping((uint64_t *)task->pgd, va, pa, pg_num * PGSIZE, perm);
ffffffe000200f8c:	f8843783          	ld	a5,-120(s0)
ffffffe000200f90:	0a87b503          	ld	a0,168(a5)
ffffffe000200f94:	fa843783          	ld	a5,-88(s0)
ffffffe000200f98:	00c79793          	slli	a5,a5,0xc
ffffffe000200f9c:	fe043703          	ld	a4,-32(s0)
ffffffe000200fa0:	00078693          	mv	a3,a5
ffffffe000200fa4:	f9043603          	ld	a2,-112(s0)
ffffffe000200fa8:	f9843583          	ld	a1,-104(s0)
ffffffe000200fac:	579010ef          	jal	ffffffe000202d24 <create_mapping>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200fb0:	fec42783          	lw	a5,-20(s0)
ffffffe000200fb4:	0017879b          	addiw	a5,a5,1
ffffffe000200fb8:	fef42623          	sw	a5,-20(s0)
ffffffe000200fbc:	fd843783          	ld	a5,-40(s0)
ffffffe000200fc0:	0387d783          	lhu	a5,56(a5)
ffffffe000200fc4:	0007871b          	sext.w	a4,a5
ffffffe000200fc8:	fec42783          	lw	a5,-20(s0)
ffffffe000200fcc:	0007879b          	sext.w	a5,a5
ffffffe000200fd0:	e2e7cae3          	blt	a5,a4,ffffffe000200e04 <load_elf_program+0x40>

        }
    }
}
ffffffe000200fd4:	07813083          	ld	ra,120(sp)
ffffffe000200fd8:	07013403          	ld	s0,112(sp)
ffffffe000200fdc:	08010113          	addi	sp,sp,128
ffffffe000200fe0:	00008067          	ret

ffffffe000200fe4 <load_program>:

void load_program(struct task_struct *task) {
ffffffe000200fe4:	f9010113          	addi	sp,sp,-112
ffffffe000200fe8:	06113423          	sd	ra,104(sp)
ffffffe000200fec:	06813023          	sd	s0,96(sp)
ffffffe000200ff0:	07010413          	addi	s0,sp,112
ffffffe000200ff4:	f8a43c23          	sd	a0,-104(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000200ff8:	00005797          	auipc	a5,0x5
ffffffe000200ffc:	00878793          	addi	a5,a5,8 # ffffffe000206000 <_sramdisk>
ffffffe000201000:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe000201004:	fd843783          	ld	a5,-40(s0)
ffffffe000201008:	0207b703          	ld	a4,32(a5)
ffffffe00020100c:	00005797          	auipc	a5,0x5
ffffffe000201010:	ff478793          	addi	a5,a5,-12 # ffffffe000206000 <_sramdisk>
ffffffe000201014:	00f707b3          	add	a5,a4,a5
ffffffe000201018:	fcf43823          	sd	a5,-48(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe00020101c:	fe042623          	sw	zero,-20(s0)
ffffffe000201020:	0fc0006f          	j	ffffffe00020111c <load_program+0x138>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe000201024:	fec42703          	lw	a4,-20(s0)
ffffffe000201028:	00070793          	mv	a5,a4
ffffffe00020102c:	00379793          	slli	a5,a5,0x3
ffffffe000201030:	40e787b3          	sub	a5,a5,a4
ffffffe000201034:	00379793          	slli	a5,a5,0x3
ffffffe000201038:	00078713          	mv	a4,a5
ffffffe00020103c:	fd043783          	ld	a5,-48(s0)
ffffffe000201040:	00e787b3          	add	a5,a5,a4
ffffffe000201044:	fcf43423          	sd	a5,-56(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000201048:	fc843783          	ld	a5,-56(s0)
ffffffe00020104c:	0007a783          	lw	a5,0(a5)
ffffffe000201050:	00078713          	mv	a4,a5
ffffffe000201054:	00100793          	li	a5,1
ffffffe000201058:	0af71c63          	bne	a4,a5,ffffffe000201110 <load_program+0x12c>
            // 获取段信息
            uint64_t addr=phdr->p_vaddr;
ffffffe00020105c:	fc843783          	ld	a5,-56(s0)
ffffffe000201060:	0107b783          	ld	a5,16(a5)
ffffffe000201064:	fcf43023          	sd	a5,-64(s0)
            uint64_t len=phdr->p_memsz;
ffffffe000201068:	fc843783          	ld	a5,-56(s0)
ffffffe00020106c:	0287b783          	ld	a5,40(a5)
ffffffe000201070:	faf43c23          	sd	a5,-72(s0)
            uint64_t offset=phdr->p_offset; 
ffffffe000201074:	fc843783          	ld	a5,-56(s0)
ffffffe000201078:	0087b783          	ld	a5,8(a5)
ffffffe00020107c:	faf43823          	sd	a5,-80(s0)
            uint64_t filesz=phdr->p_filesz;
ffffffe000201080:	fc843783          	ld	a5,-56(s0)
ffffffe000201084:	0207b783          	ld	a5,32(a5)
ffffffe000201088:	faf43423          	sd	a5,-88(s0)

            // 权限转换
            uint64_t vma_flags=0;
ffffffe00020108c:	fe043023          	sd	zero,-32(s0)
            if (phdr->p_flags & PF_R) vma_flags |= VM_READ; // 可读
ffffffe000201090:	fc843783          	ld	a5,-56(s0)
ffffffe000201094:	0047a783          	lw	a5,4(a5)
ffffffe000201098:	0047f793          	andi	a5,a5,4
ffffffe00020109c:	0007879b          	sext.w	a5,a5
ffffffe0002010a0:	00078863          	beqz	a5,ffffffe0002010b0 <load_program+0xcc>
ffffffe0002010a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002010a8:	0027e793          	ori	a5,a5,2
ffffffe0002010ac:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_W) vma_flags |= VM_WRITE; // 可写
ffffffe0002010b0:	fc843783          	ld	a5,-56(s0)
ffffffe0002010b4:	0047a783          	lw	a5,4(a5)
ffffffe0002010b8:	0027f793          	andi	a5,a5,2
ffffffe0002010bc:	0007879b          	sext.w	a5,a5
ffffffe0002010c0:	00078863          	beqz	a5,ffffffe0002010d0 <load_program+0xec>
ffffffe0002010c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002010c8:	0047e793          	ori	a5,a5,4
ffffffe0002010cc:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_X) vma_flags |= VM_EXEC; // 可执行
ffffffe0002010d0:	fc843783          	ld	a5,-56(s0)
ffffffe0002010d4:	0047a783          	lw	a5,4(a5)
ffffffe0002010d8:	0017f793          	andi	a5,a5,1
ffffffe0002010dc:	0007879b          	sext.w	a5,a5
ffffffe0002010e0:	00078863          	beqz	a5,ffffffe0002010f0 <load_program+0x10c>
ffffffe0002010e4:	fe043783          	ld	a5,-32(s0)
ffffffe0002010e8:	0087e793          	ori	a5,a5,8
ffffffe0002010ec:	fef43023          	sd	a5,-32(s0)

            do_mmap(&task->mm,addr,len,offset,filesz,vma_flags);
ffffffe0002010f0:	f9843783          	ld	a5,-104(s0)
ffffffe0002010f4:	0b078513          	addi	a0,a5,176
ffffffe0002010f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002010fc:	fa843703          	ld	a4,-88(s0)
ffffffe000201100:	fb043683          	ld	a3,-80(s0)
ffffffe000201104:	fb843603          	ld	a2,-72(s0)
ffffffe000201108:	fc043583          	ld	a1,-64(s0)
ffffffe00020110c:	a39ff0ef          	jal	ffffffe000200b44 <do_mmap>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000201110:	fec42783          	lw	a5,-20(s0)
ffffffe000201114:	0017879b          	addiw	a5,a5,1
ffffffe000201118:	fef42623          	sw	a5,-20(s0)
ffffffe00020111c:	fd843783          	ld	a5,-40(s0)
ffffffe000201120:	0387d783          	lhu	a5,56(a5)
ffffffe000201124:	0007871b          	sext.w	a4,a5
ffffffe000201128:	fec42783          	lw	a5,-20(s0)
ffffffe00020112c:	0007879b          	sext.w	a5,a5
ffffffe000201130:	eee7cae3          	blt	a5,a4,ffffffe000201024 <load_program+0x40>
        }
    }

    // user stack
    do_mmap(&task->mm,USER_END-PGSIZE,PGSIZE,0,0,VM_READ|VM_WRITE|VM_ANON);
ffffffe000201134:	f9843783          	ld	a5,-104(s0)
ffffffe000201138:	0b078513          	addi	a0,a5,176
ffffffe00020113c:	00700793          	li	a5,7
ffffffe000201140:	00000713          	li	a4,0
ffffffe000201144:	00000693          	li	a3,0
ffffffe000201148:	00001637          	lui	a2,0x1
ffffffe00020114c:	040005b7          	lui	a1,0x4000
ffffffe000201150:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201154:	00c59593          	slli	a1,a1,0xc
ffffffe000201158:	9edff0ef          	jal	ffffffe000200b44 <do_mmap>
}
ffffffe00020115c:	00000013          	nop
ffffffe000201160:	06813083          	ld	ra,104(sp)
ffffffe000201164:	06013403          	ld	s0,96(sp)
ffffffe000201168:	07010113          	addi	sp,sp,112
ffffffe00020116c:	00008067          	ret

ffffffe000201170 <task_init>:

void task_init() {
ffffffe000201170:	fc010113          	addi	sp,sp,-64
ffffffe000201174:	02113c23          	sd	ra,56(sp)
ffffffe000201178:	02813823          	sd	s0,48(sp)
ffffffe00020117c:	02913423          	sd	s1,40(sp)
ffffffe000201180:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe000201184:	7e800513          	li	a0,2024
ffffffe000201188:	4dd020ef          	jal	ffffffe000203e64 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个4Kib物理页
    idle=(struct task_struct *)kalloc();
ffffffe00020118c:	839ff0ef          	jal	ffffffe0002009c4 <kalloc>
ffffffe000201190:	00050713          	mv	a4,a0
ffffffe000201194:	00009797          	auipc	a5,0x9
ffffffe000201198:	e7478793          	addi	a5,a5,-396 # ffffffe00020a008 <idle>
ffffffe00020119c:	00e7b023          	sd	a4,0(a5)
    if (!idle) {
ffffffe0002011a0:	00009797          	auipc	a5,0x9
ffffffe0002011a4:	e6878793          	addi	a5,a5,-408 # ffffffe00020a008 <idle>
ffffffe0002011a8:	0007b783          	ld	a5,0(a5)
ffffffe0002011ac:	00079a63          	bnez	a5,ffffffe0002011c0 <task_init+0x50>
        // 如果内存分配失败，则退出
        printk("Failed to allocate memory for idle task\n");
ffffffe0002011b0:	00003517          	auipc	a0,0x3
ffffffe0002011b4:	ec850513          	addi	a0,a0,-312 # ffffffe000204078 <_srodata+0x78>
ffffffe0002011b8:	42d020ef          	jal	ffffffe000203de4 <printk>
        return;
ffffffe0002011bc:	4980006f          	j	ffffffe000201654 <task_init+0x4e4>
    }
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state=TASK_RUNNING;
ffffffe0002011c0:	00009797          	auipc	a5,0x9
ffffffe0002011c4:	e4878793          	addi	a5,a5,-440 # ffffffe00020a008 <idle>
ffffffe0002011c8:	0007b783          	ld	a5,0(a5)
ffffffe0002011cc:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter=0;
ffffffe0002011d0:	00009797          	auipc	a5,0x9
ffffffe0002011d4:	e3878793          	addi	a5,a5,-456 # ffffffe00020a008 <idle>
ffffffe0002011d8:	0007b783          	ld	a5,0(a5)
ffffffe0002011dc:	0007b423          	sd	zero,8(a5)
    idle->priority=0;
ffffffe0002011e0:	00009797          	auipc	a5,0x9
ffffffe0002011e4:	e2878793          	addi	a5,a5,-472 # ffffffe00020a008 <idle>
ffffffe0002011e8:	0007b783          	ld	a5,0(a5)
ffffffe0002011ec:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid=0;
ffffffe0002011f0:	00009797          	auipc	a5,0x9
ffffffe0002011f4:	e1878793          	addi	a5,a5,-488 # ffffffe00020a008 <idle>
ffffffe0002011f8:	0007b783          	ld	a5,0(a5)
ffffffe0002011fc:	0007bc23          	sd	zero,24(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current=idle;
ffffffe000201200:	00009797          	auipc	a5,0x9
ffffffe000201204:	e0878793          	addi	a5,a5,-504 # ffffffe00020a008 <idle>
ffffffe000201208:	0007b703          	ld	a4,0(a5)
ffffffe00020120c:	00009797          	auipc	a5,0x9
ffffffe000201210:	e0478793          	addi	a5,a5,-508 # ffffffe00020a010 <current>
ffffffe000201214:	00e7b023          	sd	a4,0(a5)
    task[0]=idle;
ffffffe000201218:	00009797          	auipc	a5,0x9
ffffffe00020121c:	df078793          	addi	a5,a5,-528 # ffffffe00020a008 <idle>
ffffffe000201220:	0007b703          	ld	a4,0(a5)
ffffffe000201224:	00009797          	auipc	a5,0x9
ffffffe000201228:	e0c78793          	addi	a5,a5,-500 # ffffffe00020a030 <task>
ffffffe00020122c:	00e7b023          	sd	a4,0(a5)
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    // for(int i=1;i<NR_TASKS;i++)
    for(int i=1;i<nr_tasks;i++)    // 初始化1个进程
ffffffe000201230:	00100793          	li	a5,1
ffffffe000201234:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201238:	3f80006f          	j	ffffffe000201630 <task_init+0x4c0>
    {
        task[i]=(struct task_struct *)kalloc();
ffffffe00020123c:	f88ff0ef          	jal	ffffffe0002009c4 <kalloc>
ffffffe000201240:	00050693          	mv	a3,a0
ffffffe000201244:	00009717          	auipc	a4,0x9
ffffffe000201248:	dec70713          	addi	a4,a4,-532 # ffffffe00020a030 <task>
ffffffe00020124c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201250:	00379793          	slli	a5,a5,0x3
ffffffe000201254:	00f707b3          	add	a5,a4,a5
ffffffe000201258:	00d7b023          	sd	a3,0(a5)
        if (!task[i]) {
ffffffe00020125c:	00009717          	auipc	a4,0x9
ffffffe000201260:	dd470713          	addi	a4,a4,-556 # ffffffe00020a030 <task>
ffffffe000201264:	fdc42783          	lw	a5,-36(s0)
ffffffe000201268:	00379793          	slli	a5,a5,0x3
ffffffe00020126c:	00f707b3          	add	a5,a4,a5
ffffffe000201270:	0007b783          	ld	a5,0(a5)
ffffffe000201274:	00079e63          	bnez	a5,ffffffe000201290 <task_init+0x120>
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d\n", i);
ffffffe000201278:	fdc42783          	lw	a5,-36(s0)
ffffffe00020127c:	00078593          	mv	a1,a5
ffffffe000201280:	00003517          	auipc	a0,0x3
ffffffe000201284:	e2850513          	addi	a0,a0,-472 # ffffffe0002040a8 <_srodata+0xa8>
ffffffe000201288:	35d020ef          	jal	ffffffe000203de4 <printk>
            return;
ffffffe00020128c:	3c80006f          	j	ffffffe000201654 <task_init+0x4e4>
        }
        task[i]->state=TASK_RUNNING;
ffffffe000201290:	00009717          	auipc	a4,0x9
ffffffe000201294:	da070713          	addi	a4,a4,-608 # ffffffe00020a030 <task>
ffffffe000201298:	fdc42783          	lw	a5,-36(s0)
ffffffe00020129c:	00379793          	slli	a5,a5,0x3
ffffffe0002012a0:	00f707b3          	add	a5,a4,a5
ffffffe0002012a4:	0007b783          	ld	a5,0(a5)
ffffffe0002012a8:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe0002012ac:	00009717          	auipc	a4,0x9
ffffffe0002012b0:	d8470713          	addi	a4,a4,-636 # ffffffe00020a030 <task>
ffffffe0002012b4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012b8:	00379793          	slli	a5,a5,0x3
ffffffe0002012bc:	00f707b3          	add	a5,a4,a5
ffffffe0002012c0:	0007b783          	ld	a5,0(a5)
ffffffe0002012c4:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX - PRIORITY_MIN + 1)+PRIORITY_MIN;
ffffffe0002012c8:	3e1020ef          	jal	ffffffe000203ea8 <rand>
ffffffe0002012cc:	00050793          	mv	a5,a0
ffffffe0002012d0:	00078713          	mv	a4,a5
ffffffe0002012d4:	00a00793          	li	a5,10
ffffffe0002012d8:	02f767bb          	remw	a5,a4,a5
ffffffe0002012dc:	0007879b          	sext.w	a5,a5
ffffffe0002012e0:	0017879b          	addiw	a5,a5,1
ffffffe0002012e4:	0007869b          	sext.w	a3,a5
ffffffe0002012e8:	00009717          	auipc	a4,0x9
ffffffe0002012ec:	d4870713          	addi	a4,a4,-696 # ffffffe00020a030 <task>
ffffffe0002012f0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012f4:	00379793          	slli	a5,a5,0x3
ffffffe0002012f8:	00f707b3          	add	a5,a4,a5
ffffffe0002012fc:	0007b783          	ld	a5,0(a5)
ffffffe000201300:	00068713          	mv	a4,a3
ffffffe000201304:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe000201308:	00009717          	auipc	a4,0x9
ffffffe00020130c:	d2870713          	addi	a4,a4,-728 # ffffffe00020a030 <task>
ffffffe000201310:	fdc42783          	lw	a5,-36(s0)
ffffffe000201314:	00379793          	slli	a5,a5,0x3
ffffffe000201318:	00f707b3          	add	a5,a4,a5
ffffffe00020131c:	0007b783          	ld	a5,0(a5)
ffffffe000201320:	fdc42703          	lw	a4,-36(s0)
ffffffe000201324:	00e7bc23          	sd	a4,24(a5)

        task[i]->thread.ra=(uint64_t)__dummy;
ffffffe000201328:	00009717          	auipc	a4,0x9
ffffffe00020132c:	d0870713          	addi	a4,a4,-760 # ffffffe00020a030 <task>
ffffffe000201330:	fdc42783          	lw	a5,-36(s0)
ffffffe000201334:	00379793          	slli	a5,a5,0x3
ffffffe000201338:	00f707b3          	add	a5,a4,a5
ffffffe00020133c:	0007b783          	ld	a5,0(a5)
ffffffe000201340:	fffff717          	auipc	a4,0xfffff
ffffffe000201344:	ea070713          	addi	a4,a4,-352 # ffffffe0002001e0 <__dummy>
ffffffe000201348:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe00020134c:	00009717          	auipc	a4,0x9
ffffffe000201350:	ce470713          	addi	a4,a4,-796 # ffffffe00020a030 <task>
ffffffe000201354:	fdc42783          	lw	a5,-36(s0)
ffffffe000201358:	00379793          	slli	a5,a5,0x3
ffffffe00020135c:	00f707b3          	add	a5,a4,a5
ffffffe000201360:	0007b783          	ld	a5,0(a5)
ffffffe000201364:	00078693          	mv	a3,a5
ffffffe000201368:	00009717          	auipc	a4,0x9
ffffffe00020136c:	cc870713          	addi	a4,a4,-824 # ffffffe00020a030 <task>
ffffffe000201370:	fdc42783          	lw	a5,-36(s0)
ffffffe000201374:	00379793          	slli	a5,a5,0x3
ffffffe000201378:	00f707b3          	add	a5,a4,a5
ffffffe00020137c:	0007b783          	ld	a5,0(a5)
ffffffe000201380:	00001737          	lui	a4,0x1
ffffffe000201384:	00e68733          	add	a4,a3,a4
ffffffe000201388:	02e7b423          	sd	a4,40(a5)

        // lab5 ------------------------------------
        task[i]->mm.mmap=NULL;
ffffffe00020138c:	00009717          	auipc	a4,0x9
ffffffe000201390:	ca470713          	addi	a4,a4,-860 # ffffffe00020a030 <task>
ffffffe000201394:	fdc42783          	lw	a5,-36(s0)
ffffffe000201398:	00379793          	slli	a5,a5,0x3
ffffffe00020139c:	00f707b3          	add	a5,a4,a5
ffffffe0002013a0:	0007b783          	ld	a5,0(a5)
ffffffe0002013a4:	0a07b823          	sd	zero,176(a5)
        // -----------------------------------------

        // lab4 ---------------------------------------------------------
        
        // 对于每个进程，创建属于它自己的页表----------------------------------
        task[i]->pgd = (uint64_t *)alloc_page();
ffffffe0002013a8:	00009717          	auipc	a4,0x9
ffffffe0002013ac:	c8870713          	addi	a4,a4,-888 # ffffffe00020a030 <task>
ffffffe0002013b0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013b4:	00379793          	slli	a5,a5,0x3
ffffffe0002013b8:	00f707b3          	add	a5,a4,a5
ffffffe0002013bc:	0007b483          	ld	s1,0(a5)
ffffffe0002013c0:	d90ff0ef          	jal	ffffffe000200950 <alloc_page>
ffffffe0002013c4:	00050793          	mv	a5,a0
ffffffe0002013c8:	0af4b423          	sd	a5,168(s1)
        if (!task[i]->pgd) {
ffffffe0002013cc:	00009717          	auipc	a4,0x9
ffffffe0002013d0:	c6470713          	addi	a4,a4,-924 # ffffffe00020a030 <task>
ffffffe0002013d4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013d8:	00379793          	slli	a5,a5,0x3
ffffffe0002013dc:	00f707b3          	add	a5,a4,a5
ffffffe0002013e0:	0007b783          	ld	a5,0(a5)
ffffffe0002013e4:	0a87b783          	ld	a5,168(a5)
ffffffe0002013e8:	00079e63          	bnez	a5,ffffffe000201404 <task_init+0x294>
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d's page directory\n", i);
ffffffe0002013ec:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013f0:	00078593          	mv	a1,a5
ffffffe0002013f4:	00003517          	auipc	a0,0x3
ffffffe0002013f8:	cdc50513          	addi	a0,a0,-804 # ffffffe0002040d0 <_srodata+0xd0>
ffffffe0002013fc:	1e9020ef          	jal	ffffffe000203de4 <printk>
            return;
ffffffe000201400:	2540006f          	j	ffffffe000201654 <task_init+0x4e4>
        }
        // 将内核页表 swapper_pg_dir 复制到每个进程的页表中
        memcpy((void *)task[i]->pgd,(void *)swapper_pg_dir,PGSIZE);
ffffffe000201404:	00009717          	auipc	a4,0x9
ffffffe000201408:	c2c70713          	addi	a4,a4,-980 # ffffffe00020a030 <task>
ffffffe00020140c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201410:	00379793          	slli	a5,a5,0x3
ffffffe000201414:	00f707b3          	add	a5,a4,a5
ffffffe000201418:	0007b783          	ld	a5,0(a5)
ffffffe00020141c:	0a87b783          	ld	a5,168(a5)
ffffffe000201420:	00001637          	lui	a2,0x1
ffffffe000201424:	0000b597          	auipc	a1,0xb
ffffffe000201428:	bdc58593          	addi	a1,a1,-1060 # ffffffe00020c000 <swapper_pg_dir>
ffffffe00020142c:	00078513          	mv	a0,a5
ffffffe000201430:	871ff0ef          	jal	ffffffe000200ca0 <memcpy>
        // 映射到进程的页表中
        // uint64_t user_stack_va = USER_END - PGSIZE;
        // uint64_t user_stack_pa = (uint64_t)user_stack - PA2VA_OFFSET;
        // create_mapping(task[i]->pgd,user_stack_va,user_stack_pa,PGSIZE,PERM_USER_USTACK);

        Elf64_Ehdr *ehdr = (Elf64_Ehdr*)_sramdisk;
ffffffe000201434:	00005797          	auipc	a5,0x5
ffffffe000201438:	bcc78793          	addi	a5,a5,-1076 # ffffffe000206000 <_sramdisk>
ffffffe00020143c:	fcf43823          	sd	a5,-48(s0)

        // check magic number
        if ((ehdr->e_ident[0]  == 0x7f &&ehdr->e_ident[1]  == 0x45 &&ehdr->e_ident[2]  == 0x4c &&
ffffffe000201440:	fd043783          	ld	a5,-48(s0)
ffffffe000201444:	0007c783          	lbu	a5,0(a5)
ffffffe000201448:	00078713          	mv	a4,a5
ffffffe00020144c:	07f00793          	li	a5,127
ffffffe000201450:	12f71e63          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
ffffffe000201454:	fd043783          	ld	a5,-48(s0)
ffffffe000201458:	0017c783          	lbu	a5,1(a5)
ffffffe00020145c:	00078713          	mv	a4,a5
ffffffe000201460:	04500793          	li	a5,69
ffffffe000201464:	12f71463          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
ffffffe000201468:	fd043783          	ld	a5,-48(s0)
ffffffe00020146c:	0027c783          	lbu	a5,2(a5)
ffffffe000201470:	00078713          	mv	a4,a5
ffffffe000201474:	04c00793          	li	a5,76
ffffffe000201478:	10f71a63          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe00020147c:	fd043783          	ld	a5,-48(s0)
ffffffe000201480:	0037c783          	lbu	a5,3(a5)
        if ((ehdr->e_ident[0]  == 0x7f &&ehdr->e_ident[1]  == 0x45 &&ehdr->e_ident[2]  == 0x4c &&
ffffffe000201484:	00078713          	mv	a4,a5
ffffffe000201488:	04600793          	li	a5,70
ffffffe00020148c:	10f71063          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe000201490:	fd043783          	ld	a5,-48(s0)
ffffffe000201494:	0047c783          	lbu	a5,4(a5)
ffffffe000201498:	00078713          	mv	a4,a5
ffffffe00020149c:	00200793          	li	a5,2
ffffffe0002014a0:	0ef71663          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
ffffffe0002014a4:	fd043783          	ld	a5,-48(s0)
ffffffe0002014a8:	0057c783          	lbu	a5,5(a5)
ffffffe0002014ac:	00078713          	mv	a4,a5
ffffffe0002014b0:	00100793          	li	a5,1
ffffffe0002014b4:	0cf71c63          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe0002014b8:	fd043783          	ld	a5,-48(s0)
ffffffe0002014bc:	0067c783          	lbu	a5,6(a5)
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe0002014c0:	00078713          	mv	a4,a5
ffffffe0002014c4:	00100793          	li	a5,1
ffffffe0002014c8:	0cf71263          	bne	a4,a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe0002014cc:	fd043783          	ld	a5,-48(s0)
ffffffe0002014d0:	0077c783          	lbu	a5,7(a5)
ffffffe0002014d4:	0a079c63          	bnez	a5,ffffffe00020158c <task_init+0x41c>
ffffffe0002014d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002014dc:	0087c783          	lbu	a5,8(a5)
ffffffe0002014e0:	0a079663          	bnez	a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe0002014e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002014e8:	0097c783          	lbu	a5,9(a5)
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe0002014ec:	0a079063          	bnez	a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe0002014f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002014f4:	00a7c783          	lbu	a5,10(a5)
ffffffe0002014f8:	08079a63          	bnez	a5,ffffffe00020158c <task_init+0x41c>
ffffffe0002014fc:	fd043783          	ld	a5,-48(s0)
ffffffe000201500:	00b7c783          	lbu	a5,11(a5)
ffffffe000201504:	08079463          	bnez	a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe000201508:	fd043783          	ld	a5,-48(s0)
ffffffe00020150c:	00c7c783          	lbu	a5,12(a5)
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe000201510:	06079e63          	bnez	a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe000201514:	fd043783          	ld	a5,-48(s0)
ffffffe000201518:	00d7c783          	lbu	a5,13(a5)
ffffffe00020151c:	06079863          	bnez	a5,ffffffe00020158c <task_init+0x41c>
ffffffe000201520:	fd043783          	ld	a5,-48(s0)
ffffffe000201524:	00e7c783          	lbu	a5,14(a5)
ffffffe000201528:	06079263          	bnez	a5,ffffffe00020158c <task_init+0x41c>
            ehdr->e_ident[15] == 0x00)) 
ffffffe00020152c:	fd043783          	ld	a5,-48(s0)
ffffffe000201530:	00f7c783          	lbu	a5,15(a5)
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe000201534:	04079c63          	bnez	a5,ffffffe00020158c <task_init+0x41c>
        {
            printk("elf\n");
ffffffe000201538:	00003517          	auipc	a0,0x3
ffffffe00020153c:	bd050513          	addi	a0,a0,-1072 # ffffffe000204108 <_srodata+0x108>
ffffffe000201540:	0a5020ef          	jal	ffffffe000203de4 <printk>
            // load_elf_program(task[i]);
            load_program(task[i]);  // vma
ffffffe000201544:	00009717          	auipc	a4,0x9
ffffffe000201548:	aec70713          	addi	a4,a4,-1300 # ffffffe00020a030 <task>
ffffffe00020154c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201550:	00379793          	slli	a5,a5,0x3
ffffffe000201554:	00f707b3          	add	a5,a4,a5
ffffffe000201558:	0007b783          	ld	a5,0(a5)
ffffffe00020155c:	00078513          	mv	a0,a5
ffffffe000201560:	a85ff0ef          	jal	ffffffe000200fe4 <load_program>
            task[i]->thread.sepc = ehdr->e_entry;
ffffffe000201564:	00009717          	auipc	a4,0x9
ffffffe000201568:	acc70713          	addi	a4,a4,-1332 # ffffffe00020a030 <task>
ffffffe00020156c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201570:	00379793          	slli	a5,a5,0x3
ffffffe000201574:	00f707b3          	add	a5,a4,a5
ffffffe000201578:	0007b783          	ld	a5,0(a5)
ffffffe00020157c:	fd043703          	ld	a4,-48(s0)
ffffffe000201580:	01873703          	ld	a4,24(a4)
ffffffe000201584:	08e7b823          	sd	a4,144(a5)
ffffffe000201588:	02c0006f          	j	ffffffe0002015b4 <task_init+0x444>
        }else
        {
            printk("bin\n");
ffffffe00020158c:	00003517          	auipc	a0,0x3
ffffffe000201590:	b8450513          	addi	a0,a0,-1148 # ffffffe000204110 <_srodata+0x110>
ffffffe000201594:	051020ef          	jal	ffffffe000203de4 <printk>
            // load_bin_program(task[i]);
            // 1.将 sepc 设置为 USER_START U-Mode程序入口地址
            task[i]->thread.sepc = USER_START;
ffffffe000201598:	00009717          	auipc	a4,0x9
ffffffe00020159c:	a9870713          	addi	a4,a4,-1384 # ffffffe00020a030 <task>
ffffffe0002015a0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002015a4:	00379793          	slli	a5,a5,0x3
ffffffe0002015a8:	00f707b3          	add	a5,a4,a5
ffffffe0002015ac:	0007b783          	ld	a5,0(a5)
ffffffe0002015b0:	0807b823          	sd	zero,144(a5)
        }
        

        // 2.set sstatus 
        uint64_t set_sstatus=0;
ffffffe0002015b4:	fc043423          	sd	zero,-56(s0)
        // SPP（使得 sret 返回至 U-Mode）--- bit[8]=0
        set_sstatus = set_sstatus & 0xfffffffffffffeff; 
ffffffe0002015b8:	fc843783          	ld	a5,-56(s0)
ffffffe0002015bc:	eff7f793          	andi	a5,a5,-257
ffffffe0002015c0:	fcf43423          	sd	a5,-56(s0)
        // SPIE（sret 之后开启中断）--- bit[5]=1
        set_sstatus = set_sstatus | (1<<5);
ffffffe0002015c4:	fc843783          	ld	a5,-56(s0)
ffffffe0002015c8:	0207e793          	ori	a5,a5,32
ffffffe0002015cc:	fcf43423          	sd	a5,-56(s0)
        // SUM（S-Mode 可以访问 User 页面）--- bit[18]=1
        set_sstatus = set_sstatus | (1<<18);        
ffffffe0002015d0:	fc843703          	ld	a4,-56(s0)
ffffffe0002015d4:	000407b7          	lui	a5,0x40
ffffffe0002015d8:	00f767b3          	or	a5,a4,a5
ffffffe0002015dc:	fcf43423          	sd	a5,-56(s0)
        task[i]->thread.sstatus = set_sstatus;
ffffffe0002015e0:	00009717          	auipc	a4,0x9
ffffffe0002015e4:	a5070713          	addi	a4,a4,-1456 # ffffffe00020a030 <task>
ffffffe0002015e8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002015ec:	00379793          	slli	a5,a5,0x3
ffffffe0002015f0:	00f707b3          	add	a5,a4,a5
ffffffe0002015f4:	0007b783          	ld	a5,0(a5) # 40000 <PGSIZE+0x3f000>
ffffffe0002015f8:	fc843703          	ld	a4,-56(s0)
ffffffe0002015fc:	08e7bc23          	sd	a4,152(a5)
        // 3.sscratch 设置为 U-Mode 的 sp，其值为 USER_END
        task[i]->thread.sscratch = USER_END;
ffffffe000201600:	00009717          	auipc	a4,0x9
ffffffe000201604:	a3070713          	addi	a4,a4,-1488 # ffffffe00020a030 <task>
ffffffe000201608:	fdc42783          	lw	a5,-36(s0)
ffffffe00020160c:	00379793          	slli	a5,a5,0x3
ffffffe000201610:	00f707b3          	add	a5,a4,a5
ffffffe000201614:	0007b783          	ld	a5,0(a5)
ffffffe000201618:	00100713          	li	a4,1
ffffffe00020161c:	02671713          	slli	a4,a4,0x26
ffffffe000201620:	0ae7b023          	sd	a4,160(a5)
    for(int i=1;i<nr_tasks;i++)    // 初始化1个进程
ffffffe000201624:	fdc42783          	lw	a5,-36(s0)
ffffffe000201628:	0017879b          	addiw	a5,a5,1
ffffffe00020162c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201630:	00004797          	auipc	a5,0x4
ffffffe000201634:	9e078793          	addi	a5,a5,-1568 # ffffffe000205010 <nr_tasks>
ffffffe000201638:	0007a703          	lw	a4,0(a5)
ffffffe00020163c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201640:	0007879b          	sext.w	a5,a5
ffffffe000201644:	bee7cce3          	blt	a5,a4,ffffffe00020123c <task_init+0xcc>
        
        // ----------------------------------------------------------------------------
    }
    
    printk("...task_init done!\n");
ffffffe000201648:	00003517          	auipc	a0,0x3
ffffffe00020164c:	ad050513          	addi	a0,a0,-1328 # ffffffe000204118 <_srodata+0x118>
ffffffe000201650:	794020ef          	jal	ffffffe000203de4 <printk>
}
ffffffe000201654:	03813083          	ld	ra,56(sp)
ffffffe000201658:	03013403          	ld	s0,48(sp)
ffffffe00020165c:	02813483          	ld	s1,40(sp)
ffffffe000201660:	04010113          	addi	sp,sp,64
ffffffe000201664:	00008067          	ret

ffffffe000201668 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000201668:	fd010113          	addi	sp,sp,-48
ffffffe00020166c:	02113423          	sd	ra,40(sp)
ffffffe000201670:	02813023          	sd	s0,32(sp)
ffffffe000201674:	03010413          	addi	s0,sp,48
    printk("dummy\n");
ffffffe000201678:	00003517          	auipc	a0,0x3
ffffffe00020167c:	ab850513          	addi	a0,a0,-1352 # ffffffe000204130 <_srodata+0x130>
ffffffe000201680:	764020ef          	jal	ffffffe000203de4 <printk>
    uint64_t MOD = 1000000007;
ffffffe000201684:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000201688:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe00020168c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000201690:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000201694:	fff00793          	li	a5,-1
ffffffe000201698:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe00020169c:	fe442783          	lw	a5,-28(s0)
ffffffe0002016a0:	0007871b          	sext.w	a4,a5
ffffffe0002016a4:	fff00793          	li	a5,-1
ffffffe0002016a8:	00f70e63          	beq	a4,a5,ffffffe0002016c4 <dummy+0x5c>
ffffffe0002016ac:	00009797          	auipc	a5,0x9
ffffffe0002016b0:	96478793          	addi	a5,a5,-1692 # ffffffe00020a010 <current>
ffffffe0002016b4:	0007b783          	ld	a5,0(a5)
ffffffe0002016b8:	0087b703          	ld	a4,8(a5)
ffffffe0002016bc:	fe442783          	lw	a5,-28(s0)
ffffffe0002016c0:	fcf70ee3          	beq	a4,a5,ffffffe00020169c <dummy+0x34>
ffffffe0002016c4:	00009797          	auipc	a5,0x9
ffffffe0002016c8:	94c78793          	addi	a5,a5,-1716 # ffffffe00020a010 <current>
ffffffe0002016cc:	0007b783          	ld	a5,0(a5)
ffffffe0002016d0:	0087b783          	ld	a5,8(a5)
ffffffe0002016d4:	fc0784e3          	beqz	a5,ffffffe00020169c <dummy+0x34>
            if (current->counter == 1) {
ffffffe0002016d8:	00009797          	auipc	a5,0x9
ffffffe0002016dc:	93878793          	addi	a5,a5,-1736 # ffffffe00020a010 <current>
ffffffe0002016e0:	0007b783          	ld	a5,0(a5)
ffffffe0002016e4:	0087b703          	ld	a4,8(a5)
ffffffe0002016e8:	00100793          	li	a5,1
ffffffe0002016ec:	00f71e63          	bne	a4,a5,ffffffe000201708 <dummy+0xa0>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe0002016f0:	00009797          	auipc	a5,0x9
ffffffe0002016f4:	92078793          	addi	a5,a5,-1760 # ffffffe00020a010 <current>
ffffffe0002016f8:	0007b783          	ld	a5,0(a5)
ffffffe0002016fc:	0087b703          	ld	a4,8(a5)
ffffffe000201700:	fff70713          	addi	a4,a4,-1
ffffffe000201704:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000201708:	00009797          	auipc	a5,0x9
ffffffe00020170c:	90878793          	addi	a5,a5,-1784 # ffffffe00020a010 <current>
ffffffe000201710:	0007b783          	ld	a5,0(a5)
ffffffe000201714:	0087b783          	ld	a5,8(a5)
ffffffe000201718:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe00020171c:	fe843783          	ld	a5,-24(s0)
ffffffe000201720:	00178713          	addi	a4,a5,1
ffffffe000201724:	fd843783          	ld	a5,-40(s0)
ffffffe000201728:	02f777b3          	remu	a5,a4,a5
ffffffe00020172c:	fef43423          	sd	a5,-24(s0)
            printk(BLUE"[PID = %d] is running. auto_inc_local_var = %d\n"CLEAR, current->pid, auto_inc_local_var);
ffffffe000201730:	00009797          	auipc	a5,0x9
ffffffe000201734:	8e078793          	addi	a5,a5,-1824 # ffffffe00020a010 <current>
ffffffe000201738:	0007b783          	ld	a5,0(a5)
ffffffe00020173c:	0187b783          	ld	a5,24(a5)
ffffffe000201740:	fe843603          	ld	a2,-24(s0)
ffffffe000201744:	00078593          	mv	a1,a5
ffffffe000201748:	00003517          	auipc	a0,0x3
ffffffe00020174c:	9f050513          	addi	a0,a0,-1552 # ffffffe000204138 <_srodata+0x138>
ffffffe000201750:	694020ef          	jal	ffffffe000203de4 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000201754:	f49ff06f          	j	ffffffe00020169c <dummy+0x34>

ffffffe000201758 <switch_to>:
    }
}

/* 线程切换入口函数 */
void switch_to(struct task_struct *next)
{
ffffffe000201758:	fd010113          	addi	sp,sp,-48
ffffffe00020175c:	02113423          	sd	ra,40(sp)
ffffffe000201760:	02813023          	sd	s0,32(sp)
ffffffe000201764:	03010413          	addi	s0,sp,48
ffffffe000201768:	fca43c23          	sd	a0,-40(s0)
    // YOUR CODE HERE
    if(current==next)
ffffffe00020176c:	00009797          	auipc	a5,0x9
ffffffe000201770:	8a478793          	addi	a5,a5,-1884 # ffffffe00020a010 <current>
ffffffe000201774:	0007b783          	ld	a5,0(a5)
ffffffe000201778:	fd843703          	ld	a4,-40(s0)
ffffffe00020177c:	06f70063          	beq	a4,a5,ffffffe0002017dc <switch_to+0x84>
    {
        return;
    }else
    {
        printk(YELLOW"\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,next->pid,next->priority,next->counter);
ffffffe000201780:	fd843783          	ld	a5,-40(s0)
ffffffe000201784:	0187b703          	ld	a4,24(a5)
ffffffe000201788:	fd843783          	ld	a5,-40(s0)
ffffffe00020178c:	0107b603          	ld	a2,16(a5)
ffffffe000201790:	fd843783          	ld	a5,-40(s0)
ffffffe000201794:	0087b783          	ld	a5,8(a5)
ffffffe000201798:	00078693          	mv	a3,a5
ffffffe00020179c:	00070593          	mv	a1,a4
ffffffe0002017a0:	00003517          	auipc	a0,0x3
ffffffe0002017a4:	9d850513          	addi	a0,a0,-1576 # ffffffe000204178 <_srodata+0x178>
ffffffe0002017a8:	63c020ef          	jal	ffffffe000203de4 <printk>
        struct task_struct *temp=current;
ffffffe0002017ac:	00009797          	auipc	a5,0x9
ffffffe0002017b0:	86478793          	addi	a5,a5,-1948 # ffffffe00020a010 <current>
ffffffe0002017b4:	0007b783          	ld	a5,0(a5)
ffffffe0002017b8:	fef43423          	sd	a5,-24(s0)
        current=next;
ffffffe0002017bc:	00009797          	auipc	a5,0x9
ffffffe0002017c0:	85478793          	addi	a5,a5,-1964 # ffffffe00020a010 <current>
ffffffe0002017c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002017c8:	00e7b023          	sd	a4,0(a5)
        __switch_to(temp,next);  //调用 __switch_to 函数进行线程切换
ffffffe0002017cc:	fd843583          	ld	a1,-40(s0)
ffffffe0002017d0:	fe843503          	ld	a0,-24(s0)
ffffffe0002017d4:	a1dfe0ef          	jal	ffffffe0002001f0 <__switch_to>
        // printk("ok\n");
    }
    return;
ffffffe0002017d8:	0080006f          	j	ffffffe0002017e0 <switch_to+0x88>
        return;
ffffffe0002017dc:	00000013          	nop
}
ffffffe0002017e0:	02813083          	ld	ra,40(sp)
ffffffe0002017e4:	02013403          	ld	s0,32(sp)
ffffffe0002017e8:	03010113          	addi	sp,sp,48
ffffffe0002017ec:	00008067          	ret

ffffffe0002017f0 <do_timer>:

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer()
{
ffffffe0002017f0:	ff010113          	addi	sp,sp,-16
ffffffe0002017f4:	00113423          	sd	ra,8(sp)
ffffffe0002017f8:	00813023          	sd	s0,0(sp)
ffffffe0002017fc:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE
    if(current==idle||current->counter<=0)
ffffffe000201800:	00009797          	auipc	a5,0x9
ffffffe000201804:	81078793          	addi	a5,a5,-2032 # ffffffe00020a010 <current>
ffffffe000201808:	0007b703          	ld	a4,0(a5)
ffffffe00020180c:	00008797          	auipc	a5,0x8
ffffffe000201810:	7fc78793          	addi	a5,a5,2044 # ffffffe00020a008 <idle>
ffffffe000201814:	0007b783          	ld	a5,0(a5)
ffffffe000201818:	00f70c63          	beq	a4,a5,ffffffe000201830 <do_timer+0x40>
ffffffe00020181c:	00008797          	auipc	a5,0x8
ffffffe000201820:	7f478793          	addi	a5,a5,2036 # ffffffe00020a010 <current>
ffffffe000201824:	0007b783          	ld	a5,0(a5)
ffffffe000201828:	0087b783          	ld	a5,8(a5)
ffffffe00020182c:	00079663          	bnez	a5,ffffffe000201838 <do_timer+0x48>
    {
        schedule();
ffffffe000201830:	05c000ef          	jal	ffffffe00020188c <schedule>
        }else
        {
            schedule();
        }
    }
    return;
ffffffe000201834:	0480006f          	j	ffffffe00020187c <do_timer+0x8c>
        current->counter=current->counter-1;
ffffffe000201838:	00008797          	auipc	a5,0x8
ffffffe00020183c:	7d878793          	addi	a5,a5,2008 # ffffffe00020a010 <current>
ffffffe000201840:	0007b783          	ld	a5,0(a5)
ffffffe000201844:	0087b703          	ld	a4,8(a5)
ffffffe000201848:	00008797          	auipc	a5,0x8
ffffffe00020184c:	7c878793          	addi	a5,a5,1992 # ffffffe00020a010 <current>
ffffffe000201850:	0007b783          	ld	a5,0(a5)
ffffffe000201854:	fff70713          	addi	a4,a4,-1
ffffffe000201858:	00e7b423          	sd	a4,8(a5)
        if(current->counter>0)
ffffffe00020185c:	00008797          	auipc	a5,0x8
ffffffe000201860:	7b478793          	addi	a5,a5,1972 # ffffffe00020a010 <current>
ffffffe000201864:	0007b783          	ld	a5,0(a5)
ffffffe000201868:	0087b783          	ld	a5,8(a5)
ffffffe00020186c:	00079663          	bnez	a5,ffffffe000201878 <do_timer+0x88>
            schedule();
ffffffe000201870:	01c000ef          	jal	ffffffe00020188c <schedule>
    return;
ffffffe000201874:	0080006f          	j	ffffffe00020187c <do_timer+0x8c>
            return;
ffffffe000201878:	00000013          	nop
}
ffffffe00020187c:	00813083          	ld	ra,8(sp)
ffffffe000201880:	00013403          	ld	s0,0(sp)
ffffffe000201884:	01010113          	addi	sp,sp,16
ffffffe000201888:	00008067          	ret

ffffffe00020188c <schedule>:

/* 调度程序，选择出下一个运行的线程 */
void schedule()
{
ffffffe00020188c:	fe010113          	addi	sp,sp,-32
ffffffe000201890:	00113c23          	sd	ra,24(sp)
ffffffe000201894:	00813823          	sd	s0,16(sp)
ffffffe000201898:	02010413          	addi	s0,sp,32
    int i;
    // 调度时选择 counter 最大的线程运行
    int max_index=0;
ffffffe00020189c:	fe042423          	sw	zero,-24(s0)
    int max_counter=0;
ffffffe0002018a0:	fe042223          	sw	zero,-28(s0)
    // for(i=1;i<NR_TASKS;i++)
    for(i=1;i<nr_tasks;i++)
ffffffe0002018a4:	00100793          	li	a5,1
ffffffe0002018a8:	fef42623          	sw	a5,-20(s0)
ffffffe0002018ac:	0e80006f          	j	ffffffe000201994 <schedule+0x108>
    {
        if(task[i]->counter>max_counter&&task[i]->state==TASK_RUNNING)
ffffffe0002018b0:	00008717          	auipc	a4,0x8
ffffffe0002018b4:	78070713          	addi	a4,a4,1920 # ffffffe00020a030 <task>
ffffffe0002018b8:	fec42783          	lw	a5,-20(s0)
ffffffe0002018bc:	00379793          	slli	a5,a5,0x3
ffffffe0002018c0:	00f707b3          	add	a5,a4,a5
ffffffe0002018c4:	0007b783          	ld	a5,0(a5)
ffffffe0002018c8:	0087b703          	ld	a4,8(a5)
ffffffe0002018cc:	fe442783          	lw	a5,-28(s0)
ffffffe0002018d0:	04e7f863          	bgeu	a5,a4,ffffffe000201920 <schedule+0x94>
ffffffe0002018d4:	00008717          	auipc	a4,0x8
ffffffe0002018d8:	75c70713          	addi	a4,a4,1884 # ffffffe00020a030 <task>
ffffffe0002018dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002018e0:	00379793          	slli	a5,a5,0x3
ffffffe0002018e4:	00f707b3          	add	a5,a4,a5
ffffffe0002018e8:	0007b783          	ld	a5,0(a5)
ffffffe0002018ec:	0007b783          	ld	a5,0(a5)
ffffffe0002018f0:	02079863          	bnez	a5,ffffffe000201920 <schedule+0x94>
        {
            max_index=i;
ffffffe0002018f4:	fec42783          	lw	a5,-20(s0)
ffffffe0002018f8:	fef42423          	sw	a5,-24(s0)
            max_counter=task[i]->counter;
ffffffe0002018fc:	00008717          	auipc	a4,0x8
ffffffe000201900:	73470713          	addi	a4,a4,1844 # ffffffe00020a030 <task>
ffffffe000201904:	fec42783          	lw	a5,-20(s0)
ffffffe000201908:	00379793          	slli	a5,a5,0x3
ffffffe00020190c:	00f707b3          	add	a5,a4,a5
ffffffe000201910:	0007b783          	ld	a5,0(a5)
ffffffe000201914:	0087b783          	ld	a5,8(a5)
ffffffe000201918:	fef42223          	sw	a5,-28(s0)
ffffffe00020191c:	06c0006f          	j	ffffffe000201988 <schedule+0xfc>
        }else if(task[i]->counter==max_counter) // 即优先级越高，运行的时间越长，且越先运行
ffffffe000201920:	00008717          	auipc	a4,0x8
ffffffe000201924:	71070713          	addi	a4,a4,1808 # ffffffe00020a030 <task>
ffffffe000201928:	fec42783          	lw	a5,-20(s0)
ffffffe00020192c:	00379793          	slli	a5,a5,0x3
ffffffe000201930:	00f707b3          	add	a5,a4,a5
ffffffe000201934:	0007b783          	ld	a5,0(a5)
ffffffe000201938:	0087b703          	ld	a4,8(a5)
ffffffe00020193c:	fe442783          	lw	a5,-28(s0)
ffffffe000201940:	04f71463          	bne	a4,a5,ffffffe000201988 <schedule+0xfc>
        {
            if(task[i]->priority>task[max_index]->priority)
ffffffe000201944:	00008717          	auipc	a4,0x8
ffffffe000201948:	6ec70713          	addi	a4,a4,1772 # ffffffe00020a030 <task>
ffffffe00020194c:	fec42783          	lw	a5,-20(s0)
ffffffe000201950:	00379793          	slli	a5,a5,0x3
ffffffe000201954:	00f707b3          	add	a5,a4,a5
ffffffe000201958:	0007b783          	ld	a5,0(a5)
ffffffe00020195c:	0107b703          	ld	a4,16(a5)
ffffffe000201960:	00008697          	auipc	a3,0x8
ffffffe000201964:	6d068693          	addi	a3,a3,1744 # ffffffe00020a030 <task>
ffffffe000201968:	fe842783          	lw	a5,-24(s0)
ffffffe00020196c:	00379793          	slli	a5,a5,0x3
ffffffe000201970:	00f687b3          	add	a5,a3,a5
ffffffe000201974:	0007b783          	ld	a5,0(a5)
ffffffe000201978:	0107b783          	ld	a5,16(a5)
ffffffe00020197c:	00e7f663          	bgeu	a5,a4,ffffffe000201988 <schedule+0xfc>
            {
                max_index=i;
ffffffe000201980:	fec42783          	lw	a5,-20(s0)
ffffffe000201984:	fef42423          	sw	a5,-24(s0)
    for(i=1;i<nr_tasks;i++)
ffffffe000201988:	fec42783          	lw	a5,-20(s0)
ffffffe00020198c:	0017879b          	addiw	a5,a5,1
ffffffe000201990:	fef42623          	sw	a5,-20(s0)
ffffffe000201994:	00003797          	auipc	a5,0x3
ffffffe000201998:	67c78793          	addi	a5,a5,1660 # ffffffe000205010 <nr_tasks>
ffffffe00020199c:	0007a703          	lw	a4,0(a5)
ffffffe0002019a0:	fec42783          	lw	a5,-20(s0)
ffffffe0002019a4:	0007879b          	sext.w	a5,a5
ffffffe0002019a8:	f0e7c4e3          	blt	a5,a4,ffffffe0002018b0 <schedule+0x24>
        }
    }

    // next=task[choice];
    // 如果所有线程 counter 都为 0，则令所有线程 counter = priority
    bool all_zero=true;
ffffffe0002019ac:	00100793          	li	a5,1
ffffffe0002019b0:	fef401a3          	sb	a5,-29(s0)
    // for(i=1;i<NR_TASKS;i++)
    for(i=1;i<nr_tasks;i++)
ffffffe0002019b4:	00100793          	li	a5,1
ffffffe0002019b8:	fef42623          	sw	a5,-20(s0)
ffffffe0002019bc:	0380006f          	j	ffffffe0002019f4 <schedule+0x168>
    {
        if(task[i]->counter!=0)
ffffffe0002019c0:	00008717          	auipc	a4,0x8
ffffffe0002019c4:	67070713          	addi	a4,a4,1648 # ffffffe00020a030 <task>
ffffffe0002019c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019cc:	00379793          	slli	a5,a5,0x3
ffffffe0002019d0:	00f707b3          	add	a5,a4,a5
ffffffe0002019d4:	0007b783          	ld	a5,0(a5)
ffffffe0002019d8:	0087b783          	ld	a5,8(a5)
ffffffe0002019dc:	00078663          	beqz	a5,ffffffe0002019e8 <schedule+0x15c>
        {
            all_zero=0;
ffffffe0002019e0:	fe0401a3          	sb	zero,-29(s0)
            break;
ffffffe0002019e4:	0280006f          	j	ffffffe000201a0c <schedule+0x180>
    for(i=1;i<nr_tasks;i++)
ffffffe0002019e8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019ec:	0017879b          	addiw	a5,a5,1
ffffffe0002019f0:	fef42623          	sw	a5,-20(s0)
ffffffe0002019f4:	00003797          	auipc	a5,0x3
ffffffe0002019f8:	61c78793          	addi	a5,a5,1564 # ffffffe000205010 <nr_tasks>
ffffffe0002019fc:	0007a703          	lw	a4,0(a5)
ffffffe000201a00:	fec42783          	lw	a5,-20(s0)
ffffffe000201a04:	0007879b          	sext.w	a5,a5
ffffffe000201a08:	fae7cce3          	blt	a5,a4,ffffffe0002019c0 <schedule+0x134>
        }
    }
    if(all_zero)
ffffffe000201a0c:	fe344783          	lbu	a5,-29(s0)
ffffffe000201a10:	0ff7f793          	zext.b	a5,a5
ffffffe000201a14:	0c078863          	beqz	a5,ffffffe000201ae4 <schedule+0x258>
    {
        printk("\n");
ffffffe000201a18:	00002517          	auipc	a0,0x2
ffffffe000201a1c:	7a050513          	addi	a0,a0,1952 # ffffffe0002041b8 <_srodata+0x1b8>
ffffffe000201a20:	3c4020ef          	jal	ffffffe000203de4 <printk>
        // for(i=1;i<NR_TASKS;i++)
        for(i=1;i<nr_tasks;i++)
ffffffe000201a24:	00100793          	li	a5,1
ffffffe000201a28:	fef42623          	sw	a5,-20(s0)
ffffffe000201a2c:	0980006f          	j	ffffffe000201ac4 <schedule+0x238>
        {
            task[i]->counter=task[i]->priority;
ffffffe000201a30:	00008717          	auipc	a4,0x8
ffffffe000201a34:	60070713          	addi	a4,a4,1536 # ffffffe00020a030 <task>
ffffffe000201a38:	fec42783          	lw	a5,-20(s0)
ffffffe000201a3c:	00379793          	slli	a5,a5,0x3
ffffffe000201a40:	00f707b3          	add	a5,a4,a5
ffffffe000201a44:	0007b703          	ld	a4,0(a5)
ffffffe000201a48:	00008697          	auipc	a3,0x8
ffffffe000201a4c:	5e868693          	addi	a3,a3,1512 # ffffffe00020a030 <task>
ffffffe000201a50:	fec42783          	lw	a5,-20(s0)
ffffffe000201a54:	00379793          	slli	a5,a5,0x3
ffffffe000201a58:	00f687b3          	add	a5,a3,a5
ffffffe000201a5c:	0007b783          	ld	a5,0(a5)
ffffffe000201a60:	01073703          	ld	a4,16(a4)
ffffffe000201a64:	00e7b423          	sd	a4,8(a5)
            printk(PURPLE"SET [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,i,task[i]->priority,task[i]->counter);
ffffffe000201a68:	00008717          	auipc	a4,0x8
ffffffe000201a6c:	5c870713          	addi	a4,a4,1480 # ffffffe00020a030 <task>
ffffffe000201a70:	fec42783          	lw	a5,-20(s0)
ffffffe000201a74:	00379793          	slli	a5,a5,0x3
ffffffe000201a78:	00f707b3          	add	a5,a4,a5
ffffffe000201a7c:	0007b783          	ld	a5,0(a5)
ffffffe000201a80:	0107b603          	ld	a2,16(a5)
ffffffe000201a84:	00008717          	auipc	a4,0x8
ffffffe000201a88:	5ac70713          	addi	a4,a4,1452 # ffffffe00020a030 <task>
ffffffe000201a8c:	fec42783          	lw	a5,-20(s0)
ffffffe000201a90:	00379793          	slli	a5,a5,0x3
ffffffe000201a94:	00f707b3          	add	a5,a4,a5
ffffffe000201a98:	0007b783          	ld	a5,0(a5)
ffffffe000201a9c:	0087b703          	ld	a4,8(a5)
ffffffe000201aa0:	fec42783          	lw	a5,-20(s0)
ffffffe000201aa4:	00070693          	mv	a3,a4
ffffffe000201aa8:	00078593          	mv	a1,a5
ffffffe000201aac:	00002517          	auipc	a0,0x2
ffffffe000201ab0:	71450513          	addi	a0,a0,1812 # ffffffe0002041c0 <_srodata+0x1c0>
ffffffe000201ab4:	330020ef          	jal	ffffffe000203de4 <printk>
        for(i=1;i<nr_tasks;i++)
ffffffe000201ab8:	fec42783          	lw	a5,-20(s0)
ffffffe000201abc:	0017879b          	addiw	a5,a5,1
ffffffe000201ac0:	fef42623          	sw	a5,-20(s0)
ffffffe000201ac4:	00003797          	auipc	a5,0x3
ffffffe000201ac8:	54c78793          	addi	a5,a5,1356 # ffffffe000205010 <nr_tasks>
ffffffe000201acc:	0007a703          	lw	a4,0(a5)
ffffffe000201ad0:	fec42783          	lw	a5,-20(s0)
ffffffe000201ad4:	0007879b          	sext.w	a5,a5
ffffffe000201ad8:	f4e7cce3          	blt	a5,a4,ffffffe000201a30 <schedule+0x1a4>
        }
        schedule();     // 设置完后需要重新进行调度
ffffffe000201adc:	db1ff0ef          	jal	ffffffe00020188c <schedule>
        // 最后通过 switch_to 切换到下一个线程
        // printk("sssswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",task[max_index]->pid,task[max_index]->priority,task[max_index]->counter);
        switch_to(task[max_index]);
    }

    return;
ffffffe000201ae0:	0280006f          	j	ffffffe000201b08 <schedule+0x27c>
        switch_to(task[max_index]);
ffffffe000201ae4:	00008717          	auipc	a4,0x8
ffffffe000201ae8:	54c70713          	addi	a4,a4,1356 # ffffffe00020a030 <task>
ffffffe000201aec:	fe842783          	lw	a5,-24(s0)
ffffffe000201af0:	00379793          	slli	a5,a5,0x3
ffffffe000201af4:	00f707b3          	add	a5,a4,a5
ffffffe000201af8:	0007b783          	ld	a5,0(a5)
ffffffe000201afc:	00078513          	mv	a0,a5
ffffffe000201b00:	c59ff0ef          	jal	ffffffe000201758 <switch_to>
    return;
ffffffe000201b04:	00000013          	nop
ffffffe000201b08:	01813083          	ld	ra,24(sp)
ffffffe000201b0c:	01013403          	ld	s0,16(sp)
ffffffe000201b10:	02010113          	addi	sp,sp,32
ffffffe000201b14:	00008067          	ret

ffffffe000201b18 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201b18:	f8010113          	addi	sp,sp,-128
ffffffe000201b1c:	06813c23          	sd	s0,120(sp)
ffffffe000201b20:	06913823          	sd	s1,112(sp)
ffffffe000201b24:	07213423          	sd	s2,104(sp)
ffffffe000201b28:	07313023          	sd	s3,96(sp)
ffffffe000201b2c:	08010413          	addi	s0,sp,128
ffffffe000201b30:	faa43c23          	sd	a0,-72(s0)
ffffffe000201b34:	fab43823          	sd	a1,-80(s0)
ffffffe000201b38:	fac43423          	sd	a2,-88(s0)
ffffffe000201b3c:	fad43023          	sd	a3,-96(s0)
ffffffe000201b40:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201b44:	f8f43823          	sd	a5,-112(s0)
ffffffe000201b48:	f9043423          	sd	a6,-120(s0)
ffffffe000201b4c:	f9143023          	sd	a7,-128(s0)
    struct sbiret result;   //用 sbiret 来接受两个返回值
    
    __asm__ volatile ( 
ffffffe000201b50:	fb843e03          	ld	t3,-72(s0)
ffffffe000201b54:	fb043e83          	ld	t4,-80(s0)
ffffffe000201b58:	f8043f03          	ld	t5,-128(s0)
ffffffe000201b5c:	f8843f83          	ld	t6,-120(s0)
ffffffe000201b60:	f9043283          	ld	t0,-112(s0)
ffffffe000201b64:	f9843483          	ld	s1,-104(s0)
ffffffe000201b68:	fa043903          	ld	s2,-96(s0)
ffffffe000201b6c:	fa843983          	ld	s3,-88(s0)
ffffffe000201b70:	000e0893          	mv	a7,t3
ffffffe000201b74:	000e8813          	mv	a6,t4
ffffffe000201b78:	000f0793          	mv	a5,t5
ffffffe000201b7c:	000f8713          	mv	a4,t6
ffffffe000201b80:	00028693          	mv	a3,t0
ffffffe000201b84:	00048613          	mv	a2,s1
ffffffe000201b88:	00090593          	mv	a1,s2
ffffffe000201b8c:	00098513          	mv	a0,s3
ffffffe000201b90:	00000073          	ecall
ffffffe000201b94:	00050e93          	mv	t4,a0
ffffffe000201b98:	00058e13          	mv	t3,a1
ffffffe000201b9c:	fdd43023          	sd	t4,-64(s0)
ffffffe000201ba0:	fdc43423          	sd	t3,-56(s0)
        :[error]"=r"(result.error),[value]"=r"(result.value)
        :[eid]"r"(eid),[fid]"r"(fid),[arg5]"r"(arg5),[arg4]"r"(arg4),[arg3]"r"(arg3),[arg2]"r"(arg2),[arg1]"r"(arg1),[arg0]"r"(arg0)
        :"a0","a1","a2","a3","a4","a5","a6","a7"
    );

    return result;
ffffffe000201ba4:	fc043783          	ld	a5,-64(s0)
ffffffe000201ba8:	fcf43823          	sd	a5,-48(s0)
ffffffe000201bac:	fc843783          	ld	a5,-56(s0)
ffffffe000201bb0:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201bb4:	fd043703          	ld	a4,-48(s0)
ffffffe000201bb8:	fd843783          	ld	a5,-40(s0)
ffffffe000201bbc:	00070313          	mv	t1,a4
ffffffe000201bc0:	00078393          	mv	t2,a5
ffffffe000201bc4:	00030713          	mv	a4,t1
ffffffe000201bc8:	00038793          	mv	a5,t2
}
ffffffe000201bcc:	00070513          	mv	a0,a4
ffffffe000201bd0:	00078593          	mv	a1,a5
ffffffe000201bd4:	07813403          	ld	s0,120(sp)
ffffffe000201bd8:	07013483          	ld	s1,112(sp)
ffffffe000201bdc:	06813903          	ld	s2,104(sp)
ffffffe000201be0:	06013983          	ld	s3,96(sp)
ffffffe000201be4:	08010113          	addi	sp,sp,128
ffffffe000201be8:	00008067          	ret

ffffffe000201bec <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201bec:	fb010113          	addi	sp,sp,-80
ffffffe000201bf0:	04113423          	sd	ra,72(sp)
ffffffe000201bf4:	04813023          	sd	s0,64(sp)
ffffffe000201bf8:	03213c23          	sd	s2,56(sp)
ffffffe000201bfc:	03313823          	sd	s3,48(sp)
ffffffe000201c00:	05010413          	addi	s0,sp,80
ffffffe000201c04:	00050793          	mv	a5,a0
ffffffe000201c08:	faf40fa3          	sb	a5,-65(s0)
    struct sbiret result=sbi_ecall(SBI_EID_DEBUG_CONSOLE_WRITE_BYTE,SBI_FID_DEBUG_CONSOLE_WRITE_BYTE,byte,0,0,0,0,0);
ffffffe000201c0c:	fbf44603          	lbu	a2,-65(s0)
ffffffe000201c10:	00000893          	li	a7,0
ffffffe000201c14:	00000813          	li	a6,0
ffffffe000201c18:	00000793          	li	a5,0
ffffffe000201c1c:	00000713          	li	a4,0
ffffffe000201c20:	00000693          	li	a3,0
ffffffe000201c24:	00200593          	li	a1,2
ffffffe000201c28:	44424537          	lui	a0,0x44424
ffffffe000201c2c:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201c30:	ee9ff0ef          	jal	ffffffe000201b18 <sbi_ecall>
ffffffe000201c34:	00050713          	mv	a4,a0
ffffffe000201c38:	00058793          	mv	a5,a1
ffffffe000201c3c:	fce43023          	sd	a4,-64(s0)
ffffffe000201c40:	fcf43423          	sd	a5,-56(s0)
    return result;
ffffffe000201c44:	fc043783          	ld	a5,-64(s0)
ffffffe000201c48:	fcf43823          	sd	a5,-48(s0)
ffffffe000201c4c:	fc843783          	ld	a5,-56(s0)
ffffffe000201c50:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201c54:	fd043703          	ld	a4,-48(s0)
ffffffe000201c58:	fd843783          	ld	a5,-40(s0)
ffffffe000201c5c:	00070913          	mv	s2,a4
ffffffe000201c60:	00078993          	mv	s3,a5
ffffffe000201c64:	00090713          	mv	a4,s2
ffffffe000201c68:	00098793          	mv	a5,s3
}
ffffffe000201c6c:	00070513          	mv	a0,a4
ffffffe000201c70:	00078593          	mv	a1,a5
ffffffe000201c74:	04813083          	ld	ra,72(sp)
ffffffe000201c78:	04013403          	ld	s0,64(sp)
ffffffe000201c7c:	03813903          	ld	s2,56(sp)
ffffffe000201c80:	03013983          	ld	s3,48(sp)
ffffffe000201c84:	05010113          	addi	sp,sp,80
ffffffe000201c88:	00008067          	ret

ffffffe000201c8c <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201c8c:	fb010113          	addi	sp,sp,-80
ffffffe000201c90:	04113423          	sd	ra,72(sp)
ffffffe000201c94:	04813023          	sd	s0,64(sp)
ffffffe000201c98:	03213c23          	sd	s2,56(sp)
ffffffe000201c9c:	03313823          	sd	s3,48(sp)
ffffffe000201ca0:	05010413          	addi	s0,sp,80
ffffffe000201ca4:	00050793          	mv	a5,a0
ffffffe000201ca8:	00058713          	mv	a4,a1
ffffffe000201cac:	faf42e23          	sw	a5,-68(s0)
ffffffe000201cb0:	00070793          	mv	a5,a4
ffffffe000201cb4:	faf42c23          	sw	a5,-72(s0)
    struct sbiret result=sbi_ecall(SBI_EID_RESET_TYPE_SHUTDOWN,SBI_SRST_RESET_REASON_NONE,reset_type,reset_reason,0,0,0,0);
ffffffe000201cb8:	fbc46603          	lwu	a2,-68(s0)
ffffffe000201cbc:	fb846683          	lwu	a3,-72(s0)
ffffffe000201cc0:	00000893          	li	a7,0
ffffffe000201cc4:	00000813          	li	a6,0
ffffffe000201cc8:	00000793          	li	a5,0
ffffffe000201ccc:	00000713          	li	a4,0
ffffffe000201cd0:	00000593          	li	a1,0
ffffffe000201cd4:	53525537          	lui	a0,0x53525
ffffffe000201cd8:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000201cdc:	e3dff0ef          	jal	ffffffe000201b18 <sbi_ecall>
ffffffe000201ce0:	00050713          	mv	a4,a0
ffffffe000201ce4:	00058793          	mv	a5,a1
ffffffe000201ce8:	fce43023          	sd	a4,-64(s0)
ffffffe000201cec:	fcf43423          	sd	a5,-56(s0)
    return result;
ffffffe000201cf0:	fc043783          	ld	a5,-64(s0)
ffffffe000201cf4:	fcf43823          	sd	a5,-48(s0)
ffffffe000201cf8:	fc843783          	ld	a5,-56(s0)
ffffffe000201cfc:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201d00:	fd043703          	ld	a4,-48(s0)
ffffffe000201d04:	fd843783          	ld	a5,-40(s0)
ffffffe000201d08:	00070913          	mv	s2,a4
ffffffe000201d0c:	00078993          	mv	s3,a5
ffffffe000201d10:	00090713          	mv	a4,s2
ffffffe000201d14:	00098793          	mv	a5,s3
}
ffffffe000201d18:	00070513          	mv	a0,a4
ffffffe000201d1c:	00078593          	mv	a1,a5
ffffffe000201d20:	04813083          	ld	ra,72(sp)
ffffffe000201d24:	04013403          	ld	s0,64(sp)
ffffffe000201d28:	03813903          	ld	s2,56(sp)
ffffffe000201d2c:	03013983          	ld	s3,48(sp)
ffffffe000201d30:	05010113          	addi	sp,sp,80
ffffffe000201d34:	00008067          	ret

ffffffe000201d38 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value)
{
ffffffe000201d38:	fa010113          	addi	sp,sp,-96
ffffffe000201d3c:	04113c23          	sd	ra,88(sp)
ffffffe000201d40:	04813823          	sd	s0,80(sp)
ffffffe000201d44:	05213423          	sd	s2,72(sp)
ffffffe000201d48:	05313023          	sd	s3,64(sp)
ffffffe000201d4c:	06010413          	addi	s0,sp,96
ffffffe000201d50:	faa43423          	sd	a0,-88(s0)
    unsigned long time_final;
    __asm__ volatile(
ffffffe000201d54:	c01022f3          	rdtime	t0
ffffffe000201d58:	00989337          	lui	t1,0x989
ffffffe000201d5c:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
ffffffe000201d60:	006282b3          	add	t0,t0,t1
ffffffe000201d64:	00028793          	mv	a5,t0
ffffffe000201d68:	fcf43c23          	sd	a5,-40(s0)
        "add t0,t0,t1 \n"
        "mv %[time_final],t0 \n"
        : [time_final]"=r"(time_final)
    );

    struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,time_final,0,0,0,0,0);
ffffffe000201d6c:	00000893          	li	a7,0
ffffffe000201d70:	00000813          	li	a6,0
ffffffe000201d74:	00000793          	li	a5,0
ffffffe000201d78:	00000713          	li	a4,0
ffffffe000201d7c:	00000693          	li	a3,0
ffffffe000201d80:	fd843603          	ld	a2,-40(s0)
ffffffe000201d84:	00000593          	li	a1,0
ffffffe000201d88:	54495537          	lui	a0,0x54495
ffffffe000201d8c:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201d90:	d89ff0ef          	jal	ffffffe000201b18 <sbi_ecall>
ffffffe000201d94:	00050713          	mv	a4,a0
ffffffe000201d98:	00058793          	mv	a5,a1
ffffffe000201d9c:	fae43c23          	sd	a4,-72(s0)
ffffffe000201da0:	fcf43023          	sd	a5,-64(s0)
    //struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,stime_value,0,0,0,0,0);
    return result;
ffffffe000201da4:	fb843783          	ld	a5,-72(s0)
ffffffe000201da8:	fcf43423          	sd	a5,-56(s0)
ffffffe000201dac:	fc043783          	ld	a5,-64(s0)
ffffffe000201db0:	fcf43823          	sd	a5,-48(s0)
ffffffe000201db4:	fc843703          	ld	a4,-56(s0)
ffffffe000201db8:	fd043783          	ld	a5,-48(s0)
ffffffe000201dbc:	00070913          	mv	s2,a4
ffffffe000201dc0:	00078993          	mv	s3,a5
ffffffe000201dc4:	00090713          	mv	a4,s2
ffffffe000201dc8:	00098793          	mv	a5,s3
ffffffe000201dcc:	00070513          	mv	a0,a4
ffffffe000201dd0:	00078593          	mv	a1,a5
ffffffe000201dd4:	05813083          	ld	ra,88(sp)
ffffffe000201dd8:	05013403          	ld	s0,80(sp)
ffffffe000201ddc:	04813903          	ld	s2,72(sp)
ffffffe000201de0:	04013983          	ld	s3,64(sp)
ffffffe000201de4:	06010113          	addi	sp,sp,96
ffffffe000201de8:	00008067          	ret

ffffffe000201dec <sys_write>:
#include "defs.h"

// 将用户态传递的字符串打印到屏幕上
// fd 为标准输出即 1，buf 为用户需要打印的起始地址，count 为字符串长度，返回打印的字符数；
void sys_write(unsigned int fd, const char* buf, size_t count, struct pt_regs *regs)  
{
ffffffe000201dec:	fc010113          	addi	sp,sp,-64
ffffffe000201df0:	02113c23          	sd	ra,56(sp)
ffffffe000201df4:	02813823          	sd	s0,48(sp)
ffffffe000201df8:	04010413          	addi	s0,sp,64
ffffffe000201dfc:	00050793          	mv	a5,a0
ffffffe000201e00:	fcb43823          	sd	a1,-48(s0)
ffffffe000201e04:	fcc43423          	sd	a2,-56(s0)
ffffffe000201e08:	fcd43023          	sd	a3,-64(s0)
ffffffe000201e0c:	fcf42e23          	sw	a5,-36(s0)
    if(fd == 1)
ffffffe000201e10:	fdc42783          	lw	a5,-36(s0)
ffffffe000201e14:	0007871b          	sext.w	a4,a5
ffffffe000201e18:	00100793          	li	a5,1
ffffffe000201e1c:	06f71063          	bne	a4,a5,ffffffe000201e7c <sys_write+0x90>
    {
        uint64_t result;
        for(size_t i=0;i<count;i++)
ffffffe000201e20:	fe043023          	sd	zero,-32(s0)
ffffffe000201e24:	0400006f          	j	ffffffe000201e64 <sys_write+0x78>
        {
            printk("%c", buf[i]);
ffffffe000201e28:	fd043703          	ld	a4,-48(s0)
ffffffe000201e2c:	fe043783          	ld	a5,-32(s0)
ffffffe000201e30:	00f707b3          	add	a5,a4,a5
ffffffe000201e34:	0007c783          	lbu	a5,0(a5)
ffffffe000201e38:	0007879b          	sext.w	a5,a5
ffffffe000201e3c:	00078593          	mv	a1,a5
ffffffe000201e40:	00002517          	auipc	a0,0x2
ffffffe000201e44:	3b850513          	addi	a0,a0,952 # ffffffe0002041f8 <_srodata+0x1f8>
ffffffe000201e48:	79d010ef          	jal	ffffffe000203de4 <printk>
            result++;
ffffffe000201e4c:	fe843783          	ld	a5,-24(s0)
ffffffe000201e50:	00178793          	addi	a5,a5,1
ffffffe000201e54:	fef43423          	sd	a5,-24(s0)
        for(size_t i=0;i<count;i++)
ffffffe000201e58:	fe043783          	ld	a5,-32(s0)
ffffffe000201e5c:	00178793          	addi	a5,a5,1
ffffffe000201e60:	fef43023          	sd	a5,-32(s0)
ffffffe000201e64:	fe043703          	ld	a4,-32(s0)
ffffffe000201e68:	fc843783          	ld	a5,-56(s0)
ffffffe000201e6c:	faf76ee3          	bltu	a4,a5,ffffffe000201e28 <sys_write+0x3c>
        }
        regs->x[10] = result;
ffffffe000201e70:	fc043783          	ld	a5,-64(s0)
ffffffe000201e74:	fe843703          	ld	a4,-24(s0)
ffffffe000201e78:	04e7b823          	sd	a4,80(a5)
    }
}
ffffffe000201e7c:	00000013          	nop
ffffffe000201e80:	03813083          	ld	ra,56(sp)
ffffffe000201e84:	03013403          	ld	s0,48(sp)
ffffffe000201e88:	04010113          	addi	sp,sp,64
ffffffe000201e8c:	00008067          	ret

ffffffe000201e90 <sys_getpid>:

// 从 current 中获取当前的 pid 放入 a0 中返回，无参数
void sys_getpid(struct pt_regs *regs)   
{
ffffffe000201e90:	fe010113          	addi	sp,sp,-32
ffffffe000201e94:	00813c23          	sd	s0,24(sp)
ffffffe000201e98:	02010413          	addi	s0,sp,32
ffffffe000201e9c:	fea43423          	sd	a0,-24(s0)
    regs->x[10] = current->pid;
ffffffe000201ea0:	00008797          	auipc	a5,0x8
ffffffe000201ea4:	17078793          	addi	a5,a5,368 # ffffffe00020a010 <current>
ffffffe000201ea8:	0007b783          	ld	a5,0(a5)
ffffffe000201eac:	0187b703          	ld	a4,24(a5)
ffffffe000201eb0:	fe843783          	ld	a5,-24(s0)
ffffffe000201eb4:	04e7b823          	sd	a4,80(a5)
}
ffffffe000201eb8:	00000013          	nop
ffffffe000201ebc:	01813403          	ld	s0,24(sp)
ffffffe000201ec0:	02010113          	addi	sp,sp,32
ffffffe000201ec4:	00008067          	ret

ffffffe000201ec8 <isValid_pte>:
extern uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags);
extern void __ret_from_fork();

#define PTE_V  (1 << 0)  // Valid
// 判断虚拟地址 addr 对应的 PTE 是否有效
uint64_t isValid_pte(uint64_t *pgd, uint64_t va) {
ffffffe000201ec8:	fc010113          	addi	sp,sp,-64
ffffffe000201ecc:	02813c23          	sd	s0,56(sp)
ffffffe000201ed0:	04010413          	addi	s0,sp,64
ffffffe000201ed4:	fca43423          	sd	a0,-56(s0)
ffffffe000201ed8:	fcb43023          	sd	a1,-64(s0)
    uint64_t VPN[3];
    VPN[2] = (va >> 30) & 0x1ff; // 9 bit
ffffffe000201edc:	fc043783          	ld	a5,-64(s0)
ffffffe000201ee0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201ee4:	1ff7f793          	andi	a5,a5,511
ffffffe000201ee8:	fef43023          	sd	a5,-32(s0)
    VPN[1] = (va >> 21) & 0x1ff;
ffffffe000201eec:	fc043783          	ld	a5,-64(s0)
ffffffe000201ef0:	0157d793          	srli	a5,a5,0x15
ffffffe000201ef4:	1ff7f793          	andi	a5,a5,511
ffffffe000201ef8:	fcf43c23          	sd	a5,-40(s0)
    VPN[0] = (va >> 12) & 0x1ff;
ffffffe000201efc:	fc043783          	ld	a5,-64(s0)
ffffffe000201f00:	00c7d793          	srli	a5,a5,0xc
ffffffe000201f04:	1ff7f793          	andi	a5,a5,511
ffffffe000201f08:	fcf43823          	sd	a5,-48(s0)

    for (int level = 2; level > 0; level--) 
ffffffe000201f0c:	00200793          	li	a5,2
ffffffe000201f10:	fef42623          	sw	a5,-20(s0)
ffffffe000201f14:	0800006f          	j	ffffffe000201f94 <isValid_pte+0xcc>
    {
        if ((pgd[VPN[level]] & 0x1) == 0) 
ffffffe000201f18:	fec42783          	lw	a5,-20(s0)
ffffffe000201f1c:	00379793          	slli	a5,a5,0x3
ffffffe000201f20:	ff078793          	addi	a5,a5,-16
ffffffe000201f24:	008787b3          	add	a5,a5,s0
ffffffe000201f28:	fe07b783          	ld	a5,-32(a5)
ffffffe000201f2c:	00379793          	slli	a5,a5,0x3
ffffffe000201f30:	fc843703          	ld	a4,-56(s0)
ffffffe000201f34:	00f707b3          	add	a5,a4,a5
ffffffe000201f38:	0007b783          	ld	a5,0(a5)
ffffffe000201f3c:	0017f793          	andi	a5,a5,1
ffffffe000201f40:	00079663          	bnez	a5,ffffffe000201f4c <isValid_pte+0x84>
        {
            return 0;
ffffffe000201f44:	00000793          	li	a5,0
ffffffe000201f48:	0800006f          	j	ffffffe000201fc8 <isValid_pte+0x100>
        }else 
        {
            pgd = (uint64_t *)((pgd[VPN[level]] >> 10 << 12) + PA2VA_OFFSET);
ffffffe000201f4c:	fec42783          	lw	a5,-20(s0)
ffffffe000201f50:	00379793          	slli	a5,a5,0x3
ffffffe000201f54:	ff078793          	addi	a5,a5,-16
ffffffe000201f58:	008787b3          	add	a5,a5,s0
ffffffe000201f5c:	fe07b783          	ld	a5,-32(a5)
ffffffe000201f60:	00379793          	slli	a5,a5,0x3
ffffffe000201f64:	fc843703          	ld	a4,-56(s0)
ffffffe000201f68:	00f707b3          	add	a5,a4,a5
ffffffe000201f6c:	0007b783          	ld	a5,0(a5)
ffffffe000201f70:	00a7d793          	srli	a5,a5,0xa
ffffffe000201f74:	00c79713          	slli	a4,a5,0xc
ffffffe000201f78:	fbf00793          	li	a5,-65
ffffffe000201f7c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201f80:	00f707b3          	add	a5,a4,a5
ffffffe000201f84:	fcf43423          	sd	a5,-56(s0)
    for (int level = 2; level > 0; level--) 
ffffffe000201f88:	fec42783          	lw	a5,-20(s0)
ffffffe000201f8c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201f90:	fef42623          	sw	a5,-20(s0)
ffffffe000201f94:	fec42783          	lw	a5,-20(s0)
ffffffe000201f98:	0007879b          	sext.w	a5,a5
ffffffe000201f9c:	f6f04ee3          	bgtz	a5,ffffffe000201f18 <isValid_pte+0x50>
        }
    }
    if ((pgd[VPN[0]] & 0x1) == 0) {
ffffffe000201fa0:	fd043783          	ld	a5,-48(s0)
ffffffe000201fa4:	00379793          	slli	a5,a5,0x3
ffffffe000201fa8:	fc843703          	ld	a4,-56(s0)
ffffffe000201fac:	00f707b3          	add	a5,a4,a5
ffffffe000201fb0:	0007b783          	ld	a5,0(a5)
ffffffe000201fb4:	0017f793          	andi	a5,a5,1
ffffffe000201fb8:	00079663          	bnez	a5,ffffffe000201fc4 <isValid_pte+0xfc>
        return 0;
ffffffe000201fbc:	00000793          	li	a5,0
ffffffe000201fc0:	0080006f          	j	ffffffe000201fc8 <isValid_pte+0x100>
    }
    return 1;
ffffffe000201fc4:	00100793          	li	a5,1
}
ffffffe000201fc8:	00078513          	mv	a0,a5
ffffffe000201fcc:	03813403          	ld	s0,56(sp)
ffffffe000201fd0:	04010113          	addi	sp,sp,64
ffffffe000201fd4:	00008067          	ret

ffffffe000201fd8 <do_fork>:

// handle fork
uint64_t do_fork(struct pt_regs *regs) {
ffffffe000201fd8:	fa010113          	addi	sp,sp,-96
ffffffe000201fdc:	04113c23          	sd	ra,88(sp)
ffffffe000201fe0:	04813823          	sd	s0,80(sp)
ffffffe000201fe4:	06010413          	addi	s0,sp,96
ffffffe000201fe8:	faa43423          	sd	a0,-88(s0)
    // 1.创建一个新进程
    // 1.1.拷贝内核栈（包括了task_struct等信息）
    struct task_struct *_task = (struct task_struct *)kalloc();
ffffffe000201fec:	9d9fe0ef          	jal	ffffffe0002009c4 <kalloc>
ffffffe000201ff0:	00050793          	mv	a5,a0
ffffffe000201ff4:	fcf43c23          	sd	a5,-40(s0)
    if(!_task) {   
ffffffe000201ff8:	fd843783          	ld	a5,-40(s0)
ffffffe000201ffc:	00079c63          	bnez	a5,ffffffe000202014 <do_fork+0x3c>
        // 如果内存分配失败，则退出
        printk("do_fork : Failed to allocate memory for child's page directory\n");
ffffffe000202000:	00002517          	auipc	a0,0x2
ffffffe000202004:	20050513          	addi	a0,a0,512 # ffffffe000204200 <_srodata+0x200>
ffffffe000202008:	5dd010ef          	jal	ffffffe000203de4 <printk>
        return -1;
ffffffe00020200c:	fff00793          	li	a5,-1
ffffffe000202010:	3380006f          	j	ffffffe000202348 <do_fork+0x370>
    }
        // 深拷贝task_struct的页
    memcpy((void *)_task, (void *)current, PGSIZE);
ffffffe000202014:	00008797          	auipc	a5,0x8
ffffffe000202018:	ffc78793          	addi	a5,a5,-4 # ffffffe00020a010 <current>
ffffffe00020201c:	0007b783          	ld	a5,0(a5)
ffffffe000202020:	00001637          	lui	a2,0x1
ffffffe000202024:	00078593          	mv	a1,a5
ffffffe000202028:	fd843503          	ld	a0,-40(s0)
ffffffe00020202c:	c75fe0ef          	jal	ffffffe000200ca0 <memcpy>
    // printk("copy task_struct\n");
        // 除此之外还要略微修改 task_struct 内容
    _task->state=TASK_RUNNING;
ffffffe000202030:	fd843783          	ld	a5,-40(s0)
ffffffe000202034:	0007b023          	sd	zero,0(a5)
    _task->counter=0;
ffffffe000202038:	fd843783          	ld	a5,-40(s0)
ffffffe00020203c:	0007b423          	sd	zero,8(a5)
    _task->priority=rand()%(PRIORITY_MAX - PRIORITY_MIN + 1)+PRIORITY_MIN;
ffffffe000202040:	669010ef          	jal	ffffffe000203ea8 <rand>
ffffffe000202044:	00050793          	mv	a5,a0
ffffffe000202048:	00078713          	mv	a4,a5
ffffffe00020204c:	00a00793          	li	a5,10
ffffffe000202050:	02f767bb          	remw	a5,a4,a5
ffffffe000202054:	0007879b          	sext.w	a5,a5
ffffffe000202058:	0017879b          	addiw	a5,a5,1
ffffffe00020205c:	0007879b          	sext.w	a5,a5
ffffffe000202060:	00078713          	mv	a4,a5
ffffffe000202064:	fd843783          	ld	a5,-40(s0)
ffffffe000202068:	00e7b823          	sd	a4,16(a5)
    _task->pid = nr_tasks;    // pid 根据 nr_tasks 来赋值
ffffffe00020206c:	00003797          	auipc	a5,0x3
ffffffe000202070:	fa478793          	addi	a5,a5,-92 # ffffffe000205010 <nr_tasks>
ffffffe000202074:	0007a783          	lw	a5,0(a5)
ffffffe000202078:	00078713          	mv	a4,a5
ffffffe00020207c:	fd843783          	ld	a5,-40(s0)
ffffffe000202080:	00e7bc23          	sd	a4,24(a5)
    
    // 设置新进程的 thread.sp/sscratch/ra
    _task->thread.ra = (uint64_t)__ret_from_fork;
ffffffe000202084:	ffffe717          	auipc	a4,0xffffe
ffffffe000202088:	0ac70713          	addi	a4,a4,172 # ffffffe000200130 <__ret_from_fork>
ffffffe00020208c:	fd843783          	ld	a5,-40(s0)
ffffffe000202090:	02e7b023          	sd	a4,32(a5)
    _task->thread.sp = (uint64_t)_task+PGSIZE-sizeof(struct pt_regs); // 栈顶
ffffffe000202094:	fd843703          	ld	a4,-40(s0)
ffffffe000202098:	000017b7          	lui	a5,0x1
ffffffe00020209c:	ee878793          	addi	a5,a5,-280 # ee8 <PGSIZE-0x118>
ffffffe0002020a0:	00f70733          	add	a4,a4,a5
ffffffe0002020a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002020a8:	02e7b423          	sd	a4,40(a5)
    _task->thread.sscratch = csr_read(sscratch);
ffffffe0002020ac:	140027f3          	csrr	a5,sscratch
ffffffe0002020b0:	fcf43823          	sd	a5,-48(s0)
ffffffe0002020b4:	fd043703          	ld	a4,-48(s0)
ffffffe0002020b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002020bc:	0ae7b023          	sd	a4,160(a5)
    _task->thread.sepc= regs->sepc; // 父进程的 sepc  added
ffffffe0002020c0:	fa843783          	ld	a5,-88(s0)
ffffffe0002020c4:	1007b703          	ld	a4,256(a5)
ffffffe0002020c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002020cc:	08e7b823          	sd	a4,144(a5)

    _task->mm.mmap = NULL;      // mm.mmap 为 NULL，因为新进程还没有任何映射
ffffffe0002020d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002020d4:	0a07b823          	sd	zero,176(a5)

    // 1.2.创建一个新的页表
    _task->pgd = (uint64_t *)alloc_page();  // pgd 为新分配的页表地址
ffffffe0002020d8:	879fe0ef          	jal	ffffffe000200950 <alloc_page>
ffffffe0002020dc:	00050793          	mv	a5,a0
ffffffe0002020e0:	00078713          	mv	a4,a5
ffffffe0002020e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002020e8:	0ae7b423          	sd	a4,168(a5)
    if(!_task->pgd) {
ffffffe0002020ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002020f0:	0a87b783          	ld	a5,168(a5)
ffffffe0002020f4:	00079c63          	bnez	a5,ffffffe00020210c <do_fork+0x134>
        // 如果内存分配失败，则退出
        printk("do_fork : Failed to allocate memory for child's pgd\n");
ffffffe0002020f8:	00002517          	auipc	a0,0x2
ffffffe0002020fc:	14850513          	addi	a0,a0,328 # ffffffe000204240 <_srodata+0x240>
ffffffe000202100:	4e5010ef          	jal	ffffffe000203de4 <printk>
        return -1;
ffffffe000202104:	fff00793          	li	a5,-1
ffffffe000202108:	2400006f          	j	ffffffe000202348 <do_fork+0x370>
    }
    // 拷贝内核页表 swapper_pg_dir
    memcpy((void *)_task->pgd, (void *)swapper_pg_dir, PGSIZE);
ffffffe00020210c:	fd843783          	ld	a5,-40(s0)
ffffffe000202110:	0a87b783          	ld	a5,168(a5)
ffffffe000202114:	00001637          	lui	a2,0x1
ffffffe000202118:	0000a597          	auipc	a1,0xa
ffffffe00020211c:	ee858593          	addi	a1,a1,-280 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202120:	00078513          	mv	a0,a5
ffffffe000202124:	b7dfe0ef          	jal	ffffffe000200ca0 <memcpy>
    // printk("copy swapper\n");

    // 遍历父进程 vma，并遍历父进程页表
    struct vm_area_struct *parent_vma = current->mm.mmap;
ffffffe000202128:	00008797          	auipc	a5,0x8
ffffffe00020212c:	ee878793          	addi	a5,a5,-280 # ffffffe00020a010 <current>
ffffffe000202130:	0007b783          	ld	a5,0(a5)
ffffffe000202134:	0b07b783          	ld	a5,176(a5)
ffffffe000202138:	fef43423          	sd	a5,-24(s0)
    while(parent_vma)
ffffffe00020213c:	1440006f          	j	ffffffe000202280 <do_fork+0x2a8>
    {
        // 将这个 vma 也添加到新进程的 vma 链表中
        do_mmap(&_task->mm,
ffffffe000202140:	fd843783          	ld	a5,-40(s0)
ffffffe000202144:	0b078513          	addi	a0,a5,176
ffffffe000202148:	fe843783          	ld	a5,-24(s0)
ffffffe00020214c:	0087b583          	ld	a1,8(a5)
                parent_vma->vm_start,
                parent_vma->vm_end-parent_vma->vm_start,
ffffffe000202150:	fe843783          	ld	a5,-24(s0)
ffffffe000202154:	0107b703          	ld	a4,16(a5)
ffffffe000202158:	fe843783          	ld	a5,-24(s0)
ffffffe00020215c:	0087b783          	ld	a5,8(a5)
        do_mmap(&_task->mm,
ffffffe000202160:	40f70633          	sub	a2,a4,a5
ffffffe000202164:	fe843783          	ld	a5,-24(s0)
ffffffe000202168:	0307b683          	ld	a3,48(a5)
ffffffe00020216c:	fe843783          	ld	a5,-24(s0)
ffffffe000202170:	0387b703          	ld	a4,56(a5)
ffffffe000202174:	fe843783          	ld	a5,-24(s0)
ffffffe000202178:	0287b783          	ld	a5,40(a5)
ffffffe00020217c:	9c9fe0ef          	jal	ffffffe000200b44 <do_mmap>
                parent_vma->vm_pgoff,
                parent_vma->vm_filesz,
                parent_vma->vm_flags);

        // 遍历页表    
        for(uint64_t addr=parent_vma->vm_start; addr < parent_vma->vm_end; addr+=PGSIZE)
ffffffe000202180:	fe843783          	ld	a5,-24(s0)
ffffffe000202184:	0087b783          	ld	a5,8(a5)
ffffffe000202188:	fef43023          	sd	a5,-32(s0)
ffffffe00020218c:	0d80006f          	j	ffffffe000202264 <do_fork+0x28c>
        {
            uint64_t pa=isValid_pte(current->pgd,addr);
ffffffe000202190:	00008797          	auipc	a5,0x8
ffffffe000202194:	e8078793          	addi	a5,a5,-384 # ffffffe00020a010 <current>
ffffffe000202198:	0007b783          	ld	a5,0(a5)
ffffffe00020219c:	0a87b783          	ld	a5,168(a5)
ffffffe0002021a0:	fe043583          	ld	a1,-32(s0)
ffffffe0002021a4:	00078513          	mv	a0,a5
ffffffe0002021a8:	d21ff0ef          	jal	ffffffe000201ec8 <isValid_pte>
ffffffe0002021ac:	fca43023          	sd	a0,-64(s0)
            // 如果找不到（PTE V 为 0）则不需要拷贝
            if(!pa) continue;
ffffffe0002021b0:	fc043783          	ld	a5,-64(s0)
ffffffe0002021b4:	08078e63          	beqz	a5,ffffffe000202250 <do_fork+0x278>
            // 如果该 vma 项有对应的页表项存在（说明已经创建了映射），则需要深拷贝一整页的内容并映射到新页表中,内核态拷贝内容也需要使用虚拟地址
            uint64_t child_va = (uint64_t )alloc_page();
ffffffe0002021b8:	f98fe0ef          	jal	ffffffe000200950 <alloc_page>
ffffffe0002021bc:	00050793          	mv	a5,a0
ffffffe0002021c0:	faf43c23          	sd	a5,-72(s0)
            if(!child_va) {
ffffffe0002021c4:	fb843783          	ld	a5,-72(s0)
ffffffe0002021c8:	00079c63          	bnez	a5,ffffffe0002021e0 <do_fork+0x208>
                printk("do_fork : Failed to allocate memory for child's page\n");
ffffffe0002021cc:	00002517          	auipc	a0,0x2
ffffffe0002021d0:	0ac50513          	addi	a0,a0,172 # ffffffe000204278 <_srodata+0x278>
ffffffe0002021d4:	411010ef          	jal	ffffffe000203de4 <printk>
                return -1;
ffffffe0002021d8:	fff00793          	li	a5,-1
ffffffe0002021dc:	16c0006f          	j	ffffffe000202348 <do_fork+0x370>
            }
            memcpy((void *)(child_va),PGROUNDDOWN(addr),PGSIZE);
ffffffe0002021e0:	fb843683          	ld	a3,-72(s0)
ffffffe0002021e4:	fe043703          	ld	a4,-32(s0)
ffffffe0002021e8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021ec:	00f777b3          	and	a5,a4,a5
ffffffe0002021f0:	00001637          	lui	a2,0x1
ffffffe0002021f4:	00078593          	mv	a1,a5
ffffffe0002021f8:	00068513          	mv	a0,a3
ffffffe0002021fc:	aa5fe0ef          	jal	ffffffe000200ca0 <memcpy>
            // mapping
            uint64_t perm=(parent_vma->vm_flags)|(1<<0)|(1<<4);
ffffffe000202200:	fe843783          	ld	a5,-24(s0)
ffffffe000202204:	0287b783          	ld	a5,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
ffffffe000202208:	0117e793          	ori	a5,a5,17
ffffffe00020220c:	faf43823          	sd	a5,-80(s0)
            create_mapping(_task->pgd,PGROUNDDOWN(addr),PGROUNDDOWN(child_va)-PA2VA_OFFSET,PGSIZE,perm);
ffffffe000202210:	fd843783          	ld	a5,-40(s0)
ffffffe000202214:	0a87b503          	ld	a0,168(a5)
ffffffe000202218:	fe043703          	ld	a4,-32(s0)
ffffffe00020221c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202220:	00f775b3          	and	a1,a4,a5
ffffffe000202224:	fb843703          	ld	a4,-72(s0)
ffffffe000202228:	fffff7b7          	lui	a5,0xfffff
ffffffe00020222c:	00f77733          	and	a4,a4,a5
ffffffe000202230:	04100793          	li	a5,65
ffffffe000202234:	01f79793          	slli	a5,a5,0x1f
ffffffe000202238:	00f707b3          	add	a5,a4,a5
ffffffe00020223c:	fb043703          	ld	a4,-80(s0)
ffffffe000202240:	000016b7          	lui	a3,0x1
ffffffe000202244:	00078613          	mv	a2,a5
ffffffe000202248:	2dd000ef          	jal	ffffffe000202d24 <create_mapping>
ffffffe00020224c:	0080006f          	j	ffffffe000202254 <do_fork+0x27c>
            if(!pa) continue;
ffffffe000202250:	00000013          	nop
        for(uint64_t addr=parent_vma->vm_start; addr < parent_vma->vm_end; addr+=PGSIZE)
ffffffe000202254:	fe043703          	ld	a4,-32(s0)
ffffffe000202258:	000017b7          	lui	a5,0x1
ffffffe00020225c:	00f707b3          	add	a5,a4,a5
ffffffe000202260:	fef43023          	sd	a5,-32(s0)
ffffffe000202264:	fe843783          	ld	a5,-24(s0)
ffffffe000202268:	0107b783          	ld	a5,16(a5) # 1010 <PGSIZE+0x10>
ffffffe00020226c:	fe043703          	ld	a4,-32(s0)
ffffffe000202270:	f2f760e3          	bltu	a4,a5,ffffffe000202190 <do_fork+0x1b8>
        }
        parent_vma = parent_vma->vm_next;
ffffffe000202274:	fe843783          	ld	a5,-24(s0)
ffffffe000202278:	0187b783          	ld	a5,24(a5)
ffffffe00020227c:	fef43423          	sd	a5,-24(s0)
    while(parent_vma)
ffffffe000202280:	fe843783          	ld	a5,-24(s0)
ffffffe000202284:	ea079ee3          	bnez	a5,ffffffe000202140 <do_fork+0x168>
    }
    
    struct pt_regs *child_regs = (struct pt_regs *)_task->thread.sp;
ffffffe000202288:	fd843783          	ld	a5,-40(s0)
ffffffe00020228c:	0287b783          	ld	a5,40(a5)
ffffffe000202290:	fcf43423          	sd	a5,-56(s0)
    memcpy(child_regs, regs, sizeof(struct pt_regs));
ffffffe000202294:	11800613          	li	a2,280
ffffffe000202298:	fa843583          	ld	a1,-88(s0)
ffffffe00020229c:	fc843503          	ld	a0,-56(s0)
ffffffe0002022a0:	a01fe0ef          	jal	ffffffe000200ca0 <memcpy>
    // printk("copy regs\n");
    child_regs->x[2] = _task->thread.sp;
ffffffe0002022a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002022a8:	0287b703          	ld	a4,40(a5)
ffffffe0002022ac:	fc843783          	ld	a5,-56(s0)
ffffffe0002022b0:	00e7b823          	sd	a4,16(a5)
    // 最后就是为子进程 pt_regs 的 a0 设置返回值 0，为 sepc 手动加四
    child_regs->x[10] = 0;
ffffffe0002022b4:	fc843783          	ld	a5,-56(s0)
ffffffe0002022b8:	0407b823          	sd	zero,80(a5)
    child_regs->sepc = regs->sepc+4;
ffffffe0002022bc:	fa843783          	ld	a5,-88(s0)
ffffffe0002022c0:	1007b783          	ld	a5,256(a5)
ffffffe0002022c4:	00478713          	addi	a4,a5,4
ffffffe0002022c8:	fc843783          	ld	a5,-56(s0)
ffffffe0002022cc:	10e7b023          	sd	a4,256(a5)

    // 2.将新进程加入调度队列
    task[nr_tasks]=_task;
ffffffe0002022d0:	00003797          	auipc	a5,0x3
ffffffe0002022d4:	d4078793          	addi	a5,a5,-704 # ffffffe000205010 <nr_tasks>
ffffffe0002022d8:	0007a783          	lw	a5,0(a5)
ffffffe0002022dc:	00008717          	auipc	a4,0x8
ffffffe0002022e0:	d5470713          	addi	a4,a4,-684 # ffffffe00020a030 <task>
ffffffe0002022e4:	00379793          	slli	a5,a5,0x3
ffffffe0002022e8:	00f707b3          	add	a5,a4,a5
ffffffe0002022ec:	fd843703          	ld	a4,-40(s0)
ffffffe0002022f0:	00e7b023          	sd	a4,0(a5)
    nr_tasks++;
ffffffe0002022f4:	00003797          	auipc	a5,0x3
ffffffe0002022f8:	d1c78793          	addi	a5,a5,-740 # ffffffe000205010 <nr_tasks>
ffffffe0002022fc:	0007a783          	lw	a5,0(a5)
ffffffe000202300:	0017879b          	addiw	a5,a5,1
ffffffe000202304:	0007871b          	sext.w	a4,a5
ffffffe000202308:	00003797          	auipc	a5,0x3
ffffffe00020230c:	d0878793          	addi	a5,a5,-760 # ffffffe000205010 <nr_tasks>
ffffffe000202310:	00e7a023          	sw	a4,0(a5)
    
    printk(DEEPGREEN"[do_fork] [PID: %d] forked from [PID: %d]\n"CLEAR,_task->pid,current->pid);
ffffffe000202314:	fd843783          	ld	a5,-40(s0)
ffffffe000202318:	0187b703          	ld	a4,24(a5)
ffffffe00020231c:	00008797          	auipc	a5,0x8
ffffffe000202320:	cf478793          	addi	a5,a5,-780 # ffffffe00020a010 <current>
ffffffe000202324:	0007b783          	ld	a5,0(a5)
ffffffe000202328:	0187b783          	ld	a5,24(a5)
ffffffe00020232c:	00078613          	mv	a2,a5
ffffffe000202330:	00070593          	mv	a1,a4
ffffffe000202334:	00002517          	auipc	a0,0x2
ffffffe000202338:	f7c50513          	addi	a0,a0,-132 # ffffffe0002042b0 <_srodata+0x2b0>
ffffffe00020233c:	2a9010ef          	jal	ffffffe000203de4 <printk>
    // 3.处理父子进程的返回值
    // 3.1.父进程通过 do_fork 函数直接返回子进程的 pid，并回到自身运行
    return _task->pid;
ffffffe000202340:	fd843783          	ld	a5,-40(s0)
ffffffe000202344:	0187b783          	ld	a5,24(a5)
    // 3.2.子进程通过被调度器调度后（跳到 thread.ra），开始执行并返回 0
ffffffe000202348:	00078513          	mv	a0,a5
ffffffe00020234c:	05813083          	ld	ra,88(sp)
ffffffe000202350:	05013403          	ld	s0,80(sp)
ffffffe000202354:	06010113          	addi	sp,sp,96
ffffffe000202358:	00008067          	ret

ffffffe00020235c <do_page_fault>:
#include "string.h"

extern create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);
extern char _sramdisk[];

void do_page_fault(struct pt_regs *regs) {
ffffffe00020235c:	f8010113          	addi	sp,sp,-128
ffffffe000202360:	06113c23          	sd	ra,120(sp)
ffffffe000202364:	06813823          	sd	s0,112(sp)
ffffffe000202368:	08010413          	addi	s0,sp,128
ffffffe00020236c:	f8a43423          	sd	a0,-120(s0)
    // 1.通过 stval 获得访问出错的虚拟内存地址（Bad Address）
    uint64_t stval = regs->stval; // 取指时的虚拟地址
ffffffe000202370:	f8843783          	ld	a5,-120(s0)
ffffffe000202374:	1107b783          	ld	a5,272(a5)
ffffffe000202378:	fcf43c23          	sd	a5,-40(s0)
    uint64_t scause = csr_read(scause);
ffffffe00020237c:	142027f3          	csrr	a5,scause
ffffffe000202380:	fcf43823          	sd	a5,-48(s0)
ffffffe000202384:	fd043783          	ld	a5,-48(s0)
ffffffe000202388:	fcf43423          	sd	a5,-56(s0)
    printk(GREEN"[trap.c,do_page_fault] [PID = %d PC = 0x%lx] valid page fault at `0x%lx` with cause %d\n"CLEAR,current->pid,regs->sepc,stval,scause);
ffffffe00020238c:	00008797          	auipc	a5,0x8
ffffffe000202390:	c8478793          	addi	a5,a5,-892 # ffffffe00020a010 <current>
ffffffe000202394:	0007b783          	ld	a5,0(a5)
ffffffe000202398:	0187b583          	ld	a1,24(a5)
ffffffe00020239c:	f8843783          	ld	a5,-120(s0)
ffffffe0002023a0:	1007b783          	ld	a5,256(a5)
ffffffe0002023a4:	fc843703          	ld	a4,-56(s0)
ffffffe0002023a8:	fd843683          	ld	a3,-40(s0)
ffffffe0002023ac:	00078613          	mv	a2,a5
ffffffe0002023b0:	00002517          	auipc	a0,0x2
ffffffe0002023b4:	f3850513          	addi	a0,a0,-200 # ffffffe0002042e8 <_srodata+0x2e8>
ffffffe0002023b8:	22d010ef          	jal	ffffffe000203de4 <printk>

    // 2.通过 find_vma() 查找 bad address 是否在某个 vma 中
    struct vm_area_struct *vma = find_vma(&current->mm, stval);
ffffffe0002023bc:	00008797          	auipc	a5,0x8
ffffffe0002023c0:	c5478793          	addi	a5,a5,-940 # ffffffe00020a010 <current>
ffffffe0002023c4:	0007b783          	ld	a5,0(a5)
ffffffe0002023c8:	0b078793          	addi	a5,a5,176
ffffffe0002023cc:	fd843583          	ld	a1,-40(s0)
ffffffe0002023d0:	00078513          	mv	a0,a5
ffffffe0002023d4:	efcfe0ef          	jal	ffffffe000200ad0 <find_vma>
ffffffe0002023d8:	00050793          	mv	a5,a0
ffffffe0002023dc:	fcf43023          	sd	a5,-64(s0)
    
    if (!vma) { // 如果不在，则出现非预期错误，可以通过 Err 宏输出错误信息
ffffffe0002023e0:	fc043783          	ld	a5,-64(s0)
ffffffe0002023e4:	02079863          	bnez	a5,ffffffe000202414 <do_page_fault+0xb8>
        Err("[S] Page Fault: Bad Address 0x%lx\n", stval);
ffffffe0002023e8:	fd843703          	ld	a4,-40(s0)
ffffffe0002023ec:	00002697          	auipc	a3,0x2
ffffffe0002023f0:	22468693          	addi	a3,a3,548 # ffffffe000204610 <__func__.1>
ffffffe0002023f4:	01600613          	li	a2,22
ffffffe0002023f8:	00002597          	auipc	a1,0x2
ffffffe0002023fc:	f5858593          	addi	a1,a1,-168 # ffffffe000204350 <_srodata+0x350>
ffffffe000202400:	00002517          	auipc	a0,0x2
ffffffe000202404:	f5850513          	addi	a0,a0,-168 # ffffffe000204358 <_srodata+0x358>
ffffffe000202408:	1dd010ef          	jal	ffffffe000203de4 <printk>
ffffffe00020240c:	00000013          	nop
ffffffe000202410:	ffdff06f          	j	ffffffe00020240c <do_page_fault+0xb0>
        return;
    } else { // 如果在，则根据 vma 的 flags 权限判断当前 page fault 是否合法
        if ((scause == 0xc && !(vma->vm_flags & VM_EXEC)) ||  // instruction
ffffffe000202414:	fc843703          	ld	a4,-56(s0)
ffffffe000202418:	00c00793          	li	a5,12
ffffffe00020241c:	00f71a63          	bne	a4,a5,ffffffe000202430 <do_page_fault+0xd4>
ffffffe000202420:	fc043783          	ld	a5,-64(s0)
ffffffe000202424:	0287b783          	ld	a5,40(a5)
ffffffe000202428:	0087f793          	andi	a5,a5,8
ffffffe00020242c:	02078e63          	beqz	a5,ffffffe000202468 <do_page_fault+0x10c>
ffffffe000202430:	fc843703          	ld	a4,-56(s0)
ffffffe000202434:	00d00793          	li	a5,13
ffffffe000202438:	00f71a63          	bne	a4,a5,ffffffe00020244c <do_page_fault+0xf0>
            (scause == 0xd && !(vma->vm_flags & VM_READ)) ||  // load
ffffffe00020243c:	fc043783          	ld	a5,-64(s0)
ffffffe000202440:	0287b783          	ld	a5,40(a5)
ffffffe000202444:	0027f793          	andi	a5,a5,2
ffffffe000202448:	02078063          	beqz	a5,ffffffe000202468 <do_page_fault+0x10c>
ffffffe00020244c:	fc843703          	ld	a4,-56(s0)
ffffffe000202450:	00f00793          	li	a5,15
ffffffe000202454:	04f71063          	bne	a4,a5,ffffffe000202494 <do_page_fault+0x138>
            (scause == 0xf && !(vma->vm_flags & VM_WRITE))) { // store
ffffffe000202458:	fc043783          	ld	a5,-64(s0)
ffffffe00020245c:	0287b783          	ld	a5,40(a5)
ffffffe000202460:	0047f793          	andi	a5,a5,4
ffffffe000202464:	02079863          	bnez	a5,ffffffe000202494 <do_page_fault+0x138>
            Err("[S] Page Fault: Illegal page fault to Bad Address 0x%lx\n", stval);
ffffffe000202468:	fd843703          	ld	a4,-40(s0)
ffffffe00020246c:	00002697          	auipc	a3,0x2
ffffffe000202470:	1a468693          	addi	a3,a3,420 # ffffffe000204610 <__func__.1>
ffffffe000202474:	01c00613          	li	a2,28
ffffffe000202478:	00002597          	auipc	a1,0x2
ffffffe00020247c:	ed858593          	addi	a1,a1,-296 # ffffffe000204350 <_srodata+0x350>
ffffffe000202480:	00002517          	auipc	a0,0x2
ffffffe000202484:	f1850513          	addi	a0,a0,-232 # ffffffe000204398 <_srodata+0x398>
ffffffe000202488:	15d010ef          	jal	ffffffe000203de4 <printk>
ffffffe00020248c:	00000013          	nop
ffffffe000202490:	ffdff06f          	j	ffffffe00020248c <do_page_fault+0x130>
        }
    }

    // 其他情况合法，按接下来的流程创建映射
    // 3.分配一个页，接下来要将这个页映射到对应的用户地址空间
    uint64_t page = alloc_page();
ffffffe000202494:	cbcfe0ef          	jal	ffffffe000200950 <alloc_page>
ffffffe000202498:	00050793          	mv	a5,a0
ffffffe00020249c:	faf43c23          	sd	a5,-72(s0)

    // 4.初始化匿名页
    if (vma->vm_flags & VM_ANON) { // 如果是匿名空间，则清零并直接映射即可
ffffffe0002024a0:	fc043783          	ld	a5,-64(s0)
ffffffe0002024a4:	0287b783          	ld	a5,40(a5)
ffffffe0002024a8:	0017f793          	andi	a5,a5,1
ffffffe0002024ac:	00078e63          	beqz	a5,ffffffe0002024c8 <do_page_fault+0x16c>
        memset((void *)page, 0, PGSIZE);
ffffffe0002024b0:	fb843783          	ld	a5,-72(s0)
ffffffe0002024b4:	00001637          	lui	a2,0x1
ffffffe0002024b8:	00000593          	li	a1,0
ffffffe0002024bc:	00078513          	mv	a0,a5
ffffffe0002024c0:	245010ef          	jal	ffffffe000203f04 <memset>
ffffffe0002024c4:	1100006f          	j	ffffffe0002025d4 <do_page_fault+0x278>
    } else { // 如果不是匿名空间，则需要从 ELF 中读取数据，填充后映射到用户空间
        uint64_t seg_start = (uint64_t)_sramdisk + vma->vm_pgoff; // 段在物理内存中的起始地址
ffffffe0002024c8:	fc043783          	ld	a5,-64(s0)
ffffffe0002024cc:	0307b703          	ld	a4,48(a5)
ffffffe0002024d0:	00004797          	auipc	a5,0x4
ffffffe0002024d4:	b3078793          	addi	a5,a5,-1232 # ffffffe000206000 <_sramdisk>
ffffffe0002024d8:	00f707b3          	add	a5,a4,a5
ffffffe0002024dc:	faf43823          	sd	a5,-80(s0)
        uint64_t seg_end = seg_start + vma->vm_filesz;           // 段在物理内存中的结束地址
ffffffe0002024e0:	fc043783          	ld	a5,-64(s0)
ffffffe0002024e4:	0387b783          	ld	a5,56(a5)
ffffffe0002024e8:	fb043703          	ld	a4,-80(s0)
ffffffe0002024ec:	00f707b3          	add	a5,a4,a5
ffffffe0002024f0:	faf43423          	sd	a5,-88(s0)
        uint64_t stval_start = seg_start + PGROUNDDOWN(stval) - vma->vm_start; // 错误发生页的起始地址
ffffffe0002024f4:	fd843703          	ld	a4,-40(s0)
ffffffe0002024f8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002024fc:	00f77733          	and	a4,a4,a5
ffffffe000202500:	fb043783          	ld	a5,-80(s0)
ffffffe000202504:	00f70733          	add	a4,a4,a5
ffffffe000202508:	fc043783          	ld	a5,-64(s0)
ffffffe00020250c:	0087b783          	ld	a5,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000202510:	40f707b3          	sub	a5,a4,a5
ffffffe000202514:	faf43023          	sd	a5,-96(s0)

        uint64_t offset = 0; // 偏移 -- 确定从当前页的哪个位置开始填充
ffffffe000202518:	fe043423          	sd	zero,-24(s0)
        if (PGROUNDDOWN(stval) == PGROUNDDOWN(seg_start)) { // 同页，从 stval 错误发生的地方开始复制
ffffffe00020251c:	fd843703          	ld	a4,-40(s0)
ffffffe000202520:	fb043783          	ld	a5,-80(s0)
ffffffe000202524:	00f74733          	xor	a4,a4,a5
ffffffe000202528:	000017b7          	lui	a5,0x1
ffffffe00020252c:	00f77c63          	bgeu	a4,a5,ffffffe000202544 <do_page_fault+0x1e8>
            offset = stval & (PGSIZE - 1);
ffffffe000202530:	fd843703          	ld	a4,-40(s0)
ffffffe000202534:	000017b7          	lui	a5,0x1
ffffffe000202538:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020253c:	00f777b3          	and	a5,a4,a5
ffffffe000202540:	fef43423          	sd	a5,-24(s0)
        }

        uint64_t valid_seg = 0; // 计算有效段大小
ffffffe000202544:	fe043023          	sd	zero,-32(s0)
        if (seg_end > stval_start && seg_end <= stval_start + PGSIZE) {
ffffffe000202548:	fa843703          	ld	a4,-88(s0)
ffffffe00020254c:	fa043783          	ld	a5,-96(s0)
ffffffe000202550:	02e7fa63          	bgeu	a5,a4,ffffffe000202584 <do_page_fault+0x228>
ffffffe000202554:	fa043703          	ld	a4,-96(s0)
ffffffe000202558:	000017b7          	lui	a5,0x1
ffffffe00020255c:	00f707b3          	add	a5,a4,a5
ffffffe000202560:	fa843703          	ld	a4,-88(s0)
ffffffe000202564:	02e7e063          	bltu	a5,a4,ffffffe000202584 <do_page_fault+0x228>
            valid_seg = seg_end - stval_start - offset;
ffffffe000202568:	fa843703          	ld	a4,-88(s0)
ffffffe00020256c:	fa043783          	ld	a5,-96(s0)
ffffffe000202570:	40f70733          	sub	a4,a4,a5
ffffffe000202574:	fe843783          	ld	a5,-24(s0)
ffffffe000202578:	40f707b3          	sub	a5,a4,a5
ffffffe00020257c:	fef43023          	sd	a5,-32(s0)
ffffffe000202580:	0280006f          	j	ffffffe0002025a8 <do_page_fault+0x24c>
        } else if (seg_end > stval_start + PGSIZE) {
ffffffe000202584:	fa043703          	ld	a4,-96(s0)
ffffffe000202588:	000017b7          	lui	a5,0x1
ffffffe00020258c:	00f707b3          	add	a5,a4,a5
ffffffe000202590:	fa843703          	ld	a4,-88(s0)
ffffffe000202594:	00e7fa63          	bgeu	a5,a4,ffffffe0002025a8 <do_page_fault+0x24c>
            valid_seg = PGSIZE - offset;
ffffffe000202598:	00001737          	lui	a4,0x1
ffffffe00020259c:	fe843783          	ld	a5,-24(s0)
ffffffe0002025a0:	40f707b3          	sub	a5,a4,a5
ffffffe0002025a4:	fef43023          	sd	a5,-32(s0)
        }

        if (valid_seg > 0) { // 进行数据拷贝
ffffffe0002025a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002025ac:	02078463          	beqz	a5,ffffffe0002025d4 <do_page_fault+0x278>
            memcpy((void *)(page + offset), (void *)stval_start, valid_seg);
ffffffe0002025b0:	fb843703          	ld	a4,-72(s0)
ffffffe0002025b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002025b8:	00f707b3          	add	a5,a4,a5
ffffffe0002025bc:	00078713          	mv	a4,a5
ffffffe0002025c0:	fa043783          	ld	a5,-96(s0)
ffffffe0002025c4:	fe043603          	ld	a2,-32(s0)
ffffffe0002025c8:	00078593          	mv	a1,a5
ffffffe0002025cc:	00070513          	mv	a0,a4
ffffffe0002025d0:	ed0fe0ef          	jal	ffffffe000200ca0 <memcpy>
        }
    }

    // 5.映射页面到用户地址空间
    uint64_t perm = (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) | (1 << 0) | (1 << 4); // 添加权限
ffffffe0002025d4:	fc043783          	ld	a5,-64(s0)
ffffffe0002025d8:	0287b783          	ld	a5,40(a5) # 1028 <PGSIZE+0x28>
ffffffe0002025dc:	00e7f793          	andi	a5,a5,14
ffffffe0002025e0:	0117e793          	ori	a5,a5,17
ffffffe0002025e4:	f8f43c23          	sd	a5,-104(s0)
    create_mapping(current->pgd, PGROUNDDOWN(stval), page - PA2VA_OFFSET, PGSIZE, perm);
ffffffe0002025e8:	00008797          	auipc	a5,0x8
ffffffe0002025ec:	a2878793          	addi	a5,a5,-1496 # ffffffe00020a010 <current>
ffffffe0002025f0:	0007b783          	ld	a5,0(a5)
ffffffe0002025f4:	0a87b503          	ld	a0,168(a5)
ffffffe0002025f8:	fd843703          	ld	a4,-40(s0)
ffffffe0002025fc:	fffff7b7          	lui	a5,0xfffff
ffffffe000202600:	00f775b3          	and	a1,a4,a5
ffffffe000202604:	fb843703          	ld	a4,-72(s0)
ffffffe000202608:	04100793          	li	a5,65
ffffffe00020260c:	01f79793          	slli	a5,a5,0x1f
ffffffe000202610:	00f707b3          	add	a5,a4,a5
ffffffe000202614:	f9843703          	ld	a4,-104(s0)
ffffffe000202618:	000016b7          	lui	a3,0x1
ffffffe00020261c:	00078613          	mv	a2,a5
ffffffe000202620:	704000ef          	jal	ffffffe000202d24 <create_mapping>
}
ffffffe000202624:	07813083          	ld	ra,120(sp)
ffffffe000202628:	07013403          	ld	s0,112(sp)
ffffffe00020262c:	08010113          	addi	sp,sp,128
ffffffe000202630:	00008067          	ret

ffffffe000202634 <trap_handler>:

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
ffffffe000202634:	fd010113          	addi	sp,sp,-48
ffffffe000202638:	02113423          	sd	ra,40(sp)
ffffffe00020263c:	02813023          	sd	s0,32(sp)
ffffffe000202640:	03010413          	addi	s0,sp,48
ffffffe000202644:	fea43423          	sd	a0,-24(s0)
ffffffe000202648:	feb43023          	sd	a1,-32(s0)
ffffffe00020264c:	fcc43c23          	sd	a2,-40(s0)
    // uint64_t scause = csr_read(scause);
    // printk("scause: %lx\n", scause);
    // 通过 `scause` 判断 trap 类型
    
    if((scause>>63)==1) // interrupt=1
ffffffe000202650:	fe843783          	ld	a5,-24(s0)
ffffffe000202654:	03f7d713          	srli	a4,a5,0x3f
ffffffe000202658:	00100793          	li	a5,1
ffffffe00020265c:	0af71c63          	bne	a4,a5,ffffffe000202714 <trap_handler+0xe0>
    {
        // 如果是 interrupt 判断是否是 timer interrupt
        if(((scause<<1)>>1)==5)
ffffffe000202660:	fe843703          	ld	a4,-24(s0)
ffffffe000202664:	fff00793          	li	a5,-1
ffffffe000202668:	0017d793          	srli	a5,a5,0x1
ffffffe00020266c:	00f77733          	and	a4,a4,a5
ffffffe000202670:	00500793          	li	a5,5
ffffffe000202674:	00f71863          	bne	a4,a5,ffffffe000202684 <trap_handler+0x50>
        {
            // 通过 `clock_set_next_event()` 设置下一次时钟中断
            clock_set_next_event();
ffffffe000202678:	c75fd0ef          	jal	ffffffe0002002ec <clock_set_next_event>
            do_timer();
ffffffe00020267c:	974ff0ef          	jal	ffffffe0002017f0 <do_timer>
        }else
        {
            Err("Reserved\n");
        }
    }
    return;
ffffffe000202680:	4280006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==1)
ffffffe000202684:	fe843703          	ld	a4,-24(s0)
ffffffe000202688:	fff00793          	li	a5,-1
ffffffe00020268c:	0017d793          	srli	a5,a5,0x1
ffffffe000202690:	00f77733          	and	a4,a4,a5
ffffffe000202694:	00100793          	li	a5,1
ffffffe000202698:	00f71e63          	bne	a4,a5,ffffffe0002026b4 <trap_handler+0x80>
            printk("%s\n","[S] Supervisor Mode Software Interrupt");
ffffffe00020269c:	00002597          	auipc	a1,0x2
ffffffe0002026a0:	d4c58593          	addi	a1,a1,-692 # ffffffe0002043e8 <_srodata+0x3e8>
ffffffe0002026a4:	00002517          	auipc	a0,0x2
ffffffe0002026a8:	d6c50513          	addi	a0,a0,-660 # ffffffe000204410 <_srodata+0x410>
ffffffe0002026ac:	738010ef          	jal	ffffffe000203de4 <printk>
    return;
ffffffe0002026b0:	3f80006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==9)
ffffffe0002026b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002026b8:	fff00793          	li	a5,-1
ffffffe0002026bc:	0017d793          	srli	a5,a5,0x1
ffffffe0002026c0:	00f77733          	and	a4,a4,a5
ffffffe0002026c4:	00900793          	li	a5,9
ffffffe0002026c8:	00f71e63          	bne	a4,a5,ffffffe0002026e4 <trap_handler+0xb0>
            printk("%s\n","[S] Supervisor Mode External Interrupt");
ffffffe0002026cc:	00002597          	auipc	a1,0x2
ffffffe0002026d0:	d4c58593          	addi	a1,a1,-692 # ffffffe000204418 <_srodata+0x418>
ffffffe0002026d4:	00002517          	auipc	a0,0x2
ffffffe0002026d8:	d3c50513          	addi	a0,a0,-708 # ffffffe000204410 <_srodata+0x410>
ffffffe0002026dc:	708010ef          	jal	ffffffe000203de4 <printk>
    return;
ffffffe0002026e0:	3c80006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==13)
ffffffe0002026e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002026e8:	fff00793          	li	a5,-1
ffffffe0002026ec:	0017d793          	srli	a5,a5,0x1
ffffffe0002026f0:	00f77733          	and	a4,a4,a5
ffffffe0002026f4:	00d00793          	li	a5,13
ffffffe0002026f8:	3af71863          	bne	a4,a5,ffffffe000202aa8 <trap_handler+0x474>
            printk("%s\n","[S] Counter-overflow Interrupt");
ffffffe0002026fc:	00002597          	auipc	a1,0x2
ffffffe000202700:	d4458593          	addi	a1,a1,-700 # ffffffe000204440 <_srodata+0x440>
ffffffe000202704:	00002517          	auipc	a0,0x2
ffffffe000202708:	d0c50513          	addi	a0,a0,-756 # ffffffe000204410 <_srodata+0x410>
ffffffe00020270c:	6d8010ef          	jal	ffffffe000203de4 <printk>
    return;
ffffffe000202710:	3980006f          	j	ffffffe000202aa8 <trap_handler+0x474>
    }else if((scause>>63)==0)  //interrupt=0
ffffffe000202714:	fe843783          	ld	a5,-24(s0)
ffffffe000202718:	3807c863          	bltz	a5,ffffffe000202aa8 <trap_handler+0x474>
        if(((scause<<1)>>1)==8) 
ffffffe00020271c:	fe843703          	ld	a4,-24(s0)
ffffffe000202720:	fff00793          	li	a5,-1
ffffffe000202724:	0017d793          	srli	a5,a5,0x1
ffffffe000202728:	00f77733          	and	a4,a4,a5
ffffffe00020272c:	00800793          	li	a5,8
ffffffe000202730:	0af71063          	bne	a4,a5,ffffffe0002027d0 <trap_handler+0x19c>
            switch (regs->x[17])    // a7
ffffffe000202734:	fd843783          	ld	a5,-40(s0)
ffffffe000202738:	0887b783          	ld	a5,136(a5) # fffffffffffff088 <VM_END+0xfffff088>
ffffffe00020273c:	0dc00713          	li	a4,220
ffffffe000202740:	06e78063          	beq	a5,a4,ffffffe0002027a0 <trap_handler+0x16c>
ffffffe000202744:	0dc00713          	li	a4,220
ffffffe000202748:	06f76663          	bltu	a4,a5,ffffffe0002027b4 <trap_handler+0x180>
ffffffe00020274c:	04000713          	li	a4,64
ffffffe000202750:	00e78863          	beq	a5,a4,ffffffe000202760 <trap_handler+0x12c>
ffffffe000202754:	0ac00713          	li	a4,172
ffffffe000202758:	02e78e63          	beq	a5,a4,ffffffe000202794 <trap_handler+0x160>
                    break;
ffffffe00020275c:	0580006f          	j	ffffffe0002027b4 <trap_handler+0x180>
                    sys_write(regs->x[10],(const char*)regs->x[11],(size_t)regs->x[12],regs); // a0,a1,a2
ffffffe000202760:	fd843783          	ld	a5,-40(s0)
ffffffe000202764:	0507b783          	ld	a5,80(a5)
ffffffe000202768:	0007871b          	sext.w	a4,a5
ffffffe00020276c:	fd843783          	ld	a5,-40(s0)
ffffffe000202770:	0587b783          	ld	a5,88(a5)
ffffffe000202774:	00078593          	mv	a1,a5
ffffffe000202778:	fd843783          	ld	a5,-40(s0)
ffffffe00020277c:	0607b783          	ld	a5,96(a5)
ffffffe000202780:	fd843683          	ld	a3,-40(s0)
ffffffe000202784:	00078613          	mv	a2,a5
ffffffe000202788:	00070513          	mv	a0,a4
ffffffe00020278c:	e60ff0ef          	jal	ffffffe000201dec <sys_write>
                    break;
ffffffe000202790:	0280006f          	j	ffffffe0002027b8 <trap_handler+0x184>
                    sys_getpid(regs);
ffffffe000202794:	fd843503          	ld	a0,-40(s0)
ffffffe000202798:	ef8ff0ef          	jal	ffffffe000201e90 <sys_getpid>
                    break;
ffffffe00020279c:	01c0006f          	j	ffffffe0002027b8 <trap_handler+0x184>
                    regs->x[10]=do_fork(regs);
ffffffe0002027a0:	fd843503          	ld	a0,-40(s0)
ffffffe0002027a4:	835ff0ef          	jal	ffffffe000201fd8 <do_fork>
ffffffe0002027a8:	00050713          	mv	a4,a0
ffffffe0002027ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002027b0:	04e7b823          	sd	a4,80(a5)
                    break;
ffffffe0002027b4:	00000013          	nop
            regs->sepc += 4;
ffffffe0002027b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002027bc:	1007b783          	ld	a5,256(a5)
ffffffe0002027c0:	00478713          	addi	a4,a5,4
ffffffe0002027c4:	fd843783          	ld	a5,-40(s0)
ffffffe0002027c8:	10e7b023          	sd	a4,256(a5)
    return;
ffffffe0002027cc:	2dc0006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==0||((scause<<1)>>1)==1||((scause<<1)>>1)==2)
ffffffe0002027d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002027d4:	fff00793          	li	a5,-1
ffffffe0002027d8:	0017d793          	srli	a5,a5,0x1
ffffffe0002027dc:	00f777b3          	and	a5,a4,a5
ffffffe0002027e0:	02078a63          	beqz	a5,ffffffe000202814 <trap_handler+0x1e0>
ffffffe0002027e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002027e8:	fff00793          	li	a5,-1
ffffffe0002027ec:	0017d793          	srli	a5,a5,0x1
ffffffe0002027f0:	00f77733          	and	a4,a4,a5
ffffffe0002027f4:	00100793          	li	a5,1
ffffffe0002027f8:	00f70e63          	beq	a4,a5,ffffffe000202814 <trap_handler+0x1e0>
ffffffe0002027fc:	fe843703          	ld	a4,-24(s0)
ffffffe000202800:	fff00793          	li	a5,-1
ffffffe000202804:	0017d793          	srli	a5,a5,0x1
ffffffe000202808:	00f77733          	and	a4,a4,a5
ffffffe00020280c:	00200793          	li	a5,2
ffffffe000202810:	02f71663          	bne	a4,a5,ffffffe00020283c <trap_handler+0x208>
            Err("Instruction exception\n");
ffffffe000202814:	00002697          	auipc	a3,0x2
ffffffe000202818:	e0c68693          	addi	a3,a3,-500 # ffffffe000204620 <__func__.0>
ffffffe00020281c:	07400613          	li	a2,116
ffffffe000202820:	00002597          	auipc	a1,0x2
ffffffe000202824:	b3058593          	addi	a1,a1,-1232 # ffffffe000204350 <_srodata+0x350>
ffffffe000202828:	00002517          	auipc	a0,0x2
ffffffe00020282c:	c3850513          	addi	a0,a0,-968 # ffffffe000204460 <_srodata+0x460>
ffffffe000202830:	5b4010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202834:	00000013          	nop
ffffffe000202838:	ffdff06f          	j	ffffffe000202834 <trap_handler+0x200>
        }else if(((scause<<1)>>1)==3)
ffffffe00020283c:	fe843703          	ld	a4,-24(s0)
ffffffe000202840:	fff00793          	li	a5,-1
ffffffe000202844:	0017d793          	srli	a5,a5,0x1
ffffffe000202848:	00f77733          	and	a4,a4,a5
ffffffe00020284c:	00300793          	li	a5,3
ffffffe000202850:	02f71663          	bne	a4,a5,ffffffe00020287c <trap_handler+0x248>
            Err("Breakpoint\n");
ffffffe000202854:	00002697          	auipc	a3,0x2
ffffffe000202858:	dcc68693          	addi	a3,a3,-564 # ffffffe000204620 <__func__.0>
ffffffe00020285c:	07700613          	li	a2,119
ffffffe000202860:	00002597          	auipc	a1,0x2
ffffffe000202864:	af058593          	addi	a1,a1,-1296 # ffffffe000204350 <_srodata+0x350>
ffffffe000202868:	00002517          	auipc	a0,0x2
ffffffe00020286c:	c2850513          	addi	a0,a0,-984 # ffffffe000204490 <_srodata+0x490>
ffffffe000202870:	574010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202874:	00000013          	nop
ffffffe000202878:	ffdff06f          	j	ffffffe000202874 <trap_handler+0x240>
        }else if(((scause<<1)>>1)==4||((scause<<1)>>1)==5)
ffffffe00020287c:	fe843703          	ld	a4,-24(s0)
ffffffe000202880:	fff00793          	li	a5,-1
ffffffe000202884:	0017d793          	srli	a5,a5,0x1
ffffffe000202888:	00f77733          	and	a4,a4,a5
ffffffe00020288c:	00400793          	li	a5,4
ffffffe000202890:	00f70e63          	beq	a4,a5,ffffffe0002028ac <trap_handler+0x278>
ffffffe000202894:	fe843703          	ld	a4,-24(s0)
ffffffe000202898:	fff00793          	li	a5,-1
ffffffe00020289c:	0017d793          	srli	a5,a5,0x1
ffffffe0002028a0:	00f77733          	and	a4,a4,a5
ffffffe0002028a4:	00500793          	li	a5,5
ffffffe0002028a8:	02f71663          	bne	a4,a5,ffffffe0002028d4 <trap_handler+0x2a0>
            Err("Load exception\n");
ffffffe0002028ac:	00002697          	auipc	a3,0x2
ffffffe0002028b0:	d7468693          	addi	a3,a3,-652 # ffffffe000204620 <__func__.0>
ffffffe0002028b4:	07a00613          	li	a2,122
ffffffe0002028b8:	00002597          	auipc	a1,0x2
ffffffe0002028bc:	a9858593          	addi	a1,a1,-1384 # ffffffe000204350 <_srodata+0x350>
ffffffe0002028c0:	00002517          	auipc	a0,0x2
ffffffe0002028c4:	bf850513          	addi	a0,a0,-1032 # ffffffe0002044b8 <_srodata+0x4b8>
ffffffe0002028c8:	51c010ef          	jal	ffffffe000203de4 <printk>
ffffffe0002028cc:	00000013          	nop
ffffffe0002028d0:	ffdff06f          	j	ffffffe0002028cc <trap_handler+0x298>
        }else if(((scause<<1)>>1)==6||((scause<<1)>>1)==7)
ffffffe0002028d4:	fe843703          	ld	a4,-24(s0)
ffffffe0002028d8:	fff00793          	li	a5,-1
ffffffe0002028dc:	0017d793          	srli	a5,a5,0x1
ffffffe0002028e0:	00f77733          	and	a4,a4,a5
ffffffe0002028e4:	00600793          	li	a5,6
ffffffe0002028e8:	00f70e63          	beq	a4,a5,ffffffe000202904 <trap_handler+0x2d0>
ffffffe0002028ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002028f0:	fff00793          	li	a5,-1
ffffffe0002028f4:	0017d793          	srli	a5,a5,0x1
ffffffe0002028f8:	00f77733          	and	a4,a4,a5
ffffffe0002028fc:	00700793          	li	a5,7
ffffffe000202900:	02f71663          	bne	a4,a5,ffffffe00020292c <trap_handler+0x2f8>
            Err("Store/AMO exception\n");
ffffffe000202904:	00002697          	auipc	a3,0x2
ffffffe000202908:	d1c68693          	addi	a3,a3,-740 # ffffffe000204620 <__func__.0>
ffffffe00020290c:	07d00613          	li	a2,125
ffffffe000202910:	00002597          	auipc	a1,0x2
ffffffe000202914:	a4058593          	addi	a1,a1,-1472 # ffffffe000204350 <_srodata+0x350>
ffffffe000202918:	00002517          	auipc	a0,0x2
ffffffe00020291c:	bc850513          	addi	a0,a0,-1080 # ffffffe0002044e0 <_srodata+0x4e0>
ffffffe000202920:	4c4010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202924:	00000013          	nop
ffffffe000202928:	ffdff06f          	j	ffffffe000202924 <trap_handler+0x2f0>
        }else if(((scause<<1)>>1)==8||((scause<<1)>>1)==9)
ffffffe00020292c:	fe843703          	ld	a4,-24(s0)
ffffffe000202930:	fff00793          	li	a5,-1
ffffffe000202934:	0017d793          	srli	a5,a5,0x1
ffffffe000202938:	00f77733          	and	a4,a4,a5
ffffffe00020293c:	00800793          	li	a5,8
ffffffe000202940:	00f70e63          	beq	a4,a5,ffffffe00020295c <trap_handler+0x328>
ffffffe000202944:	fe843703          	ld	a4,-24(s0)
ffffffe000202948:	fff00793          	li	a5,-1
ffffffe00020294c:	0017d793          	srli	a5,a5,0x1
ffffffe000202950:	00f77733          	and	a4,a4,a5
ffffffe000202954:	00900793          	li	a5,9
ffffffe000202958:	00f71c63          	bne	a4,a5,ffffffe000202970 <trap_handler+0x33c>
            printk("Environment call exception\n");
ffffffe00020295c:	00002517          	auipc	a0,0x2
ffffffe000202960:	bb450513          	addi	a0,a0,-1100 # ffffffe000204510 <_srodata+0x510>
ffffffe000202964:	480010ef          	jal	ffffffe000203de4 <printk>
    return;
ffffffe000202968:	00000013          	nop
ffffffe00020296c:	13c0006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==12)
ffffffe000202970:	fe843703          	ld	a4,-24(s0)
ffffffe000202974:	fff00793          	li	a5,-1
ffffffe000202978:	0017d793          	srli	a5,a5,0x1
ffffffe00020297c:	00f77733          	and	a4,a4,a5
ffffffe000202980:	00c00793          	li	a5,12
ffffffe000202984:	00f71e63          	bne	a4,a5,ffffffe0002029a0 <trap_handler+0x36c>
            printk(RED"Instruction page fault\n"CLEAR);
ffffffe000202988:	00002517          	auipc	a0,0x2
ffffffe00020298c:	ba850513          	addi	a0,a0,-1112 # ffffffe000204530 <_srodata+0x530>
ffffffe000202990:	454010ef          	jal	ffffffe000203de4 <printk>
            do_page_fault(regs);
ffffffe000202994:	fd843503          	ld	a0,-40(s0)
ffffffe000202998:	9c5ff0ef          	jal	ffffffe00020235c <do_page_fault>
    return;
ffffffe00020299c:	10c0006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==13)
ffffffe0002029a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002029a4:	fff00793          	li	a5,-1
ffffffe0002029a8:	0017d793          	srli	a5,a5,0x1
ffffffe0002029ac:	00f77733          	and	a4,a4,a5
ffffffe0002029b0:	00d00793          	li	a5,13
ffffffe0002029b4:	00f71e63          	bne	a4,a5,ffffffe0002029d0 <trap_handler+0x39c>
            printk(RED"Load page fault\n"CLEAR);
ffffffe0002029b8:	00002517          	auipc	a0,0x2
ffffffe0002029bc:	ba050513          	addi	a0,a0,-1120 # ffffffe000204558 <_srodata+0x558>
ffffffe0002029c0:	424010ef          	jal	ffffffe000203de4 <printk>
            do_page_fault(regs);
ffffffe0002029c4:	fd843503          	ld	a0,-40(s0)
ffffffe0002029c8:	995ff0ef          	jal	ffffffe00020235c <do_page_fault>
    return;
ffffffe0002029cc:	0dc0006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==15)
ffffffe0002029d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002029d4:	fff00793          	li	a5,-1
ffffffe0002029d8:	0017d793          	srli	a5,a5,0x1
ffffffe0002029dc:	00f77733          	and	a4,a4,a5
ffffffe0002029e0:	00f00793          	li	a5,15
ffffffe0002029e4:	00f71e63          	bne	a4,a5,ffffffe000202a00 <trap_handler+0x3cc>
            printk(RED"Store/AMO page fault\n"CLEAR);
ffffffe0002029e8:	00002517          	auipc	a0,0x2
ffffffe0002029ec:	b9050513          	addi	a0,a0,-1136 # ffffffe000204578 <_srodata+0x578>
ffffffe0002029f0:	3f4010ef          	jal	ffffffe000203de4 <printk>
            do_page_fault(regs);
ffffffe0002029f4:	fd843503          	ld	a0,-40(s0)
ffffffe0002029f8:	965ff0ef          	jal	ffffffe00020235c <do_page_fault>
    return;
ffffffe0002029fc:	0ac0006f          	j	ffffffe000202aa8 <trap_handler+0x474>
        }else if(((scause<<1)>>1)==18)
ffffffe000202a00:	fe843703          	ld	a4,-24(s0)
ffffffe000202a04:	fff00793          	li	a5,-1
ffffffe000202a08:	0017d793          	srli	a5,a5,0x1
ffffffe000202a0c:	00f77733          	and	a4,a4,a5
ffffffe000202a10:	01200793          	li	a5,18
ffffffe000202a14:	02f71663          	bne	a4,a5,ffffffe000202a40 <trap_handler+0x40c>
            Err("Software check\n");
ffffffe000202a18:	00002697          	auipc	a3,0x2
ffffffe000202a1c:	c0868693          	addi	a3,a3,-1016 # ffffffe000204620 <__func__.0>
ffffffe000202a20:	08f00613          	li	a2,143
ffffffe000202a24:	00002597          	auipc	a1,0x2
ffffffe000202a28:	92c58593          	addi	a1,a1,-1748 # ffffffe000204350 <_srodata+0x350>
ffffffe000202a2c:	00002517          	auipc	a0,0x2
ffffffe000202a30:	b6c50513          	addi	a0,a0,-1172 # ffffffe000204598 <_srodata+0x598>
ffffffe000202a34:	3b0010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202a38:	00000013          	nop
ffffffe000202a3c:	ffdff06f          	j	ffffffe000202a38 <trap_handler+0x404>
        }else if(((scause<<1)>>1)==19)
ffffffe000202a40:	fe843703          	ld	a4,-24(s0)
ffffffe000202a44:	fff00793          	li	a5,-1
ffffffe000202a48:	0017d793          	srli	a5,a5,0x1
ffffffe000202a4c:	00f77733          	and	a4,a4,a5
ffffffe000202a50:	01300793          	li	a5,19
ffffffe000202a54:	02f71663          	bne	a4,a5,ffffffe000202a80 <trap_handler+0x44c>
            Err("Hardware error\n");
ffffffe000202a58:	00002697          	auipc	a3,0x2
ffffffe000202a5c:	bc868693          	addi	a3,a3,-1080 # ffffffe000204620 <__func__.0>
ffffffe000202a60:	09200613          	li	a2,146
ffffffe000202a64:	00002597          	auipc	a1,0x2
ffffffe000202a68:	8ec58593          	addi	a1,a1,-1812 # ffffffe000204350 <_srodata+0x350>
ffffffe000202a6c:	00002517          	auipc	a0,0x2
ffffffe000202a70:	b5450513          	addi	a0,a0,-1196 # ffffffe0002045c0 <_srodata+0x5c0>
ffffffe000202a74:	370010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202a78:	00000013          	nop
ffffffe000202a7c:	ffdff06f          	j	ffffffe000202a78 <trap_handler+0x444>
            Err("Reserved\n");
ffffffe000202a80:	00002697          	auipc	a3,0x2
ffffffe000202a84:	ba068693          	addi	a3,a3,-1120 # ffffffe000204620 <__func__.0>
ffffffe000202a88:	09500613          	li	a2,149
ffffffe000202a8c:	00002597          	auipc	a1,0x2
ffffffe000202a90:	8c458593          	addi	a1,a1,-1852 # ffffffe000204350 <_srodata+0x350>
ffffffe000202a94:	00002517          	auipc	a0,0x2
ffffffe000202a98:	b5450513          	addi	a0,a0,-1196 # ffffffe0002045e8 <_srodata+0x5e8>
ffffffe000202a9c:	348010ef          	jal	ffffffe000203de4 <printk>
ffffffe000202aa0:	00000013          	nop
ffffffe000202aa4:	ffdff06f          	j	ffffffe000202aa0 <trap_handler+0x46c>
    return;
ffffffe000202aa8:	00000013          	nop
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
ffffffe000202aac:	02813083          	ld	ra,40(sp)
ffffffe000202ab0:	02013403          	ld	s0,32(sp)
ffffffe000202ab4:	03010113          	addi	sp,sp,48
ffffffe000202ab8:	00008067          	ret

ffffffe000202abc <setup_vm>:

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() 
{
ffffffe000202abc:	fd010113          	addi	sp,sp,-48
ffffffe000202ac0:	02113423          	sd	ra,40(sp)
ffffffe000202ac4:	02813023          	sd	s0,32(sp)
ffffffe000202ac8:	03010413          	addi	s0,sp,48
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/

    // 初始化页表
    memset(early_pgtbl, 0x0,PGSIZE);
ffffffe000202acc:	00001637          	lui	a2,0x1
ffffffe000202ad0:	00000593          	li	a1,0
ffffffe000202ad4:	00008517          	auipc	a0,0x8
ffffffe000202ad8:	52c50513          	addi	a0,a0,1324 # ffffffe00020b000 <early_pgtbl>
ffffffe000202adc:	428010ef          	jal	ffffffe000203f04 <memset>

    uint64_t PA,VA;
    // 第一次等值映射
    PA = PHY_START;
ffffffe000202ae0:	00100793          	li	a5,1
ffffffe000202ae4:	01f79793          	slli	a5,a5,0x1f
ffffffe000202ae8:	fef43423          	sd	a5,-24(s0)
    VA = PA;
ffffffe000202aec:	fe843783          	ld	a5,-24(s0)
ffffffe000202af0:	fef43023          	sd	a5,-32(s0)
    // 取index
    uint64_t VPN = (VA >> 30) & 0x1ff;          // 9bit
ffffffe000202af4:	fe043783          	ld	a5,-32(s0)
ffffffe000202af8:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202afc:	1ff7f793          	andi	a5,a5,511
ffffffe000202b00:	fcf43c23          	sd	a5,-40(s0)
    uint64_t PPN = (PA >> 30) & 0x3ffffff;      // 26bit
ffffffe000202b04:	fe843783          	ld	a5,-24(s0)
ffffffe000202b08:	01e7d713          	srli	a4,a5,0x1e
ffffffe000202b0c:	040007b7          	lui	a5,0x4000
ffffffe000202b10:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000202b14:	00f777b3          	and	a5,a4,a5
ffffffe000202b18:	fcf43823          	sd	a5,-48(s0)
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 9+9+10 设置权限位1111
ffffffe000202b1c:	fd043783          	ld	a5,-48(s0)
ffffffe000202b20:	01c79793          	slli	a5,a5,0x1c
ffffffe000202b24:	00f7e713          	ori	a4,a5,15
ffffffe000202b28:	00008697          	auipc	a3,0x8
ffffffe000202b2c:	4d868693          	addi	a3,a3,1240 # ffffffe00020b000 <early_pgtbl>
ffffffe000202b30:	fd843783          	ld	a5,-40(s0)
ffffffe000202b34:	00379793          	slli	a5,a5,0x3
ffffffe000202b38:	00f687b3          	add	a5,a3,a5
ffffffe000202b3c:	00e7b023          	sd	a4,0(a5)

    // 第二次等值映射
    VA = VM_START;
ffffffe000202b40:	fff00793          	li	a5,-1
ffffffe000202b44:	02579793          	slli	a5,a5,0x25
ffffffe000202b48:	fef43023          	sd	a5,-32(s0)
    VPN = (VA >> 30) & 0x1ff;                   // 9bit
ffffffe000202b4c:	fe043783          	ld	a5,-32(s0)
ffffffe000202b50:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202b54:	1ff7f793          	andi	a5,a5,511
ffffffe000202b58:	fcf43c23          	sd	a5,-40(s0)
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 设置权限为1111
ffffffe000202b5c:	fd043783          	ld	a5,-48(s0)
ffffffe000202b60:	01c79793          	slli	a5,a5,0x1c
ffffffe000202b64:	00f7e713          	ori	a4,a5,15
ffffffe000202b68:	00008697          	auipc	a3,0x8
ffffffe000202b6c:	49868693          	addi	a3,a3,1176 # ffffffe00020b000 <early_pgtbl>
ffffffe000202b70:	fd843783          	ld	a5,-40(s0)
ffffffe000202b74:	00379793          	slli	a5,a5,0x3
ffffffe000202b78:	00f687b3          	add	a5,a3,a5
ffffffe000202b7c:	00e7b023          	sd	a4,0(a5)
    // VA = VM_START;
    // // 取index
    // uint64_t VPN = (VA >> 30) & 0x1ff;//9bit
    // uint64_t PPN = (PA >> 30) & 0x3ffffff;//26bit
    // early_pgtbl[VPN] = (PPN << 28) | 0b1111;//设置权限为1111
    printk("...setup_vm done!\n");
ffffffe000202b80:	00002517          	auipc	a0,0x2
ffffffe000202b84:	ab050513          	addi	a0,a0,-1360 # ffffffe000204630 <__func__.0+0x10>
ffffffe000202b88:	25c010ef          	jal	ffffffe000203de4 <printk>
}
ffffffe000202b8c:	00000013          	nop
ffffffe000202b90:	02813083          	ld	ra,40(sp)
ffffffe000202b94:	02013403          	ld	s0,32(sp)
ffffffe000202b98:	03010113          	addi	sp,sp,48
ffffffe000202b9c:	00008067          	ret

ffffffe000202ba0 <setup_vm_final>:
extern char _erodata[];
extern char _etext[];

// 完成对所有物理内存 (128M) 的映射，并设置正确的权限
void setup_vm_final() 
{
ffffffe000202ba0:	fb010113          	addi	sp,sp,-80
ffffffe000202ba4:	04113423          	sd	ra,72(sp)
ffffffe000202ba8:	04813023          	sd	s0,64(sp)
ffffffe000202bac:	05010413          	addi	s0,sp,80
    
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000202bb0:	00001637          	lui	a2,0x1
ffffffe000202bb4:	00000593          	li	a1,0
ffffffe000202bb8:	00009517          	auipc	a0,0x9
ffffffe000202bbc:	44850513          	addi	a0,a0,1096 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202bc0:	344010ef          	jal	ffffffe000203f04 <memset>

    // No OpenSBI mapping required
    uint64_t V = VM_START+OPENSBI_SIZE;
ffffffe000202bc4:	f00017b7          	lui	a5,0xf0001
ffffffe000202bc8:	00979793          	slli	a5,a5,0x9
ffffffe000202bcc:	fef43423          	sd	a5,-24(s0)
    uint64_t P = PHY_START+OPENSBI_SIZE;
ffffffe000202bd0:	40100793          	li	a5,1025
ffffffe000202bd4:	01579793          	slli	a5,a5,0x15
ffffffe000202bd8:	fef43023          	sd	a5,-32(s0)
    
    // mapping kernel text X|-|R|V
    uint64_t size=(uint64_t)_srodata-(uint64_t)_stext;
ffffffe000202bdc:	00001717          	auipc	a4,0x1
ffffffe000202be0:	42470713          	addi	a4,a4,1060 # ffffffe000204000 <_srodata>
ffffffe000202be4:	ffffd797          	auipc	a5,0xffffd
ffffffe000202be8:	41c78793          	addi	a5,a5,1052 # ffffffe000200000 <_skernel>
ffffffe000202bec:	40f707b3          	sub	a5,a4,a5
ffffffe000202bf0:	fcf43c23          	sd	a5,-40(s0)
    create_mapping(swapper_pg_dir,V,P,size,PERM_KERNEL_TEXT);
ffffffe000202bf4:	00b00713          	li	a4,11
ffffffe000202bf8:	fd843683          	ld	a3,-40(s0)
ffffffe000202bfc:	fe043603          	ld	a2,-32(s0)
ffffffe000202c00:	fe843583          	ld	a1,-24(s0)
ffffffe000202c04:	00009517          	auipc	a0,0x9
ffffffe000202c08:	3fc50513          	addi	a0,a0,1020 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202c0c:	118000ef          	jal	ffffffe000202d24 <create_mapping>
    
    // mapping kernel rodata -|-|R|V
    uint64_t size1=(uint64_t)_sdata-(uint64_t)_srodata;
ffffffe000202c10:	00002717          	auipc	a4,0x2
ffffffe000202c14:	3f070713          	addi	a4,a4,1008 # ffffffe000205000 <TIMECLOCK>
ffffffe000202c18:	00001797          	auipc	a5,0x1
ffffffe000202c1c:	3e878793          	addi	a5,a5,1000 # ffffffe000204000 <_srodata>
ffffffe000202c20:	40f707b3          	sub	a5,a4,a5
ffffffe000202c24:	fcf43823          	sd	a5,-48(s0)
    create_mapping(swapper_pg_dir,V+size,P+size,size1,PERM_KERNEL_RODATA);
ffffffe000202c28:	fe843703          	ld	a4,-24(s0)
ffffffe000202c2c:	fd843783          	ld	a5,-40(s0)
ffffffe000202c30:	00f705b3          	add	a1,a4,a5
ffffffe000202c34:	fe043703          	ld	a4,-32(s0)
ffffffe000202c38:	fd843783          	ld	a5,-40(s0)
ffffffe000202c3c:	00f707b3          	add	a5,a4,a5
ffffffe000202c40:	00300713          	li	a4,3
ffffffe000202c44:	fd043683          	ld	a3,-48(s0)
ffffffe000202c48:	00078613          	mv	a2,a5
ffffffe000202c4c:	00009517          	auipc	a0,0x9
ffffffe000202c50:	3b450513          	addi	a0,a0,948 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202c54:	0d0000ef          	jal	ffffffe000202d24 <create_mapping>
    
    // mapping other memory -|W|R|V
    uint64_t size2=PHY_SIZE-((uint64_t)_sdata-(uint64_t)_stext)-OPENSBI_SIZE;
ffffffe000202c58:	ffffd717          	auipc	a4,0xffffd
ffffffe000202c5c:	3a870713          	addi	a4,a4,936 # ffffffe000200000 <_skernel>
ffffffe000202c60:	080007b7          	lui	a5,0x8000
ffffffe000202c64:	00f70733          	add	a4,a4,a5
ffffffe000202c68:	ffe007b7          	lui	a5,0xffe00
ffffffe000202c6c:	00f70733          	add	a4,a4,a5
ffffffe000202c70:	00002797          	auipc	a5,0x2
ffffffe000202c74:	39078793          	addi	a5,a5,912 # ffffffe000205000 <TIMECLOCK>
ffffffe000202c78:	40f707b3          	sub	a5,a4,a5
ffffffe000202c7c:	fcf43423          	sd	a5,-56(s0)
    create_mapping(swapper_pg_dir,V+size+size1,P+size+size1,size2,PERM_KERNEL_DATA);
ffffffe000202c80:	fe843703          	ld	a4,-24(s0)
ffffffe000202c84:	fd843783          	ld	a5,-40(s0)
ffffffe000202c88:	00f70733          	add	a4,a4,a5
ffffffe000202c8c:	fd043783          	ld	a5,-48(s0)
ffffffe000202c90:	00f705b3          	add	a1,a4,a5
ffffffe000202c94:	fe043703          	ld	a4,-32(s0)
ffffffe000202c98:	fd843783          	ld	a5,-40(s0)
ffffffe000202c9c:	00f70733          	add	a4,a4,a5
ffffffe000202ca0:	fd043783          	ld	a5,-48(s0)
ffffffe000202ca4:	00f707b3          	add	a5,a4,a5
ffffffe000202ca8:	00700713          	li	a4,7
ffffffe000202cac:	fc843683          	ld	a3,-56(s0)
ffffffe000202cb0:	00078613          	mv	a2,a5
ffffffe000202cb4:	00009517          	auipc	a0,0x9
ffffffe000202cb8:	34c50513          	addi	a0,a0,844 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202cbc:	068000ef          	jal	ffffffe000202d24 <create_mapping>

    // set satp with swapper_pg_dir
    // YOUR CODE HERE
    // 设置 satp 寄存器，启用分页
    uint64_t satp_value = ((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12;
ffffffe000202cc0:	00009717          	auipc	a4,0x9
ffffffe000202cc4:	34070713          	addi	a4,a4,832 # ffffffe00020c000 <swapper_pg_dir>
ffffffe000202cc8:	04100793          	li	a5,65
ffffffe000202ccc:	01f79793          	slli	a5,a5,0x1f
ffffffe000202cd0:	00f707b3          	add	a5,a4,a5
ffffffe000202cd4:	00c7d793          	srli	a5,a5,0xc
ffffffe000202cd8:	fcf43023          	sd	a5,-64(s0)
    satp_value |= (8UL << 60); // Sv39 模式
ffffffe000202cdc:	fc043703          	ld	a4,-64(s0)
ffffffe000202ce0:	fff00793          	li	a5,-1
ffffffe000202ce4:	03f79793          	slli	a5,a5,0x3f
ffffffe000202ce8:	00f767b3          	or	a5,a4,a5
ffffffe000202cec:	fcf43023          	sd	a5,-64(s0)
    csr_write(satp, satp_value);
ffffffe000202cf0:	fc043783          	ld	a5,-64(s0)
ffffffe000202cf4:	faf43c23          	sd	a5,-72(s0)
ffffffe000202cf8:	fb843783          	ld	a5,-72(s0)
ffffffe000202cfc:	18079073          	csrw	satp,a5
    
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000202d00:	12000073          	sfence.vma

    // flush icache
    // asm volatile("fence.i");

    printk("...setup_vm_final done!\n");
ffffffe000202d04:	00002517          	auipc	a0,0x2
ffffffe000202d08:	94450513          	addi	a0,a0,-1724 # ffffffe000204648 <__func__.0+0x28>
ffffffe000202d0c:	0d8010ef          	jal	ffffffe000203de4 <printk>

    return;
ffffffe000202d10:	00000013          	nop
}
ffffffe000202d14:	04813083          	ld	ra,72(sp)
ffffffe000202d18:	04013403          	ld	s0,64(sp)
ffffffe000202d1c:	05010113          	addi	sp,sp,80
ffffffe000202d20:	00008067          	ret

ffffffe000202d24 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) 
{
ffffffe000202d24:	f7010113          	addi	sp,sp,-144
ffffffe000202d28:	08113423          	sd	ra,136(sp)
ffffffe000202d2c:	08813023          	sd	s0,128(sp)
ffffffe000202d30:	09010413          	addi	s0,sp,144
ffffffe000202d34:	f8a43c23          	sd	a0,-104(s0)
ffffffe000202d38:	f8b43823          	sd	a1,-112(s0)
ffffffe000202d3c:	f8c43423          	sd	a2,-120(s0)
ffffffe000202d40:	f8d43023          	sd	a3,-128(s0)
ffffffe000202d44:	f6e43c23          	sd	a4,-136(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    
    uint64_t offset = 0; 
ffffffe000202d48:	fe043423          	sd	zero,-24(s0)

    while(offset < sz)
ffffffe000202d4c:	1580006f          	j	ffffffe000202ea4 <create_mapping+0x180>
    {
        uint64_t va_current = va + offset;
ffffffe000202d50:	f9043703          	ld	a4,-112(s0)
ffffffe000202d54:	fe843783          	ld	a5,-24(s0)
ffffffe000202d58:	00f707b3          	add	a5,a4,a5
ffffffe000202d5c:	fcf43423          	sd	a5,-56(s0)
        uint64_t pa_current = pa + offset;
ffffffe000202d60:	f8843703          	ld	a4,-120(s0)
ffffffe000202d64:	fe843783          	ld	a5,-24(s0)
ffffffe000202d68:	00f707b3          	add	a5,a4,a5
ffffffe000202d6c:	fcf43023          	sd	a5,-64(s0)
        uint64_t *pg_now = pgtbl;
ffffffe000202d70:	f9843783          	ld	a5,-104(s0)
ffffffe000202d74:	fef43023          	sd	a5,-32(s0)
        uint64_t VPN[3] = {
            (va_current >> 12) & 0x1ff, // VPN[0]
ffffffe000202d78:	fc843783          	ld	a5,-56(s0)
ffffffe000202d7c:	00c7d793          	srli	a5,a5,0xc
ffffffe000202d80:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe000202d84:	faf43023          	sd	a5,-96(s0)
            (va_current >> 21) & 0x1ff, // VPN[1]
ffffffe000202d88:	fc843783          	ld	a5,-56(s0)
ffffffe000202d8c:	0157d793          	srli	a5,a5,0x15
ffffffe000202d90:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe000202d94:	faf43423          	sd	a5,-88(s0)
            (va_current >> 30) & 0x1ff  // VPN[2]
ffffffe000202d98:	fc843783          	ld	a5,-56(s0)
ffffffe000202d9c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202da0:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe000202da4:	faf43823          	sd	a5,-80(s0)
        };

        // 处理三级页表 (Sv39)
        for (int level = 2; level > 0; level--) 
ffffffe000202da8:	00200793          	li	a5,2
ffffffe000202dac:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202db0:	0b00006f          	j	ffffffe000202e60 <create_mapping+0x13c>
        {
            uint64_t PTE = pg_now[VPN[level]];
ffffffe000202db4:	fdc42783          	lw	a5,-36(s0)
ffffffe000202db8:	00379793          	slli	a5,a5,0x3
ffffffe000202dbc:	ff078793          	addi	a5,a5,-16
ffffffe000202dc0:	008787b3          	add	a5,a5,s0
ffffffe000202dc4:	fb07b783          	ld	a5,-80(a5)
ffffffe000202dc8:	00379793          	slli	a5,a5,0x3
ffffffe000202dcc:	fe043703          	ld	a4,-32(s0)
ffffffe000202dd0:	00f707b3          	add	a5,a4,a5
ffffffe000202dd4:	0007b783          	ld	a5,0(a5)
ffffffe000202dd8:	fcf43823          	sd	a5,-48(s0)
            if ((PTE & 1) == 0) 
ffffffe000202ddc:	fd043783          	ld	a5,-48(s0)
ffffffe000202de0:	0017f793          	andi	a5,a5,1
ffffffe000202de4:	04079a63          	bnez	a5,ffffffe000202e38 <create_mapping+0x114>
            { // 如果页表项无效
                uint64_t *new_pg = (uint64_t *)kalloc(); // 分配一页
ffffffe000202de8:	bddfd0ef          	jal	ffffffe0002009c4 <kalloc>
ffffffe000202dec:	faa43c23          	sd	a0,-72(s0)
                // 计算新的页表物理地址，设置有效位
                PTE = (((uint64_t)new_pg - PA2VA_OFFSET) >> 12) << 10 | 1;
ffffffe000202df0:	fb843703          	ld	a4,-72(s0)
ffffffe000202df4:	04100793          	li	a5,65
ffffffe000202df8:	01f79793          	slli	a5,a5,0x1f
ffffffe000202dfc:	00f707b3          	add	a5,a4,a5
ffffffe000202e00:	00c7d793          	srli	a5,a5,0xc
ffffffe000202e04:	00a79793          	slli	a5,a5,0xa
ffffffe000202e08:	0017e793          	ori	a5,a5,1
ffffffe000202e0c:	fcf43823          	sd	a5,-48(s0)
                pg_now[VPN[level]] = PTE; // 更新页表项
ffffffe000202e10:	fdc42783          	lw	a5,-36(s0)
ffffffe000202e14:	00379793          	slli	a5,a5,0x3
ffffffe000202e18:	ff078793          	addi	a5,a5,-16
ffffffe000202e1c:	008787b3          	add	a5,a5,s0
ffffffe000202e20:	fb07b783          	ld	a5,-80(a5)
ffffffe000202e24:	00379793          	slli	a5,a5,0x3
ffffffe000202e28:	fe043703          	ld	a4,-32(s0)
ffffffe000202e2c:	00f707b3          	add	a5,a4,a5
ffffffe000202e30:	fd043703          	ld	a4,-48(s0)
ffffffe000202e34:	00e7b023          	sd	a4,0(a5)
            }

            // 通过当前 PTE 获取下一层页表的地址
            pg_now = (uint64_t *)(((PTE >> 10) << 12) + PA2VA_OFFSET);
ffffffe000202e38:	fd043783          	ld	a5,-48(s0)
ffffffe000202e3c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202e40:	00c79713          	slli	a4,a5,0xc
ffffffe000202e44:	fbf00793          	li	a5,-65
ffffffe000202e48:	01f79793          	slli	a5,a5,0x1f
ffffffe000202e4c:	00f707b3          	add	a5,a4,a5
ffffffe000202e50:	fef43023          	sd	a5,-32(s0)
        for (int level = 2; level > 0; level--) 
ffffffe000202e54:	fdc42783          	lw	a5,-36(s0)
ffffffe000202e58:	fff7879b          	addiw	a5,a5,-1
ffffffe000202e5c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202e60:	fdc42783          	lw	a5,-36(s0)
ffffffe000202e64:	0007879b          	sext.w	a5,a5
ffffffe000202e68:	f4f046e3          	bgtz	a5,ffffffe000202db4 <create_mapping+0x90>
        }

        // 处理一级页表
        pg_now[VPN[0]] = ((pa_current >> 12) << 10) | perm; // 设置物理地址和权限
ffffffe000202e6c:	fc043783          	ld	a5,-64(s0)
ffffffe000202e70:	00c7d793          	srli	a5,a5,0xc
ffffffe000202e74:	00a79693          	slli	a3,a5,0xa
ffffffe000202e78:	fa043783          	ld	a5,-96(s0)
ffffffe000202e7c:	00379793          	slli	a5,a5,0x3
ffffffe000202e80:	fe043703          	ld	a4,-32(s0)
ffffffe000202e84:	00f707b3          	add	a5,a4,a5
ffffffe000202e88:	f7843703          	ld	a4,-136(s0)
ffffffe000202e8c:	00e6e733          	or	a4,a3,a4
ffffffe000202e90:	00e7b023          	sd	a4,0(a5)

        offset += PGSIZE;
ffffffe000202e94:	fe843703          	ld	a4,-24(s0)
ffffffe000202e98:	000017b7          	lui	a5,0x1
ffffffe000202e9c:	00f707b3          	add	a5,a4,a5
ffffffe000202ea0:	fef43423          	sd	a5,-24(s0)
    while(offset < sz)
ffffffe000202ea4:	fe843703          	ld	a4,-24(s0)
ffffffe000202ea8:	f8043783          	ld	a5,-128(s0)
ffffffe000202eac:	eaf762e3          	bltu	a4,a5,ffffffe000202d50 <create_mapping+0x2c>
    }

    printk(BLUE"[vm.c,create_mapping] --- [%lx, %lx) -> [%lx, %lx), perm: %lx\n"CLEAR,pa,pa+sz,va,va+sz,perm);
ffffffe000202eb0:	f8843703          	ld	a4,-120(s0)
ffffffe000202eb4:	f8043783          	ld	a5,-128(s0)
ffffffe000202eb8:	00f70633          	add	a2,a4,a5
ffffffe000202ebc:	f9043703          	ld	a4,-112(s0)
ffffffe000202ec0:	f8043783          	ld	a5,-128(s0)
ffffffe000202ec4:	00f70733          	add	a4,a4,a5
ffffffe000202ec8:	f7843783          	ld	a5,-136(s0)
ffffffe000202ecc:	f9043683          	ld	a3,-112(s0)
ffffffe000202ed0:	f8843583          	ld	a1,-120(s0)
ffffffe000202ed4:	00001517          	auipc	a0,0x1
ffffffe000202ed8:	79450513          	addi	a0,a0,1940 # ffffffe000204668 <__func__.0+0x48>
ffffffe000202edc:	709000ef          	jal	ffffffe000203de4 <printk>
ffffffe000202ee0:	00000013          	nop
ffffffe000202ee4:	08813083          	ld	ra,136(sp)
ffffffe000202ee8:	08013403          	ld	s0,128(sp)
ffffffe000202eec:	09010113          	addi	sp,sp,144
ffffffe000202ef0:	00008067          	ret

ffffffe000202ef4 <start_kernel>:
#include "defs.h"
#include "proc.h"

extern void test();

int start_kernel() {
ffffffe000202ef4:	ff010113          	addi	sp,sp,-16
ffffffe000202ef8:	00113423          	sd	ra,8(sp)
ffffffe000202efc:	00813023          	sd	s0,0(sp)
ffffffe000202f00:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000202f04:	00001517          	auipc	a0,0x1
ffffffe000202f08:	7ac50513          	addi	a0,a0,1964 # ffffffe0002046b0 <__func__.0+0x90>
ffffffe000202f0c:	6d9000ef          	jal	ffffffe000203de4 <printk>
    printk(" ZJU Operating System\n");
ffffffe000202f10:	00001517          	auipc	a0,0x1
ffffffe000202f14:	7a850513          	addi	a0,a0,1960 # ffffffe0002046b8 <__func__.0+0x98>
ffffffe000202f18:	6cd000ef          	jal	ffffffe000203de4 <printk>
    // *_stext=0;
    // *_srodata=0;
    // printk("stext: %x\n", *_stext);  //test W
    // printk("srodata: %x\n", *_srodata);  //test W

    schedule();
ffffffe000202f1c:	971fe0ef          	jal	ffffffe00020188c <schedule>
    test();
ffffffe000202f20:	01c000ef          	jal	ffffffe000202f3c <test>
    return 0;
ffffffe000202f24:	00000793          	li	a5,0
}
ffffffe000202f28:	00078513          	mv	a0,a5
ffffffe000202f2c:	00813083          	ld	ra,8(sp)
ffffffe000202f30:	00013403          	ld	s0,0(sp)
ffffffe000202f34:	01010113          	addi	sp,sp,16
ffffffe000202f38:	00008067          	ret

ffffffe000202f3c <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }
#include "printk.h"

void test() {
ffffffe000202f3c:	ff010113          	addi	sp,sp,-16
ffffffe000202f40:	00813423          	sd	s0,8(sp)
ffffffe000202f44:	01010413          	addi	s0,sp,16
    // int i = 0;
    while (1) {
ffffffe000202f48:	00000013          	nop
ffffffe000202f4c:	ffdff06f          	j	ffffffe000202f48 <test+0xc>

ffffffe000202f50 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000202f50:	fe010113          	addi	sp,sp,-32
ffffffe000202f54:	00113c23          	sd	ra,24(sp)
ffffffe000202f58:	00813823          	sd	s0,16(sp)
ffffffe000202f5c:	02010413          	addi	s0,sp,32
ffffffe000202f60:	00050793          	mv	a5,a0
ffffffe000202f64:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000202f68:	fec42783          	lw	a5,-20(s0)
ffffffe000202f6c:	0ff7f793          	zext.b	a5,a5
ffffffe000202f70:	00078513          	mv	a0,a5
ffffffe000202f74:	c79fe0ef          	jal	ffffffe000201bec <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000202f78:	fec42783          	lw	a5,-20(s0)
ffffffe000202f7c:	0ff7f793          	zext.b	a5,a5
ffffffe000202f80:	0007879b          	sext.w	a5,a5
}
ffffffe000202f84:	00078513          	mv	a0,a5
ffffffe000202f88:	01813083          	ld	ra,24(sp)
ffffffe000202f8c:	01013403          	ld	s0,16(sp)
ffffffe000202f90:	02010113          	addi	sp,sp,32
ffffffe000202f94:	00008067          	ret

ffffffe000202f98 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000202f98:	fe010113          	addi	sp,sp,-32
ffffffe000202f9c:	00813c23          	sd	s0,24(sp)
ffffffe000202fa0:	02010413          	addi	s0,sp,32
ffffffe000202fa4:	00050793          	mv	a5,a0
ffffffe000202fa8:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202fac:	fec42783          	lw	a5,-20(s0)
ffffffe000202fb0:	0007871b          	sext.w	a4,a5
ffffffe000202fb4:	02000793          	li	a5,32
ffffffe000202fb8:	02f70263          	beq	a4,a5,ffffffe000202fdc <isspace+0x44>
ffffffe000202fbc:	fec42783          	lw	a5,-20(s0)
ffffffe000202fc0:	0007871b          	sext.w	a4,a5
ffffffe000202fc4:	00800793          	li	a5,8
ffffffe000202fc8:	00e7de63          	bge	a5,a4,ffffffe000202fe4 <isspace+0x4c>
ffffffe000202fcc:	fec42783          	lw	a5,-20(s0)
ffffffe000202fd0:	0007871b          	sext.w	a4,a5
ffffffe000202fd4:	00d00793          	li	a5,13
ffffffe000202fd8:	00e7c663          	blt	a5,a4,ffffffe000202fe4 <isspace+0x4c>
ffffffe000202fdc:	00100793          	li	a5,1
ffffffe000202fe0:	0080006f          	j	ffffffe000202fe8 <isspace+0x50>
ffffffe000202fe4:	00000793          	li	a5,0
}
ffffffe000202fe8:	00078513          	mv	a0,a5
ffffffe000202fec:	01813403          	ld	s0,24(sp)
ffffffe000202ff0:	02010113          	addi	sp,sp,32
ffffffe000202ff4:	00008067          	ret

ffffffe000202ff8 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000202ff8:	fb010113          	addi	sp,sp,-80
ffffffe000202ffc:	04113423          	sd	ra,72(sp)
ffffffe000203000:	04813023          	sd	s0,64(sp)
ffffffe000203004:	05010413          	addi	s0,sp,80
ffffffe000203008:	fca43423          	sd	a0,-56(s0)
ffffffe00020300c:	fcb43023          	sd	a1,-64(s0)
ffffffe000203010:	00060793          	mv	a5,a2
ffffffe000203014:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000203018:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe00020301c:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000203020:	fc843783          	ld	a5,-56(s0)
ffffffe000203024:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000203028:	0100006f          	j	ffffffe000203038 <strtol+0x40>
        p++;
ffffffe00020302c:	fd843783          	ld	a5,-40(s0)
ffffffe000203030:	00178793          	addi	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000203034:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000203038:	fd843783          	ld	a5,-40(s0)
ffffffe00020303c:	0007c783          	lbu	a5,0(a5)
ffffffe000203040:	0007879b          	sext.w	a5,a5
ffffffe000203044:	00078513          	mv	a0,a5
ffffffe000203048:	f51ff0ef          	jal	ffffffe000202f98 <isspace>
ffffffe00020304c:	00050793          	mv	a5,a0
ffffffe000203050:	fc079ee3          	bnez	a5,ffffffe00020302c <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000203054:	fd843783          	ld	a5,-40(s0)
ffffffe000203058:	0007c783          	lbu	a5,0(a5)
ffffffe00020305c:	00078713          	mv	a4,a5
ffffffe000203060:	02d00793          	li	a5,45
ffffffe000203064:	00f71e63          	bne	a4,a5,ffffffe000203080 <strtol+0x88>
        neg = true;
ffffffe000203068:	00100793          	li	a5,1
ffffffe00020306c:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000203070:	fd843783          	ld	a5,-40(s0)
ffffffe000203074:	00178793          	addi	a5,a5,1
ffffffe000203078:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020307c:	0240006f          	j	ffffffe0002030a0 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000203080:	fd843783          	ld	a5,-40(s0)
ffffffe000203084:	0007c783          	lbu	a5,0(a5)
ffffffe000203088:	00078713          	mv	a4,a5
ffffffe00020308c:	02b00793          	li	a5,43
ffffffe000203090:	00f71863          	bne	a4,a5,ffffffe0002030a0 <strtol+0xa8>
        p++;
ffffffe000203094:	fd843783          	ld	a5,-40(s0)
ffffffe000203098:	00178793          	addi	a5,a5,1
ffffffe00020309c:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe0002030a0:	fbc42783          	lw	a5,-68(s0)
ffffffe0002030a4:	0007879b          	sext.w	a5,a5
ffffffe0002030a8:	06079c63          	bnez	a5,ffffffe000203120 <strtol+0x128>
        if (*p == '0') {
ffffffe0002030ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002030b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002030b4:	00078713          	mv	a4,a5
ffffffe0002030b8:	03000793          	li	a5,48
ffffffe0002030bc:	04f71e63          	bne	a4,a5,ffffffe000203118 <strtol+0x120>
            p++;
ffffffe0002030c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002030c4:	00178793          	addi	a5,a5,1
ffffffe0002030c8:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe0002030cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002030d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002030d4:	00078713          	mv	a4,a5
ffffffe0002030d8:	07800793          	li	a5,120
ffffffe0002030dc:	00f70c63          	beq	a4,a5,ffffffe0002030f4 <strtol+0xfc>
ffffffe0002030e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002030e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002030e8:	00078713          	mv	a4,a5
ffffffe0002030ec:	05800793          	li	a5,88
ffffffe0002030f0:	00f71e63          	bne	a4,a5,ffffffe00020310c <strtol+0x114>
                base = 16;
ffffffe0002030f4:	01000793          	li	a5,16
ffffffe0002030f8:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe0002030fc:	fd843783          	ld	a5,-40(s0)
ffffffe000203100:	00178793          	addi	a5,a5,1
ffffffe000203104:	fcf43c23          	sd	a5,-40(s0)
ffffffe000203108:	0180006f          	j	ffffffe000203120 <strtol+0x128>
            } else {
                base = 8;
ffffffe00020310c:	00800793          	li	a5,8
ffffffe000203110:	faf42e23          	sw	a5,-68(s0)
ffffffe000203114:	00c0006f          	j	ffffffe000203120 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000203118:	00a00793          	li	a5,10
ffffffe00020311c:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000203120:	fd843783          	ld	a5,-40(s0)
ffffffe000203124:	0007c783          	lbu	a5,0(a5)
ffffffe000203128:	00078713          	mv	a4,a5
ffffffe00020312c:	02f00793          	li	a5,47
ffffffe000203130:	02e7f863          	bgeu	a5,a4,ffffffe000203160 <strtol+0x168>
ffffffe000203134:	fd843783          	ld	a5,-40(s0)
ffffffe000203138:	0007c783          	lbu	a5,0(a5)
ffffffe00020313c:	00078713          	mv	a4,a5
ffffffe000203140:	03900793          	li	a5,57
ffffffe000203144:	00e7ee63          	bltu	a5,a4,ffffffe000203160 <strtol+0x168>
            digit = *p - '0';
ffffffe000203148:	fd843783          	ld	a5,-40(s0)
ffffffe00020314c:	0007c783          	lbu	a5,0(a5)
ffffffe000203150:	0007879b          	sext.w	a5,a5
ffffffe000203154:	fd07879b          	addiw	a5,a5,-48
ffffffe000203158:	fcf42a23          	sw	a5,-44(s0)
ffffffe00020315c:	0800006f          	j	ffffffe0002031dc <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000203160:	fd843783          	ld	a5,-40(s0)
ffffffe000203164:	0007c783          	lbu	a5,0(a5)
ffffffe000203168:	00078713          	mv	a4,a5
ffffffe00020316c:	06000793          	li	a5,96
ffffffe000203170:	02e7f863          	bgeu	a5,a4,ffffffe0002031a0 <strtol+0x1a8>
ffffffe000203174:	fd843783          	ld	a5,-40(s0)
ffffffe000203178:	0007c783          	lbu	a5,0(a5)
ffffffe00020317c:	00078713          	mv	a4,a5
ffffffe000203180:	07a00793          	li	a5,122
ffffffe000203184:	00e7ee63          	bltu	a5,a4,ffffffe0002031a0 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000203188:	fd843783          	ld	a5,-40(s0)
ffffffe00020318c:	0007c783          	lbu	a5,0(a5)
ffffffe000203190:	0007879b          	sext.w	a5,a5
ffffffe000203194:	fa97879b          	addiw	a5,a5,-87
ffffffe000203198:	fcf42a23          	sw	a5,-44(s0)
ffffffe00020319c:	0400006f          	j	ffffffe0002031dc <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe0002031a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002031a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002031a8:	00078713          	mv	a4,a5
ffffffe0002031ac:	04000793          	li	a5,64
ffffffe0002031b0:	06e7f863          	bgeu	a5,a4,ffffffe000203220 <strtol+0x228>
ffffffe0002031b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002031b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002031bc:	00078713          	mv	a4,a5
ffffffe0002031c0:	05a00793          	li	a5,90
ffffffe0002031c4:	04e7ee63          	bltu	a5,a4,ffffffe000203220 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe0002031c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002031cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002031d0:	0007879b          	sext.w	a5,a5
ffffffe0002031d4:	fc97879b          	addiw	a5,a5,-55
ffffffe0002031d8:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe0002031dc:	fd442783          	lw	a5,-44(s0)
ffffffe0002031e0:	00078713          	mv	a4,a5
ffffffe0002031e4:	fbc42783          	lw	a5,-68(s0)
ffffffe0002031e8:	0007071b          	sext.w	a4,a4
ffffffe0002031ec:	0007879b          	sext.w	a5,a5
ffffffe0002031f0:	02f75663          	bge	a4,a5,ffffffe00020321c <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe0002031f4:	fbc42703          	lw	a4,-68(s0)
ffffffe0002031f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002031fc:	02f70733          	mul	a4,a4,a5
ffffffe000203200:	fd442783          	lw	a5,-44(s0)
ffffffe000203204:	00f707b3          	add	a5,a4,a5
ffffffe000203208:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe00020320c:	fd843783          	ld	a5,-40(s0)
ffffffe000203210:	00178793          	addi	a5,a5,1
ffffffe000203214:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000203218:	f09ff06f          	j	ffffffe000203120 <strtol+0x128>
            break;
ffffffe00020321c:	00000013          	nop
    }

    if (endptr) {
ffffffe000203220:	fc043783          	ld	a5,-64(s0)
ffffffe000203224:	00078863          	beqz	a5,ffffffe000203234 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000203228:	fc043783          	ld	a5,-64(s0)
ffffffe00020322c:	fd843703          	ld	a4,-40(s0)
ffffffe000203230:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000203234:	fe744783          	lbu	a5,-25(s0)
ffffffe000203238:	0ff7f793          	zext.b	a5,a5
ffffffe00020323c:	00078863          	beqz	a5,ffffffe00020324c <strtol+0x254>
ffffffe000203240:	fe843783          	ld	a5,-24(s0)
ffffffe000203244:	40f007b3          	neg	a5,a5
ffffffe000203248:	0080006f          	j	ffffffe000203250 <strtol+0x258>
ffffffe00020324c:	fe843783          	ld	a5,-24(s0)
}
ffffffe000203250:	00078513          	mv	a0,a5
ffffffe000203254:	04813083          	ld	ra,72(sp)
ffffffe000203258:	04013403          	ld	s0,64(sp)
ffffffe00020325c:	05010113          	addi	sp,sp,80
ffffffe000203260:	00008067          	ret

ffffffe000203264 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000203264:	fd010113          	addi	sp,sp,-48
ffffffe000203268:	02113423          	sd	ra,40(sp)
ffffffe00020326c:	02813023          	sd	s0,32(sp)
ffffffe000203270:	03010413          	addi	s0,sp,48
ffffffe000203274:	fca43c23          	sd	a0,-40(s0)
ffffffe000203278:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe00020327c:	fd043783          	ld	a5,-48(s0)
ffffffe000203280:	00079863          	bnez	a5,ffffffe000203290 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000203284:	00001797          	auipc	a5,0x1
ffffffe000203288:	44c78793          	addi	a5,a5,1100 # ffffffe0002046d0 <__func__.0+0xb0>
ffffffe00020328c:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000203290:	fd043783          	ld	a5,-48(s0)
ffffffe000203294:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000203298:	0240006f          	j	ffffffe0002032bc <puts_wo_nl+0x58>
        putch(*p++);
ffffffe00020329c:	fe843783          	ld	a5,-24(s0)
ffffffe0002032a0:	00178713          	addi	a4,a5,1
ffffffe0002032a4:	fee43423          	sd	a4,-24(s0)
ffffffe0002032a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002032ac:	0007871b          	sext.w	a4,a5
ffffffe0002032b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002032b4:	00070513          	mv	a0,a4
ffffffe0002032b8:	000780e7          	jalr	a5
    while (*p) {
ffffffe0002032bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002032c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002032c4:	fc079ce3          	bnez	a5,ffffffe00020329c <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe0002032c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002032cc:	fd043783          	ld	a5,-48(s0)
ffffffe0002032d0:	40f707b3          	sub	a5,a4,a5
ffffffe0002032d4:	0007879b          	sext.w	a5,a5
}
ffffffe0002032d8:	00078513          	mv	a0,a5
ffffffe0002032dc:	02813083          	ld	ra,40(sp)
ffffffe0002032e0:	02013403          	ld	s0,32(sp)
ffffffe0002032e4:	03010113          	addi	sp,sp,48
ffffffe0002032e8:	00008067          	ret

ffffffe0002032ec <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe0002032ec:	f9010113          	addi	sp,sp,-112
ffffffe0002032f0:	06113423          	sd	ra,104(sp)
ffffffe0002032f4:	06813023          	sd	s0,96(sp)
ffffffe0002032f8:	07010413          	addi	s0,sp,112
ffffffe0002032fc:	faa43423          	sd	a0,-88(s0)
ffffffe000203300:	fab43023          	sd	a1,-96(s0)
ffffffe000203304:	00060793          	mv	a5,a2
ffffffe000203308:	f8d43823          	sd	a3,-112(s0)
ffffffe00020330c:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000203310:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203314:	0ff7f793          	zext.b	a5,a5
ffffffe000203318:	02078663          	beqz	a5,ffffffe000203344 <print_dec_int+0x58>
ffffffe00020331c:	fa043703          	ld	a4,-96(s0)
ffffffe000203320:	fff00793          	li	a5,-1
ffffffe000203324:	03f79793          	slli	a5,a5,0x3f
ffffffe000203328:	00f71e63          	bne	a4,a5,ffffffe000203344 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe00020332c:	00001597          	auipc	a1,0x1
ffffffe000203330:	3ac58593          	addi	a1,a1,940 # ffffffe0002046d8 <__func__.0+0xb8>
ffffffe000203334:	fa843503          	ld	a0,-88(s0)
ffffffe000203338:	f2dff0ef          	jal	ffffffe000203264 <puts_wo_nl>
ffffffe00020333c:	00050793          	mv	a5,a0
ffffffe000203340:	2a00006f          	j	ffffffe0002035e0 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000203344:	f9043783          	ld	a5,-112(s0)
ffffffe000203348:	00c7a783          	lw	a5,12(a5)
ffffffe00020334c:	00079a63          	bnez	a5,ffffffe000203360 <print_dec_int+0x74>
ffffffe000203350:	fa043783          	ld	a5,-96(s0)
ffffffe000203354:	00079663          	bnez	a5,ffffffe000203360 <print_dec_int+0x74>
        return 0;
ffffffe000203358:	00000793          	li	a5,0
ffffffe00020335c:	2840006f          	j	ffffffe0002035e0 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000203360:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000203364:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203368:	0ff7f793          	zext.b	a5,a5
ffffffe00020336c:	02078063          	beqz	a5,ffffffe00020338c <print_dec_int+0xa0>
ffffffe000203370:	fa043783          	ld	a5,-96(s0)
ffffffe000203374:	0007dc63          	bgez	a5,ffffffe00020338c <print_dec_int+0xa0>
        neg = true;
ffffffe000203378:	00100793          	li	a5,1
ffffffe00020337c:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000203380:	fa043783          	ld	a5,-96(s0)
ffffffe000203384:	40f007b3          	neg	a5,a5
ffffffe000203388:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe00020338c:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000203390:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203394:	0ff7f793          	zext.b	a5,a5
ffffffe000203398:	02078863          	beqz	a5,ffffffe0002033c8 <print_dec_int+0xdc>
ffffffe00020339c:	fef44783          	lbu	a5,-17(s0)
ffffffe0002033a0:	0ff7f793          	zext.b	a5,a5
ffffffe0002033a4:	00079e63          	bnez	a5,ffffffe0002033c0 <print_dec_int+0xd4>
ffffffe0002033a8:	f9043783          	ld	a5,-112(s0)
ffffffe0002033ac:	0057c783          	lbu	a5,5(a5)
ffffffe0002033b0:	00079863          	bnez	a5,ffffffe0002033c0 <print_dec_int+0xd4>
ffffffe0002033b4:	f9043783          	ld	a5,-112(s0)
ffffffe0002033b8:	0047c783          	lbu	a5,4(a5)
ffffffe0002033bc:	00078663          	beqz	a5,ffffffe0002033c8 <print_dec_int+0xdc>
ffffffe0002033c0:	00100793          	li	a5,1
ffffffe0002033c4:	0080006f          	j	ffffffe0002033cc <print_dec_int+0xe0>
ffffffe0002033c8:	00000793          	li	a5,0
ffffffe0002033cc:	fcf40ba3          	sb	a5,-41(s0)
ffffffe0002033d0:	fd744783          	lbu	a5,-41(s0)
ffffffe0002033d4:	0017f793          	andi	a5,a5,1
ffffffe0002033d8:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe0002033dc:	fa043703          	ld	a4,-96(s0)
ffffffe0002033e0:	00a00793          	li	a5,10
ffffffe0002033e4:	02f777b3          	remu	a5,a4,a5
ffffffe0002033e8:	0ff7f713          	zext.b	a4,a5
ffffffe0002033ec:	fe842783          	lw	a5,-24(s0)
ffffffe0002033f0:	0017869b          	addiw	a3,a5,1
ffffffe0002033f4:	fed42423          	sw	a3,-24(s0)
ffffffe0002033f8:	0307071b          	addiw	a4,a4,48
ffffffe0002033fc:	0ff77713          	zext.b	a4,a4
ffffffe000203400:	ff078793          	addi	a5,a5,-16
ffffffe000203404:	008787b3          	add	a5,a5,s0
ffffffe000203408:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe00020340c:	fa043703          	ld	a4,-96(s0)
ffffffe000203410:	00a00793          	li	a5,10
ffffffe000203414:	02f757b3          	divu	a5,a4,a5
ffffffe000203418:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe00020341c:	fa043783          	ld	a5,-96(s0)
ffffffe000203420:	fa079ee3          	bnez	a5,ffffffe0002033dc <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000203424:	f9043783          	ld	a5,-112(s0)
ffffffe000203428:	00c7a783          	lw	a5,12(a5)
ffffffe00020342c:	00078713          	mv	a4,a5
ffffffe000203430:	fff00793          	li	a5,-1
ffffffe000203434:	02f71063          	bne	a4,a5,ffffffe000203454 <print_dec_int+0x168>
ffffffe000203438:	f9043783          	ld	a5,-112(s0)
ffffffe00020343c:	0037c783          	lbu	a5,3(a5)
ffffffe000203440:	00078a63          	beqz	a5,ffffffe000203454 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000203444:	f9043783          	ld	a5,-112(s0)
ffffffe000203448:	0087a703          	lw	a4,8(a5)
ffffffe00020344c:	f9043783          	ld	a5,-112(s0)
ffffffe000203450:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000203454:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203458:	f9043783          	ld	a5,-112(s0)
ffffffe00020345c:	0087a703          	lw	a4,8(a5)
ffffffe000203460:	fe842783          	lw	a5,-24(s0)
ffffffe000203464:	fcf42823          	sw	a5,-48(s0)
ffffffe000203468:	f9043783          	ld	a5,-112(s0)
ffffffe00020346c:	00c7a783          	lw	a5,12(a5)
ffffffe000203470:	fcf42623          	sw	a5,-52(s0)
ffffffe000203474:	fd042783          	lw	a5,-48(s0)
ffffffe000203478:	00078593          	mv	a1,a5
ffffffe00020347c:	fcc42783          	lw	a5,-52(s0)
ffffffe000203480:	00078613          	mv	a2,a5
ffffffe000203484:	0006069b          	sext.w	a3,a2
ffffffe000203488:	0005879b          	sext.w	a5,a1
ffffffe00020348c:	00f6d463          	bge	a3,a5,ffffffe000203494 <print_dec_int+0x1a8>
ffffffe000203490:	00058613          	mv	a2,a1
ffffffe000203494:	0006079b          	sext.w	a5,a2
ffffffe000203498:	40f707bb          	subw	a5,a4,a5
ffffffe00020349c:	0007871b          	sext.w	a4,a5
ffffffe0002034a0:	fd744783          	lbu	a5,-41(s0)
ffffffe0002034a4:	0007879b          	sext.w	a5,a5
ffffffe0002034a8:	40f707bb          	subw	a5,a4,a5
ffffffe0002034ac:	fef42023          	sw	a5,-32(s0)
ffffffe0002034b0:	0280006f          	j	ffffffe0002034d8 <print_dec_int+0x1ec>
        putch(' ');
ffffffe0002034b4:	fa843783          	ld	a5,-88(s0)
ffffffe0002034b8:	02000513          	li	a0,32
ffffffe0002034bc:	000780e7          	jalr	a5
        ++written;
ffffffe0002034c0:	fe442783          	lw	a5,-28(s0)
ffffffe0002034c4:	0017879b          	addiw	a5,a5,1
ffffffe0002034c8:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002034cc:	fe042783          	lw	a5,-32(s0)
ffffffe0002034d0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002034d4:	fef42023          	sw	a5,-32(s0)
ffffffe0002034d8:	fe042783          	lw	a5,-32(s0)
ffffffe0002034dc:	0007879b          	sext.w	a5,a5
ffffffe0002034e0:	fcf04ae3          	bgtz	a5,ffffffe0002034b4 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe0002034e4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002034e8:	0ff7f793          	zext.b	a5,a5
ffffffe0002034ec:	04078463          	beqz	a5,ffffffe000203534 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe0002034f0:	fef44783          	lbu	a5,-17(s0)
ffffffe0002034f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002034f8:	00078663          	beqz	a5,ffffffe000203504 <print_dec_int+0x218>
ffffffe0002034fc:	02d00793          	li	a5,45
ffffffe000203500:	01c0006f          	j	ffffffe00020351c <print_dec_int+0x230>
ffffffe000203504:	f9043783          	ld	a5,-112(s0)
ffffffe000203508:	0057c783          	lbu	a5,5(a5)
ffffffe00020350c:	00078663          	beqz	a5,ffffffe000203518 <print_dec_int+0x22c>
ffffffe000203510:	02b00793          	li	a5,43
ffffffe000203514:	0080006f          	j	ffffffe00020351c <print_dec_int+0x230>
ffffffe000203518:	02000793          	li	a5,32
ffffffe00020351c:	fa843703          	ld	a4,-88(s0)
ffffffe000203520:	00078513          	mv	a0,a5
ffffffe000203524:	000700e7          	jalr	a4
        ++written;
ffffffe000203528:	fe442783          	lw	a5,-28(s0)
ffffffe00020352c:	0017879b          	addiw	a5,a5,1
ffffffe000203530:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203534:	fe842783          	lw	a5,-24(s0)
ffffffe000203538:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020353c:	0280006f          	j	ffffffe000203564 <print_dec_int+0x278>
        putch('0');
ffffffe000203540:	fa843783          	ld	a5,-88(s0)
ffffffe000203544:	03000513          	li	a0,48
ffffffe000203548:	000780e7          	jalr	a5
        ++written;
ffffffe00020354c:	fe442783          	lw	a5,-28(s0)
ffffffe000203550:	0017879b          	addiw	a5,a5,1
ffffffe000203554:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203558:	fdc42783          	lw	a5,-36(s0)
ffffffe00020355c:	0017879b          	addiw	a5,a5,1
ffffffe000203560:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203564:	f9043783          	ld	a5,-112(s0)
ffffffe000203568:	00c7a703          	lw	a4,12(a5)
ffffffe00020356c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203570:	0007879b          	sext.w	a5,a5
ffffffe000203574:	40f707bb          	subw	a5,a4,a5
ffffffe000203578:	0007871b          	sext.w	a4,a5
ffffffe00020357c:	fdc42783          	lw	a5,-36(s0)
ffffffe000203580:	0007879b          	sext.w	a5,a5
ffffffe000203584:	fae7cee3          	blt	a5,a4,ffffffe000203540 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203588:	fe842783          	lw	a5,-24(s0)
ffffffe00020358c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203590:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203594:	03c0006f          	j	ffffffe0002035d0 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203598:	fd842783          	lw	a5,-40(s0)
ffffffe00020359c:	ff078793          	addi	a5,a5,-16
ffffffe0002035a0:	008787b3          	add	a5,a5,s0
ffffffe0002035a4:	fc87c783          	lbu	a5,-56(a5)
ffffffe0002035a8:	0007871b          	sext.w	a4,a5
ffffffe0002035ac:	fa843783          	ld	a5,-88(s0)
ffffffe0002035b0:	00070513          	mv	a0,a4
ffffffe0002035b4:	000780e7          	jalr	a5
        ++written;
ffffffe0002035b8:	fe442783          	lw	a5,-28(s0)
ffffffe0002035bc:	0017879b          	addiw	a5,a5,1
ffffffe0002035c0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002035c4:	fd842783          	lw	a5,-40(s0)
ffffffe0002035c8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002035cc:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002035d0:	fd842783          	lw	a5,-40(s0)
ffffffe0002035d4:	0007879b          	sext.w	a5,a5
ffffffe0002035d8:	fc07d0e3          	bgez	a5,ffffffe000203598 <print_dec_int+0x2ac>
    }

    return written;
ffffffe0002035dc:	fe442783          	lw	a5,-28(s0)
}
ffffffe0002035e0:	00078513          	mv	a0,a5
ffffffe0002035e4:	06813083          	ld	ra,104(sp)
ffffffe0002035e8:	06013403          	ld	s0,96(sp)
ffffffe0002035ec:	07010113          	addi	sp,sp,112
ffffffe0002035f0:	00008067          	ret

ffffffe0002035f4 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe0002035f4:	f4010113          	addi	sp,sp,-192
ffffffe0002035f8:	0a113c23          	sd	ra,184(sp)
ffffffe0002035fc:	0a813823          	sd	s0,176(sp)
ffffffe000203600:	0c010413          	addi	s0,sp,192
ffffffe000203604:	f4a43c23          	sd	a0,-168(s0)
ffffffe000203608:	f4b43823          	sd	a1,-176(s0)
ffffffe00020360c:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000203610:	f8043023          	sd	zero,-128(s0)
ffffffe000203614:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000203618:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe00020361c:	7a40006f          	j	ffffffe000203dc0 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000203620:	f8044783          	lbu	a5,-128(s0)
ffffffe000203624:	72078e63          	beqz	a5,ffffffe000203d60 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000203628:	f5043783          	ld	a5,-176(s0)
ffffffe00020362c:	0007c783          	lbu	a5,0(a5)
ffffffe000203630:	00078713          	mv	a4,a5
ffffffe000203634:	02300793          	li	a5,35
ffffffe000203638:	00f71863          	bne	a4,a5,ffffffe000203648 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe00020363c:	00100793          	li	a5,1
ffffffe000203640:	f8f40123          	sb	a5,-126(s0)
ffffffe000203644:	7700006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000203648:	f5043783          	ld	a5,-176(s0)
ffffffe00020364c:	0007c783          	lbu	a5,0(a5)
ffffffe000203650:	00078713          	mv	a4,a5
ffffffe000203654:	03000793          	li	a5,48
ffffffe000203658:	00f71863          	bne	a4,a5,ffffffe000203668 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe00020365c:	00100793          	li	a5,1
ffffffe000203660:	f8f401a3          	sb	a5,-125(s0)
ffffffe000203664:	7500006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000203668:	f5043783          	ld	a5,-176(s0)
ffffffe00020366c:	0007c783          	lbu	a5,0(a5)
ffffffe000203670:	00078713          	mv	a4,a5
ffffffe000203674:	06c00793          	li	a5,108
ffffffe000203678:	04f70063          	beq	a4,a5,ffffffe0002036b8 <vprintfmt+0xc4>
ffffffe00020367c:	f5043783          	ld	a5,-176(s0)
ffffffe000203680:	0007c783          	lbu	a5,0(a5)
ffffffe000203684:	00078713          	mv	a4,a5
ffffffe000203688:	07a00793          	li	a5,122
ffffffe00020368c:	02f70663          	beq	a4,a5,ffffffe0002036b8 <vprintfmt+0xc4>
ffffffe000203690:	f5043783          	ld	a5,-176(s0)
ffffffe000203694:	0007c783          	lbu	a5,0(a5)
ffffffe000203698:	00078713          	mv	a4,a5
ffffffe00020369c:	07400793          	li	a5,116
ffffffe0002036a0:	00f70c63          	beq	a4,a5,ffffffe0002036b8 <vprintfmt+0xc4>
ffffffe0002036a4:	f5043783          	ld	a5,-176(s0)
ffffffe0002036a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002036ac:	00078713          	mv	a4,a5
ffffffe0002036b0:	06a00793          	li	a5,106
ffffffe0002036b4:	00f71863          	bne	a4,a5,ffffffe0002036c4 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe0002036b8:	00100793          	li	a5,1
ffffffe0002036bc:	f8f400a3          	sb	a5,-127(s0)
ffffffe0002036c0:	6f40006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe0002036c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002036c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002036cc:	00078713          	mv	a4,a5
ffffffe0002036d0:	02b00793          	li	a5,43
ffffffe0002036d4:	00f71863          	bne	a4,a5,ffffffe0002036e4 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe0002036d8:	00100793          	li	a5,1
ffffffe0002036dc:	f8f402a3          	sb	a5,-123(s0)
ffffffe0002036e0:	6d40006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe0002036e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002036e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002036ec:	00078713          	mv	a4,a5
ffffffe0002036f0:	02000793          	li	a5,32
ffffffe0002036f4:	00f71863          	bne	a4,a5,ffffffe000203704 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe0002036f8:	00100793          	li	a5,1
ffffffe0002036fc:	f8f40223          	sb	a5,-124(s0)
ffffffe000203700:	6b40006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000203704:	f5043783          	ld	a5,-176(s0)
ffffffe000203708:	0007c783          	lbu	a5,0(a5)
ffffffe00020370c:	00078713          	mv	a4,a5
ffffffe000203710:	02a00793          	li	a5,42
ffffffe000203714:	00f71e63          	bne	a4,a5,ffffffe000203730 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000203718:	f4843783          	ld	a5,-184(s0)
ffffffe00020371c:	00878713          	addi	a4,a5,8
ffffffe000203720:	f4e43423          	sd	a4,-184(s0)
ffffffe000203724:	0007a783          	lw	a5,0(a5)
ffffffe000203728:	f8f42423          	sw	a5,-120(s0)
ffffffe00020372c:	6880006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000203730:	f5043783          	ld	a5,-176(s0)
ffffffe000203734:	0007c783          	lbu	a5,0(a5)
ffffffe000203738:	00078713          	mv	a4,a5
ffffffe00020373c:	03000793          	li	a5,48
ffffffe000203740:	04e7f663          	bgeu	a5,a4,ffffffe00020378c <vprintfmt+0x198>
ffffffe000203744:	f5043783          	ld	a5,-176(s0)
ffffffe000203748:	0007c783          	lbu	a5,0(a5)
ffffffe00020374c:	00078713          	mv	a4,a5
ffffffe000203750:	03900793          	li	a5,57
ffffffe000203754:	02e7ec63          	bltu	a5,a4,ffffffe00020378c <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000203758:	f5043783          	ld	a5,-176(s0)
ffffffe00020375c:	f5040713          	addi	a4,s0,-176
ffffffe000203760:	00a00613          	li	a2,10
ffffffe000203764:	00070593          	mv	a1,a4
ffffffe000203768:	00078513          	mv	a0,a5
ffffffe00020376c:	88dff0ef          	jal	ffffffe000202ff8 <strtol>
ffffffe000203770:	00050793          	mv	a5,a0
ffffffe000203774:	0007879b          	sext.w	a5,a5
ffffffe000203778:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe00020377c:	f5043783          	ld	a5,-176(s0)
ffffffe000203780:	fff78793          	addi	a5,a5,-1
ffffffe000203784:	f4f43823          	sd	a5,-176(s0)
ffffffe000203788:	62c0006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe00020378c:	f5043783          	ld	a5,-176(s0)
ffffffe000203790:	0007c783          	lbu	a5,0(a5)
ffffffe000203794:	00078713          	mv	a4,a5
ffffffe000203798:	02e00793          	li	a5,46
ffffffe00020379c:	06f71863          	bne	a4,a5,ffffffe00020380c <vprintfmt+0x218>
                fmt++;
ffffffe0002037a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002037a4:	00178793          	addi	a5,a5,1
ffffffe0002037a8:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe0002037ac:	f5043783          	ld	a5,-176(s0)
ffffffe0002037b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002037b4:	00078713          	mv	a4,a5
ffffffe0002037b8:	02a00793          	li	a5,42
ffffffe0002037bc:	00f71e63          	bne	a4,a5,ffffffe0002037d8 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe0002037c0:	f4843783          	ld	a5,-184(s0)
ffffffe0002037c4:	00878713          	addi	a4,a5,8
ffffffe0002037c8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002037cc:	0007a783          	lw	a5,0(a5)
ffffffe0002037d0:	f8f42623          	sw	a5,-116(s0)
ffffffe0002037d4:	5e00006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe0002037d8:	f5043783          	ld	a5,-176(s0)
ffffffe0002037dc:	f5040713          	addi	a4,s0,-176
ffffffe0002037e0:	00a00613          	li	a2,10
ffffffe0002037e4:	00070593          	mv	a1,a4
ffffffe0002037e8:	00078513          	mv	a0,a5
ffffffe0002037ec:	80dff0ef          	jal	ffffffe000202ff8 <strtol>
ffffffe0002037f0:	00050793          	mv	a5,a0
ffffffe0002037f4:	0007879b          	sext.w	a5,a5
ffffffe0002037f8:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe0002037fc:	f5043783          	ld	a5,-176(s0)
ffffffe000203800:	fff78793          	addi	a5,a5,-1
ffffffe000203804:	f4f43823          	sd	a5,-176(s0)
ffffffe000203808:	5ac0006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe00020380c:	f5043783          	ld	a5,-176(s0)
ffffffe000203810:	0007c783          	lbu	a5,0(a5)
ffffffe000203814:	00078713          	mv	a4,a5
ffffffe000203818:	07800793          	li	a5,120
ffffffe00020381c:	02f70663          	beq	a4,a5,ffffffe000203848 <vprintfmt+0x254>
ffffffe000203820:	f5043783          	ld	a5,-176(s0)
ffffffe000203824:	0007c783          	lbu	a5,0(a5)
ffffffe000203828:	00078713          	mv	a4,a5
ffffffe00020382c:	05800793          	li	a5,88
ffffffe000203830:	00f70c63          	beq	a4,a5,ffffffe000203848 <vprintfmt+0x254>
ffffffe000203834:	f5043783          	ld	a5,-176(s0)
ffffffe000203838:	0007c783          	lbu	a5,0(a5)
ffffffe00020383c:	00078713          	mv	a4,a5
ffffffe000203840:	07000793          	li	a5,112
ffffffe000203844:	30f71263          	bne	a4,a5,ffffffe000203b48 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000203848:	f5043783          	ld	a5,-176(s0)
ffffffe00020384c:	0007c783          	lbu	a5,0(a5)
ffffffe000203850:	00078713          	mv	a4,a5
ffffffe000203854:	07000793          	li	a5,112
ffffffe000203858:	00f70663          	beq	a4,a5,ffffffe000203864 <vprintfmt+0x270>
ffffffe00020385c:	f8144783          	lbu	a5,-127(s0)
ffffffe000203860:	00078663          	beqz	a5,ffffffe00020386c <vprintfmt+0x278>
ffffffe000203864:	00100793          	li	a5,1
ffffffe000203868:	0080006f          	j	ffffffe000203870 <vprintfmt+0x27c>
ffffffe00020386c:	00000793          	li	a5,0
ffffffe000203870:	faf403a3          	sb	a5,-89(s0)
ffffffe000203874:	fa744783          	lbu	a5,-89(s0)
ffffffe000203878:	0017f793          	andi	a5,a5,1
ffffffe00020387c:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000203880:	fa744783          	lbu	a5,-89(s0)
ffffffe000203884:	0ff7f793          	zext.b	a5,a5
ffffffe000203888:	00078c63          	beqz	a5,ffffffe0002038a0 <vprintfmt+0x2ac>
ffffffe00020388c:	f4843783          	ld	a5,-184(s0)
ffffffe000203890:	00878713          	addi	a4,a5,8
ffffffe000203894:	f4e43423          	sd	a4,-184(s0)
ffffffe000203898:	0007b783          	ld	a5,0(a5)
ffffffe00020389c:	01c0006f          	j	ffffffe0002038b8 <vprintfmt+0x2c4>
ffffffe0002038a0:	f4843783          	ld	a5,-184(s0)
ffffffe0002038a4:	00878713          	addi	a4,a5,8
ffffffe0002038a8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002038ac:	0007a783          	lw	a5,0(a5)
ffffffe0002038b0:	02079793          	slli	a5,a5,0x20
ffffffe0002038b4:	0207d793          	srli	a5,a5,0x20
ffffffe0002038b8:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe0002038bc:	f8c42783          	lw	a5,-116(s0)
ffffffe0002038c0:	02079463          	bnez	a5,ffffffe0002038e8 <vprintfmt+0x2f4>
ffffffe0002038c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002038c8:	02079063          	bnez	a5,ffffffe0002038e8 <vprintfmt+0x2f4>
ffffffe0002038cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002038d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002038d4:	00078713          	mv	a4,a5
ffffffe0002038d8:	07000793          	li	a5,112
ffffffe0002038dc:	00f70663          	beq	a4,a5,ffffffe0002038e8 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe0002038e0:	f8040023          	sb	zero,-128(s0)
ffffffe0002038e4:	4d00006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe0002038e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002038ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002038f0:	00078713          	mv	a4,a5
ffffffe0002038f4:	07000793          	li	a5,112
ffffffe0002038f8:	00f70a63          	beq	a4,a5,ffffffe00020390c <vprintfmt+0x318>
ffffffe0002038fc:	f8244783          	lbu	a5,-126(s0)
ffffffe000203900:	00078a63          	beqz	a5,ffffffe000203914 <vprintfmt+0x320>
ffffffe000203904:	fe043783          	ld	a5,-32(s0)
ffffffe000203908:	00078663          	beqz	a5,ffffffe000203914 <vprintfmt+0x320>
ffffffe00020390c:	00100793          	li	a5,1
ffffffe000203910:	0080006f          	j	ffffffe000203918 <vprintfmt+0x324>
ffffffe000203914:	00000793          	li	a5,0
ffffffe000203918:	faf40323          	sb	a5,-90(s0)
ffffffe00020391c:	fa644783          	lbu	a5,-90(s0)
ffffffe000203920:	0017f793          	andi	a5,a5,1
ffffffe000203924:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000203928:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe00020392c:	f5043783          	ld	a5,-176(s0)
ffffffe000203930:	0007c783          	lbu	a5,0(a5)
ffffffe000203934:	00078713          	mv	a4,a5
ffffffe000203938:	05800793          	li	a5,88
ffffffe00020393c:	00f71863          	bne	a4,a5,ffffffe00020394c <vprintfmt+0x358>
ffffffe000203940:	00001797          	auipc	a5,0x1
ffffffe000203944:	db078793          	addi	a5,a5,-592 # ffffffe0002046f0 <upperxdigits.1>
ffffffe000203948:	00c0006f          	j	ffffffe000203954 <vprintfmt+0x360>
ffffffe00020394c:	00001797          	auipc	a5,0x1
ffffffe000203950:	dbc78793          	addi	a5,a5,-580 # ffffffe000204708 <lowerxdigits.0>
ffffffe000203954:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000203958:	fe043783          	ld	a5,-32(s0)
ffffffe00020395c:	00f7f793          	andi	a5,a5,15
ffffffe000203960:	f9843703          	ld	a4,-104(s0)
ffffffe000203964:	00f70733          	add	a4,a4,a5
ffffffe000203968:	fdc42783          	lw	a5,-36(s0)
ffffffe00020396c:	0017869b          	addiw	a3,a5,1
ffffffe000203970:	fcd42e23          	sw	a3,-36(s0)
ffffffe000203974:	00074703          	lbu	a4,0(a4)
ffffffe000203978:	ff078793          	addi	a5,a5,-16
ffffffe00020397c:	008787b3          	add	a5,a5,s0
ffffffe000203980:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000203984:	fe043783          	ld	a5,-32(s0)
ffffffe000203988:	0047d793          	srli	a5,a5,0x4
ffffffe00020398c:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000203990:	fe043783          	ld	a5,-32(s0)
ffffffe000203994:	fc0792e3          	bnez	a5,ffffffe000203958 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000203998:	f8c42783          	lw	a5,-116(s0)
ffffffe00020399c:	00078713          	mv	a4,a5
ffffffe0002039a0:	fff00793          	li	a5,-1
ffffffe0002039a4:	02f71663          	bne	a4,a5,ffffffe0002039d0 <vprintfmt+0x3dc>
ffffffe0002039a8:	f8344783          	lbu	a5,-125(s0)
ffffffe0002039ac:	02078263          	beqz	a5,ffffffe0002039d0 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe0002039b0:	f8842703          	lw	a4,-120(s0)
ffffffe0002039b4:	fa644783          	lbu	a5,-90(s0)
ffffffe0002039b8:	0007879b          	sext.w	a5,a5
ffffffe0002039bc:	0017979b          	slliw	a5,a5,0x1
ffffffe0002039c0:	0007879b          	sext.w	a5,a5
ffffffe0002039c4:	40f707bb          	subw	a5,a4,a5
ffffffe0002039c8:	0007879b          	sext.w	a5,a5
ffffffe0002039cc:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002039d0:	f8842703          	lw	a4,-120(s0)
ffffffe0002039d4:	fa644783          	lbu	a5,-90(s0)
ffffffe0002039d8:	0007879b          	sext.w	a5,a5
ffffffe0002039dc:	0017979b          	slliw	a5,a5,0x1
ffffffe0002039e0:	0007879b          	sext.w	a5,a5
ffffffe0002039e4:	40f707bb          	subw	a5,a4,a5
ffffffe0002039e8:	0007871b          	sext.w	a4,a5
ffffffe0002039ec:	fdc42783          	lw	a5,-36(s0)
ffffffe0002039f0:	f8f42a23          	sw	a5,-108(s0)
ffffffe0002039f4:	f8c42783          	lw	a5,-116(s0)
ffffffe0002039f8:	f8f42823          	sw	a5,-112(s0)
ffffffe0002039fc:	f9442783          	lw	a5,-108(s0)
ffffffe000203a00:	00078593          	mv	a1,a5
ffffffe000203a04:	f9042783          	lw	a5,-112(s0)
ffffffe000203a08:	00078613          	mv	a2,a5
ffffffe000203a0c:	0006069b          	sext.w	a3,a2
ffffffe000203a10:	0005879b          	sext.w	a5,a1
ffffffe000203a14:	00f6d463          	bge	a3,a5,ffffffe000203a1c <vprintfmt+0x428>
ffffffe000203a18:	00058613          	mv	a2,a1
ffffffe000203a1c:	0006079b          	sext.w	a5,a2
ffffffe000203a20:	40f707bb          	subw	a5,a4,a5
ffffffe000203a24:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203a28:	0280006f          	j	ffffffe000203a50 <vprintfmt+0x45c>
                    putch(' ');
ffffffe000203a2c:	f5843783          	ld	a5,-168(s0)
ffffffe000203a30:	02000513          	li	a0,32
ffffffe000203a34:	000780e7          	jalr	a5
                    ++written;
ffffffe000203a38:	fec42783          	lw	a5,-20(s0)
ffffffe000203a3c:	0017879b          	addiw	a5,a5,1
ffffffe000203a40:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000203a44:	fd842783          	lw	a5,-40(s0)
ffffffe000203a48:	fff7879b          	addiw	a5,a5,-1
ffffffe000203a4c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203a50:	fd842783          	lw	a5,-40(s0)
ffffffe000203a54:	0007879b          	sext.w	a5,a5
ffffffe000203a58:	fcf04ae3          	bgtz	a5,ffffffe000203a2c <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000203a5c:	fa644783          	lbu	a5,-90(s0)
ffffffe000203a60:	0ff7f793          	zext.b	a5,a5
ffffffe000203a64:	04078463          	beqz	a5,ffffffe000203aac <vprintfmt+0x4b8>
                    putch('0');
ffffffe000203a68:	f5843783          	ld	a5,-168(s0)
ffffffe000203a6c:	03000513          	li	a0,48
ffffffe000203a70:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000203a74:	f5043783          	ld	a5,-176(s0)
ffffffe000203a78:	0007c783          	lbu	a5,0(a5)
ffffffe000203a7c:	00078713          	mv	a4,a5
ffffffe000203a80:	05800793          	li	a5,88
ffffffe000203a84:	00f71663          	bne	a4,a5,ffffffe000203a90 <vprintfmt+0x49c>
ffffffe000203a88:	05800793          	li	a5,88
ffffffe000203a8c:	0080006f          	j	ffffffe000203a94 <vprintfmt+0x4a0>
ffffffe000203a90:	07800793          	li	a5,120
ffffffe000203a94:	f5843703          	ld	a4,-168(s0)
ffffffe000203a98:	00078513          	mv	a0,a5
ffffffe000203a9c:	000700e7          	jalr	a4
                    written += 2;
ffffffe000203aa0:	fec42783          	lw	a5,-20(s0)
ffffffe000203aa4:	0027879b          	addiw	a5,a5,2
ffffffe000203aa8:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000203aac:	fdc42783          	lw	a5,-36(s0)
ffffffe000203ab0:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203ab4:	0280006f          	j	ffffffe000203adc <vprintfmt+0x4e8>
                    putch('0');
ffffffe000203ab8:	f5843783          	ld	a5,-168(s0)
ffffffe000203abc:	03000513          	li	a0,48
ffffffe000203ac0:	000780e7          	jalr	a5
                    ++written;
ffffffe000203ac4:	fec42783          	lw	a5,-20(s0)
ffffffe000203ac8:	0017879b          	addiw	a5,a5,1
ffffffe000203acc:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000203ad0:	fd442783          	lw	a5,-44(s0)
ffffffe000203ad4:	0017879b          	addiw	a5,a5,1
ffffffe000203ad8:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203adc:	f8c42703          	lw	a4,-116(s0)
ffffffe000203ae0:	fd442783          	lw	a5,-44(s0)
ffffffe000203ae4:	0007879b          	sext.w	a5,a5
ffffffe000203ae8:	fce7c8e3          	blt	a5,a4,ffffffe000203ab8 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203aec:	fdc42783          	lw	a5,-36(s0)
ffffffe000203af0:	fff7879b          	addiw	a5,a5,-1
ffffffe000203af4:	fcf42823          	sw	a5,-48(s0)
ffffffe000203af8:	03c0006f          	j	ffffffe000203b34 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000203afc:	fd042783          	lw	a5,-48(s0)
ffffffe000203b00:	ff078793          	addi	a5,a5,-16
ffffffe000203b04:	008787b3          	add	a5,a5,s0
ffffffe000203b08:	f807c783          	lbu	a5,-128(a5)
ffffffe000203b0c:	0007871b          	sext.w	a4,a5
ffffffe000203b10:	f5843783          	ld	a5,-168(s0)
ffffffe000203b14:	00070513          	mv	a0,a4
ffffffe000203b18:	000780e7          	jalr	a5
                    ++written;
ffffffe000203b1c:	fec42783          	lw	a5,-20(s0)
ffffffe000203b20:	0017879b          	addiw	a5,a5,1
ffffffe000203b24:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203b28:	fd042783          	lw	a5,-48(s0)
ffffffe000203b2c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203b30:	fcf42823          	sw	a5,-48(s0)
ffffffe000203b34:	fd042783          	lw	a5,-48(s0)
ffffffe000203b38:	0007879b          	sext.w	a5,a5
ffffffe000203b3c:	fc07d0e3          	bgez	a5,ffffffe000203afc <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000203b40:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000203b44:	2700006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000203b48:	f5043783          	ld	a5,-176(s0)
ffffffe000203b4c:	0007c783          	lbu	a5,0(a5)
ffffffe000203b50:	00078713          	mv	a4,a5
ffffffe000203b54:	06400793          	li	a5,100
ffffffe000203b58:	02f70663          	beq	a4,a5,ffffffe000203b84 <vprintfmt+0x590>
ffffffe000203b5c:	f5043783          	ld	a5,-176(s0)
ffffffe000203b60:	0007c783          	lbu	a5,0(a5)
ffffffe000203b64:	00078713          	mv	a4,a5
ffffffe000203b68:	06900793          	li	a5,105
ffffffe000203b6c:	00f70c63          	beq	a4,a5,ffffffe000203b84 <vprintfmt+0x590>
ffffffe000203b70:	f5043783          	ld	a5,-176(s0)
ffffffe000203b74:	0007c783          	lbu	a5,0(a5)
ffffffe000203b78:	00078713          	mv	a4,a5
ffffffe000203b7c:	07500793          	li	a5,117
ffffffe000203b80:	08f71063          	bne	a4,a5,ffffffe000203c00 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000203b84:	f8144783          	lbu	a5,-127(s0)
ffffffe000203b88:	00078c63          	beqz	a5,ffffffe000203ba0 <vprintfmt+0x5ac>
ffffffe000203b8c:	f4843783          	ld	a5,-184(s0)
ffffffe000203b90:	00878713          	addi	a4,a5,8
ffffffe000203b94:	f4e43423          	sd	a4,-184(s0)
ffffffe000203b98:	0007b783          	ld	a5,0(a5)
ffffffe000203b9c:	0140006f          	j	ffffffe000203bb0 <vprintfmt+0x5bc>
ffffffe000203ba0:	f4843783          	ld	a5,-184(s0)
ffffffe000203ba4:	00878713          	addi	a4,a5,8
ffffffe000203ba8:	f4e43423          	sd	a4,-184(s0)
ffffffe000203bac:	0007a783          	lw	a5,0(a5)
ffffffe000203bb0:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000203bb4:	fa843583          	ld	a1,-88(s0)
ffffffe000203bb8:	f5043783          	ld	a5,-176(s0)
ffffffe000203bbc:	0007c783          	lbu	a5,0(a5)
ffffffe000203bc0:	0007871b          	sext.w	a4,a5
ffffffe000203bc4:	07500793          	li	a5,117
ffffffe000203bc8:	40f707b3          	sub	a5,a4,a5
ffffffe000203bcc:	00f037b3          	snez	a5,a5
ffffffe000203bd0:	0ff7f793          	zext.b	a5,a5
ffffffe000203bd4:	f8040713          	addi	a4,s0,-128
ffffffe000203bd8:	00070693          	mv	a3,a4
ffffffe000203bdc:	00078613          	mv	a2,a5
ffffffe000203be0:	f5843503          	ld	a0,-168(s0)
ffffffe000203be4:	f08ff0ef          	jal	ffffffe0002032ec <print_dec_int>
ffffffe000203be8:	00050793          	mv	a5,a0
ffffffe000203bec:	fec42703          	lw	a4,-20(s0)
ffffffe000203bf0:	00f707bb          	addw	a5,a4,a5
ffffffe000203bf4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203bf8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000203bfc:	1b80006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000203c00:	f5043783          	ld	a5,-176(s0)
ffffffe000203c04:	0007c783          	lbu	a5,0(a5)
ffffffe000203c08:	00078713          	mv	a4,a5
ffffffe000203c0c:	06e00793          	li	a5,110
ffffffe000203c10:	04f71c63          	bne	a4,a5,ffffffe000203c68 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000203c14:	f8144783          	lbu	a5,-127(s0)
ffffffe000203c18:	02078463          	beqz	a5,ffffffe000203c40 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000203c1c:	f4843783          	ld	a5,-184(s0)
ffffffe000203c20:	00878713          	addi	a4,a5,8
ffffffe000203c24:	f4e43423          	sd	a4,-184(s0)
ffffffe000203c28:	0007b783          	ld	a5,0(a5)
ffffffe000203c2c:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000203c30:	fec42703          	lw	a4,-20(s0)
ffffffe000203c34:	fb043783          	ld	a5,-80(s0)
ffffffe000203c38:	00e7b023          	sd	a4,0(a5)
ffffffe000203c3c:	0240006f          	j	ffffffe000203c60 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000203c40:	f4843783          	ld	a5,-184(s0)
ffffffe000203c44:	00878713          	addi	a4,a5,8
ffffffe000203c48:	f4e43423          	sd	a4,-184(s0)
ffffffe000203c4c:	0007b783          	ld	a5,0(a5)
ffffffe000203c50:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000203c54:	fb843783          	ld	a5,-72(s0)
ffffffe000203c58:	fec42703          	lw	a4,-20(s0)
ffffffe000203c5c:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000203c60:	f8040023          	sb	zero,-128(s0)
ffffffe000203c64:	1500006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000203c68:	f5043783          	ld	a5,-176(s0)
ffffffe000203c6c:	0007c783          	lbu	a5,0(a5)
ffffffe000203c70:	00078713          	mv	a4,a5
ffffffe000203c74:	07300793          	li	a5,115
ffffffe000203c78:	02f71e63          	bne	a4,a5,ffffffe000203cb4 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000203c7c:	f4843783          	ld	a5,-184(s0)
ffffffe000203c80:	00878713          	addi	a4,a5,8
ffffffe000203c84:	f4e43423          	sd	a4,-184(s0)
ffffffe000203c88:	0007b783          	ld	a5,0(a5)
ffffffe000203c8c:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000203c90:	fc043583          	ld	a1,-64(s0)
ffffffe000203c94:	f5843503          	ld	a0,-168(s0)
ffffffe000203c98:	dccff0ef          	jal	ffffffe000203264 <puts_wo_nl>
ffffffe000203c9c:	00050793          	mv	a5,a0
ffffffe000203ca0:	fec42703          	lw	a4,-20(s0)
ffffffe000203ca4:	00f707bb          	addw	a5,a4,a5
ffffffe000203ca8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203cac:	f8040023          	sb	zero,-128(s0)
ffffffe000203cb0:	1040006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000203cb4:	f5043783          	ld	a5,-176(s0)
ffffffe000203cb8:	0007c783          	lbu	a5,0(a5)
ffffffe000203cbc:	00078713          	mv	a4,a5
ffffffe000203cc0:	06300793          	li	a5,99
ffffffe000203cc4:	02f71e63          	bne	a4,a5,ffffffe000203d00 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000203cc8:	f4843783          	ld	a5,-184(s0)
ffffffe000203ccc:	00878713          	addi	a4,a5,8
ffffffe000203cd0:	f4e43423          	sd	a4,-184(s0)
ffffffe000203cd4:	0007a783          	lw	a5,0(a5)
ffffffe000203cd8:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000203cdc:	fcc42703          	lw	a4,-52(s0)
ffffffe000203ce0:	f5843783          	ld	a5,-168(s0)
ffffffe000203ce4:	00070513          	mv	a0,a4
ffffffe000203ce8:	000780e7          	jalr	a5
                ++written;
ffffffe000203cec:	fec42783          	lw	a5,-20(s0)
ffffffe000203cf0:	0017879b          	addiw	a5,a5,1
ffffffe000203cf4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203cf8:	f8040023          	sb	zero,-128(s0)
ffffffe000203cfc:	0b80006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000203d00:	f5043783          	ld	a5,-176(s0)
ffffffe000203d04:	0007c783          	lbu	a5,0(a5)
ffffffe000203d08:	00078713          	mv	a4,a5
ffffffe000203d0c:	02500793          	li	a5,37
ffffffe000203d10:	02f71263          	bne	a4,a5,ffffffe000203d34 <vprintfmt+0x740>
                putch('%');
ffffffe000203d14:	f5843783          	ld	a5,-168(s0)
ffffffe000203d18:	02500513          	li	a0,37
ffffffe000203d1c:	000780e7          	jalr	a5
                ++written;
ffffffe000203d20:	fec42783          	lw	a5,-20(s0)
ffffffe000203d24:	0017879b          	addiw	a5,a5,1
ffffffe000203d28:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203d2c:	f8040023          	sb	zero,-128(s0)
ffffffe000203d30:	0840006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000203d34:	f5043783          	ld	a5,-176(s0)
ffffffe000203d38:	0007c783          	lbu	a5,0(a5)
ffffffe000203d3c:	0007871b          	sext.w	a4,a5
ffffffe000203d40:	f5843783          	ld	a5,-168(s0)
ffffffe000203d44:	00070513          	mv	a0,a4
ffffffe000203d48:	000780e7          	jalr	a5
                ++written;
ffffffe000203d4c:	fec42783          	lw	a5,-20(s0)
ffffffe000203d50:	0017879b          	addiw	a5,a5,1
ffffffe000203d54:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203d58:	f8040023          	sb	zero,-128(s0)
ffffffe000203d5c:	0580006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000203d60:	f5043783          	ld	a5,-176(s0)
ffffffe000203d64:	0007c783          	lbu	a5,0(a5)
ffffffe000203d68:	00078713          	mv	a4,a5
ffffffe000203d6c:	02500793          	li	a5,37
ffffffe000203d70:	02f71063          	bne	a4,a5,ffffffe000203d90 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000203d74:	f8043023          	sd	zero,-128(s0)
ffffffe000203d78:	f8043423          	sd	zero,-120(s0)
ffffffe000203d7c:	00100793          	li	a5,1
ffffffe000203d80:	f8f40023          	sb	a5,-128(s0)
ffffffe000203d84:	fff00793          	li	a5,-1
ffffffe000203d88:	f8f42623          	sw	a5,-116(s0)
ffffffe000203d8c:	0280006f          	j	ffffffe000203db4 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000203d90:	f5043783          	ld	a5,-176(s0)
ffffffe000203d94:	0007c783          	lbu	a5,0(a5)
ffffffe000203d98:	0007871b          	sext.w	a4,a5
ffffffe000203d9c:	f5843783          	ld	a5,-168(s0)
ffffffe000203da0:	00070513          	mv	a0,a4
ffffffe000203da4:	000780e7          	jalr	a5
            ++written;
ffffffe000203da8:	fec42783          	lw	a5,-20(s0)
ffffffe000203dac:	0017879b          	addiw	a5,a5,1
ffffffe000203db0:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000203db4:	f5043783          	ld	a5,-176(s0)
ffffffe000203db8:	00178793          	addi	a5,a5,1
ffffffe000203dbc:	f4f43823          	sd	a5,-176(s0)
ffffffe000203dc0:	f5043783          	ld	a5,-176(s0)
ffffffe000203dc4:	0007c783          	lbu	a5,0(a5)
ffffffe000203dc8:	84079ce3          	bnez	a5,ffffffe000203620 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000203dcc:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203dd0:	00078513          	mv	a0,a5
ffffffe000203dd4:	0b813083          	ld	ra,184(sp)
ffffffe000203dd8:	0b013403          	ld	s0,176(sp)
ffffffe000203ddc:	0c010113          	addi	sp,sp,192
ffffffe000203de0:	00008067          	ret

ffffffe000203de4 <printk>:

int printk(const char* s, ...) {
ffffffe000203de4:	f9010113          	addi	sp,sp,-112
ffffffe000203de8:	02113423          	sd	ra,40(sp)
ffffffe000203dec:	02813023          	sd	s0,32(sp)
ffffffe000203df0:	03010413          	addi	s0,sp,48
ffffffe000203df4:	fca43c23          	sd	a0,-40(s0)
ffffffe000203df8:	00b43423          	sd	a1,8(s0)
ffffffe000203dfc:	00c43823          	sd	a2,16(s0)
ffffffe000203e00:	00d43c23          	sd	a3,24(s0)
ffffffe000203e04:	02e43023          	sd	a4,32(s0)
ffffffe000203e08:	02f43423          	sd	a5,40(s0)
ffffffe000203e0c:	03043823          	sd	a6,48(s0)
ffffffe000203e10:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000203e14:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000203e18:	04040793          	addi	a5,s0,64
ffffffe000203e1c:	fcf43823          	sd	a5,-48(s0)
ffffffe000203e20:	fd043783          	ld	a5,-48(s0)
ffffffe000203e24:	fc878793          	addi	a5,a5,-56
ffffffe000203e28:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000203e2c:	fe043783          	ld	a5,-32(s0)
ffffffe000203e30:	00078613          	mv	a2,a5
ffffffe000203e34:	fd843583          	ld	a1,-40(s0)
ffffffe000203e38:	fffff517          	auipc	a0,0xfffff
ffffffe000203e3c:	11850513          	addi	a0,a0,280 # ffffffe000202f50 <putc>
ffffffe000203e40:	fb4ff0ef          	jal	ffffffe0002035f4 <vprintfmt>
ffffffe000203e44:	00050793          	mv	a5,a0
ffffffe000203e48:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000203e4c:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203e50:	00078513          	mv	a0,a5
ffffffe000203e54:	02813083          	ld	ra,40(sp)
ffffffe000203e58:	02013403          	ld	s0,32(sp)
ffffffe000203e5c:	07010113          	addi	sp,sp,112
ffffffe000203e60:	00008067          	ret

ffffffe000203e64 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000203e64:	fe010113          	addi	sp,sp,-32
ffffffe000203e68:	00813c23          	sd	s0,24(sp)
ffffffe000203e6c:	02010413          	addi	s0,sp,32
ffffffe000203e70:	00050793          	mv	a5,a0
ffffffe000203e74:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000203e78:	fec42783          	lw	a5,-20(s0)
ffffffe000203e7c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203e80:	0007879b          	sext.w	a5,a5
ffffffe000203e84:	02079713          	slli	a4,a5,0x20
ffffffe000203e88:	02075713          	srli	a4,a4,0x20
ffffffe000203e8c:	00006797          	auipc	a5,0x6
ffffffe000203e90:	18c78793          	addi	a5,a5,396 # ffffffe00020a018 <seed>
ffffffe000203e94:	00e7b023          	sd	a4,0(a5)
}
ffffffe000203e98:	00000013          	nop
ffffffe000203e9c:	01813403          	ld	s0,24(sp)
ffffffe000203ea0:	02010113          	addi	sp,sp,32
ffffffe000203ea4:	00008067          	ret

ffffffe000203ea8 <rand>:

int rand(void) {
ffffffe000203ea8:	ff010113          	addi	sp,sp,-16
ffffffe000203eac:	00813423          	sd	s0,8(sp)
ffffffe000203eb0:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000203eb4:	00006797          	auipc	a5,0x6
ffffffe000203eb8:	16478793          	addi	a5,a5,356 # ffffffe00020a018 <seed>
ffffffe000203ebc:	0007b703          	ld	a4,0(a5)
ffffffe000203ec0:	00001797          	auipc	a5,0x1
ffffffe000203ec4:	86078793          	addi	a5,a5,-1952 # ffffffe000204720 <lowerxdigits.0+0x18>
ffffffe000203ec8:	0007b783          	ld	a5,0(a5)
ffffffe000203ecc:	02f707b3          	mul	a5,a4,a5
ffffffe000203ed0:	00178713          	addi	a4,a5,1
ffffffe000203ed4:	00006797          	auipc	a5,0x6
ffffffe000203ed8:	14478793          	addi	a5,a5,324 # ffffffe00020a018 <seed>
ffffffe000203edc:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000203ee0:	00006797          	auipc	a5,0x6
ffffffe000203ee4:	13878793          	addi	a5,a5,312 # ffffffe00020a018 <seed>
ffffffe000203ee8:	0007b783          	ld	a5,0(a5)
ffffffe000203eec:	0217d793          	srli	a5,a5,0x21
ffffffe000203ef0:	0007879b          	sext.w	a5,a5
}
ffffffe000203ef4:	00078513          	mv	a0,a5
ffffffe000203ef8:	00813403          	ld	s0,8(sp)
ffffffe000203efc:	01010113          	addi	sp,sp,16
ffffffe000203f00:	00008067          	ret

ffffffe000203f04 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000203f04:	fc010113          	addi	sp,sp,-64
ffffffe000203f08:	02813c23          	sd	s0,56(sp)
ffffffe000203f0c:	04010413          	addi	s0,sp,64
ffffffe000203f10:	fca43c23          	sd	a0,-40(s0)
ffffffe000203f14:	00058793          	mv	a5,a1
ffffffe000203f18:	fcc43423          	sd	a2,-56(s0)
ffffffe000203f1c:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000203f20:	fd843783          	ld	a5,-40(s0)
ffffffe000203f24:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203f28:	fe043423          	sd	zero,-24(s0)
ffffffe000203f2c:	0280006f          	j	ffffffe000203f54 <memset+0x50>
        s[i] = c;
ffffffe000203f30:	fe043703          	ld	a4,-32(s0)
ffffffe000203f34:	fe843783          	ld	a5,-24(s0)
ffffffe000203f38:	00f707b3          	add	a5,a4,a5
ffffffe000203f3c:	fd442703          	lw	a4,-44(s0)
ffffffe000203f40:	0ff77713          	zext.b	a4,a4
ffffffe000203f44:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203f48:	fe843783          	ld	a5,-24(s0)
ffffffe000203f4c:	00178793          	addi	a5,a5,1
ffffffe000203f50:	fef43423          	sd	a5,-24(s0)
ffffffe000203f54:	fe843703          	ld	a4,-24(s0)
ffffffe000203f58:	fc843783          	ld	a5,-56(s0)
ffffffe000203f5c:	fcf76ae3          	bltu	a4,a5,ffffffe000203f30 <memset+0x2c>
    }
    return dest;
ffffffe000203f60:	fd843783          	ld	a5,-40(s0)
}
ffffffe000203f64:	00078513          	mv	a0,a5
ffffffe000203f68:	03813403          	ld	s0,56(sp)
ffffffe000203f6c:	04010113          	addi	sp,sp,64
ffffffe000203f70:	00008067          	ret
