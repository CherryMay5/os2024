
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .section .text.init     # 从.text.entry 改为 .text.init
    .globl _start
_start: # entry

    # (previous) initialize stack :set sp(stack pointer) point at the top of the stack
    la sp,boot_stack_top    
ffffffe000200000:	00009117          	auipc	sp,0x9
ffffffe000200004:	00010113          	mv	sp,sp

    # virtual memory management : 设置虚拟地址空间
    call setup_vm
ffffffe000200008:	720020ef          	jal	ffffffe000202728 <setup_vm>
    call relocate
ffffffe00020000c:	030000ef          	jal	ffffffe00020003c <relocate>
    
    # call mm_init function  memory management
    call mm_init
ffffffe000200010:	3d5000ef          	jal	ffffffe000200be4 <mm_init>

    # call setup_vm_final :完成虚拟地址空间的初始化
    call setup_vm_final
ffffffe000200014:	7f8020ef          	jal	ffffffe00020280c <setup_vm_final>

    # 线程初始化
    call task_init
ffffffe000200018:	2a0010ef          	jal	ffffffe0002012b8 <task_init>

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
ffffffe000200034:	62d010ef          	jal	ffffffe000201e60 <sbi_set_timer>
    # ori t1,t0,1<<1
    # csrw sstatus,t1
    # -------------------------------------------------------------

    # (previous) jump to start_kernel:jump to main.c start_kernel function
    j start_kernel        
ffffffe000200038:	3290206f          	j	ffffffe000202b60 <start_kernel>

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
ffffffe000200058:	0000a317          	auipc	t1,0xa
ffffffe00020005c:	fa830313          	addi	t1,t1,-88 # ffffffe00020a000 <early_pgtbl>
    srli t1,t1,12   # set PPN
ffffffe000200060:	00c35313          	srli	t1,t1,0xc
    or t0,t1,t0     # combine MODE and PPN
ffffffe000200064:	005362b3          	or	t0,t1,t0
    csrw satp,t0    # set satp
ffffffe000200068:	18029073          	csrw	satp,t0

    ret
ffffffe00020006c:	00008067          	ret

ffffffe000200070 <_traps>:
    .align 2
    .globl _traps 
_traps:

    # sscratch == 0 -----> in kernel
    csrr t0,sscratch
ffffffe000200070:	140022f3          	csrr	t0,sscratch
    bne t0,zero,_u_traps
ffffffe000200074:	14029863          	bnez	t0,ffffffe0002001c4 <_u_traps>

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-35*8
ffffffe000200078:	ee810113          	addi	sp,sp,-280 # ffffffe000208ee8 <_sbss+0xee8>

    sd x0,0*8(sp)     #0
ffffffe00020007c:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)     #ra
ffffffe000200080:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)    #sp
ffffffe000200084:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)    #gp
ffffffe000200088:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)    #tp
ffffffe00020008c:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)    #t0
ffffffe000200090:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
ffffffe000200094:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
ffffffe000200098:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)    #s0/fp
ffffffe00020009c:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)    #s1
ffffffe0002000a0:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)   #a0
ffffffe0002000a4:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
ffffffe0002000a8:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
ffffffe0002000ac:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
ffffffe0002000b0:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
ffffffe0002000b4:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
ffffffe0002000b8:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
ffffffe0002000bc:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
ffffffe0002000c0:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)  #s2
ffffffe0002000c4:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
ffffffe0002000c8:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
ffffffe0002000cc:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
ffffffe0002000d0:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
ffffffe0002000d4:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
ffffffe0002000d8:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
ffffffe0002000dc:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
ffffffe0002000e0:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
ffffffe0002000e4:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
ffffffe0002000e8:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)  #t3
ffffffe0002000ec:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
ffffffe0002000f0:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
ffffffe0002000f4:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
ffffffe0002000f8:	0ff13c23          	sd	t6,248(sp)
    
    csrr t0,sepc        # store sepc
ffffffe0002000fc:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
ffffffe000200100:	10513023          	sd	t0,256(sp)

    csrr t0,sstatus
ffffffe000200104:	100022f3          	csrr	t0,sstatus
    sd t0,33*8(sp)
ffffffe000200108:	10513423          	sd	t0,264(sp)

    csrr t0,stval
ffffffe00020010c:	143022f3          	csrr	t0,stval
    sd t0,34*8(sp)
ffffffe000200110:	10513823          	sd	t0,272(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
ffffffe000200114:	14202573          	csrr	a0,scause
    csrr a1,sepc
ffffffe000200118:	141025f3          	csrr	a1,sepc
    mv a2,sp
ffffffe00020011c:	00010613          	mv	a2,sp
    call trap_handler
ffffffe000200120:	1a8020ef          	jal	ffffffe0002022c8 <trap_handler>
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,34*8(sp)
ffffffe000200124:	11013283          	ld	t0,272(sp)
    csrw stval,t0
ffffffe000200128:	14329073          	csrw	stval,t0
    ld t0,33*8(sp)
ffffffe00020012c:	10813283          	ld	t0,264(sp)
    csrw sstatus,t0
ffffffe000200130:	10029073          	csrw	sstatus,t0
    ld t0,32*8(sp)
ffffffe000200134:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
ffffffe000200138:	14129073          	csrw	sepc,t0
    
    ld x0,0*8(sp)
ffffffe00020013c:	00013003          	ld	zero,0(sp)
    ld x1,1*8(sp)
ffffffe000200140:	00813083          	ld	ra,8(sp)
    ld x3,3*8(sp)
ffffffe000200144:	01813183          	ld	gp,24(sp)
    ld x4,4*8(sp)
ffffffe000200148:	02013203          	ld	tp,32(sp)
    ld x5,5*8(sp)
ffffffe00020014c:	02813283          	ld	t0,40(sp)
    ld x6,6*8(sp)
ffffffe000200150:	03013303          	ld	t1,48(sp)
    ld x7,7*8(sp)
ffffffe000200154:	03813383          	ld	t2,56(sp)
    ld x8,8*8(sp)
ffffffe000200158:	04013403          	ld	s0,64(sp)
    ld x9,9*8(sp)
ffffffe00020015c:	04813483          	ld	s1,72(sp)
    ld x10,10*8(sp)
ffffffe000200160:	05013503          	ld	a0,80(sp)
    ld x11,11*8(sp)
ffffffe000200164:	05813583          	ld	a1,88(sp)
    ld x12,12*8(sp)
ffffffe000200168:	06013603          	ld	a2,96(sp)
    ld x13,13*8(sp)
ffffffe00020016c:	06813683          	ld	a3,104(sp)
    ld x14,14*8(sp)
ffffffe000200170:	07013703          	ld	a4,112(sp)
    ld x15,15*8(sp)
ffffffe000200174:	07813783          	ld	a5,120(sp)
    ld x16,16*8(sp)
ffffffe000200178:	08013803          	ld	a6,128(sp)
    ld x17,17*8(sp)
ffffffe00020017c:	08813883          	ld	a7,136(sp)
    ld x18,18*8(sp)
ffffffe000200180:	09013903          	ld	s2,144(sp)
    ld x19,19*8(sp)
ffffffe000200184:	09813983          	ld	s3,152(sp)
    ld x20,20*8(sp)
ffffffe000200188:	0a013a03          	ld	s4,160(sp)
    ld x21,21*8(sp)
ffffffe00020018c:	0a813a83          	ld	s5,168(sp)
    ld x22,22*8(sp)
ffffffe000200190:	0b013b03          	ld	s6,176(sp)
    ld x23,23*8(sp)
ffffffe000200194:	0b813b83          	ld	s7,184(sp)
    ld x24,24*8(sp)
ffffffe000200198:	0c013c03          	ld	s8,192(sp)
    ld x25,25*8(sp)
ffffffe00020019c:	0c813c83          	ld	s9,200(sp)
    ld x26,26*8(sp)
ffffffe0002001a0:	0d013d03          	ld	s10,208(sp)
    ld x27,27*8(sp)
ffffffe0002001a4:	0d813d83          	ld	s11,216(sp)
    ld x28,28*8(sp)
ffffffe0002001a8:	0e013e03          	ld	t3,224(sp)
    ld x29,29*8(sp)
ffffffe0002001ac:	0e813e83          	ld	t4,232(sp)
    ld x30,30*8(sp)
ffffffe0002001b0:	0f013f03          	ld	t5,240(sp)
    ld x31,31*8(sp)
ffffffe0002001b4:	0f813f83          	ld	t6,248(sp)

    ld x2,2*8(sp)
ffffffe0002001b8:	01013103          	ld	sp,16(sp)

    addi sp,sp,35*8
ffffffe0002001bc:	11810113          	addi	sp,sp,280
    # 4. return from trap:从 trap 中返回
    sret
ffffffe0002001c0:	10200073          	sret

ffffffe0002001c4 <_u_traps>:
# lab4 new ---------------------------------
    .globl _u_traps
_u_traps:
    
    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
ffffffe0002001c4:	14002373          	csrr	t1,sscratch
    csrw sscratch,sp
ffffffe0002001c8:	14011073          	csrw	sscratch,sp
    mv sp,t1
ffffffe0002001cc:	00030113          	mv	sp,t1

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-35*8
ffffffe0002001d0:	ee810113          	addi	sp,sp,-280

    sd x0,0*8(sp)     #0
ffffffe0002001d4:	00013023          	sd	zero,0(sp)
    sd x1,1*8(sp)     #ra
ffffffe0002001d8:	00113423          	sd	ra,8(sp)
    sd x2,2*8(sp)    #sp
ffffffe0002001dc:	00213823          	sd	sp,16(sp)
    sd x3,3*8(sp)    #gp
ffffffe0002001e0:	00313c23          	sd	gp,24(sp)
    sd x4,4*8(sp)    #tp
ffffffe0002001e4:	02413023          	sd	tp,32(sp)
    sd x5,5*8(sp)    #t0
ffffffe0002001e8:	02513423          	sd	t0,40(sp)
    sd x6,6*8(sp)
ffffffe0002001ec:	02613823          	sd	t1,48(sp)
    sd x7,7*8(sp)
ffffffe0002001f0:	02713c23          	sd	t2,56(sp)
    sd x8,8*8(sp)    #s0/fp
ffffffe0002001f4:	04813023          	sd	s0,64(sp)
    sd x9,9*8(sp)    #s1
ffffffe0002001f8:	04913423          	sd	s1,72(sp)
    sd x10,10*8(sp)   #a0
ffffffe0002001fc:	04a13823          	sd	a0,80(sp)
    sd x11,11*8(sp)
ffffffe000200200:	04b13c23          	sd	a1,88(sp)
    sd x12,12*8(sp)
ffffffe000200204:	06c13023          	sd	a2,96(sp)
    sd x13,13*8(sp)
ffffffe000200208:	06d13423          	sd	a3,104(sp)
    sd x14,14*8(sp)
ffffffe00020020c:	06e13823          	sd	a4,112(sp)
    sd x15,15*8(sp)
ffffffe000200210:	06f13c23          	sd	a5,120(sp)
    sd x16,16*8(sp)
ffffffe000200214:	09013023          	sd	a6,128(sp)
    sd x17,17*8(sp)
ffffffe000200218:	09113423          	sd	a7,136(sp)
    sd x18,18*8(sp)  #s2
ffffffe00020021c:	09213823          	sd	s2,144(sp)
    sd x19,19*8(sp)
ffffffe000200220:	09313c23          	sd	s3,152(sp)
    sd x20,20*8(sp)
ffffffe000200224:	0b413023          	sd	s4,160(sp)
    sd x21,21*8(sp)
ffffffe000200228:	0b513423          	sd	s5,168(sp)
    sd x22,22*8(sp)
ffffffe00020022c:	0b613823          	sd	s6,176(sp)
    sd x23,23*8(sp)
ffffffe000200230:	0b713c23          	sd	s7,184(sp)
    sd x24,24*8(sp)
ffffffe000200234:	0d813023          	sd	s8,192(sp)
    sd x25,25*8(sp)
ffffffe000200238:	0d913423          	sd	s9,200(sp)
    sd x26,26*8(sp)
ffffffe00020023c:	0da13823          	sd	s10,208(sp)
    sd x27,27*8(sp)
ffffffe000200240:	0db13c23          	sd	s11,216(sp)
    sd x28,28*8(sp)  #t3
ffffffe000200244:	0fc13023          	sd	t3,224(sp)
    sd x29,29*8(sp)
ffffffe000200248:	0fd13423          	sd	t4,232(sp)
    sd x30,30*8(sp)
ffffffe00020024c:	0fe13823          	sd	t5,240(sp)
    sd x31,31*8(sp)
ffffffe000200250:	0ff13c23          	sd	t6,248(sp)
    
    csrr t0,sepc        # store sepc
ffffffe000200254:	141022f3          	csrr	t0,sepc
    sd t0,32*8(sp)
ffffffe000200258:	10513023          	sd	t0,256(sp)

    csrr t0,sstatus
ffffffe00020025c:	100022f3          	csrr	t0,sstatus
    sd t0,33*8(sp)
ffffffe000200260:	10513423          	sd	t0,264(sp)

    csrr t0,stval
ffffffe000200264:	143022f3          	csrr	t0,stval
    sd t0,34*8(sp)
ffffffe000200268:	10513823          	sd	t0,272(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
ffffffe00020026c:	14202573          	csrr	a0,scause
    csrr a1,sepc
ffffffe000200270:	141025f3          	csrr	a1,sepc
    mv a2,sp
ffffffe000200274:	00010613          	mv	a2,sp
    call trap_handler
ffffffe000200278:	050020ef          	jal	ffffffe0002022c8 <trap_handler>
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,34*8(sp)
ffffffe00020027c:	11013283          	ld	t0,272(sp)
    csrw stval,t0
ffffffe000200280:	14329073          	csrw	stval,t0
    
    ld t0,33*8(sp)
ffffffe000200284:	10813283          	ld	t0,264(sp)
    csrw sstatus,t0
ffffffe000200288:	10029073          	csrw	sstatus,t0

    ld t0,32*8(sp)
ffffffe00020028c:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
ffffffe000200290:	14129073          	csrw	sepc,t0
    
    ld x0,0*8(sp)
ffffffe000200294:	00013003          	ld	zero,0(sp)
    ld x1,1*8(sp)
ffffffe000200298:	00813083          	ld	ra,8(sp)
    ld x3,3*8(sp)
ffffffe00020029c:	01813183          	ld	gp,24(sp)
    ld x4,4*8(sp)
ffffffe0002002a0:	02013203          	ld	tp,32(sp)
    ld x5,5*8(sp)
ffffffe0002002a4:	02813283          	ld	t0,40(sp)
    ld x6,6*8(sp)
ffffffe0002002a8:	03013303          	ld	t1,48(sp)
    ld x7,7*8(sp)
ffffffe0002002ac:	03813383          	ld	t2,56(sp)
    ld x8,8*8(sp)
ffffffe0002002b0:	04013403          	ld	s0,64(sp)
    ld x9,9*8(sp)
ffffffe0002002b4:	04813483          	ld	s1,72(sp)
    ld x10,10*8(sp)
ffffffe0002002b8:	05013503          	ld	a0,80(sp)
    ld x11,11*8(sp)
ffffffe0002002bc:	05813583          	ld	a1,88(sp)
    ld x12,12*8(sp)
ffffffe0002002c0:	06013603          	ld	a2,96(sp)
    ld x13,13*8(sp)
ffffffe0002002c4:	06813683          	ld	a3,104(sp)
    ld x14,14*8(sp)
ffffffe0002002c8:	07013703          	ld	a4,112(sp)
    ld x15,15*8(sp)
ffffffe0002002cc:	07813783          	ld	a5,120(sp)
    ld x16,16*8(sp)
ffffffe0002002d0:	08013803          	ld	a6,128(sp)
    ld x17,17*8(sp)
ffffffe0002002d4:	08813883          	ld	a7,136(sp)
    ld x18,18*8(sp)
ffffffe0002002d8:	09013903          	ld	s2,144(sp)
    ld x19,19*8(sp)
ffffffe0002002dc:	09813983          	ld	s3,152(sp)
    ld x20,20*8(sp)
ffffffe0002002e0:	0a013a03          	ld	s4,160(sp)
    ld x21,21*8(sp)
ffffffe0002002e4:	0a813a83          	ld	s5,168(sp)
    ld x22,22*8(sp)
ffffffe0002002e8:	0b013b03          	ld	s6,176(sp)
    ld x23,23*8(sp)
ffffffe0002002ec:	0b813b83          	ld	s7,184(sp)
    ld x24,24*8(sp)
ffffffe0002002f0:	0c013c03          	ld	s8,192(sp)
    ld x25,25*8(sp)
ffffffe0002002f4:	0c813c83          	ld	s9,200(sp)
    ld x26,26*8(sp)
ffffffe0002002f8:	0d013d03          	ld	s10,208(sp)
    ld x27,27*8(sp)
ffffffe0002002fc:	0d813d83          	ld	s11,216(sp)
    ld x28,28*8(sp)
ffffffe000200300:	0e013e03          	ld	t3,224(sp)
    ld x29,29*8(sp)
ffffffe000200304:	0e813e83          	ld	t4,232(sp)
    ld x30,30*8(sp)
ffffffe000200308:	0f013f03          	ld	t5,240(sp)
    ld x31,31*8(sp)
ffffffe00020030c:	0f813f83          	ld	t6,248(sp)

    ld x2,2*8(sp)
ffffffe000200310:	01013103          	ld	sp,16(sp)

    addi sp,sp,35*8
ffffffe000200314:	11810113          	addi	sp,sp,280

    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
ffffffe000200318:	14002373          	csrr	t1,sscratch
    csrw sscratch,sp
ffffffe00020031c:	14011073          	csrw	sscratch,sp
    mv sp,t1
ffffffe000200320:	00030113          	mv	sp,t1

    # 4. return from trap:从 trap 中返回
    sret
ffffffe000200324:	10200073          	sret

ffffffe000200328 <__dummy>:
    # la t0,dummy
    # csrw sepc,t0

    # lab4 new ---------------------------------
    # 切换内核态栈sp和用户态栈sscratch
    csrr t1,sscratch
ffffffe000200328:	14002373          	csrr	t1,sscratch
    csrw sscratch,sp
ffffffe00020032c:	14011073          	csrw	sscratch,sp
    mv sp,t1
ffffffe000200330:	00030113          	mv	sp,t1
    # ------------------------------------------

    sret
ffffffe000200334:	10200073          	sret

ffffffe000200338 <__switch_to>:
    # YOUR CODE HERE
    # 保存当前线程的 ra,sp,s0~s11 到当前线程的 thread_struct 中；
    # 因为 task_struct = state -> counter -> priority -> pid -> (thread_struct)thread -> *pgd
    # 所以 thread 的起始地址 = prev + 4*8 = prev + 32

    add t0,a0,32
ffffffe000200338:	02050293          	addi	t0,a0,32
    sd ra,0*8(t0)
ffffffe00020033c:	0012b023          	sd	ra,0(t0)
    sd sp,1*8(t0)
ffffffe000200340:	0022b423          	sd	sp,8(t0)
    sd s0,2*8(t0)
ffffffe000200344:	0082b823          	sd	s0,16(t0)
    sd s1,3*8(t0)
ffffffe000200348:	0092bc23          	sd	s1,24(t0)
    sd s2,4*8(t0)
ffffffe00020034c:	0322b023          	sd	s2,32(t0)
    sd s3,5*8(t0)
ffffffe000200350:	0332b423          	sd	s3,40(t0)
    sd s4,6*8(t0)
ffffffe000200354:	0342b823          	sd	s4,48(t0)
    sd s5,7*8(t0)
ffffffe000200358:	0352bc23          	sd	s5,56(t0)
    sd s6,8*8(t0)
ffffffe00020035c:	0562b023          	sd	s6,64(t0)
    sd s7,9*8(t0)
ffffffe000200360:	0572b423          	sd	s7,72(t0)
    sd s8,10*8(t0)
ffffffe000200364:	0582b823          	sd	s8,80(t0)
    sd s9,11*8(t0)
ffffffe000200368:	0592bc23          	sd	s9,88(t0)
    sd s10,12*8(t0)
ffffffe00020036c:	07a2b023          	sd	s10,96(t0)
    sd s11,13*8(t0)
ffffffe000200370:	07b2b423          	sd	s11,104(t0)

    # lab4 new ---------------------------------
    # 保存sepc,sstatus,sscratch
    csrr t2,sepc
ffffffe000200374:	141023f3          	csrr	t2,sepc
    sd t2,14*8(t0)
ffffffe000200378:	0672b823          	sd	t2,112(t0)
    csrr t2,sstatus
ffffffe00020037c:	100023f3          	csrr	t2,sstatus
    sd t2,15*8(t0)
ffffffe000200380:	0672bc23          	sd	t2,120(t0)
    csrr t2,sscratch
ffffffe000200384:	140023f3          	csrr	t2,sscratch
    sd t2,16*8(t0)
ffffffe000200388:	0872b023          	sd	t2,128(t0)
    # ------------------------------------------

    # restore state from next process
    # YOUR CODE HERE
    # 将下一个线程的 thread_struct 中的相关数据载入到 ra,sp,s0~s11 中进行恢复：
    add t1,a1,32
ffffffe00020038c:	02058313          	addi	t1,a1,32
    ld ra,0*8(t1)
ffffffe000200390:	00033083          	ld	ra,0(t1)
    ld sp,1*8(t1)
ffffffe000200394:	00833103          	ld	sp,8(t1)
    ld s0,2*8(t1)
ffffffe000200398:	01033403          	ld	s0,16(t1)
    ld s1,3*8(t1)
ffffffe00020039c:	01833483          	ld	s1,24(t1)
    ld s2,4*8(t1)
ffffffe0002003a0:	02033903          	ld	s2,32(t1)
    ld s3,5*8(t1)
ffffffe0002003a4:	02833983          	ld	s3,40(t1)
    ld s4,6*8(t1)
ffffffe0002003a8:	03033a03          	ld	s4,48(t1)
    ld s5,7*8(t1)
ffffffe0002003ac:	03833a83          	ld	s5,56(t1)
    ld s6,8*8(t1)
ffffffe0002003b0:	04033b03          	ld	s6,64(t1)
    ld s7,9*8(t1)
ffffffe0002003b4:	04833b83          	ld	s7,72(t1)
    ld s8,10*8(t1)
ffffffe0002003b8:	05033c03          	ld	s8,80(t1)
    ld s9,11*8(t1)
ffffffe0002003bc:	05833c83          	ld	s9,88(t1)
    ld s10,12*8(t1)
ffffffe0002003c0:	06033d03          	ld	s10,96(t1)
    ld s11,13*8(t1)
ffffffe0002003c4:	06833d83          	ld	s11,104(t1)

    # lab4 new ---------------------------------
    # 恢复sepc,sstatus,sscratch
    ld t2,14*8(t1)
ffffffe0002003c8:	07033383          	ld	t2,112(t1)
    csrw sepc,t2
ffffffe0002003cc:	14139073          	csrw	sepc,t2
    ld t2,15*8(t1)
ffffffe0002003d0:	07833383          	ld	t2,120(t1)
    csrw sstatus,t2
ffffffe0002003d4:	10039073          	csrw	sstatus,t2
    ld t2,16*8(t1)
ffffffe0002003d8:	08033383          	ld	t2,128(t1)
    csrw sscratch,t2
ffffffe0002003dc:	14039073          	csrw	sscratch,t2

    # 切换页表
    ld t3,17*8(t1)
ffffffe0002003e0:	08833e03          	ld	t3,136(t1)
    li t4,0xffffffdf80000000    # PA2VA_OFFSET
ffffffe0002003e4:	fbf00e9b          	addiw	t4,zero,-65
ffffffe0002003e8:	01fe9e93          	slli	t4,t4,0x1f
    sub t3,t3,t4                # t3=t3-t4
ffffffe0002003ec:	41de0e33          	sub	t3,t3,t4
    srli t3,t3,12               # 12-bit offset
ffffffe0002003f0:	00ce5e13          	srli	t3,t3,0xc
    addi t2,x0,8                # x0:zero   t0=0+8=8
ffffffe0002003f4:	00800393          	li	t2,8
    slli t2,t2,60               # set MODE
ffffffe0002003f8:	03c39393          	slli	t2,t2,0x3c
    or t2,t2,t3
ffffffe0002003fc:	01c3e3b3          	or	t2,t2,t3
    csrw satp,t2                # set satp
ffffffe000200400:	18039073          	csrw	satp,t2

    # 刷新TLB和ICache
    sfence.vma zero, zero
ffffffe000200404:	12000073          	sfence.vma
    # ------------------------------------------

ffffffe000200408:	00008067          	ret

ffffffe00020040c <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe00020040c:	fe010113          	addi	sp,sp,-32
ffffffe000200410:	00813c23          	sd	s0,24(sp)
ffffffe000200414:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time_get;
    __asm__ volatile (
ffffffe000200418:	c01027f3          	rdtime	a5
ffffffe00020041c:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time_get]"
        :[time_get]"=r"(time_get)
    );
    return time_get;
ffffffe000200420:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200424:	00078513          	mv	a0,a5
ffffffe000200428:	01813403          	ld	s0,24(sp)
ffffffe00020042c:	02010113          	addi	sp,sp,32
ffffffe000200430:	00008067          	ret

ffffffe000200434 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200434:	fe010113          	addi	sp,sp,-32
ffffffe000200438:	00113c23          	sd	ra,24(sp)
ffffffe00020043c:	00813823          	sd	s0,16(sp)
ffffffe000200440:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200444:	fc9ff0ef          	jal	ffffffe00020040c <get_cycles>
ffffffe000200448:	00050713          	mv	a4,a0
ffffffe00020044c:	00005797          	auipc	a5,0x5
ffffffe000200450:	bb478793          	addi	a5,a5,-1100 # ffffffe000205000 <TIMECLOCK>
ffffffe000200454:	0007b783          	ld	a5,0(a5)
ffffffe000200458:	00f707b3          	add	a5,a4,a5
ffffffe00020045c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200460:	fe843503          	ld	a0,-24(s0)
ffffffe000200464:	1fd010ef          	jal	ffffffe000201e60 <sbi_set_timer>
ffffffe000200468:	00000013          	nop
ffffffe00020046c:	01813083          	ld	ra,24(sp)
ffffffe000200470:	01013403          	ld	s0,16(sp)
ffffffe000200474:	02010113          	addi	sp,sp,32
ffffffe000200478:	00008067          	ret

ffffffe00020047c <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe00020047c:	fe010113          	addi	sp,sp,-32
ffffffe000200480:	00813c23          	sd	s0,24(sp)
ffffffe000200484:	02010413          	addi	s0,sp,32
ffffffe000200488:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe00020048c:	fe843783          	ld	a5,-24(s0)
ffffffe000200490:	fff78793          	addi	a5,a5,-1
ffffffe000200494:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe000200498:	fe843783          	ld	a5,-24(s0)
ffffffe00020049c:	0017d793          	srli	a5,a5,0x1
ffffffe0002004a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002004a4:	00f767b3          	or	a5,a4,a5
ffffffe0002004a8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe0002004ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002004b0:	0027d793          	srli	a5,a5,0x2
ffffffe0002004b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002004b8:	00f767b3          	or	a5,a4,a5
ffffffe0002004bc:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe0002004c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002004c4:	0047d793          	srli	a5,a5,0x4
ffffffe0002004c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002004cc:	00f767b3          	or	a5,a4,a5
ffffffe0002004d0:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe0002004d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002004d8:	0087d793          	srli	a5,a5,0x8
ffffffe0002004dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002004e0:	00f767b3          	or	a5,a4,a5
ffffffe0002004e4:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe0002004e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002004ec:	0107d793          	srli	a5,a5,0x10
ffffffe0002004f0:	fe843703          	ld	a4,-24(s0)
ffffffe0002004f4:	00f767b3          	or	a5,a4,a5
ffffffe0002004f8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe0002004fc:	fe843783          	ld	a5,-24(s0)
ffffffe000200500:	0207d793          	srli	a5,a5,0x20
ffffffe000200504:	fe843703          	ld	a4,-24(s0)
ffffffe000200508:	00f767b3          	or	a5,a4,a5
ffffffe00020050c:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe000200510:	fe843783          	ld	a5,-24(s0)
ffffffe000200514:	00178793          	addi	a5,a5,1
}
ffffffe000200518:	00078513          	mv	a0,a5
ffffffe00020051c:	01813403          	ld	s0,24(sp)
ffffffe000200520:	02010113          	addi	sp,sp,32
ffffffe000200524:	00008067          	ret

ffffffe000200528 <buddy_init>:

void buddy_init() {
ffffffe000200528:	fd010113          	addi	sp,sp,-48
ffffffe00020052c:	02113423          	sd	ra,40(sp)
ffffffe000200530:	02813023          	sd	s0,32(sp)
ffffffe000200534:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe000200538:	000087b7          	lui	a5,0x8
ffffffe00020053c:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe000200540:	fe843783          	ld	a5,-24(s0)
ffffffe000200544:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe000200548:	fe843783          	ld	a5,-24(s0)
ffffffe00020054c:	00f777b3          	and	a5,a4,a5
ffffffe000200550:	00078863          	beqz	a5,ffffffe000200560 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe000200554:	fe843503          	ld	a0,-24(s0)
ffffffe000200558:	f25ff0ef          	jal	ffffffe00020047c <fixsize>
ffffffe00020055c:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe000200560:	00009797          	auipc	a5,0x9
ffffffe000200564:	ac078793          	addi	a5,a5,-1344 # ffffffe000209020 <buddy>
ffffffe000200568:	fe843703          	ld	a4,-24(s0)
ffffffe00020056c:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200570:	00005797          	auipc	a5,0x5
ffffffe000200574:	a9878793          	addi	a5,a5,-1384 # ffffffe000205008 <free_page_start>
ffffffe000200578:	0007b703          	ld	a4,0(a5)
ffffffe00020057c:	00009797          	auipc	a5,0x9
ffffffe000200580:	aa478793          	addi	a5,a5,-1372 # ffffffe000209020 <buddy>
ffffffe000200584:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe000200588:	00005797          	auipc	a5,0x5
ffffffe00020058c:	a8078793          	addi	a5,a5,-1408 # ffffffe000205008 <free_page_start>
ffffffe000200590:	0007b703          	ld	a4,0(a5)
ffffffe000200594:	00009797          	auipc	a5,0x9
ffffffe000200598:	a8c78793          	addi	a5,a5,-1396 # ffffffe000209020 <buddy>
ffffffe00020059c:	0007b783          	ld	a5,0(a5)
ffffffe0002005a0:	00479793          	slli	a5,a5,0x4
ffffffe0002005a4:	00f70733          	add	a4,a4,a5
ffffffe0002005a8:	00005797          	auipc	a5,0x5
ffffffe0002005ac:	a6078793          	addi	a5,a5,-1440 # ffffffe000205008 <free_page_start>
ffffffe0002005b0:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe0002005b4:	00009797          	auipc	a5,0x9
ffffffe0002005b8:	a6c78793          	addi	a5,a5,-1428 # ffffffe000209020 <buddy>
ffffffe0002005bc:	0087b703          	ld	a4,8(a5)
ffffffe0002005c0:	00009797          	auipc	a5,0x9
ffffffe0002005c4:	a6078793          	addi	a5,a5,-1440 # ffffffe000209020 <buddy>
ffffffe0002005c8:	0007b783          	ld	a5,0(a5)
ffffffe0002005cc:	00479793          	slli	a5,a5,0x4
ffffffe0002005d0:	00078613          	mv	a2,a5
ffffffe0002005d4:	00000593          	li	a1,0
ffffffe0002005d8:	00070513          	mv	a0,a4
ffffffe0002005dc:	594030ef          	jal	ffffffe000203b70 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe0002005e0:	00009797          	auipc	a5,0x9
ffffffe0002005e4:	a4078793          	addi	a5,a5,-1472 # ffffffe000209020 <buddy>
ffffffe0002005e8:	0007b783          	ld	a5,0(a5)
ffffffe0002005ec:	00179793          	slli	a5,a5,0x1
ffffffe0002005f0:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002005f4:	fc043c23          	sd	zero,-40(s0)
ffffffe0002005f8:	0500006f          	j	ffffffe000200648 <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe0002005fc:	fd843783          	ld	a5,-40(s0)
ffffffe000200600:	00178713          	addi	a4,a5,1
ffffffe000200604:	fd843783          	ld	a5,-40(s0)
ffffffe000200608:	00f777b3          	and	a5,a4,a5
ffffffe00020060c:	00079863          	bnez	a5,ffffffe00020061c <buddy_init+0xf4>
            node_size /= 2;
ffffffe000200610:	fe043783          	ld	a5,-32(s0)
ffffffe000200614:	0017d793          	srli	a5,a5,0x1
ffffffe000200618:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe00020061c:	00009797          	auipc	a5,0x9
ffffffe000200620:	a0478793          	addi	a5,a5,-1532 # ffffffe000209020 <buddy>
ffffffe000200624:	0087b703          	ld	a4,8(a5)
ffffffe000200628:	fd843783          	ld	a5,-40(s0)
ffffffe00020062c:	00379793          	slli	a5,a5,0x3
ffffffe000200630:	00f707b3          	add	a5,a4,a5
ffffffe000200634:	fe043703          	ld	a4,-32(s0)
ffffffe000200638:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe00020063c:	fd843783          	ld	a5,-40(s0)
ffffffe000200640:	00178793          	addi	a5,a5,1
ffffffe000200644:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200648:	00009797          	auipc	a5,0x9
ffffffe00020064c:	9d878793          	addi	a5,a5,-1576 # ffffffe000209020 <buddy>
ffffffe000200650:	0007b783          	ld	a5,0(a5)
ffffffe000200654:	00179793          	slli	a5,a5,0x1
ffffffe000200658:	fff78793          	addi	a5,a5,-1
ffffffe00020065c:	fd843703          	ld	a4,-40(s0)
ffffffe000200660:	f8f76ee3          	bltu	a4,a5,ffffffe0002005fc <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200664:	fc043823          	sd	zero,-48(s0)
ffffffe000200668:	0180006f          	j	ffffffe000200680 <buddy_init+0x158>
        buddy_alloc(1);
ffffffe00020066c:	00100513          	li	a0,1
ffffffe000200670:	1fc000ef          	jal	ffffffe00020086c <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200674:	fd043783          	ld	a5,-48(s0)
ffffffe000200678:	00178793          	addi	a5,a5,1
ffffffe00020067c:	fcf43823          	sd	a5,-48(s0)
ffffffe000200680:	fd043783          	ld	a5,-48(s0)
ffffffe000200684:	00c79713          	slli	a4,a5,0xc
ffffffe000200688:	00100793          	li	a5,1
ffffffe00020068c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200690:	00f70733          	add	a4,a4,a5
ffffffe000200694:	00005797          	auipc	a5,0x5
ffffffe000200698:	97478793          	addi	a5,a5,-1676 # ffffffe000205008 <free_page_start>
ffffffe00020069c:	0007b783          	ld	a5,0(a5)
ffffffe0002006a0:	00078693          	mv	a3,a5
ffffffe0002006a4:	04100793          	li	a5,65
ffffffe0002006a8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002006ac:	00f687b3          	add	a5,a3,a5
ffffffe0002006b0:	faf76ee3          	bltu	a4,a5,ffffffe00020066c <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe0002006b4:	00004517          	auipc	a0,0x4
ffffffe0002006b8:	94c50513          	addi	a0,a0,-1716 # ffffffe000204000 <_srodata>
ffffffe0002006bc:	394030ef          	jal	ffffffe000203a50 <printk>
    return;
ffffffe0002006c0:	00000013          	nop
}
ffffffe0002006c4:	02813083          	ld	ra,40(sp)
ffffffe0002006c8:	02013403          	ld	s0,32(sp)
ffffffe0002006cc:	03010113          	addi	sp,sp,48
ffffffe0002006d0:	00008067          	ret

ffffffe0002006d4 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe0002006d4:	fc010113          	addi	sp,sp,-64
ffffffe0002006d8:	02813c23          	sd	s0,56(sp)
ffffffe0002006dc:	04010413          	addi	s0,sp,64
ffffffe0002006e0:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe0002006e4:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe0002006e8:	00100793          	li	a5,1
ffffffe0002006ec:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe0002006f0:	00009797          	auipc	a5,0x9
ffffffe0002006f4:	93078793          	addi	a5,a5,-1744 # ffffffe000209020 <buddy>
ffffffe0002006f8:	0007b703          	ld	a4,0(a5)
ffffffe0002006fc:	fc843783          	ld	a5,-56(s0)
ffffffe000200700:	00f707b3          	add	a5,a4,a5
ffffffe000200704:	fff78793          	addi	a5,a5,-1
ffffffe000200708:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe00020070c:	02c0006f          	j	ffffffe000200738 <buddy_free+0x64>
        node_size *= 2;
