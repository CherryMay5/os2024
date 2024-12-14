
uapp:     file format elf64-littleriscv


Disassembly of section .text:

00000000000100e8 <_start>:
   100e8:	0c00006f          	j	101a8 <main>

00000000000100ec <getpid>:
   100ec:	fe010113          	addi	sp,sp,-32
   100f0:	00813c23          	sd	s0,24(sp)
   100f4:	02010413          	addi	s0,sp,32
   100f8:	fe843783          	ld	a5,-24(s0)
   100fc:	0ac00893          	li	a7,172
   10100:	00000073          	ecall
   10104:	00050793          	mv	a5,a0
   10108:	fef43423          	sd	a5,-24(s0)
   1010c:	fe843783          	ld	a5,-24(s0)
   10110:	00078513          	mv	a0,a5
   10114:	01813403          	ld	s0,24(sp)
   10118:	02010113          	addi	sp,sp,32
   1011c:	00008067          	ret

0000000000010120 <fork>:
   10120:	fe010113          	addi	sp,sp,-32
   10124:	00813c23          	sd	s0,24(sp)
   10128:	02010413          	addi	s0,sp,32
   1012c:	fe843783          	ld	a5,-24(s0)
   10130:	0dc00893          	li	a7,220
   10134:	00000073          	ecall
   10138:	00050793          	mv	a5,a0
   1013c:	fef43423          	sd	a5,-24(s0)
   10140:	fe843783          	ld	a5,-24(s0)
   10144:	00078513          	mv	a0,a5
   10148:	01813403          	ld	s0,24(sp)
   1014c:	02010113          	addi	sp,sp,32
   10150:	00008067          	ret

0000000000010154 <wait>:
   10154:	fd010113          	addi	sp,sp,-48
   10158:	02813423          	sd	s0,40(sp)
   1015c:	03010413          	addi	s0,sp,48
   10160:	00050793          	mv	a5,a0
   10164:	fcf42e23          	sw	a5,-36(s0)
   10168:	fe042623          	sw	zero,-20(s0)
   1016c:	0100006f          	j	1017c <wait+0x28>
   10170:	fec42783          	lw	a5,-20(s0)
   10174:	0017879b          	addiw	a5,a5,1
   10178:	fef42623          	sw	a5,-20(s0)
   1017c:	fec42783          	lw	a5,-20(s0)
   10180:	00078713          	mv	a4,a5
   10184:	fdc42783          	lw	a5,-36(s0)
   10188:	0007071b          	sext.w	a4,a4
   1018c:	0007879b          	sext.w	a5,a5
   10190:	fef760e3          	bltu	a4,a5,10170 <wait+0x1c>
   10194:	00000013          	nop
   10198:	00000013          	nop
   1019c:	02813403          	ld	s0,40(sp)
   101a0:	03010113          	addi	sp,sp,48
   101a4:	00008067          	ret

00000000000101a8 <main>:
   101a8:	fe010113          	addi	sp,sp,-32
   101ac:	00113c23          	sd	ra,24(sp)
   101b0:	00813823          	sd	s0,16(sp)
   101b4:	02010413          	addi	s0,sp,32
   101b8:	00001517          	auipc	a0,0x1
   101bc:	22850513          	addi	a0,a0,552 # 113e0 <printf+0x100>
   101c0:	120010ef          	jal	112e0 <printf>
   101c4:	fe042623          	sw	zero,-20(s0)
   101c8:	0480006f          	j	10210 <main+0x68>
   101cc:	f21ff0ef          	jal	100ec <getpid>
   101d0:	00050593          	mv	a1,a0
   101d4:	00002797          	auipc	a5,0x2
   101d8:	e2c78793          	addi	a5,a5,-468 # 12000 <global_variable>
   101dc:	0007a783          	lw	a5,0(a5)
   101e0:	0017871b          	addiw	a4,a5,1
   101e4:	0007069b          	sext.w	a3,a4
   101e8:	00002717          	auipc	a4,0x2
   101ec:	e1870713          	addi	a4,a4,-488 # 12000 <global_variable>
   101f0:	00d72023          	sw	a3,0(a4)
   101f4:	00078613          	mv	a2,a5
   101f8:	00001517          	auipc	a0,0x1
   101fc:	1f050513          	addi	a0,a0,496 # 113e8 <printf+0x108>
   10200:	0e0010ef          	jal	112e0 <printf>
   10204:	fec42783          	lw	a5,-20(s0)
   10208:	0017879b          	addiw	a5,a5,1
   1020c:	fef42623          	sw	a5,-20(s0)
   10210:	fec42783          	lw	a5,-20(s0)
   10214:	0007871b          	sext.w	a4,a5
   10218:	00200793          	li	a5,2
   1021c:	fae7d8e3          	bge	a5,a4,101cc <main+0x24>
   10220:	00002717          	auipc	a4,0x2
   10224:	de870713          	addi	a4,a4,-536 # 12008 <placeholder>
   10228:	000017b7          	lui	a5,0x1
   1022c:	00f707b3          	add	a5,a4,a5
   10230:	05a00713          	li	a4,90
   10234:	00e78023          	sb	a4,0(a5) # 1000 <_start-0xf0e8>
   10238:	00002717          	auipc	a4,0x2
   1023c:	dd070713          	addi	a4,a4,-560 # 12008 <placeholder>
   10240:	000017b7          	lui	a5,0x1
   10244:	00f707b3          	add	a5,a4,a5
   10248:	04a00713          	li	a4,74
   1024c:	00e780a3          	sb	a4,1(a5) # 1001 <_start-0xf0e7>
   10250:	00002717          	auipc	a4,0x2
   10254:	db870713          	addi	a4,a4,-584 # 12008 <placeholder>
   10258:	000017b7          	lui	a5,0x1
   1025c:	00f707b3          	add	a5,a4,a5
   10260:	05500713          	li	a4,85
   10264:	00e78123          	sb	a4,2(a5) # 1002 <_start-0xf0e6>
   10268:	00002717          	auipc	a4,0x2
   1026c:	da070713          	addi	a4,a4,-608 # 12008 <placeholder>
   10270:	000017b7          	lui	a5,0x1
   10274:	00f707b3          	add	a5,a4,a5
   10278:	02000713          	li	a4,32
   1027c:	00e781a3          	sb	a4,3(a5) # 1003 <_start-0xf0e5>
   10280:	00002717          	auipc	a4,0x2
   10284:	d8870713          	addi	a4,a4,-632 # 12008 <placeholder>
   10288:	000017b7          	lui	a5,0x1
   1028c:	00f707b3          	add	a5,a4,a5
   10290:	04f00713          	li	a4,79
   10294:	00e78223          	sb	a4,4(a5) # 1004 <_start-0xf0e4>
   10298:	00002717          	auipc	a4,0x2
   1029c:	d7070713          	addi	a4,a4,-656 # 12008 <placeholder>
   102a0:	000017b7          	lui	a5,0x1
   102a4:	00f707b3          	add	a5,a4,a5
   102a8:	05300713          	li	a4,83
   102ac:	00e782a3          	sb	a4,5(a5) # 1005 <_start-0xf0e3>
   102b0:	00002717          	auipc	a4,0x2
   102b4:	d5870713          	addi	a4,a4,-680 # 12008 <placeholder>
   102b8:	000017b7          	lui	a5,0x1
   102bc:	00f707b3          	add	a5,a4,a5
   102c0:	02000713          	li	a4,32
   102c4:	00e78323          	sb	a4,6(a5) # 1006 <_start-0xf0e2>
   102c8:	00002717          	auipc	a4,0x2
   102cc:	d4070713          	addi	a4,a4,-704 # 12008 <placeholder>
   102d0:	000017b7          	lui	a5,0x1
   102d4:	00f707b3          	add	a5,a4,a5
   102d8:	04c00713          	li	a4,76
   102dc:	00e783a3          	sb	a4,7(a5) # 1007 <_start-0xf0e1>
   102e0:	00002717          	auipc	a4,0x2
   102e4:	d2870713          	addi	a4,a4,-728 # 12008 <placeholder>
   102e8:	000017b7          	lui	a5,0x1
   102ec:	00f707b3          	add	a5,a4,a5
   102f0:	06100713          	li	a4,97
   102f4:	00e78423          	sb	a4,8(a5) # 1008 <_start-0xf0e0>
   102f8:	00002717          	auipc	a4,0x2
   102fc:	d1070713          	addi	a4,a4,-752 # 12008 <placeholder>
   10300:	000017b7          	lui	a5,0x1
   10304:	00f707b3          	add	a5,a4,a5
   10308:	06200713          	li	a4,98
   1030c:	00e784a3          	sb	a4,9(a5) # 1009 <_start-0xf0df>
   10310:	00002717          	auipc	a4,0x2
   10314:	cf870713          	addi	a4,a4,-776 # 12008 <placeholder>
   10318:	000017b7          	lui	a5,0x1
   1031c:	00f707b3          	add	a5,a4,a5
   10320:	03500713          	li	a4,53
   10324:	00e78523          	sb	a4,10(a5) # 100a <_start-0xf0de>
   10328:	00002717          	auipc	a4,0x2
   1032c:	ce070713          	addi	a4,a4,-800 # 12008 <placeholder>
   10330:	000017b7          	lui	a5,0x1
   10334:	00f707b3          	add	a5,a4,a5
   10338:	000785a3          	sb	zero,11(a5) # 100b <_start-0xf0dd>
   1033c:	de5ff0ef          	jal	10120 <fork>
   10340:	00050793          	mv	a5,a0
   10344:	fef42423          	sw	a5,-24(s0)
   10348:	fe842783          	lw	a5,-24(s0)
   1034c:	0007879b          	sext.w	a5,a5
   10350:	06079863          	bnez	a5,103c0 <main+0x218>
   10354:	d99ff0ef          	jal	100ec <getpid>
   10358:	00050793          	mv	a5,a0
   1035c:	00003617          	auipc	a2,0x3
   10360:	cac60613          	addi	a2,a2,-852 # 13008 <__global_pointer$+0x808>
   10364:	00078593          	mv	a1,a5
   10368:	00001517          	auipc	a0,0x1
   1036c:	0b050513          	addi	a0,a0,176 # 11418 <printf+0x138>
   10370:	771000ef          	jal	112e0 <printf>
   10374:	d79ff0ef          	jal	100ec <getpid>
   10378:	00050593          	mv	a1,a0
   1037c:	00002797          	auipc	a5,0x2
   10380:	c8478793          	addi	a5,a5,-892 # 12000 <global_variable>
   10384:	0007a783          	lw	a5,0(a5)
   10388:	0017871b          	addiw	a4,a5,1
   1038c:	0007069b          	sext.w	a3,a4
   10390:	00002717          	auipc	a4,0x2
   10394:	c7070713          	addi	a4,a4,-912 # 12000 <global_variable>
   10398:	00d72023          	sw	a3,0(a4)
   1039c:	00078613          	mv	a2,a5
   103a0:	00001517          	auipc	a0,0x1
   103a4:	0a850513          	addi	a0,a0,168 # 11448 <printf+0x168>
   103a8:	739000ef          	jal	112e0 <printf>
   103ac:	500007b7          	lui	a5,0x50000
   103b0:	fff78513          	addi	a0,a5,-1 # 4fffffff <__BSS_END__+0x4ffebc07>
   103b4:	da1ff0ef          	jal	10154 <wait>
   103b8:	00000013          	nop
   103bc:	fb9ff06f          	j	10374 <main+0x1cc>
   103c0:	d2dff0ef          	jal	100ec <getpid>
   103c4:	00050793          	mv	a5,a0
   103c8:	00003617          	auipc	a2,0x3
   103cc:	c4060613          	addi	a2,a2,-960 # 13008 <__global_pointer$+0x808>
   103d0:	00078593          	mv	a1,a5
   103d4:	00001517          	auipc	a0,0x1
   103d8:	0ac50513          	addi	a0,a0,172 # 11480 <printf+0x1a0>
   103dc:	705000ef          	jal	112e0 <printf>
   103e0:	d0dff0ef          	jal	100ec <getpid>
   103e4:	00050593          	mv	a1,a0
   103e8:	00002797          	auipc	a5,0x2
   103ec:	c1878793          	addi	a5,a5,-1000 # 12000 <global_variable>
   103f0:	0007a783          	lw	a5,0(a5)
   103f4:	0017871b          	addiw	a4,a5,1
   103f8:	0007069b          	sext.w	a3,a4
   103fc:	00002717          	auipc	a4,0x2
   10400:	c0470713          	addi	a4,a4,-1020 # 12000 <global_variable>
   10404:	00d72023          	sw	a3,0(a4)
   10408:	00078613          	mv	a2,a5
   1040c:	00001517          	auipc	a0,0x1
   10410:	0a450513          	addi	a0,a0,164 # 114b0 <printf+0x1d0>
   10414:	6cd000ef          	jal	112e0 <printf>
   10418:	500007b7          	lui	a5,0x50000
   1041c:	fff78513          	addi	a0,a5,-1 # 4fffffff <__BSS_END__+0x4ffebc07>
   10420:	d35ff0ef          	jal	10154 <wait>
   10424:	00000013          	nop
   10428:	fb9ff06f          	j	103e0 <main+0x238>

