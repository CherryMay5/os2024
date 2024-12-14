
uapp:     file format elf64-littleriscv


Disassembly of section .text:

00000000000100e8 <_start>:
   100e8:	08c0006f          	j	10174 <main>

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

0000000000010120 <wait>:
   10120:	fd010113          	addi	sp,sp,-48
   10124:	02813423          	sd	s0,40(sp)
   10128:	03010413          	addi	s0,sp,48
   1012c:	00050793          	mv	a5,a0
   10130:	fcf42e23          	sw	a5,-36(s0)
   10134:	fe042623          	sw	zero,-20(s0)
   10138:	0100006f          	j	10148 <wait+0x28>
   1013c:	fec42783          	lw	a5,-20(s0)
   10140:	0017879b          	addiw	a5,a5,1
   10144:	fef42623          	sw	a5,-20(s0)
   10148:	fec42783          	lw	a5,-20(s0)
   1014c:	00078713          	mv	a4,a5
   10150:	fdc42783          	lw	a5,-36(s0)
   10154:	0007071b          	sext.w	a4,a4
   10158:	0007879b          	sext.w	a5,a5
   1015c:	fef760e3          	bltu	a4,a5,1013c <wait+0x1c>
   10160:	00000013          	nop
   10164:	00000013          	nop
   10168:	02813403          	ld	s0,40(sp)
   1016c:	03010113          	addi	sp,sp,48
   10170:	00008067          	ret

0000000000010174 <main>:
   10174:	ff010113          	addi	sp,sp,-16
   10178:	00113423          	sd	ra,8(sp)
   1017c:	00813023          	sd	s0,0(sp)
   10180:	01010413          	addi	s0,sp,16
   10184:	00001517          	auipc	a0,0x1
   10188:	00450513          	addi	a0,a0,4 # 11188 <printf+0xfc>
   1018c:	701000ef          	jal	1108c <printf>
   10190:	f5dff0ef          	jal	100ec <getpid>
   10194:	00050593          	mv	a1,a0
   10198:	00003797          	auipc	a5,0x3
   1019c:	e6878793          	addi	a5,a5,-408 # 13000 <global_increment>
   101a0:	0007b783          	ld	a5,0(a5)
   101a4:	00178693          	addi	a3,a5,1
   101a8:	00003717          	auipc	a4,0x3
   101ac:	e5870713          	addi	a4,a4,-424 # 13000 <global_increment>
   101b0:	00d73023          	sd	a3,0(a4)
   101b4:	00078613          	mv	a2,a5
   101b8:	00001517          	auipc	a0,0x1
   101bc:	fe050513          	addi	a0,a0,-32 # 11198 <printf+0x10c>
   101c0:	6cd000ef          	jal	1108c <printf>
   101c4:	500007b7          	lui	a5,0x50000
   101c8:	fff78513          	addi	a0,a5,-1 # 4fffffff <__BSS_END__+0x4ffecc07>
   101cc:	f55ff0ef          	jal	10120 <wait>
   101d0:	00000013          	nop
   101d4:	fbdff06f          	j	10190 <main+0x1c>

00000000000101d8 <putc>:
   101d8:	fe010113          	addi	sp,sp,-32
   101dc:	00813c23          	sd	s0,24(sp)
   101e0:	02010413          	addi	s0,sp,32
   101e4:	00050793          	mv	a5,a0
   101e8:	fef42623          	sw	a5,-20(s0)
   101ec:	00003797          	auipc	a5,0x3
   101f0:	e1c78793          	addi	a5,a5,-484 # 13008 <tail>
   101f4:	0007a783          	lw	a5,0(a5)
   101f8:	0017871b          	addiw	a4,a5,1
   101fc:	0007069b          	sext.w	a3,a4
   10200:	00003717          	auipc	a4,0x3
   10204:	e0870713          	addi	a4,a4,-504 # 13008 <tail>
   10208:	00d72023          	sw	a3,0(a4)
   1020c:	fec42703          	lw	a4,-20(s0)
   10210:	0ff77713          	zext.b	a4,a4
   10214:	00003697          	auipc	a3,0x3
   10218:	dfc68693          	addi	a3,a3,-516 # 13010 <buffer>
   1021c:	00f687b3          	add	a5,a3,a5
   10220:	00e78023          	sb	a4,0(a5)
   10224:	fec42783          	lw	a5,-20(s0)
   10228:	0ff7f793          	zext.b	a5,a5
   1022c:	0007879b          	sext.w	a5,a5
   10230:	00078513          	mv	a0,a5
   10234:	01813403          	ld	s0,24(sp)
   10238:	02010113          	addi	sp,sp,32
   1023c:	00008067          	ret

0000000000010240 <isspace>:
   10240:	fe010113          	addi	sp,sp,-32
   10244:	00813c23          	sd	s0,24(sp)
   10248:	02010413          	addi	s0,sp,32
   1024c:	00050793          	mv	a5,a0
   10250:	fef42623          	sw	a5,-20(s0)
   10254:	fec42783          	lw	a5,-20(s0)
   10258:	0007871b          	sext.w	a4,a5
   1025c:	02000793          	li	a5,32
   10260:	02f70263          	beq	a4,a5,10284 <isspace+0x44>
   10264:	fec42783          	lw	a5,-20(s0)
   10268:	0007871b          	sext.w	a4,a5
   1026c:	00800793          	li	a5,8
   10270:	00e7de63          	bge	a5,a4,1028c <isspace+0x4c>
   10274:	fec42783          	lw	a5,-20(s0)
   10278:	0007871b          	sext.w	a4,a5
   1027c:	00d00793          	li	a5,13
   10280:	00e7c663          	blt	a5,a4,1028c <isspace+0x4c>
   10284:	00100793          	li	a5,1
   10288:	0080006f          	j	10290 <isspace+0x50>
   1028c:	00000793          	li	a5,0
   10290:	00078513          	mv	a0,a5
   10294:	01813403          	ld	s0,24(sp)
   10298:	02010113          	addi	sp,sp,32
   1029c:	00008067          	ret