ffffffe000200710:	fe843783          	ld	a5,-24(s0)
ffffffe000200714:	00179793          	slli	a5,a5,0x1
ffffffe000200718:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe00020071c:	fe043783          	ld	a5,-32(s0)
ffffffe000200720:	02078e63          	beqz	a5,ffffffe00020075c <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200724:	fe043783          	ld	a5,-32(s0)
ffffffe000200728:	00178793          	addi	a5,a5,1
ffffffe00020072c:	0017d793          	srli	a5,a5,0x1
ffffffe000200730:	fff78793          	addi	a5,a5,-1
ffffffe000200734:	fef43023          	sd	a5,-32(s0)
ffffffe000200738:	00009797          	auipc	a5,0x9
ffffffe00020073c:	8e878793          	addi	a5,a5,-1816 # ffffffe000209020 <buddy>
ffffffe000200740:	0087b703          	ld	a4,8(a5)
ffffffe000200744:	fe043783          	ld	a5,-32(s0)
ffffffe000200748:	00379793          	slli	a5,a5,0x3
ffffffe00020074c:	00f707b3          	add	a5,a4,a5
ffffffe000200750:	0007b783          	ld	a5,0(a5)
ffffffe000200754:	fa079ee3          	bnez	a5,ffffffe000200710 <buddy_free+0x3c>
ffffffe000200758:	0080006f          	j	ffffffe000200760 <buddy_free+0x8c>
            break;
ffffffe00020075c:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe000200760:	00009797          	auipc	a5,0x9
ffffffe000200764:	8c078793          	addi	a5,a5,-1856 # ffffffe000209020 <buddy>
ffffffe000200768:	0087b703          	ld	a4,8(a5)
ffffffe00020076c:	fe043783          	ld	a5,-32(s0)
ffffffe000200770:	00379793          	slli	a5,a5,0x3
ffffffe000200774:	00f707b3          	add	a5,a4,a5
ffffffe000200778:	fe843703          	ld	a4,-24(s0)
ffffffe00020077c:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200780:	0d00006f          	j	ffffffe000200850 <buddy_free+0x17c>
        index = PARENT(index);
ffffffe000200784:	fe043783          	ld	a5,-32(s0)
ffffffe000200788:	00178793          	addi	a5,a5,1
ffffffe00020078c:	0017d793          	srli	a5,a5,0x1
ffffffe000200790:	fff78793          	addi	a5,a5,-1
ffffffe000200794:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe000200798:	fe843783          	ld	a5,-24(s0)
ffffffe00020079c:	00179793          	slli	a5,a5,0x1
ffffffe0002007a0:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe0002007a4:	00009797          	auipc	a5,0x9
ffffffe0002007a8:	87c78793          	addi	a5,a5,-1924 # ffffffe000209020 <buddy>
ffffffe0002007ac:	0087b703          	ld	a4,8(a5)
ffffffe0002007b0:	fe043783          	ld	a5,-32(s0)
ffffffe0002007b4:	00479793          	slli	a5,a5,0x4
ffffffe0002007b8:	00878793          	addi	a5,a5,8
ffffffe0002007bc:	00f707b3          	add	a5,a4,a5
ffffffe0002007c0:	0007b783          	ld	a5,0(a5)
ffffffe0002007c4:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe0002007c8:	00009797          	auipc	a5,0x9
ffffffe0002007cc:	85878793          	addi	a5,a5,-1960 # ffffffe000209020 <buddy>
ffffffe0002007d0:	0087b703          	ld	a4,8(a5)
ffffffe0002007d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002007d8:	00178793          	addi	a5,a5,1
ffffffe0002007dc:	00479793          	slli	a5,a5,0x4
ffffffe0002007e0:	00f707b3          	add	a5,a4,a5
ffffffe0002007e4:	0007b783          	ld	a5,0(a5)
ffffffe0002007e8:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe0002007ec:	fd843703          	ld	a4,-40(s0)
ffffffe0002007f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002007f4:	00f707b3          	add	a5,a4,a5
ffffffe0002007f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002007fc:	02f71463          	bne	a4,a5,ffffffe000200824 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe000200800:	00009797          	auipc	a5,0x9
ffffffe000200804:	82078793          	addi	a5,a5,-2016 # ffffffe000209020 <buddy>
ffffffe000200808:	0087b703          	ld	a4,8(a5)
ffffffe00020080c:	fe043783          	ld	a5,-32(s0)
ffffffe000200810:	00379793          	slli	a5,a5,0x3
ffffffe000200814:	00f707b3          	add	a5,a4,a5
ffffffe000200818:	fe843703          	ld	a4,-24(s0)
ffffffe00020081c:	00e7b023          	sd	a4,0(a5)
ffffffe000200820:	0300006f          	j	ffffffe000200850 <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200824:	00008797          	auipc	a5,0x8
ffffffe000200828:	7fc78793          	addi	a5,a5,2044 # ffffffe000209020 <buddy>
ffffffe00020082c:	0087b703          	ld	a4,8(a5)
ffffffe000200830:	fe043783          	ld	a5,-32(s0)
ffffffe000200834:	00379793          	slli	a5,a5,0x3
ffffffe000200838:	00f706b3          	add	a3,a4,a5
ffffffe00020083c:	fd843703          	ld	a4,-40(s0)
ffffffe000200840:	fd043783          	ld	a5,-48(s0)
ffffffe000200844:	00e7f463          	bgeu	a5,a4,ffffffe00020084c <buddy_free+0x178>
ffffffe000200848:	00070793          	mv	a5,a4
ffffffe00020084c:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200850:	fe043783          	ld	a5,-32(s0)
ffffffe000200854:	f20798e3          	bnez	a5,ffffffe000200784 <buddy_free+0xb0>
    }
}
ffffffe000200858:	00000013          	nop
ffffffe00020085c:	00000013          	nop
ffffffe000200860:	03813403          	ld	s0,56(sp)
ffffffe000200864:	04010113          	addi	sp,sp,64
ffffffe000200868:	00008067          	ret

ffffffe00020086c <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe00020086c:	fc010113          	addi	sp,sp,-64
ffffffe000200870:	02113c23          	sd	ra,56(sp)
ffffffe000200874:	02813823          	sd	s0,48(sp)
ffffffe000200878:	04010413          	addi	s0,sp,64
ffffffe00020087c:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe000200880:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200884:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe000200888:	fc843783          	ld	a5,-56(s0)
ffffffe00020088c:	00079863          	bnez	a5,ffffffe00020089c <buddy_alloc+0x30>
        nrpages = 1;
ffffffe000200890:	00100793          	li	a5,1
ffffffe000200894:	fcf43423          	sd	a5,-56(s0)
ffffffe000200898:	0240006f          	j	ffffffe0002008bc <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe00020089c:	fc843783          	ld	a5,-56(s0)
ffffffe0002008a0:	fff78713          	addi	a4,a5,-1
ffffffe0002008a4:	fc843783          	ld	a5,-56(s0)
ffffffe0002008a8:	00f777b3          	and	a5,a4,a5
ffffffe0002008ac:	00078863          	beqz	a5,ffffffe0002008bc <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe0002008b0:	fc843503          	ld	a0,-56(s0)
ffffffe0002008b4:	bc9ff0ef          	jal	ffffffe00020047c <fixsize>
ffffffe0002008b8:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe0002008bc:	00008797          	auipc	a5,0x8
ffffffe0002008c0:	76478793          	addi	a5,a5,1892 # ffffffe000209020 <buddy>
ffffffe0002008c4:	0087b703          	ld	a4,8(a5)
ffffffe0002008c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002008cc:	00379793          	slli	a5,a5,0x3
ffffffe0002008d0:	00f707b3          	add	a5,a4,a5
ffffffe0002008d4:	0007b783          	ld	a5,0(a5)
ffffffe0002008d8:	fc843703          	ld	a4,-56(s0)
ffffffe0002008dc:	00e7f663          	bgeu	a5,a4,ffffffe0002008e8 <buddy_alloc+0x7c>
        return 0;
ffffffe0002008e0:	00000793          	li	a5,0
ffffffe0002008e4:	1480006f          	j	ffffffe000200a2c <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002008e8:	00008797          	auipc	a5,0x8
ffffffe0002008ec:	73878793          	addi	a5,a5,1848 # ffffffe000209020 <buddy>
ffffffe0002008f0:	0007b783          	ld	a5,0(a5)
ffffffe0002008f4:	fef43023          	sd	a5,-32(s0)
ffffffe0002008f8:	05c0006f          	j	ffffffe000200954 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe0002008fc:	00008797          	auipc	a5,0x8
ffffffe000200900:	72478793          	addi	a5,a5,1828 # ffffffe000209020 <buddy>
ffffffe000200904:	0087b703          	ld	a4,8(a5)
ffffffe000200908:	fe843783          	ld	a5,-24(s0)
ffffffe00020090c:	00479793          	slli	a5,a5,0x4
ffffffe000200910:	00878793          	addi	a5,a5,8
ffffffe000200914:	00f707b3          	add	a5,a4,a5
ffffffe000200918:	0007b783          	ld	a5,0(a5)
ffffffe00020091c:	fc843703          	ld	a4,-56(s0)
ffffffe000200920:	00e7ec63          	bltu	a5,a4,ffffffe000200938 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200924:	fe843783          	ld	a5,-24(s0)
ffffffe000200928:	00179793          	slli	a5,a5,0x1
ffffffe00020092c:	00178793          	addi	a5,a5,1
ffffffe000200930:	fef43423          	sd	a5,-24(s0)
ffffffe000200934:	0140006f          	j	ffffffe000200948 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe000200938:	fe843783          	ld	a5,-24(s0)
ffffffe00020093c:	00178793          	addi	a5,a5,1
ffffffe000200940:	00179793          	slli	a5,a5,0x1
ffffffe000200944:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200948:	fe043783          	ld	a5,-32(s0)
ffffffe00020094c:	0017d793          	srli	a5,a5,0x1
ffffffe000200950:	fef43023          	sd	a5,-32(s0)
ffffffe000200954:	fe043703          	ld	a4,-32(s0)
ffffffe000200958:	fc843783          	ld	a5,-56(s0)
ffffffe00020095c:	faf710e3          	bne	a4,a5,ffffffe0002008fc <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe000200960:	00008797          	auipc	a5,0x8
ffffffe000200964:	6c078793          	addi	a5,a5,1728 # ffffffe000209020 <buddy>
ffffffe000200968:	0087b703          	ld	a4,8(a5)
ffffffe00020096c:	fe843783          	ld	a5,-24(s0)
ffffffe000200970:	00379793          	slli	a5,a5,0x3
ffffffe000200974:	00f707b3          	add	a5,a4,a5
ffffffe000200978:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe00020097c:	fe843783          	ld	a5,-24(s0)
ffffffe000200980:	00178713          	addi	a4,a5,1
ffffffe000200984:	fe043783          	ld	a5,-32(s0)
ffffffe000200988:	02f70733          	mul	a4,a4,a5
ffffffe00020098c:	00008797          	auipc	a5,0x8
ffffffe000200990:	69478793          	addi	a5,a5,1684 # ffffffe000209020 <buddy>
ffffffe000200994:	0007b783          	ld	a5,0(a5)
ffffffe000200998:	40f707b3          	sub	a5,a4,a5
ffffffe00020099c:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe0002009a0:	0800006f          	j	ffffffe000200a20 <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe0002009a4:	fe843783          	ld	a5,-24(s0)
ffffffe0002009a8:	00178793          	addi	a5,a5,1
ffffffe0002009ac:	0017d793          	srli	a5,a5,0x1
ffffffe0002009b0:	fff78793          	addi	a5,a5,-1
ffffffe0002009b4:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002009b8:	00008797          	auipc	a5,0x8
ffffffe0002009bc:	66878793          	addi	a5,a5,1640 # ffffffe000209020 <buddy>
ffffffe0002009c0:	0087b703          	ld	a4,8(a5)
ffffffe0002009c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002009c8:	00178793          	addi	a5,a5,1
ffffffe0002009cc:	00479793          	slli	a5,a5,0x4
ffffffe0002009d0:	00f707b3          	add	a5,a4,a5
ffffffe0002009d4:	0007b603          	ld	a2,0(a5)
ffffffe0002009d8:	00008797          	auipc	a5,0x8
ffffffe0002009dc:	64878793          	addi	a5,a5,1608 # ffffffe000209020 <buddy>
ffffffe0002009e0:	0087b703          	ld	a4,8(a5)
ffffffe0002009e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002009e8:	00479793          	slli	a5,a5,0x4
ffffffe0002009ec:	00878793          	addi	a5,a5,8
ffffffe0002009f0:	00f707b3          	add	a5,a4,a5
ffffffe0002009f4:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe0002009f8:	00008797          	auipc	a5,0x8
ffffffe0002009fc:	62878793          	addi	a5,a5,1576 # ffffffe000209020 <buddy>
ffffffe000200a00:	0087b683          	ld	a3,8(a5)
ffffffe000200a04:	fe843783          	ld	a5,-24(s0)
ffffffe000200a08:	00379793          	slli	a5,a5,0x3
ffffffe000200a0c:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200a10:	00060793          	mv	a5,a2
ffffffe000200a14:	00e7f463          	bgeu	a5,a4,ffffffe000200a1c <buddy_alloc+0x1b0>
ffffffe000200a18:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200a1c:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200a20:	fe843783          	ld	a5,-24(s0)
ffffffe000200a24:	f80790e3          	bnez	a5,ffffffe0002009a4 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe000200a28:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200a2c:	00078513          	mv	a0,a5
ffffffe000200a30:	03813083          	ld	ra,56(sp)
ffffffe000200a34:	03013403          	ld	s0,48(sp)
ffffffe000200a38:	04010113          	addi	sp,sp,64
ffffffe000200a3c:	00008067          	ret

ffffffe000200a40 <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe000200a40:	fd010113          	addi	sp,sp,-48
ffffffe000200a44:	02113423          	sd	ra,40(sp)
ffffffe000200a48:	02813023          	sd	s0,32(sp)
ffffffe000200a4c:	03010413          	addi	s0,sp,48
ffffffe000200a50:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200a54:	fd843503          	ld	a0,-40(s0)
ffffffe000200a58:	e15ff0ef          	jal	ffffffe00020086c <buddy_alloc>
ffffffe000200a5c:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200a60:	fe843783          	ld	a5,-24(s0)
ffffffe000200a64:	00079663          	bnez	a5,ffffffe000200a70 <alloc_pages+0x30>
        return 0;
ffffffe000200a68:	00000793          	li	a5,0
ffffffe000200a6c:	0180006f          	j	ffffffe000200a84 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200a70:	fe843783          	ld	a5,-24(s0)
ffffffe000200a74:	00c79713          	slli	a4,a5,0xc
ffffffe000200a78:	fff00793          	li	a5,-1
ffffffe000200a7c:	02579793          	slli	a5,a5,0x25
ffffffe000200a80:	00f707b3          	add	a5,a4,a5
}
ffffffe000200a84:	00078513          	mv	a0,a5
ffffffe000200a88:	02813083          	ld	ra,40(sp)
ffffffe000200a8c:	02013403          	ld	s0,32(sp)
ffffffe000200a90:	03010113          	addi	sp,sp,48
ffffffe000200a94:	00008067          	ret

ffffffe000200a98 <alloc_page>:

void *alloc_page() {
ffffffe000200a98:	ff010113          	addi	sp,sp,-16
ffffffe000200a9c:	00113423          	sd	ra,8(sp)
ffffffe000200aa0:	00813023          	sd	s0,0(sp)
ffffffe000200aa4:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200aa8:	00100513          	li	a0,1
ffffffe000200aac:	f95ff0ef          	jal	ffffffe000200a40 <alloc_pages>
ffffffe000200ab0:	00050793          	mv	a5,a0
}
ffffffe000200ab4:	00078513          	mv	a0,a5
ffffffe000200ab8:	00813083          	ld	ra,8(sp)
ffffffe000200abc:	00013403          	ld	s0,0(sp)
ffffffe000200ac0:	01010113          	addi	sp,sp,16
ffffffe000200ac4:	00008067          	ret

ffffffe000200ac8 <free_pages>:

void free_pages(void *va) {
ffffffe000200ac8:	fe010113          	addi	sp,sp,-32
ffffffe000200acc:	00113c23          	sd	ra,24(sp)
ffffffe000200ad0:	00813823          	sd	s0,16(sp)
ffffffe000200ad4:	02010413          	addi	s0,sp,32
ffffffe000200ad8:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe000200adc:	fe843703          	ld	a4,-24(s0)
ffffffe000200ae0:	00100793          	li	a5,1
ffffffe000200ae4:	02579793          	slli	a5,a5,0x25
ffffffe000200ae8:	00f707b3          	add	a5,a4,a5
ffffffe000200aec:	00c7d793          	srli	a5,a5,0xc
ffffffe000200af0:	00078513          	mv	a0,a5
ffffffe000200af4:	be1ff0ef          	jal	ffffffe0002006d4 <buddy_free>
}
ffffffe000200af8:	00000013          	nop
ffffffe000200afc:	01813083          	ld	ra,24(sp)
ffffffe000200b00:	01013403          	ld	s0,16(sp)
ffffffe000200b04:	02010113          	addi	sp,sp,32
ffffffe000200b08:	00008067          	ret

ffffffe000200b0c <kalloc>:

void *kalloc() {
ffffffe000200b0c:	ff010113          	addi	sp,sp,-16
ffffffe000200b10:	00113423          	sd	ra,8(sp)
ffffffe000200b14:	00813023          	sd	s0,0(sp)
ffffffe000200b18:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200b1c:	f7dff0ef          	jal	ffffffe000200a98 <alloc_page>
ffffffe000200b20:	00050793          	mv	a5,a0
}
ffffffe000200b24:	00078513          	mv	a0,a5
ffffffe000200b28:	00813083          	ld	ra,8(sp)
ffffffe000200b2c:	00013403          	ld	s0,0(sp)
ffffffe000200b30:	01010113          	addi	sp,sp,16
ffffffe000200b34:	00008067          	ret

ffffffe000200b38 <kfree>:

void kfree(void *addr) {
ffffffe000200b38:	fe010113          	addi	sp,sp,-32
ffffffe000200b3c:	00113c23          	sd	ra,24(sp)
ffffffe000200b40:	00813823          	sd	s0,16(sp)
ffffffe000200b44:	02010413          	addi	s0,sp,32
ffffffe000200b48:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200b4c:	fe843503          	ld	a0,-24(s0)
ffffffe000200b50:	f79ff0ef          	jal	ffffffe000200ac8 <free_pages>

    return;
ffffffe000200b54:	00000013          	nop
}
ffffffe000200b58:	01813083          	ld	ra,24(sp)
ffffffe000200b5c:	01013403          	ld	s0,16(sp)
ffffffe000200b60:	02010113          	addi	sp,sp,32
ffffffe000200b64:	00008067          	ret

ffffffe000200b68 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200b68:	fd010113          	addi	sp,sp,-48
ffffffe000200b6c:	02113423          	sd	ra,40(sp)
ffffffe000200b70:	02813023          	sd	s0,32(sp)
ffffffe000200b74:	03010413          	addi	s0,sp,48
ffffffe000200b78:	fca43c23          	sd	a0,-40(s0)
ffffffe000200b7c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200b80:	fd843703          	ld	a4,-40(s0)
ffffffe000200b84:	000017b7          	lui	a5,0x1
ffffffe000200b88:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200b8c:	00f70733          	add	a4,a4,a5
ffffffe000200b90:	fffff7b7          	lui	a5,0xfffff
ffffffe000200b94:	00f777b3          	and	a5,a4,a5
ffffffe000200b98:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200b9c:	01c0006f          	j	ffffffe000200bb8 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200ba0:	fe843503          	ld	a0,-24(s0)
ffffffe000200ba4:	f95ff0ef          	jal	ffffffe000200b38 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200ba8:	fe843703          	ld	a4,-24(s0)
ffffffe000200bac:	000017b7          	lui	a5,0x1
ffffffe000200bb0:	00f707b3          	add	a5,a4,a5
ffffffe000200bb4:	fef43423          	sd	a5,-24(s0)
ffffffe000200bb8:	fe843703          	ld	a4,-24(s0)
ffffffe000200bbc:	000017b7          	lui	a5,0x1
ffffffe000200bc0:	00f70733          	add	a4,a4,a5
ffffffe000200bc4:	fd043783          	ld	a5,-48(s0)
ffffffe000200bc8:	fce7fce3          	bgeu	a5,a4,ffffffe000200ba0 <kfreerange+0x38>
    }
}
ffffffe000200bcc:	00000013          	nop
ffffffe000200bd0:	00000013          	nop
ffffffe000200bd4:	02813083          	ld	ra,40(sp)
ffffffe000200bd8:	02013403          	ld	s0,32(sp)
ffffffe000200bdc:	03010113          	addi	sp,sp,48
ffffffe000200be0:	00008067          	ret

ffffffe000200be4 <mm_init>:

void mm_init(void) {
ffffffe000200be4:	ff010113          	addi	sp,sp,-16
ffffffe000200be8:	00113423          	sd	ra,8(sp)
ffffffe000200bec:	00813023          	sd	s0,0(sp)
ffffffe000200bf0:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200bf4:	935ff0ef          	jal	ffffffe000200528 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200bf8:	00003517          	auipc	a0,0x3
ffffffe000200bfc:	42050513          	addi	a0,a0,1056 # ffffffe000204018 <_srodata+0x18>
ffffffe000200c00:	651020ef          	jal	ffffffe000203a50 <printk>
}
ffffffe000200c04:	00000013          	nop
ffffffe000200c08:	00813083          	ld	ra,8(sp)
ffffffe000200c0c:	00013403          	ld	s0,0(sp)
ffffffe000200c10:	01010113          	addi	sp,sp,16
ffffffe000200c14:	00008067          	ret

ffffffe000200c18 <find_vma>:
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr)
{
ffffffe000200c18:	fd010113          	addi	sp,sp,-48
ffffffe000200c1c:	02813423          	sd	s0,40(sp)
ffffffe000200c20:	03010413          	addi	s0,sp,48
ffffffe000200c24:	fca43c23          	sd	a0,-40(s0)
ffffffe000200c28:	fcb43823          	sd	a1,-48(s0)
    // 获取VMA链表头
    struct vm_area_struct *vma = mm->mmap;
ffffffe000200c2c:	fd843783          	ld	a5,-40(s0)
ffffffe000200c30:	0007b783          	ld	a5,0(a5) # 1000 <PGSIZE>
ffffffe000200c34:	fef43423          	sd	a5,-24(s0)

    // 遍历VMA链表
    while (vma) 
ffffffe000200c38:	0380006f          	j	ffffffe000200c70 <find_vma+0x58>
    {
        // 检查addr是否在当前VMA的范围内
        if (addr >= vma->vm_start && addr < vma->vm_end) 
ffffffe000200c3c:	fe843783          	ld	a5,-24(s0)
ffffffe000200c40:	0087b783          	ld	a5,8(a5)
ffffffe000200c44:	fd043703          	ld	a4,-48(s0)
ffffffe000200c48:	00f76e63          	bltu	a4,a5,ffffffe000200c64 <find_vma+0x4c>
ffffffe000200c4c:	fe843783          	ld	a5,-24(s0)
ffffffe000200c50:	0107b783          	ld	a5,16(a5)
ffffffe000200c54:	fd043703          	ld	a4,-48(s0)
ffffffe000200c58:	00f77663          	bgeu	a4,a5,ffffffe000200c64 <find_vma+0x4c>
        {
            return vma; // 找到目标VMA，返回指针
ffffffe000200c5c:	fe843783          	ld	a5,-24(s0)
ffffffe000200c60:	01c0006f          	j	ffffffe000200c7c <find_vma+0x64>
        }
        vma = vma->vm_next; // 移动到下一个VMA
ffffffe000200c64:	fe843783          	ld	a5,-24(s0)
ffffffe000200c68:	0187b783          	ld	a5,24(a5)
ffffffe000200c6c:	fef43423          	sd	a5,-24(s0)
    while (vma) 
ffffffe000200c70:	fe843783          	ld	a5,-24(s0)
ffffffe000200c74:	fc0794e3          	bnez	a5,ffffffe000200c3c <find_vma+0x24>
    }

    // 没有找到匹配的VMA
    return NULL;
ffffffe000200c78:	00000793          	li	a5,0
}
ffffffe000200c7c:	00078513          	mv	a0,a5
ffffffe000200c80:	02813403          	ld	s0,40(sp)
ffffffe000200c84:	03010113          	addi	sp,sp,48
ffffffe000200c88:	00008067          	ret

ffffffe000200c8c <do_mmap>:
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags)
{
ffffffe000200c8c:	fa010113          	addi	sp,sp,-96
ffffffe000200c90:	04113c23          	sd	ra,88(sp)
ffffffe000200c94:	04813823          	sd	s0,80(sp)
ffffffe000200c98:	06010413          	addi	s0,sp,96
ffffffe000200c9c:	fca43423          	sd	a0,-56(s0)
ffffffe000200ca0:	fcb43023          	sd	a1,-64(s0)
ffffffe000200ca4:	fac43c23          	sd	a2,-72(s0)
ffffffe000200ca8:	fad43823          	sd	a3,-80(s0)
ffffffe000200cac:	fae43423          	sd	a4,-88(s0)
ffffffe000200cb0:	faf43023          	sd	a5,-96(s0)
    // 1. 分配一个vm_area_struct
    struct vm_area_struct *new_vma=(struct vm_area_struct *)kalloc(sizeof(struct vm_area_struct));
ffffffe000200cb4:	04000513          	li	a0,64
ffffffe000200cb8:	e55ff0ef          	jal	ffffffe000200b0c <kalloc>
ffffffe000200cbc:	fca43c23          	sd	a0,-40(s0)
    if(!new_vma)
ffffffe000200cc0:	fd843783          	ld	a5,-40(s0)
ffffffe000200cc4:	00079c63          	bnez	a5,ffffffe000200cdc <do_mmap+0x50>
    {
        printk("do_mmap: kalloc failed\n");
ffffffe000200cc8:	00003517          	auipc	a0,0x3
ffffffe000200ccc:	36850513          	addi	a0,a0,872 # ffffffe000204030 <_srodata+0x30>
ffffffe000200cd0:	581020ef          	jal	ffffffe000203a50 <printk>
        return 0;
ffffffe000200cd4:	00000793          	li	a5,0
ffffffe000200cd8:	0fc0006f          	j	ffffffe000200dd4 <do_mmap+0x148>
    }

    // 2. 初始化new_vma
    new_vma->vm_mm = mm;
ffffffe000200cdc:	fd843783          	ld	a5,-40(s0)
ffffffe000200ce0:	fc843703          	ld	a4,-56(s0)
ffffffe000200ce4:	00e7b023          	sd	a4,0(a5)
    new_vma->vm_start = addr;
ffffffe000200ce8:	fd843783          	ld	a5,-40(s0)
ffffffe000200cec:	fc043703          	ld	a4,-64(s0)
ffffffe000200cf0:	00e7b423          	sd	a4,8(a5)
    new_vma->vm_end = addr + len;
ffffffe000200cf4:	fc043703          	ld	a4,-64(s0)
ffffffe000200cf8:	fb843783          	ld	a5,-72(s0)
ffffffe000200cfc:	00f70733          	add	a4,a4,a5
ffffffe000200d00:	fd843783          	ld	a5,-40(s0)
ffffffe000200d04:	00e7b823          	sd	a4,16(a5)
    new_vma->vm_next = NULL;
ffffffe000200d08:	fd843783          	ld	a5,-40(s0)
ffffffe000200d0c:	0007bc23          	sd	zero,24(a5)
    new_vma->vm_prev = NULL;
ffffffe000200d10:	fd843783          	ld	a5,-40(s0)
ffffffe000200d14:	0207b023          	sd	zero,32(a5)
    new_vma->vm_flags = flags;
ffffffe000200d18:	fd843783          	ld	a5,-40(s0)
ffffffe000200d1c:	fa043703          	ld	a4,-96(s0)
ffffffe000200d20:	02e7b423          	sd	a4,40(a5)
    new_vma->vm_pgoff = vm_pgoff;
ffffffe000200d24:	fd843783          	ld	a5,-40(s0)
ffffffe000200d28:	fb043703          	ld	a4,-80(s0)
ffffffe000200d2c:	02e7b823          	sd	a4,48(a5)
    new_vma->vm_filesz = vm_filesz;
ffffffe000200d30:	fd843783          	ld	a5,-40(s0)
ffffffe000200d34:	fa843703          	ld	a4,-88(s0)
ffffffe000200d38:	02e7bc23          	sd	a4,56(a5)

    // 3. 将new_vma插入到mm->mmap链表中
    struct vm_area_struct *curr = mm->mmap;
ffffffe000200d3c:	fc843783          	ld	a5,-56(s0)
ffffffe000200d40:	0007b783          	ld	a5,0(a5)
ffffffe000200d44:	fef43423          	sd	a5,-24(s0)
    struct vm_area_struct *prev = NULL;
ffffffe000200d48:	fe043023          	sd	zero,-32(s0)

    // 找到插入点，链表按vm_start排序
    while(curr && curr->vm_start < addr) 
ffffffe000200d4c:	0180006f          	j	ffffffe000200d64 <do_mmap+0xd8>
    {
        prev = curr;
ffffffe000200d50:	fe843783          	ld	a5,-24(s0)
ffffffe000200d54:	fef43023          	sd	a5,-32(s0)
        curr = curr->vm_next;
ffffffe000200d58:	fe843783          	ld	a5,-24(s0)
ffffffe000200d5c:	0187b783          	ld	a5,24(a5)
ffffffe000200d60:	fef43423          	sd	a5,-24(s0)
    while(curr && curr->vm_start < addr) 
ffffffe000200d64:	fe843783          	ld	a5,-24(s0)
ffffffe000200d68:	00078a63          	beqz	a5,ffffffe000200d7c <do_mmap+0xf0>
ffffffe000200d6c:	fe843783          	ld	a5,-24(s0)
ffffffe000200d70:	0087b783          	ld	a5,8(a5)
ffffffe000200d74:	fc043703          	ld	a4,-64(s0)
ffffffe000200d78:	fce7ece3          	bltu	a5,a4,ffffffe000200d50 <do_mmap+0xc4>
    }

    // 更新new_vma的next和prev
    new_vma->vm_next = curr;
ffffffe000200d7c:	fd843783          	ld	a5,-40(s0)
ffffffe000200d80:	fe843703          	ld	a4,-24(s0)
ffffffe000200d84:	00e7bc23          	sd	a4,24(a5)
    new_vma->vm_prev = prev;
ffffffe000200d88:	fd843783          	ld	a5,-40(s0)
ffffffe000200d8c:	fe043703          	ld	a4,-32(s0)
ffffffe000200d90:	02e7b023          	sd	a4,32(a5)
    if(prev) 
ffffffe000200d94:	fe043783          	ld	a5,-32(s0)
ffffffe000200d98:	00078a63          	beqz	a5,ffffffe000200dac <do_mmap+0x120>
    {
        prev->vm_next = new_vma;
ffffffe000200d9c:	fe043783          	ld	a5,-32(s0)
ffffffe000200da0:	fd843703          	ld	a4,-40(s0)
ffffffe000200da4:	00e7bc23          	sd	a4,24(a5)
ffffffe000200da8:	0100006f          	j	ffffffe000200db8 <do_mmap+0x12c>
    }else
    {
        mm->mmap = new_vma; // new_vma是链表的第一个节点
ffffffe000200dac:	fc843783          	ld	a5,-56(s0)
ffffffe000200db0:	fd843703          	ld	a4,-40(s0)
ffffffe000200db4:	00e7b023          	sd	a4,0(a5)
    }
    if(curr)
ffffffe000200db8:	fe843783          	ld	a5,-24(s0)
ffffffe000200dbc:	00078863          	beqz	a5,ffffffe000200dcc <do_mmap+0x140>
    {
        curr->vm_prev = new_vma;
ffffffe000200dc0:	fe843783          	ld	a5,-24(s0)
ffffffe000200dc4:	fd843703          	ld	a4,-40(s0)
ffffffe000200dc8:	02e7b023          	sd	a4,32(a5)
    }

    // 4. 返回新分配区域的起始地址
    return new_vma->vm_start;
ffffffe000200dcc:	fd843783          	ld	a5,-40(s0)
ffffffe000200dd0:	0087b783          	ld	a5,8(a5)
}
ffffffe000200dd4:	00078513          	mv	a0,a5
ffffffe000200dd8:	05813083          	ld	ra,88(sp)
ffffffe000200ddc:	05013403          	ld	s0,80(sp)
ffffffe000200de0:	06010113          	addi	sp,sp,96
ffffffe000200de4:	00008067          	ret

ffffffe000200de8 <memcpy>:

extern char _sramdisk[];
extern char _sbss[];
extern uint64_t swapper_pg_dir[];

