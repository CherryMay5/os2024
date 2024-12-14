
uapp.elf:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000000000000 <_start>:
   0:	0c00006f          	j	c0 <main>

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

Disassembly of section .text.fork:

0000000000000038 <fork>:
  38:	fe010113          	addi	sp,sp,-32
  3c:	00813c23          	sd	s0,24(sp)
  40:	02010413          	addi	s0,sp,32
  44:	fe843783          	ld	a5,-24(s0)
  48:	0dc00893          	li	a7,220
  4c:	00000073          	ecall
  50:	00050793          	mv	a5,a0
  54:	fef43423          	sd	a5,-24(s0)
  58:	fe843783          	ld	a5,-24(s0)
  5c:	00078513          	mv	a0,a5
  60:	01813403          	ld	s0,24(sp)
  64:	02010113          	addi	sp,sp,32
  68:	00008067          	ret

Disassembly of section .text.wait:

000000000000006c <wait>:
  6c:	fd010113          	addi	sp,sp,-48
  70:	02813423          	sd	s0,40(sp)
  74:	03010413          	addi	s0,sp,48
  78:	00050793          	mv	a5,a0
  7c:	fcf42e23          	sw	a5,-36(s0)
  80:	fe042623          	sw	zero,-20(s0)
  84:	0100006f          	j	94 <wait+0x28>
  88:	fec42783          	lw	a5,-20(s0)
  8c:	0017879b          	addiw	a5,a5,1
  90:	fef42623          	sw	a5,-20(s0)
  94:	fec42783          	lw	a5,-20(s0)
  98:	00078713          	mv	a4,a5
  9c:	fdc42783          	lw	a5,-36(s0)
  a0:	0007071b          	sext.w	a4,a4
  a4:	0007879b          	sext.w	a5,a5
  a8:	fef760e3          	bltu	a4,a5,88 <wait+0x1c>
  ac:	00000013          	nop
  b0:	00000013          	nop
  b4:	02813403          	ld	s0,40(sp)
  b8:	03010113          	addi	sp,sp,48
  bc:	00008067          	ret

Disassembly of section .text.main:

00000000000000c0 <main>:
  c0:	fe010113          	addi	sp,sp,-32
  c4:	00113c23          	sd	ra,24(sp)
  c8:	00813823          	sd	s0,16(sp)
  cc:	02010413          	addi	s0,sp,32
  d0:	00001517          	auipc	a0,0x1
  d4:	3e850513          	addi	a0,a0,1000 # 14b8 <printf+0x2c0>
  d8:	120010ef          	jal	11f8 <printf>
  dc:	fe042623          	sw	zero,-20(s0)
  e0:	0480006f          	j	128 <main+0x68>
  e4:	f21ff0ef          	jal	4 <getpid>
  e8:	00050593          	mv	a1,a0
  ec:	00001797          	auipc	a5,0x1
  f0:	52078793          	addi	a5,a5,1312 # 160c <global_variable>
  f4:	0007a783          	lw	a5,0(a5)
  f8:	0017871b          	addiw	a4,a5,1
  fc:	0007069b          	sext.w	a3,a4
 100:	00001717          	auipc	a4,0x1
 104:	50c70713          	addi	a4,a4,1292 # 160c <global_variable>
 108:	00d72023          	sw	a3,0(a4)
 10c:	00078613          	mv	a2,a5
 110:	00001517          	auipc	a0,0x1
 114:	3b050513          	addi	a0,a0,944 # 14c0 <printf+0x2c8>
 118:	0e0010ef          	jal	11f8 <printf>
 11c:	fec42783          	lw	a5,-20(s0)
 120:	0017879b          	addiw	a5,a5,1
 124:	fef42623          	sw	a5,-20(s0)
 128:	fec42783          	lw	a5,-20(s0)
 12c:	0007871b          	sext.w	a4,a5
 130:	00200793          	li	a5,2
 134:	fae7d8e3          	bge	a5,a4,e4 <main+0x24>
 138:	00001717          	auipc	a4,0x1
 13c:	4d870713          	addi	a4,a4,1240 # 1610 <placeholder>
 140:	000017b7          	lui	a5,0x1
 144:	00f707b3          	add	a5,a4,a5
 148:	05a00713          	li	a4,90
 14c:	00e78023          	sb	a4,0(a5) # 1000 <vprintfmt+0x5f8>
 150:	00001717          	auipc	a4,0x1
 154:	4c070713          	addi	a4,a4,1216 # 1610 <placeholder>
 158:	000017b7          	lui	a5,0x1
 15c:	00f707b3          	add	a5,a4,a5
 160:	04a00713          	li	a4,74
 164:	00e780a3          	sb	a4,1(a5) # 1001 <vprintfmt+0x5f9>
 168:	00001717          	auipc	a4,0x1
 16c:	4a870713          	addi	a4,a4,1192 # 1610 <placeholder>
 170:	000017b7          	lui	a5,0x1
 174:	00f707b3          	add	a5,a4,a5
 178:	05500713          	li	a4,85
 17c:	00e78123          	sb	a4,2(a5) # 1002 <vprintfmt+0x5fa>
 180:	00001717          	auipc	a4,0x1
 184:	49070713          	addi	a4,a4,1168 # 1610 <placeholder>
 188:	000017b7          	lui	a5,0x1
 18c:	00f707b3          	add	a5,a4,a5
 190:	02000713          	li	a4,32
 194:	00e781a3          	sb	a4,3(a5) # 1003 <vprintfmt+0x5fb>
 198:	00001717          	auipc	a4,0x1
 19c:	47870713          	addi	a4,a4,1144 # 1610 <placeholder>
 1a0:	000017b7          	lui	a5,0x1
 1a4:	00f707b3          	add	a5,a4,a5
 1a8:	04f00713          	li	a4,79
 1ac:	00e78223          	sb	a4,4(a5) # 1004 <vprintfmt+0x5fc>
 1b0:	00001717          	auipc	a4,0x1
 1b4:	46070713          	addi	a4,a4,1120 # 1610 <placeholder>
 1b8:	000017b7          	lui	a5,0x1
 1bc:	00f707b3          	add	a5,a4,a5
 1c0:	05300713          	li	a4,83
 1c4:	00e782a3          	sb	a4,5(a5) # 1005 <vprintfmt+0x5fd>
 1c8:	00001717          	auipc	a4,0x1
 1cc:	44870713          	addi	a4,a4,1096 # 1610 <placeholder>
 1d0:	000017b7          	lui	a5,0x1
 1d4:	00f707b3          	add	a5,a4,a5
 1d8:	02000713          	li	a4,32
 1dc:	00e78323          	sb	a4,6(a5) # 1006 <vprintfmt+0x5fe>
 1e0:	00001717          	auipc	a4,0x1
 1e4:	43070713          	addi	a4,a4,1072 # 1610 <placeholder>
 1e8:	000017b7          	lui	a5,0x1
 1ec:	00f707b3          	add	a5,a4,a5
 1f0:	04c00713          	li	a4,76
 1f4:	00e783a3          	sb	a4,7(a5) # 1007 <vprintfmt+0x5ff>
 1f8:	00001717          	auipc	a4,0x1
 1fc:	41870713          	addi	a4,a4,1048 # 1610 <placeholder>
 200:	000017b7          	lui	a5,0x1
 204:	00f707b3          	add	a5,a4,a5
 208:	06100713          	li	a4,97
 20c:	00e78423          	sb	a4,8(a5) # 1008 <vprintfmt+0x600>
 210:	00001717          	auipc	a4,0x1
 214:	40070713          	addi	a4,a4,1024 # 1610 <placeholder>
 218:	000017b7          	lui	a5,0x1
 21c:	00f707b3          	add	a5,a4,a5
 220:	06200713          	li	a4,98
 224:	00e784a3          	sb	a4,9(a5) # 1009 <vprintfmt+0x601>
 228:	00001717          	auipc	a4,0x1
 22c:	3e870713          	addi	a4,a4,1000 # 1610 <placeholder>
 230:	000017b7          	lui	a5,0x1
 234:	00f707b3          	add	a5,a4,a5
 238:	03500713          	li	a4,53
 23c:	00e78523          	sb	a4,10(a5) # 100a <vprintfmt+0x602>
 240:	00001717          	auipc	a4,0x1
 244:	3d070713          	addi	a4,a4,976 # 1610 <placeholder>
 248:	000017b7          	lui	a5,0x1
 24c:	00f707b3          	add	a5,a4,a5
 250:	000785a3          	sb	zero,11(a5) # 100b <vprintfmt+0x603>
 254:	de5ff0ef          	jal	38 <fork>
 258:	00050793          	mv	a5,a0
 25c:	fef42423          	sw	a5,-24(s0)
 260:	fe842783          	lw	a5,-24(s0)
 264:	0007879b          	sext.w	a5,a5
 268:	06079863          	bnez	a5,2d8 <main+0x218>
 26c:	d99ff0ef          	jal	4 <getpid>
 270:	00050793          	mv	a5,a0
 274:	00002617          	auipc	a2,0x2
 278:	39c60613          	addi	a2,a2,924 # 2610 <placeholder+0x1000>
 27c:	00078593          	mv	a1,a5
 280:	00001517          	auipc	a0,0x1
 284:	27050513          	addi	a0,a0,624 # 14f0 <printf+0x2f8>
 288:	771000ef          	jal	11f8 <printf>
 28c:	d79ff0ef          	jal	4 <getpid>
 290:	00050593          	mv	a1,a0
 294:	00001797          	auipc	a5,0x1
 298:	37878793          	addi	a5,a5,888 # 160c <global_variable>
 29c:	0007a783          	lw	a5,0(a5)
 2a0:	0017871b          	addiw	a4,a5,1
 2a4:	0007069b          	sext.w	a3,a4
 2a8:	00001717          	auipc	a4,0x1
 2ac:	36470713          	addi	a4,a4,868 # 160c <global_variable>
 2b0:	00d72023          	sw	a3,0(a4)
 2b4:	00078613          	mv	a2,a5
 2b8:	00001517          	auipc	a0,0x1
 2bc:	26850513          	addi	a0,a0,616 # 1520 <printf+0x328>
 2c0:	739000ef          	jal	11f8 <printf>
 2c4:	500007b7          	lui	a5,0x50000
 2c8:	fff78513          	addi	a0,a5,-1 # 4fffffff <buffer+0x4fffc9e7>
 2cc:	da1ff0ef          	jal	6c <wait>
 2d0:	00000013          	nop
 2d4:	fb9ff06f          	j	28c <main+0x1cc>
 2d8:	d2dff0ef          	jal	4 <getpid>
 2dc:	00050793          	mv	a5,a0
 2e0:	00002617          	auipc	a2,0x2
 2e4:	33060613          	addi	a2,a2,816 # 2610 <placeholder+0x1000>
 2e8:	00078593          	mv	a1,a5
 2ec:	00001517          	auipc	a0,0x1
 2f0:	26c50513          	addi	a0,a0,620 # 1558 <printf+0x360>
 2f4:	705000ef          	jal	11f8 <printf>
 2f8:	d0dff0ef          	jal	4 <getpid>
 2fc:	00050593          	mv	a1,a0
 300:	00001797          	auipc	a5,0x1
 304:	30c78793          	addi	a5,a5,780 # 160c <global_variable>
 308:	0007a783          	lw	a5,0(a5)
 30c:	0017871b          	addiw	a4,a5,1
 310:	0007069b          	sext.w	a3,a4
 314:	00001717          	auipc	a4,0x1
 318:	2f870713          	addi	a4,a4,760 # 160c <global_variable>
 31c:	00d72023          	sw	a3,0(a4)
 320:	00078613          	mv	a2,a5
 324:	00001517          	auipc	a0,0x1
 328:	26450513          	addi	a0,a0,612 # 1588 <printf+0x390>
 32c:	6cd000ef          	jal	11f8 <printf>
 330:	500007b7          	lui	a5,0x50000
 334:	fff78513          	addi	a0,a5,-1 # 4fffffff <buffer+0x4fffc9e7>
 338:	d35ff0ef          	jal	6c <wait>
 33c:	00000013          	nop
 340:	fb9ff06f          	j	2f8 <main+0x238>

