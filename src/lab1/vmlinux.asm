
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern start_kernel
    .section .text.init     # 从.text.entry 改为 .text.init
    .globl _start
_start: # entry
    # (previous) initialize stack :set sp(stack pointer) point at the top of the stack
    la sp,boot_stack_top    
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    
    # set stvec = _traps :将 _traps 所表示的地址写入 stvec
    la t0,_traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec,t0
    80200010:	10529073          	csrw	stvec,t0

    # set sie[STIE] = 1  :开启时钟中断，将 sie[STIE] 置 1
    csrr t0,sie             # 读取sie寄存器的值
    80200014:	104022f3          	csrr	t0,sie
    ori t1,t0,1<<5          # 将sie寄存器值的第五位置1，结果写入t1
    80200018:	0202e313          	ori	t1,t0,32
    csrw sie,t1             # 将更改后的值保存回sie寄存器
    8020001c:	10431073          	csrw	sie,t1

    #  set first time interrupt :设置第一次时钟中断
    call sbi_set_timer  #j
    80200020:	3cc000ef          	jal	802003ec <sbi_set_timer>

    # set sstatus[SIE] = 1 :开启 S 态下的中断响应，将 sstatus[SIE] 置 1
    csrr t0,sstatus
    80200024:	100022f3          	csrr	t0,sstatus
    ori t1,t0,1<<1
    80200028:	0022e313          	ori	t1,t0,2
    csrw sstatus,t1
    8020002c:	10031073          	csrw	sstatus,t1

    # (previous) jump to start_kernel:jump to main.c start_kernel function
    j start_kernel        
    80200030:	5700006f          	j	802005a0 <start_kernel>

0000000080200034 <_traps>:
    .align 2
    .globl _traps 
_traps:

    # 1. save 32 registers and sepc to stack:保存 CPU 的寄存器（上下文）到内存中（栈上）
    addi sp,sp,-264
    80200034:	ef810113          	addi	sp,sp,-264

    sd x0,0(sp)     #0
    80200038:	00013023          	sd	zero,0(sp)
    sd x1,8(sp)     #ra
    8020003c:	00113423          	sd	ra,8(sp)
    sd x2,16(sp)    #sp
    80200040:	00213823          	sd	sp,16(sp)
    sd x3,24(sp)    #gp
    80200044:	00313c23          	sd	gp,24(sp)
    sd x4,32(sp)    #tp
    80200048:	02413023          	sd	tp,32(sp)
    sd x5,40(sp)    #t0
    8020004c:	02513423          	sd	t0,40(sp)
    sd x6,48(sp)
    80200050:	02613823          	sd	t1,48(sp)
    sd x7,56(sp)
    80200054:	02713c23          	sd	t2,56(sp)
    sd x8,64(sp)    #s0/fp
    80200058:	04813023          	sd	s0,64(sp)
    sd x9,72(sp)    #s1
    8020005c:	04913423          	sd	s1,72(sp)
    sd x10,80(sp)   #a0
    80200060:	04a13823          	sd	a0,80(sp)
    sd x11,88(sp)
    80200064:	04b13c23          	sd	a1,88(sp)
    sd x12,96(sp)
    80200068:	06c13023          	sd	a2,96(sp)
    sd x13,104(sp)
    8020006c:	06d13423          	sd	a3,104(sp)
    sd x14,112(sp)
    80200070:	06e13823          	sd	a4,112(sp)
    sd x15,120(sp)
    80200074:	06f13c23          	sd	a5,120(sp)
    sd x16,128(sp)
    80200078:	09013023          	sd	a6,128(sp)
    sd x17,136(sp)
    8020007c:	09113423          	sd	a7,136(sp)
    sd x18,144(sp)  #s2
    80200080:	09213823          	sd	s2,144(sp)
    sd x19,152(sp)
    80200084:	09313c23          	sd	s3,152(sp)
    sd x20,160(sp)
    80200088:	0b413023          	sd	s4,160(sp)
    sd x21,168(sp)
    8020008c:	0b513423          	sd	s5,168(sp)
    sd x22,176(sp)
    80200090:	0b613823          	sd	s6,176(sp)
    sd x23,184(sp)
    80200094:	0b713c23          	sd	s7,184(sp)
    sd x24,192(sp)
    80200098:	0d813023          	sd	s8,192(sp)
    sd x25,200(sp)
    8020009c:	0d913423          	sd	s9,200(sp)
    sd x26,208(sp)
    802000a0:	0da13823          	sd	s10,208(sp)
    sd x27,216(sp)
    802000a4:	0db13c23          	sd	s11,216(sp)
    sd x28,224(sp)  #t3
    802000a8:	0fc13023          	sd	t3,224(sp)
    sd x29,232(sp)
    802000ac:	0fd13423          	sd	t4,232(sp)
    sd x30,240(sp)
    802000b0:	0fe13823          	sd	t5,240(sp)
    sd x31,248(sp)
    802000b4:	0ff13c23          	sd	t6,248(sp)
    
    csrr t0,sepc        # store sepc
    802000b8:	141022f3          	csrr	t0,sepc
    sd t0,256(sp)
    802000bc:	10513023          	sd	t0,256(sp)

    # 2. call trap_handler:将 scause 和 sepc 中的值传入 trap 处理函数 trap_handler
    csrr a0,scause
    802000c0:	14202573          	csrr	a0,scause
    csrr a1,sepc
    802000c4:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000c8:	3d8000ef          	jal	802004a0 <trap_handler>
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack:从内存中（栈上）恢复 CPU 的寄存器（上下文）
    ld t0,256(sp)
    802000cc:	10013283          	ld	t0,256(sp)
    csrw sepc,t0
    802000d0:	14129073          	csrw	sepc,t0
    
    ld x0,0(sp)
    802000d4:	00013003          	ld	zero,0(sp)
    ld x1,8(sp)
    802000d8:	00813083          	ld	ra,8(sp)
    ld x3,24(sp)
    802000dc:	01813183          	ld	gp,24(sp)
    ld x4,32(sp)
    802000e0:	02013203          	ld	tp,32(sp)
    ld x5,40(sp)
    802000e4:	02813283          	ld	t0,40(sp)
    ld x6,48(sp)
    802000e8:	03013303          	ld	t1,48(sp)
    ld x7,56(sp)
    802000ec:	03813383          	ld	t2,56(sp)
    ld x8,64(sp)
    802000f0:	04013403          	ld	s0,64(sp)
    ld x9,72(sp)
    802000f4:	04813483          	ld	s1,72(sp)
    ld x10,80(sp)
    802000f8:	05013503          	ld	a0,80(sp)
    ld x11,88(sp)
    802000fc:	05813583          	ld	a1,88(sp)
    ld x12,96(sp)
    80200100:	06013603          	ld	a2,96(sp)
    ld x13,104(sp)
    80200104:	06813683          	ld	a3,104(sp)
    ld x14,112(sp)
    80200108:	07013703          	ld	a4,112(sp)
    ld x15,120(sp)
    8020010c:	07813783          	ld	a5,120(sp)
    ld x16,128(sp)
    80200110:	08013803          	ld	a6,128(sp)
    ld x17,136(sp)
    80200114:	08813883          	ld	a7,136(sp)
    ld x18,144(sp)
    80200118:	09013903          	ld	s2,144(sp)
    ld x19,152(sp)
    8020011c:	09813983          	ld	s3,152(sp)
    ld x20,160(sp)
    80200120:	0a013a03          	ld	s4,160(sp)
    ld x21,168(sp)
    80200124:	0a813a83          	ld	s5,168(sp)
    ld x22,176(sp)
    80200128:	0b013b03          	ld	s6,176(sp)
    ld x23,184(sp)
    8020012c:	0b813b83          	ld	s7,184(sp)
    ld x24,192(sp)
    80200130:	0c013c03          	ld	s8,192(sp)
    ld x25,200(sp)
    80200134:	0c813c83          	ld	s9,200(sp)
    ld x26,208(sp)
    80200138:	0d013d03          	ld	s10,208(sp)
    ld x27,216(sp)
    8020013c:	0d813d83          	ld	s11,216(sp)
    ld x28,224(sp)
    80200140:	0e013e03          	ld	t3,224(sp)
    ld x29,232(sp)
    80200144:	0e813e83          	ld	t4,232(sp)
    ld x30,240(sp)
    80200148:	0f013f03          	ld	t5,240(sp)
    ld x31,248(sp)
    8020014c:	0f813f83          	ld	t6,248(sp)

    ld x2,16(sp)
    80200150:	01013103          	ld	sp,16(sp)

    addi sp,sp,264
    80200154:	10810113          	addi	sp,sp,264

    # 4. return from trap:从 trap 中返回
    80200158:	10200073          	sret

000000008020015c <get_cycles>:
#include "clock.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020015c:	fe010113          	addi	sp,sp,-32
    80200160:	00813c23          	sd	s0,24(sp)
    80200164:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    unsigned long time_get;
    __asm__ volatile (
    80200168:	c01027f3          	rdtime	a5
    8020016c:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time_get]"
        :[time_get]"=r"(time_get)
    );
    return time_get;
    80200170:	fe843783          	ld	a5,-24(s0)
}
    80200174:	00078513          	mv	a0,a5
    80200178:	01813403          	ld	s0,24(sp)
    8020017c:	02010113          	addi	sp,sp,32
    80200180:	00008067          	ret

0000000080200184 <clock_set_next_event>:

void clock_set_next_event() {
    80200184:	fe010113          	addi	sp,sp,-32
    80200188:	00113c23          	sd	ra,24(sp)
    8020018c:	00813823          	sd	s0,16(sp)
    80200190:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200194:	fc9ff0ef          	jal	8020015c <get_cycles>
    80200198:	00050713          	mv	a4,a0
    8020019c:	00003797          	auipc	a5,0x3
    802001a0:	e6478793          	addi	a5,a5,-412 # 80203000 <TIMECLOCK>
    802001a4:	0007b783          	ld	a5,0(a5)
    802001a8:	00f707b3          	add	a5,a4,a5
    802001ac:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001b0:	fe843503          	ld	a0,-24(s0)
    802001b4:	238000ef          	jal	802003ec <sbi_set_timer>
    802001b8:	00000013          	nop
    802001bc:	01813083          	ld	ra,24(sp)
    802001c0:	01013403          	ld	s0,16(sp)
    802001c4:	02010113          	addi	sp,sp,32
    802001c8:	00008067          	ret

00000000802001cc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001cc:	f8010113          	addi	sp,sp,-128
    802001d0:	06813c23          	sd	s0,120(sp)
    802001d4:	06913823          	sd	s1,112(sp)
    802001d8:	07213423          	sd	s2,104(sp)
    802001dc:	07313023          	sd	s3,96(sp)
    802001e0:	08010413          	addi	s0,sp,128
    802001e4:	faa43c23          	sd	a0,-72(s0)
    802001e8:	fab43823          	sd	a1,-80(s0)
    802001ec:	fac43423          	sd	a2,-88(s0)
    802001f0:	fad43023          	sd	a3,-96(s0)
    802001f4:	f8e43c23          	sd	a4,-104(s0)
    802001f8:	f8f43823          	sd	a5,-112(s0)
    802001fc:	f9043423          	sd	a6,-120(s0)
    80200200:	f9143023          	sd	a7,-128(s0)
    struct sbiret result;   //用 sbiret 来接受两个返回值
    
    __asm__ volatile ( 
    80200204:	fb843e03          	ld	t3,-72(s0)
    80200208:	fb043e83          	ld	t4,-80(s0)
    8020020c:	f8043f03          	ld	t5,-128(s0)
    80200210:	f8843f83          	ld	t6,-120(s0)
    80200214:	f9043283          	ld	t0,-112(s0)
    80200218:	f9843483          	ld	s1,-104(s0)
    8020021c:	fa043903          	ld	s2,-96(s0)
    80200220:	fa843983          	ld	s3,-88(s0)
    80200224:	000e0893          	mv	a7,t3
    80200228:	000e8813          	mv	a6,t4
    8020022c:	000f0793          	mv	a5,t5
    80200230:	000f8713          	mv	a4,t6
    80200234:	00028693          	mv	a3,t0
    80200238:	00048613          	mv	a2,s1
    8020023c:	00090593          	mv	a1,s2
    80200240:	00098513          	mv	a0,s3
    80200244:	00000073          	ecall
    80200248:	00050e93          	mv	t4,a0
    8020024c:	00058e13          	mv	t3,a1
    80200250:	fdd43023          	sd	t4,-64(s0)
    80200254:	fdc43423          	sd	t3,-56(s0)
        :[error]"=r"(result.error),[value]"=r"(result.value)
        :[eid]"r"(eid),[fid]"r"(fid),[arg5]"r"(arg5),[arg4]"r"(arg4),[arg3]"r"(arg3),[arg2]"r"(arg2),[arg1]"r"(arg1),[arg0]"r"(arg0)
        :"a0","a1","a2","a3","a4","a5","a6","a7"
    );

    return result;
    80200258:	fc043783          	ld	a5,-64(s0)
    8020025c:	fcf43823          	sd	a5,-48(s0)
    80200260:	fc843783          	ld	a5,-56(s0)
    80200264:	fcf43c23          	sd	a5,-40(s0)
    80200268:	fd043703          	ld	a4,-48(s0)
    8020026c:	fd843783          	ld	a5,-40(s0)
    80200270:	00070313          	mv	t1,a4
    80200274:	00078393          	mv	t2,a5
    80200278:	00030713          	mv	a4,t1
    8020027c:	00038793          	mv	a5,t2
}
    80200280:	00070513          	mv	a0,a4
    80200284:	00078593          	mv	a1,a5
    80200288:	07813403          	ld	s0,120(sp)
    8020028c:	07013483          	ld	s1,112(sp)
    80200290:	06813903          	ld	s2,104(sp)
    80200294:	06013983          	ld	s3,96(sp)
    80200298:	08010113          	addi	sp,sp,128
    8020029c:	00008067          	ret

00000000802002a0 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    802002a0:	fb010113          	addi	sp,sp,-80
    802002a4:	04113423          	sd	ra,72(sp)
    802002a8:	04813023          	sd	s0,64(sp)
    802002ac:	03213c23          	sd	s2,56(sp)
    802002b0:	03313823          	sd	s3,48(sp)
    802002b4:	05010413          	addi	s0,sp,80
    802002b8:	00050793          	mv	a5,a0
    802002bc:	faf40fa3          	sb	a5,-65(s0)
    struct sbiret result=sbi_ecall(SBI_EID_DEBUG_CONSOLE_WRITE_BYTE,SBI_FID_DEBUG_CONSOLE_WRITE_BYTE,byte,0,0,0,0,0);
    802002c0:	fbf44603          	lbu	a2,-65(s0)
    802002c4:	00000893          	li	a7,0
    802002c8:	00000813          	li	a6,0
    802002cc:	00000793          	li	a5,0
    802002d0:	00000713          	li	a4,0
    802002d4:	00000693          	li	a3,0
    802002d8:	00200593          	li	a1,2
    802002dc:	44424537          	lui	a0,0x44424
    802002e0:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    802002e4:	ee9ff0ef          	jal	802001cc <sbi_ecall>
    802002e8:	00050713          	mv	a4,a0
    802002ec:	00058793          	mv	a5,a1
    802002f0:	fce43023          	sd	a4,-64(s0)
    802002f4:	fcf43423          	sd	a5,-56(s0)
    return result;
    802002f8:	fc043783          	ld	a5,-64(s0)
    802002fc:	fcf43823          	sd	a5,-48(s0)
    80200300:	fc843783          	ld	a5,-56(s0)
    80200304:	fcf43c23          	sd	a5,-40(s0)
    80200308:	fd043703          	ld	a4,-48(s0)
    8020030c:	fd843783          	ld	a5,-40(s0)
    80200310:	00070913          	mv	s2,a4
    80200314:	00078993          	mv	s3,a5
    80200318:	00090713          	mv	a4,s2
    8020031c:	00098793          	mv	a5,s3
}
    80200320:	00070513          	mv	a0,a4
    80200324:	00078593          	mv	a1,a5
    80200328:	04813083          	ld	ra,72(sp)
    8020032c:	04013403          	ld	s0,64(sp)
    80200330:	03813903          	ld	s2,56(sp)
    80200334:	03013983          	ld	s3,48(sp)
    80200338:	05010113          	addi	sp,sp,80
    8020033c:	00008067          	ret

0000000080200340 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200340:	fb010113          	addi	sp,sp,-80
    80200344:	04113423          	sd	ra,72(sp)
    80200348:	04813023          	sd	s0,64(sp)
    8020034c:	03213c23          	sd	s2,56(sp)
    80200350:	03313823          	sd	s3,48(sp)
    80200354:	05010413          	addi	s0,sp,80
    80200358:	00050793          	mv	a5,a0
    8020035c:	00058713          	mv	a4,a1
    80200360:	faf42e23          	sw	a5,-68(s0)
    80200364:	00070793          	mv	a5,a4
    80200368:	faf42c23          	sw	a5,-72(s0)
    struct sbiret result=sbi_ecall(SBI_EID_RESET_TYPE_SHUTDOWN,SBI_SRST_RESET_REASON_NONE,reset_type,reset_reason,0,0,0,0);
    8020036c:	fbc46603          	lwu	a2,-68(s0)
    80200370:	fb846683          	lwu	a3,-72(s0)
    80200374:	00000893          	li	a7,0
    80200378:	00000813          	li	a6,0
    8020037c:	00000793          	li	a5,0
    80200380:	00000713          	li	a4,0
    80200384:	00000593          	li	a1,0
    80200388:	53525537          	lui	a0,0x53525
    8020038c:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200390:	e3dff0ef          	jal	802001cc <sbi_ecall>
    80200394:	00050713          	mv	a4,a0
    80200398:	00058793          	mv	a5,a1
    8020039c:	fce43023          	sd	a4,-64(s0)
    802003a0:	fcf43423          	sd	a5,-56(s0)
    return result;
    802003a4:	fc043783          	ld	a5,-64(s0)
    802003a8:	fcf43823          	sd	a5,-48(s0)
    802003ac:	fc843783          	ld	a5,-56(s0)
    802003b0:	fcf43c23          	sd	a5,-40(s0)
    802003b4:	fd043703          	ld	a4,-48(s0)
    802003b8:	fd843783          	ld	a5,-40(s0)
    802003bc:	00070913          	mv	s2,a4
    802003c0:	00078993          	mv	s3,a5
    802003c4:	00090713          	mv	a4,s2
    802003c8:	00098793          	mv	a5,s3
}
    802003cc:	00070513          	mv	a0,a4
    802003d0:	00078593          	mv	a1,a5
    802003d4:	04813083          	ld	ra,72(sp)
    802003d8:	04013403          	ld	s0,64(sp)
    802003dc:	03813903          	ld	s2,56(sp)
    802003e0:	03013983          	ld	s3,48(sp)
    802003e4:	05010113          	addi	sp,sp,80
    802003e8:	00008067          	ret

00000000802003ec <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value)
{
    802003ec:	fa010113          	addi	sp,sp,-96
    802003f0:	04113c23          	sd	ra,88(sp)
    802003f4:	04813823          	sd	s0,80(sp)
    802003f8:	05213423          	sd	s2,72(sp)
    802003fc:	05313023          	sd	s3,64(sp)
    80200400:	06010413          	addi	s0,sp,96
    80200404:	faa43423          	sd	a0,-88(s0)
    unsigned long time_final;
    __asm__ volatile(
    80200408:	c01022f3          	rdtime	t0
    8020040c:	00989337          	lui	t1,0x989
    80200410:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    80200414:	006282b3          	add	t0,t0,t1
    80200418:	00028793          	mv	a5,t0
    8020041c:	fcf43c23          	sd	a5,-40(s0)
        "add t0,t0,t1 \n"
        "mv %[time_final],t0 \n"
        : [time_final]"=r"(time_final)
    );

    struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,time_final,0,0,0,0,0);
    80200420:	00000893          	li	a7,0
    80200424:	00000813          	li	a6,0
    80200428:	00000793          	li	a5,0
    8020042c:	00000713          	li	a4,0
    80200430:	00000693          	li	a3,0
    80200434:	fd843603          	ld	a2,-40(s0)
    80200438:	00000593          	li	a1,0
    8020043c:	54495537          	lui	a0,0x54495
    80200440:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200444:	d89ff0ef          	jal	802001cc <sbi_ecall>
    80200448:	00050713          	mv	a4,a0
    8020044c:	00058793          	mv	a5,a1
    80200450:	fae43c23          	sd	a4,-72(s0)
    80200454:	fcf43023          	sd	a5,-64(s0)
    //struct sbiret result=sbi_ecall(SBI_EID_SET_TIMER,SBI_FID_SET_TIMER,stime_value,0,0,0,0,0);
    return result;
    80200458:	fb843783          	ld	a5,-72(s0)
    8020045c:	fcf43423          	sd	a5,-56(s0)
    80200460:	fc043783          	ld	a5,-64(s0)
    80200464:	fcf43823          	sd	a5,-48(s0)
    80200468:	fc843703          	ld	a4,-56(s0)
    8020046c:	fd043783          	ld	a5,-48(s0)
    80200470:	00070913          	mv	s2,a4
    80200474:	00078993          	mv	s3,a5
    80200478:	00090713          	mv	a4,s2
    8020047c:	00098793          	mv	a5,s3
    80200480:	00070513          	mv	a0,a4
    80200484:	00078593          	mv	a1,a5
    80200488:	05813083          	ld	ra,88(sp)
    8020048c:	05013403          	ld	s0,80(sp)
    80200490:	04813903          	ld	s2,72(sp)
    80200494:	04013983          	ld	s3,64(sp)
    80200498:	06010113          	addi	sp,sp,96
    8020049c:	00008067          	ret