void *memcpy(void *dest, void *src, size_t n) {
ffffffe000200de8:	fc010113          	addi	sp,sp,-64
ffffffe000200dec:	02813c23          	sd	s0,56(sp)
ffffffe000200df0:	04010413          	addi	s0,sp,64
ffffffe000200df4:	fca43c23          	sd	a0,-40(s0)
ffffffe000200df8:	fcb43823          	sd	a1,-48(s0)
ffffffe000200dfc:	fcc43423          	sd	a2,-56(s0)
    char *d = dest;
ffffffe000200e00:	fd843783          	ld	a5,-40(s0)
ffffffe000200e04:	fef43423          	sd	a5,-24(s0)
    char *s = src;
ffffffe000200e08:	fd043783          	ld	a5,-48(s0)
ffffffe000200e0c:	fef43023          	sd	a5,-32(s0)
    while (n--) {
ffffffe000200e10:	0240006f          	j	ffffffe000200e34 <memcpy+0x4c>
        *(d++) = *(s++);
ffffffe000200e14:	fe043703          	ld	a4,-32(s0)
ffffffe000200e18:	00170793          	addi	a5,a4,1
ffffffe000200e1c:	fef43023          	sd	a5,-32(s0)
ffffffe000200e20:	fe843783          	ld	a5,-24(s0)
ffffffe000200e24:	00178693          	addi	a3,a5,1
ffffffe000200e28:	fed43423          	sd	a3,-24(s0)
ffffffe000200e2c:	00074703          	lbu	a4,0(a4)
ffffffe000200e30:	00e78023          	sb	a4,0(a5)
    while (n--) {
ffffffe000200e34:	fc843783          	ld	a5,-56(s0)
ffffffe000200e38:	fff78713          	addi	a4,a5,-1
ffffffe000200e3c:	fce43423          	sd	a4,-56(s0)
ffffffe000200e40:	fc079ae3          	bnez	a5,ffffffe000200e14 <memcpy+0x2c>
    }
    return dest;
ffffffe000200e44:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200e48:	00078513          	mv	a0,a5
ffffffe000200e4c:	03813403          	ld	s0,56(sp)
ffffffe000200e50:	04010113          	addi	sp,sp,64
ffffffe000200e54:	00008067          	ret

ffffffe000200e58 <load_bin_program>:

void load_bin_program(struct task_struct *task) {
ffffffe000200e58:	fc010113          	addi	sp,sp,-64
ffffffe000200e5c:	02113c23          	sd	ra,56(sp)
ffffffe000200e60:	02813823          	sd	s0,48(sp)
ffffffe000200e64:	04010413          	addi	s0,sp,64
ffffffe000200e68:	fca43423          	sd	a0,-56(s0)
    // 将 uapp 所在的页面映射到每个进程的页表中-------------------------------
    // copy first
    void *user_uapp = alloc_pages(((uint64_t)_sbss-(uint64_t)_sramdisk)/PGSIZE+1);
ffffffe000200e6c:	00007717          	auipc	a4,0x7
ffffffe000200e70:	19470713          	addi	a4,a4,404 # ffffffe000208000 <_sbss>
ffffffe000200e74:	00005797          	auipc	a5,0x5
ffffffe000200e78:	18c78793          	addi	a5,a5,396 # ffffffe000206000 <_sramdisk>
ffffffe000200e7c:	40f707b3          	sub	a5,a4,a5
ffffffe000200e80:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e84:	00178793          	addi	a5,a5,1
ffffffe000200e88:	00078513          	mv	a0,a5
ffffffe000200e8c:	bb5ff0ef          	jal	ffffffe000200a40 <alloc_pages>
ffffffe000200e90:	fea43423          	sd	a0,-24(s0)
    uint64_t uapp_size = (uint64_t)_sbss - (uint64_t)_sramdisk;
ffffffe000200e94:	00007717          	auipc	a4,0x7
ffffffe000200e98:	16c70713          	addi	a4,a4,364 # ffffffe000208000 <_sbss>
ffffffe000200e9c:	00005797          	auipc	a5,0x5
ffffffe000200ea0:	16478793          	addi	a5,a5,356 # ffffffe000206000 <_sramdisk>
ffffffe000200ea4:	40f707b3          	sub	a5,a4,a5
ffffffe000200ea8:	fef43023          	sd	a5,-32(s0)
    memcpy(user_uapp,_sramdisk,uapp_size);
ffffffe000200eac:	fe043603          	ld	a2,-32(s0)
ffffffe000200eb0:	00005597          	auipc	a1,0x5
ffffffe000200eb4:	15058593          	addi	a1,a1,336 # ffffffe000206000 <_sramdisk>
ffffffe000200eb8:	fe843503          	ld	a0,-24(s0)
ffffffe000200ebc:	f2dff0ef          	jal	ffffffe000200de8 <memcpy>

    uint64_t uapp_va = USER_START;
ffffffe000200ec0:	fc043c23          	sd	zero,-40(s0)
    uint64_t uapp_pa = (uint64_t)user_uapp - PA2VA_OFFSET;
ffffffe000200ec4:	fe843703          	ld	a4,-24(s0)
ffffffe000200ec8:	04100793          	li	a5,65
ffffffe000200ecc:	01f79793          	slli	a5,a5,0x1f
ffffffe000200ed0:	00f707b3          	add	a5,a4,a5
ffffffe000200ed4:	fcf43823          	sd	a5,-48(s0)
    create_mapping(task->pgd,uapp_va,uapp_pa,uapp_size,PERM_USER_UAPP);
ffffffe000200ed8:	fc843783          	ld	a5,-56(s0)
ffffffe000200edc:	0a87b783          	ld	a5,168(a5)
ffffffe000200ee0:	01f00713          	li	a4,31
ffffffe000200ee4:	fe043683          	ld	a3,-32(s0)
ffffffe000200ee8:	fd043603          	ld	a2,-48(s0)
ffffffe000200eec:	fd843583          	ld	a1,-40(s0)
ffffffe000200ef0:	00078513          	mv	a0,a5
ffffffe000200ef4:	29d010ef          	jal	ffffffe000202990 <create_mapping>
}
ffffffe000200ef8:	00000013          	nop
ffffffe000200efc:	03813083          	ld	ra,56(sp)
ffffffe000200f00:	03013403          	ld	s0,48(sp)
ffffffe000200f04:	04010113          	addi	sp,sp,64
ffffffe000200f08:	00008067          	ret

ffffffe000200f0c <load_elf_program>:

void load_elf_program(struct task_struct *task) {
ffffffe000200f0c:	f8010113          	addi	sp,sp,-128
ffffffe000200f10:	06113c23          	sd	ra,120(sp)
ffffffe000200f14:	06813823          	sd	s0,112(sp)
ffffffe000200f18:	08010413          	addi	s0,sp,128
ffffffe000200f1c:	f8a43423          	sd	a0,-120(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000200f20:	00005797          	auipc	a5,0x5
ffffffe000200f24:	0e078793          	addi	a5,a5,224 # ffffffe000206000 <_sramdisk>
ffffffe000200f28:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe000200f2c:	fd843783          	ld	a5,-40(s0)
ffffffe000200f30:	0207b703          	ld	a4,32(a5)
ffffffe000200f34:	00005797          	auipc	a5,0x5
ffffffe000200f38:	0cc78793          	addi	a5,a5,204 # ffffffe000206000 <_sramdisk>
ffffffe000200f3c:	00f707b3          	add	a5,a4,a5
ffffffe000200f40:	fcf43823          	sd	a5,-48(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200f44:	fe042623          	sw	zero,-20(s0)
ffffffe000200f48:	1bc0006f          	j	ffffffe000201104 <load_elf_program+0x1f8>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe000200f4c:	fec42703          	lw	a4,-20(s0)
ffffffe000200f50:	00070793          	mv	a5,a4
ffffffe000200f54:	00379793          	slli	a5,a5,0x3
ffffffe000200f58:	40e787b3          	sub	a5,a5,a4
ffffffe000200f5c:	00379793          	slli	a5,a5,0x3
ffffffe000200f60:	00078713          	mv	a4,a5
ffffffe000200f64:	fd043783          	ld	a5,-48(s0)
ffffffe000200f68:	00e787b3          	add	a5,a5,a4
ffffffe000200f6c:	fcf43423          	sd	a5,-56(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000200f70:	fc843783          	ld	a5,-56(s0)
ffffffe000200f74:	0007a783          	lw	a5,0(a5)
ffffffe000200f78:	00078713          	mv	a4,a5
ffffffe000200f7c:	00100793          	li	a5,1
ffffffe000200f80:	16f71c63          	bne	a4,a5,ffffffe0002010f8 <load_elf_program+0x1ec>
            // alloc space and copy content
            uint64_t start_vpg=PGROUNDDOWN(phdr->p_vaddr);
ffffffe000200f84:	fc843783          	ld	a5,-56(s0)
ffffffe000200f88:	0107b703          	ld	a4,16(a5)
ffffffe000200f8c:	fffff7b7          	lui	a5,0xfffff
ffffffe000200f90:	00f777b3          	and	a5,a4,a5
ffffffe000200f94:	fcf43023          	sd	a5,-64(s0)
            uint64_t end_vpg=PGROUNDUP(phdr->p_vaddr+phdr->p_memsz);
ffffffe000200f98:	fc843783          	ld	a5,-56(s0)
ffffffe000200f9c:	0107b703          	ld	a4,16(a5) # fffffffffffff010 <VM_END+0xfffff010>
ffffffe000200fa0:	fc843783          	ld	a5,-56(s0)
ffffffe000200fa4:	0287b783          	ld	a5,40(a5)
ffffffe000200fa8:	00f70733          	add	a4,a4,a5
ffffffe000200fac:	000017b7          	lui	a5,0x1
ffffffe000200fb0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200fb4:	00f70733          	add	a4,a4,a5
ffffffe000200fb8:	fffff7b7          	lui	a5,0xfffff
ffffffe000200fbc:	00f777b3          	and	a5,a4,a5
ffffffe000200fc0:	faf43c23          	sd	a5,-72(s0)
            uint64_t offset=phdr->p_paddr-start_vpg;
ffffffe000200fc4:	fc843783          	ld	a5,-56(s0)
ffffffe000200fc8:	0187b703          	ld	a4,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000200fcc:	fc043783          	ld	a5,-64(s0)
ffffffe000200fd0:	40f707b3          	sub	a5,a4,a5
ffffffe000200fd4:	faf43823          	sd	a5,-80(s0)
            uint64_t pg_num=(end_vpg-start_vpg)/PGSIZE;
ffffffe000200fd8:	fb843703          	ld	a4,-72(s0)
ffffffe000200fdc:	fc043783          	ld	a5,-64(s0)
ffffffe000200fe0:	40f707b3          	sub	a5,a4,a5
ffffffe000200fe4:	00c7d793          	srli	a5,a5,0xc
ffffffe000200fe8:	faf43423          	sd	a5,-88(s0)
            #define PTE_R  (1 << 1)  // Readable
            #define PTE_W  (1 << 2)  // Writable
            #define PTE_X  (1 << 3)  // Executable
            #define PTE_U  (1 << 4)  // User accessible
            // 权限转换
            uint64_t perm = PTE_V | PTE_U; // 基础权限：有效和用户态访问
ffffffe000200fec:	01100793          	li	a5,17
ffffffe000200ff0:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_R) perm |= PTE_R; // 可读
ffffffe000200ff4:	fc843783          	ld	a5,-56(s0)
ffffffe000200ff8:	0047a783          	lw	a5,4(a5)
ffffffe000200ffc:	0047f793          	andi	a5,a5,4
ffffffe000201000:	0007879b          	sext.w	a5,a5
ffffffe000201004:	00078863          	beqz	a5,ffffffe000201014 <load_elf_program+0x108>
ffffffe000201008:	fe043783          	ld	a5,-32(s0)
ffffffe00020100c:	0027e793          	ori	a5,a5,2
ffffffe000201010:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_W) perm |= PTE_W; // 可写
ffffffe000201014:	fc843783          	ld	a5,-56(s0)
ffffffe000201018:	0047a783          	lw	a5,4(a5)
ffffffe00020101c:	0027f793          	andi	a5,a5,2
ffffffe000201020:	0007879b          	sext.w	a5,a5
ffffffe000201024:	00078863          	beqz	a5,ffffffe000201034 <load_elf_program+0x128>
ffffffe000201028:	fe043783          	ld	a5,-32(s0)
ffffffe00020102c:	0047e793          	ori	a5,a5,4
ffffffe000201030:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_X) perm |= PTE_X; // 可执行
ffffffe000201034:	fc843783          	ld	a5,-56(s0)
ffffffe000201038:	0047a783          	lw	a5,4(a5)
ffffffe00020103c:	0017f793          	andi	a5,a5,1
ffffffe000201040:	0007879b          	sext.w	a5,a5
ffffffe000201044:	00078863          	beqz	a5,ffffffe000201054 <load_elf_program+0x148>
ffffffe000201048:	fe043783          	ld	a5,-32(s0)
ffffffe00020104c:	0087e793          	ori	a5,a5,8
ffffffe000201050:	fef43023          	sd	a5,-32(s0)

            // 为段分配物理页
            void *uapp_mem = alloc_pages(pg_num);
ffffffe000201054:	fa843503          	ld	a0,-88(s0)
ffffffe000201058:	9e9ff0ef          	jal	ffffffe000200a40 <alloc_pages>
ffffffe00020105c:	faa43023          	sd	a0,-96(s0)
            if (!uapp_mem) {
ffffffe000201060:	fa043783          	ld	a5,-96(s0)
ffffffe000201064:	00079e63          	bnez	a5,ffffffe000201080 <load_elf_program+0x174>
                printk("Failed to allocate memory for ELF segment %d\n", i);
ffffffe000201068:	fec42783          	lw	a5,-20(s0)
ffffffe00020106c:	00078593          	mv	a1,a5
ffffffe000201070:	00003517          	auipc	a0,0x3
ffffffe000201074:	fd850513          	addi	a0,a0,-40 # ffffffe000204048 <_srodata+0x48>
ffffffe000201078:	1d9020ef          	jal	ffffffe000203a50 <printk>
                return;
ffffffe00020107c:	0a00006f          	j	ffffffe00020111c <load_elf_program+0x210>
            }

            // 拷贝段内容
            memcpy((void *)(uapp_mem + offset), (void *)(_sramdisk + phdr->p_offset), phdr->p_filesz);
ffffffe000201080:	fa043703          	ld	a4,-96(s0)
ffffffe000201084:	fb043783          	ld	a5,-80(s0)
ffffffe000201088:	00f706b3          	add	a3,a4,a5
ffffffe00020108c:	fc843783          	ld	a5,-56(s0)
ffffffe000201090:	0087b703          	ld	a4,8(a5)
ffffffe000201094:	00005797          	auipc	a5,0x5
ffffffe000201098:	f6c78793          	addi	a5,a5,-148 # ffffffe000206000 <_sramdisk>
ffffffe00020109c:	00f70733          	add	a4,a4,a5
ffffffe0002010a0:	fc843783          	ld	a5,-56(s0)
ffffffe0002010a4:	0207b783          	ld	a5,32(a5)
ffffffe0002010a8:	00078613          	mv	a2,a5
ffffffe0002010ac:	00070593          	mv	a1,a4
ffffffe0002010b0:	00068513          	mv	a0,a3
ffffffe0002010b4:	d35ff0ef          	jal	ffffffe000200de8 <memcpy>

            // do mapping
            // 映射段到进程的页表
            uint64_t va = start_vpg;
ffffffe0002010b8:	fc043783          	ld	a5,-64(s0)
ffffffe0002010bc:	f8f43c23          	sd	a5,-104(s0)
            uint64_t pa = (uint64_t)uapp_mem - PA2VA_OFFSET;
ffffffe0002010c0:	fa043703          	ld	a4,-96(s0)
ffffffe0002010c4:	04100793          	li	a5,65
ffffffe0002010c8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002010cc:	00f707b3          	add	a5,a4,a5
ffffffe0002010d0:	f8f43823          	sd	a5,-112(s0)
            create_mapping((uint64_t *)task->pgd, va, pa, pg_num * PGSIZE, perm);
ffffffe0002010d4:	f8843783          	ld	a5,-120(s0)
ffffffe0002010d8:	0a87b503          	ld	a0,168(a5)
ffffffe0002010dc:	fa843783          	ld	a5,-88(s0)
ffffffe0002010e0:	00c79793          	slli	a5,a5,0xc
ffffffe0002010e4:	fe043703          	ld	a4,-32(s0)
ffffffe0002010e8:	00078693          	mv	a3,a5
ffffffe0002010ec:	f9043603          	ld	a2,-112(s0)
ffffffe0002010f0:	f9843583          	ld	a1,-104(s0)
ffffffe0002010f4:	09d010ef          	jal	ffffffe000202990 <create_mapping>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe0002010f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002010fc:	0017879b          	addiw	a5,a5,1
ffffffe000201100:	fef42623          	sw	a5,-20(s0)
ffffffe000201104:	fd843783          	ld	a5,-40(s0)
ffffffe000201108:	0387d783          	lhu	a5,56(a5)
ffffffe00020110c:	0007871b          	sext.w	a4,a5
ffffffe000201110:	fec42783          	lw	a5,-20(s0)
ffffffe000201114:	0007879b          	sext.w	a5,a5
ffffffe000201118:	e2e7cae3          	blt	a5,a4,ffffffe000200f4c <load_elf_program+0x40>

        }
    }
}
ffffffe00020111c:	07813083          	ld	ra,120(sp)
ffffffe000201120:	07013403          	ld	s0,112(sp)
ffffffe000201124:	08010113          	addi	sp,sp,128
ffffffe000201128:	00008067          	ret

ffffffe00020112c <load_program>:

void load_program(struct task_struct *task) {
ffffffe00020112c:	f9010113          	addi	sp,sp,-112
ffffffe000201130:	06113423          	sd	ra,104(sp)
ffffffe000201134:	06813023          	sd	s0,96(sp)
ffffffe000201138:	07010413          	addi	s0,sp,112
ffffffe00020113c:	f8a43c23          	sd	a0,-104(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000201140:	00005797          	auipc	a5,0x5
ffffffe000201144:	ec078793          	addi	a5,a5,-320 # ffffffe000206000 <_sramdisk>
ffffffe000201148:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe00020114c:	fd843783          	ld	a5,-40(s0)
ffffffe000201150:	0207b703          	ld	a4,32(a5)
ffffffe000201154:	00005797          	auipc	a5,0x5
ffffffe000201158:	eac78793          	addi	a5,a5,-340 # ffffffe000206000 <_sramdisk>
ffffffe00020115c:	00f707b3          	add	a5,a4,a5
ffffffe000201160:	fcf43823          	sd	a5,-48(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000201164:	fe042623          	sw	zero,-20(s0)
ffffffe000201168:	0fc0006f          	j	ffffffe000201264 <load_program+0x138>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe00020116c:	fec42703          	lw	a4,-20(s0)
ffffffe000201170:	00070793          	mv	a5,a4
ffffffe000201174:	00379793          	slli	a5,a5,0x3
ffffffe000201178:	40e787b3          	sub	a5,a5,a4
ffffffe00020117c:	00379793          	slli	a5,a5,0x3
ffffffe000201180:	00078713          	mv	a4,a5
ffffffe000201184:	fd043783          	ld	a5,-48(s0)
ffffffe000201188:	00e787b3          	add	a5,a5,a4
ffffffe00020118c:	fcf43423          	sd	a5,-56(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000201190:	fc843783          	ld	a5,-56(s0)
ffffffe000201194:	0007a783          	lw	a5,0(a5)
ffffffe000201198:	00078713          	mv	a4,a5
ffffffe00020119c:	00100793          	li	a5,1
ffffffe0002011a0:	0af71c63          	bne	a4,a5,ffffffe000201258 <load_program+0x12c>
            // 获取段信息
            uint64_t addr=phdr->p_vaddr;
ffffffe0002011a4:	fc843783          	ld	a5,-56(s0)
ffffffe0002011a8:	0107b783          	ld	a5,16(a5)
ffffffe0002011ac:	fcf43023          	sd	a5,-64(s0)
            uint64_t len=phdr->p_memsz;
ffffffe0002011b0:	fc843783          	ld	a5,-56(s0)
ffffffe0002011b4:	0287b783          	ld	a5,40(a5)
ffffffe0002011b8:	faf43c23          	sd	a5,-72(s0)
            uint64_t offset=phdr->p_offset; 
ffffffe0002011bc:	fc843783          	ld	a5,-56(s0)
ffffffe0002011c0:	0087b783          	ld	a5,8(a5)
ffffffe0002011c4:	faf43823          	sd	a5,-80(s0)
            uint64_t filesz=phdr->p_filesz;
ffffffe0002011c8:	fc843783          	ld	a5,-56(s0)
ffffffe0002011cc:	0207b783          	ld	a5,32(a5)
ffffffe0002011d0:	faf43423          	sd	a5,-88(s0)

            // 权限转换
            uint64_t vma_flags=0;
ffffffe0002011d4:	fe043023          	sd	zero,-32(s0)
            if (phdr->p_flags & PF_R) vma_flags |= VM_READ; // 可读
ffffffe0002011d8:	fc843783          	ld	a5,-56(s0)
ffffffe0002011dc:	0047a783          	lw	a5,4(a5)
ffffffe0002011e0:	0047f793          	andi	a5,a5,4
ffffffe0002011e4:	0007879b          	sext.w	a5,a5
ffffffe0002011e8:	00078863          	beqz	a5,ffffffe0002011f8 <load_program+0xcc>
ffffffe0002011ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002011f0:	0027e793          	ori	a5,a5,2
ffffffe0002011f4:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_W) vma_flags |= VM_WRITE; // 可写
ffffffe0002011f8:	fc843783          	ld	a5,-56(s0)
ffffffe0002011fc:	0047a783          	lw	a5,4(a5)
ffffffe000201200:	0027f793          	andi	a5,a5,2
ffffffe000201204:	0007879b          	sext.w	a5,a5
ffffffe000201208:	00078863          	beqz	a5,ffffffe000201218 <load_program+0xec>
ffffffe00020120c:	fe043783          	ld	a5,-32(s0)
ffffffe000201210:	0047e793          	ori	a5,a5,4
ffffffe000201214:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_X) vma_flags |= VM_EXEC; // 可执行
ffffffe000201218:	fc843783          	ld	a5,-56(s0)
ffffffe00020121c:	0047a783          	lw	a5,4(a5)
ffffffe000201220:	0017f793          	andi	a5,a5,1
ffffffe000201224:	0007879b          	sext.w	a5,a5
ffffffe000201228:	00078863          	beqz	a5,ffffffe000201238 <load_program+0x10c>
ffffffe00020122c:	fe043783          	ld	a5,-32(s0)
ffffffe000201230:	0087e793          	ori	a5,a5,8
ffffffe000201234:	fef43023          	sd	a5,-32(s0)

            do_mmap(&task->mm,addr,len,offset,filesz,vma_flags);
ffffffe000201238:	f9843783          	ld	a5,-104(s0)
ffffffe00020123c:	0b078513          	addi	a0,a5,176
ffffffe000201240:	fe043783          	ld	a5,-32(s0)
ffffffe000201244:	fa843703          	ld	a4,-88(s0)
ffffffe000201248:	fb043683          	ld	a3,-80(s0)
ffffffe00020124c:	fb843603          	ld	a2,-72(s0)
ffffffe000201250:	fc043583          	ld	a1,-64(s0)
ffffffe000201254:	a39ff0ef          	jal	ffffffe000200c8c <do_mmap>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000201258:	fec42783          	lw	a5,-20(s0)
ffffffe00020125c:	0017879b          	addiw	a5,a5,1
ffffffe000201260:	fef42623          	sw	a5,-20(s0)
ffffffe000201264:	fd843783          	ld	a5,-40(s0)
ffffffe000201268:	0387d783          	lhu	a5,56(a5)
ffffffe00020126c:	0007871b          	sext.w	a4,a5
ffffffe000201270:	fec42783          	lw	a5,-20(s0)
ffffffe000201274:	0007879b          	sext.w	a5,a5
ffffffe000201278:	eee7cae3          	blt	a5,a4,ffffffe00020116c <load_program+0x40>
        }
    }

    // user stack
    do_mmap(&task->mm,USER_END-PGSIZE,PGSIZE,0,0,VM_READ|VM_WRITE|VM_ANON);
ffffffe00020127c:	f9843783          	ld	a5,-104(s0)
ffffffe000201280:	0b078513          	addi	a0,a5,176
ffffffe000201284:	00700793          	li	a5,7
ffffffe000201288:	00000713          	li	a4,0
ffffffe00020128c:	00000693          	li	a3,0
ffffffe000201290:	00001637          	lui	a2,0x1
ffffffe000201294:	040005b7          	lui	a1,0x4000
ffffffe000201298:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe00020129c:	00c59593          	slli	a1,a1,0xc
ffffffe0002012a0:	9edff0ef          	jal	ffffffe000200c8c <do_mmap>
}
ffffffe0002012a4:	00000013          	nop
ffffffe0002012a8:	06813083          	ld	ra,104(sp)
ffffffe0002012ac:	06013403          	ld	s0,96(sp)
ffffffe0002012b0:	07010113          	addi	sp,sp,112
ffffffe0002012b4:	00008067          	ret

ffffffe0002012b8 <task_init>:

void task_init() {
ffffffe0002012b8:	fc010113          	addi	sp,sp,-64
ffffffe0002012bc:	02113c23          	sd	ra,56(sp)
ffffffe0002012c0:	02813823          	sd	s0,48(sp)
ffffffe0002012c4:	02913423          	sd	s1,40(sp)
ffffffe0002012c8:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe0002012cc:	7e800513          	li	a0,2024
ffffffe0002012d0:	001020ef          	jal	ffffffe000203ad0 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个4Kib物理页
    idle=(struct task_struct *)kalloc();
ffffffe0002012d4:	839ff0ef          	jal	ffffffe000200b0c <kalloc>
ffffffe0002012d8:	00050713          	mv	a4,a0
ffffffe0002012dc:	00008797          	auipc	a5,0x8
ffffffe0002012e0:	d2c78793          	addi	a5,a5,-724 # ffffffe000209008 <idle>
ffffffe0002012e4:	00e7b023          	sd	a4,0(a5)
    if (!idle) {
ffffffe0002012e8:	00008797          	auipc	a5,0x8
ffffffe0002012ec:	d2078793          	addi	a5,a5,-736 # ffffffe000209008 <idle>
ffffffe0002012f0:	0007b783          	ld	a5,0(a5)
ffffffe0002012f4:	00079a63          	bnez	a5,ffffffe000201308 <task_init+0x50>
        // 如果内存分配失败，则退出
        printk("Failed to allocate memory for idle task\n");
ffffffe0002012f8:	00003517          	auipc	a0,0x3
ffffffe0002012fc:	d8050513          	addi	a0,a0,-640 # ffffffe000204078 <_srodata+0x78>
ffffffe000201300:	750020ef          	jal	ffffffe000203a50 <printk>
        return;
ffffffe000201304:	4900006f          	j	ffffffe000201794 <task_init+0x4dc>
    }
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state=TASK_RUNNING;
ffffffe000201308:	00008797          	auipc	a5,0x8
ffffffe00020130c:	d0078793          	addi	a5,a5,-768 # ffffffe000209008 <idle>
ffffffe000201310:	0007b783          	ld	a5,0(a5)
ffffffe000201314:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter=0;
ffffffe000201318:	00008797          	auipc	a5,0x8
ffffffe00020131c:	cf078793          	addi	a5,a5,-784 # ffffffe000209008 <idle>
ffffffe000201320:	0007b783          	ld	a5,0(a5)
ffffffe000201324:	0007b423          	sd	zero,8(a5)
    idle->priority=0;
ffffffe000201328:	00008797          	auipc	a5,0x8
ffffffe00020132c:	ce078793          	addi	a5,a5,-800 # ffffffe000209008 <idle>
ffffffe000201330:	0007b783          	ld	a5,0(a5)
ffffffe000201334:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid=0;
ffffffe000201338:	00008797          	auipc	a5,0x8
ffffffe00020133c:	cd078793          	addi	a5,a5,-816 # ffffffe000209008 <idle>
ffffffe000201340:	0007b783          	ld	a5,0(a5)
ffffffe000201344:	0007bc23          	sd	zero,24(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current=idle;
ffffffe000201348:	00008797          	auipc	a5,0x8
ffffffe00020134c:	cc078793          	addi	a5,a5,-832 # ffffffe000209008 <idle>
ffffffe000201350:	0007b703          	ld	a4,0(a5)
ffffffe000201354:	00008797          	auipc	a5,0x8
ffffffe000201358:	cbc78793          	addi	a5,a5,-836 # ffffffe000209010 <current>
ffffffe00020135c:	00e7b023          	sd	a4,0(a5)
    task[0]=idle;
ffffffe000201360:	00008797          	auipc	a5,0x8
ffffffe000201364:	ca878793          	addi	a5,a5,-856 # ffffffe000209008 <idle>
ffffffe000201368:	0007b703          	ld	a4,0(a5)
ffffffe00020136c:	00008797          	auipc	a5,0x8
ffffffe000201370:	cc478793          	addi	a5,a5,-828 # ffffffe000209030 <task>
ffffffe000201374:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    for(int i=1;i<NR_TASKS;i++)
ffffffe000201378:	00100793          	li	a5,1
ffffffe00020137c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201380:	3f80006f          	j	ffffffe000201778 <task_init+0x4c0>
    {
        task[i]=(struct task_struct *)kalloc();
ffffffe000201384:	f88ff0ef          	jal	ffffffe000200b0c <kalloc>
ffffffe000201388:	00050693          	mv	a3,a0
ffffffe00020138c:	00008717          	auipc	a4,0x8
ffffffe000201390:	ca470713          	addi	a4,a4,-860 # ffffffe000209030 <task>
ffffffe000201394:	fdc42783          	lw	a5,-36(s0)
ffffffe000201398:	00379793          	slli	a5,a5,0x3
ffffffe00020139c:	00f707b3          	add	a5,a4,a5
ffffffe0002013a0:	00d7b023          	sd	a3,0(a5)
        if (!task[i]) {
ffffffe0002013a4:	00008717          	auipc	a4,0x8
ffffffe0002013a8:	c8c70713          	addi	a4,a4,-884 # ffffffe000209030 <task>
ffffffe0002013ac:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013b0:	00379793          	slli	a5,a5,0x3
ffffffe0002013b4:	00f707b3          	add	a5,a4,a5
ffffffe0002013b8:	0007b783          	ld	a5,0(a5)
ffffffe0002013bc:	00079e63          	bnez	a5,ffffffe0002013d8 <task_init+0x120>
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d\n", i);
ffffffe0002013c0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013c4:	00078593          	mv	a1,a5
ffffffe0002013c8:	00003517          	auipc	a0,0x3
ffffffe0002013cc:	ce050513          	addi	a0,a0,-800 # ffffffe0002040a8 <_srodata+0xa8>
ffffffe0002013d0:	680020ef          	jal	ffffffe000203a50 <printk>
            return;
ffffffe0002013d4:	3c00006f          	j	ffffffe000201794 <task_init+0x4dc>
        }
        task[i]->state=TASK_RUNNING;
ffffffe0002013d8:	00008717          	auipc	a4,0x8
ffffffe0002013dc:	c5870713          	addi	a4,a4,-936 # ffffffe000209030 <task>
ffffffe0002013e0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013e4:	00379793          	slli	a5,a5,0x3
ffffffe0002013e8:	00f707b3          	add	a5,a4,a5
ffffffe0002013ec:	0007b783          	ld	a5,0(a5)
ffffffe0002013f0:	0007b023          	sd	zero,0(a5)
        task[i]->counter=0;
ffffffe0002013f4:	00008717          	auipc	a4,0x8
ffffffe0002013f8:	c3c70713          	addi	a4,a4,-964 # ffffffe000209030 <task>
ffffffe0002013fc:	fdc42783          	lw	a5,-36(s0)
ffffffe000201400:	00379793          	slli	a5,a5,0x3
ffffffe000201404:	00f707b3          	add	a5,a4,a5
ffffffe000201408:	0007b783          	ld	a5,0(a5)
ffffffe00020140c:	0007b423          	sd	zero,8(a5)
        task[i]->priority=rand()%(PRIORITY_MAX - PRIORITY_MIN + 1)+PRIORITY_MIN;
ffffffe000201410:	704020ef          	jal	ffffffe000203b14 <rand>
ffffffe000201414:	00050793          	mv	a5,a0
ffffffe000201418:	00078713          	mv	a4,a5
ffffffe00020141c:	00a00793          	li	a5,10
ffffffe000201420:	02f767bb          	remw	a5,a4,a5
ffffffe000201424:	0007879b          	sext.w	a5,a5
ffffffe000201428:	0017879b          	addiw	a5,a5,1
ffffffe00020142c:	0007869b          	sext.w	a3,a5
ffffffe000201430:	00008717          	auipc	a4,0x8
ffffffe000201434:	c0070713          	addi	a4,a4,-1024 # ffffffe000209030 <task>
ffffffe000201438:	fdc42783          	lw	a5,-36(s0)
ffffffe00020143c:	00379793          	slli	a5,a5,0x3
ffffffe000201440:	00f707b3          	add	a5,a4,a5
ffffffe000201444:	0007b783          	ld	a5,0(a5)
ffffffe000201448:	00068713          	mv	a4,a3
ffffffe00020144c:	00e7b823          	sd	a4,16(a5)
        task[i]->pid=i;
ffffffe000201450:	00008717          	auipc	a4,0x8
ffffffe000201454:	be070713          	addi	a4,a4,-1056 # ffffffe000209030 <task>
ffffffe000201458:	fdc42783          	lw	a5,-36(s0)
ffffffe00020145c:	00379793          	slli	a5,a5,0x3
ffffffe000201460:	00f707b3          	add	a5,a4,a5
ffffffe000201464:	0007b783          	ld	a5,0(a5)
ffffffe000201468:	fdc42703          	lw	a4,-36(s0)
ffffffe00020146c:	00e7bc23          	sd	a4,24(a5)

        task[i]->thread.ra=(uint64_t)__dummy;
ffffffe000201470:	00008717          	auipc	a4,0x8
ffffffe000201474:	bc070713          	addi	a4,a4,-1088 # ffffffe000209030 <task>
ffffffe000201478:	fdc42783          	lw	a5,-36(s0)
ffffffe00020147c:	00379793          	slli	a5,a5,0x3
ffffffe000201480:	00f707b3          	add	a5,a4,a5
ffffffe000201484:	0007b783          	ld	a5,0(a5)
ffffffe000201488:	fffff717          	auipc	a4,0xfffff
ffffffe00020148c:	ea070713          	addi	a4,a4,-352 # ffffffe000200328 <__dummy>
ffffffe000201490:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp=(uint64_t)task[i]+PGSIZE;
ffffffe000201494:	00008717          	auipc	a4,0x8
ffffffe000201498:	b9c70713          	addi	a4,a4,-1124 # ffffffe000209030 <task>
ffffffe00020149c:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014a0:	00379793          	slli	a5,a5,0x3
ffffffe0002014a4:	00f707b3          	add	a5,a4,a5
ffffffe0002014a8:	0007b783          	ld	a5,0(a5)
ffffffe0002014ac:	00078693          	mv	a3,a5
ffffffe0002014b0:	00008717          	auipc	a4,0x8
ffffffe0002014b4:	b8070713          	addi	a4,a4,-1152 # ffffffe000209030 <task>
ffffffe0002014b8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014bc:	00379793          	slli	a5,a5,0x3
ffffffe0002014c0:	00f707b3          	add	a5,a4,a5
ffffffe0002014c4:	0007b783          	ld	a5,0(a5)
ffffffe0002014c8:	00001737          	lui	a4,0x1
ffffffe0002014cc:	00e68733          	add	a4,a3,a4
ffffffe0002014d0:	02e7b423          	sd	a4,40(a5)

        // lab5 ------------------------------------
        task[i]->mm.mmap=NULL;
ffffffe0002014d4:	00008717          	auipc	a4,0x8
ffffffe0002014d8:	b5c70713          	addi	a4,a4,-1188 # ffffffe000209030 <task>
ffffffe0002014dc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014e0:	00379793          	slli	a5,a5,0x3
ffffffe0002014e4:	00f707b3          	add	a5,a4,a5
ffffffe0002014e8:	0007b783          	ld	a5,0(a5)
ffffffe0002014ec:	0a07b823          	sd	zero,176(a5)
        // -----------------------------------------

        // lab4 ---------------------------------------------------------
        
        // 对于每个进程，创建属于它自己的页表----------------------------------
        task[i]->pgd = (uint64_t *)alloc_page();
ffffffe0002014f0:	00008717          	auipc	a4,0x8
ffffffe0002014f4:	b4070713          	addi	a4,a4,-1216 # ffffffe000209030 <task>
ffffffe0002014f8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014fc:	00379793          	slli	a5,a5,0x3
ffffffe000201500:	00f707b3          	add	a5,a4,a5
ffffffe000201504:	0007b483          	ld	s1,0(a5)
ffffffe000201508:	d90ff0ef          	jal	ffffffe000200a98 <alloc_page>
ffffffe00020150c:	00050793          	mv	a5,a0
ffffffe000201510:	0af4b423          	sd	a5,168(s1)
        if (!task[i]->pgd) {
ffffffe000201514:	00008717          	auipc	a4,0x8
ffffffe000201518:	b1c70713          	addi	a4,a4,-1252 # ffffffe000209030 <task>
ffffffe00020151c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201520:	00379793          	slli	a5,a5,0x3
ffffffe000201524:	00f707b3          	add	a5,a4,a5
ffffffe000201528:	0007b783          	ld	a5,0(a5)
ffffffe00020152c:	0a87b783          	ld	a5,168(a5)
ffffffe000201530:	00079e63          	bnez	a5,ffffffe00020154c <task_init+0x294>
            // 如果内存分配失败，则退出
            printk("Failed to allocate memory for task %d's page directory\n", i);
ffffffe000201534:	fdc42783          	lw	a5,-36(s0)
ffffffe000201538:	00078593          	mv	a1,a5
ffffffe00020153c:	00003517          	auipc	a0,0x3
ffffffe000201540:	b9450513          	addi	a0,a0,-1132 # ffffffe0002040d0 <_srodata+0xd0>
ffffffe000201544:	50c020ef          	jal	ffffffe000203a50 <printk>
            return;
ffffffe000201548:	24c0006f          	j	ffffffe000201794 <task_init+0x4dc>
        }
        // 将内核页表 swapper_pg_dir 复制到每个进程的页表中
        memcpy((void *)task[i]->pgd,(void *)swapper_pg_dir,PGSIZE);
ffffffe00020154c:	00008717          	auipc	a4,0x8
ffffffe000201550:	ae470713          	addi	a4,a4,-1308 # ffffffe000209030 <task>
ffffffe000201554:	fdc42783          	lw	a5,-36(s0)
ffffffe000201558:	00379793          	slli	a5,a5,0x3
ffffffe00020155c:	00f707b3          	add	a5,a4,a5
ffffffe000201560:	0007b783          	ld	a5,0(a5)
ffffffe000201564:	0a87b783          	ld	a5,168(a5)
ffffffe000201568:	00001637          	lui	a2,0x1
ffffffe00020156c:	0000a597          	auipc	a1,0xa
ffffffe000201570:	a9458593          	addi	a1,a1,-1388 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201574:	00078513          	mv	a0,a5
ffffffe000201578:	871ff0ef          	jal	ffffffe000200de8 <memcpy>
        // 映射到进程的页表中
        // uint64_t user_stack_va = USER_END - PGSIZE;
        // uint64_t user_stack_pa = (uint64_t)user_stack - PA2VA_OFFSET;
        // create_mapping(task[i]->pgd,user_stack_va,user_stack_pa,PGSIZE,PERM_USER_USTACK);

        Elf64_Ehdr *ehdr = (Elf64_Ehdr*)_sramdisk;
ffffffe00020157c:	00005797          	auipc	a5,0x5
ffffffe000201580:	a8478793          	addi	a5,a5,-1404 # ffffffe000206000 <_sramdisk>
ffffffe000201584:	fcf43823          	sd	a5,-48(s0)

        // check magic number
        if ((ehdr->e_ident[0]  == 0x7f &&ehdr->e_ident[1]  == 0x45 &&ehdr->e_ident[2]  == 0x4c &&
ffffffe000201588:	fd043783          	ld	a5,-48(s0)
ffffffe00020158c:	0007c783          	lbu	a5,0(a5)
ffffffe000201590:	00078713          	mv	a4,a5
ffffffe000201594:	07f00793          	li	a5,127
ffffffe000201598:	12f71e63          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe00020159c:	fd043783          	ld	a5,-48(s0)
ffffffe0002015a0:	0017c783          	lbu	a5,1(a5)
ffffffe0002015a4:	00078713          	mv	a4,a5
ffffffe0002015a8:	04500793          	li	a5,69
ffffffe0002015ac:	12f71463          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe0002015b0:	fd043783          	ld	a5,-48(s0)
ffffffe0002015b4:	0027c783          	lbu	a5,2(a5)
ffffffe0002015b8:	00078713          	mv	a4,a5
ffffffe0002015bc:	04c00793          	li	a5,76
ffffffe0002015c0:	10f71a63          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe0002015c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002015c8:	0037c783          	lbu	a5,3(a5)
        if ((ehdr->e_ident[0]  == 0x7f &&ehdr->e_ident[1]  == 0x45 &&ehdr->e_ident[2]  == 0x4c &&
ffffffe0002015cc:	00078713          	mv	a4,a5
ffffffe0002015d0:	04600793          	li	a5,70
ffffffe0002015d4:	10f71063          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe0002015d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002015dc:	0047c783          	lbu	a5,4(a5)
ffffffe0002015e0:	00078713          	mv	a4,a5
ffffffe0002015e4:	00200793          	li	a5,2
ffffffe0002015e8:	0ef71663          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe0002015ec:	fd043783          	ld	a5,-48(s0)
ffffffe0002015f0:	0057c783          	lbu	a5,5(a5)
ffffffe0002015f4:	00078713          	mv	a4,a5
ffffffe0002015f8:	00100793          	li	a5,1
ffffffe0002015fc:	0cf71c63          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe000201600:	fd043783          	ld	a5,-48(s0)
ffffffe000201604:	0067c783          	lbu	a5,6(a5)
            ehdr->e_ident[3]  == 0x46 &&ehdr->e_ident[4]  == 0x02 &&ehdr->e_ident[5]  == 0x01 &&
ffffffe000201608:	00078713          	mv	a4,a5
ffffffe00020160c:	00100793          	li	a5,1
ffffffe000201610:	0cf71263          	bne	a4,a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe000201614:	fd043783          	ld	a5,-48(s0)
ffffffe000201618:	0077c783          	lbu	a5,7(a5)
ffffffe00020161c:	0a079c63          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe000201620:	fd043783          	ld	a5,-48(s0)
ffffffe000201624:	0087c783          	lbu	a5,8(a5)
ffffffe000201628:	0a079663          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe00020162c:	fd043783          	ld	a5,-48(s0)
ffffffe000201630:	0097c783          	lbu	a5,9(a5)
            ehdr->e_ident[6]  == 0x01 &&ehdr->e_ident[7]  == 0x00 && ehdr->e_ident[8]  == 0x00 &&
ffffffe000201634:	0a079063          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe000201638:	fd043783          	ld	a5,-48(s0)
ffffffe00020163c:	00a7c783          	lbu	a5,10(a5)
ffffffe000201640:	08079a63          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe000201644:	fd043783          	ld	a5,-48(s0)
ffffffe000201648:	00b7c783          	lbu	a5,11(a5)
ffffffe00020164c:	08079463          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe000201650:	fd043783          	ld	a5,-48(s0)
ffffffe000201654:	00c7c783          	lbu	a5,12(a5)
            ehdr->e_ident[9]  == 0x00 &&ehdr->e_ident[10] == 0x00 &&ehdr->e_ident[11] == 0x00 &&
ffffffe000201658:	06079e63          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe00020165c:	fd043783          	ld	a5,-48(s0)
ffffffe000201660:	00d7c783          	lbu	a5,13(a5)
ffffffe000201664:	06079863          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
ffffffe000201668:	fd043783          	ld	a5,-48(s0)
ffffffe00020166c:	00e7c783          	lbu	a5,14(a5)
ffffffe000201670:	06079263          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
            ehdr->e_ident[15] == 0x00)) 
ffffffe000201674:	fd043783          	ld	a5,-48(s0)
ffffffe000201678:	00f7c783          	lbu	a5,15(a5)
            ehdr->e_ident[12] == 0x00 &&ehdr->e_ident[13] == 0x00 &&ehdr->e_ident[14] == 0x00 &&
ffffffe00020167c:	04079c63          	bnez	a5,ffffffe0002016d4 <task_init+0x41c>
        {
            printk("elf\n");
ffffffe000201680:	00003517          	auipc	a0,0x3
ffffffe000201684:	a8850513          	addi	a0,a0,-1400 # ffffffe000204108 <_srodata+0x108>
ffffffe000201688:	3c8020ef          	jal	ffffffe000203a50 <printk>
            // load_elf_program(task[i]);
            load_program(task[i]);  // vma
ffffffe00020168c:	00008717          	auipc	a4,0x8
ffffffe000201690:	9a470713          	addi	a4,a4,-1628 # ffffffe000209030 <task>
ffffffe000201694:	fdc42783          	lw	a5,-36(s0)
ffffffe000201698:	00379793          	slli	a5,a5,0x3
ffffffe00020169c:	00f707b3          	add	a5,a4,a5
ffffffe0002016a0:	0007b783          	ld	a5,0(a5)
ffffffe0002016a4:	00078513          	mv	a0,a5
ffffffe0002016a8:	a85ff0ef          	jal	ffffffe00020112c <load_program>
            task[i]->thread.sepc = ehdr->e_entry;
ffffffe0002016ac:	00008717          	auipc	a4,0x8
ffffffe0002016b0:	98470713          	addi	a4,a4,-1660 # ffffffe000209030 <task>
ffffffe0002016b4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002016b8:	00379793          	slli	a5,a5,0x3
ffffffe0002016bc:	00f707b3          	add	a5,a4,a5
ffffffe0002016c0:	0007b783          	ld	a5,0(a5)
ffffffe0002016c4:	fd043703          	ld	a4,-48(s0)
ffffffe0002016c8:	01873703          	ld	a4,24(a4)
ffffffe0002016cc:	08e7b823          	sd	a4,144(a5)
ffffffe0002016d0:	02c0006f          	j	ffffffe0002016fc <task_init+0x444>
        }else
        {
            printk("bin\n");
ffffffe0002016d4:	00003517          	auipc	a0,0x3
ffffffe0002016d8:	a3c50513          	addi	a0,a0,-1476 # ffffffe000204110 <_srodata+0x110>
ffffffe0002016dc:	374020ef          	jal	ffffffe000203a50 <printk>
            // load_bin_program(task[i]);
            // 1.将 sepc 设置为 USER_START U-Mode程序入口地址
            task[i]->thread.sepc = USER_START;
ffffffe0002016e0:	00008717          	auipc	a4,0x8
ffffffe0002016e4:	95070713          	addi	a4,a4,-1712 # ffffffe000209030 <task>
ffffffe0002016e8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002016ec:	00379793          	slli	a5,a5,0x3
ffffffe0002016f0:	00f707b3          	add	a5,a4,a5
ffffffe0002016f4:	0007b783          	ld	a5,0(a5)
ffffffe0002016f8:	0807b823          	sd	zero,144(a5)
        }
        

        // 2.set sstatus 
        uint64_t set_sstatus=0;
ffffffe0002016fc:	fc043423          	sd	zero,-56(s0)
        // SPP（使得 sret 返回至 U-Mode）--- bit[8]=0
        set_sstatus = set_sstatus & 0xfffffffffffffeff; 
ffffffe000201700:	fc843783          	ld	a5,-56(s0)
ffffffe000201704:	eff7f793          	andi	a5,a5,-257
ffffffe000201708:	fcf43423          	sd	a5,-56(s0)
        // SPIE（sret 之后开启中断）--- bit[5]=1
        set_sstatus = set_sstatus | (1<<5);
ffffffe00020170c:	fc843783          	ld	a5,-56(s0)
ffffffe000201710:	0207e793          	ori	a5,a5,32
ffffffe000201714:	fcf43423          	sd	a5,-56(s0)
        // SUM（S-Mode 可以访问 User 页面）--- bit[18]=1
        set_sstatus = set_sstatus | (1<<18);        
ffffffe000201718:	fc843703          	ld	a4,-56(s0)
ffffffe00020171c:	000407b7          	lui	a5,0x40
ffffffe000201720:	00f767b3          	or	a5,a4,a5
ffffffe000201724:	fcf43423          	sd	a5,-56(s0)
        task[i]->thread.sstatus = set_sstatus;
ffffffe000201728:	00008717          	auipc	a4,0x8
ffffffe00020172c:	90870713          	addi	a4,a4,-1784 # ffffffe000209030 <task>
ffffffe000201730:	fdc42783          	lw	a5,-36(s0)
ffffffe000201734:	00379793          	slli	a5,a5,0x3
ffffffe000201738:	00f707b3          	add	a5,a4,a5
ffffffe00020173c:	0007b783          	ld	a5,0(a5) # 40000 <PGSIZE+0x3f000>
ffffffe000201740:	fc843703          	ld	a4,-56(s0)
ffffffe000201744:	08e7bc23          	sd	a4,152(a5)
        // 3.sscratch 设置为 U-Mode 的 sp，其值为 USER_END
        task[i]->thread.sscratch = USER_END;
ffffffe000201748:	00008717          	auipc	a4,0x8
ffffffe00020174c:	8e870713          	addi	a4,a4,-1816 # ffffffe000209030 <task>
ffffffe000201750:	fdc42783          	lw	a5,-36(s0)
ffffffe000201754:	00379793          	slli	a5,a5,0x3
ffffffe000201758:	00f707b3          	add	a5,a4,a5
ffffffe00020175c:	0007b783          	ld	a5,0(a5)
ffffffe000201760:	00100713          	li	a4,1
ffffffe000201764:	02671713          	slli	a4,a4,0x26
ffffffe000201768:	0ae7b023          	sd	a4,160(a5)
    for(int i=1;i<NR_TASKS;i++)
ffffffe00020176c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201770:	0017879b          	addiw	a5,a5,1
ffffffe000201774:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201778:	fdc42783          	lw	a5,-36(s0)
ffffffe00020177c:	0007871b          	sext.w	a4,a5
ffffffe000201780:	00400793          	li	a5,4
ffffffe000201784:	c0e7d0e3          	bge	a5,a4,ffffffe000201384 <task_init+0xcc>
        
        // ----------------------------------------------------------------------------
    }
    
    printk("...task_init done!\n");
ffffffe000201788:	00003517          	auipc	a0,0x3
ffffffe00020178c:	99050513          	addi	a0,a0,-1648 # ffffffe000204118 <_srodata+0x118>
ffffffe000201790:	2c0020ef          	jal	ffffffe000203a50 <printk>
}
ffffffe000201794:	03813083          	ld	ra,56(sp)
ffffffe000201798:	03013403          	ld	s0,48(sp)
ffffffe00020179c:	02813483          	ld	s1,40(sp)
ffffffe0002017a0:	04010113          	addi	sp,sp,64
ffffffe0002017a4:	00008067          	ret

ffffffe0002017a8 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe0002017a8:	fd010113          	addi	sp,sp,-48
ffffffe0002017ac:	02113423          	sd	ra,40(sp)
ffffffe0002017b0:	02813023          	sd	s0,32(sp)
ffffffe0002017b4:	03010413          	addi	s0,sp,48
    printk("dummy\n");
ffffffe0002017b8:	00003517          	auipc	a0,0x3
ffffffe0002017bc:	97850513          	addi	a0,a0,-1672 # ffffffe000204130 <_srodata+0x130>
ffffffe0002017c0:	290020ef          	jal	ffffffe000203a50 <printk>
    uint64_t MOD = 1000000007;
ffffffe0002017c4:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe0002017c8:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe0002017cc:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe0002017d0:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe0002017d4:	fff00793          	li	a5,-1
ffffffe0002017d8:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002017dc:	fe442783          	lw	a5,-28(s0)
ffffffe0002017e0:	0007871b          	sext.w	a4,a5
ffffffe0002017e4:	fff00793          	li	a5,-1
ffffffe0002017e8:	00f70e63          	beq	a4,a5,ffffffe000201804 <dummy+0x5c>
ffffffe0002017ec:	00008797          	auipc	a5,0x8
ffffffe0002017f0:	82478793          	addi	a5,a5,-2012 # ffffffe000209010 <current>
ffffffe0002017f4:	0007b783          	ld	a5,0(a5)
ffffffe0002017f8:	0087b703          	ld	a4,8(a5)
ffffffe0002017fc:	fe442783          	lw	a5,-28(s0)
ffffffe000201800:	fcf70ee3          	beq	a4,a5,ffffffe0002017dc <dummy+0x34>
ffffffe000201804:	00008797          	auipc	a5,0x8
ffffffe000201808:	80c78793          	addi	a5,a5,-2036 # ffffffe000209010 <current>
ffffffe00020180c:	0007b783          	ld	a5,0(a5)
ffffffe000201810:	0087b783          	ld	a5,8(a5)
ffffffe000201814:	fc0784e3          	beqz	a5,ffffffe0002017dc <dummy+0x34>
            if (current->counter == 1) {
ffffffe000201818:	00007797          	auipc	a5,0x7
ffffffe00020181c:	7f878793          	addi	a5,a5,2040 # ffffffe000209010 <current>
ffffffe000201820:	0007b783          	ld	a5,0(a5)
ffffffe000201824:	0087b703          	ld	a4,8(a5)
ffffffe000201828:	00100793          	li	a5,1
ffffffe00020182c:	00f71e63          	bne	a4,a5,ffffffe000201848 <dummy+0xa0>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000201830:	00007797          	auipc	a5,0x7
ffffffe000201834:	7e078793          	addi	a5,a5,2016 # ffffffe000209010 <current>
ffffffe000201838:	0007b783          	ld	a5,0(a5)
ffffffe00020183c:	0087b703          	ld	a4,8(a5)
ffffffe000201840:	fff70713          	addi	a4,a4,-1
ffffffe000201844:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000201848:	00007797          	auipc	a5,0x7
ffffffe00020184c:	7c878793          	addi	a5,a5,1992 # ffffffe000209010 <current>
ffffffe000201850:	0007b783          	ld	a5,0(a5)
ffffffe000201854:	0087b783          	ld	a5,8(a5)
ffffffe000201858:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe00020185c:	fe843783          	ld	a5,-24(s0)
ffffffe000201860:	00178713          	addi	a4,a5,1
ffffffe000201864:	fd843783          	ld	a5,-40(s0)
ffffffe000201868:	02f777b3          	remu	a5,a4,a5
ffffffe00020186c:	fef43423          	sd	a5,-24(s0)
            printk(BLUE"[PID = %d] is running. auto_inc_local_var = %d\n"CLEAR, current->pid, auto_inc_local_var);
ffffffe000201870:	00007797          	auipc	a5,0x7
ffffffe000201874:	7a078793          	addi	a5,a5,1952 # ffffffe000209010 <current>
ffffffe000201878:	0007b783          	ld	a5,0(a5)
ffffffe00020187c:	0187b783          	ld	a5,24(a5)
ffffffe000201880:	fe843603          	ld	a2,-24(s0)
ffffffe000201884:	00078593          	mv	a1,a5
ffffffe000201888:	00003517          	auipc	a0,0x3
ffffffe00020188c:	8b050513          	addi	a0,a0,-1872 # ffffffe000204138 <_srodata+0x138>
ffffffe000201890:	1c0020ef          	jal	ffffffe000203a50 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000201894:	f49ff06f          	j	ffffffe0002017dc <dummy+0x34>

ffffffe000201898 <switch_to>:
    }
}

/* 线程切换入口函数 */
void switch_to(struct task_struct *next)
{
ffffffe000201898:	fd010113          	addi	sp,sp,-48
ffffffe00020189c:	02113423          	sd	ra,40(sp)
ffffffe0002018a0:	02813023          	sd	s0,32(sp)
ffffffe0002018a4:	03010413          	addi	s0,sp,48
ffffffe0002018a8:	fca43c23          	sd	a0,-40(s0)
    // YOUR CODE HERE
    if(current==next)
ffffffe0002018ac:	00007797          	auipc	a5,0x7
ffffffe0002018b0:	76478793          	addi	a5,a5,1892 # ffffffe000209010 <current>
ffffffe0002018b4:	0007b783          	ld	a5,0(a5)
ffffffe0002018b8:	fd843703          	ld	a4,-40(s0)
ffffffe0002018bc:	06f70063          	beq	a4,a5,ffffffe00020191c <switch_to+0x84>
    {
        return;
    }else
    {
        printk(YELLOW"\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,next->pid,next->priority,next->counter);
ffffffe0002018c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002018c4:	0187b703          	ld	a4,24(a5)
ffffffe0002018c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002018cc:	0107b603          	ld	a2,16(a5)
ffffffe0002018d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002018d4:	0087b783          	ld	a5,8(a5)
ffffffe0002018d8:	00078693          	mv	a3,a5
ffffffe0002018dc:	00070593          	mv	a1,a4
ffffffe0002018e0:	00003517          	auipc	a0,0x3
ffffffe0002018e4:	89850513          	addi	a0,a0,-1896 # ffffffe000204178 <_srodata+0x178>
ffffffe0002018e8:	168020ef          	jal	ffffffe000203a50 <printk>
        struct task_struct *temp=current;
ffffffe0002018ec:	00007797          	auipc	a5,0x7
ffffffe0002018f0:	72478793          	addi	a5,a5,1828 # ffffffe000209010 <current>
ffffffe0002018f4:	0007b783          	ld	a5,0(a5)
ffffffe0002018f8:	fef43423          	sd	a5,-24(s0)
        current=next;
ffffffe0002018fc:	00007797          	auipc	a5,0x7
ffffffe000201900:	71478793          	addi	a5,a5,1812 # ffffffe000209010 <current>
ffffffe000201904:	fd843703          	ld	a4,-40(s0)
ffffffe000201908:	00e7b023          	sd	a4,0(a5)
        __switch_to(temp,next);  //调用 __switch_to 函数进行线程切换
ffffffe00020190c:	fd843583          	ld	a1,-40(s0)
ffffffe000201910:	fe843503          	ld	a0,-24(s0)
ffffffe000201914:	a25fe0ef          	jal	ffffffe000200338 <__switch_to>
        // printk("ok\n");
    }
    return;
ffffffe000201918:	0080006f          	j	ffffffe000201920 <switch_to+0x88>
        return;
ffffffe00020191c:	00000013          	nop
}
ffffffe000201920:	02813083          	ld	ra,40(sp)
ffffffe000201924:	02013403          	ld	s0,32(sp)
ffffffe000201928:	03010113          	addi	sp,sp,48
ffffffe00020192c:	00008067          	ret

ffffffe000201930 <do_timer>:

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer()
{
ffffffe000201930:	ff010113          	addi	sp,sp,-16
ffffffe000201934:	00113423          	sd	ra,8(sp)
ffffffe000201938:	00813023          	sd	s0,0(sp)
ffffffe00020193c:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE
    if(current==idle||current->counter<=0)
ffffffe000201940:	00007797          	auipc	a5,0x7
ffffffe000201944:	6d078793          	addi	a5,a5,1744 # ffffffe000209010 <current>
ffffffe000201948:	0007b703          	ld	a4,0(a5)
ffffffe00020194c:	00007797          	auipc	a5,0x7
ffffffe000201950:	6bc78793          	addi	a5,a5,1724 # ffffffe000209008 <idle>
ffffffe000201954:	0007b783          	ld	a5,0(a5)
ffffffe000201958:	00f70c63          	beq	a4,a5,ffffffe000201970 <do_timer+0x40>
ffffffe00020195c:	00007797          	auipc	a5,0x7
ffffffe000201960:	6b478793          	addi	a5,a5,1716 # ffffffe000209010 <current>
ffffffe000201964:	0007b783          	ld	a5,0(a5)
ffffffe000201968:	0087b783          	ld	a5,8(a5)
ffffffe00020196c:	00079663          	bnez	a5,ffffffe000201978 <do_timer+0x48>
    {
        schedule();
ffffffe000201970:	05c000ef          	jal	ffffffe0002019cc <schedule>
        }else
        {
            schedule();
        }
    }
    return;
ffffffe000201974:	0480006f          	j	ffffffe0002019bc <do_timer+0x8c>
        current->counter=current->counter-1;
ffffffe000201978:	00007797          	auipc	a5,0x7
ffffffe00020197c:	69878793          	addi	a5,a5,1688 # ffffffe000209010 <current>
ffffffe000201980:	0007b783          	ld	a5,0(a5)
ffffffe000201984:	0087b703          	ld	a4,8(a5)
ffffffe000201988:	00007797          	auipc	a5,0x7
ffffffe00020198c:	68878793          	addi	a5,a5,1672 # ffffffe000209010 <current>
ffffffe000201990:	0007b783          	ld	a5,0(a5)
ffffffe000201994:	fff70713          	addi	a4,a4,-1
ffffffe000201998:	00e7b423          	sd	a4,8(a5)
        if(current->counter>0)
ffffffe00020199c:	00007797          	auipc	a5,0x7
ffffffe0002019a0:	67478793          	addi	a5,a5,1652 # ffffffe000209010 <current>
ffffffe0002019a4:	0007b783          	ld	a5,0(a5)
ffffffe0002019a8:	0087b783          	ld	a5,8(a5)
ffffffe0002019ac:	00079663          	bnez	a5,ffffffe0002019b8 <do_timer+0x88>
            schedule();
ffffffe0002019b0:	01c000ef          	jal	ffffffe0002019cc <schedule>
    return;
ffffffe0002019b4:	0080006f          	j	ffffffe0002019bc <do_timer+0x8c>
            return;
ffffffe0002019b8:	00000013          	nop
}
ffffffe0002019bc:	00813083          	ld	ra,8(sp)
ffffffe0002019c0:	00013403          	ld	s0,0(sp)
ffffffe0002019c4:	01010113          	addi	sp,sp,16
ffffffe0002019c8:	00008067          	ret

ffffffe0002019cc <schedule>:

/* 调度程序，选择出下一个运行的线程 */
void schedule()
{
ffffffe0002019cc:	fe010113          	addi	sp,sp,-32
ffffffe0002019d0:	00113c23          	sd	ra,24(sp)
ffffffe0002019d4:	00813823          	sd	s0,16(sp)
ffffffe0002019d8:	02010413          	addi	s0,sp,32
    int i;
    // 调度时选择 counter 最大的线程运行
    int max_index=0;
ffffffe0002019dc:	fe042423          	sw	zero,-24(s0)
    int max_counter=0;
ffffffe0002019e0:	fe042223          	sw	zero,-28(s0)
    for(i=1;i<NR_TASKS;i++)
ffffffe0002019e4:	00100793          	li	a5,1
ffffffe0002019e8:	fef42623          	sw	a5,-20(s0)
ffffffe0002019ec:	0e80006f          	j	ffffffe000201ad4 <schedule+0x108>
    {
        if(task[i]->counter>max_counter&&task[i]->state==TASK_RUNNING)
ffffffe0002019f0:	00007717          	auipc	a4,0x7
ffffffe0002019f4:	64070713          	addi	a4,a4,1600 # ffffffe000209030 <task>
ffffffe0002019f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019fc:	00379793          	slli	a5,a5,0x3
ffffffe000201a00:	00f707b3          	add	a5,a4,a5
ffffffe000201a04:	0007b783          	ld	a5,0(a5)
ffffffe000201a08:	0087b703          	ld	a4,8(a5)
ffffffe000201a0c:	fe442783          	lw	a5,-28(s0)
ffffffe000201a10:	04e7f863          	bgeu	a5,a4,ffffffe000201a60 <schedule+0x94>
ffffffe000201a14:	00007717          	auipc	a4,0x7
ffffffe000201a18:	61c70713          	addi	a4,a4,1564 # ffffffe000209030 <task>
ffffffe000201a1c:	fec42783          	lw	a5,-20(s0)
ffffffe000201a20:	00379793          	slli	a5,a5,0x3
ffffffe000201a24:	00f707b3          	add	a5,a4,a5
ffffffe000201a28:	0007b783          	ld	a5,0(a5)
ffffffe000201a2c:	0007b783          	ld	a5,0(a5)
ffffffe000201a30:	02079863          	bnez	a5,ffffffe000201a60 <schedule+0x94>
        {
            max_index=i;
ffffffe000201a34:	fec42783          	lw	a5,-20(s0)
ffffffe000201a38:	fef42423          	sw	a5,-24(s0)
            max_counter=task[i]->counter;
ffffffe000201a3c:	00007717          	auipc	a4,0x7
ffffffe000201a40:	5f470713          	addi	a4,a4,1524 # ffffffe000209030 <task>
ffffffe000201a44:	fec42783          	lw	a5,-20(s0)
ffffffe000201a48:	00379793          	slli	a5,a5,0x3
ffffffe000201a4c:	00f707b3          	add	a5,a4,a5
ffffffe000201a50:	0007b783          	ld	a5,0(a5)
ffffffe000201a54:	0087b783          	ld	a5,8(a5)
ffffffe000201a58:	fef42223          	sw	a5,-28(s0)
ffffffe000201a5c:	06c0006f          	j	ffffffe000201ac8 <schedule+0xfc>
        }else if(task[i]->counter==max_counter) // 即优先级越高，运行的时间越长，且越先运行
ffffffe000201a60:	00007717          	auipc	a4,0x7
ffffffe000201a64:	5d070713          	addi	a4,a4,1488 # ffffffe000209030 <task>
ffffffe000201a68:	fec42783          	lw	a5,-20(s0)
ffffffe000201a6c:	00379793          	slli	a5,a5,0x3
ffffffe000201a70:	00f707b3          	add	a5,a4,a5
ffffffe000201a74:	0007b783          	ld	a5,0(a5)
ffffffe000201a78:	0087b703          	ld	a4,8(a5)
ffffffe000201a7c:	fe442783          	lw	a5,-28(s0)
ffffffe000201a80:	04f71463          	bne	a4,a5,ffffffe000201ac8 <schedule+0xfc>
        {
            if(task[i]->priority>task[max_index]->priority)
ffffffe000201a84:	00007717          	auipc	a4,0x7
ffffffe000201a88:	5ac70713          	addi	a4,a4,1452 # ffffffe000209030 <task>
ffffffe000201a8c:	fec42783          	lw	a5,-20(s0)
ffffffe000201a90:	00379793          	slli	a5,a5,0x3
ffffffe000201a94:	00f707b3          	add	a5,a4,a5
ffffffe000201a98:	0007b783          	ld	a5,0(a5)
ffffffe000201a9c:	0107b703          	ld	a4,16(a5)
ffffffe000201aa0:	00007697          	auipc	a3,0x7
ffffffe000201aa4:	59068693          	addi	a3,a3,1424 # ffffffe000209030 <task>
ffffffe000201aa8:	fe842783          	lw	a5,-24(s0)
ffffffe000201aac:	00379793          	slli	a5,a5,0x3
ffffffe000201ab0:	00f687b3          	add	a5,a3,a5
ffffffe000201ab4:	0007b783          	ld	a5,0(a5)
ffffffe000201ab8:	0107b783          	ld	a5,16(a5)
ffffffe000201abc:	00e7f663          	bgeu	a5,a4,ffffffe000201ac8 <schedule+0xfc>
            {
                max_index=i;
ffffffe000201ac0:	fec42783          	lw	a5,-20(s0)
ffffffe000201ac4:	fef42423          	sw	a5,-24(s0)
    for(i=1;i<NR_TASKS;i++)
ffffffe000201ac8:	fec42783          	lw	a5,-20(s0)
ffffffe000201acc:	0017879b          	addiw	a5,a5,1
ffffffe000201ad0:	fef42623          	sw	a5,-20(s0)
ffffffe000201ad4:	fec42783          	lw	a5,-20(s0)
ffffffe000201ad8:	0007871b          	sext.w	a4,a5
ffffffe000201adc:	00400793          	li	a5,4
ffffffe000201ae0:	f0e7d8e3          	bge	a5,a4,ffffffe0002019f0 <schedule+0x24>
        }
    }

    // next=task[choice];
    // 如果所有线程 counter 都为 0，则令所有线程 counter = priority
    bool all_zero=true;
ffffffe000201ae4:	00100793          	li	a5,1
ffffffe000201ae8:	fef401a3          	sb	a5,-29(s0)
    for(i=1;i<NR_TASKS;i++)
ffffffe000201aec:	00100793          	li	a5,1
ffffffe000201af0:	fef42623          	sw	a5,-20(s0)
ffffffe000201af4:	0380006f          	j	ffffffe000201b2c <schedule+0x160>
    {
        if(task[i]->counter!=0)
ffffffe000201af8:	00007717          	auipc	a4,0x7
ffffffe000201afc:	53870713          	addi	a4,a4,1336 # ffffffe000209030 <task>
ffffffe000201b00:	fec42783          	lw	a5,-20(s0)
ffffffe000201b04:	00379793          	slli	a5,a5,0x3
ffffffe000201b08:	00f707b3          	add	a5,a4,a5
ffffffe000201b0c:	0007b783          	ld	a5,0(a5)
ffffffe000201b10:	0087b783          	ld	a5,8(a5)
ffffffe000201b14:	00078663          	beqz	a5,ffffffe000201b20 <schedule+0x154>
        {
            all_zero=0;
ffffffe000201b18:	fe0401a3          	sb	zero,-29(s0)
            break;
ffffffe000201b1c:	0200006f          	j	ffffffe000201b3c <schedule+0x170>
    for(i=1;i<NR_TASKS;i++)
ffffffe000201b20:	fec42783          	lw	a5,-20(s0)
ffffffe000201b24:	0017879b          	addiw	a5,a5,1
ffffffe000201b28:	fef42623          	sw	a5,-20(s0)
ffffffe000201b2c:	fec42783          	lw	a5,-20(s0)
ffffffe000201b30:	0007871b          	sext.w	a4,a5
ffffffe000201b34:	00400793          	li	a5,4
ffffffe000201b38:	fce7d0e3          	bge	a5,a4,ffffffe000201af8 <schedule+0x12c>
        }
    }
    if(all_zero)
ffffffe000201b3c:	fe344783          	lbu	a5,-29(s0)
ffffffe000201b40:	0ff7f793          	zext.b	a5,a5
ffffffe000201b44:	0c078463          	beqz	a5,ffffffe000201c0c <schedule+0x240>
    {
        printk("\n");
ffffffe000201b48:	00002517          	auipc	a0,0x2
ffffffe000201b4c:	67050513          	addi	a0,a0,1648 # ffffffe0002041b8 <_srodata+0x1b8>
ffffffe000201b50:	701010ef          	jal	ffffffe000203a50 <printk>
        for(i=1;i<NR_TASKS;i++)
ffffffe000201b54:	00100793          	li	a5,1
ffffffe000201b58:	fef42623          	sw	a5,-20(s0)
ffffffe000201b5c:	0980006f          	j	ffffffe000201bf4 <schedule+0x228>
        {
            task[i]->counter=task[i]->priority;
ffffffe000201b60:	00007717          	auipc	a4,0x7
ffffffe000201b64:	4d070713          	addi	a4,a4,1232 # ffffffe000209030 <task>
ffffffe000201b68:	fec42783          	lw	a5,-20(s0)
ffffffe000201b6c:	00379793          	slli	a5,a5,0x3
ffffffe000201b70:	00f707b3          	add	a5,a4,a5
ffffffe000201b74:	0007b703          	ld	a4,0(a5)
ffffffe000201b78:	00007697          	auipc	a3,0x7
ffffffe000201b7c:	4b868693          	addi	a3,a3,1208 # ffffffe000209030 <task>
ffffffe000201b80:	fec42783          	lw	a5,-20(s0)
ffffffe000201b84:	00379793          	slli	a5,a5,0x3
ffffffe000201b88:	00f687b3          	add	a5,a3,a5
ffffffe000201b8c:	0007b783          	ld	a5,0(a5)
ffffffe000201b90:	01073703          	ld	a4,16(a4)
ffffffe000201b94:	00e7b423          	sd	a4,8(a5)
            printk(PURPLE"SET [PID = %d PRIORITY = %d COUNTER = %d]\n"CLEAR,i,task[i]->priority,task[i]->counter);
ffffffe000201b98:	00007717          	auipc	a4,0x7
ffffffe000201b9c:	49870713          	addi	a4,a4,1176 # ffffffe000209030 <task>
ffffffe000201ba0:	fec42783          	lw	a5,-20(s0)
ffffffe000201ba4:	00379793          	slli	a5,a5,0x3
ffffffe000201ba8:	00f707b3          	add	a5,a4,a5
ffffffe000201bac:	0007b783          	ld	a5,0(a5)
ffffffe000201bb0:	0107b603          	ld	a2,16(a5)
ffffffe000201bb4:	00007717          	auipc	a4,0x7
ffffffe000201bb8:	47c70713          	addi	a4,a4,1148 # ffffffe000209030 <task>
ffffffe000201bbc:	fec42783          	lw	a5,-20(s0)
ffffffe000201bc0:	00379793          	slli	a5,a5,0x3
ffffffe000201bc4:	00f707b3          	add	a5,a4,a5
ffffffe000201bc8:	0007b783          	ld	a5,0(a5)
ffffffe000201bcc:	0087b703          	ld	a4,8(a5)
ffffffe000201bd0:	fec42783          	lw	a5,-20(s0)
ffffffe000201bd4:	00070693          	mv	a3,a4
ffffffe000201bd8:	00078593          	mv	a1,a5
ffffffe000201bdc:	00002517          	auipc	a0,0x2
ffffffe000201be0:	5e450513          	addi	a0,a0,1508 # ffffffe0002041c0 <_srodata+0x1c0>
ffffffe000201be4:	66d010ef          	jal	ffffffe000203a50 <printk>
        for(i=1;i<NR_TASKS;i++)
ffffffe000201be8:	fec42783          	lw	a5,-20(s0)
ffffffe000201bec:	0017879b          	addiw	a5,a5,1
ffffffe000201bf0:	fef42623          	sw	a5,-20(s0)
ffffffe000201bf4:	fec42783          	lw	a5,-20(s0)
ffffffe000201bf8:	0007871b          	sext.w	a4,a5
ffffffe000201bfc:	00400793          	li	a5,4
ffffffe000201c00:	f6e7d0e3          	bge	a5,a4,ffffffe000201b60 <schedule+0x194>
        }
        schedule();     // 设置完后需要重新进行调度
ffffffe000201c04:	dc9ff0ef          	jal	ffffffe0002019cc <schedule>
        // 最后通过 switch_to 切换到下一个线程
        // printk("sssswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n",task[max_index]->pid,task[max_index]->priority,task[max_index]->counter);
        switch_to(task[max_index]);
    }

    return;
ffffffe000201c08:	0280006f          	j	ffffffe000201c30 <schedule+0x264>
        switch_to(task[max_index]);
ffffffe000201c0c:	00007717          	auipc	a4,0x7
ffffffe000201c10:	42470713          	addi	a4,a4,1060 # ffffffe000209030 <task>
ffffffe000201c14:	fe842783          	lw	a5,-24(s0)
ffffffe000201c18:	00379793          	slli	a5,a5,0x3
ffffffe000201c1c:	00f707b3          	add	a5,a4,a5
ffffffe000201c20:	0007b783          	ld	a5,0(a5)
ffffffe000201c24:	00078513          	mv	a0,a5
ffffffe000201c28:	c71ff0ef          	jal	ffffffe000201898 <switch_to>
    return;
ffffffe000201c2c:	00000013          	nop
ffffffe000201c30:	01813083          	ld	ra,24(sp)
ffffffe000201c34:	01013403          	ld	s0,16(sp)
ffffffe000201c38:	02010113          	addi	sp,sp,32
ffffffe000201c3c:	00008067          	ret

ffffffe000201c40 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201c40:	f8010113          	addi	sp,sp,-128
ffffffe000201c44:	06813c23          	sd	s0,120(sp)
ffffffe000201c48:	06913823          	sd	s1,112(sp)
ffffffe000201c4c:	07213423          	sd	s2,104(sp)
ffffffe000201c50:	07313023          	sd	s3,96(sp)
ffffffe000201c54:	08010413          	addi	s0,sp,128
ffffffe000201c58:	faa43c23          	sd	a0,-72(s0)
ffffffe000201c5c:	fab43823          	sd	a1,-80(s0)
ffffffe000201c60:	fac43423          	sd	a2,-88(s0)
ffffffe000201c64:	fad43023          	sd	a3,-96(s0)
ffffffe000201c68:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201c6c:	f8f43823          	sd	a5,-112(s0)
ffffffe000201c70:	f9043423          	sd	a6,-120(s0)
ffffffe000201c74:	f9143023          	sd	a7,-128(s0)
    struct sbiret result;   //用 sbiret 来接受两个返回值
    
    __asm__ volatile ( 
ffffffe000201c78:	fb843e03          	ld	t3,-72(s0)
ffffffe000201c7c:	fb043e83          	ld	t4,-80(s0)
ffffffe000201c80:	f8043f03          	ld	t5,-128(s0)
ffffffe000201c84:	f8843f83          	ld	t6,-120(s0)
ffffffe000201c88:	f9043283          	ld	t0,-112(s0)
ffffffe000201c8c:	f9843483          	ld	s1,-104(s0)
ffffffe000201c90:	fa043903          	ld	s2,-96(s0)
ffffffe000201c94:	fa843983          	ld	s3,-88(s0)
ffffffe000201c98:	000e0893          	mv	a7,t3
ffffffe000201c9c:	000e8813          	mv	a6,t4
ffffffe000201ca0:	000f0793          	mv	a5,t5
ffffffe000201ca4:	000f8713          	mv	a4,t6
ffffffe000201ca8:	00028693          	mv	a3,t0
ffffffe000201cac:	00048613          	mv	a2,s1
ffffffe000201cb0:	00090593          	mv	a1,s2
ffffffe000201cb4:	00098513          	mv	a0,s3
ffffffe000201cb8:	00000073          	ecall
ffffffe000201cbc:	00050e93          	mv	t4,a0
ffffffe000201cc0:	00058e13          	mv	t3,a1
ffffffe000201cc4:	fdd43023          	sd	t4,-64(s0)
ffffffe000201cc8:	fdc43423          	sd	t3,-56(s0)
        :[error]"=r"(result.error),[value]"=r"(result.value)
        :[eid]"r"(eid),[fid]"r"(fid),[arg5]"r"(arg5),[arg4]"r"(arg4),[arg3]"r"(arg3),[arg2]"r"(arg2),[arg1]"r"(arg1),[arg0]"r"(arg0)
        :"a0","a1","a2","a3","a4","a5","a6","a7"
    );

    return result;
ffffffe000201ccc:	fc043783          	ld	a5,-64(s0)
ffffffe000201cd0:	fcf43823          	sd	a5,-48(s0)
ffffffe000201cd4:	fc843783          	ld	a5,-56(s0)
ffffffe000201cd8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201cdc:	fd043703          	ld	a4,-48(s0)
ffffffe000201ce0:	fd843783          	ld	a5,-40(s0)
ffffffe000201ce4:	00070313          	mv	t1,a4
ffffffe000201ce8:	00078393          	mv	t2,a5
ffffffe000201cec:	00030713          	mv	a4,t1
ffffffe000201cf0:	00038793          	mv	a5,t2
}
ffffffe000201cf4:	00070513          	mv	a0,a4
ffffffe000201cf8:	00078593          	mv	a1,a5
ffffffe000201cfc:	07813403          	ld	s0,120(sp)
ffffffe000201d00:	07013483          	ld	s1,112(sp)
ffffffe000201d04:	06813903          	ld	s2,104(sp)
ffffffe000201d08:	06013983          	ld	s3,96(sp)
ffffffe000201d0c:	08010113          	addi	sp,sp,128
ffffffe000201d10:	00008067          	ret

ffffffe000201d14 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201d14:	fb010113          	addi	sp,sp,-80
ffffffe000201d18:	04113423          	sd	ra,72(sp)
ffffffe000201d1c:	04813023          	sd	s0,64(sp)
ffffffe000201d20:	03213c23          	sd	s2,56(sp)
ffffffe000201d24:	03313823          	sd	s3,48(sp)
ffffffe000201d28:	05010413          	addi	s0,sp,80
ffffffe000201d2c:	00050793          	mv	a5,a0
ffffffe000201d30:	faf40fa3          	sb	a5,-65(s0)
    struct sbiret result=sbi_ecall(SBI_EID_DEBUG_CONSOLE_WRITE_BYTE,SBI_FID_DEBUG_CONSOLE_WRITE_BYTE,byte,0,0,0,0,0);
ffffffe000201d34:	fbf44603          	lbu	a2,-65(s0)
ffffffe000201d38:	00000893          	li	a7,0
ffffffe000201d3c:	00000813          	li	a6,0
ffffffe000201d40:	00000793          	li	a5,0
ffffffe000201d44:	00000713          	li	a4,0
ffffffe000201d48:	00000693          	li	a3,0
ffffffe000201d4c:	00200593          	li	a1,2
ffffffe000201d50:	44424537          	lui	a0,0x44424
ffffffe000201d54:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201d58:	ee9ff0ef          	jal	ffffffe000201c40 <sbi_ecall>
ffffffe000201d5c:	00050713          	mv	a4,a0
ffffffe000201d60:	00058793          	mv	a5,a1
ffffffe000201d64:	fce43023          	sd	a4,-64(s0)
ffffffe000201d68:	fcf43423          	sd	a5,-56(s0)
    return result;
ffffffe000201d6c:	fc043783          	ld	a5,-64(s0)
ffffffe000201d70:	fcf43823          	sd	a5,-48(s0)
ffffffe000201d74:	fc843783          	ld	a5,-56(s0)
ffffffe000201d78:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201d7c:	fd043703          	ld	a4,-48(s0)
ffffffe000201d80:	fd843783          	ld	a5,-40(s0)
ffffffe000201d84:	00070913          	mv	s2,a4
ffffffe000201d88:	00078993          	mv	s3,a5
ffffffe000201d8c:	00090713          	mv	a4,s2
ffffffe000201d90:	00098793          	mv	a5,s3
}
ffffffe000201d94:	00070513          	mv	a0,a4
ffffffe000201d98:	00078593          	mv	a1,a5
ffffffe000201d9c:	04813083          	ld	ra,72(sp)
ffffffe000201da0:	04013403          	ld	s0,64(sp)
ffffffe000201da4:	03813903          	ld	s2,56(sp)
ffffffe000201da8:	03013983          	ld	s3,48(sp)
ffffffe000201dac:	05010113          	addi	sp,sp,80
ffffffe000201db0:	00008067          	ret

ffffffe000201db4 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201db4:	fb010113          	addi	sp,sp,-80
ffffffe000201db8:	04113423          	sd	ra,72(sp)
ffffffe000201dbc:	04813023          	sd	s0,64(sp)
ffffffe000201dc0:	03213c23          	sd	s2,56(sp)
ffffffe000201dc4:	03313823          	sd	s3,48(sp)
ffffffe000201dc8:	05010413          	addi	s0,sp,80
ffffffe000201dcc:	00050793          	mv	a5,a0
ffffffe000201dd0:	00058713          	mv	a4,a1
ffffffe000201dd4:	faf42e23          	sw	a5,-68(s0)
ffffffe000201dd8:	00070793          	mv	a5,a4
ffffffe000201ddc:	faf42c23          	sw	a5,-72(s0)
    struct sbiret result=sbi_ecall(SBI_EID_RESET_TYPE_SHUTDOWN,SBI_SRST_RESET_REASON_NONE,reset_type,reset_reason,0,0,0,0);
ffffffe000201de0:	fbc46603          	lwu	a2,-68(s0)
ffffffe000201de4:	fb846683          	lwu	a3,-72(s0)
ffffffe000201de8:	00000893          	li	a7,0
ffffffe000201dec:	00000813          	li	a6,0
ffffffe000201df0:	00000793          	li	a5,0
ffffffe000201df4:	00000713          	li	a4,0
ffffffe000201df8:	00000593          	li	a1,0
ffffffe000201dfc:	53525537          	lui	a0,0x53525
ffffffe000201e00:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000201e04:	e3dff0ef          	jal	ffffffe000201c40 <sbi_ecall>
ffffffe000201e08:	00050713          	mv	a4,a0
ffffffe000201e0c:	00058793          	mv	a5,a1
ffffffe000201e10:	fce43023          	sd	a4,-64(s0)
ffffffe000201e14:	fcf43423          	sd	a5,-56(s0)
    return result;
ffffffe000201e18:	fc043783          	ld	a5,-64(s0)
ffffffe000201e1c:	fcf43823          	sd	a5,-48(s0)
ffffffe000201e20:	fc843783          	ld	a5,-56(s0)
ffffffe000201e24:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201e28:	fd043703          	ld	a4,-48(s0)
ffffffe000201e2c:	fd843783          	ld	a5,-40(s0)
ffffffe000201e30:	00070913          	mv	s2,a4
ffffffe000201e34:	00078993          	mv	s3,a5
ffffffe000201e38:	00090713          	mv	a4,s2
ffffffe000201e3c:	00098793          	mv	a5,s3
}
ffffffe000201e40:	00070513          	mv	a0,a4
ffffffe000201e44:	00078593          	mv	a1,a5
ffffffe000201e48:	04813083          	ld	ra,72(sp)
ffffffe000201e4c:	04013403          	ld	s0,64(sp)
ffffffe000201e50:	03813903          	ld	s2,56(sp)
ffffffe000201e54:	03013983          	ld	s3,48(sp)
ffffffe000201e58:	05010113          	addi	sp,sp,80
ffffffe000201e5c:	00008067          	ret

ffffffe000201e60 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value)
{
ffffffe000201e60:	fa010113          	addi	sp,sp,-96
ffffffe000201e64:	04113c23          	sd	ra,88(sp)
ffffffe000201e68:	04813823          	sd	s0,80(sp)
ffffffe000201e6c:	05213423          	sd	s2,72(sp)
ffffffe000201e70:	05313023          	sd	s3,64(sp)
ffffffe000201e74:	06010413          	addi	s0,sp,96
ffffffe000201e78:	faa43423          	sd	a0,-88(s0)
    unsigned long time_final;
    __asm__ volatile(
ffffffe000201e7c:	c01022f3          	rdtime	t0
ffffffe000201e80:	00989337          	lui	t1,0x989
ffffffe000201e84:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
ffffffe000201e88:	006282b3          	add	t0,t0,t1
ffffffe000201e8c:	00028793          	mv	a5,t0
ffffffe000201e90:	fcf43c23          	sd	a5,-40(s0)
        "add t0,t0,t1 \n"
        "mv %[time_final],t0 \n"
        : [time_final]"=r"(time_final)
    );

    struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,time_final,0,0,0,0,0);