Disassembly of section .text.putc:

0000000000000344 <putc>:
 344:	fe010113          	addi	sp,sp,-32
 348:	00813c23          	sd	s0,24(sp)
 34c:	02010413          	addi	s0,sp,32
 350:	00050793          	mv	a5,a0
 354:	fef42623          	sw	a5,-20(s0)
 358:	00003797          	auipc	a5,0x3
 35c:	2b878793          	addi	a5,a5,696 # 3610 <tail>
 360:	0007a783          	lw	a5,0(a5)
 364:	0017871b          	addiw	a4,a5,1
 368:	0007069b          	sext.w	a3,a4
 36c:	00003717          	auipc	a4,0x3
 370:	2a470713          	addi	a4,a4,676 # 3610 <tail>
 374:	00d72023          	sw	a3,0(a4)
 378:	fec42703          	lw	a4,-20(s0)
 37c:	0ff77713          	zext.b	a4,a4
 380:	00003697          	auipc	a3,0x3
 384:	29868693          	addi	a3,a3,664 # 3618 <buffer>
 388:	00f687b3          	add	a5,a3,a5
 38c:	00e78023          	sb	a4,0(a5)
 390:	fec42783          	lw	a5,-20(s0)
 394:	0ff7f793          	zext.b	a5,a5
 398:	0007879b          	sext.w	a5,a5
 39c:	00078513          	mv	a0,a5
 3a0:	01813403          	ld	s0,24(sp)
 3a4:	02010113          	addi	sp,sp,32
 3a8:	00008067          	ret

Disassembly of section .text.isspace:

00000000000003ac <isspace>:
 3ac:	fe010113          	addi	sp,sp,-32
 3b0:	00813c23          	sd	s0,24(sp)
 3b4:	02010413          	addi	s0,sp,32
 3b8:	00050793          	mv	a5,a0
 3bc:	fef42623          	sw	a5,-20(s0)
 3c0:	fec42783          	lw	a5,-20(s0)
 3c4:	0007871b          	sext.w	a4,a5
 3c8:	02000793          	li	a5,32
 3cc:	02f70263          	beq	a4,a5,3f0 <isspace+0x44>
 3d0:	fec42783          	lw	a5,-20(s0)
 3d4:	0007871b          	sext.w	a4,a5
 3d8:	00800793          	li	a5,8
 3dc:	00e7de63          	bge	a5,a4,3f8 <isspace+0x4c>
 3e0:	fec42783          	lw	a5,-20(s0)
 3e4:	0007871b          	sext.w	a4,a5
 3e8:	00d00793          	li	a5,13
 3ec:	00e7c663          	blt	a5,a4,3f8 <isspace+0x4c>
 3f0:	00100793          	li	a5,1
 3f4:	0080006f          	j	3fc <isspace+0x50>
 3f8:	00000793          	li	a5,0
 3fc:	00078513          	mv	a0,a5
 400:	01813403          	ld	s0,24(sp)
 404:	02010113          	addi	sp,sp,32
 408:	00008067          	ret

Disassembly of section .text.strtol:

000000000000040c <strtol>:
 40c:	fb010113          	addi	sp,sp,-80
 410:	04113423          	sd	ra,72(sp)
 414:	04813023          	sd	s0,64(sp)
 418:	05010413          	addi	s0,sp,80
 41c:	fca43423          	sd	a0,-56(s0)
 420:	fcb43023          	sd	a1,-64(s0)
 424:	00060793          	mv	a5,a2
 428:	faf42e23          	sw	a5,-68(s0)
 42c:	fe043423          	sd	zero,-24(s0)
 430:	fe0403a3          	sb	zero,-25(s0)
 434:	fc843783          	ld	a5,-56(s0)
 438:	fcf43c23          	sd	a5,-40(s0)
 43c:	0100006f          	j	44c <strtol+0x40>
 440:	fd843783          	ld	a5,-40(s0)
 444:	00178793          	addi	a5,a5,1
 448:	fcf43c23          	sd	a5,-40(s0)
 44c:	fd843783          	ld	a5,-40(s0)
 450:	0007c783          	lbu	a5,0(a5)
 454:	0007879b          	sext.w	a5,a5
 458:	00078513          	mv	a0,a5
 45c:	f51ff0ef          	jal	3ac <isspace>
 460:	00050793          	mv	a5,a0
 464:	fc079ee3          	bnez	a5,440 <strtol+0x34>
 468:	fd843783          	ld	a5,-40(s0)
 46c:	0007c783          	lbu	a5,0(a5)
 470:	00078713          	mv	a4,a5
 474:	02d00793          	li	a5,45
 478:	00f71e63          	bne	a4,a5,494 <strtol+0x88>
 47c:	00100793          	li	a5,1
 480:	fef403a3          	sb	a5,-25(s0)
 484:	fd843783          	ld	a5,-40(s0)
 488:	00178793          	addi	a5,a5,1
 48c:	fcf43c23          	sd	a5,-40(s0)
 490:	0240006f          	j	4b4 <strtol+0xa8>
 494:	fd843783          	ld	a5,-40(s0)
 498:	0007c783          	lbu	a5,0(a5)
 49c:	00078713          	mv	a4,a5
 4a0:	02b00793          	li	a5,43
 4a4:	00f71863          	bne	a4,a5,4b4 <strtol+0xa8>
 4a8:	fd843783          	ld	a5,-40(s0)
 4ac:	00178793          	addi	a5,a5,1
 4b0:	fcf43c23          	sd	a5,-40(s0)
 4b4:	fbc42783          	lw	a5,-68(s0)
 4b8:	0007879b          	sext.w	a5,a5
 4bc:	06079c63          	bnez	a5,534 <strtol+0x128>
 4c0:	fd843783          	ld	a5,-40(s0)
 4c4:	0007c783          	lbu	a5,0(a5)
 4c8:	00078713          	mv	a4,a5
 4cc:	03000793          	li	a5,48
 4d0:	04f71e63          	bne	a4,a5,52c <strtol+0x120>
 4d4:	fd843783          	ld	a5,-40(s0)
 4d8:	00178793          	addi	a5,a5,1
 4dc:	fcf43c23          	sd	a5,-40(s0)
 4e0:	fd843783          	ld	a5,-40(s0)
 4e4:	0007c783          	lbu	a5,0(a5)
 4e8:	00078713          	mv	a4,a5
 4ec:	07800793          	li	a5,120
 4f0:	00f70c63          	beq	a4,a5,508 <strtol+0xfc>
 4f4:	fd843783          	ld	a5,-40(s0)
 4f8:	0007c783          	lbu	a5,0(a5)
 4fc:	00078713          	mv	a4,a5
 500:	05800793          	li	a5,88
 504:	00f71e63          	bne	a4,a5,520 <strtol+0x114>
 508:	01000793          	li	a5,16
 50c:	faf42e23          	sw	a5,-68(s0)
 510:	fd843783          	ld	a5,-40(s0)
 514:	00178793          	addi	a5,a5,1
 518:	fcf43c23          	sd	a5,-40(s0)
 51c:	0180006f          	j	534 <strtol+0x128>
 520:	00800793          	li	a5,8
 524:	faf42e23          	sw	a5,-68(s0)
 528:	00c0006f          	j	534 <strtol+0x128>
 52c:	00a00793          	li	a5,10
 530:	faf42e23          	sw	a5,-68(s0)
 534:	fd843783          	ld	a5,-40(s0)
 538:	0007c783          	lbu	a5,0(a5)
 53c:	00078713          	mv	a4,a5
 540:	02f00793          	li	a5,47
 544:	02e7f863          	bgeu	a5,a4,574 <strtol+0x168>
 548:	fd843783          	ld	a5,-40(s0)
 54c:	0007c783          	lbu	a5,0(a5)
 550:	00078713          	mv	a4,a5
 554:	03900793          	li	a5,57
 558:	00e7ee63          	bltu	a5,a4,574 <strtol+0x168>
 55c:	fd843783          	ld	a5,-40(s0)
 560:	0007c783          	lbu	a5,0(a5)
 564:	0007879b          	sext.w	a5,a5
 568:	fd07879b          	addiw	a5,a5,-48
 56c:	fcf42a23          	sw	a5,-44(s0)
 570:	0800006f          	j	5f0 <strtol+0x1e4>
 574:	fd843783          	ld	a5,-40(s0)
 578:	0007c783          	lbu	a5,0(a5)
 57c:	00078713          	mv	a4,a5
 580:	06000793          	li	a5,96
 584:	02e7f863          	bgeu	a5,a4,5b4 <strtol+0x1a8>
 588:	fd843783          	ld	a5,-40(s0)
 58c:	0007c783          	lbu	a5,0(a5)
 590:	00078713          	mv	a4,a5
 594:	07a00793          	li	a5,122
 598:	00e7ee63          	bltu	a5,a4,5b4 <strtol+0x1a8>
 59c:	fd843783          	ld	a5,-40(s0)
 5a0:	0007c783          	lbu	a5,0(a5)
 5a4:	0007879b          	sext.w	a5,a5
 5a8:	fa97879b          	addiw	a5,a5,-87
 5ac:	fcf42a23          	sw	a5,-44(s0)
 5b0:	0400006f          	j	5f0 <strtol+0x1e4>
 5b4:	fd843783          	ld	a5,-40(s0)
 5b8:	0007c783          	lbu	a5,0(a5)
 5bc:	00078713          	mv	a4,a5
 5c0:	04000793          	li	a5,64
 5c4:	06e7f863          	bgeu	a5,a4,634 <strtol+0x228>
 5c8:	fd843783          	ld	a5,-40(s0)
 5cc:	0007c783          	lbu	a5,0(a5)
 5d0:	00078713          	mv	a4,a5
 5d4:	05a00793          	li	a5,90
 5d8:	04e7ee63          	bltu	a5,a4,634 <strtol+0x228>
 5dc:	fd843783          	ld	a5,-40(s0)
 5e0:	0007c783          	lbu	a5,0(a5)
 5e4:	0007879b          	sext.w	a5,a5
 5e8:	fc97879b          	addiw	a5,a5,-55
 5ec:	fcf42a23          	sw	a5,-44(s0)
 5f0:	fd442783          	lw	a5,-44(s0)
 5f4:	00078713          	mv	a4,a5
 5f8:	fbc42783          	lw	a5,-68(s0)
 5fc:	0007071b          	sext.w	a4,a4
 600:	0007879b          	sext.w	a5,a5
 604:	02f75663          	bge	a4,a5,630 <strtol+0x224>
 608:	fbc42703          	lw	a4,-68(s0)
 60c:	fe843783          	ld	a5,-24(s0)
 610:	02f70733          	mul	a4,a4,a5
 614:	fd442783          	lw	a5,-44(s0)
 618:	00f707b3          	add	a5,a4,a5
 61c:	fef43423          	sd	a5,-24(s0)
 620:	fd843783          	ld	a5,-40(s0)
 624:	00178793          	addi	a5,a5,1
 628:	fcf43c23          	sd	a5,-40(s0)
 62c:	f09ff06f          	j	534 <strtol+0x128>
 630:	00000013          	nop
 634:	fc043783          	ld	a5,-64(s0)
 638:	00078863          	beqz	a5,648 <strtol+0x23c>
 63c:	fc043783          	ld	a5,-64(s0)
 640:	fd843703          	ld	a4,-40(s0)
 644:	00e7b023          	sd	a4,0(a5)
 648:	fe744783          	lbu	a5,-25(s0)
 64c:	0ff7f793          	zext.b	a5,a5
 650:	00078863          	beqz	a5,660 <strtol+0x254>
 654:	fe843783          	ld	a5,-24(s0)
 658:	40f007b3          	neg	a5,a5
 65c:	0080006f          	j	664 <strtol+0x258>
 660:	fe843783          	ld	a5,-24(s0)
 664:	00078513          	mv	a0,a5
 668:	04813083          	ld	ra,72(sp)
 66c:	04013403          	ld	s0,64(sp)
 670:	05010113          	addi	sp,sp,80
 674:	00008067          	ret

Disassembly of section .text.puts_wo_nl:

0000000000000678 <puts_wo_nl>:
 678:	fd010113          	addi	sp,sp,-48
 67c:	02113423          	sd	ra,40(sp)
 680:	02813023          	sd	s0,32(sp)
 684:	03010413          	addi	s0,sp,48
 688:	fca43c23          	sd	a0,-40(s0)
 68c:	fcb43823          	sd	a1,-48(s0)
 690:	fd043783          	ld	a5,-48(s0)
 694:	00079863          	bnez	a5,6a4 <puts_wo_nl+0x2c>
 698:	00001797          	auipc	a5,0x1
 69c:	f2878793          	addi	a5,a5,-216 # 15c0 <printf+0x3c8>
 6a0:	fcf43823          	sd	a5,-48(s0)
 6a4:	fd043783          	ld	a5,-48(s0)
 6a8:	fef43423          	sd	a5,-24(s0)
 6ac:	0240006f          	j	6d0 <puts_wo_nl+0x58>
 6b0:	fe843783          	ld	a5,-24(s0)
 6b4:	00178713          	addi	a4,a5,1
 6b8:	fee43423          	sd	a4,-24(s0)
 6bc:	0007c783          	lbu	a5,0(a5)
 6c0:	0007871b          	sext.w	a4,a5
 6c4:	fd843783          	ld	a5,-40(s0)
 6c8:	00070513          	mv	a0,a4
 6cc:	000780e7          	jalr	a5
 6d0:	fe843783          	ld	a5,-24(s0)
 6d4:	0007c783          	lbu	a5,0(a5)
 6d8:	fc079ce3          	bnez	a5,6b0 <puts_wo_nl+0x38>
 6dc:	fe843703          	ld	a4,-24(s0)
 6e0:	fd043783          	ld	a5,-48(s0)
 6e4:	40f707b3          	sub	a5,a4,a5
 6e8:	0007879b          	sext.w	a5,a5
 6ec:	00078513          	mv	a0,a5
 6f0:	02813083          	ld	ra,40(sp)
 6f4:	02013403          	ld	s0,32(sp)
 6f8:	03010113          	addi	sp,sp,48
 6fc:	00008067          	ret

Disassembly of section .text.print_dec_int:

0000000000000700 <print_dec_int>:
 700:	f9010113          	addi	sp,sp,-112
 704:	06113423          	sd	ra,104(sp)
 708:	06813023          	sd	s0,96(sp)
 70c:	07010413          	addi	s0,sp,112
 710:	faa43423          	sd	a0,-88(s0)
 714:	fab43023          	sd	a1,-96(s0)
 718:	00060793          	mv	a5,a2
 71c:	f8d43823          	sd	a3,-112(s0)
 720:	f8f40fa3          	sb	a5,-97(s0)
 724:	f9f44783          	lbu	a5,-97(s0)
 728:	0ff7f793          	zext.b	a5,a5
 72c:	02078663          	beqz	a5,758 <print_dec_int+0x58>
 730:	fa043703          	ld	a4,-96(s0)
 734:	fff00793          	li	a5,-1
 738:	03f79793          	slli	a5,a5,0x3f
 73c:	00f71e63          	bne	a4,a5,758 <print_dec_int+0x58>
 740:	00001597          	auipc	a1,0x1
 744:	e8858593          	addi	a1,a1,-376 # 15c8 <printf+0x3d0>
 748:	fa843503          	ld	a0,-88(s0)
 74c:	f2dff0ef          	jal	678 <puts_wo_nl>
 750:	00050793          	mv	a5,a0
 754:	2a00006f          	j	9f4 <print_dec_int+0x2f4>
 758:	f9043783          	ld	a5,-112(s0)
 75c:	00c7a783          	lw	a5,12(a5)
 760:	00079a63          	bnez	a5,774 <print_dec_int+0x74>
 764:	fa043783          	ld	a5,-96(s0)
 768:	00079663          	bnez	a5,774 <print_dec_int+0x74>
 76c:	00000793          	li	a5,0
 770:	2840006f          	j	9f4 <print_dec_int+0x2f4>
 774:	fe0407a3          	sb	zero,-17(s0)
 778:	f9f44783          	lbu	a5,-97(s0)
 77c:	0ff7f793          	zext.b	a5,a5
 780:	02078063          	beqz	a5,7a0 <print_dec_int+0xa0>
 784:	fa043783          	ld	a5,-96(s0)
 788:	0007dc63          	bgez	a5,7a0 <print_dec_int+0xa0>
 78c:	00100793          	li	a5,1
 790:	fef407a3          	sb	a5,-17(s0)
 794:	fa043783          	ld	a5,-96(s0)
 798:	40f007b3          	neg	a5,a5
 79c:	faf43023          	sd	a5,-96(s0)
 7a0:	fe042423          	sw	zero,-24(s0)
 7a4:	f9f44783          	lbu	a5,-97(s0)
 7a8:	0ff7f793          	zext.b	a5,a5
 7ac:	02078863          	beqz	a5,7dc <print_dec_int+0xdc>
 7b0:	fef44783          	lbu	a5,-17(s0)
 7b4:	0ff7f793          	zext.b	a5,a5
 7b8:	00079e63          	bnez	a5,7d4 <print_dec_int+0xd4>
 7bc:	f9043783          	ld	a5,-112(s0)
 7c0:	0057c783          	lbu	a5,5(a5)
 7c4:	00079863          	bnez	a5,7d4 <print_dec_int+0xd4>
 7c8:	f9043783          	ld	a5,-112(s0)
 7cc:	0047c783          	lbu	a5,4(a5)
 7d0:	00078663          	beqz	a5,7dc <print_dec_int+0xdc>
 7d4:	00100793          	li	a5,1
 7d8:	0080006f          	j	7e0 <print_dec_int+0xe0>
 7dc:	00000793          	li	a5,0
 7e0:	fcf40ba3          	sb	a5,-41(s0)
 7e4:	fd744783          	lbu	a5,-41(s0)
 7e8:	0017f793          	andi	a5,a5,1
 7ec:	fcf40ba3          	sb	a5,-41(s0)
 7f0:	fa043703          	ld	a4,-96(s0)
 7f4:	00a00793          	li	a5,10
 7f8:	02f777b3          	remu	a5,a4,a5
 7fc:	0ff7f713          	zext.b	a4,a5
 800:	fe842783          	lw	a5,-24(s0)
 804:	0017869b          	addiw	a3,a5,1
 808:	fed42423          	sw	a3,-24(s0)
 80c:	0307071b          	addiw	a4,a4,48
 810:	0ff77713          	zext.b	a4,a4
 814:	ff078793          	addi	a5,a5,-16
 818:	008787b3          	add	a5,a5,s0
 81c:	fce78423          	sb	a4,-56(a5)
 820:	fa043703          	ld	a4,-96(s0)
 824:	00a00793          	li	a5,10
 828:	02f757b3          	divu	a5,a4,a5
 82c:	faf43023          	sd	a5,-96(s0)
 830:	fa043783          	ld	a5,-96(s0)
 834:	fa079ee3          	bnez	a5,7f0 <print_dec_int+0xf0>
 838:	f9043783          	ld	a5,-112(s0)
 83c:	00c7a783          	lw	a5,12(a5)
 840:	00078713          	mv	a4,a5
 844:	fff00793          	li	a5,-1
 848:	02f71063          	bne	a4,a5,868 <print_dec_int+0x168>
 84c:	f9043783          	ld	a5,-112(s0)
 850:	0037c783          	lbu	a5,3(a5)
 854:	00078a63          	beqz	a5,868 <print_dec_int+0x168>
 858:	f9043783          	ld	a5,-112(s0)
 85c:	0087a703          	lw	a4,8(a5)
 860:	f9043783          	ld	a5,-112(s0)
 864:	00e7a623          	sw	a4,12(a5)
 868:	fe042223          	sw	zero,-28(s0)
 86c:	f9043783          	ld	a5,-112(s0)
 870:	0087a703          	lw	a4,8(a5)
 874:	fe842783          	lw	a5,-24(s0)
 878:	fcf42823          	sw	a5,-48(s0)
 87c:	f9043783          	ld	a5,-112(s0)
 880:	00c7a783          	lw	a5,12(a5)
 884:	fcf42623          	sw	a5,-52(s0)
 888:	fd042783          	lw	a5,-48(s0)
 88c:	00078593          	mv	a1,a5
 890:	fcc42783          	lw	a5,-52(s0)
 894:	00078613          	mv	a2,a5
 898:	0006069b          	sext.w	a3,a2
 89c:	0005879b          	sext.w	a5,a1
 8a0:	00f6d463          	bge	a3,a5,8a8 <print_dec_int+0x1a8>
 8a4:	00058613          	mv	a2,a1
 8a8:	0006079b          	sext.w	a5,a2
 8ac:	40f707bb          	subw	a5,a4,a5
 8b0:	0007871b          	sext.w	a4,a5
 8b4:	fd744783          	lbu	a5,-41(s0)
 8b8:	0007879b          	sext.w	a5,a5
 8bc:	40f707bb          	subw	a5,a4,a5
 8c0:	fef42023          	sw	a5,-32(s0)
 8c4:	0280006f          	j	8ec <print_dec_int+0x1ec>
 8c8:	fa843783          	ld	a5,-88(s0)
 8cc:	02000513          	li	a0,32
 8d0:	000780e7          	jalr	a5
 8d4:	fe442783          	lw	a5,-28(s0)
 8d8:	0017879b          	addiw	a5,a5,1
 8dc:	fef42223          	sw	a5,-28(s0)
 8e0:	fe042783          	lw	a5,-32(s0)
 8e4:	fff7879b          	addiw	a5,a5,-1
 8e8:	fef42023          	sw	a5,-32(s0)
 8ec:	fe042783          	lw	a5,-32(s0)
 8f0:	0007879b          	sext.w	a5,a5
 8f4:	fcf04ae3          	bgtz	a5,8c8 <print_dec_int+0x1c8>
 8f8:	fd744783          	lbu	a5,-41(s0)
 8fc:	0ff7f793          	zext.b	a5,a5
 900:	04078463          	beqz	a5,948 <print_dec_int+0x248>
 904:	fef44783          	lbu	a5,-17(s0)
 908:	0ff7f793          	zext.b	a5,a5
 90c:	00078663          	beqz	a5,918 <print_dec_int+0x218>
 910:	02d00793          	li	a5,45
 914:	01c0006f          	j	930 <print_dec_int+0x230>
 918:	f9043783          	ld	a5,-112(s0)
 91c:	0057c783          	lbu	a5,5(a5)
 920:	00078663          	beqz	a5,92c <print_dec_int+0x22c>
 924:	02b00793          	li	a5,43
 928:	0080006f          	j	930 <print_dec_int+0x230>
 92c:	02000793          	li	a5,32
 930:	fa843703          	ld	a4,-88(s0)
 934:	00078513          	mv	a0,a5
 938:	000700e7          	jalr	a4
 93c:	fe442783          	lw	a5,-28(s0)
 940:	0017879b          	addiw	a5,a5,1
 944:	fef42223          	sw	a5,-28(s0)
 948:	fe842783          	lw	a5,-24(s0)
 94c:	fcf42e23          	sw	a5,-36(s0)
 950:	0280006f          	j	978 <print_dec_int+0x278>
 954:	fa843783          	ld	a5,-88(s0)
 958:	03000513          	li	a0,48
 95c:	000780e7          	jalr	a5
 960:	fe442783          	lw	a5,-28(s0)
 964:	0017879b          	addiw	a5,a5,1
 968:	fef42223          	sw	a5,-28(s0)
 96c:	fdc42783          	lw	a5,-36(s0)
 970:	0017879b          	addiw	a5,a5,1
 974:	fcf42e23          	sw	a5,-36(s0)
 978:	f9043783          	ld	a5,-112(s0)
 97c:	00c7a703          	lw	a4,12(a5)
 980:	fd744783          	lbu	a5,-41(s0)
 984:	0007879b          	sext.w	a5,a5
 988:	40f707bb          	subw	a5,a4,a5
 98c:	0007871b          	sext.w	a4,a5
 990:	fdc42783          	lw	a5,-36(s0)
 994:	0007879b          	sext.w	a5,a5
 998:	fae7cee3          	blt	a5,a4,954 <print_dec_int+0x254>
 99c:	fe842783          	lw	a5,-24(s0)
 9a0:	fff7879b          	addiw	a5,a5,-1
 9a4:	fcf42c23          	sw	a5,-40(s0)
 9a8:	03c0006f          	j	9e4 <print_dec_int+0x2e4>
 9ac:	fd842783          	lw	a5,-40(s0)
 9b0:	ff078793          	addi	a5,a5,-16
 9b4:	008787b3          	add	a5,a5,s0
 9b8:	fc87c783          	lbu	a5,-56(a5)
 9bc:	0007871b          	sext.w	a4,a5
 9c0:	fa843783          	ld	a5,-88(s0)
 9c4:	00070513          	mv	a0,a4
 9c8:	000780e7          	jalr	a5
 9cc:	fe442783          	lw	a5,-28(s0)
 9d0:	0017879b          	addiw	a5,a5,1
 9d4:	fef42223          	sw	a5,-28(s0)
 9d8:	fd842783          	lw	a5,-40(s0)
 9dc:	fff7879b          	addiw	a5,a5,-1
 9e0:	fcf42c23          	sw	a5,-40(s0)
 9e4:	fd842783          	lw	a5,-40(s0)
 9e8:	0007879b          	sext.w	a5,a5
 9ec:	fc07d0e3          	bgez	a5,9ac <print_dec_int+0x2ac>
 9f0:	fe442783          	lw	a5,-28(s0)
 9f4:	00078513          	mv	a0,a5
 9f8:	06813083          	ld	ra,104(sp)
 9fc:	06013403          	ld	s0,96(sp)
 a00:	07010113          	addi	sp,sp,112
 a04:	00008067          	ret

