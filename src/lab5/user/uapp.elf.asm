
uapp.elf:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000000000000 <_start>:
   0:	08c0006f          	j	8c <main>

Disassembly of section .text.getpid:

0000000000000004 <getpid>:
   4:	fe010113          	addi	sp,sp,-32
   8:	00813c23          	sd	s0,24(sp)
   c:	02010413          	addi	s0,sp,32
  10:	fe843783          	ld	a5,-24(s0)
  14:	0ac00893          	li	a7,172
  18:	00000073          	ecall
  1c:	00050793          	mv	a5,a0
  20:	fef43423          	sd	a5,-24(s0)
  24:	fe843783          	ld	a5,-24(s0)
  28:	00078513          	mv	a0,a5
  2c:	01813403          	ld	s0,24(sp)
  30:	02010113          	addi	sp,sp,32
  34:	00008067          	ret

Disassembly of section .text.wait:

0000000000000038 <wait>:
  38:	fd010113          	addi	sp,sp,-48
  3c:	02813423          	sd	s0,40(sp)
  40:	03010413          	addi	s0,sp,48
  44:	00050793          	mv	a5,a0
  48:	fcf42e23          	sw	a5,-36(s0)
  4c:	fe042623          	sw	zero,-20(s0)
  50:	0100006f          	j	60 <wait+0x28>
  54:	fec42783          	lw	a5,-20(s0)
  58:	0017879b          	addiw	a5,a5,1
  5c:	fef42623          	sw	a5,-20(s0)
  60:	fec42783          	lw	a5,-20(s0)
  64:	00078713          	mv	a4,a5
  68:	fdc42783          	lw	a5,-36(s0)
  6c:	0007071b          	sext.w	a4,a4
  70:	0007879b          	sext.w	a5,a5
  74:	fef760e3          	bltu	a4,a5,54 <wait+0x1c>
  78:	00000013          	nop
  7c:	00000013          	nop
  80:	02813403          	ld	s0,40(sp)
  84:	03010113          	addi	sp,sp,48
  88:	00008067          	ret

Disassembly of section .text.main:

000000000000008c <main>:
  8c:	ff010113          	addi	sp,sp,-16
  90:	00113423          	sd	ra,8(sp)
  94:	00813023          	sd	s0,0(sp)
  98:	01010413          	addi	s0,sp,16
  9c:	00001517          	auipc	a0,0x1
  a0:	1a450513          	addi	a0,a0,420 # 1240 <printf+0x29c>
  a4:	701000ef          	jal	fa4 <printf>
  a8:	f5dff0ef          	jal	4 <getpid>
  ac:	00050593          	mv	a1,a0
  b0:	00002797          	auipc	a5,0x2
  b4:	21878793          	addi	a5,a5,536 # 22c8 <global_increment>
  b8:	0007b783          	ld	a5,0(a5)
  bc:	00178693          	addi	a3,a5,1
  c0:	00002717          	auipc	a4,0x2
  c4:	20870713          	addi	a4,a4,520 # 22c8 <global_increment>
  c8:	00d73023          	sd	a3,0(a4)
  cc:	00078613          	mv	a2,a5
  d0:	00001517          	auipc	a0,0x1
  d4:	18050513          	addi	a0,a0,384 # 1250 <printf+0x2ac>
  d8:	6cd000ef          	jal	fa4 <printf>
  dc:	500007b7          	lui	a5,0x50000
  e0:	fff78513          	addi	a0,a5,-1 # 4fffffff <buffer+0x4fffdd27>
  e4:	f55ff0ef          	jal	38 <wait>
  e8:	00000013          	nop
  ec:	fbdff06f          	j	a8 <main+0x1c>

Disassembly of section .text.putc:

00000000000000f0 <putc>:
  f0:	fe010113          	addi	sp,sp,-32
  f4:	00813c23          	sd	s0,24(sp)
  f8:	02010413          	addi	s0,sp,32
  fc:	00050793          	mv	a5,a0
 100:	fef42623          	sw	a5,-20(s0)
 104:	00002797          	auipc	a5,0x2
 108:	1cc78793          	addi	a5,a5,460 # 22d0 <tail>
 10c:	0007a783          	lw	a5,0(a5)
 110:	0017871b          	addiw	a4,a5,1
 114:	0007069b          	sext.w	a3,a4
 118:	00002717          	auipc	a4,0x2
 11c:	1b870713          	addi	a4,a4,440 # 22d0 <tail>
 120:	00d72023          	sw	a3,0(a4)
 124:	fec42703          	lw	a4,-20(s0)
 128:	0ff77713          	zext.b	a4,a4
 12c:	00002697          	auipc	a3,0x2
 130:	1ac68693          	addi	a3,a3,428 # 22d8 <buffer>
 134:	00f687b3          	add	a5,a3,a5
 138:	00e78023          	sb	a4,0(a5)
 13c:	fec42783          	lw	a5,-20(s0)
 140:	0ff7f793          	zext.b	a5,a5
 144:	0007879b          	sext.w	a5,a5
 148:	00078513          	mv	a0,a5
 14c:	01813403          	ld	s0,24(sp)
 150:	02010113          	addi	sp,sp,32
 154:	00008067          	ret

Disassembly of section .text.isspace:

0000000000000158 <isspace>:
 158:	fe010113          	addi	sp,sp,-32
 15c:	00813c23          	sd	s0,24(sp)
 160:	02010413          	addi	s0,sp,32
 164:	00050793          	mv	a5,a0
 168:	fef42623          	sw	a5,-20(s0)
 16c:	fec42783          	lw	a5,-20(s0)
 170:	0007871b          	sext.w	a4,a5
 174:	02000793          	li	a5,32
 178:	02f70263          	beq	a4,a5,19c <isspace+0x44>
 17c:	fec42783          	lw	a5,-20(s0)
 180:	0007871b          	sext.w	a4,a5
 184:	00800793          	li	a5,8
 188:	00e7de63          	bge	a5,a4,1a4 <isspace+0x4c>
 18c:	fec42783          	lw	a5,-20(s0)
 190:	0007871b          	sext.w	a4,a5
 194:	00d00793          	li	a5,13
 198:	00e7c663          	blt	a5,a4,1a4 <isspace+0x4c>
 19c:	00100793          	li	a5,1
 1a0:	0080006f          	j	1a8 <isspace+0x50>
 1a4:	00000793          	li	a5,0
 1a8:	00078513          	mv	a0,a5
 1ac:	01813403          	ld	s0,24(sp)
 1b0:	02010113          	addi	sp,sp,32
 1b4:	00008067          	ret

Disassembly of section .text.strtol:

00000000000001b8 <strtol>:
 1b8:	fb010113          	addi	sp,sp,-80
 1bc:	04113423          	sd	ra,72(sp)
 1c0:	04813023          	sd	s0,64(sp)
 1c4:	05010413          	addi	s0,sp,80
 1c8:	fca43423          	sd	a0,-56(s0)
 1cc:	fcb43023          	sd	a1,-64(s0)
 1d0:	00060793          	mv	a5,a2
 1d4:	faf42e23          	sw	a5,-68(s0)
 1d8:	fe043423          	sd	zero,-24(s0)
 1dc:	fe0403a3          	sb	zero,-25(s0)
 1e0:	fc843783          	ld	a5,-56(s0)
 1e4:	fcf43c23          	sd	a5,-40(s0)
 1e8:	0100006f          	j	1f8 <strtol+0x40>
 1ec:	fd843783          	ld	a5,-40(s0)
 1f0:	00178793          	addi	a5,a5,1
 1f4:	fcf43c23          	sd	a5,-40(s0)
 1f8:	fd843783          	ld	a5,-40(s0)
 1fc:	0007c783          	lbu	a5,0(a5)
 200:	0007879b          	sext.w	a5,a5
 204:	00078513          	mv	a0,a5
 208:	f51ff0ef          	jal	158 <isspace>
 20c:	00050793          	mv	a5,a0
 210:	fc079ee3          	bnez	a5,1ec <strtol+0x34>
 214:	fd843783          	ld	a5,-40(s0)
 218:	0007c783          	lbu	a5,0(a5)
 21c:	00078713          	mv	a4,a5
 220:	02d00793          	li	a5,45
 224:	00f71e63          	bne	a4,a5,240 <strtol+0x88>
 228:	00100793          	li	a5,1
 22c:	fef403a3          	sb	a5,-25(s0)
 230:	fd843783          	ld	a5,-40(s0)
 234:	00178793          	addi	a5,a5,1
 238:	fcf43c23          	sd	a5,-40(s0)
 23c:	0240006f          	j	260 <strtol+0xa8>
 240:	fd843783          	ld	a5,-40(s0)
 244:	0007c783          	lbu	a5,0(a5)
 248:	00078713          	mv	a4,a5
 24c:	02b00793          	li	a5,43
 250:	00f71863          	bne	a4,a5,260 <strtol+0xa8>
 254:	fd843783          	ld	a5,-40(s0)
 258:	00178793          	addi	a5,a5,1
 25c:	fcf43c23          	sd	a5,-40(s0)
 260:	fbc42783          	lw	a5,-68(s0)
 264:	0007879b          	sext.w	a5,a5
 268:	06079c63          	bnez	a5,2e0 <strtol+0x128>
 26c:	fd843783          	ld	a5,-40(s0)
 270:	0007c783          	lbu	a5,0(a5)
 274:	00078713          	mv	a4,a5
 278:	03000793          	li	a5,48
 27c:	04f71e63          	bne	a4,a5,2d8 <strtol+0x120>
 280:	fd843783          	ld	a5,-40(s0)
 284:	00178793          	addi	a5,a5,1
 288:	fcf43c23          	sd	a5,-40(s0)
 28c:	fd843783          	ld	a5,-40(s0)
 290:	0007c783          	lbu	a5,0(a5)
 294:	00078713          	mv	a4,a5
 298:	07800793          	li	a5,120
 29c:	00f70c63          	beq	a4,a5,2b4 <strtol+0xfc>
 2a0:	fd843783          	ld	a5,-40(s0)
 2a4:	0007c783          	lbu	a5,0(a5)
 2a8:	00078713          	mv	a4,a5
 2ac:	05800793          	li	a5,88
 2b0:	00f71e63          	bne	a4,a5,2cc <strtol+0x114>
 2b4:	01000793          	li	a5,16
 2b8:	faf42e23          	sw	a5,-68(s0)
 2bc:	fd843783          	ld	a5,-40(s0)
 2c0:	00178793          	addi	a5,a5,1
 2c4:	fcf43c23          	sd	a5,-40(s0)
 2c8:	0180006f          	j	2e0 <strtol+0x128>
 2cc:	00800793          	li	a5,8
 2d0:	faf42e23          	sw	a5,-68(s0)
 2d4:	00c0006f          	j	2e0 <strtol+0x128>
 2d8:	00a00793          	li	a5,10
 2dc:	faf42e23          	sw	a5,-68(s0)
 2e0:	fd843783          	ld	a5,-40(s0)
 2e4:	0007c783          	lbu	a5,0(a5)
 2e8:	00078713          	mv	a4,a5
 2ec:	02f00793          	li	a5,47
 2f0:	02e7f863          	bgeu	a5,a4,320 <strtol+0x168>
 2f4:	fd843783          	ld	a5,-40(s0)
 2f8:	0007c783          	lbu	a5,0(a5)
 2fc:	00078713          	mv	a4,a5
 300:	03900793          	li	a5,57
 304:	00e7ee63          	bltu	a5,a4,320 <strtol+0x168>
 308:	fd843783          	ld	a5,-40(s0)
 30c:	0007c783          	lbu	a5,0(a5)
 310:	0007879b          	sext.w	a5,a5
 314:	fd07879b          	addiw	a5,a5,-48
 318:	fcf42a23          	sw	a5,-44(s0)
 31c:	0800006f          	j	39c <strtol+0x1e4>
 320:	fd843783          	ld	a5,-40(s0)
 324:	0007c783          	lbu	a5,0(a5)
 328:	00078713          	mv	a4,a5
 32c:	06000793          	li	a5,96
 330:	02e7f863          	bgeu	a5,a4,360 <strtol+0x1a8>
 334:	fd843783          	ld	a5,-40(s0)
 338:	0007c783          	lbu	a5,0(a5)
 33c:	00078713          	mv	a4,a5
 340:	07a00793          	li	a5,122
 344:	00e7ee63          	bltu	a5,a4,360 <strtol+0x1a8>
 348:	fd843783          	ld	a5,-40(s0)
 34c:	0007c783          	lbu	a5,0(a5)
 350:	0007879b          	sext.w	a5,a5
 354:	fa97879b          	addiw	a5,a5,-87
 358:	fcf42a23          	sw	a5,-44(s0)
 35c:	0400006f          	j	39c <strtol+0x1e4>
 360:	fd843783          	ld	a5,-40(s0)
 364:	0007c783          	lbu	a5,0(a5)
 368:	00078713          	mv	a4,a5
 36c:	04000793          	li	a5,64
 370:	06e7f863          	bgeu	a5,a4,3e0 <strtol+0x228>
 374:	fd843783          	ld	a5,-40(s0)
 378:	0007c783          	lbu	a5,0(a5)
 37c:	00078713          	mv	a4,a5
 380:	05a00793          	li	a5,90
 384:	04e7ee63          	bltu	a5,a4,3e0 <strtol+0x228>
 388:	fd843783          	ld	a5,-40(s0)
 38c:	0007c783          	lbu	a5,0(a5)
 390:	0007879b          	sext.w	a5,a5
 394:	fc97879b          	addiw	a5,a5,-55
 398:	fcf42a23          	sw	a5,-44(s0)
 39c:	fd442783          	lw	a5,-44(s0)
 3a0:	00078713          	mv	a4,a5
 3a4:	fbc42783          	lw	a5,-68(s0)
 3a8:	0007071b          	sext.w	a4,a4
 3ac:	0007879b          	sext.w	a5,a5
 3b0:	02f75663          	bge	a4,a5,3dc <strtol+0x224>
 3b4:	fbc42703          	lw	a4,-68(s0)
 3b8:	fe843783          	ld	a5,-24(s0)
 3bc:	02f70733          	mul	a4,a4,a5
 3c0:	fd442783          	lw	a5,-44(s0)
 3c4:	00f707b3          	add	a5,a4,a5
 3c8:	fef43423          	sd	a5,-24(s0)
 3cc:	fd843783          	ld	a5,-40(s0)
 3d0:	00178793          	addi	a5,a5,1
 3d4:	fcf43c23          	sd	a5,-40(s0)
 3d8:	f09ff06f          	j	2e0 <strtol+0x128>
 3dc:	00000013          	nop
 3e0:	fc043783          	ld	a5,-64(s0)
 3e4:	00078863          	beqz	a5,3f4 <strtol+0x23c>
 3e8:	fc043783          	ld	a5,-64(s0)
 3ec:	fd843703          	ld	a4,-40(s0)
 3f0:	00e7b023          	sd	a4,0(a5)
 3f4:	fe744783          	lbu	a5,-25(s0)
 3f8:	0ff7f793          	zext.b	a5,a5
 3fc:	00078863          	beqz	a5,40c <strtol+0x254>
 400:	fe843783          	ld	a5,-24(s0)
 404:	40f007b3          	neg	a5,a5
 408:	0080006f          	j	410 <strtol+0x258>
 40c:	fe843783          	ld	a5,-24(s0)
 410:	00078513          	mv	a0,a5
 414:	04813083          	ld	ra,72(sp)
 418:	04013403          	ld	s0,64(sp)
 41c:	05010113          	addi	sp,sp,80
 420:	00008067          	ret

Disassembly of section .text.puts_wo_nl:

0000000000000424 <puts_wo_nl>:
 424:	fd010113          	addi	sp,sp,-48
 428:	02113423          	sd	ra,40(sp)
 42c:	02813023          	sd	s0,32(sp)
 430:	03010413          	addi	s0,sp,48
 434:	fca43c23          	sd	a0,-40(s0)
 438:	fcb43823          	sd	a1,-48(s0)
 43c:	fd043783          	ld	a5,-48(s0)
 440:	00079863          	bnez	a5,450 <puts_wo_nl+0x2c>
 444:	00001797          	auipc	a5,0x1
 448:	e3478793          	addi	a5,a5,-460 # 1278 <printf+0x2d4>
 44c:	fcf43823          	sd	a5,-48(s0)
 450:	fd043783          	ld	a5,-48(s0)
 454:	fef43423          	sd	a5,-24(s0)
 458:	0240006f          	j	47c <puts_wo_nl+0x58>
 45c:	fe843783          	ld	a5,-24(s0)
 460:	00178713          	addi	a4,a5,1
 464:	fee43423          	sd	a4,-24(s0)
 468:	0007c783          	lbu	a5,0(a5)
 46c:	0007871b          	sext.w	a4,a5
 470:	fd843783          	ld	a5,-40(s0)
 474:	00070513          	mv	a0,a4
 478:	000780e7          	jalr	a5
 47c:	fe843783          	ld	a5,-24(s0)
 480:	0007c783          	lbu	a5,0(a5)
 484:	fc079ce3          	bnez	a5,45c <puts_wo_nl+0x38>
 488:	fe843703          	ld	a4,-24(s0)
 48c:	fd043783          	ld	a5,-48(s0)
 490:	40f707b3          	sub	a5,a4,a5
 494:	0007879b          	sext.w	a5,a5
 498:	00078513          	mv	a0,a5
 49c:	02813083          	ld	ra,40(sp)
 4a0:	02013403          	ld	s0,32(sp)
 4a4:	03010113          	addi	sp,sp,48
 4a8:	00008067          	ret

Disassembly of section .text.print_dec_int:

00000000000004ac <print_dec_int>:
 4ac:	f9010113          	addi	sp,sp,-112
 4b0:	06113423          	sd	ra,104(sp)
 4b4:	06813023          	sd	s0,96(sp)
 4b8:	07010413          	addi	s0,sp,112
 4bc:	faa43423          	sd	a0,-88(s0)
 4c0:	fab43023          	sd	a1,-96(s0)
 4c4:	00060793          	mv	a5,a2
 4c8:	f8d43823          	sd	a3,-112(s0)
 4cc:	f8f40fa3          	sb	a5,-97(s0)
 4d0:	f9f44783          	lbu	a5,-97(s0)
 4d4:	0ff7f793          	zext.b	a5,a5
 4d8:	02078663          	beqz	a5,504 <print_dec_int+0x58>
 4dc:	fa043703          	ld	a4,-96(s0)
 4e0:	fff00793          	li	a5,-1
 4e4:	03f79793          	slli	a5,a5,0x3f
 4e8:	00f71e63          	bne	a4,a5,504 <print_dec_int+0x58>
 4ec:	00001597          	auipc	a1,0x1
 4f0:	d9458593          	addi	a1,a1,-620 # 1280 <printf+0x2dc>
 4f4:	fa843503          	ld	a0,-88(s0)
 4f8:	f2dff0ef          	jal	424 <puts_wo_nl>
 4fc:	00050793          	mv	a5,a0
 500:	2a00006f          	j	7a0 <print_dec_int+0x2f4>
 504:	f9043783          	ld	a5,-112(s0)
 508:	00c7a783          	lw	a5,12(a5)
 50c:	00079a63          	bnez	a5,520 <print_dec_int+0x74>
 510:	fa043783          	ld	a5,-96(s0)
 514:	00079663          	bnez	a5,520 <print_dec_int+0x74>
 518:	00000793          	li	a5,0
 51c:	2840006f          	j	7a0 <print_dec_int+0x2f4>
 520:	fe0407a3          	sb	zero,-17(s0)
 524:	f9f44783          	lbu	a5,-97(s0)
 528:	0ff7f793          	zext.b	a5,a5
 52c:	02078063          	beqz	a5,54c <print_dec_int+0xa0>
 530:	fa043783          	ld	a5,-96(s0)
 534:	0007dc63          	bgez	a5,54c <print_dec_int+0xa0>
 538:	00100793          	li	a5,1
 53c:	fef407a3          	sb	a5,-17(s0)
 540:	fa043783          	ld	a5,-96(s0)
 544:	40f007b3          	neg	a5,a5
 548:	faf43023          	sd	a5,-96(s0)
 54c:	fe042423          	sw	zero,-24(s0)
 550:	f9f44783          	lbu	a5,-97(s0)
 554:	0ff7f793          	zext.b	a5,a5
 558:	02078863          	beqz	a5,588 <print_dec_int+0xdc>
 55c:	fef44783          	lbu	a5,-17(s0)
 560:	0ff7f793          	zext.b	a5,a5
 564:	00079e63          	bnez	a5,580 <print_dec_int+0xd4>
 568:	f9043783          	ld	a5,-112(s0)
 56c:	0057c783          	lbu	a5,5(a5)
 570:	00079863          	bnez	a5,580 <print_dec_int+0xd4>
 574:	f9043783          	ld	a5,-112(s0)
 578:	0047c783          	lbu	a5,4(a5)
 57c:	00078663          	beqz	a5,588 <print_dec_int+0xdc>
 580:	00100793          	li	a5,1
 584:	0080006f          	j	58c <print_dec_int+0xe0>
 588:	00000793          	li	a5,0
 58c:	fcf40ba3          	sb	a5,-41(s0)
 590:	fd744783          	lbu	a5,-41(s0)
 594:	0017f793          	andi	a5,a5,1
 598:	fcf40ba3          	sb	a5,-41(s0)
 59c:	fa043703          	ld	a4,-96(s0)
 5a0:	00a00793          	li	a5,10
 5a4:	02f777b3          	remu	a5,a4,a5
 5a8:	0ff7f713          	zext.b	a4,a5
 5ac:	fe842783          	lw	a5,-24(s0)
 5b0:	0017869b          	addiw	a3,a5,1
 5b4:	fed42423          	sw	a3,-24(s0)
 5b8:	0307071b          	addiw	a4,a4,48
 5bc:	0ff77713          	zext.b	a4,a4
 5c0:	ff078793          	addi	a5,a5,-16
 5c4:	008787b3          	add	a5,a5,s0
 5c8:	fce78423          	sb	a4,-56(a5)
 5cc:	fa043703          	ld	a4,-96(s0)
 5d0:	00a00793          	li	a5,10
 5d4:	02f757b3          	divu	a5,a4,a5
 5d8:	faf43023          	sd	a5,-96(s0)
 5dc:	fa043783          	ld	a5,-96(s0)
 5e0:	fa079ee3          	bnez	a5,59c <print_dec_int+0xf0>
 5e4:	f9043783          	ld	a5,-112(s0)
 5e8:	00c7a783          	lw	a5,12(a5)
 5ec:	00078713          	mv	a4,a5
 5f0:	fff00793          	li	a5,-1
 5f4:	02f71063          	bne	a4,a5,614 <print_dec_int+0x168>
 5f8:	f9043783          	ld	a5,-112(s0)
 5fc:	0037c783          	lbu	a5,3(a5)
 600:	00078a63          	beqz	a5,614 <print_dec_int+0x168>
 604:	f9043783          	ld	a5,-112(s0)
 608:	0087a703          	lw	a4,8(a5)
 60c:	f9043783          	ld	a5,-112(s0)
 610:	00e7a623          	sw	a4,12(a5)
 614:	fe042223          	sw	zero,-28(s0)
 618:	f9043783          	ld	a5,-112(s0)
 61c:	0087a703          	lw	a4,8(a5)
 620:	fe842783          	lw	a5,-24(s0)
 624:	fcf42823          	sw	a5,-48(s0)
 628:	f9043783          	ld	a5,-112(s0)
 62c:	00c7a783          	lw	a5,12(a5)
 630:	fcf42623          	sw	a5,-52(s0)
 634:	fd042783          	lw	a5,-48(s0)
 638:	00078593          	mv	a1,a5
 63c:	fcc42783          	lw	a5,-52(s0)
 640:	00078613          	mv	a2,a5
 644:	0006069b          	sext.w	a3,a2
 648:	0005879b          	sext.w	a5,a1
 64c:	00f6d463          	bge	a3,a5,654 <print_dec_int+0x1a8>
 650:	00058613          	mv	a2,a1
 654:	0006079b          	sext.w	a5,a2
 658:	40f707bb          	subw	a5,a4,a5
 65c:	0007871b          	sext.w	a4,a5
 660:	fd744783          	lbu	a5,-41(s0)
 664:	0007879b          	sext.w	a5,a5
 668:	40f707bb          	subw	a5,a4,a5
 66c:	fef42023          	sw	a5,-32(s0)
 670:	0280006f          	j	698 <print_dec_int+0x1ec>
 674:	fa843783          	ld	a5,-88(s0)
 678:	02000513          	li	a0,32
 67c:	000780e7          	jalr	a5
 680:	fe442783          	lw	a5,-28(s0)
 684:	0017879b          	addiw	a5,a5,1
 688:	fef42223          	sw	a5,-28(s0)
 68c:	fe042783          	lw	a5,-32(s0)
 690:	fff7879b          	addiw	a5,a5,-1
 694:	fef42023          	sw	a5,-32(s0)
 698:	fe042783          	lw	a5,-32(s0)
 69c:	0007879b          	sext.w	a5,a5
 6a0:	fcf04ae3          	bgtz	a5,674 <print_dec_int+0x1c8>
 6a4:	fd744783          	lbu	a5,-41(s0)
 6a8:	0ff7f793          	zext.b	a5,a5
 6ac:	04078463          	beqz	a5,6f4 <print_dec_int+0x248>
 6b0:	fef44783          	lbu	a5,-17(s0)
 6b4:	0ff7f793          	zext.b	a5,a5
 6b8:	00078663          	beqz	a5,6c4 <print_dec_int+0x218>
 6bc:	02d00793          	li	a5,45
 6c0:	01c0006f          	j	6dc <print_dec_int+0x230>
 6c4:	f9043783          	ld	a5,-112(s0)
 6c8:	0057c783          	lbu	a5,5(a5)
 6cc:	00078663          	beqz	a5,6d8 <print_dec_int+0x22c>
 6d0:	02b00793          	li	a5,43
 6d4:	0080006f          	j	6dc <print_dec_int+0x230>
 6d8:	02000793          	li	a5,32
 6dc:	fa843703          	ld	a4,-88(s0)
 6e0:	00078513          	mv	a0,a5
 6e4:	000700e7          	jalr	a4
 6e8:	fe442783          	lw	a5,-28(s0)
 6ec:	0017879b          	addiw	a5,a5,1
 6f0:	fef42223          	sw	a5,-28(s0)
 6f4:	fe842783          	lw	a5,-24(s0)
 6f8:	fcf42e23          	sw	a5,-36(s0)
 6fc:	0280006f          	j	724 <print_dec_int+0x278>
 700:	fa843783          	ld	a5,-88(s0)
 704:	03000513          	li	a0,48
 708:	000780e7          	jalr	a5
 70c:	fe442783          	lw	a5,-28(s0)
 710:	0017879b          	addiw	a5,a5,1
 714:	fef42223          	sw	a5,-28(s0)
 718:	fdc42783          	lw	a5,-36(s0)
 71c:	0017879b          	addiw	a5,a5,1
 720:	fcf42e23          	sw	a5,-36(s0)
 724:	f9043783          	ld	a5,-112(s0)
 728:	00c7a703          	lw	a4,12(a5)
 72c:	fd744783          	lbu	a5,-41(s0)
 730:	0007879b          	sext.w	a5,a5
 734:	40f707bb          	subw	a5,a4,a5
 738:	0007871b          	sext.w	a4,a5
 73c:	fdc42783          	lw	a5,-36(s0)
 740:	0007879b          	sext.w	a5,a5
 744:	fae7cee3          	blt	a5,a4,700 <print_dec_int+0x254>
 748:	fe842783          	lw	a5,-24(s0)
 74c:	fff7879b          	addiw	a5,a5,-1
 750:	fcf42c23          	sw	a5,-40(s0)
 754:	03c0006f          	j	790 <print_dec_int+0x2e4>
 758:	fd842783          	lw	a5,-40(s0)
 75c:	ff078793          	addi	a5,a5,-16
 760:	008787b3          	add	a5,a5,s0
 764:	fc87c783          	lbu	a5,-56(a5)
 768:	0007871b          	sext.w	a4,a5
 76c:	fa843783          	ld	a5,-88(s0)
 770:	00070513          	mv	a0,a4
 774:	000780e7          	jalr	a5
 778:	fe442783          	lw	a5,-28(s0)
 77c:	0017879b          	addiw	a5,a5,1
 780:	fef42223          	sw	a5,-28(s0)
 784:	fd842783          	lw	a5,-40(s0)
 788:	fff7879b          	addiw	a5,a5,-1
 78c:	fcf42c23          	sw	a5,-40(s0)
 790:	fd842783          	lw	a5,-40(s0)
 794:	0007879b          	sext.w	a5,a5
 798:	fc07d0e3          	bgez	a5,758 <print_dec_int+0x2ac>
 79c:	fe442783          	lw	a5,-28(s0)
 7a0:	00078513          	mv	a0,a5
 7a4:	06813083          	ld	ra,104(sp)
 7a8:	06013403          	ld	s0,96(sp)
 7ac:	07010113          	addi	sp,sp,112
 7b0:	00008067          	ret