ffffffe000201e94:	00000893          	li	a7,0
ffffffe000201e98:	00000813          	li	a6,0
ffffffe000201e9c:	00000793          	li	a5,0
ffffffe000201ea0:	00000713          	li	a4,0
ffffffe000201ea4:	00000693          	li	a3,0
ffffffe000201ea8:	fd843603          	ld	a2,-40(s0)
ffffffe000201eac:	00000593          	li	a1,0
ffffffe000201eb0:	54495537          	lui	a0,0x54495
ffffffe000201eb4:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201eb8:	d89ff0ef          	jal	ffffffe000201c40 <sbi_ecall>
ffffffe000201ebc:	00050713          	mv	a4,a0
ffffffe000201ec0:	00058793          	mv	a5,a1
ffffffe000201ec4:	fae43c23          	sd	a4,-72(s0)
ffffffe000201ec8:	fcf43023          	sd	a5,-64(s0)
    //struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,stime_value,0,0,0,0,0);
    return result;
ffffffe000201ecc:	fb843783          	ld	a5,-72(s0)
ffffffe000201ed0:	fcf43423          	sd	a5,-56(s0)
ffffffe000201ed4:	fc043783          	ld	a5,-64(s0)
ffffffe000201ed8:	fcf43823          	sd	a5,-48(s0)
ffffffe000201edc:	fc843703          	ld	a4,-56(s0)
ffffffe000201ee0:	fd043783          	ld	a5,-48(s0)
ffffffe000201ee4:	00070913          	mv	s2,a4
ffffffe000201ee8:	00078993          	mv	s3,a5
ffffffe000201eec:	00090713          	mv	a4,s2
ffffffe000201ef0:	00098793          	mv	a5,s3
ffffffe000201ef4:	00070513          	mv	a0,a4
ffffffe000201ef8:	00078593          	mv	a1,a5
ffffffe000201efc:	05813083          	ld	ra,88(sp)
ffffffe000201f00:	05013403          	ld	s0,80(sp)
ffffffe000201f04:	04813903          	ld	s2,72(sp)
ffffffe000201f08:	04013983          	ld	s3,64(sp)
ffffffe000201f0c:	06010113          	addi	sp,sp,96
ffffffe000201f10:	00008067          	ret

ffffffe000201f14 <sys_write>:
#include "syscall.h"

// 将用户态传递的字符串打印到屏幕上
// fd 为标准输出即 1，buf 为用户需要打印的起始地址，count 为字符串长度，返回打印的字符数；
void sys_write(unsigned int fd, const char* buf, size_t count, struct pt_regs *regs)  
{
ffffffe000201f14:	fc010113          	addi	sp,sp,-64
ffffffe000201f18:	02113c23          	sd	ra,56(sp)
ffffffe000201f1c:	02813823          	sd	s0,48(sp)
ffffffe000201f20:	04010413          	addi	s0,sp,64
ffffffe000201f24:	00050793          	mv	a5,a0
ffffffe000201f28:	fcb43823          	sd	a1,-48(s0)
ffffffe000201f2c:	fcc43423          	sd	a2,-56(s0)
ffffffe000201f30:	fcd43023          	sd	a3,-64(s0)
ffffffe000201f34:	fcf42e23          	sw	a5,-36(s0)
    if(fd == 1)
ffffffe000201f38:	fdc42783          	lw	a5,-36(s0)
ffffffe000201f3c:	0007871b          	sext.w	a4,a5
ffffffe000201f40:	00100793          	li	a5,1
ffffffe000201f44:	06f71063          	bne	a4,a5,ffffffe000201fa4 <sys_write+0x90>
    {
        uint64_t result;
        for(size_t i=0;i<count;i++)
ffffffe000201f48:	fe043023          	sd	zero,-32(s0)
ffffffe000201f4c:	0400006f          	j	ffffffe000201f8c <sys_write+0x78>
        {
            printk("%c", buf[i]);
ffffffe000201f50:	fd043703          	ld	a4,-48(s0)
ffffffe000201f54:	fe043783          	ld	a5,-32(s0)
ffffffe000201f58:	00f707b3          	add	a5,a4,a5
ffffffe000201f5c:	0007c783          	lbu	a5,0(a5)
ffffffe000201f60:	0007879b          	sext.w	a5,a5
ffffffe000201f64:	00078593          	mv	a1,a5
ffffffe000201f68:	00002517          	auipc	a0,0x2
ffffffe000201f6c:	29050513          	addi	a0,a0,656 # ffffffe0002041f8 <_srodata+0x1f8>
ffffffe000201f70:	2e1010ef          	jal	ffffffe000203a50 <printk>
            result++;
ffffffe000201f74:	fe843783          	ld	a5,-24(s0)
ffffffe000201f78:	00178793          	addi	a5,a5,1
ffffffe000201f7c:	fef43423          	sd	a5,-24(s0)
        for(size_t i=0;i<count;i++)
ffffffe000201f80:	fe043783          	ld	a5,-32(s0)
ffffffe000201f84:	00178793          	addi	a5,a5,1
ffffffe000201f88:	fef43023          	sd	a5,-32(s0)
ffffffe000201f8c:	fe043703          	ld	a4,-32(s0)
ffffffe000201f90:	fc843783          	ld	a5,-56(s0)
ffffffe000201f94:	faf76ee3          	bltu	a4,a5,ffffffe000201f50 <sys_write+0x3c>
        }
        regs->x[10] = result;
ffffffe000201f98:	fc043783          	ld	a5,-64(s0)
ffffffe000201f9c:	fe843703          	ld	a4,-24(s0)
ffffffe000201fa0:	04e7b823          	sd	a4,80(a5)
    }
}
ffffffe000201fa4:	00000013          	nop
ffffffe000201fa8:	03813083          	ld	ra,56(sp)
ffffffe000201fac:	03013403          	ld	s0,48(sp)
ffffffe000201fb0:	04010113          	addi	sp,sp,64
ffffffe000201fb4:	00008067          	ret

ffffffe000201fb8 <sys_getpid>:

// 从 current 中获取当前的 pid 放入 a0 中返回，无参数
void sys_getpid(struct pt_regs *regs)   
{
ffffffe000201fb8:	fe010113          	addi	sp,sp,-32
ffffffe000201fbc:	00813c23          	sd	s0,24(sp)
ffffffe000201fc0:	02010413          	addi	s0,sp,32
ffffffe000201fc4:	fea43423          	sd	a0,-24(s0)
    regs->x[10] = current->pid;
ffffffe000201fc8:	00007797          	auipc	a5,0x7
ffffffe000201fcc:	04878793          	addi	a5,a5,72 # ffffffe000209010 <current>
ffffffe000201fd0:	0007b783          	ld	a5,0(a5)
ffffffe000201fd4:	0187b703          	ld	a4,24(a5)
ffffffe000201fd8:	fe843783          	ld	a5,-24(s0)
ffffffe000201fdc:	04e7b823          	sd	a4,80(a5)
ffffffe000201fe0:	00000013          	nop
ffffffe000201fe4:	01813403          	ld	s0,24(sp)
ffffffe000201fe8:	02010113          	addi	sp,sp,32
ffffffe000201fec:	00008067          	ret

ffffffe000201ff0 <do_page_fault>:
#include "string.h"

extern create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);
extern char _sramdisk[];

void do_page_fault(struct pt_regs *regs) {
ffffffe000201ff0:	f8010113          	addi	sp,sp,-128
ffffffe000201ff4:	06113c23          	sd	ra,120(sp)
ffffffe000201ff8:	06813823          	sd	s0,112(sp)
ffffffe000201ffc:	08010413          	addi	s0,sp,128
ffffffe000202000:	f8a43423          	sd	a0,-120(s0)
    // 1.通过 stval 获得访问出错的虚拟内存地址（Bad Address）
    uint64_t stval = regs->stval; // 取指时的虚拟地址
ffffffe000202004:	f8843783          	ld	a5,-120(s0)
ffffffe000202008:	1107b783          	ld	a5,272(a5)
ffffffe00020200c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t scause = csr_read(scause);
ffffffe000202010:	142027f3          	csrr	a5,scause
ffffffe000202014:	fcf43823          	sd	a5,-48(s0)
ffffffe000202018:	fd043783          	ld	a5,-48(s0)
ffffffe00020201c:	fcf43423          	sd	a5,-56(s0)
    printk(GREEN"[trap.c,do_page_fault] [PID = %d PC = 0x%lx] valid page fault at `0x%lx` with cause %d\n"CLEAR,current->pid,regs->sepc,stval,scause);
ffffffe000202020:	00007797          	auipc	a5,0x7
ffffffe000202024:	ff078793          	addi	a5,a5,-16 # ffffffe000209010 <current>
ffffffe000202028:	0007b783          	ld	a5,0(a5)
ffffffe00020202c:	0187b583          	ld	a1,24(a5)
ffffffe000202030:	f8843783          	ld	a5,-120(s0)
ffffffe000202034:	1007b783          	ld	a5,256(a5)
ffffffe000202038:	fc843703          	ld	a4,-56(s0)
ffffffe00020203c:	fd843683          	ld	a3,-40(s0)
ffffffe000202040:	00078613          	mv	a2,a5
ffffffe000202044:	00002517          	auipc	a0,0x2
ffffffe000202048:	1bc50513          	addi	a0,a0,444 # ffffffe000204200 <_srodata+0x200>
ffffffe00020204c:	205010ef          	jal	ffffffe000203a50 <printk>

    // 2.通过 find_vma() 查找 bad address 是否在某个 vma 中
    struct vm_area_struct *vma = find_vma(&current->mm, stval);
ffffffe000202050:	00007797          	auipc	a5,0x7
ffffffe000202054:	fc078793          	addi	a5,a5,-64 # ffffffe000209010 <current>
ffffffe000202058:	0007b783          	ld	a5,0(a5)
ffffffe00020205c:	0b078793          	addi	a5,a5,176
ffffffe000202060:	fd843583          	ld	a1,-40(s0)
ffffffe000202064:	00078513          	mv	a0,a5
ffffffe000202068:	bb1fe0ef          	jal	ffffffe000200c18 <find_vma>
ffffffe00020206c:	00050793          	mv	a5,a0
ffffffe000202070:	fcf43023          	sd	a5,-64(s0)
    
    if (!vma) { // 如果不在，则出现非预期错误，可以通过 Err 宏输出错误信息
ffffffe000202074:	fc043783          	ld	a5,-64(s0)
ffffffe000202078:	02079863          	bnez	a5,ffffffe0002020a8 <do_page_fault+0xb8>
        Err("[S] Page Fault: Bad Address 0x%lx\n", stval);
ffffffe00020207c:	fd843703          	ld	a4,-40(s0)
ffffffe000202080:	00002697          	auipc	a3,0x2
ffffffe000202084:	4a868693          	addi	a3,a3,1192 # ffffffe000204528 <__func__.1>
ffffffe000202088:	01600613          	li	a2,22
ffffffe00020208c:	00002597          	auipc	a1,0x2
ffffffe000202090:	1dc58593          	addi	a1,a1,476 # ffffffe000204268 <_srodata+0x268>
ffffffe000202094:	00002517          	auipc	a0,0x2
ffffffe000202098:	1dc50513          	addi	a0,a0,476 # ffffffe000204270 <_srodata+0x270>
ffffffe00020209c:	1b5010ef          	jal	ffffffe000203a50 <printk>
ffffffe0002020a0:	00000013          	nop
ffffffe0002020a4:	ffdff06f          	j	ffffffe0002020a0 <do_page_fault+0xb0>
        return;
    } else { // 如果在，则根据 vma 的 flags 权限判断当前 page fault 是否合法
        if ((scause == 0xc && !(vma->vm_flags & VM_EXEC)) ||  // instruction
ffffffe0002020a8:	fc843703          	ld	a4,-56(s0)
ffffffe0002020ac:	00c00793          	li	a5,12
ffffffe0002020b0:	00f71a63          	bne	a4,a5,ffffffe0002020c4 <do_page_fault+0xd4>
ffffffe0002020b4:	fc043783          	ld	a5,-64(s0)
ffffffe0002020b8:	0287b783          	ld	a5,40(a5)
ffffffe0002020bc:	0087f793          	andi	a5,a5,8
ffffffe0002020c0:	02078e63          	beqz	a5,ffffffe0002020fc <do_page_fault+0x10c>
ffffffe0002020c4:	fc843703          	ld	a4,-56(s0)
ffffffe0002020c8:	00d00793          	li	a5,13
ffffffe0002020cc:	00f71a63          	bne	a4,a5,ffffffe0002020e0 <do_page_fault+0xf0>
            (scause == 0xd && !(vma->vm_flags & VM_READ)) ||  // load
ffffffe0002020d0:	fc043783          	ld	a5,-64(s0)
ffffffe0002020d4:	0287b783          	ld	a5,40(a5)
ffffffe0002020d8:	0027f793          	andi	a5,a5,2
ffffffe0002020dc:	02078063          	beqz	a5,ffffffe0002020fc <do_page_fault+0x10c>
ffffffe0002020e0:	fc843703          	ld	a4,-56(s0)
ffffffe0002020e4:	00f00793          	li	a5,15
ffffffe0002020e8:	04f71063          	bne	a4,a5,ffffffe000202128 <do_page_fault+0x138>
            (scause == 0xf && !(vma->vm_flags & VM_WRITE))) { // store
ffffffe0002020ec:	fc043783          	ld	a5,-64(s0)
ffffffe0002020f0:	0287b783          	ld	a5,40(a5)
ffffffe0002020f4:	0047f793          	andi	a5,a5,4
ffffffe0002020f8:	02079863          	bnez	a5,ffffffe000202128 <do_page_fault+0x138>
            Err("[S] Page Fault: Illegal page fault to Bad Address 0x%lx\n", stval);
ffffffe0002020fc:	fd843703          	ld	a4,-40(s0)
ffffffe000202100:	00002697          	auipc	a3,0x2
ffffffe000202104:	42868693          	addi	a3,a3,1064 # ffffffe000204528 <__func__.1>
ffffffe000202108:	01c00613          	li	a2,28
ffffffe00020210c:	00002597          	auipc	a1,0x2
ffffffe000202110:	15c58593          	addi	a1,a1,348 # ffffffe000204268 <_srodata+0x268>
ffffffe000202114:	00002517          	auipc	a0,0x2
ffffffe000202118:	19c50513          	addi	a0,a0,412 # ffffffe0002042b0 <_srodata+0x2b0>
ffffffe00020211c:	135010ef          	jal	ffffffe000203a50 <printk>
ffffffe000202120:	00000013          	nop
ffffffe000202124:	ffdff06f          	j	ffffffe000202120 <do_page_fault+0x130>
        }
    }

    // 其他情况合法，按接下来的流程创建映射
    // 3.分配一个页，接下来要将这个页映射到对应的用户地址空间
    uint64_t page = alloc_page();
ffffffe000202128:	971fe0ef          	jal	ffffffe000200a98 <alloc_page>
ffffffe00020212c:	00050793          	mv	a5,a0
ffffffe000202130:	faf43c23          	sd	a5,-72(s0)

    // 4.初始化匿名页
    if (vma->vm_flags & VM_ANON) { // 如果是匿名空间，则清零并直接映射即可
ffffffe000202134:	fc043783          	ld	a5,-64(s0)
ffffffe000202138:	0287b783          	ld	a5,40(a5)
ffffffe00020213c:	0017f793          	andi	a5,a5,1
ffffffe000202140:	00078e63          	beqz	a5,ffffffe00020215c <do_page_fault+0x16c>
        memset((void *)page, 0, PGSIZE);
ffffffe000202144:	fb843783          	ld	a5,-72(s0)
ffffffe000202148:	00001637          	lui	a2,0x1
ffffffe00020214c:	00000593          	li	a1,0
ffffffe000202150:	00078513          	mv	a0,a5
ffffffe000202154:	21d010ef          	jal	ffffffe000203b70 <memset>
ffffffe000202158:	1100006f          	j	ffffffe000202268 <do_page_fault+0x278>
    } else { // 如果不是匿名空间，则需要从 ELF 中读取数据，填充后映射到用户空间
        uint64_t seg_start = (uint64_t)_sramdisk + vma->vm_pgoff; // 段在物理内存中的起始地址
ffffffe00020215c:	fc043783          	ld	a5,-64(s0)
ffffffe000202160:	0307b703          	ld	a4,48(a5)
ffffffe000202164:	00004797          	auipc	a5,0x4
ffffffe000202168:	e9c78793          	addi	a5,a5,-356 # ffffffe000206000 <_sramdisk>
ffffffe00020216c:	00f707b3          	add	a5,a4,a5
ffffffe000202170:	faf43823          	sd	a5,-80(s0)
        uint64_t seg_end = seg_start + vma->vm_filesz;           // 段在物理内存中的结束地址
ffffffe000202174:	fc043783          	ld	a5,-64(s0)
ffffffe000202178:	0387b783          	ld	a5,56(a5)
ffffffe00020217c:	fb043703          	ld	a4,-80(s0)
ffffffe000202180:	00f707b3          	add	a5,a4,a5
ffffffe000202184:	faf43423          	sd	a5,-88(s0)
        uint64_t stval_start = seg_start + PGROUNDDOWN(stval) - vma->vm_start; // 错误发生页的起始地址
ffffffe000202188:	fd843703          	ld	a4,-40(s0)
ffffffe00020218c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202190:	00f77733          	and	a4,a4,a5
ffffffe000202194:	fb043783          	ld	a5,-80(s0)
ffffffe000202198:	00f70733          	add	a4,a4,a5
ffffffe00020219c:	fc043783          	ld	a5,-64(s0)
ffffffe0002021a0:	0087b783          	ld	a5,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe0002021a4:	40f707b3          	sub	a5,a4,a5
ffffffe0002021a8:	faf43023          	sd	a5,-96(s0)

        uint64_t offset = 0; // 偏移 -- 确定从当前页的哪个位置开始填充
ffffffe0002021ac:	fe043423          	sd	zero,-24(s0)
        if (PGROUNDDOWN(stval) == PGROUNDDOWN(seg_start)) { // 同页，从 stval 错误发生的地方开始复制
ffffffe0002021b0:	fd843703          	ld	a4,-40(s0)
ffffffe0002021b4:	fb043783          	ld	a5,-80(s0)
ffffffe0002021b8:	00f74733          	xor	a4,a4,a5
ffffffe0002021bc:	000017b7          	lui	a5,0x1
ffffffe0002021c0:	00f77c63          	bgeu	a4,a5,ffffffe0002021d8 <do_page_fault+0x1e8>
            offset = stval & (PGSIZE - 1);
ffffffe0002021c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002021c8:	000017b7          	lui	a5,0x1
ffffffe0002021cc:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002021d0:	00f777b3          	and	a5,a4,a5
ffffffe0002021d4:	fef43423          	sd	a5,-24(s0)
        }

        uint64_t valid_seg = 0; // 计算有效段大小
ffffffe0002021d8:	fe043023          	sd	zero,-32(s0)
        if (seg_end > stval_start && seg_end <= stval_start + PGSIZE) {
ffffffe0002021dc:	fa843703          	ld	a4,-88(s0)
ffffffe0002021e0:	fa043783          	ld	a5,-96(s0)
ffffffe0002021e4:	02e7fa63          	bgeu	a5,a4,ffffffe000202218 <do_page_fault+0x228>
ffffffe0002021e8:	fa043703          	ld	a4,-96(s0)
ffffffe0002021ec:	000017b7          	lui	a5,0x1
ffffffe0002021f0:	00f707b3          	add	a5,a4,a5
ffffffe0002021f4:	fa843703          	ld	a4,-88(s0)
ffffffe0002021f8:	02e7e063          	bltu	a5,a4,ffffffe000202218 <do_page_fault+0x228>
            valid_seg = seg_end - stval_start - offset;
ffffffe0002021fc:	fa843703          	ld	a4,-88(s0)
ffffffe000202200:	fa043783          	ld	a5,-96(s0)
ffffffe000202204:	40f70733          	sub	a4,a4,a5
ffffffe000202208:	fe843783          	ld	a5,-24(s0)
ffffffe00020220c:	40f707b3          	sub	a5,a4,a5
ffffffe000202210:	fef43023          	sd	a5,-32(s0)
ffffffe000202214:	0280006f          	j	ffffffe00020223c <do_page_fault+0x24c>
        } else if (seg_end > stval_start + PGSIZE) {
ffffffe000202218:	fa043703          	ld	a4,-96(s0)
ffffffe00020221c:	000017b7          	lui	a5,0x1
ffffffe000202220:	00f707b3          	add	a5,a4,a5
ffffffe000202224:	fa843703          	ld	a4,-88(s0)
ffffffe000202228:	00e7fa63          	bgeu	a5,a4,ffffffe00020223c <do_page_fault+0x24c>
            valid_seg = PGSIZE - offset;
ffffffe00020222c:	00001737          	lui	a4,0x1
ffffffe000202230:	fe843783          	ld	a5,-24(s0)
ffffffe000202234:	40f707b3          	sub	a5,a4,a5
ffffffe000202238:	fef43023          	sd	a5,-32(s0)
        }

        if (valid_seg > 0) { // 进行数据拷贝
ffffffe00020223c:	fe043783          	ld	a5,-32(s0)
ffffffe000202240:	02078463          	beqz	a5,ffffffe000202268 <do_page_fault+0x278>
            memcpy((void *)(page + offset), (void *)stval_start, valid_seg);
ffffffe000202244:	fb843703          	ld	a4,-72(s0)
ffffffe000202248:	fe843783          	ld	a5,-24(s0)
ffffffe00020224c:	00f707b3          	add	a5,a4,a5
ffffffe000202250:	00078713          	mv	a4,a5
ffffffe000202254:	fa043783          	ld	a5,-96(s0)
ffffffe000202258:	fe043603          	ld	a2,-32(s0)
ffffffe00020225c:	00078593          	mv	a1,a5
ffffffe000202260:	00070513          	mv	a0,a4
ffffffe000202264:	b85fe0ef          	jal	ffffffe000200de8 <memcpy>
        }
    }

    // 5.映射页面到用户地址空间
    uint64_t perm = (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) | (1 << 0) | (1 << 4); // 添加权限
ffffffe000202268:	fc043783          	ld	a5,-64(s0)
ffffffe00020226c:	0287b783          	ld	a5,40(a5) # 1028 <PGSIZE+0x28>
ffffffe000202270:	00e7f793          	andi	a5,a5,14
ffffffe000202274:	0117e793          	ori	a5,a5,17
ffffffe000202278:	f8f43c23          	sd	a5,-104(s0)
    create_mapping(current->pgd, PGROUNDDOWN(stval), page - PA2VA_OFFSET, PGSIZE, perm);
ffffffe00020227c:	00007797          	auipc	a5,0x7
ffffffe000202280:	d9478793          	addi	a5,a5,-620 # ffffffe000209010 <current>
ffffffe000202284:	0007b783          	ld	a5,0(a5)
ffffffe000202288:	0a87b503          	ld	a0,168(a5)
ffffffe00020228c:	fd843703          	ld	a4,-40(s0)
ffffffe000202290:	fffff7b7          	lui	a5,0xfffff
ffffffe000202294:	00f775b3          	and	a1,a4,a5
ffffffe000202298:	fb843703          	ld	a4,-72(s0)
ffffffe00020229c:	04100793          	li	a5,65
ffffffe0002022a0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002022a4:	00f707b3          	add	a5,a4,a5
ffffffe0002022a8:	f9843703          	ld	a4,-104(s0)
ffffffe0002022ac:	000016b7          	lui	a3,0x1
ffffffe0002022b0:	00078613          	mv	a2,a5
ffffffe0002022b4:	6dc000ef          	jal	ffffffe000202990 <create_mapping>
}
ffffffe0002022b8:	07813083          	ld	ra,120(sp)
ffffffe0002022bc:	07013403          	ld	s0,112(sp)
ffffffe0002022c0:	08010113          	addi	sp,sp,128
ffffffe0002022c4:	00008067          	ret

ffffffe0002022c8 <trap_handler>:


void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
ffffffe0002022c8:	fd010113          	addi	sp,sp,-48
ffffffe0002022cc:	02113423          	sd	ra,40(sp)
ffffffe0002022d0:	02813023          	sd	s0,32(sp)
ffffffe0002022d4:	03010413          	addi	s0,sp,48
ffffffe0002022d8:	fea43423          	sd	a0,-24(s0)
ffffffe0002022dc:	feb43023          	sd	a1,-32(s0)
ffffffe0002022e0:	fcc43c23          	sd	a2,-40(s0)
    // uint64_t scause = csr_read(scause);
    // printk("scause: %lx\n", scause);
    // 通过 `scause` 判断 trap 类型
    
    if((scause>>63)==1) // interrupt=1
ffffffe0002022e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002022e8:	03f7d713          	srli	a4,a5,0x3f
ffffffe0002022ec:	00100793          	li	a5,1
ffffffe0002022f0:	0af71c63          	bne	a4,a5,ffffffe0002023a8 <trap_handler+0xe0>
    {
        // 如果是 interrupt 判断是否是 timer interrupt
        if(((scause<<1)>>1)==5)
ffffffe0002022f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002022f8:	fff00793          	li	a5,-1
ffffffe0002022fc:	0017d793          	srli	a5,a5,0x1
ffffffe000202300:	00f77733          	and	a4,a4,a5
ffffffe000202304:	00500793          	li	a5,5
ffffffe000202308:	00f71863          	bne	a4,a5,ffffffe000202318 <trap_handler+0x50>
        {
            // 通过 `clock_set_next_event()` 设置下一次时钟中断
            clock_set_next_event();
ffffffe00020230c:	928fe0ef          	jal	ffffffe000200434 <clock_set_next_event>
            do_timer();
ffffffe000202310:	e20ff0ef          	jal	ffffffe000201930 <do_timer>
        }else
        {
            Err("Reserved\n");
        }
    }
    return;
ffffffe000202314:	4000006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==1)
ffffffe000202318:	fe843703          	ld	a4,-24(s0)
ffffffe00020231c:	fff00793          	li	a5,-1
ffffffe000202320:	0017d793          	srli	a5,a5,0x1
ffffffe000202324:	00f77733          	and	a4,a4,a5
ffffffe000202328:	00100793          	li	a5,1
ffffffe00020232c:	00f71e63          	bne	a4,a5,ffffffe000202348 <trap_handler+0x80>
            printk("%s\n","[S] Supervisor Mode Software Interrupt");
ffffffe000202330:	00002597          	auipc	a1,0x2
ffffffe000202334:	fd058593          	addi	a1,a1,-48 # ffffffe000204300 <_srodata+0x300>
ffffffe000202338:	00002517          	auipc	a0,0x2
ffffffe00020233c:	ff050513          	addi	a0,a0,-16 # ffffffe000204328 <_srodata+0x328>
ffffffe000202340:	710010ef          	jal	ffffffe000203a50 <printk>
    return;
ffffffe000202344:	3d00006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==9)
ffffffe000202348:	fe843703          	ld	a4,-24(s0)
ffffffe00020234c:	fff00793          	li	a5,-1
ffffffe000202350:	0017d793          	srli	a5,a5,0x1
ffffffe000202354:	00f77733          	and	a4,a4,a5
ffffffe000202358:	00900793          	li	a5,9
ffffffe00020235c:	00f71e63          	bne	a4,a5,ffffffe000202378 <trap_handler+0xb0>
            printk("%s\n","[S] Supervisor Mode External Interrupt");
ffffffe000202360:	00002597          	auipc	a1,0x2
ffffffe000202364:	fd058593          	addi	a1,a1,-48 # ffffffe000204330 <_srodata+0x330>
ffffffe000202368:	00002517          	auipc	a0,0x2
ffffffe00020236c:	fc050513          	addi	a0,a0,-64 # ffffffe000204328 <_srodata+0x328>
ffffffe000202370:	6e0010ef          	jal	ffffffe000203a50 <printk>
    return;
ffffffe000202374:	3a00006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==13)
ffffffe000202378:	fe843703          	ld	a4,-24(s0)
ffffffe00020237c:	fff00793          	li	a5,-1
ffffffe000202380:	0017d793          	srli	a5,a5,0x1
ffffffe000202384:	00f77733          	and	a4,a4,a5
ffffffe000202388:	00d00793          	li	a5,13
ffffffe00020238c:	38f71463          	bne	a4,a5,ffffffe000202714 <trap_handler+0x44c>
            printk("%s\n","[S] Counter-overflow Interrupt");