00000000802004a0 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    802004a0:	fe010113          	addi	sp,sp,-32
    802004a4:	00113c23          	sd	ra,24(sp)
    802004a8:	00813823          	sd	s0,16(sp)
    802004ac:	02010413          	addi	s0,sp,32
    802004b0:	fea43423          	sd	a0,-24(s0)
    802004b4:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断 trap 类型
    if((scause>>63)==1)
    802004b8:	fe843783          	ld	a5,-24(s0)
    802004bc:	03f7d713          	srli	a4,a5,0x3f
    802004c0:	00100793          	li	a5,1
    802004c4:	0cf71463          	bne	a4,a5,8020058c <trap_handler+0xec>
    {
        // 如果是 interrupt 判断是否是 timer interrupt
        if(((scause<<1)>>1)==5)
    802004c8:	fe843703          	ld	a4,-24(s0)
    802004cc:	fff00793          	li	a5,-1
    802004d0:	0017d793          	srli	a5,a5,0x1
    802004d4:	00f77733          	and	a4,a4,a5
    802004d8:	00500793          	li	a5,5
    802004dc:	02f71063          	bne	a4,a5,802004fc <trap_handler+0x5c>
        {
            // 如果是 timer interrupt 则打印输出相关信息
            printk("%s\n","[S] Supervisor Mode Timer Interrupt");
    802004e0:	00002597          	auipc	a1,0x2
    802004e4:	b2058593          	addi	a1,a1,-1248 # 80202000 <_srodata>
    802004e8:	00002517          	auipc	a0,0x2
    802004ec:	b4050513          	addi	a0,a0,-1216 # 80202028 <_srodata+0x28>
    802004f0:	02c010ef          	jal	8020151c <printk>
            // 通过 `clock_set_next_event()` 设置下一次时钟中断
            clock_set_next_event();
    802004f4:	c91ff0ef          	jal	80200184 <clock_set_next_event>
        {
            printk("%s\n","[S] Counter-overflow Interrupt");
        }
    }
    
    return;
    802004f8:	0940006f          	j	8020058c <trap_handler+0xec>
        }else if(((scause<<1)>>1)==1)
    802004fc:	fe843703          	ld	a4,-24(s0)
    80200500:	fff00793          	li	a5,-1
    80200504:	0017d793          	srli	a5,a5,0x1
    80200508:	00f77733          	and	a4,a4,a5
    8020050c:	00100793          	li	a5,1
    80200510:	00f71e63          	bne	a4,a5,8020052c <trap_handler+0x8c>
            printk("%s\n","[S] Supervisor Mode Software Interrupt");
    80200514:	00002597          	auipc	a1,0x2
    80200518:	b1c58593          	addi	a1,a1,-1252 # 80202030 <_srodata+0x30>
    8020051c:	00002517          	auipc	a0,0x2
    80200520:	b0c50513          	addi	a0,a0,-1268 # 80202028 <_srodata+0x28>
    80200524:	7f9000ef          	jal	8020151c <printk>
    return;
    80200528:	0640006f          	j	8020058c <trap_handler+0xec>
        }else if(((scause<<1)>>1)==9)
    8020052c:	fe843703          	ld	a4,-24(s0)
    80200530:	fff00793          	li	a5,-1
    80200534:	0017d793          	srli	a5,a5,0x1
    80200538:	00f77733          	and	a4,a4,a5
    8020053c:	00900793          	li	a5,9
    80200540:	00f71e63          	bne	a4,a5,8020055c <trap_handler+0xbc>
            printk("%s\n","[S] Supervisor Mode External Interrupt");
    80200544:	00002597          	auipc	a1,0x2
    80200548:	b1458593          	addi	a1,a1,-1260 # 80202058 <_srodata+0x58>
    8020054c:	00002517          	auipc	a0,0x2
    80200550:	adc50513          	addi	a0,a0,-1316 # 80202028 <_srodata+0x28>
    80200554:	7c9000ef          	jal	8020151c <printk>
    return;
    80200558:	0340006f          	j	8020058c <trap_handler+0xec>
        }else if(((scause<<1)>>1)==13)
    8020055c:	fe843703          	ld	a4,-24(s0)
    80200560:	fff00793          	li	a5,-1
    80200564:	0017d793          	srli	a5,a5,0x1
    80200568:	00f77733          	and	a4,a4,a5
    8020056c:	00d00793          	li	a5,13
    80200570:	00f71e63          	bne	a4,a5,8020058c <trap_handler+0xec>
            printk("%s\n","[S] Counter-overflow Interrupt");
    80200574:	00002597          	auipc	a1,0x2
    80200578:	b0c58593          	addi	a1,a1,-1268 # 80202080 <_srodata+0x80>
    8020057c:	00002517          	auipc	a0,0x2
    80200580:	aac50513          	addi	a0,a0,-1364 # 80202028 <_srodata+0x28>
    80200584:	799000ef          	jal	8020151c <printk>
    return;
    80200588:	00000013          	nop
    8020058c:	00000013          	nop
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    80200590:	01813083          	ld	ra,24(sp)
    80200594:	01013403          	ld	s0,16(sp)
    80200598:	02010113          	addi	sp,sp,32
    8020059c:	00008067          	ret

00000000802005a0 <start_kernel>:
#include "stdint.h"
#include "defs.h"

extern void test();

int start_kernel() {
    802005a0:	fc010113          	addi	sp,sp,-64
    802005a4:	02113c23          	sd	ra,56(sp)
    802005a8:	02813823          	sd	s0,48(sp)
    802005ac:	04010413          	addi	s0,sp,64
    printk("2024");
    802005b0:	00002517          	auipc	a0,0x2
    802005b4:	af050513          	addi	a0,a0,-1296 # 802020a0 <_srodata+0xa0>
    802005b8:	765000ef          	jal	8020151c <printk>
    printk(" ZJU Operating System\n");
    802005bc:	00002517          	auipc	a0,0x2
    802005c0:	aec50513          	addi	a0,a0,-1300 # 802020a8 <_srodata+0xa8>
    802005c4:	759000ef          	jal	8020151c <printk>

    //用 csr_read 宏读取 sstatus 寄存器的值
    uint64_t sstatus_val1 = csr_read(sstatus);
    802005c8:	100027f3          	csrr	a5,sstatus
    802005cc:	fef43423          	sd	a5,-24(s0)
    802005d0:	fe843783          	ld	a5,-24(s0)
    802005d4:	fef43023          	sd	a5,-32(s0)
    printk("sstatus: %lx\n", sstatus_val1);
    802005d8:	fe043583          	ld	a1,-32(s0)
    802005dc:	00002517          	auipc	a0,0x2
    802005e0:	ae450513          	addi	a0,a0,-1308 # 802020c0 <_srodata+0xc0>
    802005e4:	739000ef          	jal	8020151c <printk>

    //用 csr_write 宏向 sscratch 寄存器写入数据
    csr_write(sscratch, 0x12345678);
    802005e8:	123457b7          	lui	a5,0x12345
    802005ec:	67878793          	addi	a5,a5,1656 # 12345678 <_skernel-0x6deba988>
    802005f0:	fcf43c23          	sd	a5,-40(s0)
    802005f4:	fd843783          	ld	a5,-40(s0)
    802005f8:	14079073          	csrw	sscratch,a5
    uint64_t sstatus_val2 = csr_read(sscratch);
    802005fc:	140027f3          	csrr	a5,sscratch
    80200600:	fcf43823          	sd	a5,-48(s0)
    80200604:	fd043783          	ld	a5,-48(s0)
    80200608:	fcf43423          	sd	a5,-56(s0)
    printk("sscratch: %lx\n", sstatus_val2);
    8020060c:	fc843583          	ld	a1,-56(s0)
    80200610:	00002517          	auipc	a0,0x2
    80200614:	ac050513          	addi	a0,a0,-1344 # 802020d0 <_srodata+0xd0>
    80200618:	705000ef          	jal	8020151c <printk>

    test();
    8020061c:	01c000ef          	jal	80200638 <test>
    return 0;
    80200620:	00000793          	li	a5,0
}
    80200624:	00078513          	mv	a0,a5
    80200628:	03813083          	ld	ra,56(sp)
    8020062c:	03013403          	ld	s0,48(sp)
    80200630:	04010113          	addi	sp,sp,64
    80200634:	00008067          	ret

0000000080200638 <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }
#include "printk.h"

void test() {
    80200638:	fe010113          	addi	sp,sp,-32
    8020063c:	00113c23          	sd	ra,24(sp)
    80200640:	00813823          	sd	s0,16(sp)
    80200644:	02010413          	addi	s0,sp,32
    int i = 0;
    80200648:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    8020064c:	fec42783          	lw	a5,-20(s0)
    80200650:	0017879b          	addiw	a5,a5,1
    80200654:	fef42623          	sw	a5,-20(s0)
    80200658:	fec42783          	lw	a5,-20(s0)
    8020065c:	00078713          	mv	a4,a5
    80200660:	05f5e7b7          	lui	a5,0x5f5e
    80200664:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    80200668:	02f767bb          	remw	a5,a4,a5
    8020066c:	0007879b          	sext.w	a5,a5
    80200670:	fc079ee3          	bnez	a5,8020064c <test+0x14>
            printk("kernel is running!\n");
    80200674:	00002517          	auipc	a0,0x2
    80200678:	a6c50513          	addi	a0,a0,-1428 # 802020e0 <_srodata+0xe0>
    8020067c:	6a1000ef          	jal	8020151c <printk>
            i = 0;
    80200680:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200684:	fc9ff06f          	j	8020064c <test+0x14>

0000000080200688 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200688:	fe010113          	addi	sp,sp,-32
    8020068c:	00113c23          	sd	ra,24(sp)
    80200690:	00813823          	sd	s0,16(sp)
    80200694:	02010413          	addi	s0,sp,32
    80200698:	00050793          	mv	a5,a0
    8020069c:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    802006a0:	fec42783          	lw	a5,-20(s0)
    802006a4:	0ff7f793          	zext.b	a5,a5
    802006a8:	00078513          	mv	a0,a5
    802006ac:	bf5ff0ef          	jal	802002a0 <sbi_debug_console_write_byte>
    return (char)c;
    802006b0:	fec42783          	lw	a5,-20(s0)
    802006b4:	0ff7f793          	zext.b	a5,a5
    802006b8:	0007879b          	sext.w	a5,a5
}
    802006bc:	00078513          	mv	a0,a5
    802006c0:	01813083          	ld	ra,24(sp)
    802006c4:	01013403          	ld	s0,16(sp)
    802006c8:	02010113          	addi	sp,sp,32
    802006cc:	00008067          	ret

00000000802006d0 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    802006d0:	fe010113          	addi	sp,sp,-32
    802006d4:	00813c23          	sd	s0,24(sp)
    802006d8:	02010413          	addi	s0,sp,32
    802006dc:	00050793          	mv	a5,a0
    802006e0:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    802006e4:	fec42783          	lw	a5,-20(s0)
    802006e8:	0007871b          	sext.w	a4,a5
    802006ec:	02000793          	li	a5,32
    802006f0:	02f70263          	beq	a4,a5,80200714 <isspace+0x44>
    802006f4:	fec42783          	lw	a5,-20(s0)
    802006f8:	0007871b          	sext.w	a4,a5
    802006fc:	00800793          	li	a5,8
    80200700:	00e7de63          	bge	a5,a4,8020071c <isspace+0x4c>
    80200704:	fec42783          	lw	a5,-20(s0)
    80200708:	0007871b          	sext.w	a4,a5
    8020070c:	00d00793          	li	a5,13
    80200710:	00e7c663          	blt	a5,a4,8020071c <isspace+0x4c>
    80200714:	00100793          	li	a5,1
    80200718:	0080006f          	j	80200720 <isspace+0x50>
    8020071c:	00000793          	li	a5,0
}
    80200720:	00078513          	mv	a0,a5
    80200724:	01813403          	ld	s0,24(sp)
    80200728:	02010113          	addi	sp,sp,32
    8020072c:	00008067          	ret