Disassembly of section .text.vprintfmt:

0000000000000a08 <vprintfmt>:
     a08:	f4010113          	addi	sp,sp,-192
     a0c:	0a113c23          	sd	ra,184(sp)
     a10:	0a813823          	sd	s0,176(sp)
     a14:	0c010413          	addi	s0,sp,192
     a18:	f4a43c23          	sd	a0,-168(s0)
     a1c:	f4b43823          	sd	a1,-176(s0)
     a20:	f4c43423          	sd	a2,-184(s0)
     a24:	f8043023          	sd	zero,-128(s0)
     a28:	f8043423          	sd	zero,-120(s0)
     a2c:	fe042623          	sw	zero,-20(s0)
     a30:	7a40006f          	j	11d4 <vprintfmt+0x7cc>
     a34:	f8044783          	lbu	a5,-128(s0)
     a38:	72078e63          	beqz	a5,1174 <vprintfmt+0x76c>
     a3c:	f5043783          	ld	a5,-176(s0)
     a40:	0007c783          	lbu	a5,0(a5)
     a44:	00078713          	mv	a4,a5
     a48:	02300793          	li	a5,35
     a4c:	00f71863          	bne	a4,a5,a5c <vprintfmt+0x54>
     a50:	00100793          	li	a5,1
     a54:	f8f40123          	sb	a5,-126(s0)
     a58:	7700006f          	j	11c8 <vprintfmt+0x7c0>
     a5c:	f5043783          	ld	a5,-176(s0)
     a60:	0007c783          	lbu	a5,0(a5)
     a64:	00078713          	mv	a4,a5
     a68:	03000793          	li	a5,48
     a6c:	00f71863          	bne	a4,a5,a7c <vprintfmt+0x74>
     a70:	00100793          	li	a5,1
     a74:	f8f401a3          	sb	a5,-125(s0)
     a78:	7500006f          	j	11c8 <vprintfmt+0x7c0>
     a7c:	f5043783          	ld	a5,-176(s0)
     a80:	0007c783          	lbu	a5,0(a5)
     a84:	00078713          	mv	a4,a5
     a88:	06c00793          	li	a5,108
     a8c:	04f70063          	beq	a4,a5,acc <vprintfmt+0xc4>
     a90:	f5043783          	ld	a5,-176(s0)
     a94:	0007c783          	lbu	a5,0(a5)
     a98:	00078713          	mv	a4,a5
     a9c:	07a00793          	li	a5,122
     aa0:	02f70663          	beq	a4,a5,acc <vprintfmt+0xc4>
     aa4:	f5043783          	ld	a5,-176(s0)
     aa8:	0007c783          	lbu	a5,0(a5)
     aac:	00078713          	mv	a4,a5
     ab0:	07400793          	li	a5,116
     ab4:	00f70c63          	beq	a4,a5,acc <vprintfmt+0xc4>
     ab8:	f5043783          	ld	a5,-176(s0)
     abc:	0007c783          	lbu	a5,0(a5)
     ac0:	00078713          	mv	a4,a5
     ac4:	06a00793          	li	a5,106
     ac8:	00f71863          	bne	a4,a5,ad8 <vprintfmt+0xd0>
     acc:	00100793          	li	a5,1
     ad0:	f8f400a3          	sb	a5,-127(s0)
     ad4:	6f40006f          	j	11c8 <vprintfmt+0x7c0>
     ad8:	f5043783          	ld	a5,-176(s0)
     adc:	0007c783          	lbu	a5,0(a5)
     ae0:	00078713          	mv	a4,a5
     ae4:	02b00793          	li	a5,43
     ae8:	00f71863          	bne	a4,a5,af8 <vprintfmt+0xf0>
     aec:	00100793          	li	a5,1
     af0:	f8f402a3          	sb	a5,-123(s0)
     af4:	6d40006f          	j	11c8 <vprintfmt+0x7c0>
     af8:	f5043783          	ld	a5,-176(s0)
     afc:	0007c783          	lbu	a5,0(a5)
     b00:	00078713          	mv	a4,a5
     b04:	02000793          	li	a5,32
     b08:	00f71863          	bne	a4,a5,b18 <vprintfmt+0x110>
     b0c:	00100793          	li	a5,1
     b10:	f8f40223          	sb	a5,-124(s0)
     b14:	6b40006f          	j	11c8 <vprintfmt+0x7c0>
     b18:	f5043783          	ld	a5,-176(s0)
     b1c:	0007c783          	lbu	a5,0(a5)
     b20:	00078713          	mv	a4,a5
     b24:	02a00793          	li	a5,42
     b28:	00f71e63          	bne	a4,a5,b44 <vprintfmt+0x13c>
     b2c:	f4843783          	ld	a5,-184(s0)
     b30:	00878713          	addi	a4,a5,8
     b34:	f4e43423          	sd	a4,-184(s0)
     b38:	0007a783          	lw	a5,0(a5)
     b3c:	f8f42423          	sw	a5,-120(s0)
     b40:	6880006f          	j	11c8 <vprintfmt+0x7c0>
     b44:	f5043783          	ld	a5,-176(s0)
     b48:	0007c783          	lbu	a5,0(a5)
     b4c:	00078713          	mv	a4,a5
     b50:	03000793          	li	a5,48
     b54:	04e7f663          	bgeu	a5,a4,ba0 <vprintfmt+0x198>
     b58:	f5043783          	ld	a5,-176(s0)
     b5c:	0007c783          	lbu	a5,0(a5)
     b60:	00078713          	mv	a4,a5
     b64:	03900793          	li	a5,57
     b68:	02e7ec63          	bltu	a5,a4,ba0 <vprintfmt+0x198>
     b6c:	f5043783          	ld	a5,-176(s0)
     b70:	f5040713          	addi	a4,s0,-176
     b74:	00a00613          	li	a2,10
     b78:	00070593          	mv	a1,a4
     b7c:	00078513          	mv	a0,a5
     b80:	88dff0ef          	jal	40c <strtol>
     b84:	00050793          	mv	a5,a0
     b88:	0007879b          	sext.w	a5,a5
     b8c:	f8f42423          	sw	a5,-120(s0)
     b90:	f5043783          	ld	a5,-176(s0)
     b94:	fff78793          	addi	a5,a5,-1
     b98:	f4f43823          	sd	a5,-176(s0)
     b9c:	62c0006f          	j	11c8 <vprintfmt+0x7c0>
     ba0:	f5043783          	ld	a5,-176(s0)
     ba4:	0007c783          	lbu	a5,0(a5)
     ba8:	00078713          	mv	a4,a5
     bac:	02e00793          	li	a5,46
     bb0:	06f71863          	bne	a4,a5,c20 <vprintfmt+0x218>
     bb4:	f5043783          	ld	a5,-176(s0)
     bb8:	00178793          	addi	a5,a5,1
     bbc:	f4f43823          	sd	a5,-176(s0)
     bc0:	f5043783          	ld	a5,-176(s0)
     bc4:	0007c783          	lbu	a5,0(a5)
     bc8:	00078713          	mv	a4,a5
     bcc:	02a00793          	li	a5,42
     bd0:	00f71e63          	bne	a4,a5,bec <vprintfmt+0x1e4>
     bd4:	f4843783          	ld	a5,-184(s0)
     bd8:	00878713          	addi	a4,a5,8
     bdc:	f4e43423          	sd	a4,-184(s0)
     be0:	0007a783          	lw	a5,0(a5)
     be4:	f8f42623          	sw	a5,-116(s0)
     be8:	5e00006f          	j	11c8 <vprintfmt+0x7c0>
     bec:	f5043783          	ld	a5,-176(s0)
     bf0:	f5040713          	addi	a4,s0,-176
     bf4:	00a00613          	li	a2,10
     bf8:	00070593          	mv	a1,a4
     bfc:	00078513          	mv	a0,a5
     c00:	80dff0ef          	jal	40c <strtol>
     c04:	00050793          	mv	a5,a0
     c08:	0007879b          	sext.w	a5,a5
     c0c:	f8f42623          	sw	a5,-116(s0)
     c10:	f5043783          	ld	a5,-176(s0)
     c14:	fff78793          	addi	a5,a5,-1
     c18:	f4f43823          	sd	a5,-176(s0)
     c1c:	5ac0006f          	j	11c8 <vprintfmt+0x7c0>
     c20:	f5043783          	ld	a5,-176(s0)
     c24:	0007c783          	lbu	a5,0(a5)
     c28:	00078713          	mv	a4,a5
     c2c:	07800793          	li	a5,120
     c30:	02f70663          	beq	a4,a5,c5c <vprintfmt+0x254>
     c34:	f5043783          	ld	a5,-176(s0)
     c38:	0007c783          	lbu	a5,0(a5)
     c3c:	00078713          	mv	a4,a5
     c40:	05800793          	li	a5,88
     c44:	00f70c63          	beq	a4,a5,c5c <vprintfmt+0x254>
     c48:	f5043783          	ld	a5,-176(s0)
     c4c:	0007c783          	lbu	a5,0(a5)
     c50:	00078713          	mv	a4,a5
     c54:	07000793          	li	a5,112
     c58:	30f71263          	bne	a4,a5,f5c <vprintfmt+0x554>
     c5c:	f5043783          	ld	a5,-176(s0)
     c60:	0007c783          	lbu	a5,0(a5)
     c64:	00078713          	mv	a4,a5
     c68:	07000793          	li	a5,112
     c6c:	00f70663          	beq	a4,a5,c78 <vprintfmt+0x270>
     c70:	f8144783          	lbu	a5,-127(s0)
     c74:	00078663          	beqz	a5,c80 <vprintfmt+0x278>
     c78:	00100793          	li	a5,1
     c7c:	0080006f          	j	c84 <vprintfmt+0x27c>
     c80:	00000793          	li	a5,0
     c84:	faf403a3          	sb	a5,-89(s0)
     c88:	fa744783          	lbu	a5,-89(s0)
     c8c:	0017f793          	andi	a5,a5,1
     c90:	faf403a3          	sb	a5,-89(s0)
     c94:	fa744783          	lbu	a5,-89(s0)
     c98:	0ff7f793          	zext.b	a5,a5
     c9c:	00078c63          	beqz	a5,cb4 <vprintfmt+0x2ac>
     ca0:	f4843783          	ld	a5,-184(s0)
     ca4:	00878713          	addi	a4,a5,8
     ca8:	f4e43423          	sd	a4,-184(s0)
     cac:	0007b783          	ld	a5,0(a5)
     cb0:	01c0006f          	j	ccc <vprintfmt+0x2c4>
     cb4:	f4843783          	ld	a5,-184(s0)
     cb8:	00878713          	addi	a4,a5,8
     cbc:	f4e43423          	sd	a4,-184(s0)
     cc0:	0007a783          	lw	a5,0(a5)
     cc4:	02079793          	slli	a5,a5,0x20
     cc8:	0207d793          	srli	a5,a5,0x20
     ccc:	fef43023          	sd	a5,-32(s0)
     cd0:	f8c42783          	lw	a5,-116(s0)
     cd4:	02079463          	bnez	a5,cfc <vprintfmt+0x2f4>
     cd8:	fe043783          	ld	a5,-32(s0)
     cdc:	02079063          	bnez	a5,cfc <vprintfmt+0x2f4>
     ce0:	f5043783          	ld	a5,-176(s0)
     ce4:	0007c783          	lbu	a5,0(a5)
     ce8:	00078713          	mv	a4,a5
     cec:	07000793          	li	a5,112
     cf0:	00f70663          	beq	a4,a5,cfc <vprintfmt+0x2f4>
     cf4:	f8040023          	sb	zero,-128(s0)
     cf8:	4d00006f          	j	11c8 <vprintfmt+0x7c0>
     cfc:	f5043783          	ld	a5,-176(s0)
     d00:	0007c783          	lbu	a5,0(a5)
     d04:	00078713          	mv	a4,a5
     d08:	07000793          	li	a5,112
     d0c:	00f70a63          	beq	a4,a5,d20 <vprintfmt+0x318>
     d10:	f8244783          	lbu	a5,-126(s0)
     d14:	00078a63          	beqz	a5,d28 <vprintfmt+0x320>
     d18:	fe043783          	ld	a5,-32(s0)
     d1c:	00078663          	beqz	a5,d28 <vprintfmt+0x320>
     d20:	00100793          	li	a5,1
     d24:	0080006f          	j	d2c <vprintfmt+0x324>
     d28:	00000793          	li	a5,0
     d2c:	faf40323          	sb	a5,-90(s0)
     d30:	fa644783          	lbu	a5,-90(s0)
     d34:	0017f793          	andi	a5,a5,1
     d38:	faf40323          	sb	a5,-90(s0)
     d3c:	fc042e23          	sw	zero,-36(s0)
     d40:	f5043783          	ld	a5,-176(s0)
     d44:	0007c783          	lbu	a5,0(a5)
     d48:	00078713          	mv	a4,a5
     d4c:	05800793          	li	a5,88
     d50:	00f71863          	bne	a4,a5,d60 <vprintfmt+0x358>
     d54:	00001797          	auipc	a5,0x1
     d58:	88c78793          	addi	a5,a5,-1908 # 15e0 <upperxdigits.1>
     d5c:	00c0006f          	j	d68 <vprintfmt+0x360>
     d60:	00001797          	auipc	a5,0x1
     d64:	89878793          	addi	a5,a5,-1896 # 15f8 <lowerxdigits.0>
     d68:	f8f43c23          	sd	a5,-104(s0)
     d6c:	fe043783          	ld	a5,-32(s0)
     d70:	00f7f793          	andi	a5,a5,15
     d74:	f9843703          	ld	a4,-104(s0)
     d78:	00f70733          	add	a4,a4,a5
     d7c:	fdc42783          	lw	a5,-36(s0)
     d80:	0017869b          	addiw	a3,a5,1
     d84:	fcd42e23          	sw	a3,-36(s0)
     d88:	00074703          	lbu	a4,0(a4)
     d8c:	ff078793          	addi	a5,a5,-16
     d90:	008787b3          	add	a5,a5,s0
     d94:	f8e78023          	sb	a4,-128(a5)
     d98:	fe043783          	ld	a5,-32(s0)
     d9c:	0047d793          	srli	a5,a5,0x4
     da0:	fef43023          	sd	a5,-32(s0)
     da4:	fe043783          	ld	a5,-32(s0)
     da8:	fc0792e3          	bnez	a5,d6c <vprintfmt+0x364>
     dac:	f8c42783          	lw	a5,-116(s0)
     db0:	00078713          	mv	a4,a5
     db4:	fff00793          	li	a5,-1
     db8:	02f71663          	bne	a4,a5,de4 <vprintfmt+0x3dc>
     dbc:	f8344783          	lbu	a5,-125(s0)
     dc0:	02078263          	beqz	a5,de4 <vprintfmt+0x3dc>
     dc4:	f8842703          	lw	a4,-120(s0)
     dc8:	fa644783          	lbu	a5,-90(s0)
     dcc:	0007879b          	sext.w	a5,a5
     dd0:	0017979b          	slliw	a5,a5,0x1
     dd4:	0007879b          	sext.w	a5,a5
     dd8:	40f707bb          	subw	a5,a4,a5
     ddc:	0007879b          	sext.w	a5,a5
     de0:	f8f42623          	sw	a5,-116(s0)
     de4:	f8842703          	lw	a4,-120(s0)
     de8:	fa644783          	lbu	a5,-90(s0)
     dec:	0007879b          	sext.w	a5,a5
     df0:	0017979b          	slliw	a5,a5,0x1
     df4:	0007879b          	sext.w	a5,a5
     df8:	40f707bb          	subw	a5,a4,a5
     dfc:	0007871b          	sext.w	a4,a5
     e00:	fdc42783          	lw	a5,-36(s0)
     e04:	f8f42a23          	sw	a5,-108(s0)
     e08:	f8c42783          	lw	a5,-116(s0)
     e0c:	f8f42823          	sw	a5,-112(s0)
     e10:	f9442783          	lw	a5,-108(s0)
     e14:	00078593          	mv	a1,a5
     e18:	f9042783          	lw	a5,-112(s0)
     e1c:	00078613          	mv	a2,a5
     e20:	0006069b          	sext.w	a3,a2
     e24:	0005879b          	sext.w	a5,a1
     e28:	00f6d463          	bge	a3,a5,e30 <vprintfmt+0x428>
     e2c:	00058613          	mv	a2,a1
     e30:	0006079b          	sext.w	a5,a2
     e34:	40f707bb          	subw	a5,a4,a5
     e38:	fcf42c23          	sw	a5,-40(s0)
     e3c:	0280006f          	j	e64 <vprintfmt+0x45c>
     e40:	f5843783          	ld	a5,-168(s0)
     e44:	02000513          	li	a0,32
     e48:	000780e7          	jalr	a5
     e4c:	fec42783          	lw	a5,-20(s0)
     e50:	0017879b          	addiw	a5,a5,1
     e54:	fef42623          	sw	a5,-20(s0)
     e58:	fd842783          	lw	a5,-40(s0)
     e5c:	fff7879b          	addiw	a5,a5,-1
     e60:	fcf42c23          	sw	a5,-40(s0)
     e64:	fd842783          	lw	a5,-40(s0)
     e68:	0007879b          	sext.w	a5,a5
     e6c:	fcf04ae3          	bgtz	a5,e40 <vprintfmt+0x438>
     e70:	fa644783          	lbu	a5,-90(s0)
     e74:	0ff7f793          	zext.b	a5,a5
     e78:	04078463          	beqz	a5,ec0 <vprintfmt+0x4b8>
     e7c:	f5843783          	ld	a5,-168(s0)
     e80:	03000513          	li	a0,48
     e84:	000780e7          	jalr	a5
     e88:	f5043783          	ld	a5,-176(s0)
     e8c:	0007c783          	lbu	a5,0(a5)
     e90:	00078713          	mv	a4,a5
     e94:	05800793          	li	a5,88
     e98:	00f71663          	bne	a4,a5,ea4 <vprintfmt+0x49c>
     e9c:	05800793          	li	a5,88
     ea0:	0080006f          	j	ea8 <vprintfmt+0x4a0>
     ea4:	07800793          	li	a5,120
     ea8:	f5843703          	ld	a4,-168(s0)
     eac:	00078513          	mv	a0,a5
     eb0:	000700e7          	jalr	a4
     eb4:	fec42783          	lw	a5,-20(s0)
     eb8:	0027879b          	addiw	a5,a5,2
     ebc:	fef42623          	sw	a5,-20(s0)
     ec0:	fdc42783          	lw	a5,-36(s0)
     ec4:	fcf42a23          	sw	a5,-44(s0)
     ec8:	0280006f          	j	ef0 <vprintfmt+0x4e8>
     ecc:	f5843783          	ld	a5,-168(s0)
     ed0:	03000513          	li	a0,48
     ed4:	000780e7          	jalr	a5
     ed8:	fec42783          	lw	a5,-20(s0)
     edc:	0017879b          	addiw	a5,a5,1
     ee0:	fef42623          	sw	a5,-20(s0)
     ee4:	fd442783          	lw	a5,-44(s0)
     ee8:	0017879b          	addiw	a5,a5,1
     eec:	fcf42a23          	sw	a5,-44(s0)
     ef0:	f8c42703          	lw	a4,-116(s0)
     ef4:	fd442783          	lw	a5,-44(s0)
     ef8:	0007879b          	sext.w	a5,a5
     efc:	fce7c8e3          	blt	a5,a4,ecc <vprintfmt+0x4c4>
     f00:	fdc42783          	lw	a5,-36(s0)
     f04:	fff7879b          	addiw	a5,a5,-1
     f08:	fcf42823          	sw	a5,-48(s0)
     f0c:	03c0006f          	j	f48 <vprintfmt+0x540>
     f10:	fd042783          	lw	a5,-48(s0)
     f14:	ff078793          	addi	a5,a5,-16
     f18:	008787b3          	add	a5,a5,s0
     f1c:	f807c783          	lbu	a5,-128(a5)
     f20:	0007871b          	sext.w	a4,a5
     f24:	f5843783          	ld	a5,-168(s0)
     f28:	00070513          	mv	a0,a4
     f2c:	000780e7          	jalr	a5
     f30:	fec42783          	lw	a5,-20(s0)
     f34:	0017879b          	addiw	a5,a5,1
     f38:	fef42623          	sw	a5,-20(s0)
     f3c:	fd042783          	lw	a5,-48(s0)
     f40:	fff7879b          	addiw	a5,a5,-1
     f44:	fcf42823          	sw	a5,-48(s0)
     f48:	fd042783          	lw	a5,-48(s0)
     f4c:	0007879b          	sext.w	a5,a5
     f50:	fc07d0e3          	bgez	a5,f10 <vprintfmt+0x508>
     f54:	f8040023          	sb	zero,-128(s0)
     f58:	2700006f          	j	11c8 <vprintfmt+0x7c0>
     f5c:	f5043783          	ld	a5,-176(s0)
     f60:	0007c783          	lbu	a5,0(a5)
     f64:	00078713          	mv	a4,a5
     f68:	06400793          	li	a5,100
     f6c:	02f70663          	beq	a4,a5,f98 <vprintfmt+0x590>
     f70:	f5043783          	ld	a5,-176(s0)
     f74:	0007c783          	lbu	a5,0(a5)
     f78:	00078713          	mv	a4,a5
     f7c:	06900793          	li	a5,105
     f80:	00f70c63          	beq	a4,a5,f98 <vprintfmt+0x590>
     f84:	f5043783          	ld	a5,-176(s0)
     f88:	0007c783          	lbu	a5,0(a5)
     f8c:	00078713          	mv	a4,a5
     f90:	07500793          	li	a5,117
     f94:	08f71063          	bne	a4,a5,1014 <vprintfmt+0x60c>
     f98:	f8144783          	lbu	a5,-127(s0)
     f9c:	00078c63          	beqz	a5,fb4 <vprintfmt+0x5ac>
     fa0:	f4843783          	ld	a5,-184(s0)
     fa4:	00878713          	addi	a4,a5,8
     fa8:	f4e43423          	sd	a4,-184(s0)
     fac:	0007b783          	ld	a5,0(a5)
     fb0:	0140006f          	j	fc4 <vprintfmt+0x5bc>
     fb4:	f4843783          	ld	a5,-184(s0)
     fb8:	00878713          	addi	a4,a5,8
     fbc:	f4e43423          	sd	a4,-184(s0)
     fc0:	0007a783          	lw	a5,0(a5)
     fc4:	faf43423          	sd	a5,-88(s0)
     fc8:	fa843583          	ld	a1,-88(s0)
     fcc:	f5043783          	ld	a5,-176(s0)
     fd0:	0007c783          	lbu	a5,0(a5)
     fd4:	0007871b          	sext.w	a4,a5
     fd8:	07500793          	li	a5,117
     fdc:	40f707b3          	sub	a5,a4,a5
     fe0:	00f037b3          	snez	a5,a5
     fe4:	0ff7f793          	zext.b	a5,a5
     fe8:	f8040713          	addi	a4,s0,-128
     fec:	00070693          	mv	a3,a4
     ff0:	00078613          	mv	a2,a5
     ff4:	f5843503          	ld	a0,-168(s0)
     ff8:	f08ff0ef          	jal	700 <print_dec_int>
     ffc:	00050793          	mv	a5,a0
    1000:	fec42703          	lw	a4,-20(s0)
    1004:	00f707bb          	addw	a5,a4,a5
    1008:	fef42623          	sw	a5,-20(s0)
    100c:	f8040023          	sb	zero,-128(s0)
    1010:	1b80006f          	j	11c8 <vprintfmt+0x7c0>
    1014:	f5043783          	ld	a5,-176(s0)
    1018:	0007c783          	lbu	a5,0(a5)
    101c:	00078713          	mv	a4,a5
    1020:	06e00793          	li	a5,110
    1024:	04f71c63          	bne	a4,a5,107c <vprintfmt+0x674>
    1028:	f8144783          	lbu	a5,-127(s0)
    102c:	02078463          	beqz	a5,1054 <vprintfmt+0x64c>
    1030:	f4843783          	ld	a5,-184(s0)
    1034:	00878713          	addi	a4,a5,8
    1038:	f4e43423          	sd	a4,-184(s0)
    103c:	0007b783          	ld	a5,0(a5)
    1040:	faf43823          	sd	a5,-80(s0)
    1044:	fec42703          	lw	a4,-20(s0)
    1048:	fb043783          	ld	a5,-80(s0)
    104c:	00e7b023          	sd	a4,0(a5)
    1050:	0240006f          	j	1074 <vprintfmt+0x66c>
    1054:	f4843783          	ld	a5,-184(s0)
    1058:	00878713          	addi	a4,a5,8
    105c:	f4e43423          	sd	a4,-184(s0)
    1060:	0007b783          	ld	a5,0(a5)
    1064:	faf43c23          	sd	a5,-72(s0)
    1068:	fb843783          	ld	a5,-72(s0)
    106c:	fec42703          	lw	a4,-20(s0)
    1070:	00e7a023          	sw	a4,0(a5)
    1074:	f8040023          	sb	zero,-128(s0)
    1078:	1500006f          	j	11c8 <vprintfmt+0x7c0>
    107c:	f5043783          	ld	a5,-176(s0)
    1080:	0007c783          	lbu	a5,0(a5)
    1084:	00078713          	mv	a4,a5
    1088:	07300793          	li	a5,115
    108c:	02f71e63          	bne	a4,a5,10c8 <vprintfmt+0x6c0>
    1090:	f4843783          	ld	a5,-184(s0)
    1094:	00878713          	addi	a4,a5,8
    1098:	f4e43423          	sd	a4,-184(s0)
    109c:	0007b783          	ld	a5,0(a5)
    10a0:	fcf43023          	sd	a5,-64(s0)
    10a4:	fc043583          	ld	a1,-64(s0)
    10a8:	f5843503          	ld	a0,-168(s0)
    10ac:	dccff0ef          	jal	678 <puts_wo_nl>
    10b0:	00050793          	mv	a5,a0
    10b4:	fec42703          	lw	a4,-20(s0)
    10b8:	00f707bb          	addw	a5,a4,a5
    10bc:	fef42623          	sw	a5,-20(s0)
    10c0:	f8040023          	sb	zero,-128(s0)
    10c4:	1040006f          	j	11c8 <vprintfmt+0x7c0>
    10c8:	f5043783          	ld	a5,-176(s0)
    10cc:	0007c783          	lbu	a5,0(a5)
    10d0:	00078713          	mv	a4,a5
    10d4:	06300793          	li	a5,99
    10d8:	02f71e63          	bne	a4,a5,1114 <vprintfmt+0x70c>
    10dc:	f4843783          	ld	a5,-184(s0)
    10e0:	00878713          	addi	a4,a5,8
    10e4:	f4e43423          	sd	a4,-184(s0)
    10e8:	0007a783          	lw	a5,0(a5)
    10ec:	fcf42623          	sw	a5,-52(s0)
    10f0:	fcc42703          	lw	a4,-52(s0)
    10f4:	f5843783          	ld	a5,-168(s0)
    10f8:	00070513          	mv	a0,a4
    10fc:	000780e7          	jalr	a5
    1100:	fec42783          	lw	a5,-20(s0)
    1104:	0017879b          	addiw	a5,a5,1
    1108:	fef42623          	sw	a5,-20(s0)
    110c:	f8040023          	sb	zero,-128(s0)
    1110:	0b80006f          	j	11c8 <vprintfmt+0x7c0>
    1114:	f5043783          	ld	a5,-176(s0)
    1118:	0007c783          	lbu	a5,0(a5)
    111c:	00078713          	mv	a4,a5
    1120:	02500793          	li	a5,37
    1124:	02f71263          	bne	a4,a5,1148 <vprintfmt+0x740>
    1128:	f5843783          	ld	a5,-168(s0)
    112c:	02500513          	li	a0,37
    1130:	000780e7          	jalr	a5
    1134:	fec42783          	lw	a5,-20(s0)
    1138:	0017879b          	addiw	a5,a5,1
    113c:	fef42623          	sw	a5,-20(s0)
    1140:	f8040023          	sb	zero,-128(s0)
    1144:	0840006f          	j	11c8 <vprintfmt+0x7c0>
    1148:	f5043783          	ld	a5,-176(s0)
    114c:	0007c783          	lbu	a5,0(a5)
    1150:	0007871b          	sext.w	a4,a5
    1154:	f5843783          	ld	a5,-168(s0)
    1158:	00070513          	mv	a0,a4
    115c:	000780e7          	jalr	a5
    1160:	fec42783          	lw	a5,-20(s0)
    1164:	0017879b          	addiw	a5,a5,1
    1168:	fef42623          	sw	a5,-20(s0)
    116c:	f8040023          	sb	zero,-128(s0)
    1170:	0580006f          	j	11c8 <vprintfmt+0x7c0>
    1174:	f5043783          	ld	a5,-176(s0)
    1178:	0007c783          	lbu	a5,0(a5)
    117c:	00078713          	mv	a4,a5
    1180:	02500793          	li	a5,37
    1184:	02f71063          	bne	a4,a5,11a4 <vprintfmt+0x79c>
    1188:	f8043023          	sd	zero,-128(s0)
    118c:	f8043423          	sd	zero,-120(s0)
    1190:	00100793          	li	a5,1
    1194:	f8f40023          	sb	a5,-128(s0)
    1198:	fff00793          	li	a5,-1
    119c:	f8f42623          	sw	a5,-116(s0)
    11a0:	0280006f          	j	11c8 <vprintfmt+0x7c0>
    11a4:	f5043783          	ld	a5,-176(s0)
    11a8:	0007c783          	lbu	a5,0(a5)
    11ac:	0007871b          	sext.w	a4,a5
    11b0:	f5843783          	ld	a5,-168(s0)
    11b4:	00070513          	mv	a0,a4
    11b8:	000780e7          	jalr	a5
    11bc:	fec42783          	lw	a5,-20(s0)
    11c0:	0017879b          	addiw	a5,a5,1
    11c4:	fef42623          	sw	a5,-20(s0)
    11c8:	f5043783          	ld	a5,-176(s0)
    11cc:	00178793          	addi	a5,a5,1
    11d0:	f4f43823          	sd	a5,-176(s0)
    11d4:	f5043783          	ld	a5,-176(s0)
    11d8:	0007c783          	lbu	a5,0(a5)
    11dc:	84079ce3          	bnez	a5,a34 <vprintfmt+0x2c>
    11e0:	fec42783          	lw	a5,-20(s0)
    11e4:	00078513          	mv	a0,a5
    11e8:	0b813083          	ld	ra,184(sp)
    11ec:	0b013403          	ld	s0,176(sp)
    11f0:	0c010113          	addi	sp,sp,192
    11f4:	00008067          	ret