Disassembly of section .text.vprintfmt:

00000000000007b4 <vprintfmt>:
 7b4:	f4010113          	addi	sp,sp,-192
 7b8:	0a113c23          	sd	ra,184(sp)
 7bc:	0a813823          	sd	s0,176(sp)
 7c0:	0c010413          	addi	s0,sp,192
 7c4:	f4a43c23          	sd	a0,-168(s0)
 7c8:	f4b43823          	sd	a1,-176(s0)
 7cc:	f4c43423          	sd	a2,-184(s0)
 7d0:	f8043023          	sd	zero,-128(s0)
 7d4:	f8043423          	sd	zero,-120(s0)
 7d8:	fe042623          	sw	zero,-20(s0)
 7dc:	7a40006f          	j	f80 <vprintfmt+0x7cc>
 7e0:	f8044783          	lbu	a5,-128(s0)
 7e4:	72078e63          	beqz	a5,f20 <vprintfmt+0x76c>
 7e8:	f5043783          	ld	a5,-176(s0)
 7ec:	0007c783          	lbu	a5,0(a5)
 7f0:	00078713          	mv	a4,a5
 7f4:	02300793          	li	a5,35
 7f8:	00f71863          	bne	a4,a5,808 <vprintfmt+0x54>
 7fc:	00100793          	li	a5,1
 800:	f8f40123          	sb	a5,-126(s0)
 804:	7700006f          	j	f74 <vprintfmt+0x7c0>
 808:	f5043783          	ld	a5,-176(s0)
 80c:	0007c783          	lbu	a5,0(a5)
 810:	00078713          	mv	a4,a5
 814:	03000793          	li	a5,48
 818:	00f71863          	bne	a4,a5,828 <vprintfmt+0x74>
 81c:	00100793          	li	a5,1
 820:	f8f401a3          	sb	a5,-125(s0)
 824:	7500006f          	j	f74 <vprintfmt+0x7c0>
 828:	f5043783          	ld	a5,-176(s0)
 82c:	0007c783          	lbu	a5,0(a5)
 830:	00078713          	mv	a4,a5
 834:	06c00793          	li	a5,108
 838:	04f70063          	beq	a4,a5,878 <vprintfmt+0xc4>
 83c:	f5043783          	ld	a5,-176(s0)
 840:	0007c783          	lbu	a5,0(a5)
 844:	00078713          	mv	a4,a5
 848:	07a00793          	li	a5,122
 84c:	02f70663          	beq	a4,a5,878 <vprintfmt+0xc4>
 850:	f5043783          	ld	a5,-176(s0)
 854:	0007c783          	lbu	a5,0(a5)
 858:	00078713          	mv	a4,a5
 85c:	07400793          	li	a5,116
 860:	00f70c63          	beq	a4,a5,878 <vprintfmt+0xc4>
 864:	f5043783          	ld	a5,-176(s0)
 868:	0007c783          	lbu	a5,0(a5)
 86c:	00078713          	mv	a4,a5
 870:	06a00793          	li	a5,106
 874:	00f71863          	bne	a4,a5,884 <vprintfmt+0xd0>
 878:	00100793          	li	a5,1
 87c:	f8f400a3          	sb	a5,-127(s0)
 880:	6f40006f          	j	f74 <vprintfmt+0x7c0>
 884:	f5043783          	ld	a5,-176(s0)
 888:	0007c783          	lbu	a5,0(a5)
 88c:	00078713          	mv	a4,a5
 890:	02b00793          	li	a5,43
 894:	00f71863          	bne	a4,a5,8a4 <vprintfmt+0xf0>
 898:	00100793          	li	a5,1
 89c:	f8f402a3          	sb	a5,-123(s0)
 8a0:	6d40006f          	j	f74 <vprintfmt+0x7c0>
 8a4:	f5043783          	ld	a5,-176(s0)
 8a8:	0007c783          	lbu	a5,0(a5)
 8ac:	00078713          	mv	a4,a5
 8b0:	02000793          	li	a5,32
 8b4:	00f71863          	bne	a4,a5,8c4 <vprintfmt+0x110>
 8b8:	00100793          	li	a5,1
 8bc:	f8f40223          	sb	a5,-124(s0)
 8c0:	6b40006f          	j	f74 <vprintfmt+0x7c0>
 8c4:	f5043783          	ld	a5,-176(s0)
 8c8:	0007c783          	lbu	a5,0(a5)
 8cc:	00078713          	mv	a4,a5
 8d0:	02a00793          	li	a5,42
 8d4:	00f71e63          	bne	a4,a5,8f0 <vprintfmt+0x13c>
 8d8:	f4843783          	ld	a5,-184(s0)
 8dc:	00878713          	addi	a4,a5,8
 8e0:	f4e43423          	sd	a4,-184(s0)
 8e4:	0007a783          	lw	a5,0(a5)
 8e8:	f8f42423          	sw	a5,-120(s0)
 8ec:	6880006f          	j	f74 <vprintfmt+0x7c0>
 8f0:	f5043783          	ld	a5,-176(s0)
 8f4:	0007c783          	lbu	a5,0(a5)
 8f8:	00078713          	mv	a4,a5
 8fc:	03000793          	li	a5,48
 900:	04e7f663          	bgeu	a5,a4,94c <vprintfmt+0x198>
 904:	f5043783          	ld	a5,-176(s0)
 908:	0007c783          	lbu	a5,0(a5)
 90c:	00078713          	mv	a4,a5
 910:	03900793          	li	a5,57
 914:	02e7ec63          	bltu	a5,a4,94c <vprintfmt+0x198>
 918:	f5043783          	ld	a5,-176(s0)
 91c:	f5040713          	addi	a4,s0,-176
 920:	00a00613          	li	a2,10
 924:	00070593          	mv	a1,a4
 928:	00078513          	mv	a0,a5
 92c:	88dff0ef          	jal	1b8 <strtol>
 930:	00050793          	mv	a5,a0
 934:	0007879b          	sext.w	a5,a5
 938:	f8f42423          	sw	a5,-120(s0)
 93c:	f5043783          	ld	a5,-176(s0)
 940:	fff78793          	addi	a5,a5,-1
 944:	f4f43823          	sd	a5,-176(s0)
 948:	62c0006f          	j	f74 <vprintfmt+0x7c0>
 94c:	f5043783          	ld	a5,-176(s0)
 950:	0007c783          	lbu	a5,0(a5)
 954:	00078713          	mv	a4,a5
 958:	02e00793          	li	a5,46
 95c:	06f71863          	bne	a4,a5,9cc <vprintfmt+0x218>
 960:	f5043783          	ld	a5,-176(s0)
 964:	00178793          	addi	a5,a5,1
 968:	f4f43823          	sd	a5,-176(s0)
 96c:	f5043783          	ld	a5,-176(s0)
 970:	0007c783          	lbu	a5,0(a5)
 974:	00078713          	mv	a4,a5
 978:	02a00793          	li	a5,42
 97c:	00f71e63          	bne	a4,a5,998 <vprintfmt+0x1e4>
 980:	f4843783          	ld	a5,-184(s0)
 984:	00878713          	addi	a4,a5,8
 988:	f4e43423          	sd	a4,-184(s0)
 98c:	0007a783          	lw	a5,0(a5)
 990:	f8f42623          	sw	a5,-116(s0)
 994:	5e00006f          	j	f74 <vprintfmt+0x7c0>
 998:	f5043783          	ld	a5,-176(s0)
 99c:	f5040713          	addi	a4,s0,-176
 9a0:	00a00613          	li	a2,10
 9a4:	00070593          	mv	a1,a4
 9a8:	00078513          	mv	a0,a5
 9ac:	80dff0ef          	jal	1b8 <strtol>
 9b0:	00050793          	mv	a5,a0
 9b4:	0007879b          	sext.w	a5,a5
 9b8:	f8f42623          	sw	a5,-116(s0)
 9bc:	f5043783          	ld	a5,-176(s0)
 9c0:	fff78793          	addi	a5,a5,-1
 9c4:	f4f43823          	sd	a5,-176(s0)
 9c8:	5ac0006f          	j	f74 <vprintfmt+0x7c0>
 9cc:	f5043783          	ld	a5,-176(s0)
 9d0:	0007c783          	lbu	a5,0(a5)
 9d4:	00078713          	mv	a4,a5
 9d8:	07800793          	li	a5,120
 9dc:	02f70663          	beq	a4,a5,a08 <vprintfmt+0x254>
 9e0:	f5043783          	ld	a5,-176(s0)
 9e4:	0007c783          	lbu	a5,0(a5)
 9e8:	00078713          	mv	a4,a5
 9ec:	05800793          	li	a5,88
 9f0:	00f70c63          	beq	a4,a5,a08 <vprintfmt+0x254>
 9f4:	f5043783          	ld	a5,-176(s0)
 9f8:	0007c783          	lbu	a5,0(a5)
 9fc:	00078713          	mv	a4,a5
 a00:	07000793          	li	a5,112
 a04:	30f71263          	bne	a4,a5,d08 <vprintfmt+0x554>
 a08:	f5043783          	ld	a5,-176(s0)
 a0c:	0007c783          	lbu	a5,0(a5)
 a10:	00078713          	mv	a4,a5
 a14:	07000793          	li	a5,112
 a18:	00f70663          	beq	a4,a5,a24 <vprintfmt+0x270>
 a1c:	f8144783          	lbu	a5,-127(s0)
 a20:	00078663          	beqz	a5,a2c <vprintfmt+0x278>
 a24:	00100793          	li	a5,1
 a28:	0080006f          	j	a30 <vprintfmt+0x27c>
 a2c:	00000793          	li	a5,0
 a30:	faf403a3          	sb	a5,-89(s0)
 a34:	fa744783          	lbu	a5,-89(s0)
 a38:	0017f793          	andi	a5,a5,1
 a3c:	faf403a3          	sb	a5,-89(s0)
 a40:	fa744783          	lbu	a5,-89(s0)
 a44:	0ff7f793          	zext.b	a5,a5
 a48:	00078c63          	beqz	a5,a60 <vprintfmt+0x2ac>
 a4c:	f4843783          	ld	a5,-184(s0)
 a50:	00878713          	addi	a4,a5,8
 a54:	f4e43423          	sd	a4,-184(s0)
 a58:	0007b783          	ld	a5,0(a5)
 a5c:	01c0006f          	j	a78 <vprintfmt+0x2c4>
 a60:	f4843783          	ld	a5,-184(s0)
 a64:	00878713          	addi	a4,a5,8
 a68:	f4e43423          	sd	a4,-184(s0)
 a6c:	0007a783          	lw	a5,0(a5)
 a70:	02079793          	slli	a5,a5,0x20
 a74:	0207d793          	srli	a5,a5,0x20
 a78:	fef43023          	sd	a5,-32(s0)
 a7c:	f8c42783          	lw	a5,-116(s0)
 a80:	02079463          	bnez	a5,aa8 <vprintfmt+0x2f4>
 a84:	fe043783          	ld	a5,-32(s0)
 a88:	02079063          	bnez	a5,aa8 <vprintfmt+0x2f4>
 a8c:	f5043783          	ld	a5,-176(s0)
 a90:	0007c783          	lbu	a5,0(a5)
 a94:	00078713          	mv	a4,a5
 a98:	07000793          	li	a5,112
 a9c:	00f70663          	beq	a4,a5,aa8 <vprintfmt+0x2f4>
 aa0:	f8040023          	sb	zero,-128(s0)
 aa4:	4d00006f          	j	f74 <vprintfmt+0x7c0>
 aa8:	f5043783          	ld	a5,-176(s0)
 aac:	0007c783          	lbu	a5,0(a5)
 ab0:	00078713          	mv	a4,a5
 ab4:	07000793          	li	a5,112
 ab8:	00f70a63          	beq	a4,a5,acc <vprintfmt+0x318>
 abc:	f8244783          	lbu	a5,-126(s0)
 ac0:	00078a63          	beqz	a5,ad4 <vprintfmt+0x320>
 ac4:	fe043783          	ld	a5,-32(s0)
 ac8:	00078663          	beqz	a5,ad4 <vprintfmt+0x320>
 acc:	00100793          	li	a5,1
 ad0:	0080006f          	j	ad8 <vprintfmt+0x324>
 ad4:	00000793          	li	a5,0
 ad8:	faf40323          	sb	a5,-90(s0)
 adc:	fa644783          	lbu	a5,-90(s0)
 ae0:	0017f793          	andi	a5,a5,1
 ae4:	faf40323          	sb	a5,-90(s0)
 ae8:	fc042e23          	sw	zero,-36(s0)
 aec:	f5043783          	ld	a5,-176(s0)
 af0:	0007c783          	lbu	a5,0(a5)
 af4:	00078713          	mv	a4,a5
 af8:	05800793          	li	a5,88
 afc:	00f71863          	bne	a4,a5,b0c <vprintfmt+0x358>
 b00:	00000797          	auipc	a5,0x0
 b04:	79878793          	addi	a5,a5,1944 # 1298 <upperxdigits.1>
 b08:	00c0006f          	j	b14 <vprintfmt+0x360>
 b0c:	00000797          	auipc	a5,0x0
 b10:	7a478793          	addi	a5,a5,1956 # 12b0 <lowerxdigits.0>
 b14:	f8f43c23          	sd	a5,-104(s0)
 b18:	fe043783          	ld	a5,-32(s0)
 b1c:	00f7f793          	andi	a5,a5,15
 b20:	f9843703          	ld	a4,-104(s0)
 b24:	00f70733          	add	a4,a4,a5
 b28:	fdc42783          	lw	a5,-36(s0)
 b2c:	0017869b          	addiw	a3,a5,1
 b30:	fcd42e23          	sw	a3,-36(s0)
 b34:	00074703          	lbu	a4,0(a4)
 b38:	ff078793          	addi	a5,a5,-16
 b3c:	008787b3          	add	a5,a5,s0
 b40:	f8e78023          	sb	a4,-128(a5)
 b44:	fe043783          	ld	a5,-32(s0)
 b48:	0047d793          	srli	a5,a5,0x4
 b4c:	fef43023          	sd	a5,-32(s0)
 b50:	fe043783          	ld	a5,-32(s0)
 b54:	fc0792e3          	bnez	a5,b18 <vprintfmt+0x364>
 b58:	f8c42783          	lw	a5,-116(s0)
 b5c:	00078713          	mv	a4,a5
 b60:	fff00793          	li	a5,-1
 b64:	02f71663          	bne	a4,a5,b90 <vprintfmt+0x3dc>
 b68:	f8344783          	lbu	a5,-125(s0)
 b6c:	02078263          	beqz	a5,b90 <vprintfmt+0x3dc>
 b70:	f8842703          	lw	a4,-120(s0)
 b74:	fa644783          	lbu	a5,-90(s0)
 b78:	0007879b          	sext.w	a5,a5
 b7c:	0017979b          	slliw	a5,a5,0x1
 b80:	0007879b          	sext.w	a5,a5
 b84:	40f707bb          	subw	a5,a4,a5
 b88:	0007879b          	sext.w	a5,a5
 b8c:	f8f42623          	sw	a5,-116(s0)
 b90:	f8842703          	lw	a4,-120(s0)
 b94:	fa644783          	lbu	a5,-90(s0)
 b98:	0007879b          	sext.w	a5,a5
 b9c:	0017979b          	slliw	a5,a5,0x1
 ba0:	0007879b          	sext.w	a5,a5
 ba4:	40f707bb          	subw	a5,a4,a5
 ba8:	0007871b          	sext.w	a4,a5
 bac:	fdc42783          	lw	a5,-36(s0)
 bb0:	f8f42a23          	sw	a5,-108(s0)
 bb4:	f8c42783          	lw	a5,-116(s0)
 bb8:	f8f42823          	sw	a5,-112(s0)
 bbc:	f9442783          	lw	a5,-108(s0)
 bc0:	00078593          	mv	a1,a5
 bc4:	f9042783          	lw	a5,-112(s0)
 bc8:	00078613          	mv	a2,a5
 bcc:	0006069b          	sext.w	a3,a2
 bd0:	0005879b          	sext.w	a5,a1
 bd4:	00f6d463          	bge	a3,a5,bdc <vprintfmt+0x428>
 bd8:	00058613          	mv	a2,a1
 bdc:	0006079b          	sext.w	a5,a2
 be0:	40f707bb          	subw	a5,a4,a5
 be4:	fcf42c23          	sw	a5,-40(s0)
 be8:	0280006f          	j	c10 <vprintfmt+0x45c>
 bec:	f5843783          	ld	a5,-168(s0)
 bf0:	02000513          	li	a0,32
 bf4:	000780e7          	jalr	a5
 bf8:	fec42783          	lw	a5,-20(s0)
 bfc:	0017879b          	addiw	a5,a5,1
 c00:	fef42623          	sw	a5,-20(s0)
 c04:	fd842783          	lw	a5,-40(s0)
 c08:	fff7879b          	addiw	a5,a5,-1
 c0c:	fcf42c23          	sw	a5,-40(s0)
 c10:	fd842783          	lw	a5,-40(s0)
 c14:	0007879b          	sext.w	a5,a5
 c18:	fcf04ae3          	bgtz	a5,bec <vprintfmt+0x438>
 c1c:	fa644783          	lbu	a5,-90(s0)
 c20:	0ff7f793          	zext.b	a5,a5
 c24:	04078463          	beqz	a5,c6c <vprintfmt+0x4b8>
 c28:	f5843783          	ld	a5,-168(s0)
 c2c:	03000513          	li	a0,48
 c30:	000780e7          	jalr	a5
 c34:	f5043783          	ld	a5,-176(s0)
 c38:	0007c783          	lbu	a5,0(a5)
 c3c:	00078713          	mv	a4,a5
 c40:	05800793          	li	a5,88
 c44:	00f71663          	bne	a4,a5,c50 <vprintfmt+0x49c>
 c48:	05800793          	li	a5,88
 c4c:	0080006f          	j	c54 <vprintfmt+0x4a0>
 c50:	07800793          	li	a5,120
 c54:	f5843703          	ld	a4,-168(s0)
 c58:	00078513          	mv	a0,a5
 c5c:	000700e7          	jalr	a4
 c60:	fec42783          	lw	a5,-20(s0)
 c64:	0027879b          	addiw	a5,a5,2
 c68:	fef42623          	sw	a5,-20(s0)
 c6c:	fdc42783          	lw	a5,-36(s0)
 c70:	fcf42a23          	sw	a5,-44(s0)
 c74:	0280006f          	j	c9c <vprintfmt+0x4e8>
 c78:	f5843783          	ld	a5,-168(s0)
 c7c:	03000513          	li	a0,48
 c80:	000780e7          	jalr	a5
 c84:	fec42783          	lw	a5,-20(s0)
 c88:	0017879b          	addiw	a5,a5,1
 c8c:	fef42623          	sw	a5,-20(s0)
 c90:	fd442783          	lw	a5,-44(s0)
 c94:	0017879b          	addiw	a5,a5,1
 c98:	fcf42a23          	sw	a5,-44(s0)
 c9c:	f8c42703          	lw	a4,-116(s0)
 ca0:	fd442783          	lw	a5,-44(s0)
 ca4:	0007879b          	sext.w	a5,a5
 ca8:	fce7c8e3          	blt	a5,a4,c78 <vprintfmt+0x4c4>
 cac:	fdc42783          	lw	a5,-36(s0)
 cb0:	fff7879b          	addiw	a5,a5,-1
 cb4:	fcf42823          	sw	a5,-48(s0)
 cb8:	03c0006f          	j	cf4 <vprintfmt+0x540>
 cbc:	fd042783          	lw	a5,-48(s0)
 cc0:	ff078793          	addi	a5,a5,-16
 cc4:	008787b3          	add	a5,a5,s0
 cc8:	f807c783          	lbu	a5,-128(a5)
 ccc:	0007871b          	sext.w	a4,a5
 cd0:	f5843783          	ld	a5,-168(s0)
 cd4:	00070513          	mv	a0,a4
 cd8:	000780e7          	jalr	a5
 cdc:	fec42783          	lw	a5,-20(s0)
 ce0:	0017879b          	addiw	a5,a5,1
 ce4:	fef42623          	sw	a5,-20(s0)
 ce8:	fd042783          	lw	a5,-48(s0)
 cec:	fff7879b          	addiw	a5,a5,-1
 cf0:	fcf42823          	sw	a5,-48(s0)
 cf4:	fd042783          	lw	a5,-48(s0)
 cf8:	0007879b          	sext.w	a5,a5
 cfc:	fc07d0e3          	bgez	a5,cbc <vprintfmt+0x508>
 d00:	f8040023          	sb	zero,-128(s0)
 d04:	2700006f          	j	f74 <vprintfmt+0x7c0>
 d08:	f5043783          	ld	a5,-176(s0)
 d0c:	0007c783          	lbu	a5,0(a5)
 d10:	00078713          	mv	a4,a5
 d14:	06400793          	li	a5,100
 d18:	02f70663          	beq	a4,a5,d44 <vprintfmt+0x590>
 d1c:	f5043783          	ld	a5,-176(s0)
 d20:	0007c783          	lbu	a5,0(a5)
 d24:	00078713          	mv	a4,a5
 d28:	06900793          	li	a5,105
 d2c:	00f70c63          	beq	a4,a5,d44 <vprintfmt+0x590>
 d30:	f5043783          	ld	a5,-176(s0)
 d34:	0007c783          	lbu	a5,0(a5)
 d38:	00078713          	mv	a4,a5
 d3c:	07500793          	li	a5,117
 d40:	08f71063          	bne	a4,a5,dc0 <vprintfmt+0x60c>
 d44:	f8144783          	lbu	a5,-127(s0)
 d48:	00078c63          	beqz	a5,d60 <vprintfmt+0x5ac>
 d4c:	f4843783          	ld	a5,-184(s0)
 d50:	00878713          	addi	a4,a5,8
 d54:	f4e43423          	sd	a4,-184(s0)
 d58:	0007b783          	ld	a5,0(a5)
 d5c:	0140006f          	j	d70 <vprintfmt+0x5bc>
 d60:	f4843783          	ld	a5,-184(s0)
 d64:	00878713          	addi	a4,a5,8
 d68:	f4e43423          	sd	a4,-184(s0)
 d6c:	0007a783          	lw	a5,0(a5)
 d70:	faf43423          	sd	a5,-88(s0)
 d74:	fa843583          	ld	a1,-88(s0)
 d78:	f5043783          	ld	a5,-176(s0)
 d7c:	0007c783          	lbu	a5,0(a5)
 d80:	0007871b          	sext.w	a4,a5
 d84:	07500793          	li	a5,117
 d88:	40f707b3          	sub	a5,a4,a5
 d8c:	00f037b3          	snez	a5,a5
 d90:	0ff7f793          	zext.b	a5,a5
 d94:	f8040713          	addi	a4,s0,-128
 d98:	00070693          	mv	a3,a4
 d9c:	00078613          	mv	a2,a5
 da0:	f5843503          	ld	a0,-168(s0)
 da4:	f08ff0ef          	jal	4ac <print_dec_int>
 da8:	00050793          	mv	a5,a0
 dac:	fec42703          	lw	a4,-20(s0)
 db0:	00f707bb          	addw	a5,a4,a5
 db4:	fef42623          	sw	a5,-20(s0)
 db8:	f8040023          	sb	zero,-128(s0)
 dbc:	1b80006f          	j	f74 <vprintfmt+0x7c0>
 dc0:	f5043783          	ld	a5,-176(s0)
 dc4:	0007c783          	lbu	a5,0(a5)
 dc8:	00078713          	mv	a4,a5
 dcc:	06e00793          	li	a5,110
 dd0:	04f71c63          	bne	a4,a5,e28 <vprintfmt+0x674>
 dd4:	f8144783          	lbu	a5,-127(s0)
 dd8:	02078463          	beqz	a5,e00 <vprintfmt+0x64c>
 ddc:	f4843783          	ld	a5,-184(s0)
 de0:	00878713          	addi	a4,a5,8
 de4:	f4e43423          	sd	a4,-184(s0)
 de8:	0007b783          	ld	a5,0(a5)
 dec:	faf43823          	sd	a5,-80(s0)
 df0:	fec42703          	lw	a4,-20(s0)
 df4:	fb043783          	ld	a5,-80(s0)
 df8:	00e7b023          	sd	a4,0(a5)
 dfc:	0240006f          	j	e20 <vprintfmt+0x66c>
 e00:	f4843783          	ld	a5,-184(s0)
 e04:	00878713          	addi	a4,a5,8
 e08:	f4e43423          	sd	a4,-184(s0)
 e0c:	0007b783          	ld	a5,0(a5)
 e10:	faf43c23          	sd	a5,-72(s0)
 e14:	fb843783          	ld	a5,-72(s0)
 e18:	fec42703          	lw	a4,-20(s0)
 e1c:	00e7a023          	sw	a4,0(a5)
 e20:	f8040023          	sb	zero,-128(s0)
 e24:	1500006f          	j	f74 <vprintfmt+0x7c0>
 e28:	f5043783          	ld	a5,-176(s0)
 e2c:	0007c783          	lbu	a5,0(a5)
 e30:	00078713          	mv	a4,a5
 e34:	07300793          	li	a5,115
 e38:	02f71e63          	bne	a4,a5,e74 <vprintfmt+0x6c0>
 e3c:	f4843783          	ld	a5,-184(s0)
 e40:	00878713          	addi	a4,a5,8
 e44:	f4e43423          	sd	a4,-184(s0)
 e48:	0007b783          	ld	a5,0(a5)
 e4c:	fcf43023          	sd	a5,-64(s0)
 e50:	fc043583          	ld	a1,-64(s0)
 e54:	f5843503          	ld	a0,-168(s0)
 e58:	dccff0ef          	jal	424 <puts_wo_nl>
 e5c:	00050793          	mv	a5,a0
 e60:	fec42703          	lw	a4,-20(s0)
 e64:	00f707bb          	addw	a5,a4,a5
 e68:	fef42623          	sw	a5,-20(s0)
 e6c:	f8040023          	sb	zero,-128(s0)
 e70:	1040006f          	j	f74 <vprintfmt+0x7c0>
 e74:	f5043783          	ld	a5,-176(s0)
 e78:	0007c783          	lbu	a5,0(a5)
 e7c:	00078713          	mv	a4,a5
 e80:	06300793          	li	a5,99
 e84:	02f71e63          	bne	a4,a5,ec0 <vprintfmt+0x70c>
 e88:	f4843783          	ld	a5,-184(s0)
 e8c:	00878713          	addi	a4,a5,8
 e90:	f4e43423          	sd	a4,-184(s0)
 e94:	0007a783          	lw	a5,0(a5)
 e98:	fcf42623          	sw	a5,-52(s0)
 e9c:	fcc42703          	lw	a4,-52(s0)
 ea0:	f5843783          	ld	a5,-168(s0)
 ea4:	00070513          	mv	a0,a4
 ea8:	000780e7          	jalr	a5
 eac:	fec42783          	lw	a5,-20(s0)
 eb0:	0017879b          	addiw	a5,a5,1
 eb4:	fef42623          	sw	a5,-20(s0)
 eb8:	f8040023          	sb	zero,-128(s0)
 ebc:	0b80006f          	j	f74 <vprintfmt+0x7c0>
 ec0:	f5043783          	ld	a5,-176(s0)
 ec4:	0007c783          	lbu	a5,0(a5)
 ec8:	00078713          	mv	a4,a5
 ecc:	02500793          	li	a5,37
 ed0:	02f71263          	bne	a4,a5,ef4 <vprintfmt+0x740>
 ed4:	f5843783          	ld	a5,-168(s0)
 ed8:	02500513          	li	a0,37
 edc:	000780e7          	jalr	a5
 ee0:	fec42783          	lw	a5,-20(s0)
 ee4:	0017879b          	addiw	a5,a5,1
 ee8:	fef42623          	sw	a5,-20(s0)
 eec:	f8040023          	sb	zero,-128(s0)
 ef0:	0840006f          	j	f74 <vprintfmt+0x7c0>
 ef4:	f5043783          	ld	a5,-176(s0)
 ef8:	0007c783          	lbu	a5,0(a5)
 efc:	0007871b          	sext.w	a4,a5
 f00:	f5843783          	ld	a5,-168(s0)
 f04:	00070513          	mv	a0,a4
 f08:	000780e7          	jalr	a5
 f0c:	fec42783          	lw	a5,-20(s0)
 f10:	0017879b          	addiw	a5,a5,1
 f14:	fef42623          	sw	a5,-20(s0)
 f18:	f8040023          	sb	zero,-128(s0)
 f1c:	0580006f          	j	f74 <vprintfmt+0x7c0>
 f20:	f5043783          	ld	a5,-176(s0)
 f24:	0007c783          	lbu	a5,0(a5)
 f28:	00078713          	mv	a4,a5
 f2c:	02500793          	li	a5,37
 f30:	02f71063          	bne	a4,a5,f50 <vprintfmt+0x79c>
 f34:	f8043023          	sd	zero,-128(s0)
 f38:	f8043423          	sd	zero,-120(s0)
 f3c:	00100793          	li	a5,1
 f40:	f8f40023          	sb	a5,-128(s0)
 f44:	fff00793          	li	a5,-1
 f48:	f8f42623          	sw	a5,-116(s0)
 f4c:	0280006f          	j	f74 <vprintfmt+0x7c0>
 f50:	f5043783          	ld	a5,-176(s0)
 f54:	0007c783          	lbu	a5,0(a5)
 f58:	0007871b          	sext.w	a4,a5
 f5c:	f5843783          	ld	a5,-168(s0)
 f60:	00070513          	mv	a0,a4
 f64:	000780e7          	jalr	a5
 f68:	fec42783          	lw	a5,-20(s0)
 f6c:	0017879b          	addiw	a5,a5,1
 f70:	fef42623          	sw	a5,-20(s0)
 f74:	f5043783          	ld	a5,-176(s0)
 f78:	00178793          	addi	a5,a5,1
 f7c:	f4f43823          	sd	a5,-176(s0)
 f80:	f5043783          	ld	a5,-176(s0)
 f84:	0007c783          	lbu	a5,0(a5)
 f88:	84079ce3          	bnez	a5,7e0 <vprintfmt+0x2c>
 f8c:	fec42783          	lw	a5,-20(s0)
 f90:	00078513          	mv	a0,a5
 f94:	0b813083          	ld	ra,184(sp)
 f98:	0b013403          	ld	s0,176(sp)
 f9c:	0c010113          	addi	sp,sp,192
 fa0:	00008067          	ret