0000000080200730 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200730:	fb010113          	addi	sp,sp,-80
    80200734:	04113423          	sd	ra,72(sp)
    80200738:	04813023          	sd	s0,64(sp)
    8020073c:	05010413          	addi	s0,sp,80
    80200740:	fca43423          	sd	a0,-56(s0)
    80200744:	fcb43023          	sd	a1,-64(s0)
    80200748:	00060793          	mv	a5,a2
    8020074c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200750:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200754:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200758:	fc843783          	ld	a5,-56(s0)
    8020075c:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200760:	0100006f          	j	80200770 <strtol+0x40>
        p++;
    80200764:	fd843783          	ld	a5,-40(s0)
    80200768:	00178793          	addi	a5,a5,1
    8020076c:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200770:	fd843783          	ld	a5,-40(s0)
    80200774:	0007c783          	lbu	a5,0(a5)
    80200778:	0007879b          	sext.w	a5,a5
    8020077c:	00078513          	mv	a0,a5
    80200780:	f51ff0ef          	jal	802006d0 <isspace>
    80200784:	00050793          	mv	a5,a0
    80200788:	fc079ee3          	bnez	a5,80200764 <strtol+0x34>
    }

    if (*p == '-') {
    8020078c:	fd843783          	ld	a5,-40(s0)
    80200790:	0007c783          	lbu	a5,0(a5)
    80200794:	00078713          	mv	a4,a5
    80200798:	02d00793          	li	a5,45
    8020079c:	00f71e63          	bne	a4,a5,802007b8 <strtol+0x88>
        neg = true;
    802007a0:	00100793          	li	a5,1
    802007a4:	fef403a3          	sb	a5,-25(s0)
        p++;
    802007a8:	fd843783          	ld	a5,-40(s0)
    802007ac:	00178793          	addi	a5,a5,1
    802007b0:	fcf43c23          	sd	a5,-40(s0)
    802007b4:	0240006f          	j	802007d8 <strtol+0xa8>
    } else if (*p == '+') {
    802007b8:	fd843783          	ld	a5,-40(s0)
    802007bc:	0007c783          	lbu	a5,0(a5)
    802007c0:	00078713          	mv	a4,a5
    802007c4:	02b00793          	li	a5,43
    802007c8:	00f71863          	bne	a4,a5,802007d8 <strtol+0xa8>
        p++;
    802007cc:	fd843783          	ld	a5,-40(s0)
    802007d0:	00178793          	addi	a5,a5,1
    802007d4:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    802007d8:	fbc42783          	lw	a5,-68(s0)
    802007dc:	0007879b          	sext.w	a5,a5
    802007e0:	06079c63          	bnez	a5,80200858 <strtol+0x128>
        if (*p == '0') {
    802007e4:	fd843783          	ld	a5,-40(s0)
    802007e8:	0007c783          	lbu	a5,0(a5)
    802007ec:	00078713          	mv	a4,a5
    802007f0:	03000793          	li	a5,48
    802007f4:	04f71e63          	bne	a4,a5,80200850 <strtol+0x120>
            p++;
    802007f8:	fd843783          	ld	a5,-40(s0)
    802007fc:	00178793          	addi	a5,a5,1
    80200800:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200804:	fd843783          	ld	a5,-40(s0)
    80200808:	0007c783          	lbu	a5,0(a5)
    8020080c:	00078713          	mv	a4,a5
    80200810:	07800793          	li	a5,120
    80200814:	00f70c63          	beq	a4,a5,8020082c <strtol+0xfc>
    80200818:	fd843783          	ld	a5,-40(s0)
    8020081c:	0007c783          	lbu	a5,0(a5)
    80200820:	00078713          	mv	a4,a5
    80200824:	05800793          	li	a5,88
    80200828:	00f71e63          	bne	a4,a5,80200844 <strtol+0x114>
                base = 16;
    8020082c:	01000793          	li	a5,16
    80200830:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200834:	fd843783          	ld	a5,-40(s0)
    80200838:	00178793          	addi	a5,a5,1
    8020083c:	fcf43c23          	sd	a5,-40(s0)
    80200840:	0180006f          	j	80200858 <strtol+0x128>
            } else {
                base = 8;
    80200844:	00800793          	li	a5,8
    80200848:	faf42e23          	sw	a5,-68(s0)
    8020084c:	00c0006f          	j	80200858 <strtol+0x128>
            }
        } else {
            base = 10;
    80200850:	00a00793          	li	a5,10
    80200854:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200858:	fd843783          	ld	a5,-40(s0)
    8020085c:	0007c783          	lbu	a5,0(a5)
    80200860:	00078713          	mv	a4,a5
    80200864:	02f00793          	li	a5,47
    80200868:	02e7f863          	bgeu	a5,a4,80200898 <strtol+0x168>
    8020086c:	fd843783          	ld	a5,-40(s0)
    80200870:	0007c783          	lbu	a5,0(a5)
    80200874:	00078713          	mv	a4,a5
    80200878:	03900793          	li	a5,57
    8020087c:	00e7ee63          	bltu	a5,a4,80200898 <strtol+0x168>
            digit = *p - '0';
    80200880:	fd843783          	ld	a5,-40(s0)
    80200884:	0007c783          	lbu	a5,0(a5)
    80200888:	0007879b          	sext.w	a5,a5
    8020088c:	fd07879b          	addiw	a5,a5,-48
    80200890:	fcf42a23          	sw	a5,-44(s0)
    80200894:	0800006f          	j	80200914 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200898:	fd843783          	ld	a5,-40(s0)
    8020089c:	0007c783          	lbu	a5,0(a5)
    802008a0:	00078713          	mv	a4,a5
    802008a4:	06000793          	li	a5,96
    802008a8:	02e7f863          	bgeu	a5,a4,802008d8 <strtol+0x1a8>
    802008ac:	fd843783          	ld	a5,-40(s0)
    802008b0:	0007c783          	lbu	a5,0(a5)
    802008b4:	00078713          	mv	a4,a5
    802008b8:	07a00793          	li	a5,122
    802008bc:	00e7ee63          	bltu	a5,a4,802008d8 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    802008c0:	fd843783          	ld	a5,-40(s0)
    802008c4:	0007c783          	lbu	a5,0(a5)
    802008c8:	0007879b          	sext.w	a5,a5
    802008cc:	fa97879b          	addiw	a5,a5,-87
    802008d0:	fcf42a23          	sw	a5,-44(s0)
    802008d4:	0400006f          	j	80200914 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    802008d8:	fd843783          	ld	a5,-40(s0)
    802008dc:	0007c783          	lbu	a5,0(a5)
    802008e0:	00078713          	mv	a4,a5
    802008e4:	04000793          	li	a5,64
    802008e8:	06e7f863          	bgeu	a5,a4,80200958 <strtol+0x228>
    802008ec:	fd843783          	ld	a5,-40(s0)
    802008f0:	0007c783          	lbu	a5,0(a5)
    802008f4:	00078713          	mv	a4,a5
    802008f8:	05a00793          	li	a5,90
    802008fc:	04e7ee63          	bltu	a5,a4,80200958 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200900:	fd843783          	ld	a5,-40(s0)
    80200904:	0007c783          	lbu	a5,0(a5)
    80200908:	0007879b          	sext.w	a5,a5
    8020090c:	fc97879b          	addiw	a5,a5,-55
    80200910:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200914:	fd442783          	lw	a5,-44(s0)
    80200918:	00078713          	mv	a4,a5
    8020091c:	fbc42783          	lw	a5,-68(s0)
    80200920:	0007071b          	sext.w	a4,a4
    80200924:	0007879b          	sext.w	a5,a5
    80200928:	02f75663          	bge	a4,a5,80200954 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    8020092c:	fbc42703          	lw	a4,-68(s0)
    80200930:	fe843783          	ld	a5,-24(s0)
    80200934:	02f70733          	mul	a4,a4,a5
    80200938:	fd442783          	lw	a5,-44(s0)
    8020093c:	00f707b3          	add	a5,a4,a5
    80200940:	fef43423          	sd	a5,-24(s0)
        p++;
    80200944:	fd843783          	ld	a5,-40(s0)
    80200948:	00178793          	addi	a5,a5,1
    8020094c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200950:	f09ff06f          	j	80200858 <strtol+0x128>
            break;
    80200954:	00000013          	nop
    }

    if (endptr) {
    80200958:	fc043783          	ld	a5,-64(s0)
    8020095c:	00078863          	beqz	a5,8020096c <strtol+0x23c>
        *endptr = (char *)p;
    80200960:	fc043783          	ld	a5,-64(s0)
    80200964:	fd843703          	ld	a4,-40(s0)
    80200968:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    8020096c:	fe744783          	lbu	a5,-25(s0)
    80200970:	0ff7f793          	zext.b	a5,a5
    80200974:	00078863          	beqz	a5,80200984 <strtol+0x254>
    80200978:	fe843783          	ld	a5,-24(s0)
    8020097c:	40f007b3          	neg	a5,a5
    80200980:	0080006f          	j	80200988 <strtol+0x258>
    80200984:	fe843783          	ld	a5,-24(s0)
}
    80200988:	00078513          	mv	a0,a5
    8020098c:	04813083          	ld	ra,72(sp)
    80200990:	04013403          	ld	s0,64(sp)
    80200994:	05010113          	addi	sp,sp,80
    80200998:	00008067          	ret

000000008020099c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    8020099c:	fd010113          	addi	sp,sp,-48
    802009a0:	02113423          	sd	ra,40(sp)
    802009a4:	02813023          	sd	s0,32(sp)
    802009a8:	03010413          	addi	s0,sp,48
    802009ac:	fca43c23          	sd	a0,-40(s0)
    802009b0:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    802009b4:	fd043783          	ld	a5,-48(s0)
    802009b8:	00079863          	bnez	a5,802009c8 <puts_wo_nl+0x2c>
        s = "(null)";
    802009bc:	00001797          	auipc	a5,0x1
    802009c0:	73c78793          	addi	a5,a5,1852 # 802020f8 <_srodata+0xf8>
    802009c4:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    802009c8:	fd043783          	ld	a5,-48(s0)
    802009cc:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    802009d0:	0240006f          	j	802009f4 <puts_wo_nl+0x58>
        putch(*p++);
    802009d4:	fe843783          	ld	a5,-24(s0)
    802009d8:	00178713          	addi	a4,a5,1
    802009dc:	fee43423          	sd	a4,-24(s0)
    802009e0:	0007c783          	lbu	a5,0(a5)
    802009e4:	0007871b          	sext.w	a4,a5
    802009e8:	fd843783          	ld	a5,-40(s0)
    802009ec:	00070513          	mv	a0,a4
    802009f0:	000780e7          	jalr	a5
    while (*p) {
    802009f4:	fe843783          	ld	a5,-24(s0)
    802009f8:	0007c783          	lbu	a5,0(a5)
    802009fc:	fc079ce3          	bnez	a5,802009d4 <puts_wo_nl+0x38>
    }
    return p - s;
    80200a00:	fe843703          	ld	a4,-24(s0)
    80200a04:	fd043783          	ld	a5,-48(s0)
    80200a08:	40f707b3          	sub	a5,a4,a5
    80200a0c:	0007879b          	sext.w	a5,a5
}
    80200a10:	00078513          	mv	a0,a5
    80200a14:	02813083          	ld	ra,40(sp)
    80200a18:	02013403          	ld	s0,32(sp)
    80200a1c:	03010113          	addi	sp,sp,48
    80200a20:	00008067          	ret