000000000001042c <putc>:
   1042c:	fe010113          	addi	sp,sp,-32
   10430:	00813c23          	sd	s0,24(sp)
   10434:	02010413          	addi	s0,sp,32
   10438:	00050793          	mv	a5,a0
   1043c:	fef42623          	sw	a5,-20(s0)
   10440:	00004797          	auipc	a5,0x4
   10444:	bc878793          	addi	a5,a5,-1080 # 14008 <tail>
   10448:	0007a783          	lw	a5,0(a5)
   1044c:	0017871b          	addiw	a4,a5,1
   10450:	0007069b          	sext.w	a3,a4
   10454:	00004717          	auipc	a4,0x4
   10458:	bb470713          	addi	a4,a4,-1100 # 14008 <tail>
   1045c:	00d72023          	sw	a3,0(a4)
   10460:	fec42703          	lw	a4,-20(s0)
   10464:	0ff77713          	zext.b	a4,a4
   10468:	00004697          	auipc	a3,0x4
   1046c:	ba868693          	addi	a3,a3,-1112 # 14010 <buffer>
   10470:	00f687b3          	add	a5,a3,a5
   10474:	00e78023          	sb	a4,0(a5)
   10478:	fec42783          	lw	a5,-20(s0)
   1047c:	0ff7f793          	zext.b	a5,a5
   10480:	0007879b          	sext.w	a5,a5
   10484:	00078513          	mv	a0,a5
   10488:	01813403          	ld	s0,24(sp)
   1048c:	02010113          	addi	sp,sp,32
   10490:	00008067          	ret

0000000000010494 <isspace>:
   10494:	fe010113          	addi	sp,sp,-32
   10498:	00813c23          	sd	s0,24(sp)
   1049c:	02010413          	addi	s0,sp,32
   104a0:	00050793          	mv	a5,a0
   104a4:	fef42623          	sw	a5,-20(s0)
   104a8:	fec42783          	lw	a5,-20(s0)
   104ac:	0007871b          	sext.w	a4,a5
   104b0:	02000793          	li	a5,32
   104b4:	02f70263          	beq	a4,a5,104d8 <isspace+0x44>
   104b8:	fec42783          	lw	a5,-20(s0)
   104bc:	0007871b          	sext.w	a4,a5
   104c0:	00800793          	li	a5,8
   104c4:	00e7de63          	bge	a5,a4,104e0 <isspace+0x4c>
   104c8:	fec42783          	lw	a5,-20(s0)
   104cc:	0007871b          	sext.w	a4,a5
   104d0:	00d00793          	li	a5,13
   104d4:	00e7c663          	blt	a5,a4,104e0 <isspace+0x4c>
   104d8:	00100793          	li	a5,1
   104dc:	0080006f          	j	104e4 <isspace+0x50>
   104e0:	00000793          	li	a5,0
   104e4:	00078513          	mv	a0,a5
   104e8:	01813403          	ld	s0,24(sp)
   104ec:	02010113          	addi	sp,sp,32
   104f0:	00008067          	ret