00000000000102a0 <strtol>:
   102a0:	fb010113          	addi	sp,sp,-80
   102a4:	04113423          	sd	ra,72(sp)
   102a8:	04813023          	sd	s0,64(sp)
   102ac:	05010413          	addi	s0,sp,80
   102b0:	fca43423          	sd	a0,-56(s0)
   102b4:	fcb43023          	sd	a1,-64(s0)
   102b8:	00060793          	mv	a5,a2
   102bc:	faf42e23          	sw	a5,-68(s0)
   102c0:	fe043423          	sd	zero,-24(s0)
   102c4:	fe0403a3          	sb	zero,-25(s0)
   102c8:	fc843783          	ld	a5,-56(s0)
   102cc:	fcf43c23          	sd	a5,-40(s0)
   102d0:	0100006f          	j	102e0 <strtol+0x40>
   102d4:	fd843783          	ld	a5,-40(s0)
   102d8:	00178793          	addi	a5,a5,1
   102dc:	fcf43c23          	sd	a5,-40(s0)
   102e0:	fd843783          	ld	a5,-40(s0)
   102e4:	0007c783          	lbu	a5,0(a5)
   102e8:	0007879b          	sext.w	a5,a5
   102ec:	00078513          	mv	a0,a5
   102f0:	f51ff0ef          	jal	10240 <isspace>
   102f4:	00050793          	mv	a5,a0
   102f8:	fc079ee3          	bnez	a5,102d4 <strtol+0x34>
   102fc:	fd843783          	ld	a5,-40(s0)
   10300:	0007c783          	lbu	a5,0(a5)
   10304:	00078713          	mv	a4,a5
   10308:	02d00793          	li	a5,45
   1030c:	00f71e63          	bne	a4,a5,10328 <strtol+0x88>
   10310:	00100793          	li	a5,1
   10314:	fef403a3          	sb	a5,-25(s0)
   10318:	fd843783          	ld	a5,-40(s0)
   1031c:	00178793          	addi	a5,a5,1
   10320:	fcf43c23          	sd	a5,-40(s0)
   10324:	0240006f          	j	10348 <strtol+0xa8>
   10328:	fd843783          	ld	a5,-40(s0)
   1032c:	0007c783          	lbu	a5,0(a5)
   10330:	00078713          	mv	a4,a5
   10334:	02b00793          	li	a5,43
   10338:	00f71863          	bne	a4,a5,10348 <strtol+0xa8>
   1033c:	fd843783          	ld	a5,-40(s0)
   10340:	00178793          	addi	a5,a5,1
   10344:	fcf43c23          	sd	a5,-40(s0)
   10348:	fbc42783          	lw	a5,-68(s0)
   1034c:	0007879b          	sext.w	a5,a5
   10350:	06079c63          	bnez	a5,103c8 <strtol+0x128>
   10354:	fd843783          	ld	a5,-40(s0)
   10358:	0007c783          	lbu	a5,0(a5)
   1035c:	00078713          	mv	a4,a5
   10360:	03000793          	li	a5,48
   10364:	04f71e63          	bne	a4,a5,103c0 <strtol+0x120>
   10368:	fd843783          	ld	a5,-40(s0)
   1036c:	00178793          	addi	a5,a5,1
   10370:	fcf43c23          	sd	a5,-40(s0)
   10374:	fd843783          	ld	a5,-40(s0)
   10378:	0007c783          	lbu	a5,0(a5)
   1037c:	00078713          	mv	a4,a5
   10380:	07800793          	li	a5,120
   10384:	00f70c63          	beq	a4,a5,1039c <strtol+0xfc>
   10388:	fd843783          	ld	a5,-40(s0)
   1038c:	0007c783          	lbu	a5,0(a5)
   10390:	00078713          	mv	a4,a5
   10394:	05800793          	li	a5,88
   10398:	00f71e63          	bne	a4,a5,103b4 <strtol+0x114>
   1039c:	01000793          	li	a5,16
   103a0:	faf42e23          	sw	a5,-68(s0)
   103a4:	fd843783          	ld	a5,-40(s0)
   103a8:	00178793          	addi	a5,a5,1
   103ac:	fcf43c23          	sd	a5,-40(s0)
   103b0:	0180006f          	j	103c8 <strtol+0x128>
   103b4:	00800793          	li	a5,8
   103b8:	faf42e23          	sw	a5,-68(s0)
   103bc:	00c0006f          	j	103c8 <strtol+0x128>
   103c0:	00a00793          	li	a5,10
   103c4:	faf42e23          	sw	a5,-68(s0)
   103c8:	fd843783          	ld	a5,-40(s0)
   103cc:	0007c783          	lbu	a5,0(a5)
   103d0:	00078713          	mv	a4,a5
   103d4:	02f00793          	li	a5,47
   103d8:	02e7f863          	bgeu	a5,a4,10408 <strtol+0x168>
   103dc:	fd843783          	ld	a5,-40(s0)
   103e0:	0007c783          	lbu	a5,0(a5)
   103e4:	00078713          	mv	a4,a5
   103e8:	03900793          	li	a5,57
   103ec:	00e7ee63          	bltu	a5,a4,10408 <strtol+0x168>
   103f0:	fd843783          	ld	a5,-40(s0)
   103f4:	0007c783          	lbu	a5,0(a5)
   103f8:	0007879b          	sext.w	a5,a5
   103fc:	fd07879b          	addiw	a5,a5,-48
   10400:	fcf42a23          	sw	a5,-44(s0)
   10404:	0800006f          	j	10484 <strtol+0x1e4>
   10408:	fd843783          	ld	a5,-40(s0)
   1040c:	0007c783          	lbu	a5,0(a5)
   10410:	00078713          	mv	a4,a5
   10414:	06000793          	li	a5,96
   10418:	02e7f863          	bgeu	a5,a4,10448 <strtol+0x1a8>
   1041c:	fd843783          	ld	a5,-40(s0)
   10420:	0007c783          	lbu	a5,0(a5)
   10424:	00078713          	mv	a4,a5
   10428:	07a00793          	li	a5,122
   1042c:	00e7ee63          	bltu	a5,a4,10448 <strtol+0x1a8>
   10430:	fd843783          	ld	a5,-40(s0)
   10434:	0007c783          	lbu	a5,0(a5)
   10438:	0007879b          	sext.w	a5,a5
   1043c:	fa97879b          	addiw	a5,a5,-87
   10440:	fcf42a23          	sw	a5,-44(s0)
   10444:	0400006f          	j	10484 <strtol+0x1e4>
   10448:	fd843783          	ld	a5,-40(s0)
   1044c:	0007c783          	lbu	a5,0(a5)
   10450:	00078713          	mv	a4,a5
   10454:	04000793          	li	a5,64
   10458:	06e7f863          	bgeu	a5,a4,104c8 <strtol+0x228>
   1045c:	fd843783          	ld	a5,-40(s0)
   10460:	0007c783          	lbu	a5,0(a5)
   10464:	00078713          	mv	a4,a5
   10468:	05a00793          	li	a5,90
   1046c:	04e7ee63          	bltu	a5,a4,104c8 <strtol+0x228>
   10470:	fd843783          	ld	a5,-40(s0)
   10474:	0007c783          	lbu	a5,0(a5)
   10478:	0007879b          	sext.w	a5,a5
   1047c:	fc97879b          	addiw	a5,a5,-55
   10480:	fcf42a23          	sw	a5,-44(s0)
   10484:	fd442783          	lw	a5,-44(s0)
   10488:	00078713          	mv	a4,a5
   1048c:	fbc42783          	lw	a5,-68(s0)
   10490:	0007071b          	sext.w	a4,a4
   10494:	0007879b          	sext.w	a5,a5
   10498:	02f75663          	bge	a4,a5,104c4 <strtol+0x224>
   1049c:	fbc42703          	lw	a4,-68(s0)
   104a0:	fe843783          	ld	a5,-24(s0)
   104a4:	02f70733          	mul	a4,a4,a5
   104a8:	fd442783          	lw	a5,-44(s0)
   104ac:	00f707b3          	add	a5,a4,a5
   104b0:	fef43423          	sd	a5,-24(s0)
   104b4:	fd843783          	ld	a5,-40(s0)
   104b8:	00178793          	addi	a5,a5,1
   104bc:	fcf43c23          	sd	a5,-40(s0)
   104c0:	f09ff06f          	j	103c8 <strtol+0x128>
   104c4:	00000013          	nop
   104c8:	fc043783          	ld	a5,-64(s0)
   104cc:	00078863          	beqz	a5,104dc <strtol+0x23c>
   104d0:	fc043783          	ld	a5,-64(s0)
   104d4:	fd843703          	ld	a4,-40(s0)
   104d8:	00e7b023          	sd	a4,0(a5)
   104dc:	fe744783          	lbu	a5,-25(s0)
   104e0:	0ff7f793          	zext.b	a5,a5
   104e4:	00078863          	beqz	a5,104f4 <strtol+0x254>
   104e8:	fe843783          	ld	a5,-24(s0)
   104ec:	40f007b3          	neg	a5,a5
   104f0:	0080006f          	j	104f8 <strtol+0x258>
   104f4:	fe843783          	ld	a5,-24(s0)
   104f8:	00078513          	mv	a0,a5
   104fc:	04813083          	ld	ra,72(sp)
   10500:	04013403          	ld	s0,64(sp)
   10504:	05010113          	addi	sp,sp,80
   10508:	00008067          	ret