0000000080200a24 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200a24:	f9010113          	addi	sp,sp,-112
    80200a28:	06113423          	sd	ra,104(sp)
    80200a2c:	06813023          	sd	s0,96(sp)
    80200a30:	07010413          	addi	s0,sp,112
    80200a34:	faa43423          	sd	a0,-88(s0)
    80200a38:	fab43023          	sd	a1,-96(s0)
    80200a3c:	00060793          	mv	a5,a2
    80200a40:	f8d43823          	sd	a3,-112(s0)
    80200a44:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200a48:	f9f44783          	lbu	a5,-97(s0)
    80200a4c:	0ff7f793          	zext.b	a5,a5
    80200a50:	02078663          	beqz	a5,80200a7c <print_dec_int+0x58>
    80200a54:	fa043703          	ld	a4,-96(s0)
    80200a58:	fff00793          	li	a5,-1
    80200a5c:	03f79793          	slli	a5,a5,0x3f
    80200a60:	00f71e63          	bne	a4,a5,80200a7c <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200a64:	00001597          	auipc	a1,0x1
    80200a68:	69c58593          	addi	a1,a1,1692 # 80202100 <_srodata+0x100>
    80200a6c:	fa843503          	ld	a0,-88(s0)
    80200a70:	f2dff0ef          	jal	8020099c <puts_wo_nl>
    80200a74:	00050793          	mv	a5,a0
    80200a78:	2a00006f          	j	80200d18 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80200a7c:	f9043783          	ld	a5,-112(s0)
    80200a80:	00c7a783          	lw	a5,12(a5)
    80200a84:	00079a63          	bnez	a5,80200a98 <print_dec_int+0x74>
    80200a88:	fa043783          	ld	a5,-96(s0)
    80200a8c:	00079663          	bnez	a5,80200a98 <print_dec_int+0x74>
        return 0;
    80200a90:	00000793          	li	a5,0
    80200a94:	2840006f          	j	80200d18 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200a98:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200a9c:	f9f44783          	lbu	a5,-97(s0)
    80200aa0:	0ff7f793          	zext.b	a5,a5
    80200aa4:	02078063          	beqz	a5,80200ac4 <print_dec_int+0xa0>
    80200aa8:	fa043783          	ld	a5,-96(s0)
    80200aac:	0007dc63          	bgez	a5,80200ac4 <print_dec_int+0xa0>
        neg = true;
    80200ab0:	00100793          	li	a5,1
    80200ab4:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200ab8:	fa043783          	ld	a5,-96(s0)
    80200abc:	40f007b3          	neg	a5,a5
    80200ac0:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200ac4:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200ac8:	f9f44783          	lbu	a5,-97(s0)
    80200acc:	0ff7f793          	zext.b	a5,a5
    80200ad0:	02078863          	beqz	a5,80200b00 <print_dec_int+0xdc>
    80200ad4:	fef44783          	lbu	a5,-17(s0)
    80200ad8:	0ff7f793          	zext.b	a5,a5
    80200adc:	00079e63          	bnez	a5,80200af8 <print_dec_int+0xd4>
    80200ae0:	f9043783          	ld	a5,-112(s0)
    80200ae4:	0057c783          	lbu	a5,5(a5)
    80200ae8:	00079863          	bnez	a5,80200af8 <print_dec_int+0xd4>
    80200aec:	f9043783          	ld	a5,-112(s0)
    80200af0:	0047c783          	lbu	a5,4(a5)
    80200af4:	00078663          	beqz	a5,80200b00 <print_dec_int+0xdc>
    80200af8:	00100793          	li	a5,1
    80200afc:	0080006f          	j	80200b04 <print_dec_int+0xe0>
    80200b00:	00000793          	li	a5,0
    80200b04:	fcf40ba3          	sb	a5,-41(s0)
    80200b08:	fd744783          	lbu	a5,-41(s0)
    80200b0c:	0017f793          	andi	a5,a5,1
    80200b10:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200b14:	fa043703          	ld	a4,-96(s0)
    80200b18:	00a00793          	li	a5,10
    80200b1c:	02f777b3          	remu	a5,a4,a5
    80200b20:	0ff7f713          	zext.b	a4,a5
    80200b24:	fe842783          	lw	a5,-24(s0)
    80200b28:	0017869b          	addiw	a3,a5,1
    80200b2c:	fed42423          	sw	a3,-24(s0)
    80200b30:	0307071b          	addiw	a4,a4,48
    80200b34:	0ff77713          	zext.b	a4,a4
    80200b38:	ff078793          	addi	a5,a5,-16
    80200b3c:	008787b3          	add	a5,a5,s0
    80200b40:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200b44:	fa043703          	ld	a4,-96(s0)
    80200b48:	00a00793          	li	a5,10
    80200b4c:	02f757b3          	divu	a5,a4,a5
    80200b50:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200b54:	fa043783          	ld	a5,-96(s0)
    80200b58:	fa079ee3          	bnez	a5,80200b14 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200b5c:	f9043783          	ld	a5,-112(s0)
    80200b60:	00c7a783          	lw	a5,12(a5)
    80200b64:	00078713          	mv	a4,a5
    80200b68:	fff00793          	li	a5,-1
    80200b6c:	02f71063          	bne	a4,a5,80200b8c <print_dec_int+0x168>
    80200b70:	f9043783          	ld	a5,-112(s0)
    80200b74:	0037c783          	lbu	a5,3(a5)
    80200b78:	00078a63          	beqz	a5,80200b8c <print_dec_int+0x168>
        flags->prec = flags->width;
    80200b7c:	f9043783          	ld	a5,-112(s0)
    80200b80:	0087a703          	lw	a4,8(a5)
    80200b84:	f9043783          	ld	a5,-112(s0)
    80200b88:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200b8c:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b90:	f9043783          	ld	a5,-112(s0)
    80200b94:	0087a703          	lw	a4,8(a5)
    80200b98:	fe842783          	lw	a5,-24(s0)
    80200b9c:	fcf42823          	sw	a5,-48(s0)
    80200ba0:	f9043783          	ld	a5,-112(s0)
    80200ba4:	00c7a783          	lw	a5,12(a5)
    80200ba8:	fcf42623          	sw	a5,-52(s0)
    80200bac:	fd042783          	lw	a5,-48(s0)
    80200bb0:	00078593          	mv	a1,a5
    80200bb4:	fcc42783          	lw	a5,-52(s0)
    80200bb8:	00078613          	mv	a2,a5
    80200bbc:	0006069b          	sext.w	a3,a2
    80200bc0:	0005879b          	sext.w	a5,a1
    80200bc4:	00f6d463          	bge	a3,a5,80200bcc <print_dec_int+0x1a8>
    80200bc8:	00058613          	mv	a2,a1
    80200bcc:	0006079b          	sext.w	a5,a2
    80200bd0:	40f707bb          	subw	a5,a4,a5
    80200bd4:	0007871b          	sext.w	a4,a5
    80200bd8:	fd744783          	lbu	a5,-41(s0)
    80200bdc:	0007879b          	sext.w	a5,a5
    80200be0:	40f707bb          	subw	a5,a4,a5
    80200be4:	fef42023          	sw	a5,-32(s0)
    80200be8:	0280006f          	j	80200c10 <print_dec_int+0x1ec>
        putch(' ');
    80200bec:	fa843783          	ld	a5,-88(s0)
    80200bf0:	02000513          	li	a0,32
    80200bf4:	000780e7          	jalr	a5
        ++written;
    80200bf8:	fe442783          	lw	a5,-28(s0)
    80200bfc:	0017879b          	addiw	a5,a5,1
    80200c00:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200c04:	fe042783          	lw	a5,-32(s0)
    80200c08:	fff7879b          	addiw	a5,a5,-1
    80200c0c:	fef42023          	sw	a5,-32(s0)
    80200c10:	fe042783          	lw	a5,-32(s0)
    80200c14:	0007879b          	sext.w	a5,a5
    80200c18:	fcf04ae3          	bgtz	a5,80200bec <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200c1c:	fd744783          	lbu	a5,-41(s0)
    80200c20:	0ff7f793          	zext.b	a5,a5
    80200c24:	04078463          	beqz	a5,80200c6c <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200c28:	fef44783          	lbu	a5,-17(s0)
    80200c2c:	0ff7f793          	zext.b	a5,a5
    80200c30:	00078663          	beqz	a5,80200c3c <print_dec_int+0x218>
    80200c34:	02d00793          	li	a5,45
    80200c38:	01c0006f          	j	80200c54 <print_dec_int+0x230>
    80200c3c:	f9043783          	ld	a5,-112(s0)
    80200c40:	0057c783          	lbu	a5,5(a5)
    80200c44:	00078663          	beqz	a5,80200c50 <print_dec_int+0x22c>
    80200c48:	02b00793          	li	a5,43
    80200c4c:	0080006f          	j	80200c54 <print_dec_int+0x230>
    80200c50:	02000793          	li	a5,32
    80200c54:	fa843703          	ld	a4,-88(s0)
    80200c58:	00078513          	mv	a0,a5
    80200c5c:	000700e7          	jalr	a4
        ++written;
    80200c60:	fe442783          	lw	a5,-28(s0)
    80200c64:	0017879b          	addiw	a5,a5,1
    80200c68:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c6c:	fe842783          	lw	a5,-24(s0)
    80200c70:	fcf42e23          	sw	a5,-36(s0)
    80200c74:	0280006f          	j	80200c9c <print_dec_int+0x278>
        putch('0');
    80200c78:	fa843783          	ld	a5,-88(s0)
    80200c7c:	03000513          	li	a0,48
    80200c80:	000780e7          	jalr	a5
        ++written;
    80200c84:	fe442783          	lw	a5,-28(s0)
    80200c88:	0017879b          	addiw	a5,a5,1
    80200c8c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c90:	fdc42783          	lw	a5,-36(s0)
    80200c94:	0017879b          	addiw	a5,a5,1
    80200c98:	fcf42e23          	sw	a5,-36(s0)
    80200c9c:	f9043783          	ld	a5,-112(s0)
    80200ca0:	00c7a703          	lw	a4,12(a5)
    80200ca4:	fd744783          	lbu	a5,-41(s0)
    80200ca8:	0007879b          	sext.w	a5,a5
    80200cac:	40f707bb          	subw	a5,a4,a5
    80200cb0:	0007871b          	sext.w	a4,a5
    80200cb4:	fdc42783          	lw	a5,-36(s0)
    80200cb8:	0007879b          	sext.w	a5,a5
    80200cbc:	fae7cee3          	blt	a5,a4,80200c78 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200cc0:	fe842783          	lw	a5,-24(s0)
    80200cc4:	fff7879b          	addiw	a5,a5,-1
    80200cc8:	fcf42c23          	sw	a5,-40(s0)
    80200ccc:	03c0006f          	j	80200d08 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200cd0:	fd842783          	lw	a5,-40(s0)
    80200cd4:	ff078793          	addi	a5,a5,-16
    80200cd8:	008787b3          	add	a5,a5,s0
    80200cdc:	fc87c783          	lbu	a5,-56(a5)
    80200ce0:	0007871b          	sext.w	a4,a5
    80200ce4:	fa843783          	ld	a5,-88(s0)
    80200ce8:	00070513          	mv	a0,a4
    80200cec:	000780e7          	jalr	a5
        ++written;
    80200cf0:	fe442783          	lw	a5,-28(s0)
    80200cf4:	0017879b          	addiw	a5,a5,1
    80200cf8:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200cfc:	fd842783          	lw	a5,-40(s0)
    80200d00:	fff7879b          	addiw	a5,a5,-1
    80200d04:	fcf42c23          	sw	a5,-40(s0)
    80200d08:	fd842783          	lw	a5,-40(s0)
    80200d0c:	0007879b          	sext.w	a5,a5
    80200d10:	fc07d0e3          	bgez	a5,80200cd0 <print_dec_int+0x2ac>
    }

    return written;
    80200d14:	fe442783          	lw	a5,-28(s0)
}
    80200d18:	00078513          	mv	a0,a5
    80200d1c:	06813083          	ld	ra,104(sp)
    80200d20:	06013403          	ld	s0,96(sp)
    80200d24:	07010113          	addi	sp,sp,112
    80200d28:	00008067          	ret