00000000000104f4 <strtol>:
   104f4:	fb010113          	addi	sp,sp,-80
   104f8:	04113423          	sd	ra,72(sp)
   104fc:	04813023          	sd	s0,64(sp)
   10500:	05010413          	addi	s0,sp,80
   10504:	fca43423          	sd	a0,-56(s0)
   10508:	fcb43023          	sd	a1,-64(s0)
   1050c:	00060793          	mv	a5,a2
   10510:	faf42e23          	sw	a5,-68(s0)
   10514:	fe043423          	sd	zero,-24(s0)
   10518:	fe0403a3          	sb	zero,-25(s0)
   1051c:	fc843783          	ld	a5,-56(s0)
   10520:	fcf43c23          	sd	a5,-40(s0)
   10524:	0100006f          	j	10534 <strtol+0x40>
   10528:	fd843783          	ld	a5,-40(s0)
   1052c:	00178793          	addi	a5,a5,1
   10530:	fcf43c23          	sd	a5,-40(s0)
   10534:	fd843783          	ld	a5,-40(s0)
   10538:	0007c783          	lbu	a5,0(a5)
   1053c:	0007879b          	sext.w	a5,a5
   10540:	00078513          	mv	a0,a5
   10544:	f51ff0ef          	jal	10494 <isspace>
   10548:	00050793          	mv	a5,a0
   1054c:	fc079ee3          	bnez	a5,10528 <strtol+0x34>
   10550:	fd843783          	ld	a5,-40(s0)
   10554:	0007c783          	lbu	a5,0(a5)
   10558:	00078713          	mv	a4,a5
   1055c:	02d00793          	li	a5,45
   10560:	00f71e63          	bne	a4,a5,1057c <strtol+0x88>
   10564:	00100793          	li	a5,1
   10568:	fef403a3          	sb	a5,-25(s0)
   1056c:	fd843783          	ld	a5,-40(s0)
   10570:	00178793          	addi	a5,a5,1
   10574:	fcf43c23          	sd	a5,-40(s0)
   10578:	0240006f          	j	1059c <strtol+0xa8>
   1057c:	fd843783          	ld	a5,-40(s0)
   10580:	0007c783          	lbu	a5,0(a5)
   10584:	00078713          	mv	a4,a5
   10588:	02b00793          	li	a5,43
   1058c:	00f71863          	bne	a4,a5,1059c <strtol+0xa8>
   10590:	fd843783          	ld	a5,-40(s0)
   10594:	00178793          	addi	a5,a5,1
   10598:	fcf43c23          	sd	a5,-40(s0)
   1059c:	fbc42783          	lw	a5,-68(s0)
   105a0:	0007879b          	sext.w	a5,a5
   105a4:	06079c63          	bnez	a5,1061c <strtol+0x128>
   105a8:	fd843783          	ld	a5,-40(s0)
   105ac:	0007c783          	lbu	a5,0(a5)
   105b0:	00078713          	mv	a4,a5
   105b4:	03000793          	li	a5,48
   105b8:	04f71e63          	bne	a4,a5,10614 <strtol+0x120>
   105bc:	fd843783          	ld	a5,-40(s0)
   105c0:	00178793          	addi	a5,a5,1
   105c4:	fcf43c23          	sd	a5,-40(s0)
   105c8:	fd843783          	ld	a5,-40(s0)
   105cc:	0007c783          	lbu	a5,0(a5)
   105d0:	00078713          	mv	a4,a5
   105d4:	07800793          	li	a5,120
   105d8:	00f70c63          	beq	a4,a5,105f0 <strtol+0xfc>
   105dc:	fd843783          	ld	a5,-40(s0)
   105e0:	0007c783          	lbu	a5,0(a5)
   105e4:	00078713          	mv	a4,a5
   105e8:	05800793          	li	a5,88
   105ec:	00f71e63          	bne	a4,a5,10608 <strtol+0x114>
   105f0:	01000793          	li	a5,16
   105f4:	faf42e23          	sw	a5,-68(s0)
   105f8:	fd843783          	ld	a5,-40(s0)
   105fc:	00178793          	addi	a5,a5,1
   10600:	fcf43c23          	sd	a5,-40(s0)
   10604:	0180006f          	j	1061c <strtol+0x128>
   10608:	00800793          	li	a5,8
   1060c:	faf42e23          	sw	a5,-68(s0)
   10610:	00c0006f          	j	1061c <strtol+0x128>
   10614:	00a00793          	li	a5,10
   10618:	faf42e23          	sw	a5,-68(s0)
   1061c:	fd843783          	ld	a5,-40(s0)
   10620:	0007c783          	lbu	a5,0(a5)
   10624:	00078713          	mv	a4,a5
   10628:	02f00793          	li	a5,47
   1062c:	02e7f863          	bgeu	a5,a4,1065c <strtol+0x168>
   10630:	fd843783          	ld	a5,-40(s0)
   10634:	0007c783          	lbu	a5,0(a5)
   10638:	00078713          	mv	a4,a5
   1063c:	03900793          	li	a5,57
   10640:	00e7ee63          	bltu	a5,a4,1065c <strtol+0x168>
   10644:	fd843783          	ld	a5,-40(s0)
   10648:	0007c783          	lbu	a5,0(a5)
   1064c:	0007879b          	sext.w	a5,a5
   10650:	fd07879b          	addiw	a5,a5,-48
   10654:	fcf42a23          	sw	a5,-44(s0)
   10658:	0800006f          	j	106d8 <strtol+0x1e4>
   1065c:	fd843783          	ld	a5,-40(s0)
   10660:	0007c783          	lbu	a5,0(a5)
   10664:	00078713          	mv	a4,a5
   10668:	06000793          	li	a5,96
   1066c:	02e7f863          	bgeu	a5,a4,1069c <strtol+0x1a8>
   10670:	fd843783          	ld	a5,-40(s0)
   10674:	0007c783          	lbu	a5,0(a5)
   10678:	00078713          	mv	a4,a5
   1067c:	07a00793          	li	a5,122
   10680:	00e7ee63          	bltu	a5,a4,1069c <strtol+0x1a8>
   10684:	fd843783          	ld	a5,-40(s0)
   10688:	0007c783          	lbu	a5,0(a5)
   1068c:	0007879b          	sext.w	a5,a5
   10690:	fa97879b          	addiw	a5,a5,-87
   10694:	fcf42a23          	sw	a5,-44(s0)
   10698:	0400006f          	j	106d8 <strtol+0x1e4>
   1069c:	fd843783          	ld	a5,-40(s0)
   106a0:	0007c783          	lbu	a5,0(a5)
   106a4:	00078713          	mv	a4,a5
   106a8:	04000793          	li	a5,64
   106ac:	06e7f863          	bgeu	a5,a4,1071c <strtol+0x228>
   106b0:	fd843783          	ld	a5,-40(s0)
   106b4:	0007c783          	lbu	a5,0(a5)
   106b8:	00078713          	mv	a4,a5
   106bc:	05a00793          	li	a5,90
   106c0:	04e7ee63          	bltu	a5,a4,1071c <strtol+0x228>
   106c4:	fd843783          	ld	a5,-40(s0)
   106c8:	0007c783          	lbu	a5,0(a5)
   106cc:	0007879b          	sext.w	a5,a5
   106d0:	fc97879b          	addiw	a5,a5,-55
   106d4:	fcf42a23          	sw	a5,-44(s0)
   106d8:	fd442783          	lw	a5,-44(s0)
   106dc:	00078713          	mv	a4,a5
   106e0:	fbc42783          	lw	a5,-68(s0)
   106e4:	0007071b          	sext.w	a4,a4
   106e8:	0007879b          	sext.w	a5,a5
   106ec:	02f75663          	bge	a4,a5,10718 <strtol+0x224>
   106f0:	fbc42703          	lw	a4,-68(s0)
   106f4:	fe843783          	ld	a5,-24(s0)
   106f8:	02f70733          	mul	a4,a4,a5
   106fc:	fd442783          	lw	a5,-44(s0)
   10700:	00f707b3          	add	a5,a4,a5
   10704:	fef43423          	sd	a5,-24(s0)
   10708:	fd843783          	ld	a5,-40(s0)
   1070c:	00178793          	addi	a5,a5,1
   10710:	fcf43c23          	sd	a5,-40(s0)
   10714:	f09ff06f          	j	1061c <strtol+0x128>
   10718:	00000013          	nop
   1071c:	fc043783          	ld	a5,-64(s0)
   10720:	00078863          	beqz	a5,10730 <strtol+0x23c>
   10724:	fc043783          	ld	a5,-64(s0)
   10728:	fd843703          	ld	a4,-40(s0)
   1072c:	00e7b023          	sd	a4,0(a5)
   10730:	fe744783          	lbu	a5,-25(s0)
   10734:	0ff7f793          	zext.b	a5,a5
   10738:	00078863          	beqz	a5,10748 <strtol+0x254>
   1073c:	fe843783          	ld	a5,-24(s0)
   10740:	40f007b3          	neg	a5,a5
   10744:	0080006f          	j	1074c <strtol+0x258>
   10748:	fe843783          	ld	a5,-24(s0)
   1074c:	00078513          	mv	a0,a5
   10750:	04813083          	ld	ra,72(sp)
   10754:	04013403          	ld	s0,64(sp)
   10758:	05010113          	addi	sp,sp,80
   1075c:	00008067          	ret

0000000000010760 <puts_wo_nl>:
   10760:	fd010113          	addi	sp,sp,-48
   10764:	02113423          	sd	ra,40(sp)
   10768:	02813023          	sd	s0,32(sp)
   1076c:	03010413          	addi	s0,sp,48
   10770:	fca43c23          	sd	a0,-40(s0)
   10774:	fcb43823          	sd	a1,-48(s0)
   10778:	fd043783          	ld	a5,-48(s0)
   1077c:	00079863          	bnez	a5,1078c <puts_wo_nl+0x2c>
   10780:	00001797          	auipc	a5,0x1
   10784:	d6878793          	addi	a5,a5,-664 # 114e8 <printf+0x208>
   10788:	fcf43823          	sd	a5,-48(s0)
   1078c:	fd043783          	ld	a5,-48(s0)
   10790:	fef43423          	sd	a5,-24(s0)
   10794:	0240006f          	j	107b8 <puts_wo_nl+0x58>
   10798:	fe843783          	ld	a5,-24(s0)
   1079c:	00178713          	addi	a4,a5,1
   107a0:	fee43423          	sd	a4,-24(s0)
   107a4:	0007c783          	lbu	a5,0(a5)
   107a8:	0007871b          	sext.w	a4,a5
   107ac:	fd843783          	ld	a5,-40(s0)
   107b0:	00070513          	mv	a0,a4
   107b4:	000780e7          	jalr	a5
   107b8:	fe843783          	ld	a5,-24(s0)
   107bc:	0007c783          	lbu	a5,0(a5)
   107c0:	fc079ce3          	bnez	a5,10798 <puts_wo_nl+0x38>
   107c4:	fe843703          	ld	a4,-24(s0)
   107c8:	fd043783          	ld	a5,-48(s0)
   107cc:	40f707b3          	sub	a5,a4,a5
   107d0:	0007879b          	sext.w	a5,a5
   107d4:	00078513          	mv	a0,a5
   107d8:	02813083          	ld	ra,40(sp)
   107dc:	02013403          	ld	s0,32(sp)
   107e0:	03010113          	addi	sp,sp,48
   107e4:	00008067          	ret