000000000001050c <puts_wo_nl>:
   1050c:	fd010113          	addi	sp,sp,-48
   10510:	02113423          	sd	ra,40(sp)
   10514:	02813023          	sd	s0,32(sp)
   10518:	03010413          	addi	s0,sp,48
   1051c:	fca43c23          	sd	a0,-40(s0)
   10520:	fcb43823          	sd	a1,-48(s0)
   10524:	fd043783          	ld	a5,-48(s0)
   10528:	00079863          	bnez	a5,10538 <puts_wo_nl+0x2c>
   1052c:	00001797          	auipc	a5,0x1
   10530:	c9478793          	addi	a5,a5,-876 # 111c0 <printf+0x134>
   10534:	fcf43823          	sd	a5,-48(s0)
   10538:	fd043783          	ld	a5,-48(s0)
   1053c:	fef43423          	sd	a5,-24(s0)
   10540:	0240006f          	j	10564 <puts_wo_nl+0x58>
   10544:	fe843783          	ld	a5,-24(s0)
   10548:	00178713          	addi	a4,a5,1
   1054c:	fee43423          	sd	a4,-24(s0)
   10550:	0007c783          	lbu	a5,0(a5)
   10554:	0007871b          	sext.w	a4,a5
   10558:	fd843783          	ld	a5,-40(s0)
   1055c:	00070513          	mv	a0,a4
   10560:	000780e7          	jalr	a5
   10564:	fe843783          	ld	a5,-24(s0)
   10568:	0007c783          	lbu	a5,0(a5)
   1056c:	fc079ce3          	bnez	a5,10544 <puts_wo_nl+0x38>
   10570:	fe843703          	ld	a4,-24(s0)
   10574:	fd043783          	ld	a5,-48(s0)
   10578:	40f707b3          	sub	a5,a4,a5
   1057c:	0007879b          	sext.w	a5,a5
   10580:	00078513          	mv	a0,a5
   10584:	02813083          	ld	ra,40(sp)
   10588:	02013403          	ld	s0,32(sp)
   1058c:	03010113          	addi	sp,sp,48
   10590:	00008067          	ret

0000000000010594 <print_dec_int>:
   10594:	f9010113          	addi	sp,sp,-112
   10598:	06113423          	sd	ra,104(sp)
   1059c:	06813023          	sd	s0,96(sp)
   105a0:	07010413          	addi	s0,sp,112
   105a4:	faa43423          	sd	a0,-88(s0)
   105a8:	fab43023          	sd	a1,-96(s0)
   105ac:	00060793          	mv	a5,a2
   105b0:	f8d43823          	sd	a3,-112(s0)
   105b4:	f8f40fa3          	sb	a5,-97(s0)
   105b8:	f9f44783          	lbu	a5,-97(s0)
   105bc:	0ff7f793          	zext.b	a5,a5
   105c0:	02078663          	beqz	a5,105ec <print_dec_int+0x58>
   105c4:	fa043703          	ld	a4,-96(s0)
   105c8:	fff00793          	li	a5,-1
   105cc:	03f79793          	slli	a5,a5,0x3f
   105d0:	00f71e63          	bne	a4,a5,105ec <print_dec_int+0x58>
   105d4:	00001597          	auipc	a1,0x1
   105d8:	bf458593          	addi	a1,a1,-1036 # 111c8 <printf+0x13c>
   105dc:	fa843503          	ld	a0,-88(s0)
   105e0:	f2dff0ef          	jal	1050c <puts_wo_nl>
   105e4:	00050793          	mv	a5,a0
   105e8:	2a00006f          	j	10888 <print_dec_int+0x2f4>
   105ec:	f9043783          	ld	a5,-112(s0)
   105f0:	00c7a783          	lw	a5,12(a5)
   105f4:	00079a63          	bnez	a5,10608 <print_dec_int+0x74>
   105f8:	fa043783          	ld	a5,-96(s0)
   105fc:	00079663          	bnez	a5,10608 <print_dec_int+0x74>
   10600:	00000793          	li	a5,0
   10604:	2840006f          	j	10888 <print_dec_int+0x2f4>
   10608:	fe0407a3          	sb	zero,-17(s0)
   1060c:	f9f44783          	lbu	a5,-97(s0)
   10610:	0ff7f793          	zext.b	a5,a5
   10614:	02078063          	beqz	a5,10634 <print_dec_int+0xa0>
   10618:	fa043783          	ld	a5,-96(s0)
   1061c:	0007dc63          	bgez	a5,10634 <print_dec_int+0xa0>
   10620:	00100793          	li	a5,1
   10624:	fef407a3          	sb	a5,-17(s0)
   10628:	fa043783          	ld	a5,-96(s0)
   1062c:	40f007b3          	neg	a5,a5
   10630:	faf43023          	sd	a5,-96(s0)
   10634:	fe042423          	sw	zero,-24(s0)
   10638:	f9f44783          	lbu	a5,-97(s0)
   1063c:	0ff7f793          	zext.b	a5,a5
   10640:	02078863          	beqz	a5,10670 <print_dec_int+0xdc>
   10644:	fef44783          	lbu	a5,-17(s0)
   10648:	0ff7f793          	zext.b	a5,a5
   1064c:	00079e63          	bnez	a5,10668 <print_dec_int+0xd4>
   10650:	f9043783          	ld	a5,-112(s0)
   10654:	0057c783          	lbu	a5,5(a5)
   10658:	00079863          	bnez	a5,10668 <print_dec_int+0xd4>
   1065c:	f9043783          	ld	a5,-112(s0)
   10660:	0047c783          	lbu	a5,4(a5)
   10664:	00078663          	beqz	a5,10670 <print_dec_int+0xdc>
   10668:	00100793          	li	a5,1
   1066c:	0080006f          	j	10674 <print_dec_int+0xe0>
   10670:	00000793          	li	a5,0
   10674:	fcf40ba3          	sb	a5,-41(s0)
   10678:	fd744783          	lbu	a5,-41(s0)
   1067c:	0017f793          	andi	a5,a5,1
   10680:	fcf40ba3          	sb	a5,-41(s0)
   10684:	fa043703          	ld	a4,-96(s0)
   10688:	00a00793          	li	a5,10
   1068c:	02f777b3          	remu	a5,a4,a5
   10690:	0ff7f713          	zext.b	a4,a5
   10694:	fe842783          	lw	a5,-24(s0)
   10698:	0017869b          	addiw	a3,a5,1
   1069c:	fed42423          	sw	a3,-24(s0)
   106a0:	0307071b          	addiw	a4,a4,48
   106a4:	0ff77713          	zext.b	a4,a4
   106a8:	ff078793          	addi	a5,a5,-16
   106ac:	008787b3          	add	a5,a5,s0
   106b0:	fce78423          	sb	a4,-56(a5)
   106b4:	fa043703          	ld	a4,-96(s0)
   106b8:	00a00793          	li	a5,10
   106bc:	02f757b3          	divu	a5,a4,a5
   106c0:	faf43023          	sd	a5,-96(s0)
   106c4:	fa043783          	ld	a5,-96(s0)
   106c8:	fa079ee3          	bnez	a5,10684 <print_dec_int+0xf0>
   106cc:	f9043783          	ld	a5,-112(s0)
   106d0:	00c7a783          	lw	a5,12(a5)
   106d4:	00078713          	mv	a4,a5
   106d8:	fff00793          	li	a5,-1
   106dc:	02f71063          	bne	a4,a5,106fc <print_dec_int+0x168>
   106e0:	f9043783          	ld	a5,-112(s0)
   106e4:	0037c783          	lbu	a5,3(a5)
   106e8:	00078a63          	beqz	a5,106fc <print_dec_int+0x168>
   106ec:	f9043783          	ld	a5,-112(s0)
   106f0:	0087a703          	lw	a4,8(a5)
   106f4:	f9043783          	ld	a5,-112(s0)
   106f8:	00e7a623          	sw	a4,12(a5)
   106fc:	fe042223          	sw	zero,-28(s0)
   10700:	f9043783          	ld	a5,-112(s0)
   10704:	0087a703          	lw	a4,8(a5)
   10708:	fe842783          	lw	a5,-24(s0)
   1070c:	fcf42823          	sw	a5,-48(s0)
   10710:	f9043783          	ld	a5,-112(s0)
   10714:	00c7a783          	lw	a5,12(a5)
   10718:	fcf42623          	sw	a5,-52(s0)
   1071c:	fd042783          	lw	a5,-48(s0)
   10720:	00078593          	mv	a1,a5
   10724:	fcc42783          	lw	a5,-52(s0)
   10728:	00078613          	mv	a2,a5
   1072c:	0006069b          	sext.w	a3,a2
   10730:	0005879b          	sext.w	a5,a1
   10734:	00f6d463          	bge	a3,a5,1073c <print_dec_int+0x1a8>
   10738:	00058613          	mv	a2,a1
   1073c:	0006079b          	sext.w	a5,a2
   10740:	40f707bb          	subw	a5,a4,a5
   10744:	0007871b          	sext.w	a4,a5
   10748:	fd744783          	lbu	a5,-41(s0)
   1074c:	0007879b          	sext.w	a5,a5
   10750:	40f707bb          	subw	a5,a4,a5
   10754:	fef42023          	sw	a5,-32(s0)
   10758:	0280006f          	j	10780 <print_dec_int+0x1ec>
   1075c:	fa843783          	ld	a5,-88(s0)
   10760:	02000513          	li	a0,32
   10764:	000780e7          	jalr	a5
   10768:	fe442783          	lw	a5,-28(s0)
   1076c:	0017879b          	addiw	a5,a5,1
   10770:	fef42223          	sw	a5,-28(s0)
   10774:	fe042783          	lw	a5,-32(s0)
   10778:	fff7879b          	addiw	a5,a5,-1
   1077c:	fef42023          	sw	a5,-32(s0)
   10780:	fe042783          	lw	a5,-32(s0)
   10784:	0007879b          	sext.w	a5,a5
   10788:	fcf04ae3          	bgtz	a5,1075c <print_dec_int+0x1c8>
   1078c:	fd744783          	lbu	a5,-41(s0)
   10790:	0ff7f793          	zext.b	a5,a5
   10794:	04078463          	beqz	a5,107dc <print_dec_int+0x248>
   10798:	fef44783          	lbu	a5,-17(s0)
   1079c:	0ff7f793          	zext.b	a5,a5
   107a0:	00078663          	beqz	a5,107ac <print_dec_int+0x218>
   107a4:	02d00793          	li	a5,45
   107a8:	01c0006f          	j	107c4 <print_dec_int+0x230>
   107ac:	f9043783          	ld	a5,-112(s0)
   107b0:	0057c783          	lbu	a5,5(a5)
   107b4:	00078663          	beqz	a5,107c0 <print_dec_int+0x22c>
   107b8:	02b00793          	li	a5,43
   107bc:	0080006f          	j	107c4 <print_dec_int+0x230>
   107c0:	02000793          	li	a5,32
   107c4:	fa843703          	ld	a4,-88(s0)
   107c8:	00078513          	mv	a0,a5
   107cc:	000700e7          	jalr	a4
   107d0:	fe442783          	lw	a5,-28(s0)
   107d4:	0017879b          	addiw	a5,a5,1
   107d8:	fef42223          	sw	a5,-28(s0)
   107dc:	fe842783          	lw	a5,-24(s0)
   107e0:	fcf42e23          	sw	a5,-36(s0)
   107e4:	0280006f          	j	1080c <print_dec_int+0x278>
   107e8:	fa843783          	ld	a5,-88(s0)
   107ec:	03000513          	li	a0,48
   107f0:	000780e7          	jalr	a5
   107f4:	fe442783          	lw	a5,-28(s0)
   107f8:	0017879b          	addiw	a5,a5,1
   107fc:	fef42223          	sw	a5,-28(s0)
   10800:	fdc42783          	lw	a5,-36(s0)
   10804:	0017879b          	addiw	a5,a5,1
   10808:	fcf42e23          	sw	a5,-36(s0)
   1080c:	f9043783          	ld	a5,-112(s0)
   10810:	00c7a703          	lw	a4,12(a5)
   10814:	fd744783          	lbu	a5,-41(s0)
   10818:	0007879b          	sext.w	a5,a5
   1081c:	40f707bb          	subw	a5,a4,a5
   10820:	0007871b          	sext.w	a4,a5
   10824:	fdc42783          	lw	a5,-36(s0)
   10828:	0007879b          	sext.w	a5,a5
   1082c:	fae7cee3          	blt	a5,a4,107e8 <print_dec_int+0x254>
   10830:	fe842783          	lw	a5,-24(s0)
   10834:	fff7879b          	addiw	a5,a5,-1
   10838:	fcf42c23          	sw	a5,-40(s0)
   1083c:	03c0006f          	j	10878 <print_dec_int+0x2e4>
   10840:	fd842783          	lw	a5,-40(s0)
   10844:	ff078793          	addi	a5,a5,-16
   10848:	008787b3          	add	a5,a5,s0
   1084c:	fc87c783          	lbu	a5,-56(a5)
   10850:	0007871b          	sext.w	a4,a5
   10854:	fa843783          	ld	a5,-88(s0)
   10858:	00070513          	mv	a0,a4
   1085c:	000780e7          	jalr	a5
   10860:	fe442783          	lw	a5,-28(s0)
   10864:	0017879b          	addiw	a5,a5,1
   10868:	fef42223          	sw	a5,-28(s0)
   1086c:	fd842783          	lw	a5,-40(s0)
   10870:	fff7879b          	addiw	a5,a5,-1
   10874:	fcf42c23          	sw	a5,-40(s0)
   10878:	fd842783          	lw	a5,-40(s0)
   1087c:	0007879b          	sext.w	a5,a5
   10880:	fc07d0e3          	bgez	a5,10840 <print_dec_int+0x2ac>
   10884:	fe442783          	lw	a5,-28(s0)
   10888:	00078513          	mv	a0,a5
   1088c:	06813083          	ld	ra,104(sp)
   10890:	06013403          	ld	s0,96(sp)
   10894:	07010113          	addi	sp,sp,112
   10898:	00008067          	ret