0000000080200d2c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200d2c:	f4010113          	addi	sp,sp,-192
    80200d30:	0a113c23          	sd	ra,184(sp)
    80200d34:	0a813823          	sd	s0,176(sp)
    80200d38:	0c010413          	addi	s0,sp,192
    80200d3c:	f4a43c23          	sd	a0,-168(s0)
    80200d40:	f4b43823          	sd	a1,-176(s0)
    80200d44:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200d48:	f8043023          	sd	zero,-128(s0)
    80200d4c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200d50:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200d54:	7a40006f          	j	802014f8 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200d58:	f8044783          	lbu	a5,-128(s0)
    80200d5c:	72078e63          	beqz	a5,80201498 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200d60:	f5043783          	ld	a5,-176(s0)
    80200d64:	0007c783          	lbu	a5,0(a5)
    80200d68:	00078713          	mv	a4,a5
    80200d6c:	02300793          	li	a5,35
    80200d70:	00f71863          	bne	a4,a5,80200d80 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200d74:	00100793          	li	a5,1
    80200d78:	f8f40123          	sb	a5,-126(s0)
    80200d7c:	7700006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200d80:	f5043783          	ld	a5,-176(s0)
    80200d84:	0007c783          	lbu	a5,0(a5)
    80200d88:	00078713          	mv	a4,a5
    80200d8c:	03000793          	li	a5,48
    80200d90:	00f71863          	bne	a4,a5,80200da0 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200d94:	00100793          	li	a5,1
    80200d98:	f8f401a3          	sb	a5,-125(s0)
    80200d9c:	7500006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200da0:	f5043783          	ld	a5,-176(s0)
    80200da4:	0007c783          	lbu	a5,0(a5)
    80200da8:	00078713          	mv	a4,a5
    80200dac:	06c00793          	li	a5,108
    80200db0:	04f70063          	beq	a4,a5,80200df0 <vprintfmt+0xc4>
    80200db4:	f5043783          	ld	a5,-176(s0)
    80200db8:	0007c783          	lbu	a5,0(a5)
    80200dbc:	00078713          	mv	a4,a5
    80200dc0:	07a00793          	li	a5,122
    80200dc4:	02f70663          	beq	a4,a5,80200df0 <vprintfmt+0xc4>
    80200dc8:	f5043783          	ld	a5,-176(s0)
    80200dcc:	0007c783          	lbu	a5,0(a5)
    80200dd0:	00078713          	mv	a4,a5
    80200dd4:	07400793          	li	a5,116
    80200dd8:	00f70c63          	beq	a4,a5,80200df0 <vprintfmt+0xc4>
    80200ddc:	f5043783          	ld	a5,-176(s0)
    80200de0:	0007c783          	lbu	a5,0(a5)
    80200de4:	00078713          	mv	a4,a5
    80200de8:	06a00793          	li	a5,106
    80200dec:	00f71863          	bne	a4,a5,80200dfc <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200df0:	00100793          	li	a5,1
    80200df4:	f8f400a3          	sb	a5,-127(s0)
    80200df8:	6f40006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200dfc:	f5043783          	ld	a5,-176(s0)
    80200e00:	0007c783          	lbu	a5,0(a5)
    80200e04:	00078713          	mv	a4,a5
    80200e08:	02b00793          	li	a5,43
    80200e0c:	00f71863          	bne	a4,a5,80200e1c <vprintfmt+0xf0>
                flags.sign = true;
    80200e10:	00100793          	li	a5,1
    80200e14:	f8f402a3          	sb	a5,-123(s0)
    80200e18:	6d40006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200e1c:	f5043783          	ld	a5,-176(s0)
    80200e20:	0007c783          	lbu	a5,0(a5)
    80200e24:	00078713          	mv	a4,a5
    80200e28:	02000793          	li	a5,32
    80200e2c:	00f71863          	bne	a4,a5,80200e3c <vprintfmt+0x110>
                flags.spaceflag = true;
    80200e30:	00100793          	li	a5,1
    80200e34:	f8f40223          	sb	a5,-124(s0)
    80200e38:	6b40006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200e3c:	f5043783          	ld	a5,-176(s0)
    80200e40:	0007c783          	lbu	a5,0(a5)
    80200e44:	00078713          	mv	a4,a5
    80200e48:	02a00793          	li	a5,42
    80200e4c:	00f71e63          	bne	a4,a5,80200e68 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200e50:	f4843783          	ld	a5,-184(s0)
    80200e54:	00878713          	addi	a4,a5,8
    80200e58:	f4e43423          	sd	a4,-184(s0)
    80200e5c:	0007a783          	lw	a5,0(a5)
    80200e60:	f8f42423          	sw	a5,-120(s0)
    80200e64:	6880006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200e68:	f5043783          	ld	a5,-176(s0)
    80200e6c:	0007c783          	lbu	a5,0(a5)
    80200e70:	00078713          	mv	a4,a5
    80200e74:	03000793          	li	a5,48
    80200e78:	04e7f663          	bgeu	a5,a4,80200ec4 <vprintfmt+0x198>
    80200e7c:	f5043783          	ld	a5,-176(s0)
    80200e80:	0007c783          	lbu	a5,0(a5)
    80200e84:	00078713          	mv	a4,a5
    80200e88:	03900793          	li	a5,57
    80200e8c:	02e7ec63          	bltu	a5,a4,80200ec4 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200e90:	f5043783          	ld	a5,-176(s0)
    80200e94:	f5040713          	addi	a4,s0,-176
    80200e98:	00a00613          	li	a2,10
    80200e9c:	00070593          	mv	a1,a4
    80200ea0:	00078513          	mv	a0,a5
    80200ea4:	88dff0ef          	jal	80200730 <strtol>
    80200ea8:	00050793          	mv	a5,a0
    80200eac:	0007879b          	sext.w	a5,a5
    80200eb0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200eb4:	f5043783          	ld	a5,-176(s0)
    80200eb8:	fff78793          	addi	a5,a5,-1
    80200ebc:	f4f43823          	sd	a5,-176(s0)
    80200ec0:	62c0006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200ec4:	f5043783          	ld	a5,-176(s0)
    80200ec8:	0007c783          	lbu	a5,0(a5)
    80200ecc:	00078713          	mv	a4,a5
    80200ed0:	02e00793          	li	a5,46
    80200ed4:	06f71863          	bne	a4,a5,80200f44 <vprintfmt+0x218>
                fmt++;
    80200ed8:	f5043783          	ld	a5,-176(s0)
    80200edc:	00178793          	addi	a5,a5,1
    80200ee0:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200ee4:	f5043783          	ld	a5,-176(s0)
    80200ee8:	0007c783          	lbu	a5,0(a5)
    80200eec:	00078713          	mv	a4,a5
    80200ef0:	02a00793          	li	a5,42
    80200ef4:	00f71e63          	bne	a4,a5,80200f10 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200ef8:	f4843783          	ld	a5,-184(s0)
    80200efc:	00878713          	addi	a4,a5,8
    80200f00:	f4e43423          	sd	a4,-184(s0)
    80200f04:	0007a783          	lw	a5,0(a5)
    80200f08:	f8f42623          	sw	a5,-116(s0)
    80200f0c:	5e00006f          	j	802014ec <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200f10:	f5043783          	ld	a5,-176(s0)
    80200f14:	f5040713          	addi	a4,s0,-176
    80200f18:	00a00613          	li	a2,10
    80200f1c:	00070593          	mv	a1,a4
    80200f20:	00078513          	mv	a0,a5
    80200f24:	80dff0ef          	jal	80200730 <strtol>
    80200f28:	00050793          	mv	a5,a0
    80200f2c:	0007879b          	sext.w	a5,a5
    80200f30:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200f34:	f5043783          	ld	a5,-176(s0)
    80200f38:	fff78793          	addi	a5,a5,-1
    80200f3c:	f4f43823          	sd	a5,-176(s0)
    80200f40:	5ac0006f          	j	802014ec <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200f44:	f5043783          	ld	a5,-176(s0)
    80200f48:	0007c783          	lbu	a5,0(a5)
    80200f4c:	00078713          	mv	a4,a5
    80200f50:	07800793          	li	a5,120
    80200f54:	02f70663          	beq	a4,a5,80200f80 <vprintfmt+0x254>
    80200f58:	f5043783          	ld	a5,-176(s0)
    80200f5c:	0007c783          	lbu	a5,0(a5)
    80200f60:	00078713          	mv	a4,a5
    80200f64:	05800793          	li	a5,88
    80200f68:	00f70c63          	beq	a4,a5,80200f80 <vprintfmt+0x254>
    80200f6c:	f5043783          	ld	a5,-176(s0)
    80200f70:	0007c783          	lbu	a5,0(a5)
    80200f74:	00078713          	mv	a4,a5
    80200f78:	07000793          	li	a5,112
    80200f7c:	30f71263          	bne	a4,a5,80201280 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200f80:	f5043783          	ld	a5,-176(s0)
    80200f84:	0007c783          	lbu	a5,0(a5)
    80200f88:	00078713          	mv	a4,a5
    80200f8c:	07000793          	li	a5,112
    80200f90:	00f70663          	beq	a4,a5,80200f9c <vprintfmt+0x270>
    80200f94:	f8144783          	lbu	a5,-127(s0)
    80200f98:	00078663          	beqz	a5,80200fa4 <vprintfmt+0x278>
    80200f9c:	00100793          	li	a5,1
    80200fa0:	0080006f          	j	80200fa8 <vprintfmt+0x27c>
    80200fa4:	00000793          	li	a5,0
    80200fa8:	faf403a3          	sb	a5,-89(s0)
    80200fac:	fa744783          	lbu	a5,-89(s0)
    80200fb0:	0017f793          	andi	a5,a5,1
    80200fb4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200fb8:	fa744783          	lbu	a5,-89(s0)
    80200fbc:	0ff7f793          	zext.b	a5,a5
    80200fc0:	00078c63          	beqz	a5,80200fd8 <vprintfmt+0x2ac>
    80200fc4:	f4843783          	ld	a5,-184(s0)
    80200fc8:	00878713          	addi	a4,a5,8
    80200fcc:	f4e43423          	sd	a4,-184(s0)
    80200fd0:	0007b783          	ld	a5,0(a5)
    80200fd4:	01c0006f          	j	80200ff0 <vprintfmt+0x2c4>
    80200fd8:	f4843783          	ld	a5,-184(s0)
    80200fdc:	00878713          	addi	a4,a5,8
    80200fe0:	f4e43423          	sd	a4,-184(s0)
    80200fe4:	0007a783          	lw	a5,0(a5)
    80200fe8:	02079793          	slli	a5,a5,0x20
    80200fec:	0207d793          	srli	a5,a5,0x20
    80200ff0:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200ff4:	f8c42783          	lw	a5,-116(s0)
    80200ff8:	02079463          	bnez	a5,80201020 <vprintfmt+0x2f4>
    80200ffc:	fe043783          	ld	a5,-32(s0)
    80201000:	02079063          	bnez	a5,80201020 <vprintfmt+0x2f4>
    80201004:	f5043783          	ld	a5,-176(s0)
    80201008:	0007c783          	lbu	a5,0(a5)
    8020100c:	00078713          	mv	a4,a5
    80201010:	07000793          	li	a5,112
    80201014:	00f70663          	beq	a4,a5,80201020 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80201018:	f8040023          	sb	zero,-128(s0)
    8020101c:	4d00006f          	j	802014ec <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80201020:	f5043783          	ld	a5,-176(s0)
    80201024:	0007c783          	lbu	a5,0(a5)
    80201028:	00078713          	mv	a4,a5
    8020102c:	07000793          	li	a5,112
    80201030:	00f70a63          	beq	a4,a5,80201044 <vprintfmt+0x318>
    80201034:	f8244783          	lbu	a5,-126(s0)
    80201038:	00078a63          	beqz	a5,8020104c <vprintfmt+0x320>
    8020103c:	fe043783          	ld	a5,-32(s0)
    80201040:	00078663          	beqz	a5,8020104c <vprintfmt+0x320>
    80201044:	00100793          	li	a5,1
    80201048:	0080006f          	j	80201050 <vprintfmt+0x324>
    8020104c:	00000793          	li	a5,0
    80201050:	faf40323          	sb	a5,-90(s0)
    80201054:	fa644783          	lbu	a5,-90(s0)
    80201058:	0017f793          	andi	a5,a5,1
    8020105c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80201060:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80201064:	f5043783          	ld	a5,-176(s0)
    80201068:	0007c783          	lbu	a5,0(a5)
    8020106c:	00078713          	mv	a4,a5
    80201070:	05800793          	li	a5,88
    80201074:	00f71863          	bne	a4,a5,80201084 <vprintfmt+0x358>
    80201078:	00001797          	auipc	a5,0x1
    8020107c:	0a078793          	addi	a5,a5,160 # 80202118 <upperxdigits.1>
    80201080:	00c0006f          	j	8020108c <vprintfmt+0x360>
    80201084:	00001797          	auipc	a5,0x1
    80201088:	0ac78793          	addi	a5,a5,172 # 80202130 <lowerxdigits.0>
    8020108c:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201090:	fe043783          	ld	a5,-32(s0)
    80201094:	00f7f793          	andi	a5,a5,15
    80201098:	f9843703          	ld	a4,-104(s0)
    8020109c:	00f70733          	add	a4,a4,a5
    802010a0:	fdc42783          	lw	a5,-36(s0)
    802010a4:	0017869b          	addiw	a3,a5,1
    802010a8:	fcd42e23          	sw	a3,-36(s0)
    802010ac:	00074703          	lbu	a4,0(a4)
    802010b0:	ff078793          	addi	a5,a5,-16
    802010b4:	008787b3          	add	a5,a5,s0
    802010b8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    802010bc:	fe043783          	ld	a5,-32(s0)
    802010c0:	0047d793          	srli	a5,a5,0x4
    802010c4:	fef43023          	sd	a5,-32(s0)
                } while (num);
    802010c8:	fe043783          	ld	a5,-32(s0)
    802010cc:	fc0792e3          	bnez	a5,80201090 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    802010d0:	f8c42783          	lw	a5,-116(s0)
    802010d4:	00078713          	mv	a4,a5
    802010d8:	fff00793          	li	a5,-1
    802010dc:	02f71663          	bne	a4,a5,80201108 <vprintfmt+0x3dc>
    802010e0:	f8344783          	lbu	a5,-125(s0)
    802010e4:	02078263          	beqz	a5,80201108 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    802010e8:	f8842703          	lw	a4,-120(s0)
    802010ec:	fa644783          	lbu	a5,-90(s0)
    802010f0:	0007879b          	sext.w	a5,a5
    802010f4:	0017979b          	slliw	a5,a5,0x1
    802010f8:	0007879b          	sext.w	a5,a5
    802010fc:	40f707bb          	subw	a5,a4,a5
    80201100:	0007879b          	sext.w	a5,a5
    80201104:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201108:	f8842703          	lw	a4,-120(s0)
    8020110c:	fa644783          	lbu	a5,-90(s0)
    80201110:	0007879b          	sext.w	a5,a5
    80201114:	0017979b          	slliw	a5,a5,0x1
    80201118:	0007879b          	sext.w	a5,a5
    8020111c:	40f707bb          	subw	a5,a4,a5
    80201120:	0007871b          	sext.w	a4,a5
    80201124:	fdc42783          	lw	a5,-36(s0)
    80201128:	f8f42a23          	sw	a5,-108(s0)
    8020112c:	f8c42783          	lw	a5,-116(s0)
    80201130:	f8f42823          	sw	a5,-112(s0)
    80201134:	f9442783          	lw	a5,-108(s0)
    80201138:	00078593          	mv	a1,a5
    8020113c:	f9042783          	lw	a5,-112(s0)
    80201140:	00078613          	mv	a2,a5
    80201144:	0006069b          	sext.w	a3,a2
    80201148:	0005879b          	sext.w	a5,a1
    8020114c:	00f6d463          	bge	a3,a5,80201154 <vprintfmt+0x428>
    80201150:	00058613          	mv	a2,a1
    80201154:	0006079b          	sext.w	a5,a2
    80201158:	40f707bb          	subw	a5,a4,a5
    8020115c:	fcf42c23          	sw	a5,-40(s0)
    80201160:	0280006f          	j	80201188 <vprintfmt+0x45c>
                    putch(' ');
    80201164:	f5843783          	ld	a5,-168(s0)
    80201168:	02000513          	li	a0,32
    8020116c:	000780e7          	jalr	a5
                    ++written;
    80201170:	fec42783          	lw	a5,-20(s0)
    80201174:	0017879b          	addiw	a5,a5,1
    80201178:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    8020117c:	fd842783          	lw	a5,-40(s0)
    80201180:	fff7879b          	addiw	a5,a5,-1
    80201184:	fcf42c23          	sw	a5,-40(s0)
    80201188:	fd842783          	lw	a5,-40(s0)
    8020118c:	0007879b          	sext.w	a5,a5
    80201190:	fcf04ae3          	bgtz	a5,80201164 <vprintfmt+0x438>
                }

                if (prefix) {
    80201194:	fa644783          	lbu	a5,-90(s0)
    80201198:	0ff7f793          	zext.b	a5,a5
    8020119c:	04078463          	beqz	a5,802011e4 <vprintfmt+0x4b8>
                    putch('0');
    802011a0:	f5843783          	ld	a5,-168(s0)
    802011a4:	03000513          	li	a0,48
    802011a8:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    802011ac:	f5043783          	ld	a5,-176(s0)
    802011b0:	0007c783          	lbu	a5,0(a5)
    802011b4:	00078713          	mv	a4,a5
    802011b8:	05800793          	li	a5,88
    802011bc:	00f71663          	bne	a4,a5,802011c8 <vprintfmt+0x49c>
    802011c0:	05800793          	li	a5,88
    802011c4:	0080006f          	j	802011cc <vprintfmt+0x4a0>
    802011c8:	07800793          	li	a5,120
    802011cc:	f5843703          	ld	a4,-168(s0)
    802011d0:	00078513          	mv	a0,a5
    802011d4:	000700e7          	jalr	a4
                    written += 2;
    802011d8:	fec42783          	lw	a5,-20(s0)
    802011dc:	0027879b          	addiw	a5,a5,2
    802011e0:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    802011e4:	fdc42783          	lw	a5,-36(s0)
    802011e8:	fcf42a23          	sw	a5,-44(s0)
    802011ec:	0280006f          	j	80201214 <vprintfmt+0x4e8>
                    putch('0');
    802011f0:	f5843783          	ld	a5,-168(s0)
    802011f4:	03000513          	li	a0,48
    802011f8:	000780e7          	jalr	a5
                    ++written;
    802011fc:	fec42783          	lw	a5,-20(s0)
    80201200:	0017879b          	addiw	a5,a5,1
    80201204:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201208:	fd442783          	lw	a5,-44(s0)
    8020120c:	0017879b          	addiw	a5,a5,1
    80201210:	fcf42a23          	sw	a5,-44(s0)
    80201214:	f8c42703          	lw	a4,-116(s0)
    80201218:	fd442783          	lw	a5,-44(s0)
    8020121c:	0007879b          	sext.w	a5,a5
    80201220:	fce7c8e3          	blt	a5,a4,802011f0 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201224:	fdc42783          	lw	a5,-36(s0)
    80201228:	fff7879b          	addiw	a5,a5,-1
    8020122c:	fcf42823          	sw	a5,-48(s0)
    80201230:	03c0006f          	j	8020126c <vprintfmt+0x540>
                    putch(buf[i]);
    80201234:	fd042783          	lw	a5,-48(s0)
    80201238:	ff078793          	addi	a5,a5,-16
    8020123c:	008787b3          	add	a5,a5,s0
    80201240:	f807c783          	lbu	a5,-128(a5)
    80201244:	0007871b          	sext.w	a4,a5
    80201248:	f5843783          	ld	a5,-168(s0)
    8020124c:	00070513          	mv	a0,a4
    80201250:	000780e7          	jalr	a5
                    ++written;
    80201254:	fec42783          	lw	a5,-20(s0)
    80201258:	0017879b          	addiw	a5,a5,1
    8020125c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201260:	fd042783          	lw	a5,-48(s0)
    80201264:	fff7879b          	addiw	a5,a5,-1
    80201268:	fcf42823          	sw	a5,-48(s0)
    8020126c:	fd042783          	lw	a5,-48(s0)
    80201270:	0007879b          	sext.w	a5,a5
    80201274:	fc07d0e3          	bgez	a5,80201234 <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201278:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    8020127c:	2700006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201280:	f5043783          	ld	a5,-176(s0)
    80201284:	0007c783          	lbu	a5,0(a5)
    80201288:	00078713          	mv	a4,a5
    8020128c:	06400793          	li	a5,100
    80201290:	02f70663          	beq	a4,a5,802012bc <vprintfmt+0x590>
    80201294:	f5043783          	ld	a5,-176(s0)
    80201298:	0007c783          	lbu	a5,0(a5)
    8020129c:	00078713          	mv	a4,a5
    802012a0:	06900793          	li	a5,105
    802012a4:	00f70c63          	beq	a4,a5,802012bc <vprintfmt+0x590>
    802012a8:	f5043783          	ld	a5,-176(s0)
    802012ac:	0007c783          	lbu	a5,0(a5)
    802012b0:	00078713          	mv	a4,a5
    802012b4:	07500793          	li	a5,117
    802012b8:	08f71063          	bne	a4,a5,80201338 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802012bc:	f8144783          	lbu	a5,-127(s0)
    802012c0:	00078c63          	beqz	a5,802012d8 <vprintfmt+0x5ac>
    802012c4:	f4843783          	ld	a5,-184(s0)
    802012c8:	00878713          	addi	a4,a5,8
    802012cc:	f4e43423          	sd	a4,-184(s0)
    802012d0:	0007b783          	ld	a5,0(a5)
    802012d4:	0140006f          	j	802012e8 <vprintfmt+0x5bc>
    802012d8:	f4843783          	ld	a5,-184(s0)
    802012dc:	00878713          	addi	a4,a5,8
    802012e0:	f4e43423          	sd	a4,-184(s0)
    802012e4:	0007a783          	lw	a5,0(a5)
    802012e8:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    802012ec:	fa843583          	ld	a1,-88(s0)
    802012f0:	f5043783          	ld	a5,-176(s0)
    802012f4:	0007c783          	lbu	a5,0(a5)
    802012f8:	0007871b          	sext.w	a4,a5
    802012fc:	07500793          	li	a5,117
    80201300:	40f707b3          	sub	a5,a4,a5
    80201304:	00f037b3          	snez	a5,a5
    80201308:	0ff7f793          	zext.b	a5,a5
    8020130c:	f8040713          	addi	a4,s0,-128
    80201310:	00070693          	mv	a3,a4
    80201314:	00078613          	mv	a2,a5
    80201318:	f5843503          	ld	a0,-168(s0)
    8020131c:	f08ff0ef          	jal	80200a24 <print_dec_int>
    80201320:	00050793          	mv	a5,a0
    80201324:	fec42703          	lw	a4,-20(s0)
    80201328:	00f707bb          	addw	a5,a4,a5
    8020132c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201330:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201334:	1b80006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201338:	f5043783          	ld	a5,-176(s0)
    8020133c:	0007c783          	lbu	a5,0(a5)
    80201340:	00078713          	mv	a4,a5
    80201344:	06e00793          	li	a5,110
    80201348:	04f71c63          	bne	a4,a5,802013a0 <vprintfmt+0x674>
                if (flags.longflag) {
    8020134c:	f8144783          	lbu	a5,-127(s0)
    80201350:	02078463          	beqz	a5,80201378 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201354:	f4843783          	ld	a5,-184(s0)
    80201358:	00878713          	addi	a4,a5,8
    8020135c:	f4e43423          	sd	a4,-184(s0)
    80201360:	0007b783          	ld	a5,0(a5)
    80201364:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201368:	fec42703          	lw	a4,-20(s0)
    8020136c:	fb043783          	ld	a5,-80(s0)
    80201370:	00e7b023          	sd	a4,0(a5)
    80201374:	0240006f          	j	80201398 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201378:	f4843783          	ld	a5,-184(s0)
    8020137c:	00878713          	addi	a4,a5,8
    80201380:	f4e43423          	sd	a4,-184(s0)
    80201384:	0007b783          	ld	a5,0(a5)
    80201388:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    8020138c:	fb843783          	ld	a5,-72(s0)
    80201390:	fec42703          	lw	a4,-20(s0)
    80201394:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201398:	f8040023          	sb	zero,-128(s0)
    8020139c:	1500006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    802013a0:	f5043783          	ld	a5,-176(s0)
    802013a4:	0007c783          	lbu	a5,0(a5)
    802013a8:	00078713          	mv	a4,a5
    802013ac:	07300793          	li	a5,115
    802013b0:	02f71e63          	bne	a4,a5,802013ec <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802013b4:	f4843783          	ld	a5,-184(s0)
    802013b8:	00878713          	addi	a4,a5,8
    802013bc:	f4e43423          	sd	a4,-184(s0)
    802013c0:	0007b783          	ld	a5,0(a5)
    802013c4:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    802013c8:	fc043583          	ld	a1,-64(s0)
    802013cc:	f5843503          	ld	a0,-168(s0)
    802013d0:	dccff0ef          	jal	8020099c <puts_wo_nl>
    802013d4:	00050793          	mv	a5,a0
    802013d8:	fec42703          	lw	a4,-20(s0)
    802013dc:	00f707bb          	addw	a5,a4,a5
    802013e0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013e4:	f8040023          	sb	zero,-128(s0)
    802013e8:	1040006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    802013ec:	f5043783          	ld	a5,-176(s0)
    802013f0:	0007c783          	lbu	a5,0(a5)
    802013f4:	00078713          	mv	a4,a5
    802013f8:	06300793          	li	a5,99
    802013fc:	02f71e63          	bne	a4,a5,80201438 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201400:	f4843783          	ld	a5,-184(s0)
    80201404:	00878713          	addi	a4,a5,8
    80201408:	f4e43423          	sd	a4,-184(s0)
    8020140c:	0007a783          	lw	a5,0(a5)
    80201410:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201414:	fcc42703          	lw	a4,-52(s0)
    80201418:	f5843783          	ld	a5,-168(s0)
    8020141c:	00070513          	mv	a0,a4
    80201420:	000780e7          	jalr	a5
                ++written;
    80201424:	fec42783          	lw	a5,-20(s0)
    80201428:	0017879b          	addiw	a5,a5,1
    8020142c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201430:	f8040023          	sb	zero,-128(s0)
    80201434:	0b80006f          	j	802014ec <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201438:	f5043783          	ld	a5,-176(s0)
    8020143c:	0007c783          	lbu	a5,0(a5)
    80201440:	00078713          	mv	a4,a5
    80201444:	02500793          	li	a5,37
    80201448:	02f71263          	bne	a4,a5,8020146c <vprintfmt+0x740>
                putch('%');
    8020144c:	f5843783          	ld	a5,-168(s0)
    80201450:	02500513          	li	a0,37
    80201454:	000780e7          	jalr	a5
                ++written;
    80201458:	fec42783          	lw	a5,-20(s0)
    8020145c:	0017879b          	addiw	a5,a5,1
    80201460:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201464:	f8040023          	sb	zero,-128(s0)
    80201468:	0840006f          	j	802014ec <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    8020146c:	f5043783          	ld	a5,-176(s0)
    80201470:	0007c783          	lbu	a5,0(a5)
    80201474:	0007871b          	sext.w	a4,a5
    80201478:	f5843783          	ld	a5,-168(s0)
    8020147c:	00070513          	mv	a0,a4
    80201480:	000780e7          	jalr	a5
                ++written;
    80201484:	fec42783          	lw	a5,-20(s0)
    80201488:	0017879b          	addiw	a5,a5,1
    8020148c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201490:	f8040023          	sb	zero,-128(s0)
    80201494:	0580006f          	j	802014ec <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201498:	f5043783          	ld	a5,-176(s0)
    8020149c:	0007c783          	lbu	a5,0(a5)
    802014a0:	00078713          	mv	a4,a5
    802014a4:	02500793          	li	a5,37
    802014a8:	02f71063          	bne	a4,a5,802014c8 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    802014ac:	f8043023          	sd	zero,-128(s0)
    802014b0:	f8043423          	sd	zero,-120(s0)
    802014b4:	00100793          	li	a5,1
    802014b8:	f8f40023          	sb	a5,-128(s0)
    802014bc:	fff00793          	li	a5,-1
    802014c0:	f8f42623          	sw	a5,-116(s0)
    802014c4:	0280006f          	j	802014ec <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    802014c8:	f5043783          	ld	a5,-176(s0)
    802014cc:	0007c783          	lbu	a5,0(a5)
    802014d0:	0007871b          	sext.w	a4,a5
    802014d4:	f5843783          	ld	a5,-168(s0)
    802014d8:	00070513          	mv	a0,a4
    802014dc:	000780e7          	jalr	a5
            ++written;
    802014e0:	fec42783          	lw	a5,-20(s0)
    802014e4:	0017879b          	addiw	a5,a5,1
    802014e8:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    802014ec:	f5043783          	ld	a5,-176(s0)
    802014f0:	00178793          	addi	a5,a5,1
    802014f4:	f4f43823          	sd	a5,-176(s0)
    802014f8:	f5043783          	ld	a5,-176(s0)
    802014fc:	0007c783          	lbu	a5,0(a5)
    80201500:	84079ce3          	bnez	a5,80200d58 <vprintfmt+0x2c>
        }
    }

    return written;
    80201504:	fec42783          	lw	a5,-20(s0)
}
    80201508:	00078513          	mv	a0,a5
    8020150c:	0b813083          	ld	ra,184(sp)
    80201510:	0b013403          	ld	s0,176(sp)
    80201514:	0c010113          	addi	sp,sp,192
    80201518:	00008067          	ret