00000000000107e8 <print_dec_int>:
   107e8:	f9010113          	addi	sp,sp,-112
   107ec:	06113423          	sd	ra,104(sp)
   107f0:	06813023          	sd	s0,96(sp)
   107f4:	07010413          	addi	s0,sp,112
   107f8:	faa43423          	sd	a0,-88(s0)
   107fc:	fab43023          	sd	a1,-96(s0)
   10800:	00060793          	mv	a5,a2
   10804:	f8d43823          	sd	a3,-112(s0)
   10808:	f8f40fa3          	sb	a5,-97(s0)
   1080c:	f9f44783          	lbu	a5,-97(s0)
   10810:	0ff7f793          	zext.b	a5,a5
   10814:	02078663          	beqz	a5,10840 <print_dec_int+0x58>
   10818:	fa043703          	ld	a4,-96(s0)
   1081c:	fff00793          	li	a5,-1
   10820:	03f79793          	slli	a5,a5,0x3f
   10824:	00f71e63          	bne	a4,a5,10840 <print_dec_int+0x58>
   10828:	00001597          	auipc	a1,0x1
   1082c:	cc858593          	addi	a1,a1,-824 # 114f0 <printf+0x210>
   10830:	fa843503          	ld	a0,-88(s0)
   10834:	f2dff0ef          	jal	10760 <puts_wo_nl>
   10838:	00050793          	mv	a5,a0
   1083c:	2a00006f          	j	10adc <print_dec_int+0x2f4>
   10840:	f9043783          	ld	a5,-112(s0)
   10844:	00c7a783          	lw	a5,12(a5)
   10848:	00079a63          	bnez	a5,1085c <print_dec_int+0x74>
   1084c:	fa043783          	ld	a5,-96(s0)
   10850:	00079663          	bnez	a5,1085c <print_dec_int+0x74>
   10854:	00000793          	li	a5,0
   10858:	2840006f          	j	10adc <print_dec_int+0x2f4>
   1085c:	fe0407a3          	sb	zero,-17(s0)
   10860:	f9f44783          	lbu	a5,-97(s0)
   10864:	0ff7f793          	zext.b	a5,a5
   10868:	02078063          	beqz	a5,10888 <print_dec_int+0xa0>
   1086c:	fa043783          	ld	a5,-96(s0)
   10870:	0007dc63          	bgez	a5,10888 <print_dec_int+0xa0>
   10874:	00100793          	li	a5,1
   10878:	fef407a3          	sb	a5,-17(s0)
   1087c:	fa043783          	ld	a5,-96(s0)
   10880:	40f007b3          	neg	a5,a5
   10884:	faf43023          	sd	a5,-96(s0)
   10888:	fe042423          	sw	zero,-24(s0)
   1088c:	f9f44783          	lbu	a5,-97(s0)
   10890:	0ff7f793          	zext.b	a5,a5
   10894:	02078863          	beqz	a5,108c4 <print_dec_int+0xdc>
   10898:	fef44783          	lbu	a5,-17(s0)
   1089c:	0ff7f793          	zext.b	a5,a5
   108a0:	00079e63          	bnez	a5,108bc <print_dec_int+0xd4>
   108a4:	f9043783          	ld	a5,-112(s0)
   108a8:	0057c783          	lbu	a5,5(a5)
   108ac:	00079863          	bnez	a5,108bc <print_dec_int+0xd4>
   108b0:	f9043783          	ld	a5,-112(s0)
   108b4:	0047c783          	lbu	a5,4(a5)
   108b8:	00078663          	beqz	a5,108c4 <print_dec_int+0xdc>
   108bc:	00100793          	li	a5,1
   108c0:	0080006f          	j	108c8 <print_dec_int+0xe0>
   108c4:	00000793          	li	a5,0
   108c8:	fcf40ba3          	sb	a5,-41(s0)
   108cc:	fd744783          	lbu	a5,-41(s0)
   108d0:	0017f793          	andi	a5,a5,1
   108d4:	fcf40ba3          	sb	a5,-41(s0)
   108d8:	fa043703          	ld	a4,-96(s0)
   108dc:	00a00793          	li	a5,10
   108e0:	02f777b3          	remu	a5,a4,a5
   108e4:	0ff7f713          	zext.b	a4,a5
   108e8:	fe842783          	lw	a5,-24(s0)
   108ec:	0017869b          	addiw	a3,a5,1
   108f0:	fed42423          	sw	a3,-24(s0)
   108f4:	0307071b          	addiw	a4,a4,48
   108f8:	0ff77713          	zext.b	a4,a4
   108fc:	ff078793          	addi	a5,a5,-16
   10900:	008787b3          	add	a5,a5,s0
   10904:	fce78423          	sb	a4,-56(a5)
   10908:	fa043703          	ld	a4,-96(s0)
   1090c:	00a00793          	li	a5,10
   10910:	02f757b3          	divu	a5,a4,a5
   10914:	faf43023          	sd	a5,-96(s0)
   10918:	fa043783          	ld	a5,-96(s0)
   1091c:	fa079ee3          	bnez	a5,108d8 <print_dec_int+0xf0>
   10920:	f9043783          	ld	a5,-112(s0)
   10924:	00c7a783          	lw	a5,12(a5)
   10928:	00078713          	mv	a4,a5
   1092c:	fff00793          	li	a5,-1
   10930:	02f71063          	bne	a4,a5,10950 <print_dec_int+0x168>
   10934:	f9043783          	ld	a5,-112(s0)
   10938:	0037c783          	lbu	a5,3(a5)
   1093c:	00078a63          	beqz	a5,10950 <print_dec_int+0x168>
   10940:	f9043783          	ld	a5,-112(s0)
   10944:	0087a703          	lw	a4,8(a5)
   10948:	f9043783          	ld	a5,-112(s0)
   1094c:	00e7a623          	sw	a4,12(a5)
   10950:	fe042223          	sw	zero,-28(s0)
   10954:	f9043783          	ld	a5,-112(s0)
   10958:	0087a703          	lw	a4,8(a5)
   1095c:	fe842783          	lw	a5,-24(s0)
   10960:	fcf42823          	sw	a5,-48(s0)
   10964:	f9043783          	ld	a5,-112(s0)
   10968:	00c7a783          	lw	a5,12(a5)
   1096c:	fcf42623          	sw	a5,-52(s0)
   10970:	fd042783          	lw	a5,-48(s0)
   10974:	00078593          	mv	a1,a5
   10978:	fcc42783          	lw	a5,-52(s0)
   1097c:	00078613          	mv	a2,a5
   10980:	0006069b          	sext.w	a3,a2
   10984:	0005879b          	sext.w	a5,a1
   10988:	00f6d463          	bge	a3,a5,10990 <print_dec_int+0x1a8>
   1098c:	00058613          	mv	a2,a1
   10990:	0006079b          	sext.w	a5,a2
   10994:	40f707bb          	subw	a5,a4,a5
   10998:	0007871b          	sext.w	a4,a5
   1099c:	fd744783          	lbu	a5,-41(s0)
   109a0:	0007879b          	sext.w	a5,a5
   109a4:	40f707bb          	subw	a5,a4,a5
   109a8:	fef42023          	sw	a5,-32(s0)
   109ac:	0280006f          	j	109d4 <print_dec_int+0x1ec>
   109b0:	fa843783          	ld	a5,-88(s0)
   109b4:	02000513          	li	a0,32
   109b8:	000780e7          	jalr	a5
   109bc:	fe442783          	lw	a5,-28(s0)
   109c0:	0017879b          	addiw	a5,a5,1
   109c4:	fef42223          	sw	a5,-28(s0)
   109c8:	fe042783          	lw	a5,-32(s0)
   109cc:	fff7879b          	addiw	a5,a5,-1
   109d0:	fef42023          	sw	a5,-32(s0)
   109d4:	fe042783          	lw	a5,-32(s0)
   109d8:	0007879b          	sext.w	a5,a5
   109dc:	fcf04ae3          	bgtz	a5,109b0 <print_dec_int+0x1c8>
   109e0:	fd744783          	lbu	a5,-41(s0)
   109e4:	0ff7f793          	zext.b	a5,a5
   109e8:	04078463          	beqz	a5,10a30 <print_dec_int+0x248>
   109ec:	fef44783          	lbu	a5,-17(s0)
   109f0:	0ff7f793          	zext.b	a5,a5
   109f4:	00078663          	beqz	a5,10a00 <print_dec_int+0x218>
   109f8:	02d00793          	li	a5,45
   109fc:	01c0006f          	j	10a18 <print_dec_int+0x230>
   10a00:	f9043783          	ld	a5,-112(s0)
   10a04:	0057c783          	lbu	a5,5(a5)
   10a08:	00078663          	beqz	a5,10a14 <print_dec_int+0x22c>
   10a0c:	02b00793          	li	a5,43
   10a10:	0080006f          	j	10a18 <print_dec_int+0x230>
   10a14:	02000793          	li	a5,32
   10a18:	fa843703          	ld	a4,-88(s0)
   10a1c:	00078513          	mv	a0,a5
   10a20:	000700e7          	jalr	a4
   10a24:	fe442783          	lw	a5,-28(s0)
   10a28:	0017879b          	addiw	a5,a5,1
   10a2c:	fef42223          	sw	a5,-28(s0)
   10a30:	fe842783          	lw	a5,-24(s0)
   10a34:	fcf42e23          	sw	a5,-36(s0)
   10a38:	0280006f          	j	10a60 <print_dec_int+0x278>
   10a3c:	fa843783          	ld	a5,-88(s0)
   10a40:	03000513          	li	a0,48
   10a44:	000780e7          	jalr	a5
   10a48:	fe442783          	lw	a5,-28(s0)
   10a4c:	0017879b          	addiw	a5,a5,1
   10a50:	fef42223          	sw	a5,-28(s0)
   10a54:	fdc42783          	lw	a5,-36(s0)
   10a58:	0017879b          	addiw	a5,a5,1
   10a5c:	fcf42e23          	sw	a5,-36(s0)
   10a60:	f9043783          	ld	a5,-112(s0)
   10a64:	00c7a703          	lw	a4,12(a5)
   10a68:	fd744783          	lbu	a5,-41(s0)
   10a6c:	0007879b          	sext.w	a5,a5
   10a70:	40f707bb          	subw	a5,a4,a5
   10a74:	0007871b          	sext.w	a4,a5
   10a78:	fdc42783          	lw	a5,-36(s0)
   10a7c:	0007879b          	sext.w	a5,a5
   10a80:	fae7cee3          	blt	a5,a4,10a3c <print_dec_int+0x254>
   10a84:	fe842783          	lw	a5,-24(s0)
   10a88:	fff7879b          	addiw	a5,a5,-1
   10a8c:	fcf42c23          	sw	a5,-40(s0)
   10a90:	03c0006f          	j	10acc <print_dec_int+0x2e4>
   10a94:	fd842783          	lw	a5,-40(s0)
   10a98:	ff078793          	addi	a5,a5,-16
   10a9c:	008787b3          	add	a5,a5,s0
   10aa0:	fc87c783          	lbu	a5,-56(a5)
   10aa4:	0007871b          	sext.w	a4,a5
   10aa8:	fa843783          	ld	a5,-88(s0)
   10aac:	00070513          	mv	a0,a4
   10ab0:	000780e7          	jalr	a5
   10ab4:	fe442783          	lw	a5,-28(s0)
   10ab8:	0017879b          	addiw	a5,a5,1
   10abc:	fef42223          	sw	a5,-28(s0)
   10ac0:	fd842783          	lw	a5,-40(s0)
   10ac4:	fff7879b          	addiw	a5,a5,-1
   10ac8:	fcf42c23          	sw	a5,-40(s0)
   10acc:	fd842783          	lw	a5,-40(s0)
   10ad0:	0007879b          	sext.w	a5,a5
   10ad4:	fc07d0e3          	bgez	a5,10a94 <print_dec_int+0x2ac>
   10ad8:	fe442783          	lw	a5,-28(s0)
   10adc:	00078513          	mv	a0,a5
   10ae0:	06813083          	ld	ra,104(sp)
   10ae4:	06013403          	ld	s0,96(sp)
   10ae8:	07010113          	addi	sp,sp,112
   10aec:	00008067          	ret