Disassembly of section .text.printf:

0000000000000fa4 <printf>:
     fa4:	f8010113          	addi	sp,sp,-128
     fa8:	02113c23          	sd	ra,56(sp)
     fac:	02813823          	sd	s0,48(sp)
     fb0:	04010413          	addi	s0,sp,64
     fb4:	fca43423          	sd	a0,-56(s0)
     fb8:	00b43423          	sd	a1,8(s0)
     fbc:	00c43823          	sd	a2,16(s0)
     fc0:	00d43c23          	sd	a3,24(s0)
     fc4:	02e43023          	sd	a4,32(s0)
     fc8:	02f43423          	sd	a5,40(s0)
     fcc:	03043823          	sd	a6,48(s0)
     fd0:	03143c23          	sd	a7,56(s0)
     fd4:	fe042623          	sw	zero,-20(s0)
     fd8:	04040793          	addi	a5,s0,64
     fdc:	fcf43023          	sd	a5,-64(s0)
     fe0:	fc043783          	ld	a5,-64(s0)
     fe4:	fc878793          	addi	a5,a5,-56
     fe8:	fcf43823          	sd	a5,-48(s0)
     fec:	fd043783          	ld	a5,-48(s0)
     ff0:	00078613          	mv	a2,a5
     ff4:	fc843583          	ld	a1,-56(s0)
     ff8:	fffff517          	auipc	a0,0xfffff
     ffc:	0f850513          	addi	a0,a0,248 # f0 <putc>
    1000:	fb4ff0ef          	jal	7b4 <vprintfmt>
    1004:	00050793          	mv	a5,a0
    1008:	fef42623          	sw	a5,-20(s0)
    100c:	00100793          	li	a5,1
    1010:	fef43023          	sd	a5,-32(s0)
    1014:	00001797          	auipc	a5,0x1
    1018:	2bc78793          	addi	a5,a5,700 # 22d0 <tail>
    101c:	0007a783          	lw	a5,0(a5)
    1020:	0017871b          	addiw	a4,a5,1
    1024:	0007069b          	sext.w	a3,a4
    1028:	00001717          	auipc	a4,0x1
    102c:	2a870713          	addi	a4,a4,680 # 22d0 <tail>
    1030:	00d72023          	sw	a3,0(a4)
    1034:	00001717          	auipc	a4,0x1
    1038:	2a470713          	addi	a4,a4,676 # 22d8 <buffer>
    103c:	00f707b3          	add	a5,a4,a5
    1040:	00078023          	sb	zero,0(a5)
    1044:	00001797          	auipc	a5,0x1
    1048:	28c78793          	addi	a5,a5,652 # 22d0 <tail>
    104c:	0007a603          	lw	a2,0(a5)
    1050:	fe043703          	ld	a4,-32(s0)
    1054:	00001697          	auipc	a3,0x1
    1058:	28468693          	addi	a3,a3,644 # 22d8 <buffer>
    105c:	fd843783          	ld	a5,-40(s0)
    1060:	04000893          	li	a7,64
    1064:	00070513          	mv	a0,a4
    1068:	00068593          	mv	a1,a3
    106c:	00060613          	mv	a2,a2
    1070:	00000073          	ecall
    1074:	00050793          	mv	a5,a0
    1078:	fcf43c23          	sd	a5,-40(s0)
    107c:	00001797          	auipc	a5,0x1
    1080:	25478793          	addi	a5,a5,596 # 22d0 <tail>
    1084:	0007a023          	sw	zero,0(a5)
    1088:	fec42783          	lw	a5,-20(s0)
    108c:	00078513          	mv	a0,a5
    1090:	03813083          	ld	ra,56(sp)
    1094:	03013403          	ld	s0,48(sp)
    1098:	08010113          	addi	sp,sp,128
    109c:	00008067          	ret