000000008020151c <printk>:

int printk(const char* s, ...) {
    8020151c:	f9010113          	addi	sp,sp,-112
    80201520:	02113423          	sd	ra,40(sp)
    80201524:	02813023          	sd	s0,32(sp)
    80201528:	03010413          	addi	s0,sp,48
    8020152c:	fca43c23          	sd	a0,-40(s0)
    80201530:	00b43423          	sd	a1,8(s0)
    80201534:	00c43823          	sd	a2,16(s0)
    80201538:	00d43c23          	sd	a3,24(s0)
    8020153c:	02e43023          	sd	a4,32(s0)
    80201540:	02f43423          	sd	a5,40(s0)
    80201544:	03043823          	sd	a6,48(s0)
    80201548:	03143c23          	sd	a7,56(s0)
    int res = 0;
    8020154c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201550:	04040793          	addi	a5,s0,64
    80201554:	fcf43823          	sd	a5,-48(s0)
    80201558:	fd043783          	ld	a5,-48(s0)
    8020155c:	fc878793          	addi	a5,a5,-56
    80201560:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201564:	fe043783          	ld	a5,-32(s0)
    80201568:	00078613          	mv	a2,a5
    8020156c:	fd843583          	ld	a1,-40(s0)
    80201570:	fffff517          	auipc	a0,0xfffff
    80201574:	11850513          	addi	a0,a0,280 # 80200688 <putc>
    80201578:	fb4ff0ef          	jal	80200d2c <vprintfmt>
    8020157c:	00050793          	mv	a5,a0
    80201580:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201584:	fec42783          	lw	a5,-20(s0)
}
    80201588:	00078513          	mv	a0,a5
    8020158c:	02813083          	ld	ra,40(sp)
    80201590:	02013403          	ld	s0,32(sp)
    80201594:	07010113          	addi	sp,sp,112
    80201598:	00008067          	ret