ffffffe000202390:	00002597          	auipc	a1,0x2
ffffffe000202394:	fc858593          	addi	a1,a1,-56 # ffffffe000204358 <_srodata+0x358>
ffffffe000202398:	00002517          	auipc	a0,0x2
ffffffe00020239c:	f9050513          	addi	a0,a0,-112 # ffffffe000204328 <_srodata+0x328>
ffffffe0002023a0:	6b0010ef          	jal	ffffffe000203a50 <printk>
    return;
ffffffe0002023a4:	3700006f          	j	ffffffe000202714 <trap_handler+0x44c>
    }else if((scause>>63)==0)  //interrupt=0
ffffffe0002023a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002023ac:	3607c463          	bltz	a5,ffffffe000202714 <trap_handler+0x44c>
        if(((scause<<1)>>1)==8) 
ffffffe0002023b0:	fe843703          	ld	a4,-24(s0)
ffffffe0002023b4:	fff00793          	li	a5,-1
ffffffe0002023b8:	0017d793          	srli	a5,a5,0x1
ffffffe0002023bc:	00f77733          	and	a4,a4,a5
ffffffe0002023c0:	00800793          	li	a5,8
ffffffe0002023c4:	06f71c63          	bne	a4,a5,ffffffe00020243c <trap_handler+0x174>
            switch (regs->x[17])    // a7
ffffffe0002023c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002023cc:	0887b783          	ld	a5,136(a5) # fffffffffffff088 <VM_END+0xfffff088>
ffffffe0002023d0:	04000713          	li	a4,64
ffffffe0002023d4:	00e78863          	beq	a5,a4,ffffffe0002023e4 <trap_handler+0x11c>
ffffffe0002023d8:	0ac00713          	li	a4,172
ffffffe0002023dc:	02e78e63          	beq	a5,a4,ffffffe000202418 <trap_handler+0x150>
                    break;
ffffffe0002023e0:	0440006f          	j	ffffffe000202424 <trap_handler+0x15c>
                    sys_write(regs->x[10],(const char*)regs->x[11],(size_t)regs->x[12],regs); // a0,a1,a2
ffffffe0002023e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002023e8:	0507b783          	ld	a5,80(a5)
ffffffe0002023ec:	0007871b          	sext.w	a4,a5
ffffffe0002023f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002023f4:	0587b783          	ld	a5,88(a5)
ffffffe0002023f8:	00078593          	mv	a1,a5
ffffffe0002023fc:	fd843783          	ld	a5,-40(s0)
ffffffe000202400:	0607b783          	ld	a5,96(a5)
ffffffe000202404:	fd843683          	ld	a3,-40(s0)
ffffffe000202408:	00078613          	mv	a2,a5
ffffffe00020240c:	00070513          	mv	a0,a4
ffffffe000202410:	b05ff0ef          	jal	ffffffe000201f14 <sys_write>
                    break;
ffffffe000202414:	0100006f          	j	ffffffe000202424 <trap_handler+0x15c>
                    sys_getpid(regs);
ffffffe000202418:	fd843503          	ld	a0,-40(s0)
ffffffe00020241c:	b9dff0ef          	jal	ffffffe000201fb8 <sys_getpid>
                    break;
ffffffe000202420:	00000013          	nop
            regs->sepc += 4;
ffffffe000202424:	fd843783          	ld	a5,-40(s0)
ffffffe000202428:	1007b783          	ld	a5,256(a5)
ffffffe00020242c:	00478713          	addi	a4,a5,4
ffffffe000202430:	fd843783          	ld	a5,-40(s0)
ffffffe000202434:	10e7b023          	sd	a4,256(a5)
    return;
ffffffe000202438:	2dc0006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==0||((scause<<1)>>1)==1||((scause<<1)>>1)==2)
ffffffe00020243c:	fe843703          	ld	a4,-24(s0)
ffffffe000202440:	fff00793          	li	a5,-1
ffffffe000202444:	0017d793          	srli	a5,a5,0x1
ffffffe000202448:	00f777b3          	and	a5,a4,a5
ffffffe00020244c:	02078a63          	beqz	a5,ffffffe000202480 <trap_handler+0x1b8>
ffffffe000202450:	fe843703          	ld	a4,-24(s0)
ffffffe000202454:	fff00793          	li	a5,-1
ffffffe000202458:	0017d793          	srli	a5,a5,0x1
ffffffe00020245c:	00f77733          	and	a4,a4,a5
ffffffe000202460:	00100793          	li	a5,1
ffffffe000202464:	00f70e63          	beq	a4,a5,ffffffe000202480 <trap_handler+0x1b8>
ffffffe000202468:	fe843703          	ld	a4,-24(s0)
ffffffe00020246c:	fff00793          	li	a5,-1
ffffffe000202470:	0017d793          	srli	a5,a5,0x1
ffffffe000202474:	00f77733          	and	a4,a4,a5
ffffffe000202478:	00200793          	li	a5,2
ffffffe00020247c:	02f71663          	bne	a4,a5,ffffffe0002024a8 <trap_handler+0x1e0>
            Err("Instruction exception\n");
ffffffe000202480:	00002697          	auipc	a3,0x2
ffffffe000202484:	0b868693          	addi	a3,a3,184 # ffffffe000204538 <__func__.0>
ffffffe000202488:	07300613          	li	a2,115
ffffffe00020248c:	00002597          	auipc	a1,0x2
ffffffe000202490:	ddc58593          	addi	a1,a1,-548 # ffffffe000204268 <_srodata+0x268>
ffffffe000202494:	00002517          	auipc	a0,0x2
ffffffe000202498:	ee450513          	addi	a0,a0,-284 # ffffffe000204378 <_srodata+0x378>
ffffffe00020249c:	5b4010ef          	jal	ffffffe000203a50 <printk>
ffffffe0002024a0:	00000013          	nop
ffffffe0002024a4:	ffdff06f          	j	ffffffe0002024a0 <trap_handler+0x1d8>
        }else if(((scause<<1)>>1)==3)
ffffffe0002024a8:	fe843703          	ld	a4,-24(s0)
ffffffe0002024ac:	fff00793          	li	a5,-1
ffffffe0002024b0:	0017d793          	srli	a5,a5,0x1
ffffffe0002024b4:	00f77733          	and	a4,a4,a5
ffffffe0002024b8:	00300793          	li	a5,3
ffffffe0002024bc:	02f71663          	bne	a4,a5,ffffffe0002024e8 <trap_handler+0x220>
            Err("Breakpoint\n");
ffffffe0002024c0:	00002697          	auipc	a3,0x2
ffffffe0002024c4:	07868693          	addi	a3,a3,120 # ffffffe000204538 <__func__.0>
ffffffe0002024c8:	07600613          	li	a2,118
ffffffe0002024cc:	00002597          	auipc	a1,0x2
ffffffe0002024d0:	d9c58593          	addi	a1,a1,-612 # ffffffe000204268 <_srodata+0x268>
ffffffe0002024d4:	00002517          	auipc	a0,0x2
ffffffe0002024d8:	ed450513          	addi	a0,a0,-300 # ffffffe0002043a8 <_srodata+0x3a8>
ffffffe0002024dc:	574010ef          	jal	ffffffe000203a50 <printk>
ffffffe0002024e0:	00000013          	nop
ffffffe0002024e4:	ffdff06f          	j	ffffffe0002024e0 <trap_handler+0x218>
        }else if(((scause<<1)>>1)==4||((scause<<1)>>1)==5)
ffffffe0002024e8:	fe843703          	ld	a4,-24(s0)
ffffffe0002024ec:	fff00793          	li	a5,-1
ffffffe0002024f0:	0017d793          	srli	a5,a5,0x1
ffffffe0002024f4:	00f77733          	and	a4,a4,a5
ffffffe0002024f8:	00400793          	li	a5,4
ffffffe0002024fc:	00f70e63          	beq	a4,a5,ffffffe000202518 <trap_handler+0x250>
ffffffe000202500:	fe843703          	ld	a4,-24(s0)
ffffffe000202504:	fff00793          	li	a5,-1
ffffffe000202508:	0017d793          	srli	a5,a5,0x1
ffffffe00020250c:	00f77733          	and	a4,a4,a5
ffffffe000202510:	00500793          	li	a5,5
ffffffe000202514:	02f71663          	bne	a4,a5,ffffffe000202540 <trap_handler+0x278>
            Err("Load exception\n");
ffffffe000202518:	00002697          	auipc	a3,0x2
ffffffe00020251c:	02068693          	addi	a3,a3,32 # ffffffe000204538 <__func__.0>
ffffffe000202520:	07900613          	li	a2,121
ffffffe000202524:	00002597          	auipc	a1,0x2
ffffffe000202528:	d4458593          	addi	a1,a1,-700 # ffffffe000204268 <_srodata+0x268>
ffffffe00020252c:	00002517          	auipc	a0,0x2
ffffffe000202530:	ea450513          	addi	a0,a0,-348 # ffffffe0002043d0 <_srodata+0x3d0>
ffffffe000202534:	51c010ef          	jal	ffffffe000203a50 <printk>
ffffffe000202538:	00000013          	nop
ffffffe00020253c:	ffdff06f          	j	ffffffe000202538 <trap_handler+0x270>
        }else if(((scause<<1)>>1)==6||((scause<<1)>>1)==7)
ffffffe000202540:	fe843703          	ld	a4,-24(s0)
ffffffe000202544:	fff00793          	li	a5,-1
ffffffe000202548:	0017d793          	srli	a5,a5,0x1
ffffffe00020254c:	00f77733          	and	a4,a4,a5
ffffffe000202550:	00600793          	li	a5,6
ffffffe000202554:	00f70e63          	beq	a4,a5,ffffffe000202570 <trap_handler+0x2a8>
ffffffe000202558:	fe843703          	ld	a4,-24(s0)
ffffffe00020255c:	fff00793          	li	a5,-1
ffffffe000202560:	0017d793          	srli	a5,a5,0x1
ffffffe000202564:	00f77733          	and	a4,a4,a5
ffffffe000202568:	00700793          	li	a5,7
ffffffe00020256c:	02f71663          	bne	a4,a5,ffffffe000202598 <trap_handler+0x2d0>
            Err("Store/AMO exception\n");
ffffffe000202570:	00002697          	auipc	a3,0x2
ffffffe000202574:	fc868693          	addi	a3,a3,-56 # ffffffe000204538 <__func__.0>
ffffffe000202578:	07c00613          	li	a2,124
ffffffe00020257c:	00002597          	auipc	a1,0x2
ffffffe000202580:	cec58593          	addi	a1,a1,-788 # ffffffe000204268 <_srodata+0x268>
ffffffe000202584:	00002517          	auipc	a0,0x2
ffffffe000202588:	e7450513          	addi	a0,a0,-396 # ffffffe0002043f8 <_srodata+0x3f8>
ffffffe00020258c:	4c4010ef          	jal	ffffffe000203a50 <printk>
ffffffe000202590:	00000013          	nop
ffffffe000202594:	ffdff06f          	j	ffffffe000202590 <trap_handler+0x2c8>
        }else if(((scause<<1)>>1)==8||((scause<<1)>>1)==9)
ffffffe000202598:	fe843703          	ld	a4,-24(s0)
ffffffe00020259c:	fff00793          	li	a5,-1
ffffffe0002025a0:	0017d793          	srli	a5,a5,0x1
ffffffe0002025a4:	00f77733          	and	a4,a4,a5
ffffffe0002025a8:	00800793          	li	a5,8
ffffffe0002025ac:	00f70e63          	beq	a4,a5,ffffffe0002025c8 <trap_handler+0x300>
ffffffe0002025b0:	fe843703          	ld	a4,-24(s0)
ffffffe0002025b4:	fff00793          	li	a5,-1
ffffffe0002025b8:	0017d793          	srli	a5,a5,0x1
ffffffe0002025bc:	00f77733          	and	a4,a4,a5
ffffffe0002025c0:	00900793          	li	a5,9
ffffffe0002025c4:	00f71c63          	bne	a4,a5,ffffffe0002025dc <trap_handler+0x314>
            printk("Environment call exception\n");
ffffffe0002025c8:	00002517          	auipc	a0,0x2
ffffffe0002025cc:	e6050513          	addi	a0,a0,-416 # ffffffe000204428 <_srodata+0x428>
ffffffe0002025d0:	480010ef          	jal	ffffffe000203a50 <printk>
    return;
ffffffe0002025d4:	00000013          	nop
ffffffe0002025d8:	13c0006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==12)
ffffffe0002025dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002025e0:	fff00793          	li	a5,-1
ffffffe0002025e4:	0017d793          	srli	a5,a5,0x1
ffffffe0002025e8:	00f77733          	and	a4,a4,a5
ffffffe0002025ec:	00c00793          	li	a5,12
ffffffe0002025f0:	00f71e63          	bne	a4,a5,ffffffe00020260c <trap_handler+0x344>
            printk(RED"Instruction page fault\n"CLEAR);
ffffffe0002025f4:	00002517          	auipc	a0,0x2
ffffffe0002025f8:	e5450513          	addi	a0,a0,-428 # ffffffe000204448 <_srodata+0x448>
ffffffe0002025fc:	454010ef          	jal	ffffffe000203a50 <printk>
            do_page_fault(regs);
ffffffe000202600:	fd843503          	ld	a0,-40(s0)
ffffffe000202604:	9edff0ef          	jal	ffffffe000201ff0 <do_page_fault>
    return;
ffffffe000202608:	10c0006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==13)
ffffffe00020260c:	fe843703          	ld	a4,-24(s0)
ffffffe000202610:	fff00793          	li	a5,-1
ffffffe000202614:	0017d793          	srli	a5,a5,0x1
ffffffe000202618:	00f77733          	and	a4,a4,a5
ffffffe00020261c:	00d00793          	li	a5,13
ffffffe000202620:	00f71e63          	bne	a4,a5,ffffffe00020263c <trap_handler+0x374>
            printk(RED"Load page fault\n"CLEAR);
ffffffe000202624:	00002517          	auipc	a0,0x2
ffffffe000202628:	e4c50513          	addi	a0,a0,-436 # ffffffe000204470 <_srodata+0x470>
ffffffe00020262c:	424010ef          	jal	ffffffe000203a50 <printk>
            do_page_fault(regs);
ffffffe000202630:	fd843503          	ld	a0,-40(s0)
ffffffe000202634:	9bdff0ef          	jal	ffffffe000201ff0 <do_page_fault>
    return;
ffffffe000202638:	0dc0006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==15)
ffffffe00020263c:	fe843703          	ld	a4,-24(s0)
ffffffe000202640:	fff00793          	li	a5,-1
ffffffe000202644:	0017d793          	srli	a5,a5,0x1
ffffffe000202648:	00f77733          	and	a4,a4,a5
ffffffe00020264c:	00f00793          	li	a5,15
ffffffe000202650:	00f71e63          	bne	a4,a5,ffffffe00020266c <trap_handler+0x3a4>
            printk(RED"Store/AMO page fault\n"CLEAR);
ffffffe000202654:	00002517          	auipc	a0,0x2
ffffffe000202658:	e3c50513          	addi	a0,a0,-452 # ffffffe000204490 <_srodata+0x490>
ffffffe00020265c:	3f4010ef          	jal	ffffffe000203a50 <printk>
            do_page_fault(regs);
ffffffe000202660:	fd843503          	ld	a0,-40(s0)
ffffffe000202664:	98dff0ef          	jal	ffffffe000201ff0 <do_page_fault>
    return;
ffffffe000202668:	0ac0006f          	j	ffffffe000202714 <trap_handler+0x44c>
        }else if(((scause<<1)>>1)==18)
ffffffe00020266c:	fe843703          	ld	a4,-24(s0)
ffffffe000202670:	fff00793          	li	a5,-1
ffffffe000202674:	0017d793          	srli	a5,a5,0x1
ffffffe000202678:	00f77733          	and	a4,a4,a5
ffffffe00020267c:	01200793          	li	a5,18
ffffffe000202680:	02f71663          	bne	a4,a5,ffffffe0002026ac <trap_handler+0x3e4>
            Err("Software check\n");
ffffffe000202684:	00002697          	auipc	a3,0x2
ffffffe000202688:	eb468693          	addi	a3,a3,-332 # ffffffe000204538 <__func__.0>
ffffffe00020268c:	08e00613          	li	a2,142
ffffffe000202690:	00002597          	auipc	a1,0x2
ffffffe000202694:	bd858593          	addi	a1,a1,-1064 # ffffffe000204268 <_srodata+0x268>
ffffffe000202698:	00002517          	auipc	a0,0x2
ffffffe00020269c:	e1850513          	addi	a0,a0,-488 # ffffffe0002044b0 <_srodata+0x4b0>
ffffffe0002026a0:	3b0010ef          	jal	ffffffe000203a50 <printk>
ffffffe0002026a4:	00000013          	nop
ffffffe0002026a8:	ffdff06f          	j	ffffffe0002026a4 <trap_handler+0x3dc>
        }else if(((scause<<1)>>1)==19)
ffffffe0002026ac:	fe843703          	ld	a4,-24(s0)
ffffffe0002026b0:	fff00793          	li	a5,-1
ffffffe0002026b4:	0017d793          	srli	a5,a5,0x1
ffffffe0002026b8:	00f77733          	and	a4,a4,a5
ffffffe0002026bc:	01300793          	li	a5,19
ffffffe0002026c0:	02f71663          	bne	a4,a5,ffffffe0002026ec <trap_handler+0x424>
            Err("Hardware error\n");
ffffffe0002026c4:	00002697          	auipc	a3,0x2
ffffffe0002026c8:	e7468693          	addi	a3,a3,-396 # ffffffe000204538 <__func__.0>
ffffffe0002026cc:	09100613          	li	a2,145
ffffffe0002026d0:	00002597          	auipc	a1,0x2
ffffffe0002026d4:	b9858593          	addi	a1,a1,-1128 # ffffffe000204268 <_srodata+0x268>
ffffffe0002026d8:	00002517          	auipc	a0,0x2
ffffffe0002026dc:	e0050513          	addi	a0,a0,-512 # ffffffe0002044d8 <_srodata+0x4d8>
ffffffe0002026e0:	370010ef          	jal	ffffffe000203a50 <printk>
ffffffe0002026e4:	00000013          	nop
ffffffe0002026e8:	ffdff06f          	j	ffffffe0002026e4 <trap_handler+0x41c>
            Err("Reserved\n");
ffffffe0002026ec:	00002697          	auipc	a3,0x2
ffffffe0002026f0:	e4c68693          	addi	a3,a3,-436 # ffffffe000204538 <__func__.0>
ffffffe0002026f4:	09400613          	li	a2,148
ffffffe0002026f8:	00002597          	auipc	a1,0x2
ffffffe0002026fc:	b7058593          	addi	a1,a1,-1168 # ffffffe000204268 <_srodata+0x268>
ffffffe000202700:	00002517          	auipc	a0,0x2
ffffffe000202704:	e0050513          	addi	a0,a0,-512 # ffffffe000204500 <_srodata+0x500>
ffffffe000202708:	348010ef          	jal	ffffffe000203a50 <printk>
ffffffe00020270c:	00000013          	nop
ffffffe000202710:	ffdff06f          	j	ffffffe00020270c <trap_handler+0x444>
    return;
ffffffe000202714:	00000013          	nop
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
ffffffe000202718:	02813083          	ld	ra,40(sp)
ffffffe00020271c:	02013403          	ld	s0,32(sp)
ffffffe000202720:	03010113          	addi	sp,sp,48
ffffffe000202724:	00008067          	ret

ffffffe000202728 <setup_vm>:

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() 
{
ffffffe000202728:	fd010113          	addi	sp,sp,-48
ffffffe00020272c:	02113423          	sd	ra,40(sp)
ffffffe000202730:	02813023          	sd	s0,32(sp)
ffffffe000202734:	03010413          	addi	s0,sp,48
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/

    // 初始化页表
    memset(early_pgtbl, 0x0,PGSIZE);
ffffffe000202738:	00001637          	lui	a2,0x1
ffffffe00020273c:	00000593          	li	a1,0
ffffffe000202740:	00008517          	auipc	a0,0x8
ffffffe000202744:	8c050513          	addi	a0,a0,-1856 # ffffffe00020a000 <early_pgtbl>
ffffffe000202748:	428010ef          	jal	ffffffe000203b70 <memset>

    uint64_t PA,VA;
    // 第一次等值映射
    PA = PHY_START;
ffffffe00020274c:	00100793          	li	a5,1
ffffffe000202750:	01f79793          	slli	a5,a5,0x1f
ffffffe000202754:	fef43423          	sd	a5,-24(s0)
    VA = PA;
ffffffe000202758:	fe843783          	ld	a5,-24(s0)
ffffffe00020275c:	fef43023          	sd	a5,-32(s0)
    // 取index
    uint64_t VPN = (VA >> 30) & 0x1ff;          // 9bit
ffffffe000202760:	fe043783          	ld	a5,-32(s0)
ffffffe000202764:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202768:	1ff7f793          	andi	a5,a5,511
ffffffe00020276c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t PPN = (PA >> 30) & 0x3ffffff;      // 26bit
ffffffe000202770:	fe843783          	ld	a5,-24(s0)
ffffffe000202774:	01e7d713          	srli	a4,a5,0x1e
ffffffe000202778:	040007b7          	lui	a5,0x4000
ffffffe00020277c:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000202780:	00f777b3          	and	a5,a4,a5
ffffffe000202784:	fcf43823          	sd	a5,-48(s0)
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 9+9+10 设置权限位1111
ffffffe000202788:	fd043783          	ld	a5,-48(s0)
ffffffe00020278c:	01c79793          	slli	a5,a5,0x1c
ffffffe000202790:	00f7e713          	ori	a4,a5,15
ffffffe000202794:	00008697          	auipc	a3,0x8
ffffffe000202798:	86c68693          	addi	a3,a3,-1940 # ffffffe00020a000 <early_pgtbl>
ffffffe00020279c:	fd843783          	ld	a5,-40(s0)
ffffffe0002027a0:	00379793          	slli	a5,a5,0x3
ffffffe0002027a4:	00f687b3          	add	a5,a3,a5
ffffffe0002027a8:	00e7b023          	sd	a4,0(a5)

    // 第二次等值映射
    VA = VM_START;
ffffffe0002027ac:	fff00793          	li	a5,-1
ffffffe0002027b0:	02579793          	slli	a5,a5,0x25
ffffffe0002027b4:	fef43023          	sd	a5,-32(s0)
    VPN = (VA >> 30) & 0x1ff;                   // 9bit
ffffffe0002027b8:	fe043783          	ld	a5,-32(s0)
ffffffe0002027bc:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002027c0:	1ff7f793          	andi	a5,a5,511
ffffffe0002027c4:	fcf43c23          	sd	a5,-40(s0)
    early_pgtbl[VPN] = (PPN << 28) | 0b1111;    // 设置权限为1111
ffffffe0002027c8:	fd043783          	ld	a5,-48(s0)
ffffffe0002027cc:	01c79793          	slli	a5,a5,0x1c
ffffffe0002027d0:	00f7e713          	ori	a4,a5,15
ffffffe0002027d4:	00008697          	auipc	a3,0x8
ffffffe0002027d8:	82c68693          	addi	a3,a3,-2004 # ffffffe00020a000 <early_pgtbl>
ffffffe0002027dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002027e0:	00379793          	slli	a5,a5,0x3
ffffffe0002027e4:	00f687b3          	add	a5,a3,a5
ffffffe0002027e8:	00e7b023          	sd	a4,0(a5)
    // VA = VM_START;
    // // 取index
    // uint64_t VPN = (VA >> 30) & 0x1ff;//9bit
    // uint64_t PPN = (PA >> 30) & 0x3ffffff;//26bit
    // early_pgtbl[VPN] = (PPN << 28) | 0b1111;//设置权限为1111
    printk("...setup_vm done!\n");
ffffffe0002027ec:	00002517          	auipc	a0,0x2
ffffffe0002027f0:	d5c50513          	addi	a0,a0,-676 # ffffffe000204548 <__func__.0+0x10>
ffffffe0002027f4:	25c010ef          	jal	ffffffe000203a50 <printk>
}
ffffffe0002027f8:	00000013          	nop
ffffffe0002027fc:	02813083          	ld	ra,40(sp)
ffffffe000202800:	02013403          	ld	s0,32(sp)
ffffffe000202804:	03010113          	addi	sp,sp,48
ffffffe000202808:	00008067          	ret

ffffffe00020280c <setup_vm_final>:
extern char _erodata[];
extern char _etext[];