0000000000010af0 <vprintfmt>:
   10af0:	f4010113          	addi	sp,sp,-192
   10af4:	0a113c23          	sd	ra,184(sp)
   10af8:	0a813823          	sd	s0,176(sp)
   10afc:	0c010413          	addi	s0,sp,192
   10b00:	f4a43c23          	sd	a0,-168(s0)
   10b04:	f4b43823          	sd	a1,-176(s0)
   10b08:	f4c43423          	sd	a2,-184(s0)
   10b0c:	f8043023          	sd	zero,-128(s0)
   10b10:	f8043423          	sd	zero,-120(s0)
   10b14:	fe042623          	sw	zero,-20(s0)
   10b18:	7a40006f          	j	112bc <vprintfmt+0x7cc>
   10b1c:	f8044783          	lbu	a5,-128(s0)
   10b20:	72078e63          	beqz	a5,1125c <vprintfmt+0x76c>
   10b24:	f5043783          	ld	a5,-176(s0)
   10b28:	0007c783          	lbu	a5,0(a5)
   10b2c:	00078713          	mv	a4,a5
   10b30:	02300793          	li	a5,35
   10b34:	00f71863          	bne	a4,a5,10b44 <vprintfmt+0x54>
   10b38:	00100793          	li	a5,1
   10b3c:	f8f40123          	sb	a5,-126(s0)
   10b40:	7700006f          	j	112b0 <vprintfmt+0x7c0>
   10b44:	f5043783          	ld	a5,-176(s0)
   10b48:	0007c783          	lbu	a5,0(a5)
   10b4c:	00078713          	mv	a4,a5
   10b50:	03000793          	li	a5,48
   10b54:	00f71863          	bne	a4,a5,10b64 <vprintfmt+0x74>
   10b58:	00100793          	li	a5,1
   10b5c:	f8f401a3          	sb	a5,-125(s0)
   10b60:	7500006f          	j	112b0 <vprintfmt+0x7c0>
   10b64:	f5043783          	ld	a5,-176(s0)
   10b68:	0007c783          	lbu	a5,0(a5)
   10b6c:	00078713          	mv	a4,a5
   10b70:	06c00793          	li	a5,108
   10b74:	04f70063          	beq	a4,a5,10bb4 <vprintfmt+0xc4>
   10b78:	f5043783          	ld	a5,-176(s0)
   10b7c:	0007c783          	lbu	a5,0(a5)
   10b80:	00078713          	mv	a4,a5
   10b84:	07a00793          	li	a5,122
   10b88:	02f70663          	beq	a4,a5,10bb4 <vprintfmt+0xc4>
   10b8c:	f5043783          	ld	a5,-176(s0)
   10b90:	0007c783          	lbu	a5,0(a5)
   10b94:	00078713          	mv	a4,a5
   10b98:	07400793          	li	a5,116
   10b9c:	00f70c63          	beq	a4,a5,10bb4 <vprintfmt+0xc4>
   10ba0:	f5043783          	ld	a5,-176(s0)
   10ba4:	0007c783          	lbu	a5,0(a5)
   10ba8:	00078713          	mv	a4,a5
   10bac:	06a00793          	li	a5,106
   10bb0:	00f71863          	bne	a4,a5,10bc0 <vprintfmt+0xd0>
   10bb4:	00100793          	li	a5,1
   10bb8:	f8f400a3          	sb	a5,-127(s0)
   10bbc:	6f40006f          	j	112b0 <vprintfmt+0x7c0>
   10bc0:	f5043783          	ld	a5,-176(s0)
   10bc4:	0007c783          	lbu	a5,0(a5)
   10bc8:	00078713          	mv	a4,a5
   10bcc:	02b00793          	li	a5,43
   10bd0:	00f71863          	bne	a4,a5,10be0 <vprintfmt+0xf0>
   10bd4:	00100793          	li	a5,1
   10bd8:	f8f402a3          	sb	a5,-123(s0)
   10bdc:	6d40006f          	j	112b0 <vprintfmt+0x7c0>
   10be0:	f5043783          	ld	a5,-176(s0)
   10be4:	0007c783          	lbu	a5,0(a5)
   10be8:	00078713          	mv	a4,a5
   10bec:	02000793          	li	a5,32
   10bf0:	00f71863          	bne	a4,a5,10c00 <vprintfmt+0x110>
   10bf4:	00100793          	li	a5,1
   10bf8:	f8f40223          	sb	a5,-124(s0)
   10bfc:	6b40006f          	j	112b0 <vprintfmt+0x7c0>
   10c00:	f5043783          	ld	a5,-176(s0)
   10c04:	0007c783          	lbu	a5,0(a5)
   10c08:	00078713          	mv	a4,a5
   10c0c:	02a00793          	li	a5,42
   10c10:	00f71e63          	bne	a4,a5,10c2c <vprintfmt+0x13c>
   10c14:	f4843783          	ld	a5,-184(s0)
   10c18:	00878713          	addi	a4,a5,8
   10c1c:	f4e43423          	sd	a4,-184(s0)
   10c20:	0007a783          	lw	a5,0(a5)
   10c24:	f8f42423          	sw	a5,-120(s0)
   10c28:	6880006f          	j	112b0 <vprintfmt+0x7c0>
   10c2c:	f5043783          	ld	a5,-176(s0)
   10c30:	0007c783          	lbu	a5,0(a5)
   10c34:	00078713          	mv	a4,a5
   10c38:	03000793          	li	a5,48
   10c3c:	04e7f663          	bgeu	a5,a4,10c88 <vprintfmt+0x198>
   10c40:	f5043783          	ld	a5,-176(s0)
   10c44:	0007c783          	lbu	a5,0(a5)
   10c48:	00078713          	mv	a4,a5
   10c4c:	03900793          	li	a5,57
   10c50:	02e7ec63          	bltu	a5,a4,10c88 <vprintfmt+0x198>
   10c54:	f5043783          	ld	a5,-176(s0)
   10c58:	f5040713          	addi	a4,s0,-176
   10c5c:	00a00613          	li	a2,10
   10c60:	00070593          	mv	a1,a4
   10c64:	00078513          	mv	a0,a5
   10c68:	88dff0ef          	jal	104f4 <strtol>
   10c6c:	00050793          	mv	a5,a0
   10c70:	0007879b          	sext.w	a5,a5
   10c74:	f8f42423          	sw	a5,-120(s0)
   10c78:	f5043783          	ld	a5,-176(s0)
   10c7c:	fff78793          	addi	a5,a5,-1
   10c80:	f4f43823          	sd	a5,-176(s0)
   10c84:	62c0006f          	j	112b0 <vprintfmt+0x7c0>
   10c88:	f5043783          	ld	a5,-176(s0)
   10c8c:	0007c783          	lbu	a5,0(a5)
   10c90:	00078713          	mv	a4,a5
   10c94:	02e00793          	li	a5,46
   10c98:	06f71863          	bne	a4,a5,10d08 <vprintfmt+0x218>
   10c9c:	f5043783          	ld	a5,-176(s0)
   10ca0:	00178793          	addi	a5,a5,1
   10ca4:	f4f43823          	sd	a5,-176(s0)
   10ca8:	f5043783          	ld	a5,-176(s0)
   10cac:	0007c783          	lbu	a5,0(a5)
   10cb0:	00078713          	mv	a4,a5
   10cb4:	02a00793          	li	a5,42
   10cb8:	00f71e63          	bne	a4,a5,10cd4 <vprintfmt+0x1e4>
   10cbc:	f4843783          	ld	a5,-184(s0)
   10cc0:	00878713          	addi	a4,a5,8
   10cc4:	f4e43423          	sd	a4,-184(s0)
   10cc8:	0007a783          	lw	a5,0(a5)
   10ccc:	f8f42623          	sw	a5,-116(s0)
   10cd0:	5e00006f          	j	112b0 <vprintfmt+0x7c0>
   10cd4:	f5043783          	ld	a5,-176(s0)
   10cd8:	f5040713          	addi	a4,s0,-176
   10cdc:	00a00613          	li	a2,10
   10ce0:	00070593          	mv	a1,a4
   10ce4:	00078513          	mv	a0,a5
   10ce8:	80dff0ef          	jal	104f4 <strtol>
   10cec:	00050793          	mv	a5,a0
   10cf0:	0007879b          	sext.w	a5,a5
   10cf4:	f8f42623          	sw	a5,-116(s0)
   10cf8:	f5043783          	ld	a5,-176(s0)
   10cfc:	fff78793          	addi	a5,a5,-1
   10d00:	f4f43823          	sd	a5,-176(s0)
   10d04:	5ac0006f          	j	112b0 <vprintfmt+0x7c0>
   10d08:	f5043783          	ld	a5,-176(s0)
   10d0c:	0007c783          	lbu	a5,0(a5)
   10d10:	00078713          	mv	a4,a5
   10d14:	07800793          	li	a5,120
   10d18:	02f70663          	beq	a4,a5,10d44 <vprintfmt+0x254>
   10d1c:	f5043783          	ld	a5,-176(s0)
   10d20:	0007c783          	lbu	a5,0(a5)
   10d24:	00078713          	mv	a4,a5
   10d28:	05800793          	li	a5,88
   10d2c:	00f70c63          	beq	a4,a5,10d44 <vprintfmt+0x254>
   10d30:	f5043783          	ld	a5,-176(s0)
   10d34:	0007c783          	lbu	a5,0(a5)
   10d38:	00078713          	mv	a4,a5
   10d3c:	07000793          	li	a5,112
   10d40:	30f71263          	bne	a4,a5,11044 <vprintfmt+0x554>
   10d44:	f5043783          	ld	a5,-176(s0)
   10d48:	0007c783          	lbu	a5,0(a5)
   10d4c:	00078713          	mv	a4,a5
   10d50:	07000793          	li	a5,112
   10d54:	00f70663          	beq	a4,a5,10d60 <vprintfmt+0x270>
   10d58:	f8144783          	lbu	a5,-127(s0)
   10d5c:	00078663          	beqz	a5,10d68 <vprintfmt+0x278>
   10d60:	00100793          	li	a5,1
   10d64:	0080006f          	j	10d6c <vprintfmt+0x27c>
   10d68:	00000793          	li	a5,0
   10d6c:	faf403a3          	sb	a5,-89(s0)
   10d70:	fa744783          	lbu	a5,-89(s0)
   10d74:	0017f793          	andi	a5,a5,1
   10d78:	faf403a3          	sb	a5,-89(s0)
   10d7c:	fa744783          	lbu	a5,-89(s0)
   10d80:	0ff7f793          	zext.b	a5,a5
   10d84:	00078c63          	beqz	a5,10d9c <vprintfmt+0x2ac>
   10d88:	f4843783          	ld	a5,-184(s0)
   10d8c:	00878713          	addi	a4,a5,8
   10d90:	f4e43423          	sd	a4,-184(s0)
   10d94:	0007b783          	ld	a5,0(a5)
   10d98:	01c0006f          	j	10db4 <vprintfmt+0x2c4>
   10d9c:	f4843783          	ld	a5,-184(s0)
   10da0:	00878713          	addi	a4,a5,8
   10da4:	f4e43423          	sd	a4,-184(s0)
   10da8:	0007a783          	lw	a5,0(a5)
   10dac:	02079793          	slli	a5,a5,0x20
   10db0:	0207d793          	srli	a5,a5,0x20
   10db4:	fef43023          	sd	a5,-32(s0)
   10db8:	f8c42783          	lw	a5,-116(s0)
   10dbc:	02079463          	bnez	a5,10de4 <vprintfmt+0x2f4>
   10dc0:	fe043783          	ld	a5,-32(s0)
   10dc4:	02079063          	bnez	a5,10de4 <vprintfmt+0x2f4>
   10dc8:	f5043783          	ld	a5,-176(s0)
   10dcc:	0007c783          	lbu	a5,0(a5)
   10dd0:	00078713          	mv	a4,a5
   10dd4:	07000793          	li	a5,112
   10dd8:	00f70663          	beq	a4,a5,10de4 <vprintfmt+0x2f4>
   10ddc:	f8040023          	sb	zero,-128(s0)
   10de0:	4d00006f          	j	112b0 <vprintfmt+0x7c0>
   10de4:	f5043783          	ld	a5,-176(s0)
   10de8:	0007c783          	lbu	a5,0(a5)
   10dec:	00078713          	mv	a4,a5
   10df0:	07000793          	li	a5,112
   10df4:	00f70a63          	beq	a4,a5,10e08 <vprintfmt+0x318>
   10df8:	f8244783          	lbu	a5,-126(s0)
   10dfc:	00078a63          	beqz	a5,10e10 <vprintfmt+0x320>
   10e00:	fe043783          	ld	a5,-32(s0)
   10e04:	00078663          	beqz	a5,10e10 <vprintfmt+0x320>
   10e08:	00100793          	li	a5,1
   10e0c:	0080006f          	j	10e14 <vprintfmt+0x324>
   10e10:	00000793          	li	a5,0
   10e14:	faf40323          	sb	a5,-90(s0)
   10e18:	fa644783          	lbu	a5,-90(s0)
   10e1c:	0017f793          	andi	a5,a5,1
   10e20:	faf40323          	sb	a5,-90(s0)
   10e24:	fc042e23          	sw	zero,-36(s0)
   10e28:	f5043783          	ld	a5,-176(s0)
   10e2c:	0007c783          	lbu	a5,0(a5)
   10e30:	00078713          	mv	a4,a5
   10e34:	05800793          	li	a5,88
   10e38:	00f71863          	bne	a4,a5,10e48 <vprintfmt+0x358>
   10e3c:	00000797          	auipc	a5,0x0
   10e40:	6cc78793          	addi	a5,a5,1740 # 11508 <upperxdigits.1>
   10e44:	00c0006f          	j	10e50 <vprintfmt+0x360>
   10e48:	00000797          	auipc	a5,0x0
   10e4c:	6d878793          	addi	a5,a5,1752 # 11520 <lowerxdigits.0>
   10e50:	f8f43c23          	sd	a5,-104(s0)
   10e54:	fe043783          	ld	a5,-32(s0)
   10e58:	00f7f793          	andi	a5,a5,15
   10e5c:	f9843703          	ld	a4,-104(s0)
   10e60:	00f70733          	add	a4,a4,a5
   10e64:	fdc42783          	lw	a5,-36(s0)
   10e68:	0017869b          	addiw	a3,a5,1
   10e6c:	fcd42e23          	sw	a3,-36(s0)
   10e70:	00074703          	lbu	a4,0(a4)
   10e74:	ff078793          	addi	a5,a5,-16
   10e78:	008787b3          	add	a5,a5,s0
   10e7c:	f8e78023          	sb	a4,-128(a5)
   10e80:	fe043783          	ld	a5,-32(s0)
   10e84:	0047d793          	srli	a5,a5,0x4
   10e88:	fef43023          	sd	a5,-32(s0)
   10e8c:	fe043783          	ld	a5,-32(s0)
   10e90:	fc0792e3          	bnez	a5,10e54 <vprintfmt+0x364>
   10e94:	f8c42783          	lw	a5,-116(s0)
   10e98:	00078713          	mv	a4,a5
   10e9c:	fff00793          	li	a5,-1
   10ea0:	02f71663          	bne	a4,a5,10ecc <vprintfmt+0x3dc>
   10ea4:	f8344783          	lbu	a5,-125(s0)
   10ea8:	02078263          	beqz	a5,10ecc <vprintfmt+0x3dc>
   10eac:	f8842703          	lw	a4,-120(s0)
   10eb0:	fa644783          	lbu	a5,-90(s0)
   10eb4:	0007879b          	sext.w	a5,a5
   10eb8:	0017979b          	slliw	a5,a5,0x1
   10ebc:	0007879b          	sext.w	a5,a5
   10ec0:	40f707bb          	subw	a5,a4,a5
   10ec4:	0007879b          	sext.w	a5,a5
   10ec8:	f8f42623          	sw	a5,-116(s0)
   10ecc:	f8842703          	lw	a4,-120(s0)
   10ed0:	fa644783          	lbu	a5,-90(s0)
   10ed4:	0007879b          	sext.w	a5,a5
   10ed8:	0017979b          	slliw	a5,a5,0x1
   10edc:	0007879b          	sext.w	a5,a5
   10ee0:	40f707bb          	subw	a5,a4,a5
   10ee4:	0007871b          	sext.w	a4,a5
   10ee8:	fdc42783          	lw	a5,-36(s0)
   10eec:	f8f42a23          	sw	a5,-108(s0)
   10ef0:	f8c42783          	lw	a5,-116(s0)
   10ef4:	f8f42823          	sw	a5,-112(s0)
   10ef8:	f9442783          	lw	a5,-108(s0)
   10efc:	00078593          	mv	a1,a5
   10f00:	f9042783          	lw	a5,-112(s0)
   10f04:	00078613          	mv	a2,a5
   10f08:	0006069b          	sext.w	a3,a2
   10f0c:	0005879b          	sext.w	a5,a1
   10f10:	00f6d463          	bge	a3,a5,10f18 <vprintfmt+0x428>
   10f14:	00058613          	mv	a2,a1
   10f18:	0006079b          	sext.w	a5,a2
   10f1c:	40f707bb          	subw	a5,a4,a5
   10f20:	fcf42c23          	sw	a5,-40(s0)
   10f24:	0280006f          	j	10f4c <vprintfmt+0x45c>
   10f28:	f5843783          	ld	a5,-168(s0)
   10f2c:	02000513          	li	a0,32
   10f30:	000780e7          	jalr	a5
   10f34:	fec42783          	lw	a5,-20(s0)
   10f38:	0017879b          	addiw	a5,a5,1
   10f3c:	fef42623          	sw	a5,-20(s0)
   10f40:	fd842783          	lw	a5,-40(s0)
   10f44:	fff7879b          	addiw	a5,a5,-1
   10f48:	fcf42c23          	sw	a5,-40(s0)
   10f4c:	fd842783          	lw	a5,-40(s0)
   10f50:	0007879b          	sext.w	a5,a5
   10f54:	fcf04ae3          	bgtz	a5,10f28 <vprintfmt+0x438>
   10f58:	fa644783          	lbu	a5,-90(s0)
   10f5c:	0ff7f793          	zext.b	a5,a5
   10f60:	04078463          	beqz	a5,10fa8 <vprintfmt+0x4b8>
   10f64:	f5843783          	ld	a5,-168(s0)
   10f68:	03000513          	li	a0,48
   10f6c:	000780e7          	jalr	a5
   10f70:	f5043783          	ld	a5,-176(s0)
   10f74:	0007c783          	lbu	a5,0(a5)
   10f78:	00078713          	mv	a4,a5
   10f7c:	05800793          	li	a5,88
   10f80:	00f71663          	bne	a4,a5,10f8c <vprintfmt+0x49c>
   10f84:	05800793          	li	a5,88
   10f88:	0080006f          	j	10f90 <vprintfmt+0x4a0>
   10f8c:	07800793          	li	a5,120
   10f90:	f5843703          	ld	a4,-168(s0)
   10f94:	00078513          	mv	a0,a5
   10f98:	000700e7          	jalr	a4
   10f9c:	fec42783          	lw	a5,-20(s0)
   10fa0:	0027879b          	addiw	a5,a5,2
   10fa4:	fef42623          	sw	a5,-20(s0)
   10fa8:	fdc42783          	lw	a5,-36(s0)
   10fac:	fcf42a23          	sw	a5,-44(s0)
   10fb0:	0280006f          	j	10fd8 <vprintfmt+0x4e8>
   10fb4:	f5843783          	ld	a5,-168(s0)
   10fb8:	03000513          	li	a0,48
   10fbc:	000780e7          	jalr	a5
   10fc0:	fec42783          	lw	a5,-20(s0)
   10fc4:	0017879b          	addiw	a5,a5,1
   10fc8:	fef42623          	sw	a5,-20(s0)
   10fcc:	fd442783          	lw	a5,-44(s0)
   10fd0:	0017879b          	addiw	a5,a5,1
   10fd4:	fcf42a23          	sw	a5,-44(s0)
   10fd8:	f8c42703          	lw	a4,-116(s0)
   10fdc:	fd442783          	lw	a5,-44(s0)
   10fe0:	0007879b          	sext.w	a5,a5
   10fe4:	fce7c8e3          	blt	a5,a4,10fb4 <vprintfmt+0x4c4>
   10fe8:	fdc42783          	lw	a5,-36(s0)
   10fec:	fff7879b          	addiw	a5,a5,-1
   10ff0:	fcf42823          	sw	a5,-48(s0)
   10ff4:	03c0006f          	j	11030 <vprintfmt+0x540>
   10ff8:	fd042783          	lw	a5,-48(s0)
   10ffc:	ff078793          	addi	a5,a5,-16
   11000:	008787b3          	add	a5,a5,s0
   11004:	f807c783          	lbu	a5,-128(a5)
   11008:	0007871b          	sext.w	a4,a5
   1100c:	f5843783          	ld	a5,-168(s0)
   11010:	00070513          	mv	a0,a4
   11014:	000780e7          	jalr	a5
   11018:	fec42783          	lw	a5,-20(s0)
   1101c:	0017879b          	addiw	a5,a5,1
   11020:	fef42623          	sw	a5,-20(s0)
   11024:	fd042783          	lw	a5,-48(s0)
   11028:	fff7879b          	addiw	a5,a5,-1
   1102c:	fcf42823          	sw	a5,-48(s0)
   11030:	fd042783          	lw	a5,-48(s0)
   11034:	0007879b          	sext.w	a5,a5
   11038:	fc07d0e3          	bgez	a5,10ff8 <vprintfmt+0x508>
   1103c:	f8040023          	sb	zero,-128(s0)
   11040:	2700006f          	j	112b0 <vprintfmt+0x7c0>
   11044:	f5043783          	ld	a5,-176(s0)
   11048:	0007c783          	lbu	a5,0(a5)
   1104c:	00078713          	mv	a4,a5
   11050:	06400793          	li	a5,100
   11054:	02f70663          	beq	a4,a5,11080 <vprintfmt+0x590>
   11058:	f5043783          	ld	a5,-176(s0)
   1105c:	0007c783          	lbu	a5,0(a5)
   11060:	00078713          	mv	a4,a5
   11064:	06900793          	li	a5,105
   11068:	00f70c63          	beq	a4,a5,11080 <vprintfmt+0x590>
   1106c:	f5043783          	ld	a5,-176(s0)
   11070:	0007c783          	lbu	a5,0(a5)
   11074:	00078713          	mv	a4,a5
   11078:	07500793          	li	a5,117
   1107c:	08f71063          	bne	a4,a5,110fc <vprintfmt+0x60c>
   11080:	f8144783          	lbu	a5,-127(s0)
   11084:	00078c63          	beqz	a5,1109c <vprintfmt+0x5ac>
   11088:	f4843783          	ld	a5,-184(s0)
   1108c:	00878713          	addi	a4,a5,8
   11090:	f4e43423          	sd	a4,-184(s0)
   11094:	0007b783          	ld	a5,0(a5)
   11098:	0140006f          	j	110ac <vprintfmt+0x5bc>
   1109c:	f4843783          	ld	a5,-184(s0)
   110a0:	00878713          	addi	a4,a5,8
   110a4:	f4e43423          	sd	a4,-184(s0)
   110a8:	0007a783          	lw	a5,0(a5)
   110ac:	faf43423          	sd	a5,-88(s0)
   110b0:	fa843583          	ld	a1,-88(s0)
   110b4:	f5043783          	ld	a5,-176(s0)
   110b8:	0007c783          	lbu	a5,0(a5)
   110bc:	0007871b          	sext.w	a4,a5
   110c0:	07500793          	li	a5,117
   110c4:	40f707b3          	sub	a5,a4,a5
   110c8:	00f037b3          	snez	a5,a5
   110cc:	0ff7f793          	zext.b	a5,a5
   110d0:	f8040713          	addi	a4,s0,-128
   110d4:	00070693          	mv	a3,a4
   110d8:	00078613          	mv	a2,a5
   110dc:	f5843503          	ld	a0,-168(s0)
   110e0:	f08ff0ef          	jal	107e8 <print_dec_int>
   110e4:	00050793          	mv	a5,a0
   110e8:	fec42703          	lw	a4,-20(s0)
   110ec:	00f707bb          	addw	a5,a4,a5
   110f0:	fef42623          	sw	a5,-20(s0)
   110f4:	f8040023          	sb	zero,-128(s0)
   110f8:	1b80006f          	j	112b0 <vprintfmt+0x7c0>
   110fc:	f5043783          	ld	a5,-176(s0)
   11100:	0007c783          	lbu	a5,0(a5)
   11104:	00078713          	mv	a4,a5
   11108:	06e00793          	li	a5,110
   1110c:	04f71c63          	bne	a4,a5,11164 <vprintfmt+0x674>
   11110:	f8144783          	lbu	a5,-127(s0)
   11114:	02078463          	beqz	a5,1113c <vprintfmt+0x64c>
   11118:	f4843783          	ld	a5,-184(s0)
   1111c:	00878713          	addi	a4,a5,8
   11120:	f4e43423          	sd	a4,-184(s0)
   11124:	0007b783          	ld	a5,0(a5)
   11128:	faf43823          	sd	a5,-80(s0)
   1112c:	fec42703          	lw	a4,-20(s0)
   11130:	fb043783          	ld	a5,-80(s0)
   11134:	00e7b023          	sd	a4,0(a5)
   11138:	0240006f          	j	1115c <vprintfmt+0x66c>
   1113c:	f4843783          	ld	a5,-184(s0)
   11140:	00878713          	addi	a4,a5,8
   11144:	f4e43423          	sd	a4,-184(s0)
   11148:	0007b783          	ld	a5,0(a5)
   1114c:	faf43c23          	sd	a5,-72(s0)
   11150:	fb843783          	ld	a5,-72(s0)
   11154:	fec42703          	lw	a4,-20(s0)
   11158:	00e7a023          	sw	a4,0(a5)
   1115c:	f8040023          	sb	zero,-128(s0)
   11160:	1500006f          	j	112b0 <vprintfmt+0x7c0>
   11164:	f5043783          	ld	a5,-176(s0)
   11168:	0007c783          	lbu	a5,0(a5)
   1116c:	00078713          	mv	a4,a5
   11170:	07300793          	li	a5,115
   11174:	02f71e63          	bne	a4,a5,111b0 <vprintfmt+0x6c0>
   11178:	f4843783          	ld	a5,-184(s0)
   1117c:	00878713          	addi	a4,a5,8
   11180:	f4e43423          	sd	a4,-184(s0)
   11184:	0007b783          	ld	a5,0(a5)
   11188:	fcf43023          	sd	a5,-64(s0)
   1118c:	fc043583          	ld	a1,-64(s0)
   11190:	f5843503          	ld	a0,-168(s0)
   11194:	dccff0ef          	jal	10760 <puts_wo_nl>
   11198:	00050793          	mv	a5,a0
   1119c:	fec42703          	lw	a4,-20(s0)
   111a0:	00f707bb          	addw	a5,a4,a5
   111a4:	fef42623          	sw	a5,-20(s0)
   111a8:	f8040023          	sb	zero,-128(s0)
   111ac:	1040006f          	j	112b0 <vprintfmt+0x7c0>
   111b0:	f5043783          	ld	a5,-176(s0)
   111b4:	0007c783          	lbu	a5,0(a5)
   111b8:	00078713          	mv	a4,a5
   111bc:	06300793          	li	a5,99
   111c0:	02f71e63          	bne	a4,a5,111fc <vprintfmt+0x70c>
   111c4:	f4843783          	ld	a5,-184(s0)
   111c8:	00878713          	addi	a4,a5,8
   111cc:	f4e43423          	sd	a4,-184(s0)
   111d0:	0007a783          	lw	a5,0(a5)
   111d4:	fcf42623          	sw	a5,-52(s0)
   111d8:	fcc42703          	lw	a4,-52(s0)
   111dc:	f5843783          	ld	a5,-168(s0)
   111e0:	00070513          	mv	a0,a4
   111e4:	000780e7          	jalr	a5
   111e8:	fec42783          	lw	a5,-20(s0)
   111ec:	0017879b          	addiw	a5,a5,1
   111f0:	fef42623          	sw	a5,-20(s0)
   111f4:	f8040023          	sb	zero,-128(s0)
   111f8:	0b80006f          	j	112b0 <vprintfmt+0x7c0>
   111fc:	f5043783          	ld	a5,-176(s0)
   11200:	0007c783          	lbu	a5,0(a5)
   11204:	00078713          	mv	a4,a5
   11208:	02500793          	li	a5,37
   1120c:	02f71263          	bne	a4,a5,11230 <vprintfmt+0x740>
   11210:	f5843783          	ld	a5,-168(s0)
   11214:	02500513          	li	a0,37
   11218:	000780e7          	jalr	a5
   1121c:	fec42783          	lw	a5,-20(s0)
   11220:	0017879b          	addiw	a5,a5,1
   11224:	fef42623          	sw	a5,-20(s0)
   11228:	f8040023          	sb	zero,-128(s0)
   1122c:	0840006f          	j	112b0 <vprintfmt+0x7c0>
   11230:	f5043783          	ld	a5,-176(s0)
   11234:	0007c783          	lbu	a5,0(a5)
   11238:	0007871b          	sext.w	a4,a5
   1123c:	f5843783          	ld	a5,-168(s0)
   11240:	00070513          	mv	a0,a4
   11244:	000780e7          	jalr	a5
   11248:	fec42783          	lw	a5,-20(s0)
   1124c:	0017879b          	addiw	a5,a5,1
   11250:	fef42623          	sw	a5,-20(s0)
   11254:	f8040023          	sb	zero,-128(s0)
   11258:	0580006f          	j	112b0 <vprintfmt+0x7c0>
   1125c:	f5043783          	ld	a5,-176(s0)
   11260:	0007c783          	lbu	a5,0(a5)
   11264:	00078713          	mv	a4,a5
   11268:	02500793          	li	a5,37
   1126c:	02f71063          	bne	a4,a5,1128c <vprintfmt+0x79c>
   11270:	f8043023          	sd	zero,-128(s0)
   11274:	f8043423          	sd	zero,-120(s0)
   11278:	00100793          	li	a5,1
   1127c:	f8f40023          	sb	a5,-128(s0)
   11280:	fff00793          	li	a5,-1
   11284:	f8f42623          	sw	a5,-116(s0)
   11288:	0280006f          	j	112b0 <vprintfmt+0x7c0>
   1128c:	f5043783          	ld	a5,-176(s0)
   11290:	0007c783          	lbu	a5,0(a5)
   11294:	0007871b          	sext.w	a4,a5
   11298:	f5843783          	ld	a5,-168(s0)
   1129c:	00070513          	mv	a0,a4
   112a0:	000780e7          	jalr	a5
   112a4:	fec42783          	lw	a5,-20(s0)
   112a8:	0017879b          	addiw	a5,a5,1
   112ac:	fef42623          	sw	a5,-20(s0)
   112b0:	f5043783          	ld	a5,-176(s0)
   112b4:	00178793          	addi	a5,a5,1
   112b8:	f4f43823          	sd	a5,-176(s0)
   112bc:	f5043783          	ld	a5,-176(s0)
   112c0:	0007c783          	lbu	a5,0(a5)
   112c4:	84079ce3          	bnez	a5,10b1c <vprintfmt+0x2c>
   112c8:	fec42783          	lw	a5,-20(s0)
   112cc:	00078513          	mv	a0,a5
   112d0:	0b813083          	ld	ra,184(sp)
   112d4:	0b013403          	ld	s0,176(sp)
   112d8:	0c010113          	addi	sp,sp,192
   112dc:	00008067          	ret