000000000001089c <vprintfmt>:
   1089c:	f4010113          	addi	sp,sp,-192
   108a0:	0a113c23          	sd	ra,184(sp)
   108a4:	0a813823          	sd	s0,176(sp)
   108a8:	0c010413          	addi	s0,sp,192
   108ac:	f4a43c23          	sd	a0,-168(s0)
   108b0:	f4b43823          	sd	a1,-176(s0)
   108b4:	f4c43423          	sd	a2,-184(s0)
   108b8:	f8043023          	sd	zero,-128(s0)
   108bc:	f8043423          	sd	zero,-120(s0)
   108c0:	fe042623          	sw	zero,-20(s0)
   108c4:	7a40006f          	j	11068 <vprintfmt+0x7cc>
   108c8:	f8044783          	lbu	a5,-128(s0)
   108cc:	72078e63          	beqz	a5,11008 <vprintfmt+0x76c>
   108d0:	f5043783          	ld	a5,-176(s0)
   108d4:	0007c783          	lbu	a5,0(a5)
   108d8:	00078713          	mv	a4,a5
   108dc:	02300793          	li	a5,35
   108e0:	00f71863          	bne	a4,a5,108f0 <vprintfmt+0x54>
   108e4:	00100793          	li	a5,1
   108e8:	f8f40123          	sb	a5,-126(s0)
   108ec:	7700006f          	j	1105c <vprintfmt+0x7c0>
   108f0:	f5043783          	ld	a5,-176(s0)
   108f4:	0007c783          	lbu	a5,0(a5)
   108f8:	00078713          	mv	a4,a5
   108fc:	03000793          	li	a5,48
   10900:	00f71863          	bne	a4,a5,10910 <vprintfmt+0x74>
   10904:	00100793          	li	a5,1
   10908:	f8f401a3          	sb	a5,-125(s0)
   1090c:	7500006f          	j	1105c <vprintfmt+0x7c0>
   10910:	f5043783          	ld	a5,-176(s0)
   10914:	0007c783          	lbu	a5,0(a5)
   10918:	00078713          	mv	a4,a5
   1091c:	06c00793          	li	a5,108
   10920:	04f70063          	beq	a4,a5,10960 <vprintfmt+0xc4>
   10924:	f5043783          	ld	a5,-176(s0)
   10928:	0007c783          	lbu	a5,0(a5)
   1092c:	00078713          	mv	a4,a5
   10930:	07a00793          	li	a5,122
   10934:	02f70663          	beq	a4,a5,10960 <vprintfmt+0xc4>
   10938:	f5043783          	ld	a5,-176(s0)
   1093c:	0007c783          	lbu	a5,0(a5)
   10940:	00078713          	mv	a4,a5
   10944:	07400793          	li	a5,116
   10948:	00f70c63          	beq	a4,a5,10960 <vprintfmt+0xc4>
   1094c:	f5043783          	ld	a5,-176(s0)
   10950:	0007c783          	lbu	a5,0(a5)
   10954:	00078713          	mv	a4,a5
   10958:	06a00793          	li	a5,106
   1095c:	00f71863          	bne	a4,a5,1096c <vprintfmt+0xd0>
   10960:	00100793          	li	a5,1
   10964:	f8f400a3          	sb	a5,-127(s0)
   10968:	6f40006f          	j	1105c <vprintfmt+0x7c0>
   1096c:	f5043783          	ld	a5,-176(s0)
   10970:	0007c783          	lbu	a5,0(a5)
   10974:	00078713          	mv	a4,a5
   10978:	02b00793          	li	a5,43
   1097c:	00f71863          	bne	a4,a5,1098c <vprintfmt+0xf0>
   10980:	00100793          	li	a5,1
   10984:	f8f402a3          	sb	a5,-123(s0)
   10988:	6d40006f          	j	1105c <vprintfmt+0x7c0>
   1098c:	f5043783          	ld	a5,-176(s0)
   10990:	0007c783          	lbu	a5,0(a5)
   10994:	00078713          	mv	a4,a5
   10998:	02000793          	li	a5,32
   1099c:	00f71863          	bne	a4,a5,109ac <vprintfmt+0x110>
   109a0:	00100793          	li	a5,1
   109a4:	f8f40223          	sb	a5,-124(s0)
   109a8:	6b40006f          	j	1105c <vprintfmt+0x7c0>
   109ac:	f5043783          	ld	a5,-176(s0)
   109b0:	0007c783          	lbu	a5,0(a5)
   109b4:	00078713          	mv	a4,a5
   109b8:	02a00793          	li	a5,42
   109bc:	00f71e63          	bne	a4,a5,109d8 <vprintfmt+0x13c>
   109c0:	f4843783          	ld	a5,-184(s0)
   109c4:	00878713          	addi	a4,a5,8
   109c8:	f4e43423          	sd	a4,-184(s0)
   109cc:	0007a783          	lw	a5,0(a5)
   109d0:	f8f42423          	sw	a5,-120(s0)
   109d4:	6880006f          	j	1105c <vprintfmt+0x7c0>
   109d8:	f5043783          	ld	a5,-176(s0)
   109dc:	0007c783          	lbu	a5,0(a5)
   109e0:	00078713          	mv	a4,a5
   109e4:	03000793          	li	a5,48
   109e8:	04e7f663          	bgeu	a5,a4,10a34 <vprintfmt+0x198>
   109ec:	f5043783          	ld	a5,-176(s0)
   109f0:	0007c783          	lbu	a5,0(a5)
   109f4:	00078713          	mv	a4,a5
   109f8:	03900793          	li	a5,57
   109fc:	02e7ec63          	bltu	a5,a4,10a34 <vprintfmt+0x198>
   10a00:	f5043783          	ld	a5,-176(s0)
   10a04:	f5040713          	addi	a4,s0,-176
   10a08:	00a00613          	li	a2,10
   10a0c:	00070593          	mv	a1,a4
   10a10:	00078513          	mv	a0,a5
   10a14:	88dff0ef          	jal	102a0 <strtol>
   10a18:	00050793          	mv	a5,a0
   10a1c:	0007879b          	sext.w	a5,a5
   10a20:	f8f42423          	sw	a5,-120(s0)
   10a24:	f5043783          	ld	a5,-176(s0)
   10a28:	fff78793          	addi	a5,a5,-1
   10a2c:	f4f43823          	sd	a5,-176(s0)
   10a30:	62c0006f          	j	1105c <vprintfmt+0x7c0>
   10a34:	f5043783          	ld	a5,-176(s0)
   10a38:	0007c783          	lbu	a5,0(a5)
   10a3c:	00078713          	mv	a4,a5
   10a40:	02e00793          	li	a5,46
   10a44:	06f71863          	bne	a4,a5,10ab4 <vprintfmt+0x218>
   10a48:	f5043783          	ld	a5,-176(s0)
   10a4c:	00178793          	addi	a5,a5,1
   10a50:	f4f43823          	sd	a5,-176(s0)
   10a54:	f5043783          	ld	a5,-176(s0)
   10a58:	0007c783          	lbu	a5,0(a5)
   10a5c:	00078713          	mv	a4,a5
   10a60:	02a00793          	li	a5,42
   10a64:	00f71e63          	bne	a4,a5,10a80 <vprintfmt+0x1e4>
   10a68:	f4843783          	ld	a5,-184(s0)
   10a6c:	00878713          	addi	a4,a5,8
   10a70:	f4e43423          	sd	a4,-184(s0)
   10a74:	0007a783          	lw	a5,0(a5)
   10a78:	f8f42623          	sw	a5,-116(s0)
   10a7c:	5e00006f          	j	1105c <vprintfmt+0x7c0>
   10a80:	f5043783          	ld	a5,-176(s0)
   10a84:	f5040713          	addi	a4,s0,-176
   10a88:	00a00613          	li	a2,10
   10a8c:	00070593          	mv	a1,a4
   10a90:	00078513          	mv	a0,a5
   10a94:	80dff0ef          	jal	102a0 <strtol>
   10a98:	00050793          	mv	a5,a0
   10a9c:	0007879b          	sext.w	a5,a5
   10aa0:	f8f42623          	sw	a5,-116(s0)
   10aa4:	f5043783          	ld	a5,-176(s0)
   10aa8:	fff78793          	addi	a5,a5,-1
   10aac:	f4f43823          	sd	a5,-176(s0)
   10ab0:	5ac0006f          	j	1105c <vprintfmt+0x7c0>
   10ab4:	f5043783          	ld	a5,-176(s0)
   10ab8:	0007c783          	lbu	a5,0(a5)
   10abc:	00078713          	mv	a4,a5
   10ac0:	07800793          	li	a5,120
   10ac4:	02f70663          	beq	a4,a5,10af0 <vprintfmt+0x254>
   10ac8:	f5043783          	ld	a5,-176(s0)
   10acc:	0007c783          	lbu	a5,0(a5)
   10ad0:	00078713          	mv	a4,a5
   10ad4:	05800793          	li	a5,88
   10ad8:	00f70c63          	beq	a4,a5,10af0 <vprintfmt+0x254>
   10adc:	f5043783          	ld	a5,-176(s0)
   10ae0:	0007c783          	lbu	a5,0(a5)
   10ae4:	00078713          	mv	a4,a5
   10ae8:	07000793          	li	a5,112
   10aec:	30f71263          	bne	a4,a5,10df0 <vprintfmt+0x554>
   10af0:	f5043783          	ld	a5,-176(s0)
   10af4:	0007c783          	lbu	a5,0(a5)
   10af8:	00078713          	mv	a4,a5
   10afc:	07000793          	li	a5,112
   10b00:	00f70663          	beq	a4,a5,10b0c <vprintfmt+0x270>
   10b04:	f8144783          	lbu	a5,-127(s0)
   10b08:	00078663          	beqz	a5,10b14 <vprintfmt+0x278>
   10b0c:	00100793          	li	a5,1
   10b10:	0080006f          	j	10b18 <vprintfmt+0x27c>
   10b14:	00000793          	li	a5,0
   10b18:	faf403a3          	sb	a5,-89(s0)
   10b1c:	fa744783          	lbu	a5,-89(s0)
   10b20:	0017f793          	andi	a5,a5,1
   10b24:	faf403a3          	sb	a5,-89(s0)
   10b28:	fa744783          	lbu	a5,-89(s0)
   10b2c:	0ff7f793          	zext.b	a5,a5
   10b30:	00078c63          	beqz	a5,10b48 <vprintfmt+0x2ac>
   10b34:	f4843783          	ld	a5,-184(s0)
   10b38:	00878713          	addi	a4,a5,8
   10b3c:	f4e43423          	sd	a4,-184(s0)
   10b40:	0007b783          	ld	a5,0(a5)
   10b44:	01c0006f          	j	10b60 <vprintfmt+0x2c4>
   10b48:	f4843783          	ld	a5,-184(s0)
   10b4c:	00878713          	addi	a4,a5,8
   10b50:	f4e43423          	sd	a4,-184(s0)
   10b54:	0007a783          	lw	a5,0(a5)
   10b58:	02079793          	slli	a5,a5,0x20
   10b5c:	0207d793          	srli	a5,a5,0x20
   10b60:	fef43023          	sd	a5,-32(s0)
   10b64:	f8c42783          	lw	a5,-116(s0)
   10b68:	02079463          	bnez	a5,10b90 <vprintfmt+0x2f4>
   10b6c:	fe043783          	ld	a5,-32(s0)
   10b70:	02079063          	bnez	a5,10b90 <vprintfmt+0x2f4>
   10b74:	f5043783          	ld	a5,-176(s0)
   10b78:	0007c783          	lbu	a5,0(a5)
   10b7c:	00078713          	mv	a4,a5
   10b80:	07000793          	li	a5,112
   10b84:	00f70663          	beq	a4,a5,10b90 <vprintfmt+0x2f4>
   10b88:	f8040023          	sb	zero,-128(s0)
   10b8c:	4d00006f          	j	1105c <vprintfmt+0x7c0>
   10b90:	f5043783          	ld	a5,-176(s0)
   10b94:	0007c783          	lbu	a5,0(a5)
   10b98:	00078713          	mv	a4,a5
   10b9c:	07000793          	li	a5,112
   10ba0:	00f70a63          	beq	a4,a5,10bb4 <vprintfmt+0x318>
   10ba4:	f8244783          	lbu	a5,-126(s0)
   10ba8:	00078a63          	beqz	a5,10bbc <vprintfmt+0x320>
   10bac:	fe043783          	ld	a5,-32(s0)
   10bb0:	00078663          	beqz	a5,10bbc <vprintfmt+0x320>
   10bb4:	00100793          	li	a5,1
   10bb8:	0080006f          	j	10bc0 <vprintfmt+0x324>
   10bbc:	00000793          	li	a5,0
   10bc0:	faf40323          	sb	a5,-90(s0)
   10bc4:	fa644783          	lbu	a5,-90(s0)
   10bc8:	0017f793          	andi	a5,a5,1
   10bcc:	faf40323          	sb	a5,-90(s0)
   10bd0:	fc042e23          	sw	zero,-36(s0)
   10bd4:	f5043783          	ld	a5,-176(s0)
   10bd8:	0007c783          	lbu	a5,0(a5)
   10bdc:	00078713          	mv	a4,a5
   10be0:	05800793          	li	a5,88
   10be4:	00f71863          	bne	a4,a5,10bf4 <vprintfmt+0x358>
   10be8:	00000797          	auipc	a5,0x0
   10bec:	5f878793          	addi	a5,a5,1528 # 111e0 <upperxdigits.1>
   10bf0:	00c0006f          	j	10bfc <vprintfmt+0x360>
   10bf4:	00000797          	auipc	a5,0x0
   10bf8:	60478793          	addi	a5,a5,1540 # 111f8 <lowerxdigits.0>
   10bfc:	f8f43c23          	sd	a5,-104(s0)
   10c00:	fe043783          	ld	a5,-32(s0)
   10c04:	00f7f793          	andi	a5,a5,15
   10c08:	f9843703          	ld	a4,-104(s0)
   10c0c:	00f70733          	add	a4,a4,a5
   10c10:	fdc42783          	lw	a5,-36(s0)
   10c14:	0017869b          	addiw	a3,a5,1
   10c18:	fcd42e23          	sw	a3,-36(s0)
   10c1c:	00074703          	lbu	a4,0(a4)
   10c20:	ff078793          	addi	a5,a5,-16
   10c24:	008787b3          	add	a5,a5,s0
   10c28:	f8e78023          	sb	a4,-128(a5)
   10c2c:	fe043783          	ld	a5,-32(s0)
   10c30:	0047d793          	srli	a5,a5,0x4
   10c34:	fef43023          	sd	a5,-32(s0)
   10c38:	fe043783          	ld	a5,-32(s0)
   10c3c:	fc0792e3          	bnez	a5,10c00 <vprintfmt+0x364>
   10c40:	f8c42783          	lw	a5,-116(s0)
   10c44:	00078713          	mv	a4,a5
   10c48:	fff00793          	li	a5,-1
   10c4c:	02f71663          	bne	a4,a5,10c78 <vprintfmt+0x3dc>
   10c50:	f8344783          	lbu	a5,-125(s0)
   10c54:	02078263          	beqz	a5,10c78 <vprintfmt+0x3dc>
   10c58:	f8842703          	lw	a4,-120(s0)
   10c5c:	fa644783          	lbu	a5,-90(s0)
   10c60:	0007879b          	sext.w	a5,a5
   10c64:	0017979b          	slliw	a5,a5,0x1
   10c68:	0007879b          	sext.w	a5,a5
   10c6c:	40f707bb          	subw	a5,a4,a5
   10c70:	0007879b          	sext.w	a5,a5
   10c74:	f8f42623          	sw	a5,-116(s0)
   10c78:	f8842703          	lw	a4,-120(s0)
   10c7c:	fa644783          	lbu	a5,-90(s0)
   10c80:	0007879b          	sext.w	a5,a5
   10c84:	0017979b          	slliw	a5,a5,0x1
   10c88:	0007879b          	sext.w	a5,a5
   10c8c:	40f707bb          	subw	a5,a4,a5
   10c90:	0007871b          	sext.w	a4,a5
   10c94:	fdc42783          	lw	a5,-36(s0)
   10c98:	f8f42a23          	sw	a5,-108(s0)
   10c9c:	f8c42783          	lw	a5,-116(s0)
   10ca0:	f8f42823          	sw	a5,-112(s0)
   10ca4:	f9442783          	lw	a5,-108(s0)
   10ca8:	00078593          	mv	a1,a5
   10cac:	f9042783          	lw	a5,-112(s0)
   10cb0:	00078613          	mv	a2,a5
   10cb4:	0006069b          	sext.w	a3,a2
   10cb8:	0005879b          	sext.w	a5,a1
   10cbc:	00f6d463          	bge	a3,a5,10cc4 <vprintfmt+0x428>
   10cc0:	00058613          	mv	a2,a1
   10cc4:	0006079b          	sext.w	a5,a2
   10cc8:	40f707bb          	subw	a5,a4,a5
   10ccc:	fcf42c23          	sw	a5,-40(s0)
   10cd0:	0280006f          	j	10cf8 <vprintfmt+0x45c>
   10cd4:	f5843783          	ld	a5,-168(s0)
   10cd8:	02000513          	li	a0,32
   10cdc:	000780e7          	jalr	a5
   10ce0:	fec42783          	lw	a5,-20(s0)
   10ce4:	0017879b          	addiw	a5,a5,1
   10ce8:	fef42623          	sw	a5,-20(s0)
   10cec:	fd842783          	lw	a5,-40(s0)
   10cf0:	fff7879b          	addiw	a5,a5,-1
   10cf4:	fcf42c23          	sw	a5,-40(s0)
   10cf8:	fd842783          	lw	a5,-40(s0)
   10cfc:	0007879b          	sext.w	a5,a5
   10d00:	fcf04ae3          	bgtz	a5,10cd4 <vprintfmt+0x438>
   10d04:	fa644783          	lbu	a5,-90(s0)
   10d08:	0ff7f793          	zext.b	a5,a5
   10d0c:	04078463          	beqz	a5,10d54 <vprintfmt+0x4b8>
   10d10:	f5843783          	ld	a5,-168(s0)
   10d14:	03000513          	li	a0,48
   10d18:	000780e7          	jalr	a5
   10d1c:	f5043783          	ld	a5,-176(s0)
   10d20:	0007c783          	lbu	a5,0(a5)
   10d24:	00078713          	mv	a4,a5
   10d28:	05800793          	li	a5,88
   10d2c:	00f71663          	bne	a4,a5,10d38 <vprintfmt+0x49c>
   10d30:	05800793          	li	a5,88
   10d34:	0080006f          	j	10d3c <vprintfmt+0x4a0>
   10d38:	07800793          	li	a5,120
   10d3c:	f5843703          	ld	a4,-168(s0)
   10d40:	00078513          	mv	a0,a5
   10d44:	000700e7          	jalr	a4
   10d48:	fec42783          	lw	a5,-20(s0)
   10d4c:	0027879b          	addiw	a5,a5,2
   10d50:	fef42623          	sw	a5,-20(s0)
   10d54:	fdc42783          	lw	a5,-36(s0)
   10d58:	fcf42a23          	sw	a5,-44(s0)
   10d5c:	0280006f          	j	10d84 <vprintfmt+0x4e8>
   10d60:	f5843783          	ld	a5,-168(s0)
   10d64:	03000513          	li	a0,48
   10d68:	000780e7          	jalr	a5
   10d6c:	fec42783          	lw	a5,-20(s0)
   10d70:	0017879b          	addiw	a5,a5,1
   10d74:	fef42623          	sw	a5,-20(s0)
   10d78:	fd442783          	lw	a5,-44(s0)
   10d7c:	0017879b          	addiw	a5,a5,1
   10d80:	fcf42a23          	sw	a5,-44(s0)
   10d84:	f8c42703          	lw	a4,-116(s0)
   10d88:	fd442783          	lw	a5,-44(s0)
   10d8c:	0007879b          	sext.w	a5,a5
   10d90:	fce7c8e3          	blt	a5,a4,10d60 <vprintfmt+0x4c4>
   10d94:	fdc42783          	lw	a5,-36(s0)
   10d98:	fff7879b          	addiw	a5,a5,-1
   10d9c:	fcf42823          	sw	a5,-48(s0)
   10da0:	03c0006f          	j	10ddc <vprintfmt+0x540>
   10da4:	fd042783          	lw	a5,-48(s0)
   10da8:	ff078793          	addi	a5,a5,-16
   10dac:	008787b3          	add	a5,a5,s0
   10db0:	f807c783          	lbu	a5,-128(a5)
   10db4:	0007871b          	sext.w	a4,a5
   10db8:	f5843783          	ld	a5,-168(s0)
   10dbc:	00070513          	mv	a0,a4
   10dc0:	000780e7          	jalr	a5
   10dc4:	fec42783          	lw	a5,-20(s0)
   10dc8:	0017879b          	addiw	a5,a5,1
   10dcc:	fef42623          	sw	a5,-20(s0)
   10dd0:	fd042783          	lw	a5,-48(s0)
   10dd4:	fff7879b          	addiw	a5,a5,-1
   10dd8:	fcf42823          	sw	a5,-48(s0)
   10ddc:	fd042783          	lw	a5,-48(s0)
   10de0:	0007879b          	sext.w	a5,a5
   10de4:	fc07d0e3          	bgez	a5,10da4 <vprintfmt+0x508>
   10de8:	f8040023          	sb	zero,-128(s0)
   10dec:	2700006f          	j	1105c <vprintfmt+0x7c0>
   10df0:	f5043783          	ld	a5,-176(s0)
   10df4:	0007c783          	lbu	a5,0(a5)
   10df8:	00078713          	mv	a4,a5
   10dfc:	06400793          	li	a5,100
   10e00:	02f70663          	beq	a4,a5,10e2c <vprintfmt+0x590>
   10e04:	f5043783          	ld	a5,-176(s0)
   10e08:	0007c783          	lbu	a5,0(a5)
   10e0c:	00078713          	mv	a4,a5
   10e10:	06900793          	li	a5,105
   10e14:	00f70c63          	beq	a4,a5,10e2c <vprintfmt+0x590>
   10e18:	f5043783          	ld	a5,-176(s0)
   10e1c:	0007c783          	lbu	a5,0(a5)
   10e20:	00078713          	mv	a4,a5
   10e24:	07500793          	li	a5,117
   10e28:	08f71063          	bne	a4,a5,10ea8 <vprintfmt+0x60c>
   10e2c:	f8144783          	lbu	a5,-127(s0)
   10e30:	00078c63          	beqz	a5,10e48 <vprintfmt+0x5ac>
   10e34:	f4843783          	ld	a5,-184(s0)
   10e38:	00878713          	addi	a4,a5,8
   10e3c:	f4e43423          	sd	a4,-184(s0)
   10e40:	0007b783          	ld	a5,0(a5)
   10e44:	0140006f          	j	10e58 <vprintfmt+0x5bc>
   10e48:	f4843783          	ld	a5,-184(s0)
   10e4c:	00878713          	addi	a4,a5,8
   10e50:	f4e43423          	sd	a4,-184(s0)
   10e54:	0007a783          	lw	a5,0(a5)
   10e58:	faf43423          	sd	a5,-88(s0)
   10e5c:	fa843583          	ld	a1,-88(s0)
   10e60:	f5043783          	ld	a5,-176(s0)
   10e64:	0007c783          	lbu	a5,0(a5)
   10e68:	0007871b          	sext.w	a4,a5
   10e6c:	07500793          	li	a5,117
   10e70:	40f707b3          	sub	a5,a4,a5
   10e74:	00f037b3          	snez	a5,a5
   10e78:	0ff7f793          	zext.b	a5,a5
   10e7c:	f8040713          	addi	a4,s0,-128
   10e80:	00070693          	mv	a3,a4
   10e84:	00078613          	mv	a2,a5
   10e88:	f5843503          	ld	a0,-168(s0)
   10e8c:	f08ff0ef          	jal	10594 <print_dec_int>
   10e90:	00050793          	mv	a5,a0
   10e94:	fec42703          	lw	a4,-20(s0)
   10e98:	00f707bb          	addw	a5,a4,a5
   10e9c:	fef42623          	sw	a5,-20(s0)
   10ea0:	f8040023          	sb	zero,-128(s0)
   10ea4:	1b80006f          	j	1105c <vprintfmt+0x7c0>
   10ea8:	f5043783          	ld	a5,-176(s0)
   10eac:	0007c783          	lbu	a5,0(a5)
   10eb0:	00078713          	mv	a4,a5
   10eb4:	06e00793          	li	a5,110
   10eb8:	04f71c63          	bne	a4,a5,10f10 <vprintfmt+0x674>
   10ebc:	f8144783          	lbu	a5,-127(s0)
   10ec0:	02078463          	beqz	a5,10ee8 <vprintfmt+0x64c>
   10ec4:	f4843783          	ld	a5,-184(s0)
   10ec8:	00878713          	addi	a4,a5,8
   10ecc:	f4e43423          	sd	a4,-184(s0)
   10ed0:	0007b783          	ld	a5,0(a5)
   10ed4:	faf43823          	sd	a5,-80(s0)
   10ed8:	fec42703          	lw	a4,-20(s0)
   10edc:	fb043783          	ld	a5,-80(s0)
   10ee0:	00e7b023          	sd	a4,0(a5)
   10ee4:	0240006f          	j	10f08 <vprintfmt+0x66c>
   10ee8:	f4843783          	ld	a5,-184(s0)
   10eec:	00878713          	addi	a4,a5,8
   10ef0:	f4e43423          	sd	a4,-184(s0)
   10ef4:	0007b783          	ld	a5,0(a5)
   10ef8:	faf43c23          	sd	a5,-72(s0)
   10efc:	fb843783          	ld	a5,-72(s0)
   10f00:	fec42703          	lw	a4,-20(s0)
   10f04:	00e7a023          	sw	a4,0(a5)
   10f08:	f8040023          	sb	zero,-128(s0)
   10f0c:	1500006f          	j	1105c <vprintfmt+0x7c0>
   10f10:	f5043783          	ld	a5,-176(s0)
   10f14:	0007c783          	lbu	a5,0(a5)
   10f18:	00078713          	mv	a4,a5
   10f1c:	07300793          	li	a5,115
   10f20:	02f71e63          	bne	a4,a5,10f5c <vprintfmt+0x6c0>
   10f24:	f4843783          	ld	a5,-184(s0)
   10f28:	00878713          	addi	a4,a5,8
   10f2c:	f4e43423          	sd	a4,-184(s0)
   10f30:	0007b783          	ld	a5,0(a5)
   10f34:	fcf43023          	sd	a5,-64(s0)
   10f38:	fc043583          	ld	a1,-64(s0)
   10f3c:	f5843503          	ld	a0,-168(s0)
   10f40:	dccff0ef          	jal	1050c <puts_wo_nl>
   10f44:	00050793          	mv	a5,a0
   10f48:	fec42703          	lw	a4,-20(s0)
   10f4c:	00f707bb          	addw	a5,a4,a5
   10f50:	fef42623          	sw	a5,-20(s0)
   10f54:	f8040023          	sb	zero,-128(s0)
   10f58:	1040006f          	j	1105c <vprintfmt+0x7c0>
   10f5c:	f5043783          	ld	a5,-176(s0)
   10f60:	0007c783          	lbu	a5,0(a5)
   10f64:	00078713          	mv	a4,a5
   10f68:	06300793          	li	a5,99
   10f6c:	02f71e63          	bne	a4,a5,10fa8 <vprintfmt+0x70c>
   10f70:	f4843783          	ld	a5,-184(s0)
   10f74:	00878713          	addi	a4,a5,8
   10f78:	f4e43423          	sd	a4,-184(s0)
   10f7c:	0007a783          	lw	a5,0(a5)
   10f80:	fcf42623          	sw	a5,-52(s0)
   10f84:	fcc42703          	lw	a4,-52(s0)
   10f88:	f5843783          	ld	a5,-168(s0)
   10f8c:	00070513          	mv	a0,a4
   10f90:	000780e7          	jalr	a5
   10f94:	fec42783          	lw	a5,-20(s0)
   10f98:	0017879b          	addiw	a5,a5,1
   10f9c:	fef42623          	sw	a5,-20(s0)
   10fa0:	f8040023          	sb	zero,-128(s0)
   10fa4:	0b80006f          	j	1105c <vprintfmt+0x7c0>
   10fa8:	f5043783          	ld	a5,-176(s0)
   10fac:	0007c783          	lbu	a5,0(a5)
   10fb0:	00078713          	mv	a4,a5
   10fb4:	02500793          	li	a5,37
   10fb8:	02f71263          	bne	a4,a5,10fdc <vprintfmt+0x740>
   10fbc:	f5843783          	ld	a5,-168(s0)
   10fc0:	02500513          	li	a0,37
   10fc4:	000780e7          	jalr	a5
   10fc8:	fec42783          	lw	a5,-20(s0)
   10fcc:	0017879b          	addiw	a5,a5,1
   10fd0:	fef42623          	sw	a5,-20(s0)
   10fd4:	f8040023          	sb	zero,-128(s0)
   10fd8:	0840006f          	j	1105c <vprintfmt+0x7c0>
   10fdc:	f5043783          	ld	a5,-176(s0)
   10fe0:	0007c783          	lbu	a5,0(a5)
   10fe4:	0007871b          	sext.w	a4,a5
   10fe8:	f5843783          	ld	a5,-168(s0)
   10fec:	00070513          	mv	a0,a4
   10ff0:	000780e7          	jalr	a5
   10ff4:	fec42783          	lw	a5,-20(s0)
   10ff8:	0017879b          	addiw	a5,a5,1
   10ffc:	fef42623          	sw	a5,-20(s0)
   11000:	f8040023          	sb	zero,-128(s0)
   11004:	0580006f          	j	1105c <vprintfmt+0x7c0>
   11008:	f5043783          	ld	a5,-176(s0)
   1100c:	0007c783          	lbu	a5,0(a5)
   11010:	00078713          	mv	a4,a5
   11014:	02500793          	li	a5,37
   11018:	02f71063          	bne	a4,a5,11038 <vprintfmt+0x79c>
   1101c:	f8043023          	sd	zero,-128(s0)
   11020:	f8043423          	sd	zero,-120(s0)
   11024:	00100793          	li	a5,1
   11028:	f8f40023          	sb	a5,-128(s0)
   1102c:	fff00793          	li	a5,-1
   11030:	f8f42623          	sw	a5,-116(s0)
   11034:	0280006f          	j	1105c <vprintfmt+0x7c0>
   11038:	f5043783          	ld	a5,-176(s0)
   1103c:	0007c783          	lbu	a5,0(a5)
   11040:	0007871b          	sext.w	a4,a5
   11044:	f5843783          	ld	a5,-168(s0)
   11048:	00070513          	mv	a0,a4
   1104c:	000780e7          	jalr	a5
   11050:	fec42783          	lw	a5,-20(s0)
   11054:	0017879b          	addiw	a5,a5,1
   11058:	fef42623          	sw	a5,-20(s0)
   1105c:	f5043783          	ld	a5,-176(s0)
   11060:	00178793          	addi	a5,a5,1
   11064:	f4f43823          	sd	a5,-176(s0)
   11068:	f5043783          	ld	a5,-176(s0)
   1106c:	0007c783          	lbu	a5,0(a5)
   11070:	84079ce3          	bnez	a5,108c8 <vprintfmt+0x2c>
   11074:	fec42783          	lw	a5,-20(s0)
   11078:	00078513          	mv	a0,a5
   1107c:	0b813083          	ld	ra,184(sp)
   11080:	0b013403          	ld	s0,176(sp)
   11084:	0c010113          	addi	sp,sp,192
   11088:	00008067          	ret