// 完成对所有物理内存 (128M) 的映射，并设置正确的权限
void setup_vm_final() 
{
ffffffe00020280c:	fb010113          	addi	sp,sp,-80
ffffffe000202810:	04113423          	sd	ra,72(sp)
ffffffe000202814:	04813023          	sd	s0,64(sp)
ffffffe000202818:	05010413          	addi	s0,sp,80
    
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe00020281c:	00001637          	lui	a2,0x1
ffffffe000202820:	00000593          	li	a1,0
ffffffe000202824:	00008517          	auipc	a0,0x8
ffffffe000202828:	7dc50513          	addi	a0,a0,2012 # ffffffe00020b000 <swapper_pg_dir>
ffffffe00020282c:	344010ef          	jal	ffffffe000203b70 <memset>

    // No OpenSBI mapping required
    uint64_t V = VM_START+OPENSBI_SIZE;
ffffffe000202830:	f00017b7          	lui	a5,0xf0001
ffffffe000202834:	00979793          	slli	a5,a5,0x9
ffffffe000202838:	fef43423          	sd	a5,-24(s0)
    uint64_t P = PHY_START+OPENSBI_SIZE;
ffffffe00020283c:	40100793          	li	a5,1025
ffffffe000202840:	01579793          	slli	a5,a5,0x15
ffffffe000202844:	fef43023          	sd	a5,-32(s0)
    
    // mapping kernel text X|-|R|V
    uint64_t size=(uint64_t)_srodata-(uint64_t)_stext;
ffffffe000202848:	00001717          	auipc	a4,0x1
ffffffe00020284c:	7b870713          	addi	a4,a4,1976 # ffffffe000204000 <_srodata>
ffffffe000202850:	ffffd797          	auipc	a5,0xffffd
ffffffe000202854:	7b078793          	addi	a5,a5,1968 # ffffffe000200000 <_skernel>
ffffffe000202858:	40f707b3          	sub	a5,a4,a5
ffffffe00020285c:	fcf43c23          	sd	a5,-40(s0)
    create_mapping(swapper_pg_dir,V,P,size,PERM_KERNEL_TEXT);
ffffffe000202860:	00b00713          	li	a4,11
ffffffe000202864:	fd843683          	ld	a3,-40(s0)
ffffffe000202868:	fe043603          	ld	a2,-32(s0)
ffffffe00020286c:	fe843583          	ld	a1,-24(s0)
ffffffe000202870:	00008517          	auipc	a0,0x8
ffffffe000202874:	79050513          	addi	a0,a0,1936 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202878:	118000ef          	jal	ffffffe000202990 <create_mapping>
    
    // mapping kernel rodata -|-|R|V
    uint64_t size1=(uint64_t)_sdata-(uint64_t)_srodata;
ffffffe00020287c:	00002717          	auipc	a4,0x2
ffffffe000202880:	78470713          	addi	a4,a4,1924 # ffffffe000205000 <TIMECLOCK>
ffffffe000202884:	00001797          	auipc	a5,0x1
ffffffe000202888:	77c78793          	addi	a5,a5,1916 # ffffffe000204000 <_srodata>
ffffffe00020288c:	40f707b3          	sub	a5,a4,a5
ffffffe000202890:	fcf43823          	sd	a5,-48(s0)
    create_mapping(swapper_pg_dir,V+size,P+size,size1,PERM_KERNEL_RODATA);
ffffffe000202894:	fe843703          	ld	a4,-24(s0)
ffffffe000202898:	fd843783          	ld	a5,-40(s0)
ffffffe00020289c:	00f705b3          	add	a1,a4,a5
ffffffe0002028a0:	fe043703          	ld	a4,-32(s0)
ffffffe0002028a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002028a8:	00f707b3          	add	a5,a4,a5
ffffffe0002028ac:	00300713          	li	a4,3
ffffffe0002028b0:	fd043683          	ld	a3,-48(s0)
ffffffe0002028b4:	00078613          	mv	a2,a5
ffffffe0002028b8:	00008517          	auipc	a0,0x8
ffffffe0002028bc:	74850513          	addi	a0,a0,1864 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002028c0:	0d0000ef          	jal	ffffffe000202990 <create_mapping>
    
    // mapping other memory -|W|R|V
    uint64_t size2=PHY_SIZE-((uint64_t)_sdata-(uint64_t)_stext)-OPENSBI_SIZE;
ffffffe0002028c4:	ffffd717          	auipc	a4,0xffffd
ffffffe0002028c8:	73c70713          	addi	a4,a4,1852 # ffffffe000200000 <_skernel>
ffffffe0002028cc:	080007b7          	lui	a5,0x8000
ffffffe0002028d0:	00f70733          	add	a4,a4,a5
ffffffe0002028d4:	ffe007b7          	lui	a5,0xffe00
ffffffe0002028d8:	00f70733          	add	a4,a4,a5
ffffffe0002028dc:	00002797          	auipc	a5,0x2
ffffffe0002028e0:	72478793          	addi	a5,a5,1828 # ffffffe000205000 <TIMECLOCK>
ffffffe0002028e4:	40f707b3          	sub	a5,a4,a5
ffffffe0002028e8:	fcf43423          	sd	a5,-56(s0)
    create_mapping(swapper_pg_dir,V+size+size1,P+size+size1,size2,PERM_KERNEL_DATA);
ffffffe0002028ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002028f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002028f4:	00f70733          	add	a4,a4,a5
ffffffe0002028f8:	fd043783          	ld	a5,-48(s0)
ffffffe0002028fc:	00f705b3          	add	a1,a4,a5
ffffffe000202900:	fe043703          	ld	a4,-32(s0)
ffffffe000202904:	fd843783          	ld	a5,-40(s0)
ffffffe000202908:	00f70733          	add	a4,a4,a5
ffffffe00020290c:	fd043783          	ld	a5,-48(s0)
ffffffe000202910:	00f707b3          	add	a5,a4,a5
ffffffe000202914:	00700713          	li	a4,7
ffffffe000202918:	fc843683          	ld	a3,-56(s0)
ffffffe00020291c:	00078613          	mv	a2,a5
ffffffe000202920:	00008517          	auipc	a0,0x8
ffffffe000202924:	6e050513          	addi	a0,a0,1760 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202928:	068000ef          	jal	ffffffe000202990 <create_mapping>

    // set satp with swapper_pg_dir
    // YOUR CODE HERE
    // 设置 satp 寄存器，启用分页
    uint64_t satp_value = ((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12;
ffffffe00020292c:	00008717          	auipc	a4,0x8
ffffffe000202930:	6d470713          	addi	a4,a4,1748 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202934:	04100793          	li	a5,65
ffffffe000202938:	01f79793          	slli	a5,a5,0x1f
ffffffe00020293c:	00f707b3          	add	a5,a4,a5
ffffffe000202940:	00c7d793          	srli	a5,a5,0xc
ffffffe000202944:	fcf43023          	sd	a5,-64(s0)
    satp_value |= (8UL << 60); // Sv39 模式
ffffffe000202948:	fc043703          	ld	a4,-64(s0)
ffffffe00020294c:	fff00793          	li	a5,-1
ffffffe000202950:	03f79793          	slli	a5,a5,0x3f
ffffffe000202954:	00f767b3          	or	a5,a4,a5
ffffffe000202958:	fcf43023          	sd	a5,-64(s0)
    csr_write(satp, satp_value);
ffffffe00020295c:	fc043783          	ld	a5,-64(s0)
ffffffe000202960:	faf43c23          	sd	a5,-72(s0)
ffffffe000202964:	fb843783          	ld	a5,-72(s0)
ffffffe000202968:	18079073          	csrw	satp,a5
    
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe00020296c:	12000073          	sfence.vma

    // flush icache
    // asm volatile("fence.i");

    printk("...setup_vm_final done!\n");
ffffffe000202970:	00002517          	auipc	a0,0x2
ffffffe000202974:	bf050513          	addi	a0,a0,-1040 # ffffffe000204560 <__func__.0+0x28>
ffffffe000202978:	0d8010ef          	jal	ffffffe000203a50 <printk>

    return;
ffffffe00020297c:	00000013          	nop
}
ffffffe000202980:	04813083          	ld	ra,72(sp)
ffffffe000202984:	04013403          	ld	s0,64(sp)
ffffffe000202988:	05010113          	addi	sp,sp,80
ffffffe00020298c:	00008067          	ret

ffffffe000202990 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) 
{
ffffffe000202990:	f7010113          	addi	sp,sp,-144
ffffffe000202994:	08113423          	sd	ra,136(sp)
ffffffe000202998:	08813023          	sd	s0,128(sp)
ffffffe00020299c:	09010413          	addi	s0,sp,144
ffffffe0002029a0:	f8a43c23          	sd	a0,-104(s0)
ffffffe0002029a4:	f8b43823          	sd	a1,-112(s0)
ffffffe0002029a8:	f8c43423          	sd	a2,-120(s0)
ffffffe0002029ac:	f8d43023          	sd	a3,-128(s0)
ffffffe0002029b0:	f6e43c23          	sd	a4,-136(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    
    uint64_t offset = 0; 
ffffffe0002029b4:	fe043423          	sd	zero,-24(s0)

    while(offset < sz)
ffffffe0002029b8:	1580006f          	j	ffffffe000202b10 <create_mapping+0x180>
    {
        uint64_t va_current = va + offset;
ffffffe0002029bc:	f9043703          	ld	a4,-112(s0)
ffffffe0002029c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002029c4:	00f707b3          	add	a5,a4,a5
ffffffe0002029c8:	fcf43423          	sd	a5,-56(s0)
        uint64_t pa_current = pa + offset;
ffffffe0002029cc:	f8843703          	ld	a4,-120(s0)
ffffffe0002029d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002029d4:	00f707b3          	add	a5,a4,a5
ffffffe0002029d8:	fcf43023          	sd	a5,-64(s0)
        uint64_t *pg_now = pgtbl;
ffffffe0002029dc:	f9843783          	ld	a5,-104(s0)
ffffffe0002029e0:	fef43023          	sd	a5,-32(s0)
        uint64_t VPN[3] = {
            (va_current >> 12) & 0x1ff, // VPN[0]
ffffffe0002029e4:	fc843783          	ld	a5,-56(s0)
ffffffe0002029e8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002029ec:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe0002029f0:	faf43023          	sd	a5,-96(s0)
            (va_current >> 21) & 0x1ff, // VPN[1]
ffffffe0002029f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002029f8:	0157d793          	srli	a5,a5,0x15
ffffffe0002029fc:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe000202a00:	faf43423          	sd	a5,-88(s0)
            (va_current >> 30) & 0x1ff  // VPN[2]
ffffffe000202a04:	fc843783          	ld	a5,-56(s0)
ffffffe000202a08:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202a0c:	1ff7f793          	andi	a5,a5,511
        uint64_t VPN[3] = {
ffffffe000202a10:	faf43823          	sd	a5,-80(s0)
        };

        // 处理三级页表 (Sv39)
        for (int level = 2; level > 0; level--) 
ffffffe000202a14:	00200793          	li	a5,2
ffffffe000202a18:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202a1c:	0b00006f          	j	ffffffe000202acc <create_mapping+0x13c>
        {
            uint64_t PTE = pg_now[VPN[level]];
ffffffe000202a20:	fdc42783          	lw	a5,-36(s0)
ffffffe000202a24:	00379793          	slli	a5,a5,0x3
ffffffe000202a28:	ff078793          	addi	a5,a5,-16
ffffffe000202a2c:	008787b3          	add	a5,a5,s0
ffffffe000202a30:	fb07b783          	ld	a5,-80(a5)
ffffffe000202a34:	00379793          	slli	a5,a5,0x3
ffffffe000202a38:	fe043703          	ld	a4,-32(s0)
ffffffe000202a3c:	00f707b3          	add	a5,a4,a5
ffffffe000202a40:	0007b783          	ld	a5,0(a5)
ffffffe000202a44:	fcf43823          	sd	a5,-48(s0)
            if ((PTE & 1) == 0) 
ffffffe000202a48:	fd043783          	ld	a5,-48(s0)
ffffffe000202a4c:	0017f793          	andi	a5,a5,1
ffffffe000202a50:	04079a63          	bnez	a5,ffffffe000202aa4 <create_mapping+0x114>
            { // 如果页表项无效
                uint64_t *new_pg = (uint64_t *)kalloc(); // 分配一页
ffffffe000202a54:	8b8fe0ef          	jal	ffffffe000200b0c <kalloc>
ffffffe000202a58:	faa43c23          	sd	a0,-72(s0)
                // 计算新的页表物理地址，设置有效位
                PTE = (((uint64_t)new_pg - PA2VA_OFFSET) >> 12) << 10 | 1;
ffffffe000202a5c:	fb843703          	ld	a4,-72(s0)
ffffffe000202a60:	04100793          	li	a5,65
ffffffe000202a64:	01f79793          	slli	a5,a5,0x1f
ffffffe000202a68:	00f707b3          	add	a5,a4,a5
ffffffe000202a6c:	00c7d793          	srli	a5,a5,0xc
ffffffe000202a70:	00a79793          	slli	a5,a5,0xa
ffffffe000202a74:	0017e793          	ori	a5,a5,1
ffffffe000202a78:	fcf43823          	sd	a5,-48(s0)
                pg_now[VPN[level]] = PTE; // 更新页表项
ffffffe000202a7c:	fdc42783          	lw	a5,-36(s0)
ffffffe000202a80:	00379793          	slli	a5,a5,0x3
ffffffe000202a84:	ff078793          	addi	a5,a5,-16
ffffffe000202a88:	008787b3          	add	a5,a5,s0
ffffffe000202a8c:	fb07b783          	ld	a5,-80(a5)
ffffffe000202a90:	00379793          	slli	a5,a5,0x3
ffffffe000202a94:	fe043703          	ld	a4,-32(s0)
ffffffe000202a98:	00f707b3          	add	a5,a4,a5
ffffffe000202a9c:	fd043703          	ld	a4,-48(s0)
ffffffe000202aa0:	00e7b023          	sd	a4,0(a5)
            }

            // 通过当前 PTE 获取下一层页表的地址
            pg_now = (uint64_t *)(((PTE >> 10) << 12) + PA2VA_OFFSET);
ffffffe000202aa4:	fd043783          	ld	a5,-48(s0)
ffffffe000202aa8:	00a7d793          	srli	a5,a5,0xa
ffffffe000202aac:	00c79713          	slli	a4,a5,0xc
ffffffe000202ab0:	fbf00793          	li	a5,-65
ffffffe000202ab4:	01f79793          	slli	a5,a5,0x1f
ffffffe000202ab8:	00f707b3          	add	a5,a4,a5
ffffffe000202abc:	fef43023          	sd	a5,-32(s0)
        for (int level = 2; level > 0; level--) 
ffffffe000202ac0:	fdc42783          	lw	a5,-36(s0)
ffffffe000202ac4:	fff7879b          	addiw	a5,a5,-1
ffffffe000202ac8:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202acc:	fdc42783          	lw	a5,-36(s0)
ffffffe000202ad0:	0007879b          	sext.w	a5,a5
ffffffe000202ad4:	f4f046e3          	bgtz	a5,ffffffe000202a20 <create_mapping+0x90>
        }

        // 处理一级页表
        pg_now[VPN[0]] = ((pa_current >> 12) << 10) | perm; // 设置物理地址和权限
ffffffe000202ad8:	fc043783          	ld	a5,-64(s0)
ffffffe000202adc:	00c7d793          	srli	a5,a5,0xc
ffffffe000202ae0:	00a79693          	slli	a3,a5,0xa
ffffffe000202ae4:	fa043783          	ld	a5,-96(s0)
ffffffe000202ae8:	00379793          	slli	a5,a5,0x3
ffffffe000202aec:	fe043703          	ld	a4,-32(s0)
ffffffe000202af0:	00f707b3          	add	a5,a4,a5
ffffffe000202af4:	f7843703          	ld	a4,-136(s0)
ffffffe000202af8:	00e6e733          	or	a4,a3,a4
ffffffe000202afc:	00e7b023          	sd	a4,0(a5)

        offset += PGSIZE;
ffffffe000202b00:	fe843703          	ld	a4,-24(s0)
ffffffe000202b04:	000017b7          	lui	a5,0x1
ffffffe000202b08:	00f707b3          	add	a5,a4,a5
ffffffe000202b0c:	fef43423          	sd	a5,-24(s0)
    while(offset < sz)
ffffffe000202b10:	fe843703          	ld	a4,-24(s0)
ffffffe000202b14:	f8043783          	ld	a5,-128(s0)
ffffffe000202b18:	eaf762e3          	bltu	a4,a5,ffffffe0002029bc <create_mapping+0x2c>
    }

    printk(BLUE"[vm.c,create_mapping] --- [%lx, %lx) -> [%lx, %lx), perm: %lx\n"CLEAR,pa,pa+sz,va,va+sz,perm);
ffffffe000202b1c:	f8843703          	ld	a4,-120(s0)
ffffffe000202b20:	f8043783          	ld	a5,-128(s0)
ffffffe000202b24:	00f70633          	add	a2,a4,a5
ffffffe000202b28:	f9043703          	ld	a4,-112(s0)
ffffffe000202b2c:	f8043783          	ld	a5,-128(s0)
ffffffe000202b30:	00f70733          	add	a4,a4,a5
ffffffe000202b34:	f7843783          	ld	a5,-136(s0)
ffffffe000202b38:	f9043683          	ld	a3,-112(s0)
ffffffe000202b3c:	f8843583          	ld	a1,-120(s0)
ffffffe000202b40:	00002517          	auipc	a0,0x2
ffffffe000202b44:	a4050513          	addi	a0,a0,-1472 # ffffffe000204580 <__func__.0+0x48>
ffffffe000202b48:	709000ef          	jal	ffffffe000203a50 <printk>
ffffffe000202b4c:	00000013          	nop
ffffffe000202b50:	08813083          	ld	ra,136(sp)
ffffffe000202b54:	08013403          	ld	s0,128(sp)
ffffffe000202b58:	09010113          	addi	sp,sp,144
ffffffe000202b5c:	00008067          	ret

ffffffe000202b60 <start_kernel>:
#include "defs.h"
#include "proc.h"

extern void test();

int start_kernel() {
ffffffe000202b60:	ff010113          	addi	sp,sp,-16
ffffffe000202b64:	00113423          	sd	ra,8(sp)
ffffffe000202b68:	00813023          	sd	s0,0(sp)
ffffffe000202b6c:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000202b70:	00002517          	auipc	a0,0x2
ffffffe000202b74:	a5850513          	addi	a0,a0,-1448 # ffffffe0002045c8 <__func__.0+0x90>
ffffffe000202b78:	6d9000ef          	jal	ffffffe000203a50 <printk>
    printk(" ZJU Operating System\n");
ffffffe000202b7c:	00002517          	auipc	a0,0x2
ffffffe000202b80:	a5450513          	addi	a0,a0,-1452 # ffffffe0002045d0 <__func__.0+0x98>
ffffffe000202b84:	6cd000ef          	jal	ffffffe000203a50 <printk>
    // *_stext=0;
    // *_srodata=0;
    // printk("stext: %x\n", *_stext);  //test W
    // printk("srodata: %x\n", *_srodata);  //test W

    schedule();
ffffffe000202b88:	e45fe0ef          	jal	ffffffe0002019cc <schedule>
    test();
ffffffe000202b8c:	01c000ef          	jal	ffffffe000202ba8 <test>
    return 0;
ffffffe000202b90:	00000793          	li	a5,0
}
ffffffe000202b94:	00078513          	mv	a0,a5
ffffffe000202b98:	00813083          	ld	ra,8(sp)
ffffffe000202b9c:	00013403          	ld	s0,0(sp)
ffffffe000202ba0:	01010113          	addi	sp,sp,16
ffffffe000202ba4:	00008067          	ret

ffffffe000202ba8 <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }
#include "printk.h"

void test() {
ffffffe000202ba8:	ff010113          	addi	sp,sp,-16
ffffffe000202bac:	00813423          	sd	s0,8(sp)
ffffffe000202bb0:	01010413          	addi	s0,sp,16
    // int i = 0;
    while (1) {
ffffffe000202bb4:	00000013          	nop
ffffffe000202bb8:	ffdff06f          	j	ffffffe000202bb4 <test+0xc>

ffffffe000202bbc <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000202bbc:	fe010113          	addi	sp,sp,-32
ffffffe000202bc0:	00113c23          	sd	ra,24(sp)
ffffffe000202bc4:	00813823          	sd	s0,16(sp)
ffffffe000202bc8:	02010413          	addi	s0,sp,32
ffffffe000202bcc:	00050793          	mv	a5,a0
ffffffe000202bd0:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000202bd4:	fec42783          	lw	a5,-20(s0)
ffffffe000202bd8:	0ff7f793          	zext.b	a5,a5
ffffffe000202bdc:	00078513          	mv	a0,a5
ffffffe000202be0:	934ff0ef          	jal	ffffffe000201d14 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000202be4:	fec42783          	lw	a5,-20(s0)
ffffffe000202be8:	0ff7f793          	zext.b	a5,a5
ffffffe000202bec:	0007879b          	sext.w	a5,a5
}
ffffffe000202bf0:	00078513          	mv	a0,a5
ffffffe000202bf4:	01813083          	ld	ra,24(sp)
ffffffe000202bf8:	01013403          	ld	s0,16(sp)
ffffffe000202bfc:	02010113          	addi	sp,sp,32
ffffffe000202c00:	00008067          	ret

ffffffe000202c04 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000202c04:	fe010113          	addi	sp,sp,-32
ffffffe000202c08:	00813c23          	sd	s0,24(sp)
ffffffe000202c0c:	02010413          	addi	s0,sp,32
ffffffe000202c10:	00050793          	mv	a5,a0
ffffffe000202c14:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202c18:	fec42783          	lw	a5,-20(s0)
ffffffe000202c1c:	0007871b          	sext.w	a4,a5
ffffffe000202c20:	02000793          	li	a5,32
ffffffe000202c24:	02f70263          	beq	a4,a5,ffffffe000202c48 <isspace+0x44>
ffffffe000202c28:	fec42783          	lw	a5,-20(s0)
ffffffe000202c2c:	0007871b          	sext.w	a4,a5
ffffffe000202c30:	00800793          	li	a5,8
ffffffe000202c34:	00e7de63          	bge	a5,a4,ffffffe000202c50 <isspace+0x4c>
ffffffe000202c38:	fec42783          	lw	a5,-20(s0)
ffffffe000202c3c:	0007871b          	sext.w	a4,a5
ffffffe000202c40:	00d00793          	li	a5,13
ffffffe000202c44:	00e7c663          	blt	a5,a4,ffffffe000202c50 <isspace+0x4c>
ffffffe000202c48:	00100793          	li	a5,1
ffffffe000202c4c:	0080006f          	j	ffffffe000202c54 <isspace+0x50>
ffffffe000202c50:	00000793          	li	a5,0
}
ffffffe000202c54:	00078513          	mv	a0,a5
ffffffe000202c58:	01813403          	ld	s0,24(sp)
ffffffe000202c5c:	02010113          	addi	sp,sp,32
ffffffe000202c60:	00008067          	ret

ffffffe000202c64 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000202c64:	fb010113          	addi	sp,sp,-80
ffffffe000202c68:	04113423          	sd	ra,72(sp)
ffffffe000202c6c:	04813023          	sd	s0,64(sp)
ffffffe000202c70:	05010413          	addi	s0,sp,80
ffffffe000202c74:	fca43423          	sd	a0,-56(s0)
ffffffe000202c78:	fcb43023          	sd	a1,-64(s0)
ffffffe000202c7c:	00060793          	mv	a5,a2
ffffffe000202c80:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000202c84:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000202c88:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000202c8c:	fc843783          	ld	a5,-56(s0)
ffffffe000202c90:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000202c94:	0100006f          	j	ffffffe000202ca4 <strtol+0x40>
        p++;
ffffffe000202c98:	fd843783          	ld	a5,-40(s0)
ffffffe000202c9c:	00178793          	addi	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000202ca0:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000202ca4:	fd843783          	ld	a5,-40(s0)
ffffffe000202ca8:	0007c783          	lbu	a5,0(a5)
ffffffe000202cac:	0007879b          	sext.w	a5,a5
ffffffe000202cb0:	00078513          	mv	a0,a5
ffffffe000202cb4:	f51ff0ef          	jal	ffffffe000202c04 <isspace>
ffffffe000202cb8:	00050793          	mv	a5,a0
ffffffe000202cbc:	fc079ee3          	bnez	a5,ffffffe000202c98 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000202cc0:	fd843783          	ld	a5,-40(s0)
ffffffe000202cc4:	0007c783          	lbu	a5,0(a5)
ffffffe000202cc8:	00078713          	mv	a4,a5
ffffffe000202ccc:	02d00793          	li	a5,45
ffffffe000202cd0:	00f71e63          	bne	a4,a5,ffffffe000202cec <strtol+0x88>
        neg = true;
ffffffe000202cd4:	00100793          	li	a5,1
ffffffe000202cd8:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000202cdc:	fd843783          	ld	a5,-40(s0)
ffffffe000202ce0:	00178793          	addi	a5,a5,1
ffffffe000202ce4:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202ce8:	0240006f          	j	ffffffe000202d0c <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000202cec:	fd843783          	ld	a5,-40(s0)
ffffffe000202cf0:	0007c783          	lbu	a5,0(a5)
ffffffe000202cf4:	00078713          	mv	a4,a5
ffffffe000202cf8:	02b00793          	li	a5,43
ffffffe000202cfc:	00f71863          	bne	a4,a5,ffffffe000202d0c <strtol+0xa8>
        p++;
ffffffe000202d00:	fd843783          	ld	a5,-40(s0)
ffffffe000202d04:	00178793          	addi	a5,a5,1
ffffffe000202d08:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000202d0c:	fbc42783          	lw	a5,-68(s0)
ffffffe000202d10:	0007879b          	sext.w	a5,a5
ffffffe000202d14:	06079c63          	bnez	a5,ffffffe000202d8c <strtol+0x128>
        if (*p == '0') {
ffffffe000202d18:	fd843783          	ld	a5,-40(s0)
ffffffe000202d1c:	0007c783          	lbu	a5,0(a5)
ffffffe000202d20:	00078713          	mv	a4,a5
ffffffe000202d24:	03000793          	li	a5,48
ffffffe000202d28:	04f71e63          	bne	a4,a5,ffffffe000202d84 <strtol+0x120>
            p++;
ffffffe000202d2c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d30:	00178793          	addi	a5,a5,1
ffffffe000202d34:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000202d38:	fd843783          	ld	a5,-40(s0)
ffffffe000202d3c:	0007c783          	lbu	a5,0(a5)
ffffffe000202d40:	00078713          	mv	a4,a5
ffffffe000202d44:	07800793          	li	a5,120
ffffffe000202d48:	00f70c63          	beq	a4,a5,ffffffe000202d60 <strtol+0xfc>
ffffffe000202d4c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d50:	0007c783          	lbu	a5,0(a5)
ffffffe000202d54:	00078713          	mv	a4,a5
ffffffe000202d58:	05800793          	li	a5,88
ffffffe000202d5c:	00f71e63          	bne	a4,a5,ffffffe000202d78 <strtol+0x114>
                base = 16;
ffffffe000202d60:	01000793          	li	a5,16
ffffffe000202d64:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000202d68:	fd843783          	ld	a5,-40(s0)
ffffffe000202d6c:	00178793          	addi	a5,a5,1
ffffffe000202d70:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202d74:	0180006f          	j	ffffffe000202d8c <strtol+0x128>
            } else {
                base = 8;
ffffffe000202d78:	00800793          	li	a5,8
ffffffe000202d7c:	faf42e23          	sw	a5,-68(s0)
ffffffe000202d80:	00c0006f          	j	ffffffe000202d8c <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000202d84:	00a00793          	li	a5,10
ffffffe000202d88:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000202d8c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d90:	0007c783          	lbu	a5,0(a5)
ffffffe000202d94:	00078713          	mv	a4,a5
ffffffe000202d98:	02f00793          	li	a5,47
ffffffe000202d9c:	02e7f863          	bgeu	a5,a4,ffffffe000202dcc <strtol+0x168>
ffffffe000202da0:	fd843783          	ld	a5,-40(s0)
ffffffe000202da4:	0007c783          	lbu	a5,0(a5)
ffffffe000202da8:	00078713          	mv	a4,a5
ffffffe000202dac:	03900793          	li	a5,57
ffffffe000202db0:	00e7ee63          	bltu	a5,a4,ffffffe000202dcc <strtol+0x168>
            digit = *p - '0';
ffffffe000202db4:	fd843783          	ld	a5,-40(s0)
ffffffe000202db8:	0007c783          	lbu	a5,0(a5)
ffffffe000202dbc:	0007879b          	sext.w	a5,a5
ffffffe000202dc0:	fd07879b          	addiw	a5,a5,-48
ffffffe000202dc4:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202dc8:	0800006f          	j	ffffffe000202e48 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000202dcc:	fd843783          	ld	a5,-40(s0)
ffffffe000202dd0:	0007c783          	lbu	a5,0(a5)
ffffffe000202dd4:	00078713          	mv	a4,a5
ffffffe000202dd8:	06000793          	li	a5,96
ffffffe000202ddc:	02e7f863          	bgeu	a5,a4,ffffffe000202e0c <strtol+0x1a8>
ffffffe000202de0:	fd843783          	ld	a5,-40(s0)
ffffffe000202de4:	0007c783          	lbu	a5,0(a5)
ffffffe000202de8:	00078713          	mv	a4,a5
ffffffe000202dec:	07a00793          	li	a5,122
ffffffe000202df0:	00e7ee63          	bltu	a5,a4,ffffffe000202e0c <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000202df4:	fd843783          	ld	a5,-40(s0)
ffffffe000202df8:	0007c783          	lbu	a5,0(a5)
ffffffe000202dfc:	0007879b          	sext.w	a5,a5
ffffffe000202e00:	fa97879b          	addiw	a5,a5,-87
ffffffe000202e04:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202e08:	0400006f          	j	ffffffe000202e48 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000202e0c:	fd843783          	ld	a5,-40(s0)
ffffffe000202e10:	0007c783          	lbu	a5,0(a5)
ffffffe000202e14:	00078713          	mv	a4,a5
ffffffe000202e18:	04000793          	li	a5,64
ffffffe000202e1c:	06e7f863          	bgeu	a5,a4,ffffffe000202e8c <strtol+0x228>
ffffffe000202e20:	fd843783          	ld	a5,-40(s0)
ffffffe000202e24:	0007c783          	lbu	a5,0(a5)
ffffffe000202e28:	00078713          	mv	a4,a5
ffffffe000202e2c:	05a00793          	li	a5,90
ffffffe000202e30:	04e7ee63          	bltu	a5,a4,ffffffe000202e8c <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000202e34:	fd843783          	ld	a5,-40(s0)
ffffffe000202e38:	0007c783          	lbu	a5,0(a5)
ffffffe000202e3c:	0007879b          	sext.w	a5,a5
ffffffe000202e40:	fc97879b          	addiw	a5,a5,-55
ffffffe000202e44:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000202e48:	fd442783          	lw	a5,-44(s0)
ffffffe000202e4c:	00078713          	mv	a4,a5
ffffffe000202e50:	fbc42783          	lw	a5,-68(s0)
ffffffe000202e54:	0007071b          	sext.w	a4,a4
ffffffe000202e58:	0007879b          	sext.w	a5,a5
ffffffe000202e5c:	02f75663          	bge	a4,a5,ffffffe000202e88 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000202e60:	fbc42703          	lw	a4,-68(s0)
ffffffe000202e64:	fe843783          	ld	a5,-24(s0)
ffffffe000202e68:	02f70733          	mul	a4,a4,a5
ffffffe000202e6c:	fd442783          	lw	a5,-44(s0)
ffffffe000202e70:	00f707b3          	add	a5,a4,a5
ffffffe000202e74:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202e78:	fd843783          	ld	a5,-40(s0)
ffffffe000202e7c:	00178793          	addi	a5,a5,1
ffffffe000202e80:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000202e84:	f09ff06f          	j	ffffffe000202d8c <strtol+0x128>
            break;
ffffffe000202e88:	00000013          	nop
    }

    if (endptr) {
ffffffe000202e8c:	fc043783          	ld	a5,-64(s0)
ffffffe000202e90:	00078863          	beqz	a5,ffffffe000202ea0 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000202e94:	fc043783          	ld	a5,-64(s0)
ffffffe000202e98:	fd843703          	ld	a4,-40(s0)
ffffffe000202e9c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202ea0:	fe744783          	lbu	a5,-25(s0)
ffffffe000202ea4:	0ff7f793          	zext.b	a5,a5
ffffffe000202ea8:	00078863          	beqz	a5,ffffffe000202eb8 <strtol+0x254>
ffffffe000202eac:	fe843783          	ld	a5,-24(s0)
ffffffe000202eb0:	40f007b3          	neg	a5,a5
ffffffe000202eb4:	0080006f          	j	ffffffe000202ebc <strtol+0x258>
ffffffe000202eb8:	fe843783          	ld	a5,-24(s0)
}
ffffffe000202ebc:	00078513          	mv	a0,a5
ffffffe000202ec0:	04813083          	ld	ra,72(sp)
ffffffe000202ec4:	04013403          	ld	s0,64(sp)
ffffffe000202ec8:	05010113          	addi	sp,sp,80
ffffffe000202ecc:	00008067          	ret

ffffffe000202ed0 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000202ed0:	fd010113          	addi	sp,sp,-48
ffffffe000202ed4:	02113423          	sd	ra,40(sp)
ffffffe000202ed8:	02813023          	sd	s0,32(sp)
ffffffe000202edc:	03010413          	addi	s0,sp,48
ffffffe000202ee0:	fca43c23          	sd	a0,-40(s0)
ffffffe000202ee4:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000202ee8:	fd043783          	ld	a5,-48(s0)
ffffffe000202eec:	00079863          	bnez	a5,ffffffe000202efc <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000202ef0:	00001797          	auipc	a5,0x1
ffffffe000202ef4:	6f878793          	addi	a5,a5,1784 # ffffffe0002045e8 <__func__.0+0xb0>
ffffffe000202ef8:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000202efc:	fd043783          	ld	a5,-48(s0)
ffffffe000202f00:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000202f04:	0240006f          	j	ffffffe000202f28 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000202f08:	fe843783          	ld	a5,-24(s0)
ffffffe000202f0c:	00178713          	addi	a4,a5,1
ffffffe000202f10:	fee43423          	sd	a4,-24(s0)
ffffffe000202f14:	0007c783          	lbu	a5,0(a5)
ffffffe000202f18:	0007871b          	sext.w	a4,a5
ffffffe000202f1c:	fd843783          	ld	a5,-40(s0)
ffffffe000202f20:	00070513          	mv	a0,a4
ffffffe000202f24:	000780e7          	jalr	a5
    while (*p) {
ffffffe000202f28:	fe843783          	ld	a5,-24(s0)
ffffffe000202f2c:	0007c783          	lbu	a5,0(a5)
ffffffe000202f30:	fc079ce3          	bnez	a5,ffffffe000202f08 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000202f34:	fe843703          	ld	a4,-24(s0)
ffffffe000202f38:	fd043783          	ld	a5,-48(s0)
ffffffe000202f3c:	40f707b3          	sub	a5,a4,a5
ffffffe000202f40:	0007879b          	sext.w	a5,a5
}
ffffffe000202f44:	00078513          	mv	a0,a5
ffffffe000202f48:	02813083          	ld	ra,40(sp)
ffffffe000202f4c:	02013403          	ld	s0,32(sp)
ffffffe000202f50:	03010113          	addi	sp,sp,48
ffffffe000202f54:	00008067          	ret

ffffffe000202f58 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202f58:	f9010113          	addi	sp,sp,-112
ffffffe000202f5c:	06113423          	sd	ra,104(sp)
ffffffe000202f60:	06813023          	sd	s0,96(sp)
ffffffe000202f64:	07010413          	addi	s0,sp,112
ffffffe000202f68:	faa43423          	sd	a0,-88(s0)
ffffffe000202f6c:	fab43023          	sd	a1,-96(s0)
ffffffe000202f70:	00060793          	mv	a5,a2
ffffffe000202f74:	f8d43823          	sd	a3,-112(s0)
ffffffe000202f78:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000202f7c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202f80:	0ff7f793          	zext.b	a5,a5
ffffffe000202f84:	02078663          	beqz	a5,ffffffe000202fb0 <print_dec_int+0x58>
ffffffe000202f88:	fa043703          	ld	a4,-96(s0)
ffffffe000202f8c:	fff00793          	li	a5,-1
ffffffe000202f90:	03f79793          	slli	a5,a5,0x3f
ffffffe000202f94:	00f71e63          	bne	a4,a5,ffffffe000202fb0 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202f98:	00001597          	auipc	a1,0x1
ffffffe000202f9c:	65858593          	addi	a1,a1,1624 # ffffffe0002045f0 <__func__.0+0xb8>
ffffffe000202fa0:	fa843503          	ld	a0,-88(s0)
ffffffe000202fa4:	f2dff0ef          	jal	ffffffe000202ed0 <puts_wo_nl>
ffffffe000202fa8:	00050793          	mv	a5,a0
ffffffe000202fac:	2a00006f          	j	ffffffe00020324c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202fb0:	f9043783          	ld	a5,-112(s0)
ffffffe000202fb4:	00c7a783          	lw	a5,12(a5)
ffffffe000202fb8:	00079a63          	bnez	a5,ffffffe000202fcc <print_dec_int+0x74>
ffffffe000202fbc:	fa043783          	ld	a5,-96(s0)
ffffffe000202fc0:	00079663          	bnez	a5,ffffffe000202fcc <print_dec_int+0x74>
        return 0;
ffffffe000202fc4:	00000793          	li	a5,0
ffffffe000202fc8:	2840006f          	j	ffffffe00020324c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000202fcc:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000202fd0:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202fd4:	0ff7f793          	zext.b	a5,a5
ffffffe000202fd8:	02078063          	beqz	a5,ffffffe000202ff8 <print_dec_int+0xa0>
ffffffe000202fdc:	fa043783          	ld	a5,-96(s0)
ffffffe000202fe0:	0007dc63          	bgez	a5,ffffffe000202ff8 <print_dec_int+0xa0>
        neg = true;
ffffffe000202fe4:	00100793          	li	a5,1
ffffffe000202fe8:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000202fec:	fa043783          	ld	a5,-96(s0)
ffffffe000202ff0:	40f007b3          	neg	a5,a5
ffffffe000202ff4:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000202ff8:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000202ffc:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203000:	0ff7f793          	zext.b	a5,a5
ffffffe000203004:	02078863          	beqz	a5,ffffffe000203034 <print_dec_int+0xdc>
ffffffe000203008:	fef44783          	lbu	a5,-17(s0)
ffffffe00020300c:	0ff7f793          	zext.b	a5,a5
ffffffe000203010:	00079e63          	bnez	a5,ffffffe00020302c <print_dec_int+0xd4>
ffffffe000203014:	f9043783          	ld	a5,-112(s0)
ffffffe000203018:	0057c783          	lbu	a5,5(a5)
ffffffe00020301c:	00079863          	bnez	a5,ffffffe00020302c <print_dec_int+0xd4>
ffffffe000203020:	f9043783          	ld	a5,-112(s0)
ffffffe000203024:	0047c783          	lbu	a5,4(a5)
ffffffe000203028:	00078663          	beqz	a5,ffffffe000203034 <print_dec_int+0xdc>
ffffffe00020302c:	00100793          	li	a5,1
ffffffe000203030:	0080006f          	j	ffffffe000203038 <print_dec_int+0xe0>
ffffffe000203034:	00000793          	li	a5,0
ffffffe000203038:	fcf40ba3          	sb	a5,-41(s0)
ffffffe00020303c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203040:	0017f793          	andi	a5,a5,1
ffffffe000203044:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000203048:	fa043703          	ld	a4,-96(s0)
ffffffe00020304c:	00a00793          	li	a5,10
ffffffe000203050:	02f777b3          	remu	a5,a4,a5
ffffffe000203054:	0ff7f713          	zext.b	a4,a5
ffffffe000203058:	fe842783          	lw	a5,-24(s0)
ffffffe00020305c:	0017869b          	addiw	a3,a5,1
ffffffe000203060:	fed42423          	sw	a3,-24(s0)
ffffffe000203064:	0307071b          	addiw	a4,a4,48
ffffffe000203068:	0ff77713          	zext.b	a4,a4
ffffffe00020306c:	ff078793          	addi	a5,a5,-16
ffffffe000203070:	008787b3          	add	a5,a5,s0
ffffffe000203074:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000203078:	fa043703          	ld	a4,-96(s0)
ffffffe00020307c:	00a00793          	li	a5,10
ffffffe000203080:	02f757b3          	divu	a5,a4,a5
ffffffe000203084:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000203088:	fa043783          	ld	a5,-96(s0)
ffffffe00020308c:	fa079ee3          	bnez	a5,ffffffe000203048 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000203090:	f9043783          	ld	a5,-112(s0)
ffffffe000203094:	00c7a783          	lw	a5,12(a5)
ffffffe000203098:	00078713          	mv	a4,a5
ffffffe00020309c:	fff00793          	li	a5,-1
ffffffe0002030a0:	02f71063          	bne	a4,a5,ffffffe0002030c0 <print_dec_int+0x168>
ffffffe0002030a4:	f9043783          	ld	a5,-112(s0)
ffffffe0002030a8:	0037c783          	lbu	a5,3(a5)
ffffffe0002030ac:	00078a63          	beqz	a5,ffffffe0002030c0 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe0002030b0:	f9043783          	ld	a5,-112(s0)
ffffffe0002030b4:	0087a703          	lw	a4,8(a5)
ffffffe0002030b8:	f9043783          	ld	a5,-112(s0)
ffffffe0002030bc:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002030c0:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002030c4:	f9043783          	ld	a5,-112(s0)
ffffffe0002030c8:	0087a703          	lw	a4,8(a5)
ffffffe0002030cc:	fe842783          	lw	a5,-24(s0)
ffffffe0002030d0:	fcf42823          	sw	a5,-48(s0)
ffffffe0002030d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002030d8:	00c7a783          	lw	a5,12(a5)
ffffffe0002030dc:	fcf42623          	sw	a5,-52(s0)
ffffffe0002030e0:	fd042783          	lw	a5,-48(s0)
ffffffe0002030e4:	00078593          	mv	a1,a5
ffffffe0002030e8:	fcc42783          	lw	a5,-52(s0)
ffffffe0002030ec:	00078613          	mv	a2,a5
ffffffe0002030f0:	0006069b          	sext.w	a3,a2
ffffffe0002030f4:	0005879b          	sext.w	a5,a1
ffffffe0002030f8:	00f6d463          	bge	a3,a5,ffffffe000203100 <print_dec_int+0x1a8>
ffffffe0002030fc:	00058613          	mv	a2,a1
ffffffe000203100:	0006079b          	sext.w	a5,a2
ffffffe000203104:	40f707bb          	subw	a5,a4,a5
ffffffe000203108:	0007871b          	sext.w	a4,a5
ffffffe00020310c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203110:	0007879b          	sext.w	a5,a5
ffffffe000203114:	40f707bb          	subw	a5,a4,a5
ffffffe000203118:	fef42023          	sw	a5,-32(s0)
ffffffe00020311c:	0280006f          	j	ffffffe000203144 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000203120:	fa843783          	ld	a5,-88(s0)
ffffffe000203124:	02000513          	li	a0,32
ffffffe000203128:	000780e7          	jalr	a5
        ++written;
ffffffe00020312c:	fe442783          	lw	a5,-28(s0)
ffffffe000203130:	0017879b          	addiw	a5,a5,1
ffffffe000203134:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203138:	fe042783          	lw	a5,-32(s0)
ffffffe00020313c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203140:	fef42023          	sw	a5,-32(s0)
ffffffe000203144:	fe042783          	lw	a5,-32(s0)
ffffffe000203148:	0007879b          	sext.w	a5,a5
ffffffe00020314c:	fcf04ae3          	bgtz	a5,ffffffe000203120 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000203150:	fd744783          	lbu	a5,-41(s0)
ffffffe000203154:	0ff7f793          	zext.b	a5,a5
ffffffe000203158:	04078463          	beqz	a5,ffffffe0002031a0 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe00020315c:	fef44783          	lbu	a5,-17(s0)
ffffffe000203160:	0ff7f793          	zext.b	a5,a5
ffffffe000203164:	00078663          	beqz	a5,ffffffe000203170 <print_dec_int+0x218>
ffffffe000203168:	02d00793          	li	a5,45
ffffffe00020316c:	01c0006f          	j	ffffffe000203188 <print_dec_int+0x230>
ffffffe000203170:	f9043783          	ld	a5,-112(s0)
ffffffe000203174:	0057c783          	lbu	a5,5(a5)
ffffffe000203178:	00078663          	beqz	a5,ffffffe000203184 <print_dec_int+0x22c>
ffffffe00020317c:	02b00793          	li	a5,43
ffffffe000203180:	0080006f          	j	ffffffe000203188 <print_dec_int+0x230>
ffffffe000203184:	02000793          	li	a5,32
ffffffe000203188:	fa843703          	ld	a4,-88(s0)
ffffffe00020318c:	00078513          	mv	a0,a5
ffffffe000203190:	000700e7          	jalr	a4
        ++written;
ffffffe000203194:	fe442783          	lw	a5,-28(s0)
ffffffe000203198:	0017879b          	addiw	a5,a5,1
ffffffe00020319c:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002031a0:	fe842783          	lw	a5,-24(s0)
ffffffe0002031a4:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002031a8:	0280006f          	j	ffffffe0002031d0 <print_dec_int+0x278>
        putch('0');
ffffffe0002031ac:	fa843783          	ld	a5,-88(s0)
ffffffe0002031b0:	03000513          	li	a0,48
ffffffe0002031b4:	000780e7          	jalr	a5
        ++written;
ffffffe0002031b8:	fe442783          	lw	a5,-28(s0)
ffffffe0002031bc:	0017879b          	addiw	a5,a5,1
ffffffe0002031c0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002031c4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002031c8:	0017879b          	addiw	a5,a5,1
ffffffe0002031cc:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002031d0:	f9043783          	ld	a5,-112(s0)
ffffffe0002031d4:	00c7a703          	lw	a4,12(a5)
ffffffe0002031d8:	fd744783          	lbu	a5,-41(s0)
ffffffe0002031dc:	0007879b          	sext.w	a5,a5
ffffffe0002031e0:	40f707bb          	subw	a5,a4,a5
ffffffe0002031e4:	0007871b          	sext.w	a4,a5
ffffffe0002031e8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002031ec:	0007879b          	sext.w	a5,a5
ffffffe0002031f0:	fae7cee3          	blt	a5,a4,ffffffe0002031ac <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002031f4:	fe842783          	lw	a5,-24(s0)
ffffffe0002031f8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002031fc:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203200:	03c0006f          	j	ffffffe00020323c <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203204:	fd842783          	lw	a5,-40(s0)
ffffffe000203208:	ff078793          	addi	a5,a5,-16
ffffffe00020320c:	008787b3          	add	a5,a5,s0
ffffffe000203210:	fc87c783          	lbu	a5,-56(a5)
ffffffe000203214:	0007871b          	sext.w	a4,a5
ffffffe000203218:	fa843783          	ld	a5,-88(s0)
ffffffe00020321c:	00070513          	mv	a0,a4
ffffffe000203220:	000780e7          	jalr	a5
        ++written;
ffffffe000203224:	fe442783          	lw	a5,-28(s0)
ffffffe000203228:	0017879b          	addiw	a5,a5,1
ffffffe00020322c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203230:	fd842783          	lw	a5,-40(s0)
ffffffe000203234:	fff7879b          	addiw	a5,a5,-1
ffffffe000203238:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020323c:	fd842783          	lw	a5,-40(s0)
ffffffe000203240:	0007879b          	sext.w	a5,a5
ffffffe000203244:	fc07d0e3          	bgez	a5,ffffffe000203204 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000203248:	fe442783          	lw	a5,-28(s0)
}
ffffffe00020324c:	00078513          	mv	a0,a5
ffffffe000203250:	06813083          	ld	ra,104(sp)
ffffffe000203254:	06013403          	ld	s0,96(sp)
ffffffe000203258:	07010113          	addi	sp,sp,112
ffffffe00020325c:	00008067          	ret

ffffffe000203260 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000203260:	f4010113          	addi	sp,sp,-192
ffffffe000203264:	0a113c23          	sd	ra,184(sp)
ffffffe000203268:	0a813823          	sd	s0,176(sp)
ffffffe00020326c:	0c010413          	addi	s0,sp,192
ffffffe000203270:	f4a43c23          	sd	a0,-168(s0)
ffffffe000203274:	f4b43823          	sd	a1,-176(s0)
ffffffe000203278:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe00020327c:	f8043023          	sd	zero,-128(s0)
ffffffe000203280:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000203284:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000203288:	7a40006f          	j	ffffffe000203a2c <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe00020328c:	f8044783          	lbu	a5,-128(s0)
ffffffe000203290:	72078e63          	beqz	a5,ffffffe0002039cc <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000203294:	f5043783          	ld	a5,-176(s0)
ffffffe000203298:	0007c783          	lbu	a5,0(a5)
ffffffe00020329c:	00078713          	mv	a4,a5
ffffffe0002032a0:	02300793          	li	a5,35
ffffffe0002032a4:	00f71863          	bne	a4,a5,ffffffe0002032b4 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe0002032a8:	00100793          	li	a5,1
ffffffe0002032ac:	f8f40123          	sb	a5,-126(s0)
ffffffe0002032b0:	7700006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe0002032b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002032b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002032bc:	00078713          	mv	a4,a5
ffffffe0002032c0:	03000793          	li	a5,48
ffffffe0002032c4:	00f71863          	bne	a4,a5,ffffffe0002032d4 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002032c8:	00100793          	li	a5,1
ffffffe0002032cc:	f8f401a3          	sb	a5,-125(s0)
ffffffe0002032d0:	7500006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe0002032d4:	f5043783          	ld	a5,-176(s0)
ffffffe0002032d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002032dc:	00078713          	mv	a4,a5
ffffffe0002032e0:	06c00793          	li	a5,108
ffffffe0002032e4:	04f70063          	beq	a4,a5,ffffffe000203324 <vprintfmt+0xc4>
ffffffe0002032e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002032ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002032f0:	00078713          	mv	a4,a5
ffffffe0002032f4:	07a00793          	li	a5,122
ffffffe0002032f8:	02f70663          	beq	a4,a5,ffffffe000203324 <vprintfmt+0xc4>
ffffffe0002032fc:	f5043783          	ld	a5,-176(s0)
ffffffe000203300:	0007c783          	lbu	a5,0(a5)
ffffffe000203304:	00078713          	mv	a4,a5
ffffffe000203308:	07400793          	li	a5,116
ffffffe00020330c:	00f70c63          	beq	a4,a5,ffffffe000203324 <vprintfmt+0xc4>
ffffffe000203310:	f5043783          	ld	a5,-176(s0)
ffffffe000203314:	0007c783          	lbu	a5,0(a5)
ffffffe000203318:	00078713          	mv	a4,a5
ffffffe00020331c:	06a00793          	li	a5,106
ffffffe000203320:	00f71863          	bne	a4,a5,ffffffe000203330 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000203324:	00100793          	li	a5,1
ffffffe000203328:	f8f400a3          	sb	a5,-127(s0)
ffffffe00020332c:	6f40006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000203330:	f5043783          	ld	a5,-176(s0)
ffffffe000203334:	0007c783          	lbu	a5,0(a5)
ffffffe000203338:	00078713          	mv	a4,a5
ffffffe00020333c:	02b00793          	li	a5,43
ffffffe000203340:	00f71863          	bne	a4,a5,ffffffe000203350 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000203344:	00100793          	li	a5,1
ffffffe000203348:	f8f402a3          	sb	a5,-123(s0)
ffffffe00020334c:	6d40006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000203350:	f5043783          	ld	a5,-176(s0)
ffffffe000203354:	0007c783          	lbu	a5,0(a5)
ffffffe000203358:	00078713          	mv	a4,a5
ffffffe00020335c:	02000793          	li	a5,32
ffffffe000203360:	00f71863          	bne	a4,a5,ffffffe000203370 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000203364:	00100793          	li	a5,1
ffffffe000203368:	f8f40223          	sb	a5,-124(s0)
ffffffe00020336c:	6b40006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000203370:	f5043783          	ld	a5,-176(s0)
ffffffe000203374:	0007c783          	lbu	a5,0(a5)
ffffffe000203378:	00078713          	mv	a4,a5
ffffffe00020337c:	02a00793          	li	a5,42
ffffffe000203380:	00f71e63          	bne	a4,a5,ffffffe00020339c <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000203384:	f4843783          	ld	a5,-184(s0)
ffffffe000203388:	00878713          	addi	a4,a5,8
ffffffe00020338c:	f4e43423          	sd	a4,-184(s0)
ffffffe000203390:	0007a783          	lw	a5,0(a5)
ffffffe000203394:	f8f42423          	sw	a5,-120(s0)
ffffffe000203398:	6880006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe00020339c:	f5043783          	ld	a5,-176(s0)
ffffffe0002033a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002033a4:	00078713          	mv	a4,a5
ffffffe0002033a8:	03000793          	li	a5,48
ffffffe0002033ac:	04e7f663          	bgeu	a5,a4,ffffffe0002033f8 <vprintfmt+0x198>
ffffffe0002033b0:	f5043783          	ld	a5,-176(s0)
ffffffe0002033b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002033b8:	00078713          	mv	a4,a5
ffffffe0002033bc:	03900793          	li	a5,57
ffffffe0002033c0:	02e7ec63          	bltu	a5,a4,ffffffe0002033f8 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002033c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002033c8:	f5040713          	addi	a4,s0,-176
ffffffe0002033cc:	00a00613          	li	a2,10
ffffffe0002033d0:	00070593          	mv	a1,a4
ffffffe0002033d4:	00078513          	mv	a0,a5
ffffffe0002033d8:	88dff0ef          	jal	ffffffe000202c64 <strtol>
ffffffe0002033dc:	00050793          	mv	a5,a0
ffffffe0002033e0:	0007879b          	sext.w	a5,a5
ffffffe0002033e4:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe0002033e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002033ec:	fff78793          	addi	a5,a5,-1
ffffffe0002033f0:	f4f43823          	sd	a5,-176(s0)
ffffffe0002033f4:	62c0006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe0002033f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002033fc:	0007c783          	lbu	a5,0(a5)
ffffffe000203400:	00078713          	mv	a4,a5
ffffffe000203404:	02e00793          	li	a5,46
ffffffe000203408:	06f71863          	bne	a4,a5,ffffffe000203478 <vprintfmt+0x218>
                fmt++;
ffffffe00020340c:	f5043783          	ld	a5,-176(s0)
ffffffe000203410:	00178793          	addi	a5,a5,1
ffffffe000203414:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000203418:	f5043783          	ld	a5,-176(s0)
ffffffe00020341c:	0007c783          	lbu	a5,0(a5)
ffffffe000203420:	00078713          	mv	a4,a5
ffffffe000203424:	02a00793          	li	a5,42
ffffffe000203428:	00f71e63          	bne	a4,a5,ffffffe000203444 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe00020342c:	f4843783          	ld	a5,-184(s0)
ffffffe000203430:	00878713          	addi	a4,a5,8
ffffffe000203434:	f4e43423          	sd	a4,-184(s0)
ffffffe000203438:	0007a783          	lw	a5,0(a5)
ffffffe00020343c:	f8f42623          	sw	a5,-116(s0)
ffffffe000203440:	5e00006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000203444:	f5043783          	ld	a5,-176(s0)
ffffffe000203448:	f5040713          	addi	a4,s0,-176
ffffffe00020344c:	00a00613          	li	a2,10
ffffffe000203450:	00070593          	mv	a1,a4
ffffffe000203454:	00078513          	mv	a0,a5
ffffffe000203458:	80dff0ef          	jal	ffffffe000202c64 <strtol>
ffffffe00020345c:	00050793          	mv	a5,a0
ffffffe000203460:	0007879b          	sext.w	a5,a5
ffffffe000203464:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000203468:	f5043783          	ld	a5,-176(s0)
ffffffe00020346c:	fff78793          	addi	a5,a5,-1
ffffffe000203470:	f4f43823          	sd	a5,-176(s0)
ffffffe000203474:	5ac0006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000203478:	f5043783          	ld	a5,-176(s0)
ffffffe00020347c:	0007c783          	lbu	a5,0(a5)
ffffffe000203480:	00078713          	mv	a4,a5
ffffffe000203484:	07800793          	li	a5,120
ffffffe000203488:	02f70663          	beq	a4,a5,ffffffe0002034b4 <vprintfmt+0x254>
ffffffe00020348c:	f5043783          	ld	a5,-176(s0)
ffffffe000203490:	0007c783          	lbu	a5,0(a5)
ffffffe000203494:	00078713          	mv	a4,a5
ffffffe000203498:	05800793          	li	a5,88
ffffffe00020349c:	00f70c63          	beq	a4,a5,ffffffe0002034b4 <vprintfmt+0x254>
ffffffe0002034a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002034a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002034a8:	00078713          	mv	a4,a5
ffffffe0002034ac:	07000793          	li	a5,112
ffffffe0002034b0:	30f71263          	bne	a4,a5,ffffffe0002037b4 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe0002034b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002034b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002034bc:	00078713          	mv	a4,a5
ffffffe0002034c0:	07000793          	li	a5,112
ffffffe0002034c4:	00f70663          	beq	a4,a5,ffffffe0002034d0 <vprintfmt+0x270>
ffffffe0002034c8:	f8144783          	lbu	a5,-127(s0)
ffffffe0002034cc:	00078663          	beqz	a5,ffffffe0002034d8 <vprintfmt+0x278>
ffffffe0002034d0:	00100793          	li	a5,1
ffffffe0002034d4:	0080006f          	j	ffffffe0002034dc <vprintfmt+0x27c>
ffffffe0002034d8:	00000793          	li	a5,0
ffffffe0002034dc:	faf403a3          	sb	a5,-89(s0)
ffffffe0002034e0:	fa744783          	lbu	a5,-89(s0)
ffffffe0002034e4:	0017f793          	andi	a5,a5,1
ffffffe0002034e8:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe0002034ec:	fa744783          	lbu	a5,-89(s0)
ffffffe0002034f0:	0ff7f793          	zext.b	a5,a5
ffffffe0002034f4:	00078c63          	beqz	a5,ffffffe00020350c <vprintfmt+0x2ac>
ffffffe0002034f8:	f4843783          	ld	a5,-184(s0)
ffffffe0002034fc:	00878713          	addi	a4,a5,8
ffffffe000203500:	f4e43423          	sd	a4,-184(s0)
ffffffe000203504:	0007b783          	ld	a5,0(a5)
ffffffe000203508:	01c0006f          	j	ffffffe000203524 <vprintfmt+0x2c4>
ffffffe00020350c:	f4843783          	ld	a5,-184(s0)
ffffffe000203510:	00878713          	addi	a4,a5,8
ffffffe000203514:	f4e43423          	sd	a4,-184(s0)
ffffffe000203518:	0007a783          	lw	a5,0(a5)
ffffffe00020351c:	02079793          	slli	a5,a5,0x20
ffffffe000203520:	0207d793          	srli	a5,a5,0x20
ffffffe000203524:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000203528:	f8c42783          	lw	a5,-116(s0)
ffffffe00020352c:	02079463          	bnez	a5,ffffffe000203554 <vprintfmt+0x2f4>
ffffffe000203530:	fe043783          	ld	a5,-32(s0)
ffffffe000203534:	02079063          	bnez	a5,ffffffe000203554 <vprintfmt+0x2f4>
ffffffe000203538:	f5043783          	ld	a5,-176(s0)
ffffffe00020353c:	0007c783          	lbu	a5,0(a5)
ffffffe000203540:	00078713          	mv	a4,a5
ffffffe000203544:	07000793          	li	a5,112
ffffffe000203548:	00f70663          	beq	a4,a5,ffffffe000203554 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe00020354c:	f8040023          	sb	zero,-128(s0)
ffffffe000203550:	4d00006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000203554:	f5043783          	ld	a5,-176(s0)
ffffffe000203558:	0007c783          	lbu	a5,0(a5)
ffffffe00020355c:	00078713          	mv	a4,a5
ffffffe000203560:	07000793          	li	a5,112
ffffffe000203564:	00f70a63          	beq	a4,a5,ffffffe000203578 <vprintfmt+0x318>
ffffffe000203568:	f8244783          	lbu	a5,-126(s0)
ffffffe00020356c:	00078a63          	beqz	a5,ffffffe000203580 <vprintfmt+0x320>
ffffffe000203570:	fe043783          	ld	a5,-32(s0)
ffffffe000203574:	00078663          	beqz	a5,ffffffe000203580 <vprintfmt+0x320>
ffffffe000203578:	00100793          	li	a5,1
ffffffe00020357c:	0080006f          	j	ffffffe000203584 <vprintfmt+0x324>
ffffffe000203580:	00000793          	li	a5,0
ffffffe000203584:	faf40323          	sb	a5,-90(s0)
ffffffe000203588:	fa644783          	lbu	a5,-90(s0)
ffffffe00020358c:	0017f793          	andi	a5,a5,1
ffffffe000203590:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000203594:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000203598:	f5043783          	ld	a5,-176(s0)
ffffffe00020359c:	0007c783          	lbu	a5,0(a5)
ffffffe0002035a0:	00078713          	mv	a4,a5
ffffffe0002035a4:	05800793          	li	a5,88
ffffffe0002035a8:	00f71863          	bne	a4,a5,ffffffe0002035b8 <vprintfmt+0x358>
ffffffe0002035ac:	00001797          	auipc	a5,0x1
ffffffe0002035b0:	05c78793          	addi	a5,a5,92 # ffffffe000204608 <upperxdigits.1>
ffffffe0002035b4:	00c0006f          	j	ffffffe0002035c0 <vprintfmt+0x360>
ffffffe0002035b8:	00001797          	auipc	a5,0x1
ffffffe0002035bc:	06878793          	addi	a5,a5,104 # ffffffe000204620 <lowerxdigits.0>
ffffffe0002035c0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe0002035c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002035c8:	00f7f793          	andi	a5,a5,15
ffffffe0002035cc:	f9843703          	ld	a4,-104(s0)
ffffffe0002035d0:	00f70733          	add	a4,a4,a5
ffffffe0002035d4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002035d8:	0017869b          	addiw	a3,a5,1
ffffffe0002035dc:	fcd42e23          	sw	a3,-36(s0)
ffffffe0002035e0:	00074703          	lbu	a4,0(a4)
ffffffe0002035e4:	ff078793          	addi	a5,a5,-16
ffffffe0002035e8:	008787b3          	add	a5,a5,s0
ffffffe0002035ec:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002035f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002035f4:	0047d793          	srli	a5,a5,0x4
ffffffe0002035f8:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe0002035fc:	fe043783          	ld	a5,-32(s0)
ffffffe000203600:	fc0792e3          	bnez	a5,ffffffe0002035c4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000203604:	f8c42783          	lw	a5,-116(s0)
ffffffe000203608:	00078713          	mv	a4,a5
ffffffe00020360c:	fff00793          	li	a5,-1
ffffffe000203610:	02f71663          	bne	a4,a5,ffffffe00020363c <vprintfmt+0x3dc>
ffffffe000203614:	f8344783          	lbu	a5,-125(s0)
ffffffe000203618:	02078263          	beqz	a5,ffffffe00020363c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe00020361c:	f8842703          	lw	a4,-120(s0)
ffffffe000203620:	fa644783          	lbu	a5,-90(s0)
ffffffe000203624:	0007879b          	sext.w	a5,a5
ffffffe000203628:	0017979b          	slliw	a5,a5,0x1
ffffffe00020362c:	0007879b          	sext.w	a5,a5
ffffffe000203630:	40f707bb          	subw	a5,a4,a5
ffffffe000203634:	0007879b          	sext.w	a5,a5
ffffffe000203638:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe00020363c:	f8842703          	lw	a4,-120(s0)
ffffffe000203640:	fa644783          	lbu	a5,-90(s0)
ffffffe000203644:	0007879b          	sext.w	a5,a5
ffffffe000203648:	0017979b          	slliw	a5,a5,0x1
ffffffe00020364c:	0007879b          	sext.w	a5,a5
ffffffe000203650:	40f707bb          	subw	a5,a4,a5
ffffffe000203654:	0007871b          	sext.w	a4,a5
ffffffe000203658:	fdc42783          	lw	a5,-36(s0)
ffffffe00020365c:	f8f42a23          	sw	a5,-108(s0)
ffffffe000203660:	f8c42783          	lw	a5,-116(s0)
ffffffe000203664:	f8f42823          	sw	a5,-112(s0)
ffffffe000203668:	f9442783          	lw	a5,-108(s0)
ffffffe00020366c:	00078593          	mv	a1,a5
ffffffe000203670:	f9042783          	lw	a5,-112(s0)
ffffffe000203674:	00078613          	mv	a2,a5
ffffffe000203678:	0006069b          	sext.w	a3,a2
ffffffe00020367c:	0005879b          	sext.w	a5,a1
ffffffe000203680:	00f6d463          	bge	a3,a5,ffffffe000203688 <vprintfmt+0x428>
ffffffe000203684:	00058613          	mv	a2,a1
ffffffe000203688:	0006079b          	sext.w	a5,a2
ffffffe00020368c:	40f707bb          	subw	a5,a4,a5
ffffffe000203690:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203694:	0280006f          	j	ffffffe0002036bc <vprintfmt+0x45c>
                    putch(' ');
ffffffe000203698:	f5843783          	ld	a5,-168(s0)
ffffffe00020369c:	02000513          	li	a0,32
ffffffe0002036a0:	000780e7          	jalr	a5
                    ++written;
ffffffe0002036a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002036a8:	0017879b          	addiw	a5,a5,1
ffffffe0002036ac:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002036b0:	fd842783          	lw	a5,-40(s0)
ffffffe0002036b4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002036b8:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002036bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002036c0:	0007879b          	sext.w	a5,a5
ffffffe0002036c4:	fcf04ae3          	bgtz	a5,ffffffe000203698 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe0002036c8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002036cc:	0ff7f793          	zext.b	a5,a5
ffffffe0002036d0:	04078463          	beqz	a5,ffffffe000203718 <vprintfmt+0x4b8>
                    putch('0');
ffffffe0002036d4:	f5843783          	ld	a5,-168(s0)
ffffffe0002036d8:	03000513          	li	a0,48
ffffffe0002036dc:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe0002036e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002036e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002036e8:	00078713          	mv	a4,a5
ffffffe0002036ec:	05800793          	li	a5,88
ffffffe0002036f0:	00f71663          	bne	a4,a5,ffffffe0002036fc <vprintfmt+0x49c>
ffffffe0002036f4:	05800793          	li	a5,88
ffffffe0002036f8:	0080006f          	j	ffffffe000203700 <vprintfmt+0x4a0>
ffffffe0002036fc:	07800793          	li	a5,120
ffffffe000203700:	f5843703          	ld	a4,-168(s0)
ffffffe000203704:	00078513          	mv	a0,a5
ffffffe000203708:	000700e7          	jalr	a4
                    written += 2;
ffffffe00020370c:	fec42783          	lw	a5,-20(s0)
ffffffe000203710:	0027879b          	addiw	a5,a5,2
ffffffe000203714:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000203718:	fdc42783          	lw	a5,-36(s0)
ffffffe00020371c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203720:	0280006f          	j	ffffffe000203748 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000203724:	f5843783          	ld	a5,-168(s0)
ffffffe000203728:	03000513          	li	a0,48
ffffffe00020372c:	000780e7          	jalr	a5
                    ++written;
ffffffe000203730:	fec42783          	lw	a5,-20(s0)
ffffffe000203734:	0017879b          	addiw	a5,a5,1
ffffffe000203738:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe00020373c:	fd442783          	lw	a5,-44(s0)
ffffffe000203740:	0017879b          	addiw	a5,a5,1
ffffffe000203744:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203748:	f8c42703          	lw	a4,-116(s0)
ffffffe00020374c:	fd442783          	lw	a5,-44(s0)
ffffffe000203750:	0007879b          	sext.w	a5,a5
ffffffe000203754:	fce7c8e3          	blt	a5,a4,ffffffe000203724 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203758:	fdc42783          	lw	a5,-36(s0)
ffffffe00020375c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203760:	fcf42823          	sw	a5,-48(s0)
ffffffe000203764:	03c0006f          	j	ffffffe0002037a0 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000203768:	fd042783          	lw	a5,-48(s0)
ffffffe00020376c:	ff078793          	addi	a5,a5,-16
ffffffe000203770:	008787b3          	add	a5,a5,s0
ffffffe000203774:	f807c783          	lbu	a5,-128(a5)
ffffffe000203778:	0007871b          	sext.w	a4,a5
ffffffe00020377c:	f5843783          	ld	a5,-168(s0)
ffffffe000203780:	00070513          	mv	a0,a4
ffffffe000203784:	000780e7          	jalr	a5
                    ++written;
ffffffe000203788:	fec42783          	lw	a5,-20(s0)
ffffffe00020378c:	0017879b          	addiw	a5,a5,1
ffffffe000203790:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203794:	fd042783          	lw	a5,-48(s0)
ffffffe000203798:	fff7879b          	addiw	a5,a5,-1
ffffffe00020379c:	fcf42823          	sw	a5,-48(s0)
ffffffe0002037a0:	fd042783          	lw	a5,-48(s0)
ffffffe0002037a4:	0007879b          	sext.w	a5,a5
ffffffe0002037a8:	fc07d0e3          	bgez	a5,ffffffe000203768 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe0002037ac:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002037b0:	2700006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002037b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002037b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002037bc:	00078713          	mv	a4,a5
ffffffe0002037c0:	06400793          	li	a5,100
ffffffe0002037c4:	02f70663          	beq	a4,a5,ffffffe0002037f0 <vprintfmt+0x590>
ffffffe0002037c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002037cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002037d0:	00078713          	mv	a4,a5
ffffffe0002037d4:	06900793          	li	a5,105
ffffffe0002037d8:	00f70c63          	beq	a4,a5,ffffffe0002037f0 <vprintfmt+0x590>
ffffffe0002037dc:	f5043783          	ld	a5,-176(s0)
ffffffe0002037e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002037e4:	00078713          	mv	a4,a5
ffffffe0002037e8:	07500793          	li	a5,117
ffffffe0002037ec:	08f71063          	bne	a4,a5,ffffffe00020386c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002037f0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002037f4:	00078c63          	beqz	a5,ffffffe00020380c <vprintfmt+0x5ac>
ffffffe0002037f8:	f4843783          	ld	a5,-184(s0)
ffffffe0002037fc:	00878713          	addi	a4,a5,8
ffffffe000203800:	f4e43423          	sd	a4,-184(s0)
ffffffe000203804:	0007b783          	ld	a5,0(a5)
ffffffe000203808:	0140006f          	j	ffffffe00020381c <vprintfmt+0x5bc>
ffffffe00020380c:	f4843783          	ld	a5,-184(s0)
ffffffe000203810:	00878713          	addi	a4,a5,8
ffffffe000203814:	f4e43423          	sd	a4,-184(s0)
ffffffe000203818:	0007a783          	lw	a5,0(a5)
ffffffe00020381c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000203820:	fa843583          	ld	a1,-88(s0)
ffffffe000203824:	f5043783          	ld	a5,-176(s0)
ffffffe000203828:	0007c783          	lbu	a5,0(a5)
ffffffe00020382c:	0007871b          	sext.w	a4,a5
ffffffe000203830:	07500793          	li	a5,117
ffffffe000203834:	40f707b3          	sub	a5,a4,a5
ffffffe000203838:	00f037b3          	snez	a5,a5
ffffffe00020383c:	0ff7f793          	zext.b	a5,a5
ffffffe000203840:	f8040713          	addi	a4,s0,-128
ffffffe000203844:	00070693          	mv	a3,a4
ffffffe000203848:	00078613          	mv	a2,a5
ffffffe00020384c:	f5843503          	ld	a0,-168(s0)
ffffffe000203850:	f08ff0ef          	jal	ffffffe000202f58 <print_dec_int>
ffffffe000203854:	00050793          	mv	a5,a0
ffffffe000203858:	fec42703          	lw	a4,-20(s0)
ffffffe00020385c:	00f707bb          	addw	a5,a4,a5
ffffffe000203860:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203864:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000203868:	1b80006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe00020386c:	f5043783          	ld	a5,-176(s0)
ffffffe000203870:	0007c783          	lbu	a5,0(a5)
ffffffe000203874:	00078713          	mv	a4,a5
ffffffe000203878:	06e00793          	li	a5,110
ffffffe00020387c:	04f71c63          	bne	a4,a5,ffffffe0002038d4 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000203880:	f8144783          	lbu	a5,-127(s0)
ffffffe000203884:	02078463          	beqz	a5,ffffffe0002038ac <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000203888:	f4843783          	ld	a5,-184(s0)
ffffffe00020388c:	00878713          	addi	a4,a5,8
ffffffe000203890:	f4e43423          	sd	a4,-184(s0)
ffffffe000203894:	0007b783          	ld	a5,0(a5)
ffffffe000203898:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe00020389c:	fec42703          	lw	a4,-20(s0)
ffffffe0002038a0:	fb043783          	ld	a5,-80(s0)
ffffffe0002038a4:	00e7b023          	sd	a4,0(a5)
ffffffe0002038a8:	0240006f          	j	ffffffe0002038cc <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe0002038ac:	f4843783          	ld	a5,-184(s0)
ffffffe0002038b0:	00878713          	addi	a4,a5,8
ffffffe0002038b4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002038b8:	0007b783          	ld	a5,0(a5)
ffffffe0002038bc:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe0002038c0:	fb843783          	ld	a5,-72(s0)
ffffffe0002038c4:	fec42703          	lw	a4,-20(s0)
ffffffe0002038c8:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe0002038cc:	f8040023          	sb	zero,-128(s0)
ffffffe0002038d0:	1500006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe0002038d4:	f5043783          	ld	a5,-176(s0)
ffffffe0002038d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002038dc:	00078713          	mv	a4,a5
ffffffe0002038e0:	07300793          	li	a5,115
ffffffe0002038e4:	02f71e63          	bne	a4,a5,ffffffe000203920 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe0002038e8:	f4843783          	ld	a5,-184(s0)
ffffffe0002038ec:	00878713          	addi	a4,a5,8
ffffffe0002038f0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002038f4:	0007b783          	ld	a5,0(a5)
ffffffe0002038f8:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe0002038fc:	fc043583          	ld	a1,-64(s0)
ffffffe000203900:	f5843503          	ld	a0,-168(s0)
ffffffe000203904:	dccff0ef          	jal	ffffffe000202ed0 <puts_wo_nl>
ffffffe000203908:	00050793          	mv	a5,a0
ffffffe00020390c:	fec42703          	lw	a4,-20(s0)
ffffffe000203910:	00f707bb          	addw	a5,a4,a5
ffffffe000203914:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203918:	f8040023          	sb	zero,-128(s0)
ffffffe00020391c:	1040006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000203920:	f5043783          	ld	a5,-176(s0)
ffffffe000203924:	0007c783          	lbu	a5,0(a5)
ffffffe000203928:	00078713          	mv	a4,a5
ffffffe00020392c:	06300793          	li	a5,99
ffffffe000203930:	02f71e63          	bne	a4,a5,ffffffe00020396c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000203934:	f4843783          	ld	a5,-184(s0)
ffffffe000203938:	00878713          	addi	a4,a5,8
ffffffe00020393c:	f4e43423          	sd	a4,-184(s0)
ffffffe000203940:	0007a783          	lw	a5,0(a5)
ffffffe000203944:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000203948:	fcc42703          	lw	a4,-52(s0)
ffffffe00020394c:	f5843783          	ld	a5,-168(s0)
ffffffe000203950:	00070513          	mv	a0,a4
ffffffe000203954:	000780e7          	jalr	a5
                ++written;
ffffffe000203958:	fec42783          	lw	a5,-20(s0)
ffffffe00020395c:	0017879b          	addiw	a5,a5,1
ffffffe000203960:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203964:	f8040023          	sb	zero,-128(s0)
ffffffe000203968:	0b80006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe00020396c:	f5043783          	ld	a5,-176(s0)
ffffffe000203970:	0007c783          	lbu	a5,0(a5)
ffffffe000203974:	00078713          	mv	a4,a5
ffffffe000203978:	02500793          	li	a5,37
ffffffe00020397c:	02f71263          	bne	a4,a5,ffffffe0002039a0 <vprintfmt+0x740>
                putch('%');
ffffffe000203980:	f5843783          	ld	a5,-168(s0)
ffffffe000203984:	02500513          	li	a0,37
ffffffe000203988:	000780e7          	jalr	a5
                ++written;
ffffffe00020398c:	fec42783          	lw	a5,-20(s0)
ffffffe000203990:	0017879b          	addiw	a5,a5,1
ffffffe000203994:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203998:	f8040023          	sb	zero,-128(s0)
ffffffe00020399c:	0840006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002039a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002039a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002039a8:	0007871b          	sext.w	a4,a5
ffffffe0002039ac:	f5843783          	ld	a5,-168(s0)
ffffffe0002039b0:	00070513          	mv	a0,a4
ffffffe0002039b4:	000780e7          	jalr	a5
                ++written;
ffffffe0002039b8:	fec42783          	lw	a5,-20(s0)
ffffffe0002039bc:	0017879b          	addiw	a5,a5,1
ffffffe0002039c0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002039c4:	f8040023          	sb	zero,-128(s0)
ffffffe0002039c8:	0580006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe0002039cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002039d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002039d4:	00078713          	mv	a4,a5
ffffffe0002039d8:	02500793          	li	a5,37
ffffffe0002039dc:	02f71063          	bne	a4,a5,ffffffe0002039fc <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe0002039e0:	f8043023          	sd	zero,-128(s0)
ffffffe0002039e4:	f8043423          	sd	zero,-120(s0)
ffffffe0002039e8:	00100793          	li	a5,1
ffffffe0002039ec:	f8f40023          	sb	a5,-128(s0)
ffffffe0002039f0:	fff00793          	li	a5,-1
ffffffe0002039f4:	f8f42623          	sw	a5,-116(s0)
ffffffe0002039f8:	0280006f          	j	ffffffe000203a20 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe0002039fc:	f5043783          	ld	a5,-176(s0)
ffffffe000203a00:	0007c783          	lbu	a5,0(a5)
ffffffe000203a04:	0007871b          	sext.w	a4,a5
ffffffe000203a08:	f5843783          	ld	a5,-168(s0)
ffffffe000203a0c:	00070513          	mv	a0,a4
ffffffe000203a10:	000780e7          	jalr	a5
            ++written;
ffffffe000203a14:	fec42783          	lw	a5,-20(s0)
ffffffe000203a18:	0017879b          	addiw	a5,a5,1
ffffffe000203a1c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000203a20:	f5043783          	ld	a5,-176(s0)
ffffffe000203a24:	00178793          	addi	a5,a5,1
ffffffe000203a28:	f4f43823          	sd	a5,-176(s0)
ffffffe000203a2c:	f5043783          	ld	a5,-176(s0)
ffffffe000203a30:	0007c783          	lbu	a5,0(a5)
ffffffe000203a34:	84079ce3          	bnez	a5,ffffffe00020328c <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000203a38:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203a3c:	00078513          	mv	a0,a5
ffffffe000203a40:	0b813083          	ld	ra,184(sp)
ffffffe000203a44:	0b013403          	ld	s0,176(sp)
ffffffe000203a48:	0c010113          	addi	sp,sp,192
ffffffe000203a4c:	00008067          	ret

ffffffe000203a50 <printk>:

int printk(const char* s, ...) {
ffffffe000203a50:	f9010113          	addi	sp,sp,-112
ffffffe000203a54:	02113423          	sd	ra,40(sp)
ffffffe000203a58:	02813023          	sd	s0,32(sp)
ffffffe000203a5c:	03010413          	addi	s0,sp,48
ffffffe000203a60:	fca43c23          	sd	a0,-40(s0)
ffffffe000203a64:	00b43423          	sd	a1,8(s0)
ffffffe000203a68:	00c43823          	sd	a2,16(s0)
ffffffe000203a6c:	00d43c23          	sd	a3,24(s0)
ffffffe000203a70:	02e43023          	sd	a4,32(s0)
ffffffe000203a74:	02f43423          	sd	a5,40(s0)
ffffffe000203a78:	03043823          	sd	a6,48(s0)
ffffffe000203a7c:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000203a80:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000203a84:	04040793          	addi	a5,s0,64
ffffffe000203a88:	fcf43823          	sd	a5,-48(s0)
ffffffe000203a8c:	fd043783          	ld	a5,-48(s0)
ffffffe000203a90:	fc878793          	addi	a5,a5,-56
ffffffe000203a94:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000203a98:	fe043783          	ld	a5,-32(s0)
ffffffe000203a9c:	00078613          	mv	a2,a5
ffffffe000203aa0:	fd843583          	ld	a1,-40(s0)
ffffffe000203aa4:	fffff517          	auipc	a0,0xfffff
ffffffe000203aa8:	11850513          	addi	a0,a0,280 # ffffffe000202bbc <putc>
ffffffe000203aac:	fb4ff0ef          	jal	ffffffe000203260 <vprintfmt>
ffffffe000203ab0:	00050793          	mv	a5,a0
ffffffe000203ab4:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000203ab8:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203abc:	00078513          	mv	a0,a5
ffffffe000203ac0:	02813083          	ld	ra,40(sp)
ffffffe000203ac4:	02013403          	ld	s0,32(sp)
ffffffe000203ac8:	07010113          	addi	sp,sp,112
ffffffe000203acc:	00008067          	ret

ffffffe000203ad0 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000203ad0:	fe010113          	addi	sp,sp,-32
ffffffe000203ad4:	00813c23          	sd	s0,24(sp)
ffffffe000203ad8:	02010413          	addi	s0,sp,32
ffffffe000203adc:	00050793          	mv	a5,a0
ffffffe000203ae0:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000203ae4:	fec42783          	lw	a5,-20(s0)
ffffffe000203ae8:	fff7879b          	addiw	a5,a5,-1
ffffffe000203aec:	0007879b          	sext.w	a5,a5
ffffffe000203af0:	02079713          	slli	a4,a5,0x20
ffffffe000203af4:	02075713          	srli	a4,a4,0x20
ffffffe000203af8:	00005797          	auipc	a5,0x5
ffffffe000203afc:	52078793          	addi	a5,a5,1312 # ffffffe000209018 <seed>
ffffffe000203b00:	00e7b023          	sd	a4,0(a5)
}
ffffffe000203b04:	00000013          	nop
ffffffe000203b08:	01813403          	ld	s0,24(sp)
ffffffe000203b0c:	02010113          	addi	sp,sp,32
ffffffe000203b10:	00008067          	ret

ffffffe000203b14 <rand>:

int rand(void) {
ffffffe000203b14:	ff010113          	addi	sp,sp,-16
ffffffe000203b18:	00813423          	sd	s0,8(sp)
ffffffe000203b1c:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000203b20:	00005797          	auipc	a5,0x5
ffffffe000203b24:	4f878793          	addi	a5,a5,1272 # ffffffe000209018 <seed>
ffffffe000203b28:	0007b703          	ld	a4,0(a5)
ffffffe000203b2c:	00001797          	auipc	a5,0x1
ffffffe000203b30:	b0c78793          	addi	a5,a5,-1268 # ffffffe000204638 <lowerxdigits.0+0x18>
ffffffe000203b34:	0007b783          	ld	a5,0(a5)
ffffffe000203b38:	02f707b3          	mul	a5,a4,a5
ffffffe000203b3c:	00178713          	addi	a4,a5,1
ffffffe000203b40:	00005797          	auipc	a5,0x5
ffffffe000203b44:	4d878793          	addi	a5,a5,1240 # ffffffe000209018 <seed>
ffffffe000203b48:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000203b4c:	00005797          	auipc	a5,0x5
ffffffe000203b50:	4cc78793          	addi	a5,a5,1228 # ffffffe000209018 <seed>
ffffffe000203b54:	0007b783          	ld	a5,0(a5)
ffffffe000203b58:	0217d793          	srli	a5,a5,0x21
ffffffe000203b5c:	0007879b          	sext.w	a5,a5
}
ffffffe000203b60:	00078513          	mv	a0,a5
ffffffe000203b64:	00813403          	ld	s0,8(sp)
ffffffe000203b68:	01010113          	addi	sp,sp,16
ffffffe000203b6c:	00008067          	ret

ffffffe000203b70 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000203b70:	fc010113          	addi	sp,sp,-64
ffffffe000203b74:	02813c23          	sd	s0,56(sp)
ffffffe000203b78:	04010413          	addi	s0,sp,64
ffffffe000203b7c:	fca43c23          	sd	a0,-40(s0)
ffffffe000203b80:	00058793          	mv	a5,a1
ffffffe000203b84:	fcc43423          	sd	a2,-56(s0)
ffffffe000203b88:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000203b8c:	fd843783          	ld	a5,-40(s0)
ffffffe000203b90:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203b94:	fe043423          	sd	zero,-24(s0)
ffffffe000203b98:	0280006f          	j	ffffffe000203bc0 <memset+0x50>
        s[i] = c;
ffffffe000203b9c:	fe043703          	ld	a4,-32(s0)
ffffffe000203ba0:	fe843783          	ld	a5,-24(s0)
ffffffe000203ba4:	00f707b3          	add	a5,a4,a5
ffffffe000203ba8:	fd442703          	lw	a4,-44(s0)
ffffffe000203bac:	0ff77713          	zext.b	a4,a4
ffffffe000203bb0:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203bb4:	fe843783          	ld	a5,-24(s0)
ffffffe000203bb8:	00178793          	addi	a5,a5,1
ffffffe000203bbc:	fef43423          	sd	a5,-24(s0)
ffffffe000203bc0:	fe843703          	ld	a4,-24(s0)
ffffffe000203bc4:	fc843783          	ld	a5,-56(s0)
ffffffe000203bc8:	fcf76ae3          	bltu	a4,a5,ffffffe000203b9c <memset+0x2c>
    }
    return dest;
ffffffe000203bcc:	fd843783          	ld	a5,-40(s0)
}
ffffffe000203bd0:	00078513          	mv	a0,a5
ffffffe000203bd4:	03813403          	ld	s0,56(sp)
ffffffe000203bd8:	04010113          	addi	sp,sp,64
ffffffe000203bdc:	00008067          	ret