00000000000112e0 <printf>:
   112e0:	f8010113          	addi	sp,sp,-128
   112e4:	02113c23          	sd	ra,56(sp)
   112e8:	02813823          	sd	s0,48(sp)
   112ec:	04010413          	addi	s0,sp,64
   112f0:	fca43423          	sd	a0,-56(s0)
   112f4:	00b43423          	sd	a1,8(s0)
   112f8:	00c43823          	sd	a2,16(s0)
   112fc:	00d43c23          	sd	a3,24(s0)
   11300:	02e43023          	sd	a4,32(s0)
   11304:	02f43423          	sd	a5,40(s0)
   11308:	03043823          	sd	a6,48(s0)
   1130c:	03143c23          	sd	a7,56(s0)
   11310:	fe042623          	sw	zero,-20(s0)
   11314:	04040793          	addi	a5,s0,64
   11318:	fcf43023          	sd	a5,-64(s0)
   1131c:	fc043783          	ld	a5,-64(s0)
   11320:	fc878793          	addi	a5,a5,-56
   11324:	fcf43823          	sd	a5,-48(s0)
   11328:	fd043783          	ld	a5,-48(s0)
   1132c:	00078613          	mv	a2,a5
   11330:	fc843583          	ld	a1,-56(s0)
   11334:	fffff517          	auipc	a0,0xfffff
   11338:	0f850513          	addi	a0,a0,248 # 1042c <putc>
   1133c:	fb4ff0ef          	jal	10af0 <vprintfmt>
   11340:	00050793          	mv	a5,a0
   11344:	fef42623          	sw	a5,-20(s0)
   11348:	00100793          	li	a5,1
   1134c:	fef43023          	sd	a5,-32(s0)
   11350:	00003797          	auipc	a5,0x3
   11354:	cb878793          	addi	a5,a5,-840 # 14008 <tail>
   11358:	0007a783          	lw	a5,0(a5)
   1135c:	0017871b          	addiw	a4,a5,1
   11360:	0007069b          	sext.w	a3,a4
   11364:	00003717          	auipc	a4,0x3
   11368:	ca470713          	addi	a4,a4,-860 # 14008 <tail>
   1136c:	00d72023          	sw	a3,0(a4)
   11370:	00003717          	auipc	a4,0x3
   11374:	ca070713          	addi	a4,a4,-864 # 14010 <buffer>
   11378:	00f707b3          	add	a5,a4,a5
   1137c:	00078023          	sb	zero,0(a5)
   11380:	00003797          	auipc	a5,0x3
   11384:	c8878793          	addi	a5,a5,-888 # 14008 <tail>
   11388:	0007a603          	lw	a2,0(a5)
   1138c:	fe043703          	ld	a4,-32(s0)
   11390:	00003697          	auipc	a3,0x3
   11394:	c8068693          	addi	a3,a3,-896 # 14010 <buffer>
   11398:	fd843783          	ld	a5,-40(s0)
   1139c:	04000893          	li	a7,64
   113a0:	00070513          	mv	a0,a4
   113a4:	00068593          	mv	a1,a3
   113a8:	00060613          	mv	a2,a2
   113ac:	00000073          	ecall
   113b0:	00050793          	mv	a5,a0
   113b4:	fcf43c23          	sd	a5,-40(s0)
   113b8:	00003797          	auipc	a5,0x3
   113bc:	c5078793          	addi	a5,a5,-944 # 14008 <tail>
   113c0:	0007a023          	sw	zero,0(a5)
   113c4:	fec42783          	lw	a5,-20(s0)
   113c8:	00078513          	mv	a0,a5
   113cc:	03813083          	ld	ra,56(sp)
   113d0:	03013403          	ld	s0,48(sp)
   113d4:	08010113          	addi	sp,sp,128
   113d8:	00008067          	ret