Disassembly of section .text.printf:

00000000000011f8 <printf>:
    11f8:	f8010113          	addi	sp,sp,-128
    11fc:	02113c23          	sd	ra,56(sp)
    1200:	02813823          	sd	s0,48(sp)
    1204:	04010413          	addi	s0,sp,64
    1208:	fca43423          	sd	a0,-56(s0)
    120c:	00b43423          	sd	a1,8(s0)
    1210:	00c43823          	sd	a2,16(s0)
    1214:	00d43c23          	sd	a3,24(s0)
    1218:	02e43023          	sd	a4,32(s0)
    121c:	02f43423          	sd	a5,40(s0)
    1220:	03043823          	sd	a6,48(s0)
    1224:	03143c23          	sd	a7,56(s0)
    1228:	fe042623          	sw	zero,-20(s0)
    122c:	04040793          	addi	a5,s0,64
    1230:	fcf43023          	sd	a5,-64(s0)
    1234:	fc043783          	ld	a5,-64(s0)
    1238:	fc878793          	addi	a5,a5,-56
    123c:	fcf43823          	sd	a5,-48(s0)
    1240:	fd043783          	ld	a5,-48(s0)
    1244:	00078613          	mv	a2,a5
    1248:	fc843583          	ld	a1,-56(s0)
    124c:	fffff517          	auipc	a0,0xfffff
    1250:	0f850513          	addi	a0,a0,248 # 344 <putc>
    1254:	fb4ff0ef          	jal	a08 <vprintfmt>
    1258:	00050793          	mv	a5,a0
    125c:	fef42623          	sw	a5,-20(s0)
    1260:	00100793          	li	a5,1
    1264:	fef43023          	sd	a5,-32(s0)
    1268:	00002797          	auipc	a5,0x2
    126c:	3a878793          	addi	a5,a5,936 # 3610 <tail>
    1270:	0007a783          	lw	a5,0(a5)
    1274:	0017871b          	addiw	a4,a5,1
    1278:	0007069b          	sext.w	a3,a4
    127c:	00002717          	auipc	a4,0x2
    1280:	39470713          	addi	a4,a4,916 # 3610 <tail>
    1284:	00d72023          	sw	a3,0(a4)
    1288:	00002717          	auipc	a4,0x2
    128c:	39070713          	addi	a4,a4,912 # 3618 <buffer>
    1290:	00f707b3          	add	a5,a4,a5
    1294:	00078023          	sb	zero,0(a5)
    1298:	00002797          	auipc	a5,0x2
    129c:	37878793          	addi	a5,a5,888 # 3610 <tail>
    12a0:	0007a603          	lw	a2,0(a5)
    12a4:	fe043703          	ld	a4,-32(s0)
    12a8:	00002697          	auipc	a3,0x2
    12ac:	37068693          	addi	a3,a3,880 # 3618 <buffer>
    12b0:	fd843783          	ld	a5,-40(s0)
    12b4:	04000893          	li	a7,64
    12b8:	00070513          	mv	a0,a4
    12bc:	00068593          	mv	a1,a3
    12c0:	00060613          	mv	a2,a2
    12c4:	00000073          	ecall
    12c8:	00050793          	mv	a5,a0
    12cc:	fcf43c23          	sd	a5,-40(s0)
    12d0:	00002797          	auipc	a5,0x2
    12d4:	34078793          	addi	a5,a5,832 # 3610 <tail>
    12d8:	0007a023          	sw	zero,0(a5)
    12dc:	fec42783          	lw	a5,-20(s0)
    12e0:	00078513          	mv	a0,a5
    12e4:	03813083          	ld	ra,56(sp)
    12e8:	03013403          	ld	s0,48(sp)
    12ec:	08010113          	addi	sp,sp,128
    12f0:	00008067          	ret