000000000001108c <printf>:
   1108c:	f8010113          	addi	sp,sp,-128
   11090:	02113c23          	sd	ra,56(sp)
   11094:	02813823          	sd	s0,48(sp)
   11098:	04010413          	addi	s0,sp,64
   1109c:	fca43423          	sd	a0,-56(s0)
   110a0:	00b43423          	sd	a1,8(s0)
   110a4:	00c43823          	sd	a2,16(s0)
   110a8:	00d43c23          	sd	a3,24(s0)
   110ac:	02e43023          	sd	a4,32(s0)
   110b0:	02f43423          	sd	a5,40(s0)
   110b4:	03043823          	sd	a6,48(s0)
   110b8:	03143c23          	sd	a7,56(s0)
   110bc:	fe042623          	sw	zero,-20(s0)
   110c0:	04040793          	addi	a5,s0,64
   110c4:	fcf43023          	sd	a5,-64(s0)
   110c8:	fc043783          	ld	a5,-64(s0)
   110cc:	fc878793          	addi	a5,a5,-56
   110d0:	fcf43823          	sd	a5,-48(s0)
   110d4:	fd043783          	ld	a5,-48(s0)
   110d8:	00078613          	mv	a2,a5
   110dc:	fc843583          	ld	a1,-56(s0)
   110e0:	fffff517          	auipc	a0,0xfffff
   110e4:	0f850513          	addi	a0,a0,248 # 101d8 <putc>
   110e8:	fb4ff0ef          	jal	1089c <vprintfmt>
   110ec:	00050793          	mv	a5,a0
   110f0:	fef42623          	sw	a5,-20(s0)
   110f4:	00100793          	li	a5,1
   110f8:	fef43023          	sd	a5,-32(s0)
   110fc:	00002797          	auipc	a5,0x2
   11100:	f0c78793          	addi	a5,a5,-244 # 13008 <tail>
   11104:	0007a783          	lw	a5,0(a5)
   11108:	0017871b          	addiw	a4,a5,1
   1110c:	0007069b          	sext.w	a3,a4
   11110:	00002717          	auipc	a4,0x2
   11114:	ef870713          	addi	a4,a4,-264 # 13008 <tail>
   11118:	00d72023          	sw	a3,0(a4)
   1111c:	00002717          	auipc	a4,0x2
   11120:	ef470713          	addi	a4,a4,-268 # 13010 <buffer>
   11124:	00f707b3          	add	a5,a4,a5
   11128:	00078023          	sb	zero,0(a5)
   1112c:	00002797          	auipc	a5,0x2
   11130:	edc78793          	addi	a5,a5,-292 # 13008 <tail>
   11134:	0007a603          	lw	a2,0(a5)
   11138:	fe043703          	ld	a4,-32(s0)
   1113c:	00002697          	auipc	a3,0x2
   11140:	ed468693          	addi	a3,a3,-300 # 13010 <buffer>
   11144:	fd843783          	ld	a5,-40(s0)
   11148:	04000893          	li	a7,64
   1114c:	00070513          	mv	a0,a4
   11150:	00068593          	mv	a1,a3
   11154:	00060613          	mv	a2,a2
   11158:	00000073          	ecall
   1115c:	00050793          	mv	a5,a0
   11160:	fcf43c23          	sd	a5,-40(s0)
   11164:	00002797          	auipc	a5,0x2
   11168:	ea478793          	addi	a5,a5,-348 # 13008 <tail>
   1116c:	0007a023          	sw	zero,0(a5)
   11170:	fec42783          	lw	a5,-20(s0)
   11174:	00078513          	mv	a0,a5
   11178:	03813083          	ld	ra,56(sp)
   1117c:	03013403          	ld	s0,48(sp)
   11180:	08010113          	addi	sp,sp,128
   11184:	00008067          	ret
