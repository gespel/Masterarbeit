
dev.elf:	file format elf64-littleriscv

Disassembly of section .text:

0000000040000000 <text_start>:
40000000: 00353023     	sd	gp, 0x0(a0)
40000004: 00153823     	sd	ra, 0x10(a0)
40000008: 00253c23     	sd	sp, 0x18(a0)
4000000c: f100         	sd	s0, 0x20(a0)
4000000e: f504         	sd	s1, 0x28(a0)
40000010: 03253823     	sd	s2, 0x30(a0)
40000014: 03353c23     	sd	s3, 0x38(a0)
40000018: 05453023     	sd	s4, 0x40(a0)
4000001c: 05553423     	sd	s5, 0x48(a0)
40000020: 05653823     	sd	s6, 0x50(a0)
40000024: 05753c23     	sd	s7, 0x58(a0)
40000028: 07853023     	sd	s8, 0x60(a0)
4000002c: 07953423     	sd	s9, 0x68(a0)
40000030: 07a53823     	sd	s10, 0x70(a0)
40000034: 07b53c23     	sd	s11, 0x78(a0)
40000038: 4501         	li	a0, 0x0
4000003a: 8082         	ret

000000004000003c <__dpa_os_restore>:
4000003c: 00053183     	ld	gp, 0x0(a0)
40000040: 01053083     	ld	ra, 0x10(a0)
40000044: 01853103     	ld	sp, 0x18(a0)
40000048: 7100         	ld	s0, 0x20(a0)
4000004a: 7504         	ld	s1, 0x28(a0)
4000004c: 03053903     	ld	s2, 0x30(a0)
40000050: 03853983     	ld	s3, 0x38(a0)
40000054: 04053a03     	ld	s4, 0x40(a0)
40000058: 04853a83     	ld	s5, 0x48(a0)
4000005c: 05053b03     	ld	s6, 0x50(a0)
40000060: 05853b83     	ld	s7, 0x58(a0)
40000064: 06053c03     	ld	s8, 0x60(a0)
40000068: 06853c83     	ld	s9, 0x68(a0)
4000006c: 07053d03     	ld	s10, 0x70(a0)
40000070: 07853d83     	ld	s11, 0x78(a0)
40000074: 4505         	li	a0, 0x1
40000076: 8082         	ret

0000000040000078 <memcpy>:
40000078: 46a1         	li	a3, 0x8
4000007a: 00c508b3     	add	a7, a0, a2
4000007e: 04d66363     	bltu	a2, a3, 0x400000c4 <memcpy+0x4c>
40000082: 00757613     	andi	a2, a0, 0x7
40000086: 0075f693     	andi	a3, a1, 0x7
4000008a: 02d61d63     	bne	a2, a3, 0x400000c4 <memcpy+0x4c>
4000008e: ea31         	bnez	a2, 0x400000e2 <memcpy+0x6a>
40000090: 86aa         	mv	a3, a0
40000092: ff88f713     	andi	a4, a7, -0x8
40000096: 40d70633     	sub	a2, a4, a3
4000009a: 04100793     	li	a5, 0x41
4000009e: 06f65263     	bge	a2, a5, 0x40000102 <memcpy+0x8a>
400000a2: 862e         	mv	a2, a1
400000a4: 87b6         	mv	a5, a3
400000a6: 00e7fb63     	bgeu	a5, a4, 0x400000bc <memcpy+0x44>
400000aa: 620c         	ld	a1, 0x0(a2)
400000ac: 00878693     	addi	a3, a5, 0x8
400000b0: 0621         	addi	a2, a2, 0x8
400000b2: e38c         	sd	a1, 0x0(a5)
400000b4: 87b6         	mv	a5, a3
400000b6: fee6eae3     	bltu	a3, a4, 0x400000aa <memcpy+0x32>
400000ba: a011         	j	0x400000be <memcpy+0x46>
400000bc: 86be         	mv	a3, a5
400000be: 0116e563     	bltu	a3, a7, 0x400000c8 <memcpy+0x50>
400000c2: 8082         	ret
400000c4: 86aa         	mv	a3, a0
400000c6: 862e         	mv	a2, a1
400000c8: ff16fde3     	bgeu	a3, a7, 0x400000c2 <memcpy+0x4a>
400000cc: 40d885b3     	sub	a1, a7, a3
400000d0: 00064703     	lbu	a4, 0x0(a2)
400000d4: 00e68023     	sb	a4, 0x0(a3)
400000d8: 0685         	addi	a3, a3, 0x1
400000da: 15fd         	addi	a1, a1, -0x1
400000dc: 0605         	addi	a2, a2, 0x1
400000de: f9ed         	bnez	a1, 0x400000d0 <memcpy+0x58>
400000e0: b7cd         	j	0x400000c2 <memcpy+0x4a>
400000e2: 00150613     	addi	a2, a0, 0x1
400000e6: 872a         	mv	a4, a0
400000e8: 0005c783     	lbu	a5, 0x0(a1)
400000ec: 00170693     	addi	a3, a4, 0x1
400000f0: 0585         	addi	a1, a1, 0x1
400000f2: 00f70023     	sb	a5, 0x0(a4)
400000f6: 00767793     	andi	a5, a2, 0x7
400000fa: 0605         	addi	a2, a2, 0x1
400000fc: 8736         	mv	a4, a3
400000fe: f7ed         	bnez	a5, 0x400000e8 <memcpy+0x70>
40000100: bf49         	j	0x40000092 <memcpy+0x1a>
40000102: fbf60613     	addi	a2, a2, -0x41
40000106: ff1c77b7     	lui	a5, 0xff1c7
4000010a: 1c778793     	addi	a5, a5, 0x1c7
4000010e: 07b2         	slli	a5, a5, 0xc
40000110: 1c778793     	addi	a5, a5, 0x1c7
40000114: 07b2         	slli	a5, a5, 0xc
40000116: 1c778793     	addi	a5, a5, 0x1c7
4000011a: 07b6         	slli	a5, a5, 0xd
4000011c: 38f78793     	addi	a5, a5, 0x38f
40000120: 02f63633     	mulhu	a2, a2, a5
40000124: 00665793     	srli	a5, a2, 0x6
40000128: fc067613     	andi	a2, a2, -0x40
4000012c: 078e         	slli	a5, a5, 0x3
4000012e: 962e         	add	a2, a2, a1
40000130: 963e         	add	a2, a2, a5
40000132: 04860813     	addi	a6, a2, 0x48
40000136: 619c         	ld	a5, 0x0(a1)
40000138: 0085b283     	ld	t0, 0x8(a1)
4000013c: 0105b303     	ld	t1, 0x10(a1)
40000140: 0185b383     	ld	t2, 0x18(a1)
40000144: 0205be03     	ld	t3, 0x20(a1)
40000148: 0285be83     	ld	t4, 0x28(a1)
4000014c: 0305bf03     	ld	t5, 0x30(a1)
40000150: 0385bf83     	ld	t6, 0x38(a1)
40000154: 04858613     	addi	a2, a1, 0x48
40000158: 61ac         	ld	a1, 0x40(a1)
4000015a: e29c         	sd	a5, 0x0(a3)
4000015c: 0056b423     	sd	t0, 0x8(a3)
40000160: 0066b823     	sd	t1, 0x10(a3)
40000164: 0076bc23     	sd	t2, 0x18(a3)
40000168: 03c6b023     	sd	t3, 0x20(a3)
4000016c: 03d6b423     	sd	t4, 0x28(a3)
40000170: 03e6b823     	sd	t5, 0x30(a3)
40000174: 03f6bc23     	sd	t6, 0x38(a3)
40000178: 04868793     	addi	a5, a3, 0x48
4000017c: e2ac         	sd	a1, 0x40(a3)
4000017e: 86be         	mv	a3, a5
40000180: 85b2         	mv	a1, a2
40000182: fb061ae3     	bne	a2, a6, 0x40000136 <memcpy+0xbe>
40000186: b705         	j	0x400000a6 <memcpy+0x2e>

0000000040000188 <memset>:
40000188: 433d         	li	t1, 0xf
4000018a: 872a         	mv	a4, a0
4000018c: 02c37163     	bgeu	t1, a2, 0x400001ae <memset+0x26>
40000190: 00f77793     	andi	a5, a4, 0xf
40000194: e3c1         	bnez	a5, 0x40000214 <memset+0x8c>
40000196: e1bd         	bnez	a1, 0x400001fc <memset+0x74>
40000198: ff067693     	andi	a3, a2, -0x10
4000019c: 8a3d         	andi	a2, a2, 0xf
4000019e: 96ba         	add	a3, a3, a4
400001a0: e30c         	sd	a1, 0x0(a4)
400001a2: e70c         	sd	a1, 0x8(a4)
400001a4: 0741         	addi	a4, a4, 0x10
400001a6: fed76de3     	bltu	a4, a3, 0x400001a0 <memset+0x18>
400001aa: e211         	bnez	a2, 0x400001ae <memset+0x26>
400001ac: 8082         	ret
400001ae: 40c306b3     	sub	a3, t1, a2
400001b2: 068a         	slli	a3, a3, 0x2
400001b4: 00000297     	auipc	t0, 0x0
400001b8: 9696         	add	a3, a3, t0
400001ba: 00a68067     	jr	0xa(a3)
400001be: 00b70723     	sb	a1, 0xe(a4)
400001c2: 00b706a3     	sb	a1, 0xd(a4)
400001c6: 00b70623     	sb	a1, 0xc(a4)
400001ca: 00b705a3     	sb	a1, 0xb(a4)
400001ce: 00b70523     	sb	a1, 0xa(a4)
400001d2: 00b704a3     	sb	a1, 0x9(a4)
400001d6: 00b70423     	sb	a1, 0x8(a4)
400001da: 00b703a3     	sb	a1, 0x7(a4)
400001de: 00b70323     	sb	a1, 0x6(a4)
400001e2: 00b702a3     	sb	a1, 0x5(a4)
400001e6: 00b70223     	sb	a1, 0x4(a4)
400001ea: 00b701a3     	sb	a1, 0x3(a4)
400001ee: 00b70123     	sb	a1, 0x2(a4)
400001f2: 00b700a3     	sb	a1, 0x1(a4)
400001f6: 00b70023     	sb	a1, 0x0(a4)
400001fa: 8082         	ret
400001fc: 0ff5f593     	zext.b	a1, a1
40000200: 00859693     	slli	a3, a1, 0x8
40000204: 8dd5         	or	a1, a1, a3
40000206: 01059693     	slli	a3, a1, 0x10
4000020a: 8dd5         	or	a1, a1, a3
4000020c: 02059693     	slli	a3, a1, 0x20
40000210: 8dd5         	or	a1, a1, a3
40000212: b759         	j	0x40000198 <memset+0x10>
40000214: 00279693     	slli	a3, a5, 0x2
40000218: 00000297     	auipc	t0, 0x0
4000021c: 9696         	add	a3, a3, t0
4000021e: 8286         	mv	t0, ra
40000220: fa2680e7     	jalr	-0x5e(a3)
40000224: 8096         	mv	ra, t0
40000226: 17c1         	addi	a5, a5, -0x10
40000228: 8f1d         	sub	a4, a4, a5
4000022a: 963e         	add	a2, a2, a5
4000022c: f8c371e3     	bgeu	t1, a2, 0x400001ae <memset+0x26>
40000230: b79d         	j	0x40000196 <memset+0xe>

0000000040000232 <strlen>:
40000232: 00757613     	andi	a2, a0, 0x7
40000236: 85aa         	mv	a1, a0
40000238: e259         	bnez	a2, 0x400002be <strlen+0x8c>
4000023a: 7f7f8637     	lui	a2, 0x7f7f8
4000023e: f7f60613     	addi	a2, a2, -0x81
40000242: 02061693     	slli	a3, a2, 0x20
40000246: 9636         	add	a2, a2, a3
40000248: f01016b7     	lui	a3, 0xf0101
4000024c: 0692         	slli	a3, a3, 0x4
4000024e: 10168693     	addi	a3, a3, 0x101
40000252: 06c2         	slli	a3, a3, 0x10
40000254: 10168693     	addi	a3, a3, 0x101
40000258: 06be         	slli	a3, a3, 0xf
4000025a: 08068693     	addi	a3, a3, 0x80
4000025e: 6198         	ld	a4, 0x0(a1)
40000260: 00c777b3     	and	a5, a4, a2
40000264: 97b2         	add	a5, a5, a2
40000266: 8f5d         	or	a4, a4, a5
40000268: 8f75         	and	a4, a4, a3
4000026a: 05a1         	addi	a1, a1, 0x8
4000026c: fed709e3     	beq	a4, a3, 0x4000025e <strlen+0x2c>
40000270: ff85c603     	lbu	a2, -0x8(a1)
40000274: 40a58533     	sub	a0, a1, a0
40000278: c60d         	beqz	a2, 0x400002a2 <strlen+0x70>
4000027a: ff95c603     	lbu	a2, -0x7(a1)
4000027e: c605         	beqz	a2, 0x400002a6 <strlen+0x74>
40000280: ffa5c603     	lbu	a2, -0x6(a1)
40000284: c21d         	beqz	a2, 0x400002aa <strlen+0x78>
40000286: ffb5c603     	lbu	a2, -0x5(a1)
4000028a: c215         	beqz	a2, 0x400002ae <strlen+0x7c>
4000028c: ffc5c603     	lbu	a2, -0x4(a1)
40000290: c20d         	beqz	a2, 0x400002b2 <strlen+0x80>
40000292: ffd5c603     	lbu	a2, -0x3(a1)
40000296: c205         	beqz	a2, 0x400002b6 <strlen+0x84>
40000298: ffe5c583     	lbu	a1, -0x2(a1)
4000029c: cd99         	beqz	a1, 0x400002ba <strlen+0x88>
4000029e: 157d         	addi	a0, a0, -0x1
400002a0: 8082         	ret
400002a2: 1561         	addi	a0, a0, -0x8
400002a4: 8082         	ret
400002a6: 1565         	addi	a0, a0, -0x7
400002a8: 8082         	ret
400002aa: 1569         	addi	a0, a0, -0x6
400002ac: 8082         	ret
400002ae: 156d         	addi	a0, a0, -0x5
400002b0: 8082         	ret
400002b2: 1571         	addi	a0, a0, -0x4
400002b4: 8082         	ret
400002b6: 1575         	addi	a0, a0, -0x3
400002b8: 8082         	ret
400002ba: 1579         	addi	a0, a0, -0x2
400002bc: 8082         	ret
400002be: 4681         	li	a3, 0x0
400002c0: 00150613     	addi	a2, a0, 0x1
400002c4: 85aa         	mv	a1, a0
400002c6: 0005c703     	lbu	a4, 0x0(a1)
400002ca: cb01         	beqz	a4, 0x400002da <strlen+0xa8>
400002cc: 0585         	addi	a1, a1, 0x1
400002ce: 00d60733     	add	a4, a2, a3
400002d2: 8b1d         	andi	a4, a4, 0x7
400002d4: 0685         	addi	a3, a3, 0x1
400002d6: fb65         	bnez	a4, 0x400002c6 <strlen+0x94>
400002d8: b78d         	j	0x4000023a <strlen+0x8>
400002da: 8536         	mv	a0, a3
400002dc: 8082         	ret

00000000400002de <snprintf>:
400002de: 7175         	addi	sp, sp, -0x90
400002e0: ec86         	sd	ra, 0x58(sp)
400002e2: e8a2         	sd	s0, 0x50(sp)
400002e4: 82b2         	mv	t0, a2
400002e6: 842e         	mv	s0, a1
400002e8: e546         	sd	a7, 0x88(sp)
400002ea: e142         	sd	a6, 0x80(sp)
400002ec: fcbe         	sd	a5, 0x78(sp)
400002ee: f8ba         	sd	a4, 0x70(sp)
400002f0: 1582         	slli	a1, a1, 0x20
400002f2: f4b6         	sd	a3, 0x68(sp)
400002f4: 0005d463     	bgez	a1, 0x400002fc <snprintf+0x1e>
400002f8: 29f01413     	bseti	s0, zero, 0x1f
400002fc: 000205b7     	lui	a1, 0x20
40000300: c42e         	sw	a1, 0x8(sp)
40000302: 00010623     	sb	zero, 0xc(sp)
40000306: 000106a3     	sb	zero, 0xd(sp)
4000030a: 00010723     	sb	zero, 0xe(sp)
4000030e: 000107a3     	sb	zero, 0xf(sp)
40000312: 00000597     	auipc	a1, 0x0
40000316: 03e58593     	addi	a1, a1, 0x3e
4000031a: e82e         	sd	a1, 0x10(sp)
4000031c: ec02         	sd	zero, 0x18(sp)
4000031e: f002         	sd	zero, 0x20(sp)
40000320: f42a         	sd	a0, 0x28(sp)
40000322: 4585         	li	a1, 0x1
40000324: 0ab475b3     	maxu	a1, s0, a1
40000328: 952e         	add	a0, a0, a1
4000032a: 157d         	addi	a0, a0, -0x1
4000032c: f82a         	sd	a0, 0x30(sp)
4000032e: fc02         	sd	zero, 0x38(sp)
40000330: e082         	sd	zero, 0x40(sp)
40000332: 10a8         	addi	a0, sp, 0x68
40000334: e4aa         	sd	a0, 0x48(sp)
40000336: 0028         	addi	a0, sp, 0x8
40000338: 10b0         	addi	a2, sp, 0x68
4000033a: 8596         	mv	a1, t0
4000033c: 028000ef     	jal	0x40000364 <vfprintf>
40000340: c401         	beqz	s0, 0x40000348 <snprintf+0x6a>
40000342: 75a2         	ld	a1, 0x28(sp)
40000344: 00058023     	sb	zero, 0x0(a1)
40000348: 60e6         	ld	ra, 0x58(sp)
4000034a: 6446         	ld	s0, 0x50(sp)
4000034c: 6149         	addi	sp, sp, 0x90
4000034e: 8082         	ret

0000000040000350 <__file_str_put>:
40000350: 7190         	ld	a2, 0x20(a1)
40000352: 7594         	ld	a3, 0x28(a1)
40000354: 00d60763     	beq	a2, a3, 0x40000362 <__file_str_put+0x12>
40000358: 00160693     	addi	a3, a2, 0x1
4000035c: f194         	sd	a3, 0x20(a1)
4000035e: 00a60023     	sb	a0, 0x0(a2)
40000362: 8082         	ret

0000000040000364 <vfprintf>:
40000364: 7111         	addi	sp, sp, -0x100
40000366: fd86         	sd	ra, 0xf8(sp)
40000368: f9a2         	sd	s0, 0xf0(sp)
4000036a: f5a6         	sd	s1, 0xe8(sp)
4000036c: f1ca         	sd	s2, 0xe0(sp)
4000036e: edce         	sd	s3, 0xd8(sp)
40000370: e9d2         	sd	s4, 0xd0(sp)
40000372: e5d6         	sd	s5, 0xc8(sp)
40000374: e1da         	sd	s6, 0xc0(sp)
40000376: fd5e         	sd	s7, 0xb8(sp)
40000378: f962         	sd	s8, 0xb0(sp)
4000037a: f566         	sd	s9, 0xa8(sp)
4000037c: f16a         	sd	s10, 0xa0(sp)
4000037e: ed6e         	sd	s11, 0x98(sp)
40000380: 8a2a         	mv	s4, a0
40000382: 00254503     	lbu	a0, 0x2(a0)
40000386: 8909         	andi	a0, a0, 0x2
40000388: e932         	sd	a2, 0x90(sp)
4000038a: 22050be3     	beqz	a0, 0x40000dc0 <vfprintf+0xa5c>
4000038e: 4b01         	li	s6, 0x0
40000390: 008a3b83     	ld	s7, 0x8(s4)
40000394: 654a         	ld	a0, 0x90(sp)
40000396: e52a         	sd	a0, 0x88(sp)
40000398: 00004517     	auipc	a0, 0x4
4000039c: 1e850513     	addi	a0, a0, 0x1e8
400003a0: f4aa         	sd	a0, 0x68(sp)
400003a2: 10625537     	lui	a0, 0x10625
400003a6: dd350513     	addi	a0, a0, -0x22d
400003aa: 1502         	slli	a0, a0, 0x20
400003ac: e0aa         	sd	a0, 0x40(sp)
400003ae: 51eb8537     	lui	a0, 0x51eb8
400003b2: 51f50513     	addi	a0, a0, 0x51f
400003b6: 1502         	slli	a0, a0, 0x20
400003b8: e4aa         	sd	a0, 0x48(sp)
400003ba: ccccd537     	lui	a0, 0xccccd
400003be: ccd50513     	addi	a0, a0, -0x333
400003c2: 1502         	slli	a0, a0, 0x20
400003c4: e8aa         	sd	a0, 0x50(sp)
400003c6: 6541         	lui	a0, 0x10
400003c8: 1565         	addi	a0, a0, -0x7
400003ca: ecaa         	sd	a0, 0x58(sp)
400003cc: f0ae         	sd	a1, 0x60(sp)
400003ce: 8aae         	mv	s5, a1
400003d0: 000ac503     	lbu	a0, 0x0(s5)
400003d4: 02500613     	li	a2, 0x25
400003d8: 00c50c63     	beq	a0, a2, 0x400003f0 <vfprintf+0x8c>
400003dc: 1e0503e3     	beqz	a0, 0x40000dc2 <vfprintf+0xa5e>
400003e0: 0a85         	addi	s5, s5, 0x1
400003e2: 2b05         	addiw	s6, s6, 0x1
400003e4: 85d2         	mv	a1, s4
400003e6: 9b82         	jalr	s7
400003e8: fe0554e3     	bgez	a0, 0x400003d0 <vfprintf+0x6c>
400003ec: 1c90006f     	j	0x40000db4 <vfprintf+0xa50>
400003f0: 001ac583     	lbu	a1, 0x1(s5)
400003f4: 0a89         	addi	s5, s5, 0x2
400003f6: 00c59963     	bne	a1, a2, 0x40000408 <vfprintf+0xa4>
400003fa: 2b05         	addiw	s6, s6, 0x1
400003fc: 85d2         	mv	a1, s4
400003fe: 9b82         	jalr	s7
40000400: fc0558e3     	bgez	a0, 0x400003d0 <vfprintf+0x6c>
40000404: 1b10006f     	j	0x40000db4 <vfprintf+0xa50>
40000408: 4901         	li	s2, 0x0
4000040a: 4c81         	li	s9, 0x0
4000040c: 4981         	li	s3, 0x0
4000040e: 4d81         	li	s11, 0x0
40000410: 4c7d         	li	s8, 0x1f
40000412: 4d41         	li	s10, 0x10
40000414: 7626         	ld	a2, 0x68(sp)
40000416: 46a5         	li	a3, 0x9
40000418: 04000893     	li	a7, 0x40
4000041c: 05600813     	li	a6, 0x56
40000420: 02e00793     	li	a5, 0x2e
40000424: 07f00713     	li	a4, 0x7f
40000428: a811         	j	0x4000043c <vfprintf+0xd8>
4000042a: 002ded93     	ori	s11, s11, 0x2
4000042e: 004ded93     	ori	s11, s11, 0x4
40000432: 000ac583     	lbu	a1, 0x0(s5)
40000436: 0a85         	addi	s5, s5, 0x1
40000438: 14058763     	beqz	a1, 0x40000586 <vfprintf+0x222>
4000043c: 080dc4bb     	zext.h	s1, s11
40000440: 0ff5f413     	zext.b	s0, a1
40000444: 009c6d63     	bltu	s8, s1, 0x4000045e <vfprintf+0xfa>
40000448: fe058513     	addi	a0, a1, -0x20
4000044c: 00ad6b63     	bltu	s10, a0, 0x40000462 <vfprintf+0xfe>
40000450: 050e         	slli	a0, a0, 0x3
40000452: 9532         	add	a0, a0, a2
40000454: 6108         	ld	a0, 0x0(a0)
40000456: 8502         	jr	a0
40000458: 010ded93     	ori	s11, s11, 0x10
4000045c: bfd9         	j	0x40000432 <vfprintf+0xce>
4000045e: 02976163     	bltu	a4, s1, 0x40000480 <vfprintf+0x11c>
40000462: fd040513     	addi	a0, s0, -0x30
40000466: 02a6e963     	bltu	a3, a0, 0x40000498 <vfprintf+0x134>
4000046a: 0514f663     	bgeu	s1, a7, 0x400004b6 <vfprintf+0x152>
4000046e: 00199593     	slli	a1, s3, 0x1
40000472: 098e         	slli	s3, s3, 0x3
40000474: 95ce         	add	a1, a1, s3
40000476: 00b509bb     	addw	s3, a0, a1
4000047a: 020ded93     	ori	s11, s11, 0x20
4000047e: bf55         	j	0x40000432 <vfprintf+0xce>
40000480: fb458513     	addi	a0, a1, -0x4c
40000484: 10a7e263     	bltu	a5, a0, 0x40000588 <vfprintf+0x224>
40000488: 050e         	slli	a0, a0, 0x3
4000048a: 00004597     	auipc	a1, 0x4
4000048e: f7e58593     	addi	a1, a1, -0x82
40000492: 952e         	add	a0, a0, a1
40000494: 6108         	ld	a0, 0x0(a0)
40000496: 8502         	jr	a0
40000498: fdc58513     	addi	a0, a1, -0x24
4000049c: 0ea86663     	bltu	a6, a0, 0x40000588 <vfprintf+0x224>
400004a0: 050e         	slli	a0, a0, 0x3
400004a2: 00004597     	auipc	a1, 0x4
400004a6: 16658593     	addi	a1, a1, 0x166
400004aa: 952e         	add	a0, a0, a1
400004ac: 6108         	ld	a0, 0x0(a0)
400004ae: 8502         	jr	a0
400004b0: 080ded93     	ori	s11, s11, 0x80
400004b4: bfbd         	j	0x40000432 <vfprintf+0xce>
400004b6: 001c9593     	slli	a1, s9, 0x1
400004ba: 0c8e         	slli	s9, s9, 0x3
400004bc: 95e6         	add	a1, a1, s9
400004be: 00b50cbb     	addw	s9, a0, a1
400004c2: bf85         	j	0x40000432 <vfprintf+0xce>
400004c4: 001ded93     	ori	s11, s11, 0x1
400004c8: b7ad         	j	0x40000432 <vfprintf+0xce>
400004ca: 008ded93     	ori	s11, s11, 0x8
400004ce: b795         	j	0x40000432 <vfprintf+0xce>
400004d0: 002d9513     	slli	a0, s11, 0x2
400004d4: 20057513     	andi	a0, a0, 0x200
400004d8: 00ade533     	or	a0, s11, a0
400004dc: 08056d93     	ori	s11, a0, 0x80
400004e0: bf89         	j	0x40000432 <vfprintf+0xce>
400004e2: 280ded93     	ori	s11, s11, 0x280
400004e6: b7b1         	j	0x40000432 <vfprintf+0xce>
400004e8: 001d9513     	slli	a0, s11, 0x1
400004ec: 20057513     	andi	a0, a0, 0x200
400004f0: 00ade533     	or	a0, s11, a0
400004f4: 10056d93     	ori	s11, a0, 0x100
400004f8: bf2d         	j	0x40000432 <vfprintf+0xce>
400004fa: 06090063     	beqz	s2, 0x4000055a <vfprintf+0x1f6>
400004fe: 654a         	ld	a0, 0x90(sp)
40000500: e52a         	sd	a0, 0x88(sp)
40000502: 864e         	mv	a2, s3
40000504: 0114e363     	bltu	s1, a7, 0x4000050a <vfprintf+0x1a6>
40000508: 8666         	mv	a2, s9
4000050a: 012c         	addi	a1, sp, 0x88
4000050c: 7506         	ld	a0, 0x60(sp)
4000050e: 0d5000ef     	jal	0x40000de2 <skip_to_arg>
40000512: 652a         	ld	a0, 0x88(sp)
40000514: 00850593     	addi	a1, a0, 0x8
40000518: e52e         	sd	a1, 0x88(sp)
4000051a: 4108         	lw	a0, 0x0(a0)
4000051c: 04000893     	li	a7, 0x40
40000520: 0514e263     	bltu	s1, a7, 0x40000564 <vfprintf+0x200>
40000524: 8caa         	mv	s9, a0
40000526: a081         	j	0x40000566 <vfprintf+0x202>
40000528: f00915e3     	bnez	s2, 0x40000432 <vfprintf+0xce>
4000052c: 652a         	ld	a0, 0x88(sp)
4000052e: 00850593     	addi	a1, a0, 0x8
40000532: e52e         	sd	a1, 0x88(sp)
40000534: 4108         	lw	a0, 0x0(a0)
40000536: 4901         	li	s2, 0x0
40000538: 03f00593     	li	a1, 0x3f
4000053c: 0295ee63     	bltu	a1, s1, 0x40000578 <vfprintf+0x214>
40000540: 02054e63     	bltz	a0, 0x4000057c <vfprintf+0x218>
40000544: 020ded93     	ori	s11, s11, 0x20
40000548: 89aa         	mv	s3, a0
4000054a: b5e5         	j	0x40000432 <vfprintf+0xce>
4000054c: 03f00513     	li	a0, 0x3f
40000550: 069569e3     	bltu	a0, s1, 0x40000dc2 <vfprintf+0xa5e>
40000554: 040ded93     	ori	s11, s11, 0x40
40000558: bde9         	j	0x40000432 <vfprintf+0xce>
4000055a: 4c81         	li	s9, 0x0
4000055c: 4d81         	li	s11, 0x0
4000055e: 894e         	mv	s2, s3
40000560: 4981         	li	s3, 0x0
40000562: bdc1         	j	0x40000432 <vfprintf+0xce>
40000564: 89aa         	mv	s3, a0
40000566: 7626         	ld	a2, 0x68(sp)
40000568: 46a5         	li	a3, 0x9
4000056a: 05600813     	li	a6, 0x56
4000056e: 02e00793     	li	a5, 0x2e
40000572: 07f00713     	li	a4, 0x7f
40000576: bd75         	j	0x40000432 <vfprintf+0xce>
40000578: 8caa         	mv	s9, a0
4000057a: bd65         	j	0x40000432 <vfprintf+0xce>
4000057c: 40a009bb     	negw	s3, a0
40000580: 028ded93     	ori	s11, s11, 0x28
40000584: b57d         	j	0x40000432 <vfprintf+0xce>
40000586: 4401         	li	s0, 0x0
40000588: 00090963     	beqz	s2, 0x4000059a <vfprintf+0x236>
4000058c: 654a         	ld	a0, 0x90(sp)
4000058e: e52a         	sd	a0, 0x88(sp)
40000590: 012c         	addi	a1, sp, 0x88
40000592: 7506         	ld	a0, 0x60(sp)
40000594: 864a         	mv	a2, s2
40000596: 04d000ef     	jal	0x40000de2 <skip_to_arg>
4000059a: 000cd463     	bgez	s9, 0x400005a2 <vfprintf+0x23e>
4000059e: fbfdfd93     	andi	s11, s11, -0x41
400005a2: 02046593     	ori	a1, s0, 0x20
400005a6: 0a0ced33     	max	s10, s9, zero
400005aa: 06100513     	li	a0, 0x61
400005ae: 06a58063     	beq	a1, a0, 0x4000060e <vfprintf+0x2aa>
400005b2: f9b58513     	addi	a0, a1, -0x65
400005b6: 4609         	li	a2, 0x2
400005b8: 04a67b63     	bgeu	a2, a0, 0x4000060e <vfprintf+0x2aa>
400005bc: f9d40513     	addi	a0, s0, -0x63
400005c0: 4649         	li	a2, 0x12
400005c2: 20a66763     	bltu	a2, a0, 0x400007d0 <vfprintf+0x46c>
400005c6: 4481         	li	s1, 0x0
400005c8: 050e         	slli	a0, a0, 0x3
400005ca: 00004617     	auipc	a2, 0x4
400005ce: 2f660613     	addi	a2, a2, 0x2f6
400005d2: 9532         	add	a0, a0, a2
400005d4: 6108         	ld	a0, 0x0(a0)
400005d6: 4621         	li	a2, 0x8
400005d8: 8502         	jr	a0
400005da: 080df593     	andi	a1, s11, 0x80
400005de: 652a         	ld	a0, 0x88(sp)
400005e0: 00850613     	addi	a2, a0, 0x8
400005e4: e532         	sd	a2, 0x88(sp)
400005e6: 22059463     	bnez	a1, 0x4000080e <vfprintf+0x4aa>
400005ea: 080dc63b     	zext.h	a2, s11
400005ee: 10067693     	andi	a3, a2, 0x100
400005f2: 410c         	lw	a1, 0x0(a0)
400005f4: 20068e63     	beqz	a3, 0x40000810 <vfprintf+0x4ac>
400005f8: 20067613     	andi	a2, a2, 0x200
400005fc: 0805c533     	zext.w	a0, a1
40000600: 5a061163     	bnez	a2, 0x40000ba2 <vfprintf+0x83e>
40000604: 60551593     	sext.h	a1, a0
40000608: 20059663     	bnez	a1, 0x40000814 <vfprintf+0x4b0>
4000060c: ab79         	j	0x40000baa <vfprintf+0x846>
4000060e: 40858cb3     	sub	s9, a1, s0
40000612: 652a         	ld	a0, 0x88(sp)
40000614: 00850613     	addi	a2, a0, 0x8
40000618: e532         	sd	a2, 0x88(sp)
4000061a: 6108         	ld	a0, 0x0(a0)
4000061c: 06100613     	li	a2, 0x61
40000620: 04c59363     	bne	a1, a2, 0x40000666 <vfprintf+0x302>
40000624: 486dd593     	bexti	a1, s11, 0x6
40000628: 15fd         	addi	a1, a1, -0x1
4000062a: 01a5ed33     	or	s10, a1, s10
4000062e: 0ffcf693     	zext.b	a3, s9
40000632: 188c         	addi	a1, sp, 0x70
40000634: 866a         	mv	a2, s10
40000636: 10d000ef     	jal	0x40000f42 <__dtox_engine>
4000063a: 00150913     	addi	s2, a0, 0x1
4000063e: 0ff97513     	zext.b	a0, s2
40000642: 01a54463     	blt	a0, s10, 0x4000064a <vfprintf+0x2e6>
40000646: fff50d13     	addi	s10, a0, -0x1
4000064a: 28bd9513     	bseti	a0, s11, 0xb
4000064e: 28c51d93     	bseti	s11, a0, 0xc
40000652: 07000413     	li	s0, 0x70
40000656: 4705         	li	a4, 0x1
40000658: 57c6         	lw	a5, 0x70(sp)
4000065a: ff67851b     	addiw	a0, a5, -0xa
4000065e: 55b5         	li	a1, -0x13
40000660: 06b56963     	bltu	a0, a1, 0x400006d2 <vfprintf+0x36e>
40000664: a885         	j	0x400006d4 <vfprintf+0x370>
40000666: 040df613     	andi	a2, s11, 0x40
4000066a: e211         	bnez	a2, 0x4000066e <vfprintf+0x30a>
4000066c: 4d19         	li	s10, 0x6
4000066e: 06600613     	li	a2, 0x66
40000672: 00c58f63     	beq	a1, a2, 0x40000690 <vfprintf+0x32c>
40000676: 06500613     	li	a2, 0x65
4000067a: 02c59363     	bne	a1, a2, 0x400006a0 <vfprintf+0x33c>
4000067e: 4701         	li	a4, 0x0
40000680: 4681         	li	a3, 0x0
40000682: 001d0613     	addi	a2, s10, 0x1
40000686: 28cd9d93     	bseti	s11, s11, 0xc
4000068a: 06500413     	li	s0, 0x65
4000068e: a015         	j	0x400006b2 <vfprintf+0x34e>
40000690: 28dd9d93     	bseti	s11, s11, 0xd
40000694: 4685         	li	a3, 0x1
40000696: 06600413     	li	s0, 0x66
4000069a: 4645         	li	a2, 0x11
4000069c: 876a         	mv	a4, s10
4000069e: a811         	j	0x400006b2 <vfprintf+0x34e>
400006a0: 0ffd7693     	zext.b	a3, s10
400006a4: 866a         	mv	a2, s10
400006a6: e291         	bnez	a3, 0x400006aa <vfprintf+0x346>
400006a8: 4605         	li	a2, 0x1
400006aa: 4701         	li	a4, 0x0
400006ac: 4681         	li	a3, 0x0
400006ae: ffe58413     	addi	s0, a1, -0x2
400006b2: 0ff67593     	zext.b	a1, a2
400006b6: 4645         	li	a2, 0x11
400006b8: 0ac5d633     	minu	a2, a1, a2
400006bc: 188c         	addi	a1, sp, 0x70
400006be: 3f3000ef     	jal	0x400012b0 <__dtoa_engine>
400006c2: 892a         	mv	s2, a0
400006c4: 4709         	li	a4, 0x2
400006c6: 57c6         	lw	a5, 0x70(sp)
400006c8: ff67851b     	addiw	a0, a5, -0xa
400006cc: 55b5         	li	a1, -0x13
400006ce: 00b57363     	bgeu	a0, a1, 0x400006d4 <vfprintf+0x370>
400006d2: 4709         	li	a4, 0x2
400006d4: f9c7849b     	addiw	s1, a5, -0x64
400006d8: f3900513     	li	a0, -0xc7
400006dc: 02a4e463     	bltu	s1, a0, 0x40000704 <vfprintf+0x3a0>
400006e0: 07414503     	lbu	a0, 0x74(sp)
400006e4: 00157593     	andi	a1, a0, 0x1
400006e8: e585         	bnez	a1, 0x40000710 <vfprintf+0x3ac>
400006ea: 002df593     	andi	a1, s11, 0x2
400006ee: e5cd         	bnez	a1, 0x40000798 <vfprintf+0x434>
400006f0: 080dc5bb     	zext.h	a1, s11
400006f4: 8991         	andi	a1, a1, 0x4
400006f6: 0015bc13     	seqz	s8, a1
400006fa: 00359813     	slli	a6, a1, 0x3
400006fe: 8931         	andi	a0, a0, 0xc
40000700: ed09         	bnez	a0, 0x4000071a <vfprintf+0x3b6>
40000702: a045         	j	0x400007a2 <vfprintf+0x43e>
40000704: 470d         	li	a4, 0x3
40000706: 07414503     	lbu	a0, 0x74(sp)
4000070a: 00157593     	andi	a1, a0, 0x1
4000070e: ddf1         	beqz	a1, 0x400006ea <vfprintf+0x386>
40000710: 4c01         	li	s8, 0x0
40000712: 02d00813     	li	a6, 0x2d
40000716: 8931         	andi	a0, a0, 0xc
40000718: c549         	beqz	a0, 0x400007a2 <vfprintf+0x43e>
4000071a: 4511         	li	a0, 0x4
4000071c: 41850533     	sub	a0, a0, s8
40000720: 03355763     	bge	a0, s3, 0x4000074e <vfprintf+0x3ea>
40000724: 008df593     	andi	a1, s11, 0x8
40000728: 40a98d3b     	subw	s10, s3, a0
4000072c: e195         	bnez	a1, 0x40000750 <vfprintf+0x3ec>
4000072e: 84c2         	mv	s1, a6
40000730: 016d0b3b     	addw	s6, s10, s6
40000734: 4135043b     	subw	s0, a0, s3
40000738: 02000513     	li	a0, 0x20
4000073c: 85d2         	mv	a1, s4
4000073e: 9b82         	jalr	s7
40000740: 66054a63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000744: 2405         	addiw	s0, s0, 0x1
40000746: f86d         	bnez	s0, 0x40000738 <vfprintf+0x3d4>
40000748: 4d01         	li	s10, 0x0
4000074a: 8826         	mv	a6, s1
4000074c: a011         	j	0x40000750 <vfprintf+0x3ec>
4000074e: 4d01         	li	s10, 0x0
40000750: 000c1863     	bnez	s8, 0x40000760 <vfprintf+0x3fc>
40000754: 8542         	mv	a0, a6
40000756: 85d2         	mv	a1, s4
40000758: 9b82         	jalr	s7
4000075a: 64054d63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
4000075e: 2b05         	addiw	s6, s6, 0x1
40000760: 07414503     	lbu	a0, 0x74(sp)
40000764: 8921         	andi	a0, a0, 0x8
40000766: c511         	beqz	a0, 0x40000772 <vfprintf+0x40e>
40000768: 00004517     	auipc	a0, 0x4
4000076c: 77150493     	addi	s1, a0, 0x771
40000770: a029         	j	0x4000077a <vfprintf+0x416>
40000772: 00004517     	auipc	a0, 0x4
40000776: 63650493     	addi	s1, a0, 0x636
4000077a: 0004c503     	lbu	a0, 0x0(s1)
4000077e: 60050763     	beqz	a0, 0x40000d8c <vfprintf+0xa28>
40000782: 0485         	addi	s1, s1, 0x1
40000784: 2b05         	addiw	s6, s6, 0x1
40000786: 4195053b     	subw	a0, a0, s9
4000078a: 0ff57513     	zext.b	a0, a0
4000078e: 85d2         	mv	a1, s4
40000790: 9b82         	jalr	s7
40000792: fe0554e3     	bgez	a0, 0x4000077a <vfprintf+0x416>
40000796: ad39         	j	0x40000db4 <vfprintf+0xa50>
40000798: 4c01         	li	s8, 0x0
4000079a: 02b00813     	li	a6, 0x2b
4000079e: 8931         	andi	a0, a0, 0xc
400007a0: fd2d         	bnez	a0, 0x4000071a <vfprintf+0x3b6>
400007a2: 650d         	lui	a0, 0x3
400007a4: 00adf533     	and	a0, s11, a0
400007a8: 22051663     	bnez	a0, 0x400009d4 <vfprintf+0x670>
400007ac: a011         	j	0x400007b0 <vfprintf+0x44c>
400007ae: 197d         	addi	s2, s2, -0x1
400007b0: 0ff97513     	zext.b	a0, s2
400007b4: 1c050163     	beqz	a0, 0x40000976 <vfprintf+0x612>
400007b8: 0ff97513     	zext.b	a0, s2
400007bc: 07510593     	addi	a1, sp, 0x75
400007c0: 95aa         	add	a1, a1, a0
400007c2: fff5c583     	lbu	a1, -0x1(a1)
400007c6: 03000613     	li	a2, 0x30
400007ca: fec582e3     	beq	a1, a2, 0x400007ae <vfprintf+0x44a>
400007ce: a26d         	j	0x40000978 <vfprintf+0x614>
400007d0: 07800513     	li	a0, 0x78
400007d4: 1ca59e63     	bne	a1, a0, 0x400009b0 <vfprintf+0x64c>
400007d8: 08800613     	li	a2, 0x88
400007dc: 8e01         	sub	a2, a2, s0
400007de: 84a2         	mv	s1, s0
400007e0: a221         	j	0x400008e8 <vfprintf+0x584>
400007e2: 652a         	ld	a0, 0x88(sp)
400007e4: 00850593     	addi	a1, a0, 0x8
400007e8: e52e         	sd	a1, 0x88(sp)
400007ea: 00053903     	ld	s2, 0x0(a0)
400007ee: 00091663     	bnez	s2, 0x400007fa <vfprintf+0x496>
400007f2: 00004517     	auipc	a0, 0x4
400007f6: 70f50913     	addi	s2, a0, 0x70f
400007fa: 486dd513     	bexti	a0, s11, 0x6
400007fe: 157d         	addi	a0, a0, -0x1
40000800: 01a565b3     	or	a1, a0, s10
40000804: 854a         	mv	a0, s2
40000806: 28d000ef     	jal	0x40001292 <strnlen>
4000080a: 84aa         	mv	s1, a0
4000080c: a079         	j	0x4000089a <vfprintf+0x536>
4000080e: 610c         	ld	a1, 0x0(a0)
40000810: 38058d63     	beqz	a1, 0x40000baa <vfprintf+0x846>
40000814: 40b00533     	neg	a0, a1
40000818: 0aa5e533     	max	a0, a1, a0
4000081c: 91fd         	srli	a1, a1, 0x3f
4000081e: 05aa         	slli	a1, a1, 0xa
40000820: 00bde5b3     	or	a1, s11, a1
40000824: fef5f913     	andi	s2, a1, -0x11
40000828: 188c         	addi	a1, sp, 0x70
4000082a: 4629         	li	a2, 0xa
4000082c: 6de000ef     	jal	0x40000f0a <__ultoa_invert>
40000830: 188c         	addi	a1, sp, 0x70
40000832: 40b50c3b     	subw	s8, a0, a1
40000836: 04097513     	andi	a0, s2, 0x40
4000083a: 10050563     	beqz	a0, 0x40000944 <vfprintf+0x5e0>
4000083e: 6541         	lui	a0, 0x10
40000840: 1579         	addi	a0, a0, -0x2
40000842: 00a97533     	and	a0, s2, a0
40000846: 01ac5e63     	bge	s8, s10, 0x40000862 <vfprintf+0x4fe>
4000084a: e019         	bnez	s0, 0x40000850 <vfprintf+0x4ec>
4000084c: fee97513     	andi	a0, s2, -0x12
40000850: 892a         	mv	s2, a0
40000852: 856a         	mv	a0, s10
40000854: 01097d93     	andi	s11, s2, 0x10
40000858: 08094cbb     	zext.h	s9, s2
4000085c: 0e0d8b63     	beqz	s11, 0x40000952 <vfprintf+0x5ee>
40000860: ae85         	j	0x40000bd0 <vfprintf+0x86c>
40000862: 892a         	mv	s2, a0
40000864: 8562         	mv	a0, s8
40000866: 01097d93     	andi	s11, s2, 0x10
4000086a: 08094cbb     	zext.h	s9, s2
4000086e: 0e0d8263     	beqz	s11, 0x40000952 <vfprintf+0x5ee>
40000872: aeb9         	j	0x40000bd0 <vfprintf+0x86c>
40000874: 6541         	lui	a0, 0x10
40000876: 153d         	addi	a0, a0, -0x11
40000878: 00adfdb3     	and	s11, s11, a0
4000087c: 4629         	li	a2, 0xa
4000087e: 07500493     	li	s1, 0x75
40000882: a09d         	j	0x400008e8 <vfprintf+0x584>
40000884: 652a         	ld	a0, 0x88(sp)
40000886: 00850593     	addi	a1, a0, 0x8
4000088a: e52e         	sd	a1, 0x88(sp)
4000088c: 00054503     	lbu	a0, 0x0(a0)
40000890: 06a10823     	sb	a0, 0x70(sp)
40000894: 4485         	li	s1, 0x1
40000896: 07010913     	addi	s2, sp, 0x70
4000089a: 008df513     	andi	a0, s11, 0x8
4000089e: ed19         	bnez	a0, 0x400008bc <vfprintf+0x558>
400008a0: 0134fe63     	bgeu	s1, s3, 0x400008bc <vfprintf+0x558>
400008a4: 844e         	mv	s0, s3
400008a6: 02000513     	li	a0, 0x20
400008aa: 85d2         	mv	a1, s4
400008ac: 9b82         	jalr	s7
400008ae: 50054363     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
400008b2: 0b05         	addi	s6, s6, 0x1
400008b4: 147d         	addi	s0, s0, -0x1
400008b6: 19fd         	addi	s3, s3, -0x1
400008b8: fe84e7e3     	bltu	s1, s0, 0x400008a6 <vfprintf+0x542>
400008bc: 40998d3b     	subw	s10, s3, s1
400008c0: 009b0b3b     	addw	s6, s6, s1
400008c4: 4c048463     	beqz	s1, 0x40000d8c <vfprintf+0xa28>
400008c8: 14fd         	addi	s1, s1, -0x1
400008ca: 00190413     	addi	s0, s2, 0x1
400008ce: 00094503     	lbu	a0, 0x0(s2)
400008d2: 85d2         	mv	a1, s4
400008d4: 9b82         	jalr	s7
400008d6: 8922         	mv	s2, s0
400008d8: fe0556e3     	bgez	a0, 0x400008c4 <vfprintf+0x560>
400008dc: a9e1         	j	0x40000db4 <vfprintf+0xa50>
400008de: 090ded93     	ori	s11, s11, 0x90
400008e2: 4641         	li	a2, 0x10
400008e4: 07800493     	li	s1, 0x78
400008e8: 6566         	ld	a0, 0x58(sp)
400008ea: 00adf933     	and	s2, s11, a0
400008ee: 080df593     	andi	a1, s11, 0x80
400008f2: 652a         	ld	a0, 0x88(sp)
400008f4: 00850693     	addi	a3, a0, 0x8
400008f8: e536         	sd	a3, 0x88(sp)
400008fa: e989         	bnez	a1, 0x4000090c <vfprintf+0x5a8>
400008fc: 10097593     	andi	a1, s2, 0x100
40000900: 00056503     	lwu	a0, 0x0(a0)
40000904: e1b5         	bnez	a1, 0x40000968 <vfprintf+0x604>
40000906: c509         	beqz	a0, 0x40000910 <vfprintf+0x5ac>
40000908: e11d         	bnez	a0, 0x4000092e <vfprintf+0x5ca>
4000090a: a031         	j	0x40000916 <vfprintf+0x5b2>
4000090c: 6108         	ld	a0, 0x0(a0)
4000090e: fd6d         	bnez	a0, 0x40000908 <vfprintf+0x5a4>
40000910: fe9df913     	andi	s2, s11, -0x17
40000914: ed09         	bnez	a0, 0x4000092e <vfprintf+0x5ca>
40000916: 040df513     	andi	a0, s11, 0x40
4000091a: c911         	beqz	a0, 0x4000092e <vfprintf+0x5ca>
4000091c: 4501         	li	a0, 0x0
4000091e: 01904863     	bgtz	s9, 0x4000092e <vfprintf+0x5ca>
40000922: 4c01         	li	s8, 0x0
40000924: 6541         	lui	a0, 0x10
40000926: 1525         	addi	a0, a0, -0x17
40000928: 00adf933     	and	s2, s11, a0
4000092c: a039         	j	0x4000093a <vfprintf+0x5d6>
4000092e: 188c         	addi	a1, sp, 0x70
40000930: 5da000ef     	jal	0x40000f0a <__ultoa_invert>
40000934: 188c         	addi	a1, sp, 0x70
40000936: 40b50c3b     	subw	s8, a0, a1
4000093a: 8426         	mv	s0, s1
4000093c: 04097513     	andi	a0, s2, 0x40
40000940: ee051fe3     	bnez	a0, 0x4000083e <vfprintf+0x4da>
40000944: 8562         	mv	a0, s8
40000946: 01097d93     	andi	s11, s2, 0x10
4000094a: 08094cbb     	zext.h	s9, s2
4000094e: 280d9163     	bnez	s11, 0x40000bd0 <vfprintf+0x86c>
40000952: 406cf593     	andi	a1, s9, 0x406
40000956: 00b035b3     	snez	a1, a1
4000095a: 008cf613     	andi	a2, s9, 0x8
4000095e: 00a5893b     	addw	s2, a1, a0
40000962: 26060f63     	beqz	a2, 0x40000be0 <vfprintf+0x87c>
40000966: a475         	j	0x40000c12 <vfprintf+0x8ae>
40000968: 20097593     	andi	a1, s2, 0x200
4000096c: edb9         	bnez	a1, 0x400009ca <vfprintf+0x666>
4000096e: 0805453b     	zext.h	a0, a0
40000972: f959         	bnez	a0, 0x40000908 <vfprintf+0x5a4>
40000974: bf71         	j	0x40000910 <vfprintf+0x5ac>
40000976: 4901         	li	s2, 0x0
40000978: 080dc5bb     	zext.h	a1, s11
4000097c: 000d061b     	sext.w	a2, s10
40000980: 0105f693     	andi	a3, a1, 0x10
40000984: 4585         	li	a1, 0x1
40000986: 0ab675b3     	maxu	a1, a2, a1
4000098a: c291         	beqz	a3, 0x4000098e <vfprintf+0x62a>
4000098c: 852e         	mv	a0, a1
4000098e: 5671         	li	a2, -0x4
40000990: 00c7cd63     	blt	a5, a2, 0x400009aa <vfprintf+0x646>
40000994: 00b7db63     	bge	a5, a1, 0x400009aa <vfprintf+0x646>
40000998: 28dd9d93     	bseti	s11, s11, 0xd
4000099c: 02a7db63     	bge	a5, a0, 0x400009d2 <vfprintf+0x66e>
400009a0: fff7c593     	not	a1, a5
400009a4: 00b50d33     	add	s10, a0, a1
400009a8: a035         	j	0x400009d4 <vfprintf+0x670>
400009aa: fff50d13     	addi	s10, a0, -0x1
400009ae: a01d         	j	0x400009d4 <vfprintf+0x670>
400009b0: 02500513     	li	a0, 0x25
400009b4: 85d2         	mv	a1, s4
400009b6: 9b82         	jalr	s7
400009b8: 3e054e63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
400009bc: 2b09         	addiw	s6, s6, 0x2
400009be: 8522         	mv	a0, s0
400009c0: 85d2         	mv	a1, s4
400009c2: 9b82         	jalr	s7
400009c4: a00556e3     	bgez	a0, 0x400003d0 <vfprintf+0x6c>
400009c8: a6f5         	j	0x40000db4 <vfprintf+0xa50>
400009ca: 0ff57513     	zext.b	a0, a0
400009ce: fd0d         	bnez	a0, 0x40000908 <vfprintf+0x5a4>
400009d0: b781         	j	0x40000910 <vfprintf+0x5ac>
400009d2: 4d01         	li	s10, 0x0
400009d4: c187861b     	addiw	a2, a5, -0x3e8
400009d8: 032d9513     	slli	a0, s11, 0x32
400009dc: 080dcdbb     	zext.h	s11, s11
400009e0: 00054e63     	bltz	a0, 0x400009fc <vfprintf+0x698>
400009e4: 853a         	mv	a0, a4
400009e6: 83100593     	li	a1, -0x7cf
400009ea: 00b67363     	bgeu	a2, a1, 0x400009f0 <vfprintf+0x68c>
400009ee: 4511         	li	a0, 0x4
400009f0: 00add593     	srli	a1, s11, 0xa
400009f4: 8989         	andi	a1, a1, 0x2
400009f6: 952e         	add	a0, a0, a1
400009f8: 050d         	addi	a0, a0, 0x3
400009fa: a021         	j	0x40000a02 <vfprintf+0x69e>
400009fc: 0a07e533     	max	a0, a5, zero
40000a00: 0505         	addi	a0, a0, 0x1
40000a02: e426         	sd	s1, 0x8(sp)
40000a04: fc3e         	sd	a5, 0x38(sp)
40000a06: 000d049b     	sext.w	s1, s10
40000a0a: 001d0793     	addi	a5, s10, 0x1
40000a0e: f022         	sd	s0, 0x20(sp)
40000a10: e03a         	sd	a4, 0x0(sp)
40000a12: ec32         	sd	a2, 0x18(sp)
40000a14: f86a         	sd	s10, 0x30(sp)
40000a16: c099         	beqz	s1, 0x40000a1c <vfprintf+0x6b8>
40000a18: 85be         	mv	a1, a5
40000a1a: a019         	j	0x40000a20 <vfprintf+0x6bc>
40000a1c: 484dd593     	bexti	a1, s11, 0x4
40000a20: 001c4613     	xori	a2, s8, 0x1
40000a24: 00a586b3     	add	a3, a1, a0
40000a28: 9eb1         	addw	a3, a3, a2
40000a2a: 0136a733     	slt	a4, a3, s3
40000a2e: 40d986bb     	subw	a3, s3, a3
40000a32: 40e0043b     	negw	s0, a4
40000a36: 009df713     	andi	a4, s11, 0x9
40000a3a: 00d47d33     	and	s10, s0, a3
40000a3e: e83e         	sd	a5, 0x10(sp)
40000a40: f426         	sd	s1, 0x28(sp)
40000a42: e31d         	bnez	a4, 0x40000a68 <vfprintf+0x704>
40000a44: 020d0263     	beqz	s10, 0x40000a68 <vfprintf+0x704>
40000a48: 84c2         	mv	s1, a6
40000a4a: 9b36         	add	s6, s6, a3
40000a4c: 952e         	add	a0, a0, a1
40000a4e: 4136043b     	subw	s0, a2, s3
40000a52: 942a         	add	s0, s0, a0
40000a54: 02000513     	li	a0, 0x20
40000a58: 85d2         	mv	a1, s4
40000a5a: 9b82         	jalr	s7
40000a5c: 34054c63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000a60: 2405         	addiw	s0, s0, 0x1
40000a62: f86d         	bnez	s0, 0x40000a54 <vfprintf+0x6f0>
40000a64: 4d01         	li	s10, 0x0
40000a66: 8826         	mv	a6, s1
40000a68: 000c1863     	bnez	s8, 0x40000a78 <vfprintf+0x714>
40000a6c: 8542         	mv	a0, a6
40000a6e: 85d2         	mv	a1, s4
40000a70: 9b82         	jalr	s7
40000a72: 34054163     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000a76: 0b05         	addi	s6, s6, 0x1
40000a78: 034d9513     	slli	a0, s11, 0x34
40000a7c: 02055363     	bgez	a0, 0x40000aa2 <vfprintf+0x73e>
40000a80: 03000513     	li	a0, 0x30
40000a84: 85d2         	mv	a1, s4
40000a86: 9b82         	jalr	s7
40000a88: 32054663     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000a8c: 07800513     	li	a0, 0x78
40000a90: 4195053b     	subw	a0, a0, s9
40000a94: 0ff57513     	zext.b	a0, a0
40000a98: 85d2         	mv	a1, s4
40000a9a: 9b82         	jalr	s7
40000a9c: 30054c63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000aa0: 0b09         	addi	s6, s6, 0x2
40000aa2: 008df513     	andi	a0, s11, 0x8
40000aa6: ed09         	bnez	a0, 0x40000ac0 <vfprintf+0x75c>
40000aa8: 000d0c63     	beqz	s10, 0x40000ac0 <vfprintf+0x75c>
40000aac: 9b6a         	add	s6, s6, s10
40000aae: 03000513     	li	a0, 0x30
40000ab2: 85d2         	mv	a1, s4
40000ab4: 9b82         	jalr	s7
40000ab6: 2e054f63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000aba: 3d7d         	addiw	s10, s10, -0x1
40000abc: fe0d19e3     	bnez	s10, 0x40000aae <vfprintf+0x74a>
40000ac0: 032d9513     	slli	a0, s11, 0x32
40000ac4: 04054c63     	bltz	a0, 0x40000b1c <vfprintf+0x7b8>
40000ac8: 07514503     	lbu	a0, 0x75(sp)
40000acc: 85d2         	mv	a1, s4
40000ace: 9b82         	jalr	s7
40000ad0: 2e054263     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000ad4: 7522         	ld	a0, 0x28(sp)
40000ad6: 0ca05063     	blez	a0, 0x40000b96 <vfprintf+0x832>
40000ada: 02e00513     	li	a0, 0x2e
40000ade: 85d2         	mv	a1, s4
40000ae0: 9b82         	jalr	s7
40000ae2: 2c054963     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000ae6: 0ff97913     	zext.b	s2, s2
40000aea: 7542         	ld	a0, 0x30(sp)
40000aec: 9b2a         	add	s6, s6, a0
40000aee: 0b09         	addi	s6, s6, 0x2
40000af0: 6542         	ld	a0, 0x10(sp)
40000af2: 080549b3     	zext.w	s3, a0
40000af6: 4485         	li	s1, 0x1
40000af8: 07610d93     	addi	s11, sp, 0x76
40000afc: 0124f563     	bgeu	s1, s2, 0x40000b06 <vfprintf+0x7a2>
40000b00: 000dc503     	lbu	a0, 0x0(s11)
40000b04: a019         	j	0x40000b0a <vfprintf+0x7a6>
40000b06: 03000513     	li	a0, 0x30
40000b0a: 85d2         	mv	a1, s4
40000b0c: 9b82         	jalr	s7
40000b0e: 2a054363     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000b12: 0485         	addi	s1, s1, 0x1
40000b14: 0d85         	addi	s11, s11, 0x1
40000b16: fe9993e3     	bne	s3, s1, 0x40000afc <vfprintf+0x798>
40000b1a: aa71         	j	0x40000cb6 <vfprintf+0x952>
40000b1c: 7562         	ld	a0, 0x38(sp)
40000b1e: 0a056cb3     	max	s9, a0, zero
40000b22: 0ff97913     	zext.b	s2, s2
40000b26: 75c2         	ld	a1, 0x30(sp)
40000b28: 40b009bb     	negw	s3, a1
40000b2c: 419504bb     	subw	s1, a0, s9
40000b30: 557d         	li	a0, -0x1
40000b32: 00ac9963     	bne	s9, a0, 0x40000b44 <vfprintf+0x7e0>
40000b36: 02e00513     	li	a0, 0x2e
40000b3a: 85d2         	mv	a1, s4
40000b3c: 9b82         	jalr	s7
40000b3e: 26054b63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000b42: 0b05         	addi	s6, s6, 0x1
40000b44: 03000513     	li	a0, 0x30
40000b48: 0004c963     	bltz	s1, 0x40000b5a <vfprintf+0x7f6>
40000b4c: 0124d763     	bge	s1, s2, 0x40000b5a <vfprintf+0x7f6>
40000b50: 07510513     	addi	a0, sp, 0x75
40000b54: 9526         	add	a0, a0, s1
40000b56: 00054503     	lbu	a0, 0x0(a0)
40000b5a: 0199da63     	bge	s3, s9, 0x40000b6e <vfprintf+0x80a>
40000b5e: 3cfd         	addiw	s9, s9, -0x1
40000b60: 0b05         	addi	s6, s6, 0x1
40000b62: 85d2         	mv	a1, s4
40000b64: 9b82         	jalr	s7
40000b66: 2485         	addiw	s1, s1, 0x1
40000b68: fc0554e3     	bgez	a0, 0x40000b30 <vfprintf+0x7cc>
40000b6c: a4a1         	j	0x40000db4 <vfprintf+0xa50>
40000b6e: 85d2         	mv	a1, s4
40000b70: 9b82         	jalr	s7
40000b72: 24054163     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000b76: 010df593     	andi	a1, s11, 0x10
40000b7a: 001b051b     	addiw	a0, s6, 0x1
40000b7e: 22058963     	beqz	a1, 0x40000db0 <vfprintf+0xa4c>
40000b82: 220c9563     	bnez	s9, 0x40000dac <vfprintf+0xa48>
40000b86: 02e00513     	li	a0, 0x2e
40000b8a: 85d2         	mv	a1, s4
40000b8c: 9b82         	jalr	s7
40000b8e: 22054363     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000b92: 2b09         	addiw	s6, s6, 0x2
40000b94: aae5         	j	0x40000d8c <vfprintf+0xa28>
40000b96: 010df513     	andi	a0, s11, 0x10
40000b9a: 10051763     	bnez	a0, 0x40000ca8 <vfprintf+0x944>
40000b9e: 0b05         	addi	s6, s6, 0x1
40000ba0: aa19         	j	0x40000cb6 <vfprintf+0x952>
40000ba2: 60451593     	sext.b	a1, a0
40000ba6: c60597e3     	bnez	a1, 0x40000814 <vfprintf+0x4b0>
40000baa: 040df613     	andi	a2, s11, 0x40
40000bae: 4501         	li	a0, 0x0
40000bb0: c60606e3     	beqz	a2, 0x4000081c <vfprintf+0x4b8>
40000bb4: c79044e3     	bgtz	s9, 0x4000081c <vfprintf+0x4b8>
40000bb8: 4c01         	li	s8, 0x0
40000bba: 4501         	li	a0, 0x0
40000bbc: 65c1         	lui	a1, 0x10
40000bbe: 15b9         	addi	a1, a1, -0x12
40000bc0: 00bdf933     	and	s2, s11, a1
40000bc4: 01097d93     	andi	s11, s2, 0x10
40000bc8: 08094cbb     	zext.h	s9, s2
40000bcc: d80d83e3     	beqz	s11, 0x40000952 <vfprintf+0x5ee>
40000bd0: 008035b3     	snez	a1, s0
40000bd4: 0585         	addi	a1, a1, 0x1
40000bd6: 008cf613     	andi	a2, s9, 0x8
40000bda: 00a5893b     	addw	s2, a1, a0
40000bde: ea15         	bnez	a2, 0x40000c12 <vfprintf+0x8ae>
40000be0: 001cf513     	andi	a0, s9, 0x1
40000be4: c909         	beqz	a0, 0x40000bf6 <vfprintf+0x892>
40000be6: 8d62         	mv	s10, s8
40000be8: 01395763     	bge	s2, s3, 0x40000bf6 <vfprintf+0x892>
40000bec: 013c0533     	add	a0, s8, s3
40000bf0: 41250d3b     	subw	s10, a0, s2
40000bf4: a831         	j	0x40000c10 <vfprintf+0x8ac>
40000bf6: 01395e63     	bge	s2, s3, 0x40000c12 <vfprintf+0x8ae>
40000bfa: 412984bb     	subw	s1, s3, s2
40000bfe: 9b26         	add	s6, s6, s1
40000c00: 02000513     	li	a0, 0x20
40000c04: 85d2         	mv	a1, s4
40000c06: 9b82         	jalr	s7
40000c08: 1a054663     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000c0c: 34fd         	addiw	s1, s1, -0x1
40000c0e: f8ed         	bnez	s1, 0x40000c00 <vfprintf+0x89c>
40000c10: 894e         	mv	s2, s3
40000c12: 000d9b63     	bnez	s11, 0x40000c28 <vfprintf+0x8c4>
40000c16: 406cf513     	andi	a0, s9, 0x406
40000c1a: c505         	beqz	a0, 0x40000c42 <vfprintf+0x8de>
40000c1c: 002cf513     	andi	a0, s9, 0x2
40000c20: cd1d         	beqz	a0, 0x40000c5e <vfprintf+0x8fa>
40000c22: 02b00513     	li	a0, 0x2b
40000c26: a835         	j	0x40000c62 <vfprintf+0x8fe>
40000c28: 03000513     	li	a0, 0x30
40000c2c: 85d2         	mv	a1, s4
40000c2e: 9b82         	jalr	s7
40000c30: 18054263     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000c34: c021         	beqz	s0, 0x40000c74 <vfprintf+0x910>
40000c36: 8522         	mv	a0, s0
40000c38: 85d2         	mv	a1, s4
40000c3a: 9b82         	jalr	s7
40000c3c: 16054c63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000c40: 0b09         	addi	s6, s6, 0x2
40000c42: 846a         	mv	s0, s10
40000c44: 84ea         	mv	s1, s10
40000c46: 03ac5c63     	bge	s8, s10, 0x40000c7e <vfprintf+0x91a>
40000c4a: 03000513     	li	a0, 0x30
40000c4e: 85d2         	mv	a1, s4
40000c50: 9b82         	jalr	s7
40000c52: 16054163     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000c56: 347d         	addiw	s0, s0, -0x1
40000c58: fe8c49e3     	blt	s8, s0, 0x40000c4a <vfprintf+0x8e6>
40000c5c: a00d         	j	0x40000c7e <vfprintf+0x91a>
40000c5e: 02000513     	li	a0, 0x20
40000c62: 400cf593     	andi	a1, s9, 0x400
40000c66: c199         	beqz	a1, 0x40000c6c <vfprintf+0x908>
40000c68: 02d00513     	li	a0, 0x2d
40000c6c: 85d2         	mv	a1, s4
40000c6e: 9b82         	jalr	s7
40000c70: 14054263     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000c74: 0b05         	addi	s6, s6, 0x1
40000c76: 846a         	mv	s0, s10
40000c78: 84ea         	mv	s1, s10
40000c7a: fdac48e3     	blt	s8, s10, 0x40000c4a <vfprintf+0x8e6>
40000c7e: 41298d3b     	subw	s10, s3, s2
40000c82: 0a9c6533     	max	a0, s8, s1
40000c86: 00ab0b3b     	addw	s6, s6, a0
40000c8a: 418004b3     	neg	s1, s8
40000c8e: 06f10513     	addi	a0, sp, 0x6f
40000c92: 9c2a         	add	s8, s8, a0
40000c94: cce5         	beqz	s1, 0x40000d8c <vfprintf+0xa28>
40000c96: 000c4503     	lbu	a0, 0x0(s8)
40000c9a: 85d2         	mv	a1, s4
40000c9c: 9b82         	jalr	s7
40000c9e: 0485         	addi	s1, s1, 0x1
40000ca0: 1c7d         	addi	s8, s8, -0x1
40000ca2: fe0559e3     	bgez	a0, 0x40000c94 <vfprintf+0x930>
40000ca6: a239         	j	0x40000db4 <vfprintf+0xa50>
40000ca8: 02e00513     	li	a0, 0x2e
40000cac: 85d2         	mv	a1, s4
40000cae: 9b82         	jalr	s7
40000cb0: 10054263     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000cb4: 0b09         	addi	s6, s6, 0x2
40000cb6: 7502         	ld	a0, 0x20(sp)
40000cb8: 4195053b     	subw	a0, a0, s9
40000cbc: 0ff57513     	zext.b	a0, a0
40000cc0: 85d2         	mv	a1, s4
40000cc2: 9b82         	jalr	s7
40000cc4: 0e054863     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000cc8: 7562         	ld	a0, 0x38(sp)
40000cca: 9179         	srli	a0, a0, 0x3e
40000ccc: 8909         	andi	a0, a0, 0x2
40000cce: 02b50513     	addi	a0, a0, 0x2b
40000cd2: 85d2         	mv	a1, s4
40000cd4: 9b82         	jalr	s7
40000cd6: 0c054f63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000cda: 75e2         	ld	a1, 0x38(sp)
40000cdc: 40b0053b     	negw	a0, a1
40000ce0: 0aa5e933     	max	s2, a1, a0
40000ce4: 83000513     	li	a0, -0x7d0
40000ce8: 65e2         	ld	a1, 0x18(sp)
40000cea: 02b56863     	bltu	a0, a1, 0x40000d1a <vfprintf+0x9b6>
40000cee: 02091513     	slli	a0, s2, 0x20
40000cf2: 6586         	ld	a1, 0x40(sp)
40000cf4: 02b534b3     	mulhu	s1, a0, a1
40000cf8: 9099         	srli	s1, s1, 0x26
40000cfa: 03048513     	addi	a0, s1, 0x30
40000cfe: 0ff57513     	zext.b	a0, a0
40000d02: 85d2         	mv	a1, s4
40000d04: 9b82         	jalr	s7
40000d06: 0a054763     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000d0a: 3e800513     	li	a0, 0x3e8
40000d0e: 02a48533     	mul	a0, s1, a0
40000d12: 0b0d         	addi	s6, s6, 0x3
40000d14: 40a9093b     	subw	s2, s2, a0
40000d18: a039         	j	0x40000d26 <vfprintf+0x9c2>
40000d1a: 0b09         	addi	s6, s6, 0x2
40000d1c: f3800513     	li	a0, -0xc8
40000d20: 65a2         	ld	a1, 0x8(sp)
40000d22: 08b56063     	bltu	a0, a1, 0x40000da2 <vfprintf+0xa3e>
40000d26: 02091513     	slli	a0, s2, 0x20
40000d2a: 65a6         	ld	a1, 0x48(sp)
40000d2c: 02b534b3     	mulhu	s1, a0, a1
40000d30: 9095         	srli	s1, s1, 0x25
40000d32: 03048513     	addi	a0, s1, 0x30
40000d36: 0ff57513     	zext.b	a0, a0
40000d3a: 85d2         	mv	a1, s4
40000d3c: 9b82         	jalr	s7
40000d3e: 06054b63     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000d42: 06400513     	li	a0, 0x64
40000d46: 02a48533     	mul	a0, s1, a0
40000d4a: 0b05         	addi	s6, s6, 0x1
40000d4c: 40a9093b     	subw	s2, s2, a0
40000d50: 02091513     	slli	a0, s2, 0x20
40000d54: 65c6         	ld	a1, 0x50(sp)
40000d56: 02b534b3     	mulhu	s1, a0, a1
40000d5a: 908d         	srli	s1, s1, 0x23
40000d5c: 03048513     	addi	a0, s1, 0x30
40000d60: 0ff57513     	zext.b	a0, a0
40000d64: 85d2         	mv	a1, s4
40000d66: 9b82         	jalr	s7
40000d68: 04054663     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000d6c: 0b05         	addi	s6, s6, 0x1
40000d6e: 00149513     	slli	a0, s1, 0x1
40000d72: 048e         	slli	s1, s1, 0x3
40000d74: 9526         	add	a0, a0, s1
40000d76: 40a9093b     	subw	s2, s2, a0
40000d7a: 03090513     	addi	a0, s2, 0x30
40000d7e: 0ff57513     	zext.b	a0, a0
40000d82: 85d2         	mv	a1, s4
40000d84: 9b82         	jalr	s7
40000d86: 02054763     	bltz	a0, 0x40000db4 <vfprintf+0xa50>
40000d8a: 2b05         	addiw	s6, s6, 0x1
40000d8c: e5a05263     	blez	s10, 0x400003d0 <vfprintf+0x6c>
40000d90: 3d7d         	addiw	s10, s10, -0x1
40000d92: 2b05         	addiw	s6, s6, 0x1
40000d94: 02000513     	li	a0, 0x20
40000d98: 85d2         	mv	a1, s4
40000d9a: 9b82         	jalr	s7
40000d9c: fe0558e3     	bgez	a0, 0x40000d8c <vfprintf+0xa28>
40000da0: a811         	j	0x40000db4 <vfprintf+0xa50>
40000da2: 4509         	li	a0, 0x2
40000da4: 6582         	ld	a1, 0x0(sp)
40000da6: faa5f5e3     	bgeu	a1, a0, 0x40000d50 <vfprintf+0x9ec>
40000daa: bfc1         	j	0x40000d7a <vfprintf+0xa16>
40000dac: 8b2a         	mv	s6, a0
40000dae: bff9         	j	0x40000d8c <vfprintf+0xa28>
40000db0: 8b2a         	mv	s6, a0
40000db2: bfe9         	j	0x40000d8c <vfprintf+0xa28>
40000db4: 002a4503     	lbu	a0, 0x2(s4)
40000db8: 00456513     	ori	a0, a0, 0x4
40000dbc: 00aa0123     	sb	a0, 0x2(s4)
40000dc0: 5b7d         	li	s6, -0x1
40000dc2: 855a         	mv	a0, s6
40000dc4: 70ee         	ld	ra, 0xf8(sp)
40000dc6: 744e         	ld	s0, 0xf0(sp)
40000dc8: 74ae         	ld	s1, 0xe8(sp)
40000dca: 790e         	ld	s2, 0xe0(sp)
40000dcc: 69ee         	ld	s3, 0xd8(sp)
40000dce: 6a4e         	ld	s4, 0xd0(sp)
40000dd0: 6aae         	ld	s5, 0xc8(sp)
40000dd2: 6b0e         	ld	s6, 0xc0(sp)
40000dd4: 7bea         	ld	s7, 0xb8(sp)
40000dd6: 7c4a         	ld	s8, 0xb0(sp)
40000dd8: 7caa         	ld	s9, 0xa8(sp)
40000dda: 7d0a         	ld	s10, 0xa0(sp)
40000ddc: 6dea         	ld	s11, 0x98(sp)
40000dde: 6111         	addi	sp, sp, 0x100
40000de0: 8082         	ret

0000000040000de2 <skip_to_arg>:
40000de2: 4689         	li	a3, 0x2
40000de4: 12d64263     	blt	a2, a3, 0x40000f08 <skip_to_arg+0x126>
40000de8: 1101         	addi	sp, sp, -0x20
40000dea: ec22         	sd	s0, 0x18(sp)
40000dec: e826         	sd	s1, 0x10(sp)
40000dee: e44a         	sd	s2, 0x8(sp)
40000df0: e04e         	sd	s3, 0x0(sp)
40000df2: 4805         	li	a6, 0x1
40000df4: 02500993     	li	s3, 0x25
40000df8: 497d         	li	s2, 0x1f
40000dfa: 03000893     	li	a7, 0x30
40000dfe: 12889f37     	lui	t5, 0x12889
40000e02: 0f52         	slli	t5, t5, 0x14
40000e04: 42a5         	li	t0, 0x9
40000e06: 05600313     	li	t1, 0x56
40000e0a: 00004697     	auipc	a3, 0x4
40000e0e: cc668393     	addi	t2, a3, -0x33a
40000e12: 07f00e13     	li	t3, 0x7f
40000e16: 02e00e93     	li	t4, 0x2e
40000e1a: 86aa         	mv	a3, a0
40000e1c: 8736         	mv	a4, a3
40000e1e: a801         	j	0x40000e2e <skip_to_arg+0x4c>
40000e20: 00270693     	addi	a3, a4, 0x2
40000e24: 00174783     	lbu	a5, 0x1(a4)
40000e28: 8736         	mv	a4, a3
40000e2a: 01379963     	bne	a5, s3, 0x40000e3c <skip_to_arg+0x5a>
40000e2e: 00074683     	lbu	a3, 0x0(a4)
40000e32: ff3687e3     	beq	a3, s3, 0x40000e20 <skip_to_arg+0x3e>
40000e36: 0705         	addi	a4, a4, 0x1
40000e38: fafd         	bnez	a3, 0x40000e2e <skip_to_arg+0x4c>
40000e3a: a0d1         	j	0x40000efe <skip_to_arg+0x11c>
40000e3c: 4401         	li	s0, 0x0
40000e3e: 4f81         	li	t6, 0x0
40000e40: 4701         	li	a4, 0x0
40000e42: a809         	j	0x40000e54 <skip_to_arg+0x72>
40000e44: 08046413     	ori	s0, s0, 0x80
40000e48: 84ba         	mv	s1, a4
40000e4a: 0006c783     	lbu	a5, 0x0(a3)
40000e4e: 0685         	addi	a3, a3, 0x1
40000e50: 8726         	mv	a4, s1
40000e52: cbd9         	beqz	a5, 0x40000ee8 <skip_to_arg+0x106>
40000e54: 00896863     	bltu	s2, s0, 0x40000e64 <skip_to_arg+0x82>
40000e58: 00f8e863     	bltu	a7, a5, 0x40000e68 <skip_to_arg+0x86>
40000e5c: 48ff54b3     	bext	s1, t5, a5
40000e60: f4e5         	bnez	s1, 0x40000e48 <skip_to_arg+0x66>
40000e62: a019         	j	0x40000e68 <skip_to_arg+0x86>
40000e64: 028e6063     	bltu	t3, s0, 0x40000e84 <skip_to_arg+0xa2>
40000e68: 0ff7f493     	zext.b	s1, a5
40000e6c: fd048493     	addi	s1, s1, -0x30
40000e70: 0292e663     	bltu	t0, s1, 0x40000e9c <skip_to_arg+0xba>
40000e74: 00171793     	slli	a5, a4, 0x1
40000e78: 070e         	slli	a4, a4, 0x3
40000e7a: 973e         	add	a4, a4, a5
40000e7c: 9cb9         	addw	s1, s1, a4
40000e7e: 02046413     	ori	s0, s0, 0x20
40000e82: b7e1         	j	0x40000e4a <skip_to_arg+0x68>
40000e84: fb478793     	addi	a5, a5, -0x4c
40000e88: 06fee063     	bltu	t4, a5, 0x40000ee8 <skip_to_arg+0x106>
40000e8c: 078e         	slli	a5, a5, 0x3
40000e8e: 00004497     	auipc	s1, 0x4
40000e92: aca48493     	addi	s1, s1, -0x536
40000e96: 97a6         	add	a5, a5, s1
40000e98: 639c         	ld	a5, 0x0(a5)
40000e9a: 8782         	jr	a5
40000e9c: fdc78793     	addi	a5, a5, -0x24
40000ea0: 04f36463     	bltu	t1, a5, 0x40000ee8 <skip_to_arg+0x106>
40000ea4: 078e         	slli	a5, a5, 0x3
40000ea6: 979e         	add	a5, a5, t2
40000ea8: 639c         	ld	a5, 0x0(a5)
40000eaa: 4481         	li	s1, 0x0
40000eac: 8782         	jr	a5
40000eae: 020f9863     	bnez	t6, 0x40000ede <skip_to_arg+0xfc>
40000eb2: 4481         	li	s1, 0x0
40000eb4: 8fba         	mv	t6, a4
40000eb6: bf51         	j	0x40000e4a <skip_to_arg+0x68>
40000eb8: 00241793     	slli	a5, s0, 0x2
40000ebc: 2007f793     	andi	a5, a5, 0x200
40000ec0: 8fc1         	or	a5, a5, s0
40000ec2: 0807e413     	ori	s0, a5, 0x80
40000ec6: b749         	j	0x40000e48 <skip_to_arg+0x66>
40000ec8: 28046413     	ori	s0, s0, 0x280
40000ecc: bfb5         	j	0x40000e48 <skip_to_arg+0x66>
40000ece: 00141793     	slli	a5, s0, 0x1
40000ed2: 2007f793     	andi	a5, a5, 0x200
40000ed6: 8fc1         	or	a5, a5, s0
40000ed8: 1007e413     	ori	s0, a5, 0x100
40000edc: b7b5         	j	0x40000e48 <skip_to_arg+0x66>
40000ede: 01070463     	beq	a4, a6, 0x40000ee6 <skip_to_arg+0x104>
40000ee2: 4481         	li	s1, 0x0
40000ee4: b79d         	j	0x40000e4a <skip_to_arg+0x68>
40000ee6: 8fc2         	mv	t6, a6
40000ee8: 000f8b63     	beqz	t6, 0x40000efe <skip_to_arg+0x11c>
40000eec: 010f9763     	bne	t6, a6, 0x40000efa <skip_to_arg+0x118>
40000ef0: 6194         	ld	a3, 0x0(a1)
40000ef2: 06a1         	addi	a3, a3, 0x8
40000ef4: e194         	sd	a3, 0x0(a1)
40000ef6: 2805         	addiw	a6, a6, 0x1
40000ef8: 86aa         	mv	a3, a0
40000efa: f2c841e3     	blt	a6, a2, 0x40000e1c <skip_to_arg+0x3a>
40000efe: 6462         	ld	s0, 0x18(sp)
40000f00: 64c2         	ld	s1, 0x10(sp)
40000f02: 6922         	ld	s2, 0x8(sp)
40000f04: 6982         	ld	s3, 0x0(sp)
40000f06: 6105         	addi	sp, sp, 0x20
40000f08: 8082         	ret

0000000040000f0a <__ultoa_invert>:
40000f0a: 01f67893     	andi	a7, a2, 0x1f
40000f0e: 4825         	li	a6, 0x9
40000f10: a811         	j	0x40000f24 <__ultoa_invert+0x1a>
40000f12: 03068713     	addi	a4, a3, 0x30
40000f16: 00158693     	addi	a3, a1, 0x1
40000f1a: 00e58023     	sb	a4, 0x0(a1)
40000f1e: 85b6         	mv	a1, a3
40000f20: 0117ef63     	bltu	a5, a7, 0x40000f3e <__ultoa_invert+0x34>
40000f24: 87aa         	mv	a5, a0
40000f26: 03155533     	divu	a0, a0, a7
40000f2a: 031506b3     	mul	a3, a0, a7
40000f2e: 40d786b3     	sub	a3, a5, a3
40000f32: fed870e3     	bgeu	a6, a3, 0x40000f12 <__ultoa_invert+0x8>
40000f36: 8e91         	sub	a3, a3, a2
40000f38: 03768693     	addi	a3, a3, 0x37
40000f3c: bfd9         	j	0x40000f12 <__ultoa_invert+0x8>
40000f3e: 8536         	mv	a0, a3
40000f40: 8082         	ret

0000000040000f42 <__dtox_engine>:
40000f42: 82b2         	mv	t0, a2
40000f44: 03f55713     	srli	a4, a0, 0x3f
40000f48: 00e58223     	sb	a4, 0x4(a1)
40000f4c: 00151793     	slli	a5, a0, 0x1
40000f50: 0532         	slli	a0, a0, 0xc
40000f52: 8131         	srli	a0, a0, 0xc
40000f54: 93d5         	srli	a5, a5, 0x35
40000f56: e10d         	bnez	a0, 0x40000f78 <__dtox_engine+0x36>
40000f58: e385         	bnez	a5, 0x40000f78 <__dtox_engine+0x36>
40000f5a: 4881         	li	a7, 0x0
40000f5c: 0005a023     	sw	zero, 0x0(a1)
40000f60: 1602c663     	bltz	t0, 0x400010cc <__dtox_engine+0x18a>
40000f64: 4535         	li	a0, 0xd
40000f66: 04a2e263     	bltu	t0, a0, 0x40000faa <__dtox_engine+0x68>
40000f6a: 00558813     	addi	a6, a1, 0x5
40000f6e: 00f8f793     	andi	a5, a7, 0xf
40000f72: 0048d713     	srli	a4, a7, 0x4
40000f76: a29d         	j	0x400010dc <__dtox_engine+0x19a>
40000f78: 7ff00613     	li	a2, 0x7ff
40000f7c: 00c79a63     	bne	a5, a2, 0x40000f90 <__dtox_engine+0x4e>
40000f80: 12051863     	bnez	a0, 0x400010b0 <__dtox_engine+0x16e>
40000f84: 4511         	li	a0, 0x4
40000f86: 8d59         	or	a0, a0, a4
40000f88: 00a58223     	sb	a0, 0x4(a1)
40000f8c: 4501         	li	a0, 0x0
40000f8e: 8082         	ret
40000f90: 00f03833     	snez	a6, a5
40000f94: 12079463     	bnez	a5, 0x400010bc <__dtox_engine+0x17a>
40000f98: c0200713     	li	a4, -0x3fe
40000f9c: 1852         	slli	a6, a6, 0x34
40000f9e: 010568b3     	or	a7, a0, a6
40000fa2: c198         	sw	a4, 0x0(a1)
40000fa4: fc02d0e3     	bgez	t0, 0x40000f64 <__dtox_engine+0x22>
40000fa8: a215         	j	0x400010cc <__dtox_engine+0x18a>
40000faa: 00229793     	slli	a5, t0, 0x2
40000fae: 03300513     	li	a0, 0x33
40000fb2: 9d1d         	subw	a0, a0, a5
40000fb4: 28a01733     	bset	a4, zero, a0
40000fb8: 4609         	li	a2, 0x2
40000fba: 00a61533     	sll	a0, a2, a0
40000fbe: fff50613     	addi	a2, a0, -0x1
40000fc2: 00c8f633     	and	a2, a7, a2
40000fc6: 40a00833     	neg	a6, a0
40000fca: 00c76863     	bltu	a4, a2, 0x40000fda <__dtox_engine+0x98>
40000fce: 03400513     	li	a0, 0x34
40000fd2: 9d1d         	subw	a0, a0, a5
40000fd4: 48a8d533     	bext	a0, a7, a0
40000fd8: c111         	beqz	a0, 0x40000fdc <__dtox_engine+0x9a>
40000fda: 98ba         	add	a7, a7, a4
40000fdc: 0108f8b3     	and	a7, a7, a6
40000fe0: 00558813     	addi	a6, a1, 0x5
40000fe4: 00f8f793     	andi	a5, a7, 0xf
40000fe8: 0048d713     	srli	a4, a7, 0x4
40000fec: ebe5         	bnez	a5, 0x400010dc <__dtox_engine+0x19a>
40000fee: 8b3d         	andi	a4, a4, 0xf
40000ff0: 0088d793     	srli	a5, a7, 0x8
40000ff4: 10071263     	bnez	a4, 0x400010f8 <__dtox_engine+0x1b6>
40000ff8: 4531         	li	a0, 0xc
40000ffa: 0ea2ff63     	bgeu	t0, a0, 0x400010f8 <__dtox_engine+0x1b6>
40000ffe: 8bbd         	andi	a5, a5, 0xf
40001000: 00c8d713     	srli	a4, a7, 0xc
40001004: 10079a63     	bnez	a5, 0x40001118 <__dtox_engine+0x1d6>
40001008: 452d         	li	a0, 0xb
4000100a: 10a2f763     	bgeu	t0, a0, 0x40001118 <__dtox_engine+0x1d6>
4000100e: 00f77793     	andi	a5, a4, 0xf
40001012: 0108d713     	srli	a4, a7, 0x10
40001016: 12079263     	bnez	a5, 0x4000113a <__dtox_engine+0x1f8>
4000101a: 4529         	li	a0, 0xa
4000101c: 10a2ff63     	bgeu	t0, a0, 0x4000113a <__dtox_engine+0x1f8>
40001020: 00f77793     	andi	a5, a4, 0xf
40001024: 0148d713     	srli	a4, a7, 0x14
40001028: 12079a63     	bnez	a5, 0x4000115c <__dtox_engine+0x21a>
4000102c: 4525         	li	a0, 0x9
4000102e: 12a2f763     	bgeu	t0, a0, 0x4000115c <__dtox_engine+0x21a>
40001032: 00f77793     	andi	a5, a4, 0xf
40001036: 0188d713     	srli	a4, a7, 0x18
4000103a: 14079163     	bnez	a5, 0x4000117c <__dtox_engine+0x23a>
4000103e: 4521         	li	a0, 0x8
40001040: 12a2fe63     	bgeu	t0, a0, 0x4000117c <__dtox_engine+0x23a>
40001044: 00f77793     	andi	a5, a4, 0xf
40001048: 01c8d713     	srli	a4, a7, 0x1c
4000104c: 14079963     	bnez	a5, 0x4000119e <__dtox_engine+0x25c>
40001050: 451d         	li	a0, 0x7
40001052: 14a2f663     	bgeu	t0, a0, 0x4000119e <__dtox_engine+0x25c>
40001056: 00f77793     	andi	a5, a4, 0xf
4000105a: 0208d713     	srli	a4, a7, 0x20
4000105e: 16079163     	bnez	a5, 0x400011c0 <__dtox_engine+0x27e>
40001062: 4519         	li	a0, 0x6
40001064: 14a2fe63     	bgeu	t0, a0, 0x400011c0 <__dtox_engine+0x27e>
40001068: 00f77793     	andi	a5, a4, 0xf
4000106c: 0248d713     	srli	a4, a7, 0x24
40001070: 16079963     	bnez	a5, 0x400011e2 <__dtox_engine+0x2a0>
40001074: 4515         	li	a0, 0x5
40001076: 16a2f663     	bgeu	t0, a0, 0x400011e2 <__dtox_engine+0x2a0>
4000107a: 00f77793     	andi	a5, a4, 0xf
4000107e: 0288d713     	srli	a4, a7, 0x28
40001082: 18079163     	bnez	a5, 0x40001204 <__dtox_engine+0x2c2>
40001086: 4511         	li	a0, 0x4
40001088: 16a2fe63     	bgeu	t0, a0, 0x40001204 <__dtox_engine+0x2c2>
4000108c: 00f77793     	andi	a5, a4, 0xf
40001090: 02c8d713     	srli	a4, a7, 0x2c
40001094: 18079963     	bnez	a5, 0x40001226 <__dtox_engine+0x2e4>
40001098: 450d         	li	a0, 0x3
4000109a: 18a2f663     	bgeu	t0, a0, 0x40001226 <__dtox_engine+0x2e4>
4000109e: 8b3d         	andi	a4, a4, 0xf
400010a0: 0308d793     	srli	a5, a7, 0x30
400010a4: 1a071163     	bnez	a4, 0x40001246 <__dtox_engine+0x304>
400010a8: 4509         	li	a0, 0x2
400010aa: 1aa2eb63     	bltu	t0, a0, 0x40001260 <__dtox_engine+0x31e>
400010ae: aa61         	j	0x40001246 <__dtox_engine+0x304>
400010b0: 4521         	li	a0, 0x8
400010b2: 8d59         	or	a0, a0, a4
400010b4: 00a58223     	sb	a0, 0x4(a1)
400010b8: 4501         	li	a0, 0x0
400010ba: 8082         	ret
400010bc: c0178713     	addi	a4, a5, -0x3ff
400010c0: 1852         	slli	a6, a6, 0x34
400010c2: 010568b3     	or	a7, a0, a6
400010c6: c198         	sw	a4, 0x0(a1)
400010c8: e802dee3     	bgez	t0, 0x40000f64 <__dtox_engine+0x22>
400010cc: 4281         	li	t0, 0x0
400010ce: 00558813     	addi	a6, a1, 0x5
400010d2: 00f8f793     	andi	a5, a7, 0xf
400010d6: 0048d713     	srli	a4, a7, 0x4
400010da: db91         	beqz	a5, 0x40000fee <__dtox_engine+0xac>
400010dc: 4525         	li	a0, 0x9
400010de: 00f57563     	bgeu	a0, a5, 0x400010e8 <__dtox_engine+0x1a6>
400010e2: 8f95         	sub	a5, a5, a3
400010e4: 02778793     	addi	a5, a5, 0x27
400010e8: 03078513     	addi	a0, a5, 0x30
400010ec: 00a58923     	sb	a0, 0x12(a1)
400010f0: 8b3d         	andi	a4, a4, 0xf
400010f2: 0088d793     	srli	a5, a7, 0x8
400010f6: 42b5         	li	t0, 0xd
400010f8: 4525         	li	a0, 0x9
400010fa: 00e57563     	bgeu	a0, a4, 0x40001104 <__dtox_engine+0x1c2>
400010fe: 8f15         	sub	a4, a4, a3
40001100: 02770713     	addi	a4, a4, 0x27
40001104: 03070513     	addi	a0, a4, 0x30
40001108: 00a588a3     	sb	a0, 0x11(a1)
4000110c: 4531         	li	a0, 0xc
4000110e: 0aa2f2b3     	maxu	t0, t0, a0
40001112: 8bbd         	andi	a5, a5, 0xf
40001114: 00c8d713     	srli	a4, a7, 0xc
40001118: 4525         	li	a0, 0x9
4000111a: 00f57563     	bgeu	a0, a5, 0x40001124 <__dtox_engine+0x1e2>
4000111e: 8f95         	sub	a5, a5, a3
40001120: 02778793     	addi	a5, a5, 0x27
40001124: 03078513     	addi	a0, a5, 0x30
40001128: 00a58823     	sb	a0, 0x10(a1)
4000112c: 452d         	li	a0, 0xb
4000112e: 0aa2f2b3     	maxu	t0, t0, a0
40001132: 00f77793     	andi	a5, a4, 0xf
40001136: 0108d713     	srli	a4, a7, 0x10
4000113a: 4525         	li	a0, 0x9
4000113c: 00f57563     	bgeu	a0, a5, 0x40001146 <__dtox_engine+0x204>
40001140: 8f95         	sub	a5, a5, a3
40001142: 02778793     	addi	a5, a5, 0x27
40001146: 03078513     	addi	a0, a5, 0x30
4000114a: 00a587a3     	sb	a0, 0xf(a1)
4000114e: 4529         	li	a0, 0xa
40001150: 0aa2f2b3     	maxu	t0, t0, a0
40001154: 00f77793     	andi	a5, a4, 0xf
40001158: 0148d713     	srli	a4, a7, 0x14
4000115c: 4525         	li	a0, 0x9
4000115e: 00f57563     	bgeu	a0, a5, 0x40001168 <__dtox_engine+0x226>
40001162: 8f95         	sub	a5, a5, a3
40001164: 02778793     	addi	a5, a5, 0x27
40001168: 03078613     	addi	a2, a5, 0x30
4000116c: 00c58723     	sb	a2, 0xe(a1)
40001170: 0aa2f2b3     	maxu	t0, t0, a0
40001174: 00f77793     	andi	a5, a4, 0xf
40001178: 0188d713     	srli	a4, a7, 0x18
4000117c: 4525         	li	a0, 0x9
4000117e: 00f57563     	bgeu	a0, a5, 0x40001188 <__dtox_engine+0x246>
40001182: 8f95         	sub	a5, a5, a3
40001184: 02778793     	addi	a5, a5, 0x27
40001188: 03078513     	addi	a0, a5, 0x30
4000118c: 00a586a3     	sb	a0, 0xd(a1)
40001190: 4521         	li	a0, 0x8
40001192: 0aa2f2b3     	maxu	t0, t0, a0
40001196: 00f77793     	andi	a5, a4, 0xf
4000119a: 01c8d713     	srli	a4, a7, 0x1c
4000119e: 4525         	li	a0, 0x9
400011a0: 00f57563     	bgeu	a0, a5, 0x400011aa <__dtox_engine+0x268>
400011a4: 8f95         	sub	a5, a5, a3
400011a6: 02778793     	addi	a5, a5, 0x27
400011aa: 03078513     	addi	a0, a5, 0x30
400011ae: 00a58623     	sb	a0, 0xc(a1)
400011b2: 451d         	li	a0, 0x7
400011b4: 0aa2f2b3     	maxu	t0, t0, a0
400011b8: 00f77793     	andi	a5, a4, 0xf
400011bc: 0208d713     	srli	a4, a7, 0x20
400011c0: 4525         	li	a0, 0x9
400011c2: 00f57563     	bgeu	a0, a5, 0x400011cc <__dtox_engine+0x28a>
400011c6: 8f95         	sub	a5, a5, a3
400011c8: 02778793     	addi	a5, a5, 0x27
400011cc: 03078513     	addi	a0, a5, 0x30
400011d0: 00a585a3     	sb	a0, 0xb(a1)
400011d4: 4519         	li	a0, 0x6
400011d6: 0aa2f2b3     	maxu	t0, t0, a0
400011da: 00f77793     	andi	a5, a4, 0xf
400011de: 0248d713     	srli	a4, a7, 0x24
400011e2: 4525         	li	a0, 0x9
400011e4: 00f57563     	bgeu	a0, a5, 0x400011ee <__dtox_engine+0x2ac>
400011e8: 8f95         	sub	a5, a5, a3
400011ea: 02778793     	addi	a5, a5, 0x27
400011ee: 03078513     	addi	a0, a5, 0x30
400011f2: 00a58523     	sb	a0, 0xa(a1)
400011f6: 4515         	li	a0, 0x5
400011f8: 0aa2f2b3     	maxu	t0, t0, a0
400011fc: 00f77793     	andi	a5, a4, 0xf
40001200: 0288d713     	srli	a4, a7, 0x28
40001204: 4525         	li	a0, 0x9
40001206: 00f57563     	bgeu	a0, a5, 0x40001210 <__dtox_engine+0x2ce>
4000120a: 8f95         	sub	a5, a5, a3
4000120c: 02778793     	addi	a5, a5, 0x27
40001210: 03078513     	addi	a0, a5, 0x30
40001214: 00a584a3     	sb	a0, 0x9(a1)
40001218: 4511         	li	a0, 0x4
4000121a: 0aa2f2b3     	maxu	t0, t0, a0
4000121e: 00f77793     	andi	a5, a4, 0xf
40001222: 02c8d713     	srli	a4, a7, 0x2c
40001226: 4525         	li	a0, 0x9
40001228: 00f57563     	bgeu	a0, a5, 0x40001232 <__dtox_engine+0x2f0>
4000122c: 8f95         	sub	a5, a5, a3
4000122e: 02778793     	addi	a5, a5, 0x27
40001232: 03078513     	addi	a0, a5, 0x30
40001236: 00a58423     	sb	a0, 0x8(a1)
4000123a: 450d         	li	a0, 0x3
4000123c: 0aa2f2b3     	maxu	t0, t0, a0
40001240: 8b3d         	andi	a4, a4, 0xf
40001242: 0308d793     	srli	a5, a7, 0x30
40001246: 4525         	li	a0, 0x9
40001248: 00e57563     	bgeu	a0, a4, 0x40001252 <__dtox_engine+0x310>
4000124c: 8f15         	sub	a4, a4, a3
4000124e: 02770713     	addi	a4, a4, 0x27
40001252: 03070513     	addi	a0, a4, 0x30
40001256: 00a583a3     	sb	a0, 0x7(a1)
4000125a: 4509         	li	a0, 0x2
4000125c: 0aa2f2b3     	maxu	t0, t0, a0
40001260: 8bbd         	andi	a5, a5, 0xf
40001262: 0057e633     	or	a2, a5, t0
40001266: 0348d513     	srli	a0, a7, 0x34
4000126a: ce11         	beqz	a2, 0x40001286 <__dtox_engine+0x344>
4000126c: 4625         	li	a2, 0x9
4000126e: 00f67563     	bgeu	a2, a5, 0x40001278 <__dtox_engine+0x336>
40001272: 8f95         	sub	a5, a5, a3
40001274: 02778793     	addi	a5, a5, 0x27
40001278: 03078613     	addi	a2, a5, 0x30
4000127c: 00c58323     	sb	a2, 0x6(a1)
40001280: 4585         	li	a1, 0x1
40001282: 0ab2f2b3     	maxu	t0, t0, a1
40001286: 03050513     	addi	a0, a0, 0x30
4000128a: 00a80023     	sb	a0, 0x0(a6)
4000128e: 8516         	mv	a0, t0
40001290: 8082         	ret

0000000040001292 <strnlen>:
40001292: 862a         	mv	a2, a0
40001294: c999         	beqz	a1, 0x400012aa <strnlen+0x18>
40001296: 00b506b3     	add	a3, a0, a1
4000129a: 862a         	mv	a2, a0
4000129c: 00064703     	lbu	a4, 0x0(a2)
400012a0: c709         	beqz	a4, 0x400012aa <strnlen+0x18>
400012a2: 15fd         	addi	a1, a1, -0x1
400012a4: 0605         	addi	a2, a2, 0x1
400012a6: f9fd         	bnez	a1, 0x4000129c <strnlen+0xa>
400012a8: 8636         	mv	a2, a3
400012aa: 40a60533     	sub	a0, a2, a0
400012ae: 8082         	ret

00000000400012b0 <__dtoa_engine>:
400012b0: 7135         	addi	sp, sp, -0xa0
400012b2: ed06         	sd	ra, 0x98(sp)
400012b4: e922         	sd	s0, 0x90(sp)
400012b6: e526         	sd	s1, 0x88(sp)
400012b8: e14a         	sd	s2, 0x80(sp)
400012ba: fcce         	sd	s3, 0x78(sp)
400012bc: f8d2         	sd	s4, 0x70(sp)
400012be: f4d6         	sd	s5, 0x68(sp)
400012c0: f0da         	sd	s6, 0x60(sp)
400012c2: ecde         	sd	s7, 0x58(sp)
400012c4: e8e2         	sd	s8, 0x50(sp)
400012c6: e4e6         	sd	s9, 0x48(sp)
400012c8: e0ea         	sd	s10, 0x40(sp)
400012ca: fc6e         	sd	s11, 0x38(sp)
400012cc: 00c51793     	slli	a5, a0, 0xc
400012d0: 83b1         	srli	a5, a5, 0xc
400012d2: 00151493     	slli	s1, a0, 0x1
400012d6: 90d5         	srli	s1, s1, 0x35
400012d8: 03f55b13     	srli	s6, a0, 0x3f
400012dc: ef89         	bnez	a5, 0x400012f6 <__dtoa_engine+0x46>
400012de: ec81         	bnez	s1, 0x400012f6 <__dtoa_engine+0x46>
400012e0: 0b09         	addi	s6, s6, 0x2
400012e2: 03000513     	li	a0, 0x30
400012e6: 00a582a3     	sb	a0, 0x5(a1)
400012ea: 01658223     	sb	s6, 0x4(a1)
400012ee: 0005a023     	sw	zero, 0x0(a1)
400012f2: 4505         	li	a0, 0x1
400012f4: a1e5         	j	0x400017dc <__dtoa_engine+0x52c>
400012f6: 7ff00513     	li	a0, 0x7ff
400012fa: 00a49563     	bne	s1, a0, 0x40001304 <__dtoa_engine+0x54>
400012fe: cf81         	beqz	a5, 0x40001316 <__dtoa_engine+0x66>
40001300: 4621         	li	a2, 0x8
40001302: a819         	j	0x40001318 <__dtoa_engine+0x68>
40001304: 00903533     	snez	a0, s1
40001308: 1552         	slli	a0, a0, 0x34
4000130a: 00a7ec33     	or	s8, a5, a0
4000130e: e899         	bnez	s1, 0x40001324 <__dtoa_engine+0x74>
40001310: bcc00a93     	li	s5, -0x434
40001314: a811         	j	0x40001328 <__dtoa_engine+0x78>
40001316: 4611         	li	a2, 0x4
40001318: 4501         	li	a0, 0x0
4000131a: 01666633     	or	a2, a2, s6
4000131e: 00c58223     	sb	a2, 0x4(a1)
40001322: a96d         	j	0x400017dc <__dtoa_engine+0x52c>
40001324: bcb48a9b     	addiw	s5, s1, -0x435
40001328: ec36         	sd	a3, 0x18(sp)
4000132a: e83a         	sd	a4, 0x10(sp)
4000132c: 8bb2         	mv	s7, a2
4000132e: f02e         	sd	a1, 0x20(sp)
40001330: 001c7c93     	andi	s9, s8, 0x1
40001334: 0c0a         	slli	s8, s8, 0x2
40001336: 00f03533     	snez	a0, a5
4000133a: 0024b593     	sltiu	a1, s1, 0x2
4000133e: 00b56db3     	or	s11, a0, a1
40001342: 001cb513     	seqz	a0, s9
40001346: e42a         	sd	a0, 0x8(sp)
40001348: 002c0993     	addi	s3, s8, 0x2
4000134c: fffdc493     	not	s1, s11
40001350: 0a0ac563     	bltz	s5, 0x400013fa <__dtoa_engine+0x14a>
40001354: 8556         	mv	a0, s5
40001356: 4a4000ef     	jal	0x400017fa <__log10Pow2>
4000135a: 004ab593     	sltiu	a1, s5, 0x4
4000135e: 0015c593     	xori	a1, a1, 0x1
40001362: 40b5093b     	subw	s2, a0, a1
40001366: 854a         	mv	a0, s2
40001368: 4b4000ef     	jal	0x4000181c <__pow5bits>
4000136c: 8a2a         	mv	s4, a0
4000136e: 102c         	addi	a1, sp, 0x28
40001370: 854a         	mv	a0, s2
40001372: 61a000ef     	jal	0x4000198c <__double_computeInvPow5>
40001376: 77a2         	ld	a5, 0x28(sp)
40001378: 7442         	ld	s0, 0x30(sp)
4000137a: 033406b3     	mul	a3, s0, s3
4000137e: 0337b533     	mulhu	a0, a5, s3
40001382: 033435b3     	mulhu	a1, s0, s3
40001386: 00d508b3     	add	a7, a0, a3
4000138a: 00a8b533     	sltu	a0, a7, a0
4000138e: 00a58833     	add	a6, a1, a0
40001392: 4159063b     	subw	a2, s2, s5
40001396: 009c0533     	add	a0, s8, s1
4000139a: 02a405b3     	mul	a1, s0, a0
4000139e: 02a7b733     	mulhu	a4, a5, a0
400013a2: 9652         	add	a2, a2, s4
400013a4: 03c6061b     	addiw	a2, a2, 0x3c
400013a8: 02a434b3     	mulhu	s1, s0, a0
400013ac: 95ba         	add	a1, a1, a4
400013ae: 00e5b733     	sltu	a4, a1, a4
400013b2: 038406b3     	mul	a3, s0, s8
400013b6: 0387b7b3     	mulhu	a5, a5, s8
400013ba: 00e482b3     	add	t0, s1, a4
400013be: 038434b3     	mulhu	s1, s0, s8
400013c2: fc060713     	addi	a4, a2, -0x40
400013c6: 00d78433     	add	s0, a5, a3
400013ca: 00f436b3     	sltu	a3, s0, a5
400013ce: 94b6         	add	s1, s1, a3
400013d0: 0e074263     	bltz	a4, 0x400014b4 <__dtoa_engine+0x204>
400013d4: 00c85a33     	srl	s4, a6, a2
400013d8: 00c2dd33     	srl	s10, t0, a2
400013dc: 00c4d4b3     	srl	s1, s1, a2
400013e0: 82de         	mv	t0, s7
400013e2: 6842         	ld	a6, 0x10(sp)
400013e4: 68e2         	ld	a7, 0x18(sp)
400013e6: 45d5         	li	a1, 0x15
400013e8: 7302         	ld	t1, 0x20(sp)
400013ea: 1125f263     	bgeu	a1, s2, 0x400014ee <__dtoa_engine+0x23e>
400013ee: 4f01         	li	t5, 0x0
400013f0: 4e01         	li	t3, 0x0
400013f2: 8396         	mv	t2, t0
400013f4: 1c089d63     	bnez	a7, 0x400015ce <__dtoa_engine+0x31e>
400013f8: aafd         	j	0x400015f6 <__dtoa_engine+0x346>
400013fa: 4150043b     	negw	s0, s5
400013fe: 8522         	mv	a0, s0
40001400: 40a000ef     	jal	0x4000180a <__log10Pow5>
40001404: fffab593     	sltiu	a1, s5, -0x1
40001408: 40b5093b     	subw	s2, a0, a1
4000140c: 4124043b     	subw	s0, s0, s2
40001410: 8522         	mv	a0, s0
40001412: 40a000ef     	jal	0x4000181c <__pow5bits>
40001416: 8a2a         	mv	s4, a0
40001418: 102c         	addi	a1, sp, 0x28
4000141a: 8522         	mv	a0, s0
4000141c: 44c000ef     	jal	0x40001868 <__double_computePow5>
40001420: 7722         	ld	a4, 0x28(sp)
40001422: 77c2         	ld	a5, 0x30(sp)
40001424: 03378633     	mul	a2, a5, s3
40001428: 03373533     	mulhu	a0, a4, s3
4000142c: 0337b5b3     	mulhu	a1, a5, s3
40001430: 00c508b3     	add	a7, a0, a2
40001434: 00a8b533     	sltu	a0, a7, a0
40001438: 00a58833     	add	a6, a1, a0
4000143c: 94e2         	add	s1, s1, s8
4000143e: 02978433     	mul	s0, a5, s1
40001442: 029736b3     	mulhu	a3, a4, s1
40001446: 4149053b     	subw	a0, s2, s4
4000144a: 03d5051b     	addiw	a0, a0, 0x3d
4000144e: 0297b633     	mulhu	a2, a5, s1
40001452: 9436         	add	s0, s0, a3
40001454: 00d436b3     	sltu	a3, s0, a3
40001458: 038785b3     	mul	a1, a5, s8
4000145c: 038734b3     	mulhu	s1, a4, s8
40001460: 00d60733     	add	a4, a2, a3
40001464: 0387b7b3     	mulhu	a5, a5, s8
40001468: fc050613     	addi	a2, a0, -0x40
4000146c: 95a6         	add	a1, a1, s1
4000146e: 0095b6b3     	sltu	a3, a1, s1
40001472: 97b6         	add	a5, a5, a3
40001474: 0c064363     	bltz	a2, 0x4000153a <__dtoa_engine+0x28a>
40001478: 00a85a33     	srl	s4, a6, a0
4000147c: 00a75d33     	srl	s10, a4, a0
40001480: 00a7d4b3     	srl	s1, a5, a0
40001484: 82de         	mv	t0, s7
40001486: 6842         	ld	a6, 0x10(sp)
40001488: 68e2         	ld	a7, 0x18(sp)
4000148a: 4f05         	li	t5, 0x1
4000148c: 7302         	ld	t1, 0x20(sp)
4000148e: 0f2f7363     	bgeu	t5, s2, 0x40001574 <__dtoa_engine+0x2c4>
40001492: 03e00513     	li	a0, 0x3e
40001496: 11256363     	bltu	a0, s2, 0x4000159c <__dtoa_engine+0x2ec>
4000149a: 4e01         	li	t3, 0x0
4000149c: 557d         	li	a0, -0x1
4000149e: 01251533     	sll	a0, a0, s2
400014a2: 40ac7533     	andn	a0, s8, a0
400014a6: 00153f13     	seqz	t5, a0
400014aa: 9956         	add	s2, s2, s5
400014ac: 8396         	mv	t2, t0
400014ae: 12089063     	bnez	a7, 0x400015ce <__dtoa_engine+0x31e>
400014b2: a291         	j	0x400015f6 <__dtoa_engine+0x346>
400014b4: 00c8d6b3     	srl	a3, a7, a2
400014b8: 0806         	slli	a6, a6, 0x1
400014ba: fff64713     	not	a4, a2
400014be: 00e817b3     	sll	a5, a6, a4
400014c2: 00f6ea33     	or	s4, a3, a5
400014c6: 00c5d5b3     	srl	a1, a1, a2
400014ca: 0286         	slli	t0, t0, 0x1
400014cc: 00e296b3     	sll	a3, t0, a4
400014d0: 00d5ed33     	or	s10, a1, a3
400014d4: 00c455b3     	srl	a1, s0, a2
400014d8: 0486         	slli	s1, s1, 0x1
400014da: 00e494b3     	sll	s1, s1, a4
400014de: 8ccd         	or	s1, s1, a1
400014e0: 82de         	mv	t0, s7
400014e2: 6842         	ld	a6, 0x10(sp)
400014e4: 68e2         	ld	a7, 0x18(sp)
400014e6: 45d5         	li	a1, 0x15
400014e8: 7302         	ld	t1, 0x20(sp)
400014ea: f125e2e3     	bltu	a1, s2, 0x400013ee <__dtoa_engine+0x13e>
400014ee: 033335b7     	lui	a1, 0x3333
400014f2: 33358593     	addi	a1, a1, 0x333
400014f6: 05b2         	slli	a1, a1, 0xc
400014f8: 33358593     	addi	a1, a1, 0x333
400014fc: 05b2         	slli	a1, a1, 0xc
400014fe: 33358593     	addi	a1, a1, 0x333
40001502: 05b2         	slli	a1, a1, 0xc
40001504: 33458593     	addi	a1, a1, 0x334
40001508: 02bc35b3     	mulhu	a1, s8, a1
4000150c: 000c061b     	sext.w	a2, s8
40001510: 00259693     	slli	a3, a1, 0x2
40001514: 9db5         	addw	a1, a1, a3
40001516: 06c59963     	bne	a1, a2, 0x40001588 <__dtoa_engine+0x2d8>
4000151a: 8562         	mv	a0, s8
4000151c: 314000ef     	jal	0x40001830 <__pow5Factor>
40001520: 68e2         	ld	a7, 0x18(sp)
40001522: 6842         	ld	a6, 0x10(sp)
40001524: 82de         	mv	t0, s7
40001526: 7302         	ld	t1, 0x20(sp)
40001528: 4e01         	li	t3, 0x0
4000152a: 01253533     	sltu	a0, a0, s2
4000152e: 00154f13     	xori	t5, a0, 0x1
40001532: 83de         	mv	t2, s7
40001534: 08089d63     	bnez	a7, 0x400015ce <__dtoa_engine+0x31e>
40001538: a87d         	j	0x400015f6 <__dtoa_engine+0x346>
4000153a: 00a8d633     	srl	a2, a7, a0
4000153e: 0806         	slli	a6, a6, 0x1
40001540: fff54693     	not	a3, a0
40001544: 00d814b3     	sll	s1, a6, a3
40001548: 00966a33     	or	s4, a2, s1
4000154c: 00a45633     	srl	a2, s0, a0
40001550: 0706         	slli	a4, a4, 0x1
40001552: 00d71733     	sll	a4, a4, a3
40001556: 00e66d33     	or	s10, a2, a4
4000155a: 00a5d533     	srl	a0, a1, a0
4000155e: 0786         	slli	a5, a5, 0x1
40001560: 00d794b3     	sll	s1, a5, a3
40001564: 8cc9         	or	s1, s1, a0
40001566: 82de         	mv	t0, s7
40001568: 6842         	ld	a6, 0x10(sp)
4000156a: 68e2         	ld	a7, 0x18(sp)
4000156c: 4f05         	li	t5, 0x1
4000156e: 7302         	ld	t1, 0x20(sp)
40001570: f32f61e3     	bltu	t5, s2, 0x40001492 <__dtoa_engine+0x1e2>
40001574: 419a0a33     	sub	s4, s4, s9
40001578: 6522         	ld	a0, 0x8(sp)
4000157a: 01b57e33     	and	t3, a0, s11
4000157e: 9956         	add	s2, s2, s5
40001580: 8396         	mv	t2, t0
40001582: 04089663     	bnez	a7, 0x400015ce <__dtoa_engine+0x31e>
40001586: a885         	j	0x400015f6 <__dtoa_engine+0x346>
40001588: 020c9163     	bnez	s9, 0x400015aa <__dtoa_engine+0x2fa>
4000158c: 2a4000ef     	jal	0x40001830 <__pow5Factor>
40001590: 4f01         	li	t5, 0x0
40001592: 01253533     	sltu	a0, a0, s2
40001596: 00154e13     	xori	t3, a0, 0x1
4000159a: a01d         	j	0x400015c0 <__dtoa_engine+0x310>
4000159c: 4f01         	li	t5, 0x0
4000159e: 4e01         	li	t3, 0x0
400015a0: 9956         	add	s2, s2, s5
400015a2: 8396         	mv	t2, t0
400015a4: 02089563     	bnez	a7, 0x400015ce <__dtoa_engine+0x31e>
400015a8: a0b9         	j	0x400015f6 <__dtoa_engine+0x346>
400015aa: 854e         	mv	a0, s3
400015ac: 284000ef     	jal	0x40001830 <__pow5Factor>
400015b0: 4f01         	li	t5, 0x0
400015b2: 4e01         	li	t3, 0x0
400015b4: 01253533     	sltu	a0, a0, s2
400015b8: 00154513     	xori	a0, a0, 0x1
400015bc: 40aa0a33     	sub	s4, s4, a0
400015c0: 7302         	ld	t1, 0x20(sp)
400015c2: 82de         	mv	t0, s7
400015c4: 6842         	ld	a6, 0x10(sp)
400015c6: 68e2         	ld	a7, 0x18(sp)
400015c8: 83de         	mv	t2, s7
400015ca: 02088663     	beqz	a7, 0x400015f6 <__dtoa_engine+0x346>
400015ce: 4505         	li	a0, 0x1
400015d0: 45a9         	li	a1, 0xa
400015d2: 00b4e963     	bltu	s1, a1, 0x400015e4 <__dtoa_engine+0x334>
400015d6: 00159613     	slli	a2, a1, 0x1
400015da: 058e         	slli	a1, a1, 0x3
400015dc: 95b2         	add	a1, a1, a2
400015de: 0505         	addi	a0, a0, 0x1
400015e0: feb4fbe3     	bgeu	s1, a1, 0x400015d6 <__dtoa_engine+0x326>
400015e4: 01f8559b     	srliw	a1, a6, 0x1f
400015e8: 01090633     	add	a2, s2, a6
400015ec: 9d31         	addw	a0, a0, a2
400015ee: 0aa5e533     	max	a0, a1, a0
400015f2: 0aa2c3b3     	min	t2, t0, a0
400015f6: 4581         	li	a1, 0x0
400015f8: 4a81         	li	s5, 0x0
400015fa: 4981         	li	s3, 0x0
400015fc: ccccd537     	lui	a0, 0xccccd
40001600: ccd50513     	addi	a0, a0, -0x333
40001604: 02051613     	slli	a2, a0, 0x20
40001608: 9532         	add	a0, a0, a2
4000160a: 5fd9         	li	t6, -0xa
4000160c: 4ea9         	li	t4, 0xa
4000160e: a825         	j	0x40001646 <__dtoa_engine+0x396>
40001610: 8bce         	mv	s7, s3
40001612: 02a4b6b3     	mulhu	a3, s1, a0
40001616: 03f4073b     	mulw	a4, s0, t6
4000161a: 41a007bb     	negw	a5, s10
4000161e: 0ff5f593     	zext.b	a1, a1
40001622: 828d         	srli	a3, a3, 0x3
40001624: 03f68633     	mul	a2, a3, t6
40001628: 8f3d         	xor	a4, a4, a5
4000162a: 00173713     	seqz	a4, a4
4000162e: 00ee7e33     	and	t3, t3, a4
40001632: 9626         	add	a2, a2, s1
40001634: 0015b593     	seqz	a1, a1
40001638: 01e5ff33     	and	t5, a1, t5
4000163c: 0a85         	addi	s5, s5, 0x1
4000163e: 8d22         	mv	s10, s0
40001640: 85b2         	mv	a1, a2
40001642: 84b6         	mv	s1, a3
40001644: 89de         	mv	s3, s7
40001646: 02aa3633     	mulhu	a2, s4, a0
4000164a: 02ad3433     	mulhu	s0, s10, a0
4000164e: 00365a13     	srli	s4, a2, 0x3
40001652: 800d         	srli	s0, s0, 0x3
40001654: fb446ee3     	bltu	s0, s4, 0x40001610 <__dtoa_engine+0x360>
40001658: 4b85         	li	s7, 0x1
4000165a: 4685         	li	a3, 0x1
4000165c: 01d4eb63     	bltu	s1, t4, 0x40001672 <__dtoa_engine+0x3c2>
40001660: 4685         	li	a3, 0x1
40001662: 47a9         	li	a5, 0xa
40001664: 00179713     	slli	a4, a5, 0x1
40001668: 078e         	slli	a5, a5, 0x3
4000166a: 97ba         	add	a5, a5, a4
4000166c: 2685         	addiw	a3, a3, 0x1
4000166e: fef4fbe3     	bgeu	s1, a5, 0x40001664 <__dtoa_engine+0x3b4>
40001672: 00d3d763     	bge	t2, a3, 0x40001680 <__dtoa_engine+0x3d0>
40001676: 0093e6b3     	or	a3, t2, s1
4000167a: 0016b693     	seqz	a3, a3
4000167e: dad1         	beqz	a3, 0x40001612 <__dtoa_engine+0x362>
40001680: 001e7513     	andi	a0, t3, 0x1
40001684: c12d         	beqz	a0, 0x400016e6 <__dtoa_engine+0x436>
40001686: 5ed9         	li	t4, -0xa
40001688: 03d4053b     	mulw	a0, s0, t4
4000168c: 41a0063b     	negw	a2, s10
40001690: 04c51b63     	bne	a0, a2, 0x400016e6 <__dtoa_engine+0x436>
40001694: ccccd537     	lui	a0, 0xccccd
40001698: ccd50693     	addi	a3, a0, -0x333
4000169c: 02069513     	slli	a0, a3, 0x20
400016a0: 96aa         	add	a3, a3, a0
400016a2: 8d22         	mv	s10, s0
400016a4: 02d4b533     	mulhu	a0, s1, a3
400016a8: 0ff5f593     	zext.b	a1, a1
400016ac: 02d43433     	mulhu	s0, s0, a3
400016b0: 0015b593     	seqz	a1, a1
400016b4: 810d         	srli	a0, a0, 0x3
400016b6: 03d50633     	mul	a2, a0, t4
400016ba: 800d         	srli	s0, s0, 0x3
400016bc: 03d4073b     	mulw	a4, s0, t4
400016c0: 00bf7f33     	and	t5, t5, a1
400016c4: 9626         	add	a2, a2, s1
400016c6: 41a007bb     	negw	a5, s10
400016ca: 0a85         	addi	s5, s5, 0x1
400016cc: 84aa         	mv	s1, a0
400016ce: 85b2         	mv	a1, a2
400016d0: fcf709e3     	beq	a4, a5, 0x400016a2 <__dtoa_engine+0x3f2>
400016d4: 01a545b3     	xor	a1, a0, s10
400016d8: 00b035b3     	snez	a1, a1
400016dc: 00b9e5b3     	or	a1, s3, a1
400016e0: 8985         	andi	a1, a1, 0x1
400016e2: cd81         	beqz	a1, 0x400016fa <__dtoa_engine+0x44a>
400016e4: a03d         	j	0x40001712 <__dtoa_engine+0x462>
400016e6: 862e         	mv	a2, a1
400016e8: 8526         	mv	a0, s1
400016ea: 01a4c5b3     	xor	a1, s1, s10
400016ee: 00b035b3     	snez	a1, a1
400016f2: 00b9e5b3     	or	a1, s3, a1
400016f6: 8985         	andi	a1, a1, 0x1
400016f8: ed89         	bnez	a1, 0x40001712 <__dtoa_engine+0x462>
400016fa: 65a2         	ld	a1, 0x8(sp)
400016fc: 01c5f5b3     	and	a1, a1, t3
40001700: e989         	bnez	a1, 0x40001712 <__dtoa_engine+0x462>
40001702: 4605         	li	a2, 0x1
40001704: 00c505b3     	add	a1, a0, a2
40001708: 4505         	li	a0, 0x1
4000170a: 46a9         	li	a3, 0xa
4000170c: 02d5f763     	bgeu	a1, a3, 0x4000173a <__dtoa_engine+0x48a>
40001710: a825         	j	0x40001748 <__dtoa_engine+0x498>
40001712: 0ff67593     	zext.b	a1, a2
40001716: ffb58613     	addi	a2, a1, -0x5
4000171a: 00c03633     	snez	a2, a2
4000171e: 41e66633     	orn	a2, a2, t5
40001722: 8e49         	or	a2, a2, a0
40001724: 0055b593     	sltiu	a1, a1, 0x5
40001728: 0015c593     	xori	a1, a1, 0x1
4000172c: 8e6d         	and	a2, a2, a1
4000172e: 00c505b3     	add	a1, a0, a2
40001732: 4505         	li	a0, 0x1
40001734: 46a9         	li	a3, 0xa
40001736: 00d5e963     	bltu	a1, a3, 0x40001748 <__dtoa_engine+0x498>
4000173a: 00169713     	slli	a4, a3, 0x1
4000173e: 068e         	slli	a3, a3, 0x3
40001740: 96ba         	add	a3, a3, a4
40001742: 2505         	addiw	a0, a0, 0x1
40001744: fed5fbe3     	bgeu	a1, a3, 0x4000173a <__dtoa_engine+0x48a>
40001748: 00a3a6b3     	slt	a3, t2, a0
4000174c: 8e75         	and	a2, a2, a3
4000174e: 012a8733     	add	a4, s5, s2
40001752: ca15         	beqz	a2, 0x40001786 <__dtoa_engine+0x4d6>
40001754: 00088a63     	beqz	a7, 0x40001768 <__dtoa_engine+0x4b8>
40001758: 983a         	add	a6, a6, a4
4000175a: 00a8063b     	addw	a2, a6, a0
4000175e: 4685         	li	a3, 0x1
40001760: 0ad66633     	max	a2, a2, a3
40001764: 0ac2c3b3     	min	t2, t0, a2
40001768: 00a3df63     	bge	t2, a0, 0x40001786 <__dtoa_engine+0x4d6>
4000176c: 0595         	addi	a1, a1, 0x5
4000176e: ccccd637     	lui	a2, 0xccccd
40001772: ccd60613     	addi	a2, a2, -0x333
40001776: 02061693     	slli	a3, a2, 0x20
4000177a: 9636         	add	a2, a2, a3
4000177c: 02c5b5b3     	mulhu	a1, a1, a2
40001780: 0705         	addi	a4, a4, 0x1
40001782: 818d         	srli	a1, a1, 0x3
40001784: 357d         	addiw	a0, a0, -0x1
40001786: 0a754533     	min	a0, a0, t2
4000178a: 60551513     	sext.h	a0, a0
4000178e: 60571613     	sext.h	a2, a4
40001792: 962a         	add	a2, a2, a0
40001794: 167d         	addi	a2, a2, -0x1
40001796: 02a05f63     	blez	a0, 0x400017d4 <__dtoa_engine+0x524>
4000179a: 00430693     	addi	a3, t1, 0x4
4000179e: 00a68733     	add	a4, a3, a0
400017a2: ccccd7b7     	lui	a5, 0xccccd
400017a6: ccd78493     	addi	s1, a5, -0x333
400017aa: 02049793     	slli	a5, s1, 0x20
400017ae: 97a6         	add	a5, a5, s1
400017b0: 02f5b4b3     	mulhu	s1, a1, a5
400017b4: 0f84f413     	andi	s0, s1, 0xf8
400017b8: 4085843b     	subw	s0, a1, s0
400017bc: 0034d593     	srli	a1, s1, 0x3
400017c0: 00159493     	slli	s1, a1, 0x1
400017c4: 9c05         	subw	s0, s0, s1
400017c6: 03046493     	ori	s1, s0, 0x30
400017ca: 00970023     	sb	s1, 0x0(a4)
400017ce: 177d         	addi	a4, a4, -0x1
400017d0: fed710e3     	bne	a4, a3, 0x400017b0 <__dtoa_engine+0x500>
400017d4: 00c32023     	sw	a2, 0x0(t1)
400017d8: 01630223     	sb	s6, 0x4(t1)
400017dc: 60ea         	ld	ra, 0x98(sp)
400017de: 644a         	ld	s0, 0x90(sp)
400017e0: 64aa         	ld	s1, 0x88(sp)
400017e2: 690a         	ld	s2, 0x80(sp)
400017e4: 79e6         	ld	s3, 0x78(sp)
400017e6: 7a46         	ld	s4, 0x70(sp)
400017e8: 7aa6         	ld	s5, 0x68(sp)
400017ea: 7b06         	ld	s6, 0x60(sp)
400017ec: 6be6         	ld	s7, 0x58(sp)
400017ee: 6c46         	ld	s8, 0x50(sp)
400017f0: 6ca6         	ld	s9, 0x48(sp)
400017f2: 6d06         	ld	s10, 0x40(sp)
400017f4: 7de2         	ld	s11, 0x38(sp)
400017f6: 610d         	addi	sp, sp, 0xa0
400017f8: 8082         	ret

00000000400017fa <__log10Pow2>:
400017fa: 65cd         	lui	a1, 0x13
400017fc: 44158593     	addi	a1, a1, 0x441
40001800: 02b50533     	mul	a0, a0, a1
40001804: 0125551b     	srliw	a0, a0, 0x12
40001808: 8082         	ret

000000004000180a <__log10Pow5>:
4000180a: 000b35b7     	lui	a1, 0xb3
4000180e: efb58593     	addi	a1, a1, -0x105
40001812: 02b50533     	mul	a0, a0, a1
40001816: 0145551b     	srliw	a0, a0, 0x14
4000181a: 8082         	ret

000000004000181c <__pow5bits>:
4000181c: 001295b7     	lui	a1, 0x129
40001820: 34f58593     	addi	a1, a1, 0x34f
40001824: 02b50533     	mul	a0, a0, a1
40001828: 0135551b     	srliw	a0, a0, 0x13
4000182c: 0505         	addi	a0, a0, 0x1
4000182e: 8082         	ret

0000000040001830 <__pow5Factor>:
40001830: 85aa         	mv	a1, a0
40001832: 557d         	li	a0, -0x1
40001834: ccccd637     	lui	a2, 0xccccd
40001838: ccd60613     	addi	a2, a2, -0x333
4000183c: 02061693     	slli	a3, a2, 0x20
40001840: 9636         	add	a2, a2, a3
40001842: 033336b7     	lui	a3, 0x3333
40001846: 33368693     	addi	a3, a3, 0x333
4000184a: 06b2         	slli	a3, a3, 0xc
4000184c: 33368693     	addi	a3, a3, 0x333
40001850: 06b2         	slli	a3, a3, 0xc
40001852: 33368693     	addi	a3, a3, 0x333
40001856: 06b2         	slli	a3, a3, 0xc
40001858: 33468693     	addi	a3, a3, 0x334
4000185c: 02c585b3     	mul	a1, a1, a2
40001860: 2505         	addiw	a0, a0, 0x1
40001862: fed5ede3     	bltu	a1, a3, 0x4000185c <__pow5Factor+0x2c>
40001866: 8082         	ret

0000000040001868 <__double_computePow5>:
40001868: 715d         	addi	sp, sp, -0x50
4000186a: e486         	sd	ra, 0x48(sp)
4000186c: e0a2         	sd	s0, 0x40(sp)
4000186e: fc26         	sd	s1, 0x38(sp)
40001870: f84a         	sd	s2, 0x30(sp)
40001872: f44e         	sd	s3, 0x28(sp)
40001874: f052         	sd	s4, 0x20(sp)
40001876: ec56         	sd	s5, 0x18(sp)
40001878: e85a         	sd	s6, 0x10(sp)
4000187a: e45e         	sd	s7, 0x8(sp)
4000187c: e062         	sd	s8, 0x0(sp)
4000187e: 892e         	mv	s2, a1
40001880: 84aa         	mv	s1, a0
40001882: 1502         	slli	a0, a0, 0x20
40001884: 4ec4f5b7     	lui	a1, 0x4ec4f
40001888: c4f58593     	addi	a1, a1, -0x3b1
4000188c: 1582         	slli	a1, a1, 0x20
4000188e: 02b53533     	mulhu	a0, a0, a1
40001892: 910d         	srli	a0, a0, 0x23
40001894: 45e9         	li	a1, 0x1a
40001896: 02b5043b     	mulw	s0, a0, a1
4000189a: 0512         	slli	a0, a0, 0x4
4000189c: 00003597     	auipc	a1, 0x3
400018a0: 67458593     	addi	a1, a1, 0x674
400018a4: 952e         	add	a0, a0, a1
400018a6: 00849563     	bne	s1, s0, 0x400018b0 <__double_computePow5+0x48>
400018aa: 610c         	ld	a1, 0x0(a0)
400018ac: 6508         	ld	a0, 0x8(a0)
400018ae: a87d         	j	0x4000196c <__double_computePow5+0x104>
400018b0: 408485bb     	subw	a1, s1, s0
400018b4: 1582         	slli	a1, a1, 0x20
400018b6: 81f5         	srli	a1, a1, 0x1d
400018b8: 00003617     	auipc	a2, 0x3
400018bc: 72860613     	addi	a2, a2, 0x728
400018c0: 95b2         	add	a1, a1, a2
400018c2: 0005ba03     	ld	s4, 0x0(a1)
400018c6: 00053c03     	ld	s8, 0x0(a0)
400018ca: 034c3bb3     	mulhu	s7, s8, s4
400018ce: 00853b03     	ld	s6, 0x8(a0)
400018d2: 034b0ab3     	mul	s5, s6, s4
400018d6: 8526         	mv	a0, s1
400018d8: f45ff0ef     	jal	0x4000181c <__pow5bits>
400018dc: 89aa         	mv	s3, a0
400018de: 8522         	mv	a0, s0
400018e0: f3dff0ef     	jal	0x4000181c <__pow5bits>
400018e4: 40a9863b     	subw	a2, s3, a0
400018e8: fc060693     	addi	a3, a2, -0x40
400018ec: 00cbd5b3     	srl	a1, s7, a2
400018f0: 0006c463     	bltz	a3, 0x400018f8 <__double_computePow5+0x90>
400018f4: 852e         	mv	a0, a1
400018f6: a819         	j	0x4000190c <__double_computePow5+0xa4>
400018f8: 034c0533     	mul	a0, s8, s4
400018fc: fff64713     	not	a4, a2
40001900: 0b86         	slli	s7, s7, 0x1
40001902: 00c55533     	srl	a0, a0, a2
40001906: 00eb9733     	sll	a4, s7, a4
4000190a: 8d59         	or	a0, a0, a4
4000190c: 96fd         	srai	a3, a3, 0x3f
4000190e: 8df5         	and	a1, a1, a3
40001910: 04000713     	li	a4, 0x40
40001914: 9f11         	subw	a4, a4, a2
40001916: fc070693     	addi	a3, a4, -0x40
4000191a: 00ea9633     	sll	a2, s5, a4
4000191e: 0006c463     	bltz	a3, 0x40001926 <__double_computePow5+0xbe>
40001922: 8732         	mv	a4, a2
40001924: a821         	j	0x4000193c <__double_computePow5+0xd4>
40001926: 034b3833     	mulhu	a6, s6, s4
4000192a: fff74413     	not	s0, a4
4000192e: 001ad793     	srli	a5, s5, 0x1
40001932: 00e81733     	sll	a4, a6, a4
40001936: 0087d7b3     	srl	a5, a5, s0
4000193a: 8f5d         	or	a4, a4, a5
4000193c: 96fd         	srai	a3, a3, 0x3f
4000193e: 8e75         	and	a2, a2, a3
40001940: 95ba         	add	a1, a1, a4
40001942: 9532         	add	a0, a0, a2
40001944: 00c53633     	sltu	a2, a0, a2
40001948: 962e         	add	a2, a2, a1
4000194a: 0044d59b     	srliw	a1, s1, 0x4
4000194e: 058a         	slli	a1, a1, 0x2
40001950: 00003697     	auipc	a3, 0x3
40001954: 76068693     	addi	a3, a3, 0x760
40001958: 95b6         	add	a1, a1, a3
4000195a: 418c         	lw	a1, 0x0(a1)
4000195c: 0486         	slli	s1, s1, 0x1
4000195e: 0095d5bb     	srlw	a1, a1, s1
40001962: 898d         	andi	a1, a1, 0x3
40001964: 95aa         	add	a1, a1, a0
40001966: 00a5b533     	sltu	a0, a1, a0
4000196a: 9532         	add	a0, a0, a2
4000196c: 00b93023     	sd	a1, 0x0(s2)
40001970: 00a93423     	sd	a0, 0x8(s2)
40001974: 60a6         	ld	ra, 0x48(sp)
40001976: 6406         	ld	s0, 0x40(sp)
40001978: 74e2         	ld	s1, 0x38(sp)
4000197a: 7942         	ld	s2, 0x30(sp)
4000197c: 79a2         	ld	s3, 0x28(sp)
4000197e: 7a02         	ld	s4, 0x20(sp)
40001980: 6ae2         	ld	s5, 0x18(sp)
40001982: 6b42         	ld	s6, 0x10(sp)
40001984: 6ba2         	ld	s7, 0x8(sp)
40001986: 6c02         	ld	s8, 0x0(sp)
40001988: 6161         	addi	sp, sp, 0x50
4000198a: 8082         	ret

000000004000198c <__double_computeInvPow5>:
4000198c: 715d         	addi	sp, sp, -0x50
4000198e: e486         	sd	ra, 0x48(sp)
40001990: e0a2         	sd	s0, 0x40(sp)
40001992: fc26         	sd	s1, 0x38(sp)
40001994: f84a         	sd	s2, 0x30(sp)
40001996: f44e         	sd	s3, 0x28(sp)
40001998: f052         	sd	s4, 0x20(sp)
4000199a: ec56         	sd	s5, 0x18(sp)
4000199c: e85a         	sd	s6, 0x10(sp)
4000199e: e45e         	sd	s7, 0x8(sp)
400019a0: 892e         	mv	s2, a1
400019a2: 84aa         	mv	s1, a0
400019a4: 0565         	addi	a0, a0, 0x19
400019a6: 4ec4f5b7     	lui	a1, 0x4ec4f
400019aa: c4f58593     	addi	a1, a1, -0x3b1
400019ae: 1582         	slli	a1, a1, 0x20
400019b0: 1502         	slli	a0, a0, 0x20
400019b2: 02b53533     	mulhu	a0, a0, a1
400019b6: 02355593     	srli	a1, a0, 0x23
400019ba: 4569         	li	a0, 0x1a
400019bc: 02a5853b     	mulw	a0, a1, a0
400019c0: 0592         	slli	a1, a1, 0x4
400019c2: 00003617     	auipc	a2, 0x3
400019c6: 74660613     	addi	a2, a2, 0x746
400019ca: 95b2         	add	a1, a1, a2
400019cc: 00951563     	bne	a0, s1, 0x400019d6 <__double_computeInvPow5+0x4a>
400019d0: 6188         	ld	a0, 0x0(a1)
400019d2: 658c         	ld	a1, 0x8(a1)
400019d4: a0e1         	j	0x40001a9c <__double_computeInvPow5+0x110>
400019d6: 4095063b     	subw	a2, a0, s1
400019da: 1602         	slli	a2, a2, 0x20
400019dc: 8275         	srli	a2, a2, 0x1d
400019de: 00003697     	auipc	a3, 0x3
400019e2: 60268693     	addi	a3, a3, 0x602
400019e6: 9636         	add	a2, a2, a3
400019e8: 00063983     	ld	s3, 0x0(a2)
400019ec: 0005bb83     	ld	s7, 0x0(a1)
400019f0: 1bfd         	addi	s7, s7, -0x1
400019f2: 033bbb33     	mulhu	s6, s7, s3
400019f6: 0085ba83     	ld	s5, 0x8(a1)
400019fa: 033a8a33     	mul	s4, s5, s3
400019fe: e1fff0ef     	jal	0x4000181c <__pow5bits>
40001a02: 842a         	mv	s0, a0
40001a04: 8526         	mv	a0, s1
40001a06: e17ff0ef     	jal	0x4000181c <__pow5bits>
40001a0a: 9c09         	subw	s0, s0, a0
40001a0c: fc040613     	addi	a2, s0, -0x40
40001a10: 008b55b3     	srl	a1, s6, s0
40001a14: 00064463     	bltz	a2, 0x40001a1c <__double_computeInvPow5+0x90>
40001a18: 852e         	mv	a0, a1
40001a1a: a819         	j	0x40001a30 <__double_computeInvPow5+0xa4>
40001a1c: 033b8533     	mul	a0, s7, s3
40001a20: fff44693     	not	a3, s0
40001a24: 0b06         	slli	s6, s6, 0x1
40001a26: 00855533     	srl	a0, a0, s0
40001a2a: 00db16b3     	sll	a3, s6, a3
40001a2e: 8d55         	or	a0, a0, a3
40001a30: 967d         	srai	a2, a2, 0x3f
40001a32: 00b67833     	and	a6, a2, a1
40001a36: 04000613     	li	a2, 0x40
40001a3a: 9e01         	subw	a2, a2, s0
40001a3c: fc060713     	addi	a4, a2, -0x40
40001a40: 00ca16b3     	sll	a3, s4, a2
40001a44: 00074463     	bltz	a4, 0x40001a4c <__double_computeInvPow5+0xc0>
40001a48: 8636         	mv	a2, a3
40001a4a: a821         	j	0x40001a62 <__double_computeInvPow5+0xd6>
40001a4c: 033ab7b3     	mulhu	a5, s5, s3
40001a50: fff64413     	not	s0, a2
40001a54: 001a5593     	srli	a1, s4, 0x1
40001a58: 00c79633     	sll	a2, a5, a2
40001a5c: 0085d5b3     	srl	a1, a1, s0
40001a60: 8e4d         	or	a2, a2, a1
40001a62: 977d         	srai	a4, a4, 0x3f
40001a64: 8ef9         	and	a3, a3, a4
40001a66: 0044d59b     	srliw	a1, s1, 0x4
40001a6a: 058a         	slli	a1, a1, 0x2
40001a6c: 00003717     	auipc	a4, 0x3
40001a70: 78c70713     	addi	a4, a4, 0x78c
40001a74: 95ba         	add	a1, a1, a4
40001a76: 418c         	lw	a1, 0x0(a1)
40001a78: 0486         	slli	s1, s1, 0x1
40001a7a: 0095d5bb     	srlw	a1, a1, s1
40001a7e: 898d         	andi	a1, a1, 0x3
40001a80: 96aa         	add	a3, a3, a0
40001a82: 00a6b533     	sltu	a0, a3, a0
40001a86: 9642         	add	a2, a2, a6
40001a88: 9532         	add	a0, a0, a2
40001a8a: 95b6         	add	a1, a1, a3
40001a8c: 00d5b633     	sltu	a2, a1, a3
40001a90: 962a         	add	a2, a2, a0
40001a92: 00158513     	addi	a0, a1, 0x1
40001a96: 00153593     	seqz	a1, a0
40001a9a: 95b2         	add	a1, a1, a2
40001a9c: 00a93023     	sd	a0, 0x0(s2)
40001aa0: 00b93423     	sd	a1, 0x8(s2)
40001aa4: 60a6         	ld	ra, 0x48(sp)
40001aa6: 6406         	ld	s0, 0x40(sp)
40001aa8: 74e2         	ld	s1, 0x38(sp)
40001aaa: 7942         	ld	s2, 0x30(sp)
40001aac: 79a2         	ld	s3, 0x28(sp)
40001aae: 7a02         	ld	s4, 0x20(sp)
40001ab0: 6ae2         	ld	s5, 0x18(sp)
40001ab2: 6b42         	ld	s6, 0x10(sp)
40001ab4: 6ba2         	ld	s7, 0x8(sp)
40001ab6: 6161         	addi	sp, sp, 0x50
40001ab8: 8082         	ret

0000000040001aba <add>:
40001aba: 1101         	addi	sp, sp, -0x20
40001abc: ec06         	sd	ra, 0x18(sp)
40001abe: e822         	sd	s0, 0x10(sp)
40001ac0: e426         	sd	s1, 0x8(sp)
40001ac2: 842e         	mv	s0, a1
40001ac4: 84aa         	mv	s1, a0
40001ac6: 00003517     	auipc	a0, 0x3
40001aca: 2cd50613     	addi	a2, a0, 0x2cd
40001ace: 4591         	li	a1, 0x4
40001ad0: 4501         	li	a0, 0x0
40001ad2: 1ab000ef     	jal	0x4000247c <flexio_dev_msg>
40001ad6: 00940533     	add	a0, s0, s1
40001ada: 60e2         	ld	ra, 0x18(sp)
40001adc: 6442         	ld	s0, 0x10(sp)
40001ade: 64a2         	ld	s1, 0x8(sp)
40001ae0: 6105         	addi	sp, sp, 0x20
40001ae2: 8082         	ret

0000000040001ae4 <spin>:
40001ae4: 715d         	addi	sp, sp, -0x50
40001ae6: e486         	sd	ra, 0x48(sp)
40001ae8: e0a2         	sd	s0, 0x40(sp)
40001aea: fc26         	sd	s1, 0x38(sp)
40001aec: f84a         	sd	s2, 0x30(sp)
40001aee: f44e         	sd	s3, 0x28(sp)
40001af0: f052         	sd	s4, 0x20(sp)
40001af2: ec56         	sd	s5, 0x18(sp)
40001af4: e85a         	sd	s6, 0x10(sp)
40001af6: e45e         	sd	s7, 0x8(sp)
40001af8: 89ae         	mv	s3, a1
40001afa: 892a         	mv	s2, a0
40001afc: 6561         	lui	a0, 0x18
40001afe: 6a050a93     	addi	s5, a0, 0x6a0
40001b02: c0102b73     	rdtime	s6
40001b06: c0002a73     	rdcycle	s4
40001b0a: 4b81         	li	s7, 0x0
40001b0c: 015b04b3     	add	s1, s6, s5
40001b10: 0125b023     	sd	s2, 0x0(a1)
40001b14: 0205b023     	sd	zero, 0x20(a1)
40001b18: a019         	j	0x40001b1e <spin+0x3a>
40001b1a: 03247463     	bgeu	s0, s2, 0x40001b42 <spin+0x5e>
40001b1e: c0102573     	rdtime	a0
40001b22: 41650433     	sub	s0, a0, s6
40001b26: fe956ae3     	bltu	a0, s1, 0x40001b1a <spin+0x36>
40001b2a: 0b85         	addi	s7, s7, 0x1
40001b2c: 855e         	mv	a0, s7
40001b2e: 064000ef     	jal	0x40001b92 <gdb_tick>
40001b32: 94d6         	add	s1, s1, s5
40001b34: 0179bc23     	sd	s7, 0x18(s3)
40001b38: 0089b423     	sd	s0, 0x8(s3)
40001b3c: 0110000f     	fence	w, w
40001b40: bfe9         	j	0x40001b1a <spin+0x36>
40001b42: 0089b423     	sd	s0, 0x8(s3)
40001b46: c0002573     	rdcycle	a0
40001b4a: 41450533     	sub	a0, a0, s4
40001b4e: 00a9b823     	sd	a0, 0x10(s3)
40001b52: 0179bc23     	sd	s7, 0x18(s3)
40001b56: 4505         	li	a0, 0x1
40001b58: 02a9b023     	sd	a0, 0x20(s3)
40001b5c: 0110000f     	fence	w, w
40001b60: 8522         	mv	a0, s0
40001b62: 60a6         	ld	ra, 0x48(sp)
40001b64: 6406         	ld	s0, 0x40(sp)
40001b66: 74e2         	ld	s1, 0x38(sp)
40001b68: 7942         	ld	s2, 0x30(sp)
40001b6a: 79a2         	ld	s3, 0x28(sp)
40001b6c: 7a02         	ld	s4, 0x20(sp)
40001b6e: 6ae2         	ld	s5, 0x18(sp)
40001b70: 6b42         	ld	s6, 0x10(sp)
40001b72: 6ba2         	ld	s7, 0x8(sp)
40001b74: 6161         	addi	sp, sp, 0x50
40001b76: 8082         	ret

0000000040001b78 <read_u64>:
40001b78: 6108         	ld	a0, 0x0(a0)
40001b7a: 8082         	ret

0000000040001b7c <busy_us>:
40001b7c: c01025f3     	rdtime	a1
40001b80: c0102673     	rdtime	a2
40001b84: 8e0d         	sub	a2, a2, a1
40001b86: fea66de3     	bltu	a2, a0, 0x40001b80 <busy_us+0x4>
40001b8a: c0102573     	rdtime	a0
40001b8e: 8d0d         	sub	a0, a0, a1
40001b90: 8082         	ret

0000000040001b92 <gdb_tick>:
40001b92: 3fffe597     	auipc	a1, 0x3fffe
40001b96: 5aa5bf23     	sd	a0, 0x5be(a1)
40001b9a: 8082         	ret

0000000040001b9c <flexio_dev_bzero16>:
40001b9c: 99f9         	andi	a1, a1, -0x2
40001b9e: c599         	beqz	a1, 0x40001bac <flexio_dev_bzero16+0x10>
40001ba0: 95aa         	add	a1, a1, a0
40001ba2: 00051023     	sh	zero, 0x0(a0)
40001ba6: 0509         	addi	a0, a0, 0x2
40001ba8: feb56de3     	bltu	a0, a1, 0x40001ba2 <flexio_dev_bzero16+0x6>
40001bac: 8082         	ret

0000000040001bae <flexio_dev_bzero32>:
40001bae: 99f1         	andi	a1, a1, -0x4
40001bb0: c599         	beqz	a1, 0x40001bbe <flexio_dev_bzero32+0x10>
40001bb2: 95aa         	add	a1, a1, a0
40001bb4: 00052023     	sw	zero, 0x0(a0)
40001bb8: 0511         	addi	a0, a0, 0x4
40001bba: feb56de3     	bltu	a0, a1, 0x40001bb4 <flexio_dev_bzero32+0x6>
40001bbe: 8082         	ret

0000000040001bc0 <flexio_dev_bzero64>:
40001bc0: 99e1         	andi	a1, a1, -0x8
40001bc2: c599         	beqz	a1, 0x40001bd0 <flexio_dev_bzero64+0x10>
40001bc4: 95aa         	add	a1, a1, a0
40001bc6: 00053023     	sd	zero, 0x0(a0)
40001bca: 0521         	addi	a0, a0, 0x8
40001bcc: feb56de3     	bltu	a0, a1, 0x40001bc6 <flexio_dev_bzero64+0x6>
40001bd0: 8082         	ret

0000000040001bd2 <flexio_dev_memcpy128>:
40001bd2: 8211         	srli	a2, a2, 0x4
40001bd4: ce09         	beqz	a2, 0x40001bee <flexio_dev_memcpy128+0x1c>
40001bd6: 0612         	slli	a2, a2, 0x4
40001bd8: 962a         	add	a2, a2, a0
40001bda: 6594         	ld	a3, 0x8(a1)
40001bdc: 6198         	ld	a4, 0x0(a1)
40001bde: 05c1         	addi	a1, a1, 0x10
40001be0: 01050793     	addi	a5, a0, 0x10
40001be4: e118         	sd	a4, 0x0(a0)
40001be6: e514         	sd	a3, 0x8(a0)
40001be8: 853e         	mv	a0, a5
40001bea: fec798e3     	bne	a5, a2, 0x40001bda <flexio_dev_memcpy128+0x8>
40001bee: 8082         	ret

0000000040001bf0 <flexio_dev_memcpy16>:
40001bf0: 8205         	srli	a2, a2, 0x1
40001bf2: ce09         	beqz	a2, 0x40001c0c <flexio_dev_memcpy16+0x1c>
40001bf4: 0606         	slli	a2, a2, 0x1
40001bf6: 962a         	add	a2, a2, a0
40001bf8: 00059683     	lh	a3, 0x0(a1)
40001bfc: 0589         	addi	a1, a1, 0x2
40001bfe: 00250713     	addi	a4, a0, 0x2
40001c02: 00d51023     	sh	a3, 0x0(a0)
40001c06: 853a         	mv	a0, a4
40001c08: fec718e3     	bne	a4, a2, 0x40001bf8 <flexio_dev_memcpy16+0x8>
40001c0c: 8082         	ret

0000000040001c0e <flexio_dev_memcpy32>:
40001c0e: 8209         	srli	a2, a2, 0x2
40001c10: ca19         	beqz	a2, 0x40001c26 <flexio_dev_memcpy32+0x18>
40001c12: 060a         	slli	a2, a2, 0x2
40001c14: 962a         	add	a2, a2, a0
40001c16: 4194         	lw	a3, 0x0(a1)
40001c18: 0591         	addi	a1, a1, 0x4
40001c1a: 00450713     	addi	a4, a0, 0x4
40001c1e: c114         	sw	a3, 0x0(a0)
40001c20: 853a         	mv	a0, a4
40001c22: fec71ae3     	bne	a4, a2, 0x40001c16 <flexio_dev_memcpy32+0x8>
40001c26: 8082         	ret

0000000040001c28 <flexio_dev_memcpy64>:
40001c28: 820d         	srli	a2, a2, 0x3
40001c2a: ca19         	beqz	a2, 0x40001c40 <flexio_dev_memcpy64+0x18>
40001c2c: 060e         	slli	a2, a2, 0x3
40001c2e: 962a         	add	a2, a2, a0
40001c30: 6194         	ld	a3, 0x0(a1)
40001c32: 05a1         	addi	a1, a1, 0x8
40001c34: 00850713     	addi	a4, a0, 0x8
40001c38: e114         	sd	a3, 0x0(a0)
40001c3a: 853a         	mv	a0, a4
40001c3c: fec71ae3     	bne	a4, a2, 0x40001c30 <flexio_dev_memcpy64+0x8>
40001c40: 8082         	ret

0000000040001c42 <flexio_dev_bzero16.6>:
40001c42: 99f9         	andi	a1, a1, -0x2
40001c44: c599         	beqz	a1, 0x40001c52 <flexio_dev_bzero16.6+0x10>
40001c46: 95aa         	add	a1, a1, a0
40001c48: 00051023     	sh	zero, 0x0(a0)
40001c4c: 0509         	addi	a0, a0, 0x2
40001c4e: feb56de3     	bltu	a0, a1, 0x40001c48 <flexio_dev_bzero16.6+0x6>
40001c52: 8082         	ret

0000000040001c54 <flexio_dev_bzero32.7>:
40001c54: 99f1         	andi	a1, a1, -0x4
40001c56: c599         	beqz	a1, 0x40001c64 <flexio_dev_bzero32.7+0x10>
40001c58: 95aa         	add	a1, a1, a0
40001c5a: 00052023     	sw	zero, 0x0(a0)
40001c5e: 0511         	addi	a0, a0, 0x4
40001c60: feb56de3     	bltu	a0, a1, 0x40001c5a <flexio_dev_bzero32.7+0x6>
40001c64: 8082         	ret

0000000040001c66 <flexio_dev_bzero64.8>:
40001c66: 99e1         	andi	a1, a1, -0x8
40001c68: c599         	beqz	a1, 0x40001c76 <flexio_dev_bzero64.8+0x10>
40001c6a: 95aa         	add	a1, a1, a0
40001c6c: 00053023     	sd	zero, 0x0(a0)
40001c70: 0521         	addi	a0, a0, 0x8
40001c72: feb56de3     	bltu	a0, a1, 0x40001c6c <flexio_dev_bzero64.8+0x6>
40001c76: 8082         	ret

0000000040001c78 <flexio_dev_memcpy128.9>:
40001c78: 8211         	srli	a2, a2, 0x4
40001c7a: ce09         	beqz	a2, 0x40001c94 <flexio_dev_memcpy128.9+0x1c>
40001c7c: 0612         	slli	a2, a2, 0x4
40001c7e: 962a         	add	a2, a2, a0
40001c80: 6594         	ld	a3, 0x8(a1)
40001c82: 6198         	ld	a4, 0x0(a1)
40001c84: 05c1         	addi	a1, a1, 0x10
40001c86: 01050793     	addi	a5, a0, 0x10
40001c8a: e118         	sd	a4, 0x0(a0)
40001c8c: e514         	sd	a3, 0x8(a0)
40001c8e: 853e         	mv	a0, a5
40001c90: fec798e3     	bne	a5, a2, 0x40001c80 <flexio_dev_memcpy128.9+0x8>
40001c94: 8082         	ret

0000000040001c96 <flexio_dev_memcpy16.10>:
40001c96: 8205         	srli	a2, a2, 0x1
40001c98: ce09         	beqz	a2, 0x40001cb2 <flexio_dev_memcpy16.10+0x1c>
40001c9a: 0606         	slli	a2, a2, 0x1
40001c9c: 962a         	add	a2, a2, a0
40001c9e: 00059683     	lh	a3, 0x0(a1)
40001ca2: 0589         	addi	a1, a1, 0x2
40001ca4: 00250713     	addi	a4, a0, 0x2
40001ca8: 00d51023     	sh	a3, 0x0(a0)
40001cac: 853a         	mv	a0, a4
40001cae: fec718e3     	bne	a4, a2, 0x40001c9e <flexio_dev_memcpy16.10+0x8>
40001cb2: 8082         	ret

0000000040001cb4 <flexio_dev_memcpy32.11>:
40001cb4: 8209         	srli	a2, a2, 0x2
40001cb6: ca19         	beqz	a2, 0x40001ccc <flexio_dev_memcpy32.11+0x18>
40001cb8: 060a         	slli	a2, a2, 0x2
40001cba: 962a         	add	a2, a2, a0
40001cbc: 4194         	lw	a3, 0x0(a1)
40001cbe: 0591         	addi	a1, a1, 0x4
40001cc0: 00450713     	addi	a4, a0, 0x4
40001cc4: c114         	sw	a3, 0x0(a0)
40001cc6: 853a         	mv	a0, a4
40001cc8: fec71ae3     	bne	a4, a2, 0x40001cbc <flexio_dev_memcpy32.11+0x8>
40001ccc: 8082         	ret

0000000040001cce <flexio_dev_memcpy64.12>:
40001cce: 820d         	srli	a2, a2, 0x3
40001cd0: ca19         	beqz	a2, 0x40001ce6 <flexio_dev_memcpy64.12+0x18>
40001cd2: 060e         	slli	a2, a2, 0x3
40001cd4: 962a         	add	a2, a2, a0
40001cd6: 6194         	ld	a3, 0x0(a1)
40001cd8: 05a1         	addi	a1, a1, 0x8
40001cda: 00850713     	addi	a4, a0, 0x8
40001cde: e114         	sd	a3, 0x0(a0)
40001ce0: 853a         	mv	a0, a4
40001ce2: fec71ae3     	bne	a4, a2, 0x40001cd6 <flexio_dev_memcpy64.12+0x8>
40001ce6: 8082         	ret

0000000040001ce8 <flexio_dev_yield>:
40001ce8: 7179         	addi	sp, sp, -0x30
40001cea: f406         	sd	ra, 0x28(sp)
40001cec: f022         	sd	s0, 0x20(sp)
40001cee: ec26         	sd	s1, 0x18(sp)
40001cf0: e84a         	sd	s2, 0x10(sp)
40001cf2: e44e         	sd	s3, 0x8(sp)
40001cf4: 02023483     	ld	s1, 0x20(tp)
40001cf8: 60a0         	ld	s0, 0x40(s1)
40001cfa: cc6d         	beqz	s0, 0x40001df4 <flexio_dev_yield+0x10c>
40001cfc: 00840513     	addi	a0, s0, 0x8
40001d00: b00fe0ef     	jal	0x40000000 <text_start>
40001d04: cd7d         	beqz	a0, 0x40001e02 <flexio_dev_yield+0x11a>
40001d06: 4488         	lw	a0, 0x8(s1)
40001d08: 59fd         	li	s3, -0x1
40001d0a: 00040023     	sb	zero, 0x0(s0)
40001d0e: 01350c63     	beq	a0, s3, 0x40001d26 <flexio_dev_yield+0x3e>
40001d12: 0805443b     	zext.h	s0, a0
40001d16: 4889         	li	a7, 0x2
40001d18: 8522         	mv	a0, s0
40001d1a: 00000073     	ecall
40001d1e: c501         	beqz	a0, 0x40001d26 <flexio_dev_yield+0x3e>
40001d20: 02023503     	ld	a0, 0x20(tp)
40001d24: c500         	sw	s0, 0x8(a0)
40001d26: 48c8         	lw	a0, 0x14(s1)
40001d28: 00c4a903     	lw	s2, 0xc(s1)
40001d2c: 03350863     	beq	a0, s3, 0x40001d5c <flexio_dev_yield+0x74>
40001d30: 0440000f     	fence	o, o
40001d34: 0805443b     	zext.h	s0, a0
40001d38: 488d         	li	a7, 0x3
40001d3a: 8522         	mv	a0, s0
40001d3c: 00000073     	ecall
40001d40: cd15         	beqz	a0, 0x40001d7c <flexio_dev_yield+0x94>
40001d42: 02023503     	ld	a0, 0x20(tp)
40001d46: c940         	sw	s0, 0x14(a0)
40001d48: 0cc0000f     	fence	io, io
40001d4c: 20001537     	lui	a0, 0x20001
40001d50: 0512         	slli	a0, a0, 0x4
40001d52: 01252023     	sw	s2, 0x0(a0)
40001d56: 0cc0000f     	fence	io, io
40001d5a: a829         	j	0x40001d74 <flexio_dev_yield+0x8c>
40001d5c: 557d         	li	a0, -0x1
40001d5e: 00a90f63     	beq	s2, a0, 0x40001d7c <flexio_dev_yield+0x94>
40001d62: 0cc0000f     	fence	io, io
40001d66: 20001537     	lui	a0, 0x20001
40001d6a: 0512         	slli	a0, a0, 0x4
40001d6c: 01252023     	sw	s2, 0x0(a0)
40001d70: 0cc0000f     	fence	io, io
40001d74: 8512         	mv	a0, tp
40001d76: 7108         	ld	a0, 0x20(a0)
40001d78: 01252623     	sw	s2, 0xc(a0)
40001d7c: 4c88         	lw	a0, 0x18(s1)
40001d7e: 55fd         	li	a1, -0x1
40001d80: 0104a903     	lw	s2, 0x10(s1)
40001d84: 02b50863     	beq	a0, a1, 0x40001db4 <flexio_dev_yield+0xcc>
40001d88: 0440000f     	fence	o, o
40001d8c: 0805443b     	zext.h	s0, a0
40001d90: 489d         	li	a7, 0x7
40001d92: 8522         	mv	a0, s0
40001d94: 00000073     	ecall
40001d98: cd0d         	beqz	a0, 0x40001dd2 <flexio_dev_yield+0xea>
40001d9a: 02023503     	ld	a0, 0x20(tp)
40001d9e: cd00         	sw	s0, 0x18(a0)
40001da0: 0cc0000f     	fence	io, io
40001da4: 20001537     	lui	a0, 0x20001
40001da8: 0512         	slli	a0, a0, 0x4
40001daa: 05252023     	sw	s2, 0x40(a0)
40001dae: 0cc0000f     	fence	io, io
40001db2: a821         	j	0x40001dca <flexio_dev_yield+0xe2>
40001db4: 00b90f63     	beq	s2, a1, 0x40001dd2 <flexio_dev_yield+0xea>
40001db8: 0cc0000f     	fence	io, io
40001dbc: 20001537     	lui	a0, 0x20001
40001dc0: 0512         	slli	a0, a0, 0x4
40001dc2: 05252023     	sw	s2, 0x40(a0)
40001dc6: 0cc0000f     	fence	io, io
40001dca: 8512         	mv	a0, tp
40001dcc: 7108         	ld	a0, 0x20(a0)
40001dce: 01252823     	sw	s2, 0x10(a0)
40001dd2: 0004e403     	lwu	s0, 0x0(s1)
40001dd6: 557d         	li	a0, -0x1
40001dd8: 9101         	srli	a0, a0, 0x20
40001dda: 00a40d63     	beq	s0, a0, 0x40001df4 <flexio_dev_yield+0x10c>
40001dde: 00823583     	ld	a1, 0x8(tp)
40001de2: 0804453b     	zext.h	a0, s0
40001de6: 4895         	li	a7, 0x5
40001de8: 00000073     	ecall
40001dec: c501         	beqz	a0, 0x40001df4 <flexio_dev_yield+0x10c>
40001dee: 02023503     	ld	a0, 0x20(tp)
40001df2: c100         	sw	s0, 0x0(a0)
40001df4: 70a2         	ld	ra, 0x28(sp)
40001df6: 7402         	ld	s0, 0x20(sp)
40001df8: 64e2         	ld	s1, 0x18(sp)
40001dfa: 6942         	ld	s2, 0x10(sp)
40001dfc: 69a2         	ld	s3, 0x8(sp)
40001dfe: 6145         	addi	sp, sp, 0x30
40001e00: 8082         	ret
40001e02: 4505         	li	a0, 0x1
40001e04: 0204c583     	lbu	a1, 0x20(s1)
40001e08: 00a40023     	sb	a0, 0x0(s0)
40001e0c: c599         	beqz	a1, 0x40001e1a <flexio_dev_yield+0x132>
40001e0e: 01c4e583     	lwu	a1, 0x1c(s1)
40001e12: 4505         	li	a0, 0x1
40001e14: 48a9         	li	a7, 0xa
40001e16: 00000073     	ecall
40001e1a: 39e000ef     	jal	0x400021b8 <flexio_dev_thread_reschedule>

0000000040001e1e <flexio_dev_yield_and_retrigger>:
40001e1e: 1141         	addi	sp, sp, -0x10
40001e20: e406         	sd	ra, 0x8(sp)
40001e22: e022         	sd	s0, 0x0(sp)
40001e24: 02023403     	ld	s0, 0x20(tp)
40001e28: 4505         	li	a0, 0x1
40001e2a: 02a40023     	sb	a0, 0x20(s0)
40001e2e: ebbff0ef     	jal	0x40001ce8 <flexio_dev_yield>
40001e32: 02040023     	sb	zero, 0x20(s0)
40001e36: 60a2         	ld	ra, 0x8(sp)
40001e38: 6402         	ld	s0, 0x0(sp)
40001e3a: 0141         	addi	sp, sp, 0x10
40001e3c: 8082         	ret

0000000040001e3e <flexio_dev_bzero16.14>:
40001e3e: 99f9         	andi	a1, a1, -0x2
40001e40: c599         	beqz	a1, 0x40001e4e <flexio_dev_bzero16.14+0x10>
40001e42: 95aa         	add	a1, a1, a0
40001e44: 00051023     	sh	zero, 0x0(a0)
40001e48: 0509         	addi	a0, a0, 0x2
40001e4a: feb56de3     	bltu	a0, a1, 0x40001e44 <flexio_dev_bzero16.14+0x6>
40001e4e: 8082         	ret

0000000040001e50 <flexio_dev_bzero32.15>:
40001e50: 99f1         	andi	a1, a1, -0x4
40001e52: c599         	beqz	a1, 0x40001e60 <flexio_dev_bzero32.15+0x10>
40001e54: 95aa         	add	a1, a1, a0
40001e56: 00052023     	sw	zero, 0x0(a0)
40001e5a: 0511         	addi	a0, a0, 0x4
40001e5c: feb56de3     	bltu	a0, a1, 0x40001e56 <flexio_dev_bzero32.15+0x6>
40001e60: 8082         	ret

0000000040001e62 <flexio_dev_bzero64.16>:
40001e62: 99e1         	andi	a1, a1, -0x8
40001e64: c599         	beqz	a1, 0x40001e72 <flexio_dev_bzero64.16+0x10>
40001e66: 95aa         	add	a1, a1, a0
40001e68: 00053023     	sd	zero, 0x0(a0)
40001e6c: 0521         	addi	a0, a0, 0x8
40001e6e: feb56de3     	bltu	a0, a1, 0x40001e68 <flexio_dev_bzero64.16+0x6>
40001e72: 8082         	ret

0000000040001e74 <flexio_dev_cross_device_ring_db>:
40001e74: 0805453b     	zext.h	a0, a0
40001e78: 0805c5b3     	zext.w	a1, a1
40001e7c: 08064633     	zext.w	a2, a2
40001e80: 48ad         	li	a7, 0xb
40001e82: 00000073     	ecall
40001e86: 00153513     	seqz	a0, a0
40001e8a: 8082         	ret

0000000040001e8c <flexio_dev_event_handler_activate>:
40001e8c: 080545b3     	zext.w	a1, a0
40001e90: 4505         	li	a0, 0x1
40001e92: 48a9         	li	a7, 0xa
40001e94: 00000073     	ecall
40001e98: 8082         	ret

0000000040001e9a <flexio_dev_finish>:
40001e9a: 1141         	addi	sp, sp, -0x10
40001e9c: e406         	sd	ra, 0x8(sp)
40001e9e: 04000513     	li	a0, 0x40
40001ea2: 4891         	li	a7, 0x4
40001ea4: 00000073     	ecall

0000000040001ea8 <flexio_dev_get_current_thread_name>:
40001ea8: 02023503     	ld	a0, 0x20(tp)
40001eac: 02150513     	addi	a0, a0, 0x21
40001eb0: 8082         	ret

0000000040001eb2 <flexio_dev_get_pcc_table_base>:
40001eb2: 151a         	slli	a0, a0, 0x26
40001eb4: 2ba51513     	bseti	a0, a0, 0x3a
40001eb8: 8082         	ret

0000000040001eba <flexio_dev_get_thread_ctx>:
40001eba: 00453023     	sd	tp, 0x0(a0)
40001ebe: 4501         	li	a0, 0x0
40001ec0: 8082         	ret

0000000040001ec2 <flexio_dev_get_thread_id>:
40001ec2: 02023503     	ld	a0, 0x20(tp)
40001ec6: 4d48         	lw	a0, 0x1c(a0)
40001ec8: 8082         	ret

0000000040001eca <flexio_dev_get_thread_local_storage>:
40001eca: 02023503     	ld	a0, 0x20(tp)
40001ece: 7d08         	ld	a0, 0x38(a0)
40001ed0: 8082         	ret

0000000040001ed2 <flexio_dev_memcpy128.19>:
40001ed2: 8211         	srli	a2, a2, 0x4
40001ed4: ce09         	beqz	a2, 0x40001eee <flexio_dev_memcpy128.19+0x1c>
40001ed6: 0612         	slli	a2, a2, 0x4
40001ed8: 962a         	add	a2, a2, a0
40001eda: 6594         	ld	a3, 0x8(a1)
40001edc: 6198         	ld	a4, 0x0(a1)
40001ede: 05c1         	addi	a1, a1, 0x10
40001ee0: 01050793     	addi	a5, a0, 0x10
40001ee4: e118         	sd	a4, 0x0(a0)
40001ee6: e514         	sd	a3, 0x8(a0)
40001ee8: 853e         	mv	a0, a5
40001eea: fec798e3     	bne	a5, a2, 0x40001eda <flexio_dev_memcpy128.19+0x8>
40001eee: 8082         	ret

0000000040001ef0 <flexio_dev_memcpy16.20>:
40001ef0: 8205         	srli	a2, a2, 0x1
40001ef2: ce09         	beqz	a2, 0x40001f0c <flexio_dev_memcpy16.20+0x1c>
40001ef4: 0606         	slli	a2, a2, 0x1
40001ef6: 962a         	add	a2, a2, a0
40001ef8: 00059683     	lh	a3, 0x0(a1)
40001efc: 0589         	addi	a1, a1, 0x2
40001efe: 00250713     	addi	a4, a0, 0x2
40001f02: 00d51023     	sh	a3, 0x0(a0)
40001f06: 853a         	mv	a0, a4
40001f08: fec718e3     	bne	a4, a2, 0x40001ef8 <flexio_dev_memcpy16.20+0x8>
40001f0c: 8082         	ret

0000000040001f0e <flexio_dev_memcpy32.21>:
40001f0e: 8209         	srli	a2, a2, 0x2
40001f10: ca19         	beqz	a2, 0x40001f26 <flexio_dev_memcpy32.21+0x18>
40001f12: 060a         	slli	a2, a2, 0x2
40001f14: 962a         	add	a2, a2, a0
40001f16: 4194         	lw	a3, 0x0(a1)
40001f18: 0591         	addi	a1, a1, 0x4
40001f1a: 00450713     	addi	a4, a0, 0x4
40001f1e: c114         	sw	a3, 0x0(a0)
40001f20: 853a         	mv	a0, a4
40001f22: fec71ae3     	bne	a4, a2, 0x40001f16 <flexio_dev_memcpy32.21+0x8>
40001f26: 8082         	ret

0000000040001f28 <flexio_dev_memcpy64.22>:
40001f28: 820d         	srli	a2, a2, 0x3
40001f2a: ca19         	beqz	a2, 0x40001f40 <flexio_dev_memcpy64.22+0x18>
40001f2c: 060e         	slli	a2, a2, 0x3
40001f2e: 962a         	add	a2, a2, a0
40001f30: 6194         	ld	a3, 0x0(a1)
40001f32: 05a1         	addi	a1, a1, 0x8
40001f34: 00850713     	addi	a4, a0, 0x8
40001f38: e114         	sd	a3, 0x0(a0)
40001f3a: 853a         	mv	a0, a4
40001f3c: fec71ae3     	bne	a4, a2, 0x40001f30 <flexio_dev_memcpy64.22+0x8>
40001f40: 8082         	ret

0000000040001f42 <flexio_dev_multi_window_config>:
40001f42: 7179         	addi	sp, sp, -0x30
40001f44: f406         	sd	ra, 0x28(sp)
40001f46: f022         	sd	s0, 0x20(sp)
40001f48: ec26         	sd	s1, 0x18(sp)
40001f4a: e84a         	sd	s2, 0x10(sp)
40001f4c: e44e         	sd	s3, 0x8(sp)
40001f4e: 8932         	mv	s2, a2
40001f50: 84ae         	mv	s1, a1
40001f52: 842a         	mv	s0, a0
40001f54: 0440000f     	fence	o, o
40001f58: 4985         	li	s3, 0x1
40001f5a: e531         	bnez	a0, 0x40001fa6 <flexio_dev_multi_window_config+0x64>
40001f5c: 488d         	li	a7, 0x3
40001f5e: 8526         	mv	a0, s1
40001f60: 00000073     	ecall
40001f64: c90d         	beqz	a0, 0x40001f96 <flexio_dev_multi_window_config+0x54>
40001f66: 4981         	li	s3, 0x0
40001f68: 02023503     	ld	a0, 0x20(tp)
40001f6c: 00241593     	slli	a1, s0, 0x2
40001f70: 952e         	add	a0, a0, a1
40001f72: c944         	sw	s1, 0x14(a0)
40001f74: 0cc0000f     	fence	io, io
40001f78: 1462         	slli	s0, s0, 0x38
40001f7a: 9049         	srli	s0, s0, 0x32
40001f7c: 29041513     	bseti	a0, s0, 0x10
40001f80: 2a151513     	bseti	a0, a0, 0x21
40001f84: 01252023     	sw	s2, 0x0(a0)
40001f88: 0cc0000f     	fence	io, io
40001f8c: 02023503     	ld	a0, 0x20(tp)
40001f90: 952e         	add	a0, a0, a1
40001f92: 01252623     	sw	s2, 0xc(a0)
40001f96: 854e         	mv	a0, s3
40001f98: 70a2         	ld	ra, 0x28(sp)
40001f9a: 7402         	ld	s0, 0x20(sp)
40001f9c: 64e2         	ld	s1, 0x18(sp)
40001f9e: 6942         	ld	s2, 0x10(sp)
40001fa0: 69a2         	ld	s3, 0x8(sp)
40001fa2: 6145         	addi	sp, sp, 0x30
40001fa4: 8082         	ret
40001fa6: 4505         	li	a0, 0x1
40001fa8: fea417e3     	bne	s0, a0, 0x40001f96 <flexio_dev_multi_window_config+0x54>
40001fac: 8526         	mv	a0, s1
40001fae: 489d         	li	a7, 0x7
40001fb0: 00000073     	ecall
40001fb4: 4985         	li	s3, 0x1
40001fb6: f945         	bnez	a0, 0x40001f66 <flexio_dev_multi_window_config+0x24>
40001fb8: bff9         	j	0x40001f96 <flexio_dev_multi_window_config+0x54>

0000000040001fba <flexio_dev_multi_window_copy_from_host>:
40001fba: 4705         	li	a4, 0x1
40001fbc: 02a76463     	bltu	a4, a0, 0x40001fe4 <flexio_dev_multi_window_copy_from_host+0x2a>
40001fc0: c215         	beqz	a2, 0x40001fe4 <flexio_dev_multi_window_copy_from_host+0x2a>
40001fc2: 1141         	addi	sp, sp, -0x10
40001fc4: e406         	sd	ra, 0x8(sp)
40001fc6: 060e         	slli	a2, a2, 0x3
40001fc8: 820d         	srli	a2, a2, 0x3
40001fca: 2bf61713     	bseti	a4, a2, 0x3f
40001fce: 0880000f     	fence	i, i
40001fd2: 0806c633     	zext.w	a2, a3
40001fd6: 852e         	mv	a0, a1
40001fd8: 85ba         	mv	a1, a4
40001fda: 89efe0ef     	jal	0x40000078 <memcpy>
40001fde: 4701         	li	a4, 0x0
40001fe0: 60a2         	ld	ra, 0x8(sp)
40001fe2: 0141         	addi	sp, sp, 0x10
40001fe4: 853a         	mv	a0, a4
40001fe6: 8082         	ret

0000000040001fe8 <flexio_dev_multi_window_copy_to_host>:
40001fe8: 4705         	li	a4, 0x1
40001fea: 02a76463     	bltu	a4, a0, 0x40002012 <flexio_dev_multi_window_copy_to_host+0x2a>
40001fee: c195         	beqz	a1, 0x40002012 <flexio_dev_multi_window_copy_to_host+0x2a>
40001ff0: 1141         	addi	sp, sp, -0x10
40001ff2: e406         	sd	ra, 0x8(sp)
40001ff4: 058e         	slli	a1, a1, 0x3
40001ff6: 818d         	srli	a1, a1, 0x3
40001ff8: 2bf59513     	bseti	a0, a1, 0x3f
40001ffc: 0806c6b3     	zext.w	a3, a3
40002000: 85b2         	mv	a1, a2
40002002: 8636         	mv	a2, a3
40002004: 874fe0ef     	jal	0x40000078 <memcpy>
40002008: 4701         	li	a4, 0x0
4000200a: 0440000f     	fence	o, o
4000200e: 60a2         	ld	ra, 0x8(sp)
40002010: 0141         	addi	sp, sp, 0x10
40002012: 853a         	mv	a0, a4
40002014: 8082         	ret

0000000040002016 <flexio_dev_multi_window_mkey_config>:
40002016: 4605         	li	a2, 0x1
40002018: 02a66363     	bltu	a2, a0, 0x4000203e <flexio_dev_multi_window_mkey_config+0x28>
4000201c: 4601         	li	a2, 0x0
4000201e: 0cc0000f     	fence	io, io
40002022: 0065169b     	slliw	a3, a0, 0x6
40002026: 29069693     	bseti	a3, a3, 0x10
4000202a: 2a169693     	bseti	a3, a3, 0x21
4000202e: c28c         	sw	a1, 0x0(a3)
40002030: 0cc0000f     	fence	io, io
40002034: 02023683     	ld	a3, 0x20(tp)
40002038: 050a         	slli	a0, a0, 0x2
4000203a: 9536         	add	a0, a0, a3
4000203c: c54c         	sw	a1, 0xc(a0)
4000203e: 8532         	mv	a0, a2
40002040: 8082         	ret

0000000040002042 <flexio_dev_multi_window_ptr_acquire>:
40002042: 4685         	li	a3, 0x1
40002044: 00a6e963     	bltu	a3, a0, 0x40002056 <flexio_dev_multi_window_ptr_acquire+0x14>
40002048: c599         	beqz	a1, 0x40002056 <flexio_dev_multi_window_ptr_acquire+0x14>
4000204a: 4681         	li	a3, 0x0
4000204c: 058e         	slli	a1, a1, 0x3
4000204e: 818d         	srli	a1, a1, 0x3
40002050: 2bf59513     	bseti	a0, a1, 0x3f
40002054: e208         	sd	a0, 0x0(a2)
40002056: 8536         	mv	a0, a3
40002058: 8082         	ret

000000004000205a <flexio_dev_nic_counters_config>:
4000205a: 872e         	mv	a4, a1
4000205c: 85aa         	mv	a1, a0
4000205e: 080646b3     	zext.w	a3, a2
40002062: 48a5         	li	a7, 0x9
40002064: 4501         	li	a0, 0x0
40002066: 863a         	mv	a2, a4
40002068: 00000073     	ecall
4000206c: 8082         	ret

000000004000206e <flexio_dev_nic_counters_sample>:
4000206e: 1141         	addi	sp, sp, -0x10
40002070: e406         	sd	ra, 0x8(sp)
40002072: 4505         	li	a0, 0x1
40002074: 48a5         	li	a7, 0x9
40002076: 00000073     	ecall
4000207a: 60a2         	ld	ra, 0x8(sp)
4000207c: 0141         	addi	sp, sp, 0x10
4000207e: 8082         	ret

0000000040002080 <flexio_dev_outbox_config>:
40002080: 1141         	addi	sp, sp, -0x10
40002082: e406         	sd	ra, 0x8(sp)
40002084: e022         	sd	s0, 0x0(sp)
40002086: 842e         	mv	s0, a1
40002088: 0cc0000f     	fence	io, io
4000208c: 4889         	li	a7, 0x2
4000208e: 852e         	mv	a0, a1
40002090: 00000073     	ecall
40002094: c909         	beqz	a0, 0x400020a6 <flexio_dev_outbox_config+0x26>
40002096: 4501         	li	a0, 0x0
40002098: 02023583     	ld	a1, 0x20(tp)
4000209c: c580         	sw	s0, 0x8(a1)
4000209e: 60a2         	ld	ra, 0x8(sp)
400020a0: 6402         	ld	s0, 0x0(sp)
400020a2: 0141         	addi	sp, sp, 0x10
400020a4: 8082         	ret
400020a6: 4505         	li	a0, 0x1
400020a8: bfdd         	j	0x4000209e <flexio_dev_outbox_config+0x1e>

00000000400020aa <flexio_dev_outbox_config_fast>:
400020aa: 1141         	addi	sp, sp, -0x10
400020ac: e406         	sd	ra, 0x8(sp)
400020ae: e022         	sd	s0, 0x0(sp)
400020b0: 842e         	mv	s0, a1
400020b2: 4889         	li	a7, 0x2
400020b4: 852e         	mv	a0, a1
400020b6: 00000073     	ecall
400020ba: c501         	beqz	a0, 0x400020c2 <flexio_dev_outbox_config_fast+0x18>
400020bc: 02023503     	ld	a0, 0x20(tp)
400020c0: c500         	sw	s0, 0x8(a0)
400020c2: 60a2         	ld	ra, 0x8(sp)
400020c4: 6402         	ld	s0, 0x0(sp)
400020c6: 0141         	addi	sp, sp, 0x10
400020c8: 8082         	ret

00000000400020ca <flexio_dev_outbox_config_uar_extension>:
400020ca: 1141         	addi	sp, sp, -0x10
400020cc: e422         	sd	s0, 0x8(sp)
400020ce: 842e         	mv	s0, a1
400020d0: 00823583     	ld	a1, 0x8(tp)
400020d4: 0804453b     	zext.h	a0, s0
400020d8: 4895         	li	a7, 0x5
400020da: 00000073     	ecall
400020de: c901         	beqz	a0, 0x400020ee <flexio_dev_outbox_config_uar_extension+0x24>
400020e0: 4501         	li	a0, 0x0
400020e2: 02023583     	ld	a1, 0x20(tp)
400020e6: c180         	sw	s0, 0x0(a1)
400020e8: 6422         	ld	s0, 0x8(sp)
400020ea: 0141         	addi	sp, sp, 0x10
400020ec: 8082         	ret
400020ee: 4505         	li	a0, 0x1
400020f0: bfe5         	j	0x400020e8 <flexio_dev_outbox_config_uar_extension+0x1e>

00000000400020f2 <flexio_dev_perf_measure_calibrate>:
400020f2: 1141         	addi	sp, sp, -0x10
400020f4: e406         	sd	ra, 0x8(sp)
400020f6: e022         	sd	s0, 0x0(sp)
400020f8: 00003517     	auipc	a0, 0x3
400020fc: d9c50413     	addi	s0, a0, -0x264
40002100: 4591         	li	a1, 0x4
40002102: 4501         	li	a0, 0x0
40002104: 8622         	mv	a2, s0
40002106: 376000ef     	jal	0x4000247c <flexio_dev_msg>
4000210a: 00003517     	auipc	a0, 0x3
4000210e: cee50613     	addi	a2, a0, -0x312
40002112: 4591         	li	a1, 0x4
40002114: 4501         	li	a0, 0x0
40002116: 366000ef     	jal	0x4000247c <flexio_dev_msg>
4000211a: c0002573     	rdcycle	a0
4000211e: c02025f3     	rdinstret	a1
40002122: c00027f3     	rdcycle	a5
40002126: 8f89         	sub	a5, a5, a0
40002128: c0202773     	rdinstret	a4
4000212c: 8f0d         	sub	a4, a4, a1
4000212e: 00003517     	auipc	a0, 0x3
40002132: daf50613     	addi	a2, a0, -0x251
40002136: 00003517     	auipc	a0, 0x3
4000213a: cbb50693     	addi	a3, a0, -0x345
4000213e: 4591         	li	a1, 0x4
40002140: 4501         	li	a0, 0x0
40002142: 33a000ef     	jal	0x4000247c <flexio_dev_msg>
40002146: 00003517     	auipc	a0, 0x3
4000214a: c6650613     	addi	a2, a0, -0x39a
4000214e: 4591         	li	a1, 0x4
40002150: 4501         	li	a0, 0x0
40002152: 32a000ef     	jal	0x4000247c <flexio_dev_msg>
40002156: 4591         	li	a1, 0x4
40002158: 4501         	li	a0, 0x0
4000215a: 8622         	mv	a2, s0
4000215c: 60a2         	ld	ra, 0x8(sp)
4000215e: 6402         	ld	s0, 0x0(sp)
40002160: 0141         	addi	sp, sp, 0x10
40002162: ae29         	j	0x4000247c <flexio_dev_msg>

0000000040002164 <flexio_dev_perf_print>:
40002164: 86ae         	mv	a3, a1
40002166: 6518         	ld	a4, 0x8(a0)
40002168: 611c         	ld	a5, 0x0(a0)
4000216a: 00003517     	auipc	a0, 0x3
4000216e: d7350613     	addi	a2, a0, -0x28d
40002172: 4591         	li	a1, 0x4
40002174: 4501         	li	a0, 0x0
40002176: a619         	j	0x4000247c <flexio_dev_msg>

0000000040002178 <flexio_dev_process_finish>:
40002178: 1141         	addi	sp, sp, -0x10
4000217a: e406         	sd	ra, 0x8(sp)
4000217c: 04000513     	li	a0, 0x40
40002180: 4891         	li	a7, 0x4
40002182: 00000073     	ecall

0000000040002186 <flexio_dev_reschedule>:
40002186: 032000ef     	jal	0x400021b8 <flexio_dev_thread_reschedule>

000000004000218a <flexio_dev_thread_finish>:
4000218a: 1141         	addi	sp, sp, -0x10
4000218c: e406         	sd	ra, 0x8(sp)
4000218e: 4505         	li	a0, 0x1
40002190: 4881         	li	a7, 0x0
40002192: 00000073     	ecall

0000000040002196 <flexio_dev_thread_is_wrapped>:
40002196: 02023503     	ld	a0, 0x20(tp)
4000219a: 03254503     	lbu	a0, 0x32(a0)
4000219e: 8082         	ret

00000000400021a0 <flexio_dev_thread_longjmp>:
400021a0: 02023503     	ld	a0, 0x20(tp)
400021a4: 03254583     	lbu	a1, 0x32(a0)
400021a8: c599         	beqz	a1, 0x400021b6 <flexio_dev_thread_longjmp+0x16>
400021aa: 1141         	addi	sp, sp, -0x10
400021ac: e406         	sd	ra, 0x8(sp)
400021ae: 6128         	ld	a0, 0x40(a0)
400021b0: 0521         	addi	a0, a0, 0x8
400021b2: e8bfd0ef     	jal	0x4000003c <__dpa_os_restore>
400021b6: 8082         	ret

00000000400021b8 <flexio_dev_thread_reschedule>:
400021b8: 1141         	addi	sp, sp, -0x10
400021ba: e406         	sd	ra, 0x8(sp)
400021bc: 02023503     	ld	a0, 0x20(tp)
400021c0: 55fd         	li	a1, -0x1
400021c2: c10c         	sw	a1, 0x0(a0)
400021c4: 4501         	li	a0, 0x0
400021c6: 4881         	li	a7, 0x0
400021c8: 00000073     	ecall

00000000400021cc <flexio_dev_thread_retrigger>:
400021cc: 1141         	addi	sp, sp, -0x10
400021ce: e406         	sd	ra, 0x8(sp)
400021d0: 02023503     	ld	a0, 0x20(tp)
400021d4: 55fd         	li	a1, -0x1
400021d6: c10c         	sw	a1, 0x0(a0)
400021d8: 4509         	li	a0, 0x2
400021da: 4881         	li	a7, 0x0
400021dc: 00000073     	ecall

00000000400021e0 <flexio_dev_bzero16.42>:
400021e0: 99f9         	andi	a1, a1, -0x2
400021e2: c599         	beqz	a1, 0x400021f0 <flexio_dev_bzero16.42+0x10>
400021e4: 95aa         	add	a1, a1, a0
400021e6: 00051023     	sh	zero, 0x0(a0)
400021ea: 0509         	addi	a0, a0, 0x2
400021ec: feb56de3     	bltu	a0, a1, 0x400021e6 <flexio_dev_bzero16.42+0x6>
400021f0: 8082         	ret

00000000400021f2 <flexio_dev_bzero32.43>:
400021f2: 99f1         	andi	a1, a1, -0x4
400021f4: c599         	beqz	a1, 0x40002202 <flexio_dev_bzero32.43+0x10>
400021f6: 95aa         	add	a1, a1, a0
400021f8: 00052023     	sw	zero, 0x0(a0)
400021fc: 0511         	addi	a0, a0, 0x4
400021fe: feb56de3     	bltu	a0, a1, 0x400021f8 <flexio_dev_bzero32.43+0x6>
40002202: 8082         	ret

0000000040002204 <flexio_dev_bzero64.44>:
40002204: 99e1         	andi	a1, a1, -0x8
40002206: c599         	beqz	a1, 0x40002214 <flexio_dev_bzero64.44+0x10>
40002208: 95aa         	add	a1, a1, a0
4000220a: 00053023     	sd	zero, 0x0(a0)
4000220e: 0521         	addi	a0, a0, 0x8
40002210: feb56de3     	bltu	a0, a1, 0x4000220a <flexio_dev_bzero64.44+0x6>
40002214: 8082         	ret

0000000040002216 <flexio_dev_error>:
40002216: 1141         	addi	sp, sp, -0x10
40002218: e406         	sd	ra, 0x8(sp)
4000221a: e022         	sd	s0, 0x0(sp)
4000221c: 03851593     	slli	a1, a0, 0x38
40002220: fbe50513     	addi	a0, a0, -0x42
40002224: 95fd         	srai	a1, a1, 0x3f
40002226: 8d6d         	and	a0, a0, a1
40002228: 04250413     	addi	s0, a0, 0x42
4000222c: 00003517     	auipc	a0, 0x3
40002230: c3150613     	addi	a2, a0, -0x3cf
40002234: 4591         	li	a1, 0x4
40002236: 4501         	li	a0, 0x0
40002238: 86a2         	mv	a3, s0
4000223a: 242000ef     	jal	0x4000247c <flexio_dev_msg>
4000223e: 4891         	li	a7, 0x4
40002240: 8522         	mv	a0, s0
40002242: 00000073     	ecall

0000000040002246 <flexio_dev_get_and_rst_errno>:
40002246: 02820513     	addi	a0, tp, 0x28
4000224a: 0e05252f     	amoswap.w.aqrl	a0, zero, (a0)
4000224e: 08054533     	zext.w	a0, a0
40002252: 8082         	ret

0000000040002254 <flexio_dev_get_errno>:
40002254: 02826503     	lwu	a0, 0x28(tp)
40002258: 8082         	ret

000000004000225a <flexio_dev_memcpy128.45>:
4000225a: 8211         	srli	a2, a2, 0x4
4000225c: ce09         	beqz	a2, 0x40002276 <flexio_dev_memcpy128.45+0x1c>
4000225e: 0612         	slli	a2, a2, 0x4
40002260: 962a         	add	a2, a2, a0
40002262: 6594         	ld	a3, 0x8(a1)
40002264: 6198         	ld	a4, 0x0(a1)
40002266: 05c1         	addi	a1, a1, 0x10
40002268: 01050793     	addi	a5, a0, 0x10
4000226c: e118         	sd	a4, 0x0(a0)
4000226e: e514         	sd	a3, 0x8(a0)
40002270: 853e         	mv	a0, a5
40002272: fec798e3     	bne	a5, a2, 0x40002262 <flexio_dev_memcpy128.45+0x8>
40002276: 8082         	ret

0000000040002278 <flexio_dev_memcpy16.46>:
40002278: 8205         	srli	a2, a2, 0x1
4000227a: ce09         	beqz	a2, 0x40002294 <flexio_dev_memcpy16.46+0x1c>
4000227c: 0606         	slli	a2, a2, 0x1
4000227e: 962a         	add	a2, a2, a0
40002280: 00059683     	lh	a3, 0x0(a1)
40002284: 0589         	addi	a1, a1, 0x2
40002286: 00250713     	addi	a4, a0, 0x2
4000228a: 00d51023     	sh	a3, 0x0(a0)
4000228e: 853a         	mv	a0, a4
40002290: fec718e3     	bne	a4, a2, 0x40002280 <flexio_dev_memcpy16.46+0x8>
40002294: 8082         	ret

0000000040002296 <flexio_dev_memcpy32.47>:
40002296: 8209         	srli	a2, a2, 0x2
40002298: ca19         	beqz	a2, 0x400022ae <flexio_dev_memcpy32.47+0x18>
4000229a: 060a         	slli	a2, a2, 0x2
4000229c: 962a         	add	a2, a2, a0
4000229e: 4194         	lw	a3, 0x0(a1)
400022a0: 0591         	addi	a1, a1, 0x4
400022a2: 00450713     	addi	a4, a0, 0x4
400022a6: c114         	sw	a3, 0x0(a0)
400022a8: 853a         	mv	a0, a4
400022aa: fec71ae3     	bne	a4, a2, 0x4000229e <flexio_dev_memcpy32.47+0x8>
400022ae: 8082         	ret

00000000400022b0 <flexio_dev_memcpy64.48>:
400022b0: 820d         	srli	a2, a2, 0x3
400022b2: ca19         	beqz	a2, 0x400022c8 <flexio_dev_memcpy64.48+0x18>
400022b4: 060e         	slli	a2, a2, 0x3
400022b6: 962a         	add	a2, a2, a0
400022b8: 6194         	ld	a3, 0x0(a1)
400022ba: 05a1         	addi	a1, a1, 0x8
400022bc: 00850713     	addi	a4, a0, 0x8
400022c0: e114         	sd	a3, 0x0(a0)
400022c2: 853a         	mv	a0, a4
400022c4: fec71ae3     	bne	a4, a2, 0x400022b8 <flexio_dev_memcpy64.48+0x8>
400022c8: 8082         	ret

00000000400022ca <flexio_dev_rst_errno>:
400022ca: 02022423     	sw	zero, 0x28(tp)
400022ce: 8082         	ret

00000000400022d0 <flexio_dev_tracer_notify_host>:
400022d0: 00351613     	slli	a2, a0, 0x3
400022d4: 3fffe517     	auipc	a0, 0x3fffe
400022d8: e8450513     	addi	a0, a0, -0x17c
400022dc: 9532         	add	a0, a0, a2
400022de: 6108         	ld	a0, 0x0(a0)
400022e0: 01b54883     	lbu	a7, 0x1b(a0)
400022e4: 3fffe697     	auipc	a3, 0x3fffe
400022e8: 66c68693     	addi	a3, a3, 0x66c
400022ec: 9636         	add	a2, a2, a3
400022ee: 00063803     	ld	a6, 0x0(a2)
400022f2: 6930         	ld	a2, 0x50(a0)
400022f4: 01054683     	lbu	a3, 0x10(a0)
400022f8: 57fd         	li	a5, -0x1
400022fa: 00d796b3     	sll	a3, a5, a3
400022fe: 751c         	ld	a5, 0x28(a0)
40002300: 00c66703     	lwu	a4, 0xc(a2)
40002304: 40d776b3     	andn	a3, a4, a3
40002308: 069a         	slli	a3, a3, 0x6
4000230a: 96be         	add	a3, a3, a5
4000230c: 4658         	lw	a4, 0xc(a2)
4000230e: 411c         	lw	a5, 0x0(a0)
40002310: 1742         	slli	a4, a4, 0x30
40002312: 9321         	srli	a4, a4, 0x28
40002314: 2729         	addiw	a4, a4, 0xa
40002316: 6987571b     	greviw	a4, a4, 0x18
4000231a: c298         	sw	a4, 0x0(a3)
4000231c: 470d         	li	a4, 0x3
4000231e: 0087979b     	slliw	a5, a5, 0x8
40002322: 04e89963     	bne	a7, a4, 0x40002374 <flexio_dev_tracer_notify_host+0xa4>
40002326: 0037e713     	ori	a4, a5, 0x3
4000232a: 6987571b     	greviw	a4, a4, 0x18
4000232e: c2d8         	sw	a4, 0x4(a3)
40002330: 0006b423     	sd	zero, 0x8(a3)
40002334: 4d58         	lw	a4, 0x1c(a0)
40002336: 593c         	lw	a5, 0x70(a0)
40002338: 07451883     	lh	a7, 0x74(a0)
4000233c: 6987571b     	greviw	a4, a4, 0x18
40002340: ca98         	sw	a4, 0x10(a3)
40002342: 0006aa23     	sw	zero, 0x14(a3)
40002346: 6987d71b     	greviw	a4, a5, 0x18
4000234a: ce98         	sw	a4, 0x18(a3)
4000234c: 6721         	lui	a4, 0x8
4000234e: 00e69e23     	sh	a4, 0x1c(a3)
40002352: 6888d71b     	greviw	a4, a7, 0x8
40002356: 00e69f23     	sh	a4, 0x1e(a3)
4000235a: 0065959b     	slliw	a1, a1, 0x6
4000235e: 451c         	lw	a5, 0x8(a0)
40002360: 01883803     	ld	a6, 0x18(a6)
40002364: 6985d59b     	greviw	a1, a1, 0x18
40002368: d28c         	sw	a1, 0x20(a3)
4000236a: 02800713     	li	a4, 0x28
4000236e: 02400593     	li	a1, 0x24
40002372: a015         	j	0x40002396 <flexio_dev_tracer_notify_host+0xc6>
40002374: 0027e713     	ori	a4, a5, 0x2
40002378: 6987571b     	greviw	a4, a4, 0x18
4000237c: c2d8         	sw	a4, 0x4(a3)
4000237e: 0006b423     	sd	zero, 0x8(a3)
40002382: 0065959b     	slliw	a1, a1, 0x6
40002386: 451c         	lw	a5, 0x8(a0)
40002388: 01883803     	ld	a6, 0x18(a6)
4000238c: 6985d59b     	greviw	a1, a1, 0x18
40002390: ca8c         	sw	a1, 0x10(a3)
40002392: 4761         	li	a4, 0x18
40002394: 45d1         	li	a1, 0x14
40002396: 6987d79b     	greviw	a5, a5, 0x18
4000239a: 95b6         	add	a1, a1, a3
4000239c: c19c         	sw	a5, 0x0(a1)
4000239e: 6b885593     	rev8	a1, a6
400023a2: 96ba         	add	a3, a3, a4
400023a4: e28c         	sd	a1, 0x0(a3)
400023a6: 0110000f     	fence	w, w
400023aa: 464c         	lw	a1, 0xc(a2)
400023ac: 0585         	addi	a1, a1, 0x1
400023ae: c64c         	sw	a1, 0xc(a2)
400023b0: 00c66583     	lwu	a1, 0xc(a2)
400023b4: 00056503     	lwu	a0, 0x0(a0)
400023b8: 2a101613     	bseti	a2, zero, 0x21
400023bc: 6214         	ld	a3, 0x0(a2)
400023be: 8a85         	andi	a3, a3, 0x1
400023c0: fef5         	bnez	a3, 0x400023bc <flexio_dev_tracer_notify_host+0xec>
400023c2: 0805c5bb     	zext.h	a1, a1
400023c6: 08a5c533     	pack	a0, a1, a0
400023ca: 1c000593     	li	a1, 0x1c0
400023ce: 2a159593     	bseti	a1, a1, 0x21
400023d2: e188         	sd	a0, 0x0(a1)
400023d4: 8082         	ret

00000000400023d6 <flexio_dev_bzero16.56>:
400023d6: 99f9         	andi	a1, a1, -0x2
400023d8: c599         	beqz	a1, 0x400023e6 <flexio_dev_bzero16.56+0x10>
400023da: 95aa         	add	a1, a1, a0
400023dc: 00051023     	sh	zero, 0x0(a0)
400023e0: 0509         	addi	a0, a0, 0x2
400023e2: feb56de3     	bltu	a0, a1, 0x400023dc <flexio_dev_bzero16.56+0x6>
400023e6: 8082         	ret

00000000400023e8 <flexio_dev_bzero32.57>:
400023e8: 99f1         	andi	a1, a1, -0x4
400023ea: c599         	beqz	a1, 0x400023f8 <flexio_dev_bzero32.57+0x10>
400023ec: 95aa         	add	a1, a1, a0
400023ee: 00052023     	sw	zero, 0x0(a0)
400023f2: 0511         	addi	a0, a0, 0x4
400023f4: feb56de3     	bltu	a0, a1, 0x400023ee <flexio_dev_bzero32.57+0x6>
400023f8: 8082         	ret

00000000400023fa <flexio_dev_bzero64.58>:
400023fa: 99e1         	andi	a1, a1, -0x8
400023fc: c599         	beqz	a1, 0x4000240a <flexio_dev_bzero64.58+0x10>
400023fe: 95aa         	add	a1, a1, a0
40002400: 00053023     	sd	zero, 0x0(a0)
40002404: 0521         	addi	a0, a0, 0x8
40002406: feb56de3     	bltu	a0, a1, 0x40002400 <flexio_dev_bzero64.58+0x6>
4000240a: 8082         	ret

000000004000240c <flexio_dev_memcpy128.59>:
4000240c: 8211         	srli	a2, a2, 0x4
4000240e: ce09         	beqz	a2, 0x40002428 <flexio_dev_memcpy128.59+0x1c>
40002410: 0612         	slli	a2, a2, 0x4
40002412: 962a         	add	a2, a2, a0
40002414: 6594         	ld	a3, 0x8(a1)
40002416: 6198         	ld	a4, 0x0(a1)
40002418: 05c1         	addi	a1, a1, 0x10
4000241a: 01050793     	addi	a5, a0, 0x10
4000241e: e118         	sd	a4, 0x0(a0)
40002420: e514         	sd	a3, 0x8(a0)
40002422: 853e         	mv	a0, a5
40002424: fec798e3     	bne	a5, a2, 0x40002414 <flexio_dev_memcpy128.59+0x8>
40002428: 8082         	ret

000000004000242a <flexio_dev_memcpy16.60>:
4000242a: 8205         	srli	a2, a2, 0x1
4000242c: ce09         	beqz	a2, 0x40002446 <flexio_dev_memcpy16.60+0x1c>
4000242e: 0606         	slli	a2, a2, 0x1
40002430: 962a         	add	a2, a2, a0
40002432: 00059683     	lh	a3, 0x0(a1)
40002436: 0589         	addi	a1, a1, 0x2
40002438: 00250713     	addi	a4, a0, 0x2
4000243c: 00d51023     	sh	a3, 0x0(a0)
40002440: 853a         	mv	a0, a4
40002442: fec718e3     	bne	a4, a2, 0x40002432 <flexio_dev_memcpy16.60+0x8>
40002446: 8082         	ret

0000000040002448 <flexio_dev_memcpy32.61>:
40002448: 8209         	srli	a2, a2, 0x2
4000244a: ca19         	beqz	a2, 0x40002460 <flexio_dev_memcpy32.61+0x18>
4000244c: 060a         	slli	a2, a2, 0x2
4000244e: 962a         	add	a2, a2, a0
40002450: 4194         	lw	a3, 0x0(a1)
40002452: 0591         	addi	a1, a1, 0x4
40002454: 00450713     	addi	a4, a0, 0x4
40002458: c114         	sw	a3, 0x0(a0)
4000245a: 853a         	mv	a0, a4
4000245c: fec71ae3     	bne	a4, a2, 0x40002450 <flexio_dev_memcpy32.61+0x8>
40002460: 8082         	ret

0000000040002462 <flexio_dev_memcpy64.62>:
40002462: 820d         	srli	a2, a2, 0x3
40002464: ca19         	beqz	a2, 0x4000247a <flexio_dev_memcpy64.62+0x18>
40002466: 060e         	slli	a2, a2, 0x3
40002468: 962a         	add	a2, a2, a0
4000246a: 6194         	ld	a3, 0x0(a1)
4000246c: 05a1         	addi	a1, a1, 0x8
4000246e: 00850713     	addi	a4, a0, 0x8
40002472: e114         	sd	a3, 0x0(a0)
40002474: 853a         	mv	a0, a4
40002476: fec71ae3     	bne	a4, a2, 0x4000246a <flexio_dev_memcpy64.62+0x8>
4000247a: 8082         	ret

000000004000247c <flexio_dev_msg>:
4000247c: 7175         	addi	sp, sp, -0x90
4000247e: ec86         	sd	ra, 0x58(sp)
40002480: e8a2         	sd	s0, 0x50(sp)
40002482: e4a6         	sd	s1, 0x48(sp)
40002484: e0ca         	sd	s2, 0x40(sp)
40002486: fc4e         	sd	s3, 0x38(sp)
40002488: f852         	sd	s4, 0x30(sp)
4000248a: f456         	sd	s5, 0x28(sp)
4000248c: f05a         	sd	s6, 0x20(sp)
4000248e: ec5e         	sd	s7, 0x18(sp)
40002490: e862         	sd	s8, 0x10(sp)
40002492: e466         	sd	s9, 0x8(sp)
40002494: 8932         	mv	s2, a2
40002496: 8a2e         	mv	s4, a1
40002498: e546         	sd	a7, 0x88(sp)
4000249a: e142         	sd	a6, 0x80(sp)
4000249c: fcbe         	sd	a5, 0x78(sp)
4000249e: f8ba         	sd	a4, 0x70(sp)
400024a0: 15e9         	addi	a1, a1, -0x6
400024a2: 566d         	li	a2, -0x5
400024a4: f4b6         	sd	a3, 0x68(sp)
400024a6: 00c5f463     	bgeu	a1, a2, 0x400024ae <flexio_dev_msg+0x32>
400024aa: 5c7d         	li	s8, -0x1
400024ac: a855         	j	0x40002560 <flexio_dev_msg+0xe4>
400024ae: 0ff00993     	li	s3, 0xff
400024b2: 07351163     	bne	a0, s3, 0x40002514 <flexio_dev_msg+0x98>
400024b6: 4481         	li	s1, 0x0
400024b8: 4c01         	li	s8, 0x0
400024ba: 3fffe517     	auipc	a0, 0x3fffe
400024be: c9e50a93     	addi	s5, a0, -0x362
400024c2: 06810b13     	addi	s6, sp, 0x68
400024c6: 4b8d         	li	s7, 0x3
400024c8: 4c85         	li	s9, 0x1
400024ca: a039         	j	0x400024d8 <flexio_dev_msg+0x5c>
400024cc: 4501         	li	a0, 0x0
400024ce: 01856c33     	or	s8, a0, s8
400024d2: 0485         	addi	s1, s1, 0x1
400024d4: 09348663     	beq	s1, s3, 0x40002560 <flexio_dev_msg+0xe4>
400024d8: 00349513     	slli	a0, s1, 0x3
400024dc: 9556         	add	a0, a0, s5
400024de: 6108         	ld	a0, 0x0(a0)
400024e0: d96d         	beqz	a0, 0x400024d2 <flexio_dev_msg+0x56>
400024e2: 01a54583     	lbu	a1, 0x1a(a0)
400024e6: e05a         	sd	s6, 0x0(sp)
400024e8: ff45e2e3     	bltu	a1, s4, 0x400024cc <flexio_dev_msg+0x50>
400024ec: 01354583     	lbu	a1, 0x13(a0)
400024f0: fd758ee3     	beq	a1, s7, 0x400024cc <flexio_dev_msg+0x50>
400024f4: 6920         	ld	s0, 0x50(a0)
400024f6: 404c         	lw	a1, 0x4(s0)
400024f8: d9f1         	beqz	a1, 0x400024cc <flexio_dev_msg+0x50>
400024fa: 7128         	ld	a0, 0x60(a0)
400024fc: 0f9425af     	amoswap.w.aqrl	a1, s9, (s0)
40002500: fdf5         	bnez	a1, 0x400024fc <flexio_dev_msg+0x80>
40002502: 10b0         	addi	a2, sp, 0x68
40002504: 85ca         	mv	a1, s2
40002506: e5ffd0ef     	jal	0x40000364 <vfprintf>
4000250a: 0310000f     	fence	rw, w
4000250e: 00042023     	sw	zero, 0x0(s0)
40002512: bf75         	j	0x400024ce <flexio_dev_msg+0x52>
40002514: 050e         	slli	a0, a0, 0x3
40002516: 3fffe597     	auipc	a1, 0x3fffe
4000251a: c4258593     	addi	a1, a1, -0x3be
4000251e: 952e         	add	a0, a0, a1
40002520: 10ac         	addi	a1, sp, 0x68
40002522: 6108         	ld	a0, 0x0(a0)
40002524: e02e         	sd	a1, 0x0(sp)
40002526: cd05         	beqz	a0, 0x4000255e <flexio_dev_msg+0xe2>
40002528: 01a54583     	lbu	a1, 0x1a(a0)
4000252c: 0345e963     	bltu	a1, s4, 0x4000255e <flexio_dev_msg+0xe2>
40002530: 01354583     	lbu	a1, 0x13(a0)
40002534: 460d         	li	a2, 0x3
40002536: 02c58463     	beq	a1, a2, 0x4000255e <flexio_dev_msg+0xe2>
4000253a: 6920         	ld	s0, 0x50(a0)
4000253c: 404c         	lw	a1, 0x4(s0)
4000253e: c185         	beqz	a1, 0x4000255e <flexio_dev_msg+0xe2>
40002540: 7128         	ld	a0, 0x60(a0)
40002542: 4585         	li	a1, 0x1
40002544: 0eb4262f     	amoswap.w.aqrl	a2, a1, (s0)
40002548: fe75         	bnez	a2, 0x40002544 <flexio_dev_msg+0xc8>
4000254a: 10b0         	addi	a2, sp, 0x68
4000254c: 85ca         	mv	a1, s2
4000254e: e17fd0ef     	jal	0x40000364 <vfprintf>
40002552: 8c2a         	mv	s8, a0
40002554: 0310000f     	fence	rw, w
40002558: 00042023     	sw	zero, 0x0(s0)
4000255c: a011         	j	0x40002560 <flexio_dev_msg+0xe4>
4000255e: 4c01         	li	s8, 0x0
40002560: 8562         	mv	a0, s8
40002562: 60e6         	ld	ra, 0x58(sp)
40002564: 6446         	ld	s0, 0x50(sp)
40002566: 64a6         	ld	s1, 0x48(sp)
40002568: 6906         	ld	s2, 0x40(sp)
4000256a: 79e2         	ld	s3, 0x38(sp)
4000256c: 7a42         	ld	s4, 0x30(sp)
4000256e: 7aa2         	ld	s5, 0x28(sp)
40002570: 7b02         	ld	s6, 0x20(sp)
40002572: 6be2         	ld	s7, 0x18(sp)
40002574: 6c42         	ld	s8, 0x10(sp)
40002576: 6ca2         	ld	s9, 0x8(sp)
40002578: 6149         	addi	sp, sp, 0x90
4000257a: 8082         	ret

000000004000257c <flexio_dev_puts>:
4000257c: 4501         	li	a0, 0x0
4000257e: 4990006f     	j	0x40003216 <flexio_dev_fputs>

0000000040002582 <flexio_dev_tracer_flush>:
40002582: 1141         	addi	sp, sp, -0x10
40002584: e406         	sd	ra, 0x8(sp)
40002586: e022         	sd	s0, 0x0(sp)
40002588: 00351593     	slli	a1, a0, 0x3
4000258c: 3fffe617     	auipc	a2, 0x3fffe
40002590: bcc60613     	addi	a2, a2, -0x434
40002594: 962e         	add	a2, a2, a1
40002596: 6210         	ld	a2, 0x0(a2)
40002598: 01364603     	lbu	a2, 0x13(a2)
4000259c: 468d         	li	a3, 0x3
4000259e: 04d61063     	bne	a2, a3, 0x400025de <flexio_dev_tracer_flush+0x5c>
400025a2: 3fffe617     	auipc	a2, 0x3fffe
400025a6: 3ae60613     	addi	a2, a2, 0x3ae
400025aa: 95b2         	add	a1, a1, a2
400025ac: 6180         	ld	s0, 0x0(a1)
400025ae: 404c         	lw	a1, 0x4(s0)
400025b0: c59d         	beqz	a1, 0x400025de <flexio_dev_tracer_flush+0x5c>
400025b2: d1fff0ef     	jal	0x400022d0 <flexio_dev_tracer_notify_host>
400025b6: 00042223     	sw	zero, 0x4(s0)
400025ba: 7008         	ld	a0, 0x20(s0)
400025bc: 01041583     	lh	a1, 0x10(s0)
400025c0: 0585         	addi	a1, a1, 0x1
400025c2: 00b41823     	sh	a1, 0x10(s0)
400025c6: 01241603     	lh	a2, 0x12(s0)
400025ca: 8df1         	and	a1, a1, a2
400025cc: 0805c5bb     	zext.h	a1, a1
400025d0: 00245603     	lhu	a2, 0x2(s0)
400025d4: 00c595bb     	sllw	a1, a1, a2
400025d8: 059a         	slli	a1, a1, 0x6
400025da: 952e         	add	a0, a0, a1
400025dc: ec08         	sd	a0, 0x18(s0)
400025de: 60a2         	ld	ra, 0x8(sp)
400025e0: 6402         	ld	s0, 0x0(sp)
400025e2: 0141         	addi	sp, sp, 0x10
400025e4: 8082         	ret

00000000400025e6 <flexio_dev_bzero16.69>:
400025e6: 99f9         	andi	a1, a1, -0x2
400025e8: c599         	beqz	a1, 0x400025f6 <flexio_dev_bzero16.69+0x10>
400025ea: 95aa         	add	a1, a1, a0
400025ec: 00051023     	sh	zero, 0x0(a0)
400025f0: 0509         	addi	a0, a0, 0x2
400025f2: feb56de3     	bltu	a0, a1, 0x400025ec <flexio_dev_bzero16.69+0x6>
400025f6: 8082         	ret

00000000400025f8 <flexio_dev_bzero32.70>:
400025f8: 99f1         	andi	a1, a1, -0x4
400025fa: c599         	beqz	a1, 0x40002608 <flexio_dev_bzero32.70+0x10>
400025fc: 95aa         	add	a1, a1, a0
400025fe: 00052023     	sw	zero, 0x0(a0)
40002602: 0511         	addi	a0, a0, 0x4
40002604: feb56de3     	bltu	a0, a1, 0x400025fe <flexio_dev_bzero32.70+0x6>
40002608: 8082         	ret

000000004000260a <flexio_dev_bzero64.71>:
4000260a: 99e1         	andi	a1, a1, -0x8
4000260c: c599         	beqz	a1, 0x4000261a <flexio_dev_bzero64.71+0x10>
4000260e: 95aa         	add	a1, a1, a0
40002610: 00053023     	sd	zero, 0x0(a0)
40002614: 0521         	addi	a0, a0, 0x8
40002616: feb56de3     	bltu	a0, a1, 0x40002610 <flexio_dev_bzero64.71+0x6>
4000261a: 8082         	ret

000000004000261c <flexio_dev_memcpy128.72>:
4000261c: 8211         	srli	a2, a2, 0x4
4000261e: ce09         	beqz	a2, 0x40002638 <flexio_dev_memcpy128.72+0x1c>
40002620: 0612         	slli	a2, a2, 0x4
40002622: 962a         	add	a2, a2, a0
40002624: 6594         	ld	a3, 0x8(a1)
40002626: 6198         	ld	a4, 0x0(a1)
40002628: 05c1         	addi	a1, a1, 0x10
4000262a: 01050793     	addi	a5, a0, 0x10
4000262e: e118         	sd	a4, 0x0(a0)
40002630: e514         	sd	a3, 0x8(a0)
40002632: 853e         	mv	a0, a5
40002634: fec798e3     	bne	a5, a2, 0x40002624 <flexio_dev_memcpy128.72+0x8>
40002638: 8082         	ret

000000004000263a <flexio_dev_memcpy16.73>:
4000263a: 8205         	srli	a2, a2, 0x1
4000263c: ce09         	beqz	a2, 0x40002656 <flexio_dev_memcpy16.73+0x1c>
4000263e: 0606         	slli	a2, a2, 0x1
40002640: 962a         	add	a2, a2, a0
40002642: 00059683     	lh	a3, 0x0(a1)
40002646: 0589         	addi	a1, a1, 0x2
40002648: 00250713     	addi	a4, a0, 0x2
4000264c: 00d51023     	sh	a3, 0x0(a0)
40002650: 853a         	mv	a0, a4
40002652: fec718e3     	bne	a4, a2, 0x40002642 <flexio_dev_memcpy16.73+0x8>
40002656: 8082         	ret

0000000040002658 <flexio_dev_memcpy32.74>:
40002658: 8209         	srli	a2, a2, 0x2
4000265a: ca19         	beqz	a2, 0x40002670 <flexio_dev_memcpy32.74+0x18>
4000265c: 060a         	slli	a2, a2, 0x2
4000265e: 962a         	add	a2, a2, a0
40002660: 4194         	lw	a3, 0x0(a1)
40002662: 0591         	addi	a1, a1, 0x4
40002664: 00450713     	addi	a4, a0, 0x4
40002668: c114         	sw	a3, 0x0(a0)
4000266a: 853a         	mv	a0, a4
4000266c: fec71ae3     	bne	a4, a2, 0x40002660 <flexio_dev_memcpy32.74+0x8>
40002670: 8082         	ret

0000000040002672 <flexio_dev_memcpy64.75>:
40002672: 820d         	srli	a2, a2, 0x3
40002674: ca19         	beqz	a2, 0x4000268a <flexio_dev_memcpy64.75+0x18>
40002676: 060e         	slli	a2, a2, 0x3
40002678: 962a         	add	a2, a2, a0
4000267a: 6194         	ld	a3, 0x0(a1)
4000267c: 05a1         	addi	a1, a1, 0x8
4000267e: 00850713     	addi	a4, a0, 0x8
40002682: e114         	sd	a3, 0x0(a0)
40002684: 853a         	mv	a0, a4
40002686: fec71ae3     	bne	a4, a2, 0x4000267a <flexio_dev_memcpy64.75+0x8>
4000268a: 8082         	ret

000000004000268c <flexio_dev_bzero16.77>:
4000268c: 99f9         	andi	a1, a1, -0x2
4000268e: c599         	beqz	a1, 0x4000269c <flexio_dev_bzero16.77+0x10>
40002690: 95aa         	add	a1, a1, a0
40002692: 00051023     	sh	zero, 0x0(a0)
40002696: 0509         	addi	a0, a0, 0x2
40002698: feb56de3     	bltu	a0, a1, 0x40002692 <flexio_dev_bzero16.77+0x6>
4000269c: 8082         	ret

000000004000269e <flexio_dev_bzero32.78>:
4000269e: 99f1         	andi	a1, a1, -0x4
400026a0: c599         	beqz	a1, 0x400026ae <flexio_dev_bzero32.78+0x10>
400026a2: 95aa         	add	a1, a1, a0
400026a4: 00052023     	sw	zero, 0x0(a0)
400026a8: 0511         	addi	a0, a0, 0x4
400026aa: feb56de3     	bltu	a0, a1, 0x400026a4 <flexio_dev_bzero32.78+0x6>
400026ae: 8082         	ret

00000000400026b0 <flexio_dev_bzero64.79>:
400026b0: 99e1         	andi	a1, a1, -0x8
400026b2: c599         	beqz	a1, 0x400026c0 <flexio_dev_bzero64.79+0x10>
400026b4: 95aa         	add	a1, a1, a0
400026b6: 00053023     	sd	zero, 0x0(a0)
400026ba: 0521         	addi	a0, a0, 0x8
400026bc: feb56de3     	bltu	a0, a1, 0x400026b6 <flexio_dev_bzero64.79+0x6>
400026c0: 8082         	ret

00000000400026c2 <flexio_dev_memcpy128.80>:
400026c2: 8211         	srli	a2, a2, 0x4
400026c4: ce09         	beqz	a2, 0x400026de <flexio_dev_memcpy128.80+0x1c>
400026c6: 0612         	slli	a2, a2, 0x4
400026c8: 962a         	add	a2, a2, a0
400026ca: 6594         	ld	a3, 0x8(a1)
400026cc: 6198         	ld	a4, 0x0(a1)
400026ce: 05c1         	addi	a1, a1, 0x10
400026d0: 01050793     	addi	a5, a0, 0x10
400026d4: e118         	sd	a4, 0x0(a0)
400026d6: e514         	sd	a3, 0x8(a0)
400026d8: 853e         	mv	a0, a5
400026da: fec798e3     	bne	a5, a2, 0x400026ca <flexio_dev_memcpy128.80+0x8>
400026de: 8082         	ret

00000000400026e0 <flexio_dev_memcpy16.81>:
400026e0: 8205         	srli	a2, a2, 0x1
400026e2: ce09         	beqz	a2, 0x400026fc <flexio_dev_memcpy16.81+0x1c>
400026e4: 0606         	slli	a2, a2, 0x1
400026e6: 962a         	add	a2, a2, a0
400026e8: 00059683     	lh	a3, 0x0(a1)
400026ec: 0589         	addi	a1, a1, 0x2
400026ee: 00250713     	addi	a4, a0, 0x2
400026f2: 00d51023     	sh	a3, 0x0(a0)
400026f6: 853a         	mv	a0, a4
400026f8: fec718e3     	bne	a4, a2, 0x400026e8 <flexio_dev_memcpy16.81+0x8>
400026fc: 8082         	ret

00000000400026fe <flexio_dev_memcpy32.82>:
400026fe: 8209         	srli	a2, a2, 0x2
40002700: ca19         	beqz	a2, 0x40002716 <flexio_dev_memcpy32.82+0x18>
40002702: 060a         	slli	a2, a2, 0x2
40002704: 962a         	add	a2, a2, a0
40002706: 4194         	lw	a3, 0x0(a1)
40002708: 0591         	addi	a1, a1, 0x4
4000270a: 00450713     	addi	a4, a0, 0x4
4000270e: c114         	sw	a3, 0x0(a0)
40002710: 853a         	mv	a0, a4
40002712: fec71ae3     	bne	a4, a2, 0x40002706 <flexio_dev_memcpy32.82+0x8>
40002716: 8082         	ret

0000000040002718 <flexio_dev_memcpy64.83>:
40002718: 820d         	srli	a2, a2, 0x3
4000271a: ca19         	beqz	a2, 0x40002730 <flexio_dev_memcpy64.83+0x18>
4000271c: 060e         	slli	a2, a2, 0x3
4000271e: 962a         	add	a2, a2, a0
40002720: 6194         	ld	a3, 0x0(a1)
40002722: 05a1         	addi	a1, a1, 0x8
40002724: 00850713     	addi	a4, a0, 0x8
40002728: e114         	sd	a3, 0x0(a0)
4000272a: 853a         	mv	a0, a4
4000272c: fec71ae3     	bne	a4, a2, 0x40002720 <flexio_dev_memcpy64.83+0x8>
40002730: 8082         	ret

0000000040002732 <flexio_dev_bzero16.85>:
40002732: 99f9         	andi	a1, a1, -0x2
40002734: c599         	beqz	a1, 0x40002742 <flexio_dev_bzero16.85+0x10>
40002736: 95aa         	add	a1, a1, a0
40002738: 00051023     	sh	zero, 0x0(a0)
4000273c: 0509         	addi	a0, a0, 0x2
4000273e: feb56de3     	bltu	a0, a1, 0x40002738 <flexio_dev_bzero16.85+0x6>
40002742: 8082         	ret

0000000040002744 <flexio_dev_bzero32.86>:
40002744: 99f1         	andi	a1, a1, -0x4
40002746: c599         	beqz	a1, 0x40002754 <flexio_dev_bzero32.86+0x10>
40002748: 95aa         	add	a1, a1, a0
4000274a: 00052023     	sw	zero, 0x0(a0)
4000274e: 0511         	addi	a0, a0, 0x4
40002750: feb56de3     	bltu	a0, a1, 0x4000274a <flexio_dev_bzero32.86+0x6>
40002754: 8082         	ret

0000000040002756 <flexio_dev_bzero64.87>:
40002756: 99e1         	andi	a1, a1, -0x8
40002758: c599         	beqz	a1, 0x40002766 <flexio_dev_bzero64.87+0x10>
4000275a: 95aa         	add	a1, a1, a0
4000275c: 00053023     	sd	zero, 0x0(a0)
40002760: 0521         	addi	a0, a0, 0x8
40002762: feb56de3     	bltu	a0, a1, 0x4000275c <flexio_dev_bzero64.87+0x6>
40002766: 8082         	ret

0000000040002768 <flexio_dev_memcpy128.88>:
40002768: 8211         	srli	a2, a2, 0x4
4000276a: ce09         	beqz	a2, 0x40002784 <flexio_dev_memcpy128.88+0x1c>
4000276c: 0612         	slli	a2, a2, 0x4
4000276e: 962a         	add	a2, a2, a0
40002770: 6594         	ld	a3, 0x8(a1)
40002772: 6198         	ld	a4, 0x0(a1)
40002774: 05c1         	addi	a1, a1, 0x10
40002776: 01050793     	addi	a5, a0, 0x10
4000277a: e118         	sd	a4, 0x0(a0)
4000277c: e514         	sd	a3, 0x8(a0)
4000277e: 853e         	mv	a0, a5
40002780: fec798e3     	bne	a5, a2, 0x40002770 <flexio_dev_memcpy128.88+0x8>
40002784: 8082         	ret

0000000040002786 <flexio_dev_memcpy16.89>:
40002786: 8205         	srli	a2, a2, 0x1
40002788: ce09         	beqz	a2, 0x400027a2 <flexio_dev_memcpy16.89+0x1c>
4000278a: 0606         	slli	a2, a2, 0x1
4000278c: 962a         	add	a2, a2, a0
4000278e: 00059683     	lh	a3, 0x0(a1)
40002792: 0589         	addi	a1, a1, 0x2
40002794: 00250713     	addi	a4, a0, 0x2
40002798: 00d51023     	sh	a3, 0x0(a0)
4000279c: 853a         	mv	a0, a4
4000279e: fec718e3     	bne	a4, a2, 0x4000278e <flexio_dev_memcpy16.89+0x8>
400027a2: 8082         	ret

00000000400027a4 <flexio_dev_memcpy32.90>:
400027a4: 8209         	srli	a2, a2, 0x2
400027a6: ca19         	beqz	a2, 0x400027bc <flexio_dev_memcpy32.90+0x18>
400027a8: 060a         	slli	a2, a2, 0x2
400027aa: 962a         	add	a2, a2, a0
400027ac: 4194         	lw	a3, 0x0(a1)
400027ae: 0591         	addi	a1, a1, 0x4
400027b0: 00450713     	addi	a4, a0, 0x4
400027b4: c114         	sw	a3, 0x0(a0)
400027b6: 853a         	mv	a0, a4
400027b8: fec71ae3     	bne	a4, a2, 0x400027ac <flexio_dev_memcpy32.90+0x8>
400027bc: 8082         	ret

00000000400027be <flexio_dev_memcpy64.91>:
400027be: 820d         	srli	a2, a2, 0x3
400027c0: ca19         	beqz	a2, 0x400027d6 <flexio_dev_memcpy64.91+0x18>
400027c2: 060e         	slli	a2, a2, 0x3
400027c4: 962a         	add	a2, a2, a0
400027c6: 6194         	ld	a3, 0x0(a1)
400027c8: 05a1         	addi	a1, a1, 0x8
400027ca: 00850713     	addi	a4, a0, 0x8
400027ce: e114         	sd	a3, 0x0(a0)
400027d0: 853a         	mv	a0, a4
400027d2: fec71ae3     	bne	a4, a2, 0x400027c6 <flexio_dev_memcpy64.91+0x8>
400027d6: 8082         	ret

00000000400027d8 <flexio_dev_bzero16.103>:
400027d8: 99f9         	andi	a1, a1, -0x2
400027da: c599         	beqz	a1, 0x400027e8 <flexio_dev_bzero16.103+0x10>
400027dc: 95aa         	add	a1, a1, a0
400027de: 00051023     	sh	zero, 0x0(a0)
400027e2: 0509         	addi	a0, a0, 0x2
400027e4: feb56de3     	bltu	a0, a1, 0x400027de <flexio_dev_bzero16.103+0x6>
400027e8: 8082         	ret

00000000400027ea <flexio_dev_bzero32.104>:
400027ea: 99f1         	andi	a1, a1, -0x4
400027ec: c599         	beqz	a1, 0x400027fa <flexio_dev_bzero32.104+0x10>
400027ee: 95aa         	add	a1, a1, a0
400027f0: 00052023     	sw	zero, 0x0(a0)
400027f4: 0511         	addi	a0, a0, 0x4
400027f6: feb56de3     	bltu	a0, a1, 0x400027f0 <flexio_dev_bzero32.104+0x6>
400027fa: 8082         	ret

00000000400027fc <flexio_dev_bzero64.105>:
400027fc: 99e1         	andi	a1, a1, -0x8
400027fe: c599         	beqz	a1, 0x4000280c <flexio_dev_bzero64.105+0x10>
40002800: 95aa         	add	a1, a1, a0
40002802: 00053023     	sd	zero, 0x0(a0)
40002806: 0521         	addi	a0, a0, 0x8
40002808: feb56de3     	bltu	a0, a1, 0x40002802 <flexio_dev_bzero64.105+0x6>
4000280c: 8082         	ret

000000004000280e <flexio_dev_memcpy128.106>:
4000280e: 8211         	srli	a2, a2, 0x4
40002810: ce09         	beqz	a2, 0x4000282a <flexio_dev_memcpy128.106+0x1c>
40002812: 0612         	slli	a2, a2, 0x4
40002814: 962a         	add	a2, a2, a0
40002816: 6594         	ld	a3, 0x8(a1)
40002818: 6198         	ld	a4, 0x0(a1)
4000281a: 05c1         	addi	a1, a1, 0x10
4000281c: 01050793     	addi	a5, a0, 0x10
40002820: e118         	sd	a4, 0x0(a0)
40002822: e514         	sd	a3, 0x8(a0)
40002824: 853e         	mv	a0, a5
40002826: fec798e3     	bne	a5, a2, 0x40002816 <flexio_dev_memcpy128.106+0x8>
4000282a: 8082         	ret

000000004000282c <flexio_dev_memcpy16.107>:
4000282c: 8205         	srli	a2, a2, 0x1
4000282e: ce09         	beqz	a2, 0x40002848 <flexio_dev_memcpy16.107+0x1c>
40002830: 0606         	slli	a2, a2, 0x1
40002832: 962a         	add	a2, a2, a0
40002834: 00059683     	lh	a3, 0x0(a1)
40002838: 0589         	addi	a1, a1, 0x2
4000283a: 00250713     	addi	a4, a0, 0x2
4000283e: 00d51023     	sh	a3, 0x0(a0)
40002842: 853a         	mv	a0, a4
40002844: fec718e3     	bne	a4, a2, 0x40002834 <flexio_dev_memcpy16.107+0x8>
40002848: 8082         	ret

000000004000284a <flexio_dev_memcpy32.108>:
4000284a: 8209         	srli	a2, a2, 0x2
4000284c: ca19         	beqz	a2, 0x40002862 <flexio_dev_memcpy32.108+0x18>
4000284e: 060a         	slli	a2, a2, 0x2
40002850: 962a         	add	a2, a2, a0
40002852: 4194         	lw	a3, 0x0(a1)
40002854: 0591         	addi	a1, a1, 0x4
40002856: 00450713     	addi	a4, a0, 0x4
4000285a: c114         	sw	a3, 0x0(a0)
4000285c: 853a         	mv	a0, a4
4000285e: fec71ae3     	bne	a4, a2, 0x40002852 <flexio_dev_memcpy32.108+0x8>
40002862: 8082         	ret

0000000040002864 <flexio_dev_memcpy64.109>:
40002864: 820d         	srli	a2, a2, 0x3
40002866: ca19         	beqz	a2, 0x4000287c <flexio_dev_memcpy64.109+0x18>
40002868: 060e         	slli	a2, a2, 0x3
4000286a: 962a         	add	a2, a2, a0
4000286c: 6194         	ld	a3, 0x0(a1)
4000286e: 05a1         	addi	a1, a1, 0x8
40002870: 00850713     	addi	a4, a0, 0x8
40002874: e114         	sd	a3, 0x0(a0)
40002876: 853a         	mv	a0, a4
40002878: fec71ae3     	bne	a4, a2, 0x4000286c <flexio_dev_memcpy64.109+0x8>
4000287c: 8082         	ret

000000004000287e <_dpacc_flexio_dev_arg_unpack_add>:
4000287e: 6110         	ld	a2, 0x0(a0)
40002880: 6514         	ld	a3, 0x8(a0)
40002882: 87ae         	mv	a5, a1
40002884: 8532         	mv	a0, a2
40002886: 85b6         	mv	a1, a3
40002888: 8782         	jr	a5

000000004000288a <_dpacc_flexio_dev_arg_unpack_busy_us>:
4000288a: 6108         	ld	a0, 0x0(a0)
4000288c: 8582         	jr	a1

000000004000288e <_dpacc_flexio_dev_arg_unpack_read_u64>:
4000288e: 6108         	ld	a0, 0x0(a0)
40002890: 8582         	jr	a1

0000000040002892 <_dpacc_flexio_dev_arg_unpack_spin>:
40002892: 6110         	ld	a2, 0x0(a0)
40002894: 6514         	ld	a3, 0x8(a0)
40002896: 87ae         	mv	a5, a1
40002898: 8532         	mv	a0, a2
4000289a: 85b6         	mv	a1, a3
4000289c: 8782         	jr	a5

000000004000289e <flexio_hw_rpc>:
4000289e: 7179         	addi	sp, sp, -0x30
400028a0: f406         	sd	ra, 0x28(sp)
400028a2: f022         	sd	s0, 0x20(sp)
400028a4: ec26         	sd	s1, 0x18(sp)
400028a6: e84a         	sd	s2, 0x10(sp)
400028a8: e44e         	sd	s3, 0x8(sp)
400028aa: 842a         	mv	s0, a0
400028ac: 01053983     	ld	s3, 0x10(a0)
400028b0: 02023503     	ld	a0, 0x20(tp)
400028b4: 6128         	ld	a0, 0x40(a0)
400028b6: 0521         	addi	a0, a0, 0x8
400028b8: f48fd0ef     	jal	0x40000000 <text_start>
400028bc: 4905         	li	s2, 0x1
400028be: 4485         	li	s1, 0x1
400028c0: e511         	bnez	a0, 0x400028cc <flexio_hw_rpc+0x2e>
400028c2: 02840513     	addi	a0, s0, 0x28
400028c6: 700c         	ld	a1, 0x20(s0)
400028c8: 9982         	jalr	s3
400028ca: 84aa         	mv	s1, a0
400028cc: 00445583     	lhu	a1, 0x4(s0)
400028d0: 4010         	lw	a2, 0x0(s0)
400028d2: 4501         	li	a0, 0x0
400028d4: e6eff0ef     	jal	0x40001f42 <flexio_dev_multi_window_config>
400028d8: 6408         	ld	a0, 0x8(s0)
400028da: 050e         	slli	a0, a0, 0x3
400028dc: 810d         	srli	a0, a0, 0x3
400028de: 2bf51593     	bseti	a1, a0, 0x3f
400028e2: 5645         	li	a2, -0xf
400028e4: 8205         	srli	a2, a2, 0x1
400028e6: 8d11         	sub	a0, a0, a2
400028e8: e104         	sd	s1, 0x0(a0)
400028ea: 0125b023     	sd	s2, 0x0(a1)
400028ee: 8cbff0ef     	jal	0x400021b8 <flexio_dev_thread_reschedule>

00000000400028f2 <flexio_hw_async_rpc_worker>:
400028f2: 7139         	addi	sp, sp, -0x40
400028f4: fc06         	sd	ra, 0x38(sp)
400028f6: f822         	sd	s0, 0x30(sp)
400028f8: f426         	sd	s1, 0x28(sp)
400028fa: f04a         	sd	s2, 0x20(sp)
400028fc: ec4e         	sd	s3, 0x18(sp)
400028fe: e852         	sd	s4, 0x10(sp)
40002900: e456         	sd	s5, 0x8(sp)
40002902: 750c         	ld	a1, 0x28(a0)
40002904: 03f5c603     	lbu	a2, 0x3f(a1)
40002908: 8a05         	andi	a2, a2, 0x1
4000290a: 4154         	lw	a3, 0x4(a0)
4000290c: 00c69463     	bne	a3, a2, 0x40002914 <flexio_hw_async_rpc_worker+0x22>
40002910: 8bdff0ef     	jal	0x400021cc <flexio_dev_thread_retrigger>
40002914: 03f5c603     	lbu	a2, 0x3f(a1)
40002918: 0f067613     	andi	a2, a2, 0xf0
4000291c: 02000693     	li	a3, 0x20
40002920: 0cd61a63     	bne	a2, a3, 0x400029f4 <flexio_hw_async_rpc_worker+0x102>
40002924: 02023603     	ld	a2, 0x20(tp)
40002928: 04063a03     	ld	s4, 0x40(a2)
4000292c: 7150         	ld	a2, 0xa0(a0)
4000292e: 03c59583     	lh	a1, 0x3c(a1)
40002932: 8191         	srli	a1, a1, 0x4
40002934: 0305f593     	andi	a1, a1, 0x30
40002938: 95b2         	add	a1, a1, a2
4000293a: 658c         	ld	a1, 0x8(a1)
4000293c: 6b85d993     	rev8	s3, a1
40002940: 0110000f     	fence	w, w
40002944: 892a         	mv	s2, a0
40002946: 6948         	ld	a0, 0x90(a0)
40002948: 410c         	lw	a1, 0x0(a0)
4000294a: 6985d59b     	greviw	a1, a1, 0x18
4000294e: 0585         	addi	a1, a1, 0x1
40002950: 0805c5bb     	zext.h	a1, a1
40002954: 6985d59b     	greviw	a1, a1, 0x18
40002958: c10c         	sw	a1, 0x0(a0)
4000295a: 0009a503     	lw	a0, 0x0(s3)
4000295e: e179         	bnez	a0, 0x40002a24 <flexio_hw_async_rpc_worker+0x132>
40002960: 854a         	mv	a0, s2
40002962: 01492583     	lw	a1, 0x14(s2)
40002966: 07093603     	ld	a2, 0x70(s2)
4000296a: 08093683     	ld	a3, 0x80(s2)
4000296e: 00094703     	lbu	a4, 0x0(s2)
40002972: 00194783     	lbu	a5, 0x1(s2)
40002976: 00294483     	lbu	s1, 0x2(s2)
4000297a: 00394403     	lbu	s0, 0x3(s2)
4000297e: 00e68023     	sb	a4, 0x0(a3)
40002982: 00f680a3     	sb	a5, 0x1(a3)
40002986: 00968123     	sb	s1, 0x2(a3)
4000298a: 008681a3     	sb	s0, 0x3(a3)
4000298e: 00892683     	lw	a3, 0x8(s2)
40002992: 05092703     	lw	a4, 0x50(s2)
40002996: 16c2         	slli	a3, a3, 0x30
40002998: 92a1         	srli	a3, a3, 0x28
4000299a: 26a9         	addiw	a3, a3, 0xa
4000299c: 6986d69b     	greviw	a3, a3, 0x18
400029a0: c214         	sw	a3, 0x0(a2)
400029a2: 0722         	slli	a4, a4, 0x8
400029a4: 2709         	addiw	a4, a4, 0x2
400029a6: 6987569b     	greviw	a3, a4, 0x18
400029aa: c254         	sw	a3, 0x4(a2)
400029ac: 00063423     	sd	zero, 0x8(a2)
400029b0: 08093683     	ld	a3, 0x80(s2)
400029b4: 04000737     	lui	a4, 0x4000
400029b8: ca18         	sw	a4, 0x10(a2)
400029ba: 6985d59b     	greviw	a1, a1, 0x18
400029be: ca4c         	sw	a1, 0x14(a2)
400029c0: 6b86d593     	rev8	a1, a3
400029c4: ee0c         	sd	a1, 0x18(a2)
400029c6: 00892583     	lw	a1, 0x8(s2)
400029ca: 0585         	addi	a1, a1, 0x1
400029cc: 00b92423     	sw	a1, 0x8(s2)
400029d0: 0110000f     	fence	w, w
400029d4: 05096603     	lwu	a2, 0x50(s2)
400029d8: 2a101693     	bseti	a3, zero, 0x21
400029dc: 6298         	ld	a4, 0x0(a3)
400029de: 8b05         	andi	a4, a4, 0x1
400029e0: ff75         	bnez	a4, 0x400029dc <flexio_hw_async_rpc_worker+0xea>
400029e2: 0805c5bb     	zext.h	a1, a1
400029e6: 08c5c5b3     	pack	a1, a1, a2
400029ea: 1c000613     	li	a2, 0x1c0
400029ee: 2a161613     	bseti	a2, a2, 0x21
400029f2: e20c         	sd	a1, 0x0(a2)
400029f4: 490c         	lw	a1, 0x10(a0)
400029f6: 0585         	addi	a1, a1, 0x1
400029f8: c90c         	sw	a1, 0x10(a0)
400029fa: 4150         	lw	a2, 0x4(a0)
400029fc: 00163613     	seqz	a2, a2
40002a00: c150         	sw	a2, 0x4(a0)
40002a02: 0110000f     	fence	w, w
40002a06: 7110         	ld	a2, 0x20(a0)
40002a08: 15a2         	slli	a1, a1, 0x28
40002a0a: 91a1         	srli	a1, a1, 0x28
40002a0c: 6985d59b     	greviw	a1, a1, 0x18
40002a10: c20c         	sw	a1, 0x0(a2)
40002a12: 0110000f     	fence	w, w
40002a16: 4910         	lw	a2, 0x10(a0)
40002a18: 4d0c         	lw	a1, 0x18(a0)
40002a1a: 8532         	mv	a0, a2
40002a1c: 1cf010ef     	jal	0x400043ea <flexio_hal_outbox_write_cq_db>
40002a20: f98ff0ef     	jal	0x400021b8 <flexio_dev_thread_reschedule>
40002a24: 4481         	li	s1, 0x0
40002a26: 0a21         	addi	s4, s4, 0x8
40002a28: 01098413     	addi	s0, s3, 0x10
40002a2c: a039         	j	0x40002a3a <flexio_hw_async_rpc_worker+0x148>
40002a2e: 0485         	addi	s1, s1, 0x1
40002a30: 0009e503     	lwu	a0, 0x0(s3)
40002a34: 0441         	addi	s0, s0, 0x10
40002a36: f2a4f5e3     	bgeu	s1, a0, 0x40002960 <flexio_hw_async_rpc_worker+0x6e>
40002a3a: 00043a83     	ld	s5, 0x0(s0)
40002a3e: 8552         	mv	a0, s4
40002a40: dc0fd0ef     	jal	0x40000000 <text_start>
40002a44: f56d         	bnez	a0, 0x40002a2e <flexio_hw_async_rpc_worker+0x13c>
40002a46: ff843503     	ld	a0, -0x8(s0)
40002a4a: 9a82         	jalr	s5
40002a4c: b7cd         	j	0x40002a2e <flexio_hw_async_rpc_worker+0x13c>

0000000040002a4e <flexio_hw_async_rpc_dispatcher>:
40002a4e: 7159         	addi	sp, sp, -0x70
40002a50: f486         	sd	ra, 0x68(sp)
40002a52: f0a2         	sd	s0, 0x60(sp)
40002a54: eca6         	sd	s1, 0x58(sp)
40002a56: e8ca         	sd	s2, 0x50(sp)
40002a58: e4ce         	sd	s3, 0x48(sp)
40002a5a: e0d2         	sd	s4, 0x40(sp)
40002a5c: fc56         	sd	s5, 0x38(sp)
40002a5e: f85a         	sd	s6, 0x30(sp)
40002a60: f45e         	sd	s7, 0x28(sp)
40002a62: f062         	sd	s8, 0x20(sp)
40002a64: ec66         	sd	s9, 0x18(sp)
40002a66: e86a         	sd	s10, 0x10(sp)
40002a68: e46e         	sd	s11, 0x8(sp)
40002a6a: 842a         	mv	s0, a0
40002a6c: 04053903     	ld	s2, 0x40(a0)
40002a70: 03053983     	ld	s3, 0x30(a0)
40002a74: 4548         	lw	a0, 0xc(a0)
40002a76: 3fffd597     	auipc	a1, 0x3fffd
40002a7a: 5ca58b13     	addi	s6, a1, 0x5ca
40002a7e: e911         	bnez	a0, 0x40002a92 <flexio_hw_async_rpc_dispatcher+0x44>
40002a80: 4505         	li	a0, 0x1
40002a82: 00ab00a3     	sb	a0, 0x1(s6)
40002a86: 440c         	lw	a1, 0x8(s0)
40002a88: 00ab0023     	sb	a0, 0x0(s6)
40002a8c: e599         	bnez	a1, 0x40002a9a <flexio_hw_async_rpc_dispatcher+0x4c>
40002a8e: 4781         	li	a5, 0x0
40002a90: a815         	j	0x40002ac4 <flexio_hw_async_rpc_dispatcher+0x76>
40002a92: 4c4c         	lw	a1, 0x1c(s0)
40002a94: 000b4503     	lbu	a0, 0x0(s6)
40002a98: a82d         	j	0x40002ad2 <flexio_hw_async_rpc_dispatcher+0x84>
40002a9a: 4581         	li	a1, 0x0
40002a9c: 4601         	li	a2, 0x0
40002a9e: 01090693     	addi	a3, s2, 0x10
40002aa2: 874e         	mv	a4, s3
40002aa4: c30c         	sw	a1, 0x0(a4)
40002aa6: fea6aa23     	sw	a0, -0xc(a3)
40002aaa: fe06bc23     	sd	zero, -0x8(a3)
40002aae: 0006a023     	sw	zero, 0x0(a3)
40002ab2: 0605         	addi	a2, a2, 0x1
40002ab4: 00846783     	lwu	a5, 0x8(s0)
40002ab8: 0c068693     	addi	a3, a3, 0xc0
40002abc: 0585         	addi	a1, a1, 0x1
40002abe: 0711         	addi	a4, a4, 0x4
40002ac0: fef662e3     	bltu	a2, a5, 0x40002aa4 <flexio_hw_async_rpc_dispatcher+0x56>
40002ac4: 4581         	li	a1, 0x0
40002ac6: c05c         	sw	a5, 0x4(s0)
40002ac8: 00042e23     	sw	zero, 0x1c(s0)
40002acc: 02042023     	sw	zero, 0x20(s0)
40002ad0: c448         	sw	a0, 0xc(s0)
40002ad2: 00046a83     	lwu	s5, 0x0(s0)
40002ad6: 6478         	ld	a4, 0xc8(s0)
40002ad8: 0155f5b3     	and	a1, a1, s5
40002adc: 059a         	slli	a1, a1, 0x6
40002ade: 972e         	add	a4, a4, a1
40002ae0: 03f74583     	lbu	a1, 0x3f(a4)
40002ae4: 8985         	andi	a1, a1, 0x1
40002ae6: 1aa59d63     	bne	a1, a0, 0x40002ca0 <flexio_hw_async_rpc_dispatcher+0x252>
40002aea: 0110000f     	fence	w, w
40002aee: 01c46503     	lwu	a0, 0x1c(s0)
40002af2: 0b846583     	lwu	a1, 0xb8(s0)
40002af6: 2a101d13     	bseti	s10, zero, 0x21
40002afa: 000d3603     	ld	a2, 0x0(s10)
40002afe: 8a05         	andi	a2, a2, 0x1
40002b00: fe6d         	bnez	a2, 0x40002afa <flexio_hw_async_rpc_dispatcher+0xac>
40002b02: 08a5c533     	pack	a0, a1, a0
40002b06: 10000593     	li	a1, 0x100
40002b0a: 2a159593     	bseti	a1, a1, 0x21
40002b0e: 4050         	lw	a2, 0x4(s0)
40002b10: e188         	sd	a0, 0x0(a1)
40002b12: 36060b63     	beqz	a2, 0x40002e88 <flexio_hw_async_rpc_dispatcher+0x43a>
40002b16: 03843a03     	ld	s4, 0x38(s0)
40002b1a: 000a2023     	sw	zero, 0x0(s4)
40002b1e: 6c28         	ld	a0, 0x58(s0)
40002b20: 02046583     	lwu	a1, 0x20(s0)
40002b24: 0155f5b3     	and	a1, a1, s5
40002b28: 059a         	slli	a1, a1, 0x6
40002b2a: 952e         	add	a0, a0, a1
40002b2c: 03f54583     	lbu	a1, 0x3f(a0)
40002b30: 8985         	andi	a1, a1, 0x1
40002b32: 001b4603     	lbu	a2, 0x1(s6)
40002b36: 2ec58363     	beq	a1, a2, 0x40002e1c <flexio_hw_async_rpc_dispatcher+0x3ce>
40002b3a: 03f50613     	addi	a2, a0, 0x3f
40002b3e: 01000bb7     	lui	s7, 0x1000
40002b42: 1bfd         	addi	s7, s7, -0x1
40002b44: 02000713     	li	a4, 0x20
40002b48: 1c000593     	li	a1, 0x1c0
40002b4c: 2a159593     	bseti	a1, a1, 0x21
40002b50: e02e         	sd	a1, 0x0(sp)
40002b52: a82d         	j	0x40002b8c <flexio_hw_async_rpc_dispatcher+0x13e>
40002b54: 5010         	lw	a2, 0x20(s0)
40002b56: 2605         	addiw	a2, a2, 0x1
40002b58: d010         	sw	a2, 0x20(s0)
40002b5a: 01567533     	and	a0, a2, s5
40002b5e: 001b4583     	lbu	a1, 0x1(s6)
40002b62: 12050a63     	beqz	a0, 0x40002c96 <flexio_hw_async_rpc_dispatcher+0x248>
40002b66: 6c34         	ld	a3, 0x58(s0)
40002b68: 051a         	slli	a0, a0, 0x6
40002b6a: 9536         	add	a0, a0, a3
40002b6c: 0110000f     	fence	w, w
40002b70: 6834         	ld	a3, 0x50(s0)
40002b72: 01767633     	and	a2, a2, s7
40002b76: 6986561b     	greviw	a2, a2, 0x18
40002b7a: c290         	sw	a2, 0x0(a3)
40002b7c: 03f54603     	lbu	a2, 0x3f(a0)
40002b80: 00167693     	andi	a3, a2, 0x1
40002b84: 03f50613     	addi	a2, a0, 0x3f
40002b88: 1eb68863     	beq	a3, a1, 0x40002d78 <flexio_hw_async_rpc_dispatcher+0x32a>
40002b8c: 404c         	lw	a1, 0x4(s0)
40002b8e: 1e058563     	beqz	a1, 0x40002d78 <flexio_hw_async_rpc_dispatcher+0x32a>
40002b92: 0220000f     	fence	r, r
40002b96: 00064583     	lbu	a1, 0x0(a2)
40002b9a: 0f05f593     	andi	a1, a1, 0xf0
40002b9e: fae59be3     	bne	a1, a4, 0x40002b54 <flexio_hw_async_rpc_dispatcher+0x106>
40002ba2: 6c4c         	ld	a1, 0x98(s0)
40002ba4: 03c51503     	lh	a0, 0x3c(a0)
40002ba8: 6885551b     	greviw	a0, a0, 0x8
40002bac: 01557533     	and	a0, a0, s5
40002bb0: 1542         	slli	a0, a0, 0x30
40002bb2: 9131         	srli	a0, a0, 0x2c
40002bb4: 952e         	add	a0, a0, a1
40002bb6: 6508         	ld	a0, 0x8(a0)
40002bb8: 6b855513     	rev8	a0, a0
40002bbc: 0110000f     	fence	w, w
40002bc0: 644c         	ld	a1, 0x88(s0)
40002bc2: 4190         	lw	a2, 0x0(a1)
40002bc4: 6986561b     	greviw	a2, a2, 0x18
40002bc8: 0605         	addi	a2, a2, 0x1
40002bca: 0806463b     	zext.h	a2, a2
40002bce: 6986561b     	greviw	a2, a2, 0x18
40002bd2: c190         	sw	a2, 0x0(a1)
40002bd4: 000a6583     	lwu	a1, 0x0(s4)
40002bd8: 00459613     	slli	a2, a1, 0x4
40002bdc: 9652         	add	a2, a2, s4
40002bde: 6114         	ld	a3, 0x0(a0)
40002be0: 6508         	ld	a0, 0x8(a0)
40002be2: e614         	sd	a3, 0x8(a2)
40002be4: ea08         	sd	a0, 0x10(a2)
40002be6: 2585         	addiw	a1, a1, 0x1
40002be8: 00ba2023     	sw	a1, 0x0(s4)
40002bec: 5048         	lw	a0, 0x24(s0)
40002bee: f6a593e3     	bne	a1, a0, 0x40002b54 <flexio_hw_async_rpc_dispatcher+0x106>
40002bf2: 4048         	lw	a0, 0x4(s0)
40002bf4: 157d         	addi	a0, a0, -0x1
40002bf6: c048         	sw	a0, 0x4(s0)
40002bf8: 1502         	slli	a0, a0, 0x20
40002bfa: 8179         	srli	a0, a0, 0x1e
40002bfc: 954e         	add	a0, a0, s3
40002bfe: 00056503     	lwu	a0, 0x0(a0)
40002c02: 00651593     	slli	a1, a0, 0x6
40002c06: 0522         	slli	a0, a0, 0x8
40002c08: 8d0d         	sub	a0, a0, a1
40002c0a: 00a904b3     	add	s1, s2, a0
40002c0e: 0144ad83     	lw	s11, 0x14(s1)
40002c12: 000a2503     	lw	a0, 0x0(s4)
40002c16: 0512         	slli	a0, a0, 0x4
40002c18: 00850c9b     	addiw	s9, a0, 0x8
40002c1c: 0a84bc03     	ld	s8, 0xa8(s1)
40002c20: 7cc8         	ld	a0, 0xb8(s1)
40002c22: 080cc633     	zext.w	a2, s9
40002c26: 85d2         	mv	a1, s4
40002c28: c50fd0ef     	jal	0x40000078 <memcpy>
40002c2c: 44c8         	lw	a0, 0xc(s1)
40002c2e: 0884a583     	lw	a1, 0x88(s1)
40002c32: 1542         	slli	a0, a0, 0x30
40002c34: 9121         	srli	a0, a0, 0x28
40002c36: 2529         	addiw	a0, a0, 0xa
40002c38: 6985551b     	greviw	a0, a0, 0x18
40002c3c: 00ac2023     	sw	a0, 0x0(s8)
40002c40: 05a2         	slli	a1, a1, 0x8
40002c42: 2589         	addiw	a1, a1, 0x2
40002c44: 6985d51b     	greviw	a0, a1, 0x18
40002c48: 00ac2223     	sw	a0, 0x4(s8)
40002c4c: 000c3423     	sd	zero, 0x8(s8)
40002c50: 7cc8         	ld	a0, 0xb8(s1)
40002c52: 698cd59b     	greviw	a1, s9, 0x18
40002c56: 00bc2823     	sw	a1, 0x10(s8)
40002c5a: 698dd59b     	greviw	a1, s11, 0x18
40002c5e: 00bc2a23     	sw	a1, 0x14(s8)
40002c62: 6b855513     	rev8	a0, a0
40002c66: 00ac3c23     	sd	a0, 0x18(s8)
40002c6a: 44c8         	lw	a0, 0xc(s1)
40002c6c: 0505         	addi	a0, a0, 0x1
40002c6e: c4c8         	sw	a0, 0xc(s1)
40002c70: 0110000f     	fence	w, w
40002c74: 0884e583     	lwu	a1, 0x88(s1)
40002c78: 000d3603     	ld	a2, 0x0(s10)
40002c7c: 8a05         	andi	a2, a2, 0x1
40002c7e: fe6d         	bnez	a2, 0x40002c78 <flexio_hw_async_rpc_dispatcher+0x22a>
40002c80: 0805453b     	zext.h	a0, a0
40002c84: 08b54533     	pack	a0, a0, a1
40002c88: 6582         	ld	a1, 0x0(sp)
40002c8a: e188         	sd	a0, 0x0(a1)
40002c8c: 000a2023     	sw	zero, 0x0(s4)
40002c90: 02000713     	li	a4, 0x20
40002c94: b5c1         	j	0x40002b54 <flexio_hw_async_rpc_dispatcher+0x106>
40002c96: 0015b593     	seqz	a1, a1
40002c9a: 00bb00a3     	sb	a1, 0x1(s6)
40002c9e: b5e1         	j	0x40002b66 <flexio_hw_async_rpc_dispatcher+0x118>
40002ca0: 01000537     	lui	a0, 0x1000
40002ca4: 157d         	addi	a0, a0, -0x1
40002ca6: 05090813     	addi	a6, s2, 0x50
40002caa: 02000893     	li	a7, 0x20
40002cae: a839         	j	0x40002ccc <flexio_hw_async_rpc_dispatcher+0x27e>
40002cb0: 059a         	slli	a1, a1, 0x6
40002cb2: 972e         	add	a4, a4, a1
40002cb4: 0110000f     	fence	w, w
40002cb8: 606c         	ld	a1, 0xc0(s0)
40002cba: 8ce9         	and	s1, s1, a0
40002cbc: 6984d61b     	greviw	a2, s1, 0x18
40002cc0: c190         	sw	a2, 0x0(a1)
40002cc2: 03f74583     	lbu	a1, 0x3f(a4)
40002cc6: 8985         	andi	a1, a1, 0x1
40002cc8: e2f581e3     	beq	a1, a5, 0x40002aea <flexio_hw_async_rpc_dispatcher+0x9c>
40002ccc: 0220000f     	fence	r, r
40002cd0: 03f74583     	lbu	a1, 0x3f(a4)
40002cd4: 0f05f593     	andi	a1, a1, 0xf0
40002cd8: 05159463     	bne	a1, a7, 0x40002d20 <flexio_hw_async_rpc_dispatcher+0x2d2>
40002cdc: 0bc42583     	lw	a1, 0xbc(s0)
40002ce0: cdb1         	beqz	a1, 0x40002d3c <flexio_hw_async_rpc_dispatcher+0x2ee>
40002ce2: 530c         	lw	a1, 0x20(a4)
40002ce4: f005f593     	andi	a1, a1, -0x100
40002ce8: 6985d59b     	greviw	a1, a1, 0x18
40002cec: 00446683     	lwu	a3, 0x4(s0)
40002cf0: 068a         	slli	a3, a3, 0x2
40002cf2: 96ce         	add	a3, a3, s3
40002cf4: c28c         	sw	a1, 0x0(a3)
40002cf6: 4054         	lw	a3, 0x4(s0)
40002cf8: 0685         	addi	a3, a3, 0x1
40002cfa: c054         	sw	a3, 0x4(s0)
40002cfc: 1582         	slli	a1, a1, 0x20
40002cfe: 01a5d693     	srli	a3, a1, 0x1a
40002d02: 81e1         	srli	a1, a1, 0x18
40002d04: 8d95         	sub	a1, a1, a3
40002d06: 95ca         	add	a1, a1, s2
40002d08: 6db4         	ld	a3, 0x58(a1)
40002d0a: 0110000f     	fence	w, w
40002d0e: 428c         	lw	a1, 0x0(a3)
40002d10: 6985d59b     	greviw	a1, a1, 0x18
40002d14: 0585         	addi	a1, a1, 0x1
40002d16: 0805c5bb     	zext.h	a1, a1
40002d1a: 6985d59b     	greviw	a1, a1, 0x18
40002d1e: c28c         	sw	a1, 0x0(a3)
40002d20: 4c44         	lw	s1, 0x1c(s0)
40002d22: 2485         	addiw	s1, s1, 0x1
40002d24: cc44         	sw	s1, 0x1c(s0)
40002d26: 6478         	ld	a4, 0xc8(s0)
40002d28: 0154f5b3     	and	a1, s1, s5
40002d2c: 000b4783     	lbu	a5, 0x0(s6)
40002d30: f1c1         	bnez	a1, 0x40002cb0 <flexio_hw_async_rpc_dispatcher+0x262>
40002d32: 0017b793     	seqz	a5, a5
40002d36: 00fb0023     	sb	a5, 0x0(s6)
40002d3a: bf9d         	j	0x40002cb0 <flexio_hw_async_rpc_dispatcher+0x262>
40002d3c: 00846483     	lwu	s1, 0x8(s0)
40002d40: d4e9         	beqz	s1, 0x40002d0a <flexio_hw_async_rpc_dispatcher+0x2bc>
40002d42: 4781         	li	a5, 0x0
40002d44: 5f0c         	lw	a1, 0x38(a4)
40002d46: f005f593     	andi	a1, a1, -0x100
40002d4a: 6985d593     	rev8.w	a1, a1
40002d4e: 2581         	sext.w	a1, a1
40002d50: 8742         	mv	a4, a6
40002d52: 4310         	lw	a2, 0x0(a4)
40002d54: 00c58863     	beq	a1, a2, 0x40002d64 <flexio_hw_async_rpc_dispatcher+0x316>
40002d58: 0785         	addi	a5, a5, 0x1
40002d5a: 0c070713     	addi	a4, a4, 0xc0
40002d5e: fef49ae3     	bne	s1, a5, 0x40002d52 <flexio_hw_async_rpc_dispatcher+0x304>
40002d62: b765         	j	0x40002d0a <flexio_hw_async_rpc_dispatcher+0x2bc>
40002d64: 00446583     	lwu	a1, 0x4(s0)
40002d68: 058a         	slli	a1, a1, 0x2
40002d6a: 95ce         	add	a1, a1, s3
40002d6c: c19c         	sw	a5, 0x0(a1)
40002d6e: 404c         	lw	a1, 0x4(s0)
40002d70: 0585         	addi	a1, a1, 0x1
40002d72: c04c         	sw	a1, 0x4(s0)
40002d74: 6714         	ld	a3, 0x8(a4)
40002d76: bf51         	j	0x40002d0a <flexio_hw_async_rpc_dispatcher+0x2bc>
40002d78: 000a2503     	lw	a0, 0x0(s4)
40002d7c: c145         	beqz	a0, 0x40002e1c <flexio_hw_async_rpc_dispatcher+0x3ce>
40002d7e: 4048         	lw	a0, 0x4(s0)
40002d80: 157d         	addi	a0, a0, -0x1
40002d82: c048         	sw	a0, 0x4(s0)
40002d84: 1502         	slli	a0, a0, 0x20
40002d86: 8179         	srli	a0, a0, 0x1e
40002d88: 954e         	add	a0, a0, s3
40002d8a: 00056503     	lwu	a0, 0x0(a0)
40002d8e: 00651593     	slli	a1, a0, 0x6
40002d92: 0522         	slli	a0, a0, 0x8
40002d94: 8d0d         	sub	a0, a0, a1
40002d96: 992a         	add	s2, s2, a0
40002d98: 01492983     	lw	s3, 0x14(s2)
40002d9c: 000a2503     	lw	a0, 0x0(s4)
40002da0: 0512         	slli	a0, a0, 0x4
40002da2: 00850a9b     	addiw	s5, a0, 0x8
40002da6: 0a893483     	ld	s1, 0xa8(s2)
40002daa: 0b893503     	ld	a0, 0xb8(s2)
40002dae: 080ac633     	zext.w	a2, s5
40002db2: 85d2         	mv	a1, s4
40002db4: ac4fd0ef     	jal	0x40000078 <memcpy>
40002db8: 00c92503     	lw	a0, 0xc(s2)
40002dbc: 08892583     	lw	a1, 0x88(s2)
40002dc0: 1542         	slli	a0, a0, 0x30
40002dc2: 9121         	srli	a0, a0, 0x28
40002dc4: 2529         	addiw	a0, a0, 0xa
40002dc6: 6985551b     	greviw	a0, a0, 0x18
40002dca: c088         	sw	a0, 0x0(s1)
40002dcc: 05a2         	slli	a1, a1, 0x8
40002dce: 2589         	addiw	a1, a1, 0x2
40002dd0: 6985d51b     	greviw	a0, a1, 0x18
40002dd4: c0c8         	sw	a0, 0x4(s1)
40002dd6: 0004b423     	sd	zero, 0x8(s1)
40002dda: 0b893503     	ld	a0, 0xb8(s2)
40002dde: 698ad59b     	greviw	a1, s5, 0x18
40002de2: c88c         	sw	a1, 0x10(s1)
40002de4: 6989d59b     	greviw	a1, s3, 0x18
40002de8: c8cc         	sw	a1, 0x14(s1)
40002dea: 6b855513     	rev8	a0, a0
40002dee: ec88         	sd	a0, 0x18(s1)
40002df0: 00c92503     	lw	a0, 0xc(s2)
40002df4: 0505         	addi	a0, a0, 0x1
40002df6: 00a92623     	sw	a0, 0xc(s2)
40002dfa: 0110000f     	fence	w, w
40002dfe: 08896583     	lwu	a1, 0x88(s2)
40002e02: 000d3603     	ld	a2, 0x0(s10)
40002e06: 8a05         	andi	a2, a2, 0x1
40002e08: fe6d         	bnez	a2, 0x40002e02 <flexio_hw_async_rpc_dispatcher+0x3b4>
40002e0a: 0805453b     	zext.h	a0, a0
40002e0e: 08b54533     	pack	a0, a0, a1
40002e12: 1c000593     	li	a1, 0x1c0
40002e16: 2a159593     	bseti	a1, a1, 0x21
40002e1a: e188         	sd	a0, 0x0(a1)
40002e1c: 0110000f     	fence	w, w
40002e20: 02046503     	lwu	a0, 0x20(s0)
40002e24: 04846583     	lwu	a1, 0x48(s0)
40002e28: 000d3603     	ld	a2, 0x0(s10)
40002e2c: 8a05         	andi	a2, a2, 0x1
40002e2e: fe6d         	bnez	a2, 0x40002e28 <flexio_hw_async_rpc_dispatcher+0x3da>
40002e30: 08a5c533     	pack	a0, a1, a0
40002e34: 10000593     	li	a1, 0x100
40002e38: 2a159593     	bseti	a1, a1, 0x21
40002e3c: 4050         	lw	a2, 0x4(s0)
40002e3e: 4414         	lw	a3, 0x8(s0)
40002e40: e188         	sd	a0, 0x0(a1)
40002e42: 04d61363     	bne	a2, a3, 0x40002e88 <flexio_hw_async_rpc_dispatcher+0x43a>
40002e46: 01045483     	lhu	s1, 0x10(s0)
40002e4a: 0440000f     	fence	o, o
40002e4e: 488d         	li	a7, 0x3
40002e50: 8526         	mv	a0, s1
40002e52: 00000073     	ecall
40002e56: c105         	beqz	a0, 0x40002e76 <flexio_hw_async_rpc_dispatcher+0x428>
40002e58: 4848         	lw	a0, 0x14(s0)
40002e5a: 02023583     	ld	a1, 0x20(tp)
40002e5e: c9c4         	sw	s1, 0x14(a1)
40002e60: 0cc0000f     	fence	io, io
40002e64: 200015b7     	lui	a1, 0x20001
40002e68: 0592         	slli	a1, a1, 0x4
40002e6a: c188         	sw	a0, 0x0(a1)
40002e6c: 0cc0000f     	fence	io, io
40002e70: 02023583     	ld	a1, 0x20(tp)
40002e74: c5c8         	sw	a0, 0xc(a1)
40002e76: 7408         	ld	a0, 0x28(s0)
40002e78: 050e         	slli	a0, a0, 0x3
40002e7a: 810d         	srli	a0, a0, 0x3
40002e7c: 2bf51513     	bseti	a0, a0, 0x3f
40002e80: 4585         	li	a1, 0x1
40002e82: c10c         	sw	a1, 0x0(a0)
40002e84: 0440000f     	fence	o, o
40002e88: b30ff0ef     	jal	0x400021b8 <flexio_dev_thread_reschedule>

0000000040002e8c <flexio_dev_event_handler_wrapper>:
40002e8c: 1141         	addi	sp, sp, -0x10
40002e8e: e406         	sd	ra, 0x8(sp)
40002e90: 02023583     	ld	a1, 0x20(tp)
40002e94: 61b0         	ld	a2, 0x40(a1)
40002e96: 00064683     	lbu	a3, 0x0(a2)
40002e9a: ee91         	bnez	a3, 0x40002eb6 <flexio_dev_event_handler_wrapper+0x2a>
40002e9c: 567d         	li	a2, -0x1
40002e9e: e590         	sd	a2, 0x8(a1)
40002ea0: c190         	sw	a2, 0x0(a1)
40002ea2: c9d0         	sw	a2, 0x14(a1)
40002ea4: cd90         	sw	a2, 0x18(a1)
40002ea6: c990         	sw	a2, 0x10(a1)
40002ea8: 6910         	ld	a2, 0x10(a0)
40002eaa: 650c         	ld	a1, 0x8(a0)
40002eac: 00053103     	ld	sp, 0x0(a0)
40002eb0: 8532         	mv	a0, a2
40002eb2: 4081         	li	ra, 0x0
40002eb4: 8582         	jr	a1
40002eb6: 00860513     	addi	a0, a2, 0x8
40002eba: 982fd0ef     	jal	0x4000003c <__dpa_os_restore>

0000000040002ebe <_dpacc_flexio_dev_arg_unpack_flexio_dev_event_handler_wrapper>:
40002ebe: 6108         	ld	a0, 0x0(a0)
40002ec0: 8582         	jr	a1

0000000040002ec2 <_dpacc_flexio_dev_arg_unpack_flexio_hw_async_rpc_dispatcher>:
40002ec2: 6108         	ld	a0, 0x0(a0)
40002ec4: 8582         	jr	a1

0000000040002ec6 <_dpacc_flexio_dev_arg_unpack_flexio_hw_async_rpc_worker>:
40002ec6: 6108         	ld	a0, 0x0(a0)
40002ec8: 8582         	jr	a1

0000000040002eca <_dpacc_flexio_dev_arg_unpack_flexio_hw_rpc>:
40002eca: 6108         	ld	a0, 0x0(a0)
40002ecc: 8582         	jr	a1

0000000040002ece <performance_analysis_area_begin>:
40002ece: 2a101513     	bseti	a0, zero, 0x21
40002ed2: 610c         	ld	a1, 0x0(a0)
40002ed4: 8985         	andi	a1, a1, 0x1
40002ed6: fdf5         	bnez	a1, 0x40002ed2 <performance_analysis_area_begin+0x4>
40002ed8: 08000537     	lui	a0, 0x8000
40002edc: 03f50513     	addi	a0, a0, 0x3f
40002ee0: 051a         	slli	a0, a0, 0x6
40002ee2: 04100593     	li	a1, 0x41
40002ee6: 15e2         	slli	a1, a1, 0x38
40002ee8: 0585         	addi	a1, a1, 0x1
40002eea: e10c         	sd	a1, 0x0(a0)
40002eec: 8082         	ret

0000000040002eee <rpc_msg_stream_cfg>:
40002eee: 7139         	addi	sp, sp, -0x40
40002ef0: fc06         	sd	ra, 0x38(sp)
40002ef2: f822         	sd	s0, 0x30(sp)
40002ef4: f426         	sd	s1, 0x28(sp)
40002ef6: f04a         	sd	s2, 0x20(sp)
40002ef8: ec4e         	sd	s3, 0x18(sp)
40002efa: e852         	sd	s4, 0x10(sp)
40002efc: e456         	sd	s5, 0x8(sp)
40002efe: e05a         	sd	s6, 0x0(sp)
40002f00: 842a         	mv	s0, a0
40002f02: 01954983     	lbu	s3, 0x19(a0)
40002f06: 00399a13     	slli	s4, s3, 0x3
40002f0a: 3fffd517     	auipc	a0, 0x3fffd
40002f0e: 24e50a93     	addi	s5, a0, 0x24e
40002f12: 9ad2         	add	s5, s5, s4
40002f14: 008ab023     	sd	s0, 0x0(s5)
40002f18: 6824         	ld	s1, 0x50(s0)
40002f1a: 03c00613     	li	a2, 0x3c
40002f1e: 8526         	mv	a0, s1
40002f20: 4581         	li	a1, 0x0
40002f22: a66fd0ef     	jal	0x40000188 <memset>
40002f26: 6428         	ld	a0, 0x48(s0)
40002f28: 01044583     	lbu	a1, 0x10(s0)
40002f2c: 28b01633     	bset	a2, zero, a1
40002f30: 0ff00593     	li	a1, 0xff
40002f34: a54fd0ef     	jal	0x40000188 <memset>
40002f38: 6828         	ld	a0, 0x50(s0)
40002f3a: 02052a23     	sw	zero, 0x34(a0)
40002f3e: 4905         	li	s2, 0x1
40002f40: 03250c23     	sb	s2, 0x38(a0)
40002f44: 0310000f     	fence	rw, w
40002f48: 0004aa23     	sw	zero, 0x14(s1)
40002f4c: 0310000f     	fence	rw, w
40002f50: 0004a423     	sw	zero, 0x8(s1)
40002f54: 0310000f     	fence	rw, w
40002f58: 0004a023     	sw	zero, 0x0(s1)
40002f5c: 0310000f     	fence	rw, w
40002f60: 0204a823     	sw	zero, 0x30(s1)
40002f64: 01844503     	lbu	a0, 0x18(s0)
40002f68: 28a01533     	bset	a0, zero, a0
40002f6c: d4c8         	sw	a0, 0x2c(s1)
40002f6e: 557d         	li	a0, -0x1
40002f70: 00a49823     	sh	a0, 0x10(s1)
40002f74: 01344503     	lbu	a0, 0x13(s0)
40002f78: 4b0d         	li	s6, 0x3
40002f7a: 0124a223     	sw	s2, 0x4(s1)
40002f7e: 07651063     	bne	a0, s6, 0x40002fde <rpc_msg_stream_cfg+0xf0>
40002f82: 7424         	ld	s1, 0x68(s0)
40002f84: 02800613     	li	a2, 0x28
40002f88: 8526         	mv	a0, s1
40002f8a: 4581         	li	a1, 0x0
40002f8c: 9fcfd0ef     	jal	0x40000188 <memset>
40002f90: 01a44503     	lbu	a0, 0x1a(s0)
40002f94: 00a48023     	sb	a0, 0x0(s1)
40002f98: 01b44503     	lbu	a0, 0x1b(s0)
40002f9c: 0004a223     	sw	zero, 0x4(s1)
40002fa0: 08ab6763     	bltu	s6, a0, 0x4000302e <rpc_msg_stream_cfg+0x140>
40002fa4: 4585         	li	a1, 0x1
40002fa6: 08b50463     	beq	a0, a1, 0x4000302e <rpc_msg_stream_cfg+0x140>
40002faa: 4901         	li	s2, 0x0
40002fac: 01244503     	lbu	a0, 0x12(s0)
40002fb0: 1569         	addi	a0, a0, -0x6
40002fb2: 00a49123     	sh	a0, 0x2(s1)
40002fb6: 28a01533     	bset	a0, zero, a0
40002fba: c488         	sw	a0, 0x8(s1)
40002fbc: 7808         	ld	a0, 0x30(s0)
40002fbe: f088         	sd	a0, 0x20(s1)
40002fc0: ec88         	sd	a0, 0x18(s1)
40002fc2: 01044503     	lbu	a0, 0x10(s0)
40002fc6: 28a01533     	bset	a0, zero, a0
40002fca: 157d         	addi	a0, a0, -0x1
40002fcc: 00a49923     	sh	a0, 0x12(s1)
40002fd0: 3fffe517     	auipc	a0, 0x3fffe
40002fd4: 98050513     	addi	a0, a0, -0x680
40002fd8: 9552         	add	a0, a0, s4
40002fda: e104         	sd	s1, 0x0(a0)
40002fdc: a889         	j	0x4000302e <rpc_msg_stream_cfg+0x140>
40002fde: 000ab503     	ld	a0, 0x0(s5)
40002fe2: c12d         	beqz	a0, 0x40003044 <rpc_msg_stream_cfg+0x156>
40002fe4: 7124         	ld	s1, 0x60(a0)
40002fe6: 05000613     	li	a2, 0x50
40002fea: 8526         	mv	a0, s1
40002fec: 4581         	li	a1, 0x0
40002fee: 99afd0ef     	jal	0x40000188 <memset>
40002ff2: 4901         	li	s2, 0x0
40002ff4: 00000517     	auipc	a0, 0x0
40002ff8: 17250513     	addi	a0, a0, 0x172
40002ffc: e488         	sd	a0, 0x8(s1)
40002ffe: 00000517     	auipc	a0, 0x0
40003002: 1c050513     	addi	a0, a0, 0x1c0
40003006: ec88         	sd	a0, 0x18(s1)
40003008: 4509         	li	a0, 0x2
4000300a: 00a48123     	sb	a0, 0x2(s1)
4000300e: 00000517     	auipc	a0, 0x0
40003012: 1dc50513     	addi	a0, a0, 0x1dc
40003016: f088         	sd	a0, 0x20(s1)
40003018: 0334a423     	sw	s3, 0x28(s1)
4000301c: 6c28         	ld	a0, 0x58(s0)
4000301e: f888         	sd	a0, 0x30(s1)
40003020: 00099763     	bnez	s3, 0x4000302e <rpc_msg_stream_cfg+0x140>
40003024: 4901         	li	s2, 0x0
40003026: 3fffe517     	auipc	a0, 0x3fffe
4000302a: 12953523     	sd	s1, 0x12a(a0)
4000302e: 854a         	mv	a0, s2
40003030: 70e2         	ld	ra, 0x38(sp)
40003032: 7442         	ld	s0, 0x30(sp)
40003034: 74a2         	ld	s1, 0x28(sp)
40003036: 7902         	ld	s2, 0x20(sp)
40003038: 69e2         	ld	s3, 0x18(sp)
4000303a: 6a42         	ld	s4, 0x10(sp)
4000303c: 6aa2         	ld	s5, 0x8(sp)
4000303e: 6b02         	ld	s6, 0x0(sp)
40003040: 6121         	addi	sp, sp, 0x40
40003042: 8082         	ret
40003044: 4481         	li	s1, 0x0
40003046: b745         	j	0x40002fe6 <rpc_msg_stream_cfg+0xf8>

0000000040003048 <rpc_msg_stream_close>:
40003048: 1141         	addi	sp, sp, -0x10
4000304a: e406         	sd	ra, 0x8(sp)
4000304c: e022         	sd	s0, 0x0(sp)
4000304e: 0005059b     	sext.w	a1, a0
40003052: 058e         	slli	a1, a1, 0x3
40003054: 3fffd617     	auipc	a2, 0x3fffd
40003058: 10460613     	addi	a2, a2, 0x104
4000305c: 95b2         	add	a1, a1, a2
4000305e: 6198         	ld	a4, 0x0(a1)
40003060: 01374783     	lbu	a5, 0x13(a4)
40003064: 468d         	li	a3, 0x3
40003066: 04d79d63     	bne	a5, a3, 0x400030c0 <rpc_msg_stream_close+0x78>
4000306a: 03851593     	slli	a1, a0, 0x38
4000306e: 91d5         	srli	a1, a1, 0x35
40003070: 962e         	add	a2, a2, a1
40003072: 6210         	ld	a2, 0x0(a2)
40003074: 01364603     	lbu	a2, 0x13(a2)
40003078: 04d61c63     	bne	a2, a3, 0x400030d0 <rpc_msg_stream_close+0x88>
4000307c: 3fffe617     	auipc	a2, 0x3fffe
40003080: 8d460613     	addi	a2, a2, -0x72c
40003084: 95b2         	add	a1, a1, a2
40003086: 6180         	ld	s0, 0x0(a1)
40003088: 404c         	lw	a1, 0x4(s0)
4000308a: c1b9         	beqz	a1, 0x400030d0 <rpc_msg_stream_close+0x88>
4000308c: 0ff57513     	zext.b	a0, a0
40003090: a40ff0ef     	jal	0x400022d0 <flexio_dev_tracer_notify_host>
40003094: 4501         	li	a0, 0x0
40003096: 00042223     	sw	zero, 0x4(s0)
4000309a: 01041583     	lh	a1, 0x10(s0)
4000309e: 0585         	addi	a1, a1, 0x1
400030a0: 00b41823     	sh	a1, 0x10(s0)
400030a4: 01241603     	lh	a2, 0x12(s0)
400030a8: 8df1         	and	a1, a1, a2
400030aa: 0805c5bb     	zext.h	a1, a1
400030ae: 00245603     	lhu	a2, 0x2(s0)
400030b2: 00c595bb     	sllw	a1, a1, a2
400030b6: 7010         	ld	a2, 0x20(s0)
400030b8: 059a         	slli	a1, a1, 0x6
400030ba: 95b2         	add	a1, a1, a2
400030bc: ec0c         	sd	a1, 0x18(s0)
400030be: a8b9         	j	0x4000311c <rpc_msg_stream_close+0xd4>
400030c0: 6b30         	ld	a2, 0x50(a4)
400030c2: 4685         	li	a3, 0x1
400030c4: 0ed6252f     	amoswap.w.aqrl	a0, a3, (a2)
400030c8: c511         	beqz	a0, 0x400030d4 <rpc_msg_stream_close+0x8c>
400030ca: 2bf69513     	bseti	a0, a3, 0x3f
400030ce: a039         	j	0x400030dc <rpc_msg_stream_close+0x94>
400030d0: 4501         	li	a0, 0x0
400030d2: a0a9         	j	0x4000311c <rpc_msg_stream_close+0xd4>
400030d4: 0310000f     	fence	rw, w
400030d8: 00062023     	sw	zero, 0x0(a2)
400030dc: 4709         	li	a4, 0x2
400030de: 01460793     	addi	a5, a2, 0x14
400030e2: 0ed7a7af     	amoswap.w.aqrl	a5, a3, (a5)
400030e6: 2bf71693     	bseti	a3, a4, 0x3f
400030ea: c399         	beqz	a5, 0x400030f0 <rpc_msg_stream_close+0xa8>
400030ec: 8d55         	or	a0, a0, a3
400030ee: a029         	j	0x400030f8 <rpc_msg_stream_close+0xb0>
400030f0: 0310000f     	fence	rw, w
400030f4: 00062a23     	sw	zero, 0x14(a2)
400030f8: 00860713     	addi	a4, a2, 0x8
400030fc: 4785         	li	a5, 0x1
400030fe: 0ef7272f     	amoswap.w.aqrl	a4, a5, (a4)
40003102: c701         	beqz	a4, 0x4000310a <rpc_msg_stream_close+0xc2>
40003104: 0689         	addi	a3, a3, 0x2
40003106: 8d55         	or	a0, a0, a3
40003108: a811         	j	0x4000311c <rpc_msg_stream_close+0xd4>
4000310a: 0310000f     	fence	rw, w
4000310e: 00062423     	sw	zero, 0x8(a2)
40003112: e509         	bnez	a0, 0x4000311c <rpc_msg_stream_close+0xd4>
40003114: 00062223     	sw	zero, 0x4(a2)
40003118: 0005b023     	sd	zero, 0x0(a1)
4000311c: 60a2         	ld	ra, 0x8(sp)
4000311e: 6402         	ld	s0, 0x0(sp)
40003120: 0141         	addi	sp, sp, 0x10
40003122: 8082         	ret

0000000040003124 <msg_stream_level_set>:
40003124: 0ff57593     	zext.b	a1, a0
40003128: 058e         	slli	a1, a1, 0x3
4000312a: 3fffd617     	auipc	a2, 0x3fffd
4000312e: 02e60613     	addi	a2, a2, 0x2e
40003132: 962e         	add	a2, a2, a1
40003134: 6214         	ld	a3, 0x0(a2)
40003136: c685         	beqz	a3, 0x4000315e <msg_stream_level_set+0x3a>
40003138: 00855613     	srli	a2, a0, 0x8
4000313c: 0136c503     	lbu	a0, 0x13(a3)
40003140: 470d         	li	a4, 0x3
40003142: 00c68d23     	sb	a2, 0x1a(a3)
40003146: 00e51e63     	bne	a0, a4, 0x40003162 <msg_stream_level_set+0x3e>
4000314a: 4501         	li	a0, 0x0
4000314c: 3fffe697     	auipc	a3, 0x3fffe
40003150: 80468693     	addi	a3, a3, -0x7fc
40003154: 95b6         	add	a1, a1, a3
40003156: 618c         	ld	a1, 0x0(a1)
40003158: 00c58023     	sb	a2, 0x0(a1)
4000315c: 8082         	ret
4000315e: 557d         	li	a0, -0x1
40003160: 8082         	ret
40003162: 4501         	li	a0, 0x0
40003164: 8082         	ret

0000000040003166 <flexio_putc>:
40003166: 7990         	ld	a2, 0x30(a1)
40003168: 5d94         	lw	a3, 0x38(a1)
4000316a: 9636         	add	a2, a2, a3
4000316c: 00a60023     	sb	a0, 0x0(a2)
40003170: 5d94         	lw	a3, 0x38(a1)
40003172: 0016861b     	addiw	a2, a3, 0x1
40003176: 1eb6a693     	slti	a3, a3, 0x1eb
4000317a: ff650713     	addi	a4, a0, -0xa
4000317e: 00e03733     	snez	a4, a4
40003182: 8ef9         	and	a3, a3, a4
40003184: dd90         	sw	a2, 0x38(a1)
40003186: ea9d         	bnez	a3, 0x400031bc <flexio_putc+0x56>
40003188: 00163693     	seqz	a3, a2
4000318c: ea85         	bnez	a3, 0x400031bc <flexio_putc+0x56>
4000318e: 1101         	addi	sp, sp, -0x20
40003190: ec06         	sd	ra, 0x18(sp)
40003192: e822         	sd	s0, 0x10(sp)
40003194: e426         	sd	s1, 0x8(sp)
40003196: 7994         	ld	a3, 0x30(a1)
40003198: 9636         	add	a2, a2, a3
4000319a: 00060023     	sb	zero, 0x0(a2)
4000319e: 5590         	lw	a2, 0x28(a1)
400031a0: 7994         	ld	a3, 0x30(a1)
400031a2: 842a         	mv	s0, a0
400031a4: 8532         	mv	a0, a2
400031a6: 84ae         	mv	s1, a1
400031a8: 85b6         	mv	a1, a3
400031aa: 06c000ef     	jal	0x40003216 <flexio_dev_fputs>
400031ae: 8522         	mv	a0, s0
400031b0: 0204ac23     	sw	zero, 0x38(s1)
400031b4: 60e2         	ld	ra, 0x18(sp)
400031b6: 6442         	ld	s0, 0x10(sp)
400031b8: 64a2         	ld	s1, 0x8(sp)
400031ba: 6105         	addi	sp, sp, 0x20
400031bc: 8082         	ret

00000000400031be <flexio_flush>:
400031be: 5d0c         	lw	a1, 0x38(a0)
400031c0: c19d         	beqz	a1, 0x400031e6 <flexio_flush+0x28>
400031c2: 1141         	addi	sp, sp, -0x10
400031c4: e406         	sd	ra, 0x8(sp)
400031c6: e022         	sd	s0, 0x0(sp)
400031c8: 7910         	ld	a2, 0x30(a0)
400031ca: 95b2         	add	a1, a1, a2
400031cc: 00058023     	sb	zero, 0x0(a1)
400031d0: 5510         	lw	a2, 0x28(a0)
400031d2: 790c         	ld	a1, 0x30(a0)
400031d4: 842a         	mv	s0, a0
400031d6: 8532         	mv	a0, a2
400031d8: 03e000ef     	jal	0x40003216 <flexio_dev_fputs>
400031dc: 02042c23     	sw	zero, 0x38(s0)
400031e0: 60a2         	ld	ra, 0x8(sp)
400031e2: 6402         	ld	s0, 0x0(sp)
400031e4: 0141         	addi	sp, sp, 0x10
400031e6: 4501         	li	a0, 0x0
400031e8: 8082         	ret

00000000400031ea <flexio_close>:
400031ea: 5d0c         	lw	a1, 0x38(a0)
400031ec: c19d         	beqz	a1, 0x40003212 <flexio_close+0x28>
400031ee: 1141         	addi	sp, sp, -0x10
400031f0: e406         	sd	ra, 0x8(sp)
400031f2: e022         	sd	s0, 0x0(sp)
400031f4: 7910         	ld	a2, 0x30(a0)
400031f6: 95b2         	add	a1, a1, a2
400031f8: 00058023     	sb	zero, 0x0(a1)
400031fc: 5510         	lw	a2, 0x28(a0)
400031fe: 790c         	ld	a1, 0x30(a0)
40003200: 842a         	mv	s0, a0
40003202: 8532         	mv	a0, a2
40003204: 012000ef     	jal	0x40003216 <flexio_dev_fputs>
40003208: 02042c23     	sw	zero, 0x38(s0)
4000320c: 60a2         	ld	ra, 0x8(sp)
4000320e: 6402         	ld	s0, 0x0(sp)
40003210: 0141         	addi	sp, sp, 0x10
40003212: 4501         	li	a0, 0x0
40003214: 8082         	ret

0000000040003216 <flexio_dev_fputs>:
40003216: 715d         	addi	sp, sp, -0x50
40003218: e486         	sd	ra, 0x48(sp)
4000321a: e0a2         	sd	s0, 0x40(sp)
4000321c: fc26         	sd	s1, 0x38(sp)
4000321e: f84a         	sd	s2, 0x30(sp)
40003220: f44e         	sd	s3, 0x28(sp)
40003222: f052         	sd	s4, 0x20(sp)
40003224: 00351613     	slli	a2, a0, 0x3
40003228: 3fffd697     	auipc	a3, 0x3fffd
4000322c: f3068693     	addi	a3, a3, -0xd0
40003230: 9636         	add	a2, a2, a3
40003232: 00063a03     	ld	s4, 0x0(a2)
40003236: 013a4603     	lbu	a2, 0x13(s4)
4000323a: 468d         	li	a3, 0x3
4000323c: 34d60563     	beq	a2, a3, 0x40003586 <flexio_dev_fputs+0x370>
40003240: 008a2603     	lw	a2, 0x8(s4)
40003244: 34060163     	beqz	a2, 0x40003586 <flexio_dev_fputs+0x370>
40003248: 0ff00613     	li	a2, 0xff
4000324c: 86aa         	mv	a3, a0
4000324e: 4501         	li	a0, 0x0
40003250: 32d66c63     	bltu	a2, a3, 0x40003588 <flexio_dev_fputs+0x372>
40003254: 050a3483     	ld	s1, 0x50(s4)
40003258: 40d0         	lw	a2, 0x4(s1)
4000325a: 32060763     	beqz	a2, 0x40003588 <flexio_dev_fputs+0x372>
4000325e: 892e         	mv	s2, a1
40003260: 01448513     	addi	a0, s1, 0x14
40003264: 4585         	li	a1, 0x1
40003266: 0eb5262f     	amoswap.w.aqrl	a2, a1, (a0)
4000326a: fe75         	bnez	a2, 0x40003266 <flexio_dev_fputs+0x50>
4000326c: 01848593     	addi	a1, s1, 0x18
40003270: 0028         	addi	a0, sp, 0x8
40003272: 4661         	li	a2, 0x18
40003274: e05fc0ef     	jal	0x40000078 <memcpy>
40003278: 4cc8         	lw	a0, 0x1c(s1)
4000327a: 0511         	addi	a0, a0, 0x4
4000327c: ccc8         	sw	a0, 0x1c(s1)
4000327e: 4c88         	lw	a0, 0x18(s1)
40003280: 0505         	addi	a0, a0, 0x1
40003282: cc88         	sw	a0, 0x18(s1)
40003284: 5088         	lw	a0, 0x20(s1)
40003286: 0505         	addi	a0, a0, 0x1
40003288: 013a4583     	lbu	a1, 0x13(s4)
4000328c: 4605         	li	a2, 0x1
4000328e: d088         	sw	a0, 0x20(s1)
40003290: 30c58a63     	beq	a1, a2, 0x400035a4 <flexio_dev_fputs+0x38e>
40003294: 010a4583     	lbu	a1, 0x10(s4)
40003298: 28b015b3     	bset	a1, zero, a1
4000329c: 2581         	sext.w	a1, a1
4000329e: 44d0         	lw	a2, 0xc(s1)
400032a0: 40c5063b     	subw	a2, a0, a2
400032a4: feb67de3     	bgeu	a2, a1, 0x4000329e <flexio_dev_fputs+0x88>
400032a8: 69c1         	lui	s3, 0x10
400032aa: 19fd         	addi	s3, s3, -0x1
400032ac: 0310000f     	fence	rw, w
400032b0: 0004aa23     	sw	zero, 0x14(s1)
400032b4: 050a3603     	ld	a2, 0x50(s4)
400032b8: 4e05         	li	t3, 0x1
400032ba: 537d         	li	t1, -0x1
400032bc: 4811         	li	a6, 0x4
400032be: ffd98893     	addi	a7, s3, -0x3
400032c2: 42c1         	li	t0, 0x10
400032c4: a805         	j	0x400032f4 <flexio_dev_fputs+0xde>
400032c6: 0310000f     	fence	rw, w
400032ca: 02062823     	sw	zero, 0x30(a2)
400032ce: 010a4683     	lbu	a3, 0x10(s4)
400032d2: 050a3603     	ld	a2, 0x50(s4)
400032d6: 00c11503     	lh	a0, 0xc(sp)
400032da: 00d815b3     	sll	a1, a6, a3
400032de: 01061703     	lh	a4, 0x10(a2)
400032e2: 070a         	slli	a4, a4, 0x2
400032e4: 9d19         	subw	a0, a0, a4
400032e6: 0805453b     	zext.h	a0, a0
400032ea: 0115f5b3     	and	a1, a1, a7
400032ee: 2581         	sext.w	a1, a1
400032f0: 0aa5fb63     	bgeu	a1, a0, 0x400033a6 <flexio_dev_fputs+0x190>
400032f4: 011a4683     	lbu	a3, 0x11(s4)
400032f8: 03060713     	addi	a4, a2, 0x30
400032fc: 0fc727af     	amoswap.w.aqrl	a5, t3, (a4)
40003300: fff5         	bnez	a5, 0x400032fc <flexio_dev_fputs+0xe6>
40003302: 00d314b3     	sll	s1, t1, a3
40003306: 040a3683     	ld	a3, 0x40(s4)
4000330a: 03466703     	lwu	a4, 0x34(a2)
4000330e: 40977733     	andn	a4, a4, s1
40003312: 00671793     	slli	a5, a4, 0x6
40003316: 97b6         	add	a5, a5, a3
40003318: 03f7c583     	lbu	a1, 0x3f(a5)
4000331c: 0015f393     	andi	t2, a1, 0x1
40003320: 03864583     	lbu	a1, 0x38(a2)
40003324: fab381e3     	beq	t2, a1, 0x400032c6 <flexio_dev_fputs+0xb0>
40003328: 03f78793     	addi	a5, a5, 0x3f
4000332c: 0220000f     	fence	r, r
40003330: 0007c583     	lbu	a1, 0x0(a5)
40003334: 2a55fa63     	bgeu	a1, t0, 0x400035e8 <flexio_dev_fputs+0x3d2>
40003338: 071a         	slli	a4, a4, 0x6
4000333a: 9736         	add	a4, a4, a3
4000333c: 03c71583     	lh	a1, 0x3c(a4)
40003340: 6885d59b     	greviw	a1, a1, 0x8
40003344: 00b61823     	sh	a1, 0x10(a2)
40003348: 050a3703     	ld	a4, 0x50(s4)
4000334c: 011a4583     	lbu	a1, 0x11(s4)
40003350: 00b315b3     	sll	a1, t1, a1
40003354: 5b5c         	lw	a5, 0x34(a4)
40003356: 0785         	addi	a5, a5, 0x1
40003358: 40b7f5b3     	andn	a1, a5, a1
4000335c: 2581         	sext.w	a1, a1
4000335e: db5c         	sw	a5, 0x34(a4)
40003360: cd85         	beqz	a1, 0x40003398 <flexio_dev_fputs+0x182>
40003362: 0110000f     	fence	w, w
40003366: 038a3583     	ld	a1, 0x38(s4)
4000336a: 17a2         	slli	a5, a5, 0x28
4000336c: 93a1         	srli	a5, a5, 0x28
4000336e: 6987d71b     	greviw	a4, a5, 0x18
40003372: c198         	sw	a4, 0x0(a1)
40003374: 03466583     	lwu	a1, 0x34(a2)
40003378: 4095f733     	andn	a4, a1, s1
4000337c: 00671593     	slli	a1, a4, 0x6
40003380: 95b6         	add	a1, a1, a3
40003382: 03f5c783     	lbu	a5, 0x3f(a1)
40003386: 0017f413     	andi	s0, a5, 0x1
4000338a: 03864503     	lbu	a0, 0x38(a2)
4000338e: 03f58793     	addi	a5, a1, 0x3f
40003392: f8a41de3     	bne	s0, a0, 0x4000332c <flexio_dev_fputs+0x116>
40003396: bf05         	j	0x400032c6 <flexio_dev_fputs+0xb0>
40003398: 03874583     	lbu	a1, 0x38(a4)
4000339c: 0015b593     	seqz	a1, a1
400033a0: 02b70c23     	sb	a1, 0x38(a4)
400033a4: bf7d         	j	0x40003362 <flexio_dev_fputs+0x14c>
400033a6: 013a4503     	lbu	a0, 0x13(s4)
400033aa: 10050363     	beqz	a0, 0x400034b0 <flexio_dev_fputs+0x29a>
400033ae: 00815503     	lhu	a0, 0x8(sp)
400033b2: 55fd         	li	a1, -0x1
400033b4: 00d595b3     	sll	a1, a1, a3
400033b8: 40b57533     	andn	a0, a0, a1
400033bc: 012a4583     	lbu	a1, 0x12(s4)
400033c0: 00b51533     	sll	a0, a0, a1
400033c4: 030a3483     	ld	s1, 0x30(s4)
400033c8: 08054533     	zext.w	a0, a0
400033cc: 94aa         	add	s1, s1, a0
400033ce: 28b01533     	bset	a0, zero, a1
400033d2: 080545b3     	zext.w	a1, a0
400033d6: 46e2         	lw	a3, 0x18(sp)
400033d8: 02023503     	ld	a0, 0x20(tp)
400033dc: 4d58         	lw	a4, 0x1c(a0)
400033de: 00002517     	auipc	a0, 0x2
400033e2: 9aa50613     	addi	a2, a0, -0x656
400033e6: 8526         	mv	a0, s1
400033e8: 87ca         	mv	a5, s2
400033ea: ef5fc0ef     	jal	0x400002de <snprintf>
400033ee: 020a3583     	ld	a1, 0x20(s4)
400033f2: 46f2         	lw	a3, 0x1c(sp)
400033f4: 01416603     	lwu	a2, 0x14(sp)
400033f8: 1ea6e663     	bltu	a3, a0, 0x400035e4 <flexio_dev_fputs+0x3ce>
400033fc: 95b2         	add	a1, a1, a2
400033fe: 010a4603     	lbu	a2, 0x10(s4)
40003402: 028a3683     	ld	a3, 0x28(s4)
40003406: 4432         	lw	s0, 0xc(sp)
40003408: 4791         	li	a5, 0x4
4000340a: 00c79633     	sll	a2, a5, a2
4000340e: 964e         	add	a2, a2, s3
40003410: 00140713     	addi	a4, s0, 0x1
40003414: c63a         	sw	a4, 0xc(sp)
40003416: 8e61         	and	a2, a2, s0
40003418: 1642         	slli	a2, a2, 0x30
4000341a: 9231         	srli	a2, a2, 0x2c
4000341c: 9636         	add	a2, a2, a3
4000341e: 46c2         	lw	a3, 0x10(sp)
40003420: 000a2703     	lw	a4, 0x0(s4)
40003424: 16c2         	slli	a3, a3, 0x30
40003426: 92a1         	srli	a3, a3, 0x28
40003428: 26a1         	addiw	a3, a3, 0x8
4000342a: 6986d69b     	greviw	a3, a3, 0x18
4000342e: c214         	sw	a3, 0x0(a2)
40003430: 0722         	slli	a4, a4, 0x8
40003432: 270d         	addiw	a4, a4, 0x3
40003434: 6987569b     	greviw	a3, a4, 0x18
40003438: c254         	sw	a3, 0x4(a2)
4000343a: 080006b7     	lui	a3, 0x8000
4000343e: e614         	sd	a3, 0x8(a2)
40003440: 010a4603     	lbu	a2, 0x10(s4)
40003444: 028a3683     	ld	a3, 0x28(s4)
40003448: 4432         	lw	s0, 0xc(sp)
4000344a: 00c79633     	sll	a2, a5, a2
4000344e: 964e         	add	a2, a2, s3
40003450: 00140713     	addi	a4, s0, 0x1
40003454: c63a         	sw	a4, 0xc(sp)
40003456: 8e61         	and	a2, a2, s0
40003458: 1642         	slli	a2, a2, 0x30
4000345a: 9231         	srli	a2, a2, 0x2c
4000345c: 9636         	add	a2, a2, a3
4000345e: 014a2683     	lw	a3, 0x14(s4)
40003462: 6b85d593     	rev8	a1, a1
40003466: e20c         	sd	a1, 0x0(a2)
40003468: 6986d59b     	greviw	a1, a3, 0x18
4000346c: c60c         	sw	a1, 0x8(a2)
4000346e: 010a4583     	lbu	a1, 0x10(s4)
40003472: 028a3603     	ld	a2, 0x28(s4)
40003476: 46b2         	lw	a3, 0xc(sp)
40003478: 00b795b3     	sll	a1, a5, a1
4000347c: 95ce         	add	a1, a1, s3
4000347e: 00168713     	addi	a4, a3, 0x1
40003482: c63a         	sw	a4, 0xc(sp)
40003484: 8df5         	and	a1, a1, a3
40003486: 15c2         	slli	a1, a1, 0x30
40003488: 91b1         	srli	a1, a1, 0x2c
4000348a: 95b2         	add	a1, a1, a2
4000348c: 008a2603     	lw	a2, 0x8(s4)
40003490: 6985569b     	greviw	a3, a0, 0x18
40003494: c194         	sw	a3, 0x0(a1)
40003496: 6986561b     	greviw	a2, a2, 0x18
4000349a: c1d0         	sw	a2, 0x4(a1)
4000349c: 6b84d613     	rev8	a2, s1
400034a0: e590         	sd	a2, 0x8(a1)
400034a2: 002c         	addi	a1, sp, 0x8
400034a4: 84aa         	mv	s1, a0
400034a6: 8552         	mv	a0, s4
400034a8: 14a000ef     	jal	0x400035f2 <ready_for_db>
400034ac: 8526         	mv	a0, s1
400034ae: a8e9         	j	0x40003588 <flexio_dev_fputs+0x372>
400034b0: 01ba4503     	lbu	a0, 0x1b(s4)
400034b4: c519         	beqz	a0, 0x400034c2 <flexio_dev_fputs+0x2ac>
400034b6: 458d         	li	a1, 0x3
400034b8: 0eb50063     	beq	a0, a1, 0x40003598 <flexio_dev_fputs+0x382>
400034bc: 4589         	li	a1, 0x2
400034be: 0cb51463     	bne	a0, a1, 0x40003586 <flexio_dev_fputs+0x370>
400034c2: 00815503     	lhu	a0, 0x8(sp)
400034c6: 55fd         	li	a1, -0x1
400034c8: 00d595b3     	sll	a1, a1, a3
400034cc: 40b57533     	andn	a0, a0, a1
400034d0: 012a4583     	lbu	a1, 0x12(s4)
400034d4: 00b51533     	sll	a0, a0, a1
400034d8: 030a3483     	ld	s1, 0x30(s4)
400034dc: 08054533     	zext.w	a0, a0
400034e0: 94aa         	add	s1, s1, a0
400034e2: 28b01533     	bset	a0, zero, a1
400034e6: 080545b3     	zext.w	a1, a0
400034ea: 02023503     	ld	a0, 0x20(tp)
400034ee: 4d54         	lw	a3, 0x1c(a0)
400034f0: 00002517     	auipc	a0, 0x2
400034f4: a1850613     	addi	a2, a0, -0x5e8
400034f8: 8526         	mv	a0, s1
400034fa: 874a         	mv	a4, s2
400034fc: de3fc0ef     	jal	0x400002de <snprintf>
40003500: 0015041b     	addiw	s0, a0, 0x1
40003504: 010a4503     	lbu	a0, 0x10(s4)
40003508: 028a3583     	ld	a1, 0x28(s4)
4000350c: 4632         	lw	a2, 0xc(sp)
4000350e: 4691         	li	a3, 0x4
40003510: 00a69533     	sll	a0, a3, a0
40003514: 954e         	add	a0, a0, s3
40003516: 00160713     	addi	a4, a2, 0x1
4000351a: c63a         	sw	a4, 0xc(sp)
4000351c: 8d71         	and	a0, a0, a2
4000351e: 1542         	slli	a0, a0, 0x30
40003520: 9131         	srli	a0, a0, 0x2c
40003522: 952e         	add	a0, a0, a1
40003524: 45c2         	lw	a1, 0x10(sp)
40003526: 000a2603     	lw	a2, 0x0(s4)
4000352a: 15c2         	slli	a1, a1, 0x30
4000352c: 91a1         	srli	a1, a1, 0x28
4000352e: 25a9         	addiw	a1, a1, 0xa
40003530: 6985d59b     	greviw	a1, a1, 0x18
40003534: c10c         	sw	a1, 0x0(a0)
40003536: 0622         	slli	a2, a2, 0x8
40003538: 2609         	addiw	a2, a2, 0x2
4000353a: 6986559b     	greviw	a1, a2, 0x18
4000353e: c14c         	sw	a1, 0x4(a0)
40003540: 080005b7     	lui	a1, 0x8000
40003544: e50c         	sd	a1, 0x8(a0)
40003546: 010a4503     	lbu	a0, 0x10(s4)
4000354a: 028a3583     	ld	a1, 0x28(s4)
4000354e: 4632         	lw	a2, 0xc(sp)
40003550: 00a69533     	sll	a0, a3, a0
40003554: 954e         	add	a0, a0, s3
40003556: 00160693     	addi	a3, a2, 0x1
4000355a: c636         	sw	a3, 0xc(sp)
4000355c: 8d71         	and	a0, a0, a2
4000355e: 1542         	slli	a0, a0, 0x30
40003560: 9131         	srli	a0, a0, 0x2c
40003562: 952e         	add	a0, a0, a1
40003564: 008a2583     	lw	a1, 0x8(s4)
40003568: 6984561b     	greviw	a2, s0, 0x18
4000356c: c110         	sw	a2, 0x0(a0)
4000356e: 6985d59b     	greviw	a1, a1, 0x18
40003572: c14c         	sw	a1, 0x4(a0)
40003574: 6b84d593     	rev8	a1, s1
40003578: e50c         	sd	a1, 0x8(a0)
4000357a: 002c         	addi	a1, sp, 0x8
4000357c: 8552         	mv	a0, s4
4000357e: 074000ef     	jal	0x400035f2 <ready_for_db>
40003582: 8522         	mv	a0, s0
40003584: a011         	j	0x40003588 <flexio_dev_fputs+0x372>
40003586: 4501         	li	a0, 0x0
40003588: 60a6         	ld	ra, 0x48(sp)
4000358a: 6406         	ld	s0, 0x40(sp)
4000358c: 74e2         	ld	s1, 0x38(sp)
4000358e: 7942         	ld	s2, 0x30(sp)
40003590: 79a2         	ld	s3, 0x28(sp)
40003592: 7a02         	ld	s4, 0x20(sp)
40003594: 6161         	addi	sp, sp, 0x50
40003596: 8082         	ret
40003598: 002c         	addi	a1, sp, 0x8
4000359a: 8552         	mv	a0, s4
4000359c: 864a         	mv	a2, s2
4000359e: 178000ef     	jal	0x40003716 <puts_send_ud>
400035a2: b7dd         	j	0x40003588 <flexio_dev_fputs+0x372>
400035a4: 5488         	lw	a0, 0x28(s1)
400035a6: 0505         	addi	a0, a0, 0x1
400035a8: d488         	sw	a0, 0x28(s1)
400035aa: 02023503     	ld	a0, 0x20(tp)
400035ae: 4d48         	lw	a0, 0x1c(a0)
400035b0: 59fd         	li	s3, -0x1
400035b2: 0045551b     	srliw	a0, a0, 0x4
400035b6: 0985         	addi	s3, s3, 0x1
400035b8: fd6d         	bnez	a0, 0x400035b2 <flexio_dev_fputs+0x39c>
400035ba: 854a         	mv	a0, s2
400035bc: c77fc0ef     	jal	0x40000232 <strlen>
400035c0: 954e         	add	a0, a0, s3
400035c2: 50cc         	lw	a1, 0x24(s1)
400035c4: 952e         	add	a0, a0, a1
400035c6: 0531         	addi	a0, a0, 0xc
400035c8: 018a4583     	lbu	a1, 0x18(s4)
400035cc: 567d         	li	a2, -0x1
400035ce: 00b61633     	sll	a2, a2, a1
400035d2: 40c57533     	andn	a0, a0, a2
400035d6: d0c8         	sw	a0, 0x24(s1)
400035d8: 28b015b3     	bset	a1, zero, a1
400035dc: 9d89         	subw	a1, a1, a0
400035de: d4cc         	sw	a1, 0x2c(s1)
400035e0: 5088         	lw	a0, 0x20(s1)
400035e2: b94d         	j	0x40003294 <flexio_dev_fputs+0x7e>
400035e4: 8536         	mv	a0, a3
400035e6: bd19         	j	0x400033fc <flexio_dev_fputs+0x1e6>
400035e8: 04000513     	li	a0, 0x40
400035ec: 4891         	li	a7, 0x4
400035ee: 00000073     	ecall

00000000400035f2 <ready_for_db>:
400035f2: 7179         	addi	sp, sp, -0x30
400035f4: f422         	sd	s0, 0x28(sp)
400035f6: f026         	sd	s1, 0x20(sp)
400035f8: ec4a         	sd	s2, 0x18(sp)
400035fa: e84e         	sd	s3, 0x10(sp)
400035fc: e452         	sd	s4, 0x8(sp)
400035fe: e056         	sd	s5, 0x0(sp)
40003600: 05053a83     	ld	s5, 0x50(a0)
40003604: 4590         	lw	a2, 0x8(a1)
40003606: 01054683     	lbu	a3, 0x10(a0)
4000360a: 008a8713     	addi	a4, s5, 0x8
4000360e: 4785         	li	a5, 0x1
40003610: 0ef724af     	amoswap.w.aqrl	s1, a5, (a4)
40003614: fcf5         	bnez	s1, 0x40003610 <ready_for_db+0x1e>
40003616: 577d         	li	a4, -0x1
40003618: 00d717b3     	sll	a5, a4, a3
4000361c: 40f677b3     	andn	a5, a2, a5
40003620: 00d6563b     	srlw	a2, a2, a3
40003624: 6534         	ld	a3, 0x48(a0)
40003626: 0807c7b3     	zext.w	a5, a5
4000362a: 96be         	add	a3, a3, a5
4000362c: 00c68023     	sb	a2, 0x0(a3)
40003630: 00caa783     	lw	a5, 0xc(s5)
40003634: 01054603     	lbu	a2, 0x10(a0)
40003638: 04853803     	ld	a6, 0x48(a0)
4000363c: 00c71733     	sll	a4, a4, a2
40003640: 84be         	mv	s1, a5
40003642: 40e7f7b3     	andn	a5, a5, a4
40003646: 00c4d43b     	srlw	s0, s1, a2
4000364a: 0807c7b3     	zext.w	a5, a5
4000364e: 97c2         	add	a5, a5, a6
40003650: 0007c683     	lbu	a3, 0x0(a5)
40003654: 0ff47413     	zext.b	s0, s0
40003658: 0014879b     	addiw	a5, s1, 0x1
4000365c: fe8682e3     	beq	a3, s0, 0x40003640 <ready_for_db+0x4e>
40003660: 458c         	lw	a1, 0x8(a1)
40003662: 04b4e063     	bltu	s1, a1, 0x400036a2 <ready_for_db+0xb0>
40003666: 02023583     	ld	a1, 0x20(tp)
4000366a: 0005e903     	lwu	s2, 0x0(a1)
4000366e: 55fd         	li	a1, -0x1
40003670: 9181         	srli	a1, a1, 0x20
40003672: 04b91463     	bne	s2, a1, 0x400036ba <ready_for_db+0xc8>
40003676: 0110000f     	fence	w, w
4000367a: 00056503     	lwu	a0, 0x0(a0)
4000367e: 2a101593     	bseti	a1, zero, 0x21
40003682: 6190         	ld	a2, 0x0(a1)
40003684: 8a05         	andi	a2, a2, 0x1
40003686: fe75         	bnez	a2, 0x40003682 <ready_for_db+0x90>
40003688: 0804c5bb     	zext.h	a1, s1
4000368c: 08a5c533     	pack	a0, a1, a0
40003690: 1c000593     	li	a1, 0x1c0
40003694: 2a159593     	bseti	a1, a1, 0x21
40003698: e188         	sd	a0, 0x0(a1)
4000369a: 00caa003     	lw	zero, 0xc(s5)
4000369e: 009aa623     	sw	s1, 0xc(s5)
400036a2: 0310000f     	fence	rw, w
400036a6: 000aa423     	sw	zero, 0x8(s5)
400036aa: 7422         	ld	s0, 0x28(sp)
400036ac: 7482         	ld	s1, 0x20(sp)
400036ae: 6962         	ld	s2, 0x18(sp)
400036b0: 69c2         	ld	s3, 0x10(sp)
400036b2: 6a22         	ld	s4, 0x8(sp)
400036b4: 6a82         	ld	s5, 0x0(sp)
400036b6: 6145         	addi	sp, sp, 0x30
400036b8: 8082         	ret
400036ba: 89aa         	mv	s3, a0
400036bc: 00c56a03     	lwu	s4, 0xc(a0)
400036c0: 00823583     	ld	a1, 0x8(tp)
400036c4: 080a453b     	zext.h	a0, s4
400036c8: 4895         	li	a7, 0x5
400036ca: 00000073     	ecall
400036ce: c509         	beqz	a0, 0x400036d8 <ready_for_db+0xe6>
400036d0: 02023503     	ld	a0, 0x20(tp)
400036d4: 01452023     	sw	s4, 0x0(a0)
400036d8: 0110000f     	fence	w, w
400036dc: 0009e503     	lwu	a0, 0x0(s3)
400036e0: 2a101593     	bseti	a1, zero, 0x21
400036e4: 6190         	ld	a2, 0x0(a1)
400036e6: 8a05         	andi	a2, a2, 0x1
400036e8: fe75         	bnez	a2, 0x400036e4 <ready_for_db+0xf2>
400036ea: 0804c5bb     	zext.h	a1, s1
400036ee: 08a5c533     	pack	a0, a1, a0
400036f2: 1c000593     	li	a1, 0x1c0
400036f6: 2a159593     	bseti	a1, a1, 0x21
400036fa: e188         	sd	a0, 0x0(a1)
400036fc: 00823583     	ld	a1, 0x8(tp)
40003700: 0809453b     	zext.h	a0, s2
40003704: 4895         	li	a7, 0x5
40003706: 00000073     	ecall
4000370a: d941         	beqz	a0, 0x4000369a <ready_for_db+0xa8>
4000370c: 02023503     	ld	a0, 0x20(tp)
40003710: 01252023     	sw	s2, 0x0(a0)
40003714: b759         	j	0x4000369a <ready_for_db+0xa8>

0000000040003716 <puts_send_ud>:
40003716: 7179         	addi	sp, sp, -0x30
40003718: f406         	sd	ra, 0x28(sp)
4000371a: f022         	sd	s0, 0x20(sp)
4000371c: ec26         	sd	s1, 0x18(sp)
4000371e: e84a         	sd	s2, 0x10(sp)
40003720: e44e         	sd	s3, 0x8(sp)
40003722: 8732         	mv	a4, a2
40003724: 842e         	mv	s0, a1
40003726: 84aa         	mv	s1, a0
40003728: 0005d503     	lhu	a0, 0x0(a1)
4000372c: 0104c583     	lbu	a1, 0x10(s1)
40003730: 567d         	li	a2, -0x1
40003732: 00b615b3     	sll	a1, a2, a1
40003736: 40b57533     	andn	a0, a0, a1
4000373a: 0124c583     	lbu	a1, 0x12(s1)
4000373e: 00b51533     	sll	a0, a0, a1
40003742: 0304b903     	ld	s2, 0x30(s1)
40003746: 08054533     	zext.w	a0, a0
4000374a: 992a         	add	s2, s2, a0
4000374c: 28b01533     	bset	a0, zero, a1
40003750: 080545b3     	zext.w	a1, a0
40003754: 02023503     	ld	a0, 0x20(tp)
40003758: 4d54         	lw	a3, 0x1c(a0)
4000375a: 00001517     	auipc	a0, 0x1
4000375e: 7ae50613     	addi	a2, a0, 0x7ae
40003762: 854a         	mv	a0, s2
40003764: b7bfc0ef     	jal	0x400002de <snprintf>
40003768: 0015099b     	addiw	s3, a0, 0x1
4000376c: 0104c503     	lbu	a0, 0x10(s1)
40003770: 748c         	ld	a1, 0x28(s1)
40003772: 4050         	lw	a2, 0x4(s0)
40003774: 4691         	li	a3, 0x4
40003776: 00a69533     	sll	a0, a3, a0
4000377a: 157d         	addi	a0, a0, -0x1
4000377c: 00160713     	addi	a4, a2, 0x1
40003780: c058         	sw	a4, 0x4(s0)
40003782: 8d71         	and	a0, a0, a2
40003784: 1542         	slli	a0, a0, 0x30
40003786: 9131         	srli	a0, a0, 0x2c
40003788: 952e         	add	a0, a0, a1
4000378a: 440c         	lw	a1, 0x8(s0)
4000378c: 4090         	lw	a2, 0x0(s1)
4000378e: 15c2         	slli	a1, a1, 0x30
40003790: 91a1         	srli	a1, a1, 0x28
40003792: 25a9         	addiw	a1, a1, 0xa
40003794: 6985d59b     	greviw	a1, a1, 0x18
40003798: c10c         	sw	a1, 0x0(a0)
4000379a: 0622         	slli	a2, a2, 0x8
4000379c: 260d         	addiw	a2, a2, 0x3
4000379e: 6986559b     	greviw	a1, a2, 0x18
400037a2: c14c         	sw	a1, 0x4(a0)
400037a4: 080005b7     	lui	a1, 0x8000
400037a8: e50c         	sd	a1, 0x8(a0)
400037aa: 0104c503     	lbu	a0, 0x10(s1)
400037ae: 748c         	ld	a1, 0x28(s1)
400037b0: 4050         	lw	a2, 0x4(s0)
400037b2: 00a69533     	sll	a0, a3, a0
400037b6: 157d         	addi	a0, a0, -0x1
400037b8: 00160713     	addi	a4, a2, 0x1
400037bc: c058         	sw	a4, 0x4(s0)
400037be: 8d71         	and	a0, a0, a2
400037c0: 1542         	slli	a0, a0, 0x30
400037c2: 9131         	srli	a0, a0, 0x2c
400037c4: 952e         	add	a0, a0, a1
400037c6: 4ccc         	lw	a1, 0x1c(s1)
400037c8: 58b0         	lw	a2, 0x70(s1)
400037ca: 07449703     	lh	a4, 0x74(s1)
400037ce: 6985d59b     	greviw	a1, a1, 0x18
400037d2: c10c         	sw	a1, 0x0(a0)
400037d4: 00052223     	sw	zero, 0x4(a0)
400037d8: 6986559b     	greviw	a1, a2, 0x18
400037dc: c50c         	sw	a1, 0x8(a0)
400037de: 65a1         	lui	a1, 0x8
400037e0: 00b51623     	sh	a1, 0xc(a0)
400037e4: 6887559b     	greviw	a1, a4, 0x8
400037e8: 00b51723     	sh	a1, 0xe(a0)
400037ec: 0104c503     	lbu	a0, 0x10(s1)
400037f0: 748c         	ld	a1, 0x28(s1)
400037f2: 4050         	lw	a2, 0x4(s0)
400037f4: 00a69533     	sll	a0, a3, a0
400037f8: 157d         	addi	a0, a0, -0x1
400037fa: 00160693     	addi	a3, a2, 0x1
400037fe: c054         	sw	a3, 0x4(s0)
40003800: 8d71         	and	a0, a0, a2
40003802: 1542         	slli	a0, a0, 0x30
40003804: 9131         	srli	a0, a0, 0x2c
40003806: 952e         	add	a0, a0, a1
40003808: 448c         	lw	a1, 0x8(s1)
4000380a: 6989d61b     	greviw	a2, s3, 0x18
4000380e: c110         	sw	a2, 0x0(a0)
40003810: 6985d59b     	greviw	a1, a1, 0x18
40003814: c14c         	sw	a1, 0x4(a0)
40003816: 6b895593     	rev8	a1, s2
4000381a: e50c         	sd	a1, 0x8(a0)
4000381c: 8526         	mv	a0, s1
4000381e: 85a2         	mv	a1, s0
40003820: dd3ff0ef     	jal	0x400035f2 <ready_for_db>
40003824: 854e         	mv	a0, s3
40003826: 70a2         	ld	ra, 0x28(sp)
40003828: 7402         	ld	s0, 0x20(sp)
4000382a: 64e2         	ld	s1, 0x18(sp)
4000382c: 6942         	ld	s2, 0x10(sp)
4000382e: 69a2         	ld	s3, 0x8(sp)
40003830: 6145         	addi	sp, sp, 0x30
40003832: 8082         	ret

0000000040003834 <_dpacc_flexio_dev_arg_unpack_msg_stream_level_set>:
40003834: 6108         	ld	a0, 0x0(a0)
40003836: 8582         	jr	a1

0000000040003838 <_dpacc_flexio_dev_arg_unpack_rpc_msg_stream_cfg>:
40003838: 6108         	ld	a0, 0x0(a0)
4000383a: 8582         	jr	a1

000000004000383c <_dpacc_flexio_dev_arg_unpack_rpc_msg_stream_close>:
4000383c: 6108         	ld	a0, 0x0(a0)
4000383e: 8582         	jr	a1

0000000040003840 <rpc_dtrace_init>:
40003840: 7179         	addi	sp, sp, -0x30
40003842: f406         	sd	ra, 0x28(sp)
40003844: f022         	sd	s0, 0x20(sp)
40003846: ec26         	sd	s1, 0x18(sp)
40003848: e84a         	sd	s2, 0x10(sp)
4000384a: e44e         	sd	s3, 0x8(sp)
4000384c: 842a         	mv	s0, a0
4000384e: 3fffe517     	auipc	a0, 0x3fffe
40003852: 8fa50913     	addi	s2, a0, -0x706
40003856: 01090493     	addi	s1, s2, 0x10
4000385a: 0b800613     	li	a2, 0xb8
4000385e: 8526         	mv	a0, s1
40003860: 4581         	li	a1, 0x0
40003862: 927fc0ef     	jal	0x40000188 <memset>
40003866: 4008         	lw	a0, 0x0(s0)
40003868: 06a92823     	sw	a0, 0x70(s2)
4000386c: 06000993     	li	s3, 0x60
40003870: 0b355633     	minu	a2, a0, s3
40003874: 8526         	mv	a0, s1
40003876: 85a2         	mv	a1, s0
40003878: 801fc0ef     	jal	0x40000078 <memcpy>
4000387c: 4008         	lw	a0, 0x0(s0)
4000387e: 05351b63     	bne	a0, s3, 0x400038d4 <rpc_dtrace_init+0x94>
40003882: 4501         	li	a0, 0x0
40003884: 00092023     	sw	zero, 0x0(s2)
40003888: 0310000f     	fence	rw, w
4000388c: 06092e23     	sw	zero, 0x7c(s2)
40003890: 01694583     	lbu	a1, 0x16(s2)
40003894: 28b015b3     	bset	a1, zero, a1
40003898: 15fd         	addi	a1, a1, -0x1
4000389a: 08b92223     	sw	a1, 0x84(s2)
4000389e: 01594583     	lbu	a1, 0x15(s2)
400038a2: 28b015b3     	bset	a1, zero, a1
400038a6: 15fd         	addi	a1, a1, -0x1
400038a8: 08b92023     	sw	a1, 0x80(s2)
400038ac: 01494583     	lbu	a1, 0x14(s2)
400038b0: 4605         	li	a2, 0x1
400038b2: 08092823     	sw	zero, 0x90(s2)
400038b6: 02b64163     	blt	a2, a1, 0x400038d8 <rpc_dtrace_init+0x98>
400038ba: c1b9         	beqz	a1, 0x40003900 <rpc_dtrace_init+0xc0>
400038bc: 4605         	li	a2, 0x1
400038be: 06c59763     	bne	a1, a2, 0x4000392c <rpc_dtrace_init+0xec>
400038c2: 02093583     	ld	a1, 0x20(s2)
400038c6: c9b5         	beqz	a1, 0x4000393a <rpc_dtrace_init+0xfa>
400038c8: 4501         	li	a0, 0x0
400038ca: 058e         	slli	a1, a1, 0x3
400038cc: 818d         	srli	a1, a1, 0x3
400038ce: 2bf59593     	bseti	a1, a1, 0x3f
400038d2: a899         	j	0x40003928 <rpc_dtrace_init+0xe8>
400038d4: 557d         	li	a0, -0x1
400038d6: a899         	j	0x4000392c <rpc_dtrace_init+0xec>
400038d8: 4609         	li	a2, 0x2
400038da: 04c58463     	beq	a1, a2, 0x40003922 <rpc_dtrace_init+0xe2>
400038de: 460d         	li	a2, 0x3
400038e0: 04c59663     	bne	a1, a2, 0x4000392c <rpc_dtrace_init+0xec>
400038e4: 4501         	li	a0, 0x0
400038e6: 05893583     	ld	a1, 0x58(s2)
400038ea: 08b93423     	sd	a1, 0x88(s2)
400038ee: 06093583     	ld	a1, 0x60(s2)
400038f2: 0ab93423     	sd	a1, 0xa8(s2)
400038f6: 06893583     	ld	a1, 0x68(s2)
400038fa: 0ab93823     	sd	a1, 0xb0(s2)
400038fe: a03d         	j	0x4000392c <rpc_dtrace_init+0xec>
40003900: 4501         	li	a0, 0x0
40003902: 03494583     	lbu	a1, 0x34(s2)
40003906: 28b015b3     	bset	a1, zero, a1
4000390a: 15fd         	addi	a1, a1, -0x1
4000390c: 08b92e23     	sw	a1, 0x9c(s2)
40003910: 04093583     	ld	a1, 0x40(s2)
40003914: 08b93423     	sd	a1, 0x88(s2)
40003918: 03893583     	ld	a1, 0x38(s2)
4000391c: 0ab93023     	sd	a1, 0xa0(s2)
40003920: a031         	j	0x4000392c <rpc_dtrace_init+0xec>
40003922: 4501         	li	a0, 0x0
40003924: 04893583     	ld	a1, 0x48(s2)
40003928: 08b93423     	sd	a1, 0x88(s2)
4000392c: 70a2         	ld	ra, 0x28(sp)
4000392e: 7402         	ld	s0, 0x20(sp)
40003930: 64e2         	ld	s1, 0x18(sp)
40003932: 6942         	ld	s2, 0x10(sp)
40003934: 69a2         	ld	s3, 0x8(sp)
40003936: 6145         	addi	sp, sp, 0x30
40003938: 8082         	ret
4000393a: 4501         	li	a0, 0x0
4000393c: bfc5         	j	0x4000392c <rpc_dtrace_init+0xec>

000000004000393e <rpc_dtrace_start>:
4000393e: 1101         	addi	sp, sp, -0x20
40003940: ec06         	sd	ra, 0x18(sp)
40003942: e822         	sd	s0, 0x10(sp)
40003944: e426         	sd	s1, 0x8(sp)
40003946: 3fffe597     	auipc	a1, 0x3fffe
4000394a: 80258413     	addi	s0, a1, -0x7fe
4000394e: 01444583     	lbu	a1, 0x14(s0)
40003952: 06042a23     	sw	zero, 0x74(s0)
40003956: 06042c23     	sw	zero, 0x78(s0)
4000395a: 4605         	li	a2, 0x1
4000395c: 08a42823     	sw	a0, 0x90(s0)
40003960: 02b64463     	blt	a2, a1, 0x40003988 <rpc_dtrace_start+0x4a>
40003964: c5b1         	beqz	a1, 0x400039b0 <rpc_dtrace_start+0x72>
40003966: 4605         	li	a2, 0x1
40003968: 12c59763     	bne	a1, a2, 0x40003a96 <rpc_dtrace_start+0x158>
4000396c: 00153513     	seqz	a0, a0
40003970: 157d         	addi	a0, a0, -0x1
40003972: 00000597     	auipc	a1, 0x0
40003976: 64458593     	addi	a1, a1, 0x644
4000397a: 40a5f5b3     	andn	a1, a1, a0
4000397e: 00000617     	auipc	a2, 0x0
40003982: 6e460613     	addi	a2, a2, 0x6e4
40003986: a229         	j	0x40003a90 <rpc_dtrace_start+0x152>
40003988: 4609         	li	a2, 0x2
4000398a: 0cc58a63     	beq	a1, a2, 0x40003a5e <rpc_dtrace_start+0x120>
4000398e: 460d         	li	a2, 0x3
40003990: 10c59363     	bne	a1, a2, 0x40003a96 <rpc_dtrace_start+0x158>
40003994: 00153513     	seqz	a0, a0
40003998: 157d         	addi	a0, a0, -0x1
4000399a: 00001597     	auipc	a1, 0x1
4000399e: 86c58593     	addi	a1, a1, -0x794
400039a2: 40a5f5b3     	andn	a1, a1, a0
400039a6: 00000617     	auipc	a2, 0x0
400039aa: 48060613     	addi	a2, a2, 0x480
400039ae: a0cd         	j	0x40003a90 <rpc_dtrace_start+0x152>
400039b0: 03444583     	lbu	a1, 0x34(s0)
400039b4: 28b016b3     	bset	a3, zero, a1
400039b8: 0006859b     	sext.w	a1, a3
400039bc: 06b05563     	blez	a1, 0x40003a26 <rpc_dtrace_start+0xe8>
400039c0: 01544703     	lbu	a4, 0x15(s0)
400039c4: 04000593     	li	a1, 0x40
400039c8: 00e597b3     	sll	a5, a1, a4
400039cc: 602c         	ld	a1, 0x40(s0)
400039ce: 7050         	ld	a2, 0xa0(s0)
400039d0: 6987d813     	rev8.w	a6, a5
400039d4: 2a601793     	bseti	a5, zero, 0x26
400039d8: 00e79733     	sll	a4, a5, a4
400039dc: 42075293     	srai	t0, a4, 0x20
400039e0: 16fd         	addi	a3, a3, -0x1
400039e2: 1682         	slli	a3, a3, 0x20
400039e4: 82e9         	srli	a3, a3, 0x1a
400039e6: 96b2         	add	a3, a3, a2
400039e8: 04068793     	addi	a5, a3, 0x40
400039ec: 0b0006b7     	lui	a3, 0xb000
400039f0: f0068693     	addi	a3, a3, -0x100
400039f4: 040008b7     	lui	a7, 0x4000
400039f8: 5418         	lw	a4, 0x28(s0)
400039fa: c214         	sw	a3, 0x0(a2)
400039fc: 0722         	slli	a4, a4, 0x8
400039fe: 2709         	addiw	a4, a4, 0x2
40003a00: 6987571b     	greviw	a4, a4, 0x18
40003a04: c258         	sw	a4, 0x4(a2)
40003a06: 01163423     	sd	a7, 0x8(a2)
40003a0a: 5458         	lw	a4, 0x2c(s0)
40003a0c: 01062823     	sw	a6, 0x10(a2)
40003a10: 6987571b     	greviw	a4, a4, 0x18
40003a14: ca58         	sw	a4, 0x14(a2)
40003a16: 6b85d713     	rev8	a4, a1
40003a1a: ee18         	sd	a4, 0x18(a2)
40003a1c: 04060613     	addi	a2, a2, 0x40
40003a20: 9596         	add	a1, a1, t0
40003a22: fcf61be3     	bne	a2, a5, 0x400039f8 <rpc_dtrace_start+0xba>
40003a26: 08042c23     	sw	zero, 0x98(s0)
40003a2a: 00153513     	seqz	a0, a0
40003a2e: fff50593     	addi	a1, a0, -0x1
40003a32: 00000617     	auipc	a2, 0x0
40003a36: 31460613     	addi	a2, a2, 0x314
40003a3a: 40b67633     	andn	a2, a2, a1
40003a3e: 00000697     	auipc	a3, 0x0
40003a42: 3e868693     	addi	a3, a3, 0x3e8
40003a46: 8df5         	and	a1, a1, a3
40003a48: 8dd1         	or	a1, a1, a2
40003a4a: fc4c         	sd	a1, 0xb8(s0)
40003a4c: 40a00533     	neg	a0, a0
40003a50: 00000597     	auipc	a1, 0x0
40003a54: 45258593     	addi	a1, a1, 0x452
40003a58: 8d6d         	and	a0, a0, a1
40003a5a: e068         	sd	a0, 0xc0(s0)
40003a5c: a82d         	j	0x40003a96 <rpc_dtrace_start+0x158>
40003a5e: 6454         	ld	a3, 0x88(s0)
40003a60: 08442583     	lw	a1, 0x84(s0)
40003a64: 0585         	addi	a1, a1, 0x1
40003a66: 0805c633     	zext.w	a2, a1
40003a6a: 0ff00593     	li	a1, 0xff
40003a6e: 84aa         	mv	s1, a0
40003a70: 8536         	mv	a0, a3
40003a72: f16fc0ef     	jal	0x40000188 <memset>
40003a76: 0014b513     	seqz	a0, s1
40003a7a: 157d         	addi	a0, a0, -0x1
40003a7c: 00000597     	auipc	a1, 0x0
40003a80: 68058593     	addi	a1, a1, 0x680
40003a84: 40a5f5b3     	andn	a1, a1, a0
40003a88: 00000617     	auipc	a2, 0x0
40003a8c: 70260613     	addi	a2, a2, 0x702
40003a90: 8d71         	and	a0, a0, a2
40003a92: 8d4d         	or	a0, a0, a1
40003a94: fc48         	sd	a0, 0xb8(s0)
40003a96: 0310000f     	fence	rw, w
40003a9a: 4505         	li	a0, 0x1
40003a9c: c008         	sw	a0, 0x0(s0)
40003a9e: 4501         	li	a0, 0x0
40003aa0: 60e2         	ld	ra, 0x18(sp)
40003aa2: 6442         	ld	s0, 0x10(sp)
40003aa4: 64a2         	ld	s1, 0x8(sp)
40003aa6: 6105         	addi	sp, sp, 0x20
40003aa8: 8082         	ret

0000000040003aaa <rpc_dtrace_stop>:
40003aaa: 0310000f     	fence	rw, w
40003aae: 3fffd517     	auipc	a0, 0x3fffd
40003ab2: 68052d23     	sw	zero, 0x69a(a0)
40003ab6: 4501         	li	a0, 0x0
40003ab8: 8082         	ret

0000000040003aba <rpc_dtrace_flush>:
40003aba: 711d         	addi	sp, sp, -0x60
40003abc: ec86         	sd	ra, 0x58(sp)
40003abe: e8a2         	sd	s0, 0x50(sp)
40003ac0: e4a6         	sd	s1, 0x48(sp)
40003ac2: e0ca         	sd	s2, 0x40(sp)
40003ac4: fc4e         	sd	s3, 0x38(sp)
40003ac6: f852         	sd	s4, 0x30(sp)
40003ac8: f456         	sd	s5, 0x28(sp)
40003aca: f05a         	sd	s6, 0x20(sp)
40003acc: ec5e         	sd	s7, 0x18(sp)
40003ace: e862         	sd	s8, 0x10(sp)
40003ad0: e466         	sd	s9, 0x8(sp)
40003ad2: 3fffd517     	auipc	a0, 0x3fffd
40003ad6: 67650a13     	addi	s4, a0, 0x676
40003ada: 014a4503     	lbu	a0, 0x14(s4)
40003ade: 458d         	li	a1, 0x3
40003ae0: 10b50263     	beq	a0, a1, 0x40003be4 <rpc_dtrace_flush+0x12a>
40003ae4: 4585         	li	a1, 0x1
40003ae6: 0eb50c63     	beq	a0, a1, 0x40003bde <rpc_dtrace_flush+0x124>
40003aea: 1c051563     	bnez	a0, 0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003aee: 090a2503     	lw	a0, 0x90(s4)
40003af2: 10050f63     	beqz	a0, 0x40003c10 <rpc_dtrace_flush+0x156>
40003af6: 074a2483     	lw	s1, 0x74(s4)
40003afa: 084a2503     	lw	a0, 0x84(s4)
40003afe: 069a2c23     	sw	s1, 0x78(s4)
40003b02: 00957663     	bgeu	a0, s1, 0x40003b0e <rpc_dtrace_flush+0x54>
40003b06: 00150493     	addi	s1, a0, 0x1
40003b0a: 069a2c23     	sw	s1, 0x78(s4)
40003b0e: 0804c533     	zext.w	a0, s1
40003b12: 015a4583     	lbu	a1, 0x15(s4)
40003b16: 00b55533     	srl	a0, a0, a1
40003b1a: c96d         	beqz	a0, 0x40003c0c <rpc_dtrace_flush+0x152>
40003b1c: 597d         	li	s2, -0x1
40003b1e: 02095993     	srli	s3, s2, 0x20
40003b22: 2a101413     	bseti	s0, zero, 0x21
40003b26: 1c000513     	li	a0, 0x1c0
40003b2a: 2a151a93     	bseti	s5, a0, 0x21
40003b2e: 098a2503     	lw	a0, 0x98(s4)
40003b32: 00150593     	addi	a1, a0, 0x1
40003b36: 08ba2c23     	sw	a1, 0x98(s4)
40003b3a: 09ca2603     	lw	a2, 0x9c(s4)
40003b3e: 8e69         	and	a2, a2, a0
40003b40: 0a0a3683     	ld	a3, 0xa0(s4)
40003b44: 160a         	slli	a2, a2, 0x22
40003b46: 8271         	srli	a2, a2, 0x1c
40003b48: 9636         	add	a2, a2, a3
40003b4a: 1542         	slli	a0, a0, 0x30
40003b4c: 9121         	srli	a0, a0, 0x28
40003b4e: 2529         	addiw	a0, a0, 0xa
40003b50: 6985551b     	greviw	a0, a0, 0x18
40003b54: c208         	sw	a0, 0x0(a2)
40003b56: 028a6b83     	lwu	s7, 0x28(s4)
40003b5a: 02023503     	ld	a0, 0x20(tp)
40003b5e: 00056b03     	lwu	s6, 0x0(a0)
40003b62: 0805cc3b     	zext.h	s8, a1
40003b66: 013b0663     	beq	s6, s3, 0x40003b72 <rpc_dtrace_flush+0xb8>
40003b6a: 030a6c83     	lwu	s9, 0x30(s4)
40003b6e: 039b1663     	bne	s6, s9, 0x40003b9a <rpc_dtrace_flush+0xe0>
40003b72: 0110000f     	fence	w, w
40003b76: 6008         	ld	a0, 0x0(s0)
40003b78: 8905         	andi	a0, a0, 0x1
40003b7a: fd75         	bnez	a0, 0x40003b76 <rpc_dtrace_flush+0xbc>
40003b7c: 097c4533     	pack	a0, s8, s7
40003b80: 00aab023     	sd	a0, 0x0(s5)
40003b84: 015a4503     	lbu	a0, 0x15(s4)
40003b88: 00a915b3     	sll	a1, s2, a0
40003b8c: 94ae         	add	s1, s1, a1
40003b8e: 0804c5b3     	zext.w	a1, s1
40003b92: 00a5d533     	srl	a0, a1, a0
40003b96: fd41         	bnez	a0, 0x40003b2e <rpc_dtrace_flush+0x74>
40003b98: a895         	j	0x40003c0c <rpc_dtrace_flush+0x152>
40003b9a: 00823583     	ld	a1, 0x8(tp)
40003b9e: 080cc53b     	zext.h	a0, s9
40003ba2: 4895         	li	a7, 0x5
40003ba4: 00000073     	ecall
40003ba8: c509         	beqz	a0, 0x40003bb2 <rpc_dtrace_flush+0xf8>
40003baa: 02023503     	ld	a0, 0x20(tp)
40003bae: 01952023     	sw	s9, 0x0(a0)
40003bb2: 0110000f     	fence	w, w
40003bb6: 6008         	ld	a0, 0x0(s0)
40003bb8: 8905         	andi	a0, a0, 0x1
40003bba: fd75         	bnez	a0, 0x40003bb6 <rpc_dtrace_flush+0xfc>
40003bbc: 097c4533     	pack	a0, s8, s7
40003bc0: 00aab023     	sd	a0, 0x0(s5)
40003bc4: 00823583     	ld	a1, 0x8(tp)
40003bc8: 080b453b     	zext.h	a0, s6
40003bcc: 4895         	li	a7, 0x5
40003bce: 00000073     	ecall
40003bd2: d94d         	beqz	a0, 0x40003b84 <rpc_dtrace_flush+0xca>
40003bd4: 02023503     	ld	a0, 0x20(tp)
40003bd8: 01652023     	sw	s6, 0x0(a0)
40003bdc: b765         	j	0x40003b84 <rpc_dtrace_flush+0xca>
40003bde: 0440000f     	fence	o, o
40003be2: a8c9         	j	0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003be4: 090a2583     	lw	a1, 0x90(s4)
40003be8: 0b0a3503     	ld	a0, 0xb0(s4)
40003bec: c1c5         	beqz	a1, 0x40003c8c <rpc_dtrace_flush+0x1d2>
40003bee: 088a3583     	ld	a1, 0x88(s4)
40003bf2: 074a2603     	lw	a2, 0x74(s4)
40003bf6: 084a2683     	lw	a3, 0x84(s4)
40003bfa: 00c6b733     	sltu	a4, a3, a2
40003bfe: 2685         	addiw	a3, a3, 0x1
40003c00: 177d         	addi	a4, a4, -0x1
40003c02: 40e6f6b3     	andn	a3, a3, a4
40003c06: 8e79         	and	a2, a2, a4
40003c08: 8e55         	or	a2, a2, a3
40003c0a: a055         	j	0x40003cae <rpc_dtrace_flush+0x1f4>
40003c0c: 080a2823     	sw	zero, 0x90(s4)
40003c10: 078a2503     	lw	a0, 0x78(s4)
40003c14: 080a2583     	lw	a1, 0x80(s4)
40003c18: 8d6d         	and	a0, a0, a1
40003c1a: cd49         	beqz	a0, 0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003c1c: 098a2583     	lw	a1, 0x98(s4)
40003c20: 00158413     	addi	s0, a1, 0x1
40003c24: 088a2c23     	sw	s0, 0x98(s4)
40003c28: 09ca2603     	lw	a2, 0x9c(s4)
40003c2c: 8e6d         	and	a2, a2, a1
40003c2e: 0a0a3683     	ld	a3, 0xa0(s4)
40003c32: 160a         	slli	a2, a2, 0x22
40003c34: 8271         	srli	a2, a2, 0x1c
40003c36: 9636         	add	a2, a2, a3
40003c38: 15c2         	slli	a1, a1, 0x30
40003c3a: 91a1         	srli	a1, a1, 0x28
40003c3c: 25a9         	addiw	a1, a1, 0xa
40003c3e: 6985d59b     	greviw	a1, a1, 0x18
40003c42: c20c         	sw	a1, 0x0(a2)
40003c44: 0065151b     	slliw	a0, a0, 0x6
40003c48: 6985551b     	greviw	a0, a0, 0x18
40003c4c: ca08         	sw	a0, 0x10(a2)
40003c4e: 02023503     	ld	a0, 0x20(tp)
40003c52: 00056483     	lwu	s1, 0x0(a0)
40003c56: 557d         	li	a0, -0x1
40003c58: 9101         	srli	a0, a0, 0x20
40003c5a: 028a6903     	lwu	s2, 0x28(s4)
40003c5e: 00a48663     	beq	s1, a0, 0x40003c6a <rpc_dtrace_flush+0x1b0>
40003c62: 030a6983     	lwu	s3, 0x30(s4)
40003c66: 07349563     	bne	s1, s3, 0x40003cd0 <rpc_dtrace_flush+0x216>
40003c6a: 0110000f     	fence	w, w
40003c6e: 2a101513     	bseti	a0, zero, 0x21
40003c72: 610c         	ld	a1, 0x0(a0)
40003c74: 8985         	andi	a1, a1, 0x1
40003c76: fdf5         	bnez	a1, 0x40003c72 <rpc_dtrace_flush+0x1b8>
40003c78: 0804453b     	zext.h	a0, s0
40003c7c: 09254533     	pack	a0, a0, s2
40003c80: 1c000593     	li	a1, 0x1c0
40003c84: 2a159593     	bseti	a1, a1, 0x21
40003c88: e188         	sd	a0, 0x0(a1)
40003c8a: a02d         	j	0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003c8c: 078a2583     	lw	a1, 0x78(s4)
40003c90: 080a2683     	lw	a3, 0x80(s4)
40003c94: 00b6f633     	and	a2, a3, a1
40003c98: ce11         	beqz	a2, 0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003c9a: 084a2703     	lw	a4, 0x84(s4)
40003c9e: 40d776b3     	andn	a3, a4, a3
40003ca2: 8df5         	and	a1, a1, a3
40003ca4: 088a3683     	ld	a3, 0x88(s4)
40003ca8: 1582         	slli	a1, a1, 0x20
40003caa: 81e9         	srli	a1, a1, 0x1a
40003cac: 95b6         	add	a1, a1, a3
40003cae: 0a8a3683     	ld	a3, 0xa8(s4)
40003cb2: 9682         	jalr	a3
40003cb4: 4501         	li	a0, 0x0
40003cb6: 60e6         	ld	ra, 0x58(sp)
40003cb8: 6446         	ld	s0, 0x50(sp)
40003cba: 64a6         	ld	s1, 0x48(sp)
40003cbc: 6906         	ld	s2, 0x40(sp)
40003cbe: 79e2         	ld	s3, 0x38(sp)
40003cc0: 7a42         	ld	s4, 0x30(sp)
40003cc2: 7aa2         	ld	s5, 0x28(sp)
40003cc4: 7b02         	ld	s6, 0x20(sp)
40003cc6: 6be2         	ld	s7, 0x18(sp)
40003cc8: 6c42         	ld	s8, 0x10(sp)
40003cca: 6ca2         	ld	s9, 0x8(sp)
40003ccc: 6125         	addi	sp, sp, 0x60
40003cce: 8082         	ret
40003cd0: 00823583     	ld	a1, 0x8(tp)
40003cd4: 0809c53b     	zext.h	a0, s3
40003cd8: 4895         	li	a7, 0x5
40003cda: 00000073     	ecall
40003cde: c509         	beqz	a0, 0x40003ce8 <rpc_dtrace_flush+0x22e>
40003ce0: 02023503     	ld	a0, 0x20(tp)
40003ce4: 01352023     	sw	s3, 0x0(a0)
40003ce8: 0110000f     	fence	w, w
40003cec: 2a101513     	bseti	a0, zero, 0x21
40003cf0: 610c         	ld	a1, 0x0(a0)
40003cf2: 8985         	andi	a1, a1, 0x1
40003cf4: fdf5         	bnez	a1, 0x40003cf0 <rpc_dtrace_flush+0x236>
40003cf6: 0804453b     	zext.h	a0, s0
40003cfa: 09254533     	pack	a0, a0, s2
40003cfe: 1c000593     	li	a1, 0x1c0
40003d02: 2a159593     	bseti	a1, a1, 0x21
40003d06: e188         	sd	a0, 0x0(a1)
40003d08: 00823583     	ld	a1, 0x8(tp)
40003d0c: 0804c53b     	zext.h	a0, s1
40003d10: 4895         	li	a7, 0x5
40003d12: 00000073     	ecall
40003d16: dd59         	beqz	a0, 0x40003cb4 <rpc_dtrace_flush+0x1fa>
40003d18: 02023503     	ld	a0, 0x20(tp)
40003d1c: c104         	sw	s1, 0x0(a0)
40003d1e: bf59         	j	0x40003cb4 <rpc_dtrace_flush+0x1fa>

0000000040003d20 <rpc_dtrace_release>:
40003d20: 3fffd517     	auipc	a0, 0x3fffd
40003d24: 42850513     	addi	a0, a0, 0x428
40003d28: 410c         	lw	a1, 0x0(a0)
40003d2a: c199         	beqz	a1, 0x40003d30 <rpc_dtrace_release+0x10>
40003d2c: 557d         	li	a0, -0x1
40003d2e: 8082         	ret
40003d30: 1141         	addi	sp, sp, -0x10
40003d32: e406         	sd	ra, 0x8(sp)
40003d34: 0541         	addi	a0, a0, 0x10
40003d36: 0b800613     	li	a2, 0xb8
40003d3a: c4efc0ef     	jal	0x40000188 <memset>
40003d3e: 4501         	li	a0, 0x0
40003d40: 60a2         	ld	ra, 0x8(sp)
40003d42: 0141         	addi	sp, sp, 0x10
40003d44: 8082         	ret

0000000040003d46 <qp_tp_gen>:
40003d46: 3fffd897     	auipc	a7, 0x3fffd
40003d4a: 40288893     	addi	a7, a7, 0x402
40003d4e: 07488293     	addi	t0, a7, 0x74
40003d52: 4305         	li	t1, 0x1
40003d54: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
40003d58: 07c88393     	addi	t2, a7, 0x7c
40003d5c: 0e63a32f     	amoswap.w.aqrl	t1, t1, (t2)
40003d60: 00030363     	beqz	t1, 0x40003d66 <qp_tp_gen+0x20>
40003d64: 8082         	ret
40003d66: 0788a303     	lw	t1, 0x78(a7)
40003d6a: 00130393     	addi	t2, t1, 0x1
40003d6e: 0678ac23     	sw	t2, 0x78(a7)
40003d72: 0848a383     	lw	t2, 0x84(a7)
40003d76: 0063f333     	and	t1, t2, t1
40003d7a: 0888b383     	ld	t2, 0x88(a7)
40003d7e: 02031e13     	slli	t3, t1, 0x20
40003d82: 01ae5e13     	srli	t3, t3, 0x1a
40003d86: 93f2         	add	t2, t2, t3
40003d88: 0053a223     	sw	t0, 0x4(t2)
40003d8c: 02023283     	ld	t0, 0x20(tp)
40003d90: 01c29283     	lh	t0, 0x1c(t0)
40003d94: 00539423     	sh	t0, 0x8(t2)
40003d98: c01022f3     	rdtime	t0
40003d9c: 0103be03     	ld	t3, 0x10(t2)
40003da0: 02c2         	slli	t0, t0, 0x10
40003da2: 1e4e         	slli	t3, t3, 0x33
40003da4: 033e5e13     	srli	t3, t3, 0x33
40003da8: 00a3a023     	sw	a0, 0x0(t2)
40003dac: 15f6         	slli	a1, a1, 0x3d
40003dae: 91c1         	srli	a1, a1, 0x30
40003db0: 00b2e533     	or	a0, t0, a1
40003db4: 00ae6533     	or	a0, t3, a0
40003db8: 00a3b823     	sd	a0, 0x10(t2)
40003dbc: 00c3bc23     	sd	a2, 0x18(t2)
40003dc0: 02d3b023     	sd	a3, 0x20(t2)
40003dc4: 02e3b423     	sd	a4, 0x28(t2)
40003dc8: 02f3b823     	sd	a5, 0x30(t2)
40003dcc: 0808a503     	lw	a0, 0x80(a7)
40003dd0: 40657533     	andn	a0, a0, t1
40003dd4: 0303bc23     	sd	a6, 0x38(t2)
40003dd8: c511         	beqz	a0, 0x40003de4 <qp_tp_gen+0x9e>
40003dda: 0310000f     	fence	rw, w
40003dde: 0608ae23     	sw	zero, 0x7c(a7)
40003de2: 8082         	ret
40003de4: 1141         	addi	sp, sp, -0x10
40003de6: e406         	sd	ra, 0x8(sp)
40003de8: 0988a583     	lw	a1, 0x98(a7)
40003dec: 0015851b     	addiw	a0, a1, 0x1
40003df0: 08a8ac23     	sw	a0, 0x98(a7)
40003df4: 09c8a603     	lw	a2, 0x9c(a7)
40003df8: 8e6d         	and	a2, a2, a1
40003dfa: 0a08b683     	ld	a3, 0xa0(a7)
40003dfe: 160a         	slli	a2, a2, 0x22
40003e00: 8271         	srli	a2, a2, 0x1c
40003e02: 9636         	add	a2, a2, a3
40003e04: 15c2         	slli	a1, a1, 0x30
40003e06: 91a1         	srli	a1, a1, 0x28
40003e08: 25a9         	addiw	a1, a1, 0xa
40003e0a: 6985d59b     	greviw	a1, a1, 0x18
40003e0e: c20c         	sw	a1, 0x0(a2)
40003e10: 0288a583     	lw	a1, 0x28(a7)
40003e14: 0308a603     	lw	a2, 0x30(a7)
40003e18: e046         	sd	a7, 0x0(sp)
40003e1a: 4b2000ef     	jal	0x400042cc <ring_db>
40003e1e: 6882         	ld	a7, 0x0(sp)
40003e20: 60a2         	ld	ra, 0x8(sp)
40003e22: 0141         	addi	sp, sp, 0x10
40003e24: bf5d         	j	0x40003dda <qp_tp_gen+0x94>

0000000040003e26 <qp_tp_ll_gen>:
40003e26: 3fffd897     	auipc	a7, 0x3fffd
40003e2a: 32288893     	addi	a7, a7, 0x322
40003e2e: 07488293     	addi	t0, a7, 0x74
40003e32: 4305         	li	t1, 0x1
40003e34: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
40003e38: 0848a303     	lw	t1, 0x84(a7)
40003e3c: 04536e63     	bltu	t1, t0, 0x40003e98 <qp_tp_ll_gen+0x72>
40003e40: 0888b883     	ld	a7, 0x88(a7)
40003e44: 02029313     	slli	t1, t0, 0x20
40003e48: 01a35313     	srli	t1, t1, 0x1a
40003e4c: 989a         	add	a7, a7, t1
40003e4e: 0058a223     	sw	t0, 0x4(a7)
40003e52: 02023283     	ld	t0, 0x20(tp)
40003e56: 01c29283     	lh	t0, 0x1c(t0)
40003e5a: 00589423     	sh	t0, 0x8(a7)
40003e5e: c01022f3     	rdtime	t0
40003e62: 0108b303     	ld	t1, 0x10(a7)
40003e66: 02c2         	slli	t0, t0, 0x10
40003e68: 134e         	slli	t1, t1, 0x33
40003e6a: 03335313     	srli	t1, t1, 0x33
40003e6e: 00a8a023     	sw	a0, 0x0(a7)
40003e72: 15f6         	slli	a1, a1, 0x3d
40003e74: 91c1         	srli	a1, a1, 0x30
40003e76: 00b2e533     	or	a0, t0, a1
40003e7a: 00a36533     	or	a0, t1, a0
40003e7e: 00a8b823     	sd	a0, 0x10(a7)
40003e82: 00c8bc23     	sd	a2, 0x18(a7)
40003e86: 02d8b023     	sd	a3, 0x20(a7)
40003e8a: 02e8b423     	sd	a4, 0x28(a7)
40003e8e: 02f8b823     	sd	a5, 0x30(a7)
40003e92: 0308bc23     	sd	a6, 0x38(a7)
40003e96: 8082         	ret
40003e98: 0310000f     	fence	rw, w
40003e9c: 0008a023     	sw	zero, 0x0(a7)
40003ea0: 8082         	ret

0000000040003ea2 <silly_flush_qp>:
40003ea2: 7179         	addi	sp, sp, -0x30
40003ea4: f422         	sd	s0, 0x28(sp)
40003ea6: f026         	sd	s1, 0x20(sp)
40003ea8: ec4a         	sd	s2, 0x18(sp)
40003eaa: e84e         	sd	s3, 0x10(sp)
40003eac: e452         	sd	s4, 0x8(sp)
40003eae: 3fffd517     	auipc	a0, 0x3fffd
40003eb2: 29a50413     	addi	s0, a0, 0x29a
40003eb6: 07c40513     	addi	a0, s0, 0x7c
40003eba: 4585         	li	a1, 0x1
40003ebc: 0eb5262f     	amoswap.w.aqrl	a2, a1, (a0)
40003ec0: fe75         	bnez	a2, 0x40003ebc <silly_flush_qp+0x1a>
40003ec2: 5c28         	lw	a0, 0x78(s0)
40003ec4: 08042583     	lw	a1, 0x80(s0)
40003ec8: 8d6d         	and	a0, a0, a1
40003eca: c151         	beqz	a0, 0x40003f4e <silly_flush_qp+0xac>
40003ecc: 09842583     	lw	a1, 0x98(s0)
40003ed0: 00158493     	addi	s1, a1, 0x1
40003ed4: 08942c23     	sw	s1, 0x98(s0)
40003ed8: 09c42603     	lw	a2, 0x9c(s0)
40003edc: 8e6d         	and	a2, a2, a1
40003ede: 7054         	ld	a3, 0xa0(s0)
40003ee0: 160a         	slli	a2, a2, 0x22
40003ee2: 8271         	srli	a2, a2, 0x1c
40003ee4: 9636         	add	a2, a2, a3
40003ee6: 15c2         	slli	a1, a1, 0x30
40003ee8: 91a1         	srli	a1, a1, 0x28
40003eea: 25a9         	addiw	a1, a1, 0xa
40003eec: 6985d59b     	greviw	a1, a1, 0x18
40003ef0: c20c         	sw	a1, 0x0(a2)
40003ef2: 0065151b     	slliw	a0, a0, 0x6
40003ef6: 6985551b     	greviw	a0, a0, 0x18
40003efa: ca08         	sw	a0, 0x10(a2)
40003efc: 02023503     	ld	a0, 0x20(tp)
40003f00: 00056903     	lwu	s2, 0x0(a0)
40003f04: 557d         	li	a0, -0x1
40003f06: 9101         	srli	a0, a0, 0x20
40003f08: 02846983     	lwu	s3, 0x28(s0)
40003f0c: 00a90663     	beq	s2, a0, 0x40003f18 <silly_flush_qp+0x76>
40003f10: 03046a03     	lwu	s4, 0x30(s0)
40003f14: 05491863     	bne	s2, s4, 0x40003f64 <silly_flush_qp+0xc2>
40003f18: 0110000f     	fence	w, w
40003f1c: 2a101513     	bseti	a0, zero, 0x21
40003f20: 610c         	ld	a1, 0x0(a0)
40003f22: 8985         	andi	a1, a1, 0x1
40003f24: fdf5         	bnez	a1, 0x40003f20 <silly_flush_qp+0x7e>
40003f26: 0804c53b     	zext.h	a0, s1
40003f2a: 09354533     	pack	a0, a0, s3
40003f2e: 1c000593     	li	a1, 0x1c0
40003f32: 2a159593     	bseti	a1, a1, 0x21
40003f36: e188         	sd	a0, 0x0(a1)
40003f38: 08042583     	lw	a1, 0x80(s0)
40003f3c: 5c28         	lw	a0, 0x78(s0)
40003f3e: 00a5f633     	and	a2, a1, a0
40003f42: c611         	beqz	a2, 0x40003f4e <silly_flush_qp+0xac>
40003f44: 2505         	addiw	a0, a0, 0x1
40003f46: 00a5f633     	and	a2, a1, a0
40003f4a: fe6d         	bnez	a2, 0x40003f44 <silly_flush_qp+0xa2>
40003f4c: dc28         	sw	a0, 0x78(s0)
40003f4e: 0310000f     	fence	rw, w
40003f52: 06042e23     	sw	zero, 0x7c(s0)
40003f56: 7422         	ld	s0, 0x28(sp)
40003f58: 7482         	ld	s1, 0x20(sp)
40003f5a: 6962         	ld	s2, 0x18(sp)
40003f5c: 69c2         	ld	s3, 0x10(sp)
40003f5e: 6a22         	ld	s4, 0x8(sp)
40003f60: 6145         	addi	sp, sp, 0x30
40003f62: 8082         	ret
40003f64: 00823583     	ld	a1, 0x8(tp)
40003f68: 080a453b     	zext.h	a0, s4
40003f6c: 4895         	li	a7, 0x5
40003f6e: 00000073     	ecall
40003f72: c509         	beqz	a0, 0x40003f7c <silly_flush_qp+0xda>
40003f74: 02023503     	ld	a0, 0x20(tp)
40003f78: 01452023     	sw	s4, 0x0(a0)
40003f7c: 0110000f     	fence	w, w
40003f80: 2a101513     	bseti	a0, zero, 0x21
40003f84: 610c         	ld	a1, 0x0(a0)
40003f86: 8985         	andi	a1, a1, 0x1
40003f88: fdf5         	bnez	a1, 0x40003f84 <silly_flush_qp+0xe2>
40003f8a: 0804c53b     	zext.h	a0, s1
40003f8e: 09354533     	pack	a0, a0, s3
40003f92: 1c000593     	li	a1, 0x1c0
40003f96: 2a159593     	bseti	a1, a1, 0x21
40003f9a: e188         	sd	a0, 0x0(a1)
40003f9c: 00823583     	ld	a1, 0x8(tp)
40003fa0: 0809453b     	zext.h	a0, s2
40003fa4: 4895         	li	a7, 0x5
40003fa6: 00000073     	ecall
40003faa: d559         	beqz	a0, 0x40003f38 <silly_flush_qp+0x96>
40003fac: 02023503     	ld	a0, 0x20(tp)
40003fb0: 01252023     	sw	s2, 0x0(a0)
40003fb4: b751         	j	0x40003f38 <silly_flush_qp+0x96>

0000000040003fb6 <win_tp_gen>:
40003fb6: 3fffd897     	auipc	a7, 0x3fffd
40003fba: 19288893     	addi	a7, a7, 0x192
40003fbe: 07488293     	addi	t0, a7, 0x74
40003fc2: 4305         	li	t1, 0x1
40003fc4: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
40003fc8: 07c88393     	addi	t2, a7, 0x7c
40003fcc: 0e63a32f     	amoswap.w.aqrl	t1, t1, (t2)
40003fd0: 00030363     	beqz	t1, 0x40003fd6 <win_tp_gen+0x20>
40003fd4: 8082         	ret
40003fd6: 0188a303     	lw	t1, 0x18(a7)
40003fda: 0cc0000f     	fence	io, io
40003fde: 200013b7     	lui	t2, 0x20001
40003fe2: 0392         	slli	t2, t2, 0x4
40003fe4: 0063a023     	sw	t1, 0x0(t2)
40003fe8: 0cc0000f     	fence	io, io
40003fec: 02023383     	ld	t2, 0x20(tp)
40003ff0: 0063a623     	sw	t1, 0xc(t2)
40003ff4: 0788e303     	lwu	t1, 0x78(a7)
40003ff8: 00130393     	addi	t2, t1, 0x1
40003ffc: 0678ac23     	sw	t2, 0x78(a7)
40004000: 0848e383     	lwu	t2, 0x84(a7)
40004004: 0063f333     	and	t1, t2, t1
40004008: 0888b383     	ld	t2, 0x88(a7)
4000400c: 031a         	slli	t1, t1, 0x6
4000400e: 931e         	add	t1, t1, t2
40004010: 02023383     	ld	t2, 0x20(tp)
40004014: 01c39383     	lh	t2, 0x1c(t2)
40004018: 00731423     	sh	t2, 0x8(t1)
4000401c: c01023f3     	rdtime	t2
40004020: 01033e03     	ld	t3, 0x10(t1)
40004024: 03c2         	slli	t2, t2, 0x10
40004026: 1e4e         	slli	t3, t3, 0x33
40004028: 033e5e13     	srli	t3, t3, 0x33
4000402c: 00a32023     	sw	a0, 0x0(t1)
40004030: 15f6         	slli	a1, a1, 0x3d
40004032: 91c1         	srli	a1, a1, 0x30
40004034: 00b3e533     	or	a0, t2, a1
40004038: 00ae6533     	or	a0, t3, a0
4000403c: 00a33823     	sd	a0, 0x10(t1)
40004040: 00c33c23     	sd	a2, 0x18(t1)
40004044: 02d33023     	sd	a3, 0x20(t1)
40004048: 02e33423     	sd	a4, 0x28(t1)
4000404c: 02f33823     	sd	a5, 0x30(t1)
40004050: 03033c23     	sd	a6, 0x38(t1)
40004054: 00532223     	sw	t0, 0x4(t1)
40004058: 0310000f     	fence	rw, w
4000405c: 0608ae23     	sw	zero, 0x7c(a7)
40004060: 8082         	ret

0000000040004062 <win_tp_ll_gen>:
40004062: 3fffd897     	auipc	a7, 0x3fffd
40004066: 0e688893     	addi	a7, a7, 0xe6
4000406a: 07488293     	addi	t0, a7, 0x74
4000406e: 4305         	li	t1, 0x1
40004070: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
40004074: 0848a303     	lw	t1, 0x84(a7)
40004078: 06536d63     	bltu	t1, t0, 0x400040f2 <win_tp_ll_gen+0x90>
4000407c: 0188a303     	lw	t1, 0x18(a7)
40004080: 0cc0000f     	fence	io, io
40004084: 200013b7     	lui	t2, 0x20001
40004088: 0392         	slli	t2, t2, 0x4
4000408a: 0063a023     	sw	t1, 0x0(t2)
4000408e: 0cc0000f     	fence	io, io
40004092: 02023383     	ld	t2, 0x20(tp)
40004096: 0063a623     	sw	t1, 0xc(t2)
4000409a: 0888b883     	ld	a7, 0x88(a7)
4000409e: 02029313     	slli	t1, t0, 0x20
400040a2: 01a35313     	srli	t1, t1, 0x1a
400040a6: 989a         	add	a7, a7, t1
400040a8: 0058a223     	sw	t0, 0x4(a7)
400040ac: 02023283     	ld	t0, 0x20(tp)
400040b0: 01c29283     	lh	t0, 0x1c(t0)
400040b4: 00589423     	sh	t0, 0x8(a7)
400040b8: c01022f3     	rdtime	t0
400040bc: 0108b303     	ld	t1, 0x10(a7)
400040c0: 02c2         	slli	t0, t0, 0x10
400040c2: 134e         	slli	t1, t1, 0x33
400040c4: 03335313     	srli	t1, t1, 0x33
400040c8: 00a8a023     	sw	a0, 0x0(a7)
400040cc: 15f6         	slli	a1, a1, 0x3d
400040ce: 91c1         	srli	a1, a1, 0x30
400040d0: 00b2e533     	or	a0, t0, a1
400040d4: 00a36533     	or	a0, t1, a0
400040d8: 00a8b823     	sd	a0, 0x10(a7)
400040dc: 00c8bc23     	sd	a2, 0x18(a7)
400040e0: 02d8b023     	sd	a3, 0x20(a7)
400040e4: 02e8b423     	sd	a4, 0x28(a7)
400040e8: 02f8b823     	sd	a5, 0x30(a7)
400040ec: 0308bc23     	sd	a6, 0x38(a7)
400040f0: 8082         	ret
400040f2: 0310000f     	fence	rw, w
400040f6: 0008a023     	sw	zero, 0x0(a7)
400040fa: 8082         	ret

00000000400040fc <dbuf_tp_gen>:
400040fc: 3fffd897     	auipc	a7, 0x3fffd
40004100: 04c88893     	addi	a7, a7, 0x4c
40004104: 07488293     	addi	t0, a7, 0x74
40004108: 4305         	li	t1, 0x1
4000410a: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
4000410e: 07c88393     	addi	t2, a7, 0x7c
40004112: 0e63a32f     	amoswap.w.aqrl	t1, t1, (t2)
40004116: 00030363     	beqz	t1, 0x4000411c <dbuf_tp_gen+0x20>
4000411a: 8082         	ret
4000411c: 0788e303     	lwu	t1, 0x78(a7)
40004120: 00130393     	addi	t2, t1, 0x1
40004124: 0678ac23     	sw	t2, 0x78(a7)
40004128: 0848e383     	lwu	t2, 0x84(a7)
4000412c: 0063f333     	and	t1, t2, t1
40004130: 0888b383     	ld	t2, 0x88(a7)
40004134: 031a         	slli	t1, t1, 0x6
40004136: 931e         	add	t1, t1, t2
40004138: 02023383     	ld	t2, 0x20(tp)
4000413c: 01c39383     	lh	t2, 0x1c(t2)
40004140: 00731423     	sh	t2, 0x8(t1)
40004144: c01023f3     	rdtime	t2
40004148: 01033e03     	ld	t3, 0x10(t1)
4000414c: 03c2         	slli	t2, t2, 0x10
4000414e: 1e4e         	slli	t3, t3, 0x33
40004150: 033e5e13     	srli	t3, t3, 0x33
40004154: 00a32023     	sw	a0, 0x0(t1)
40004158: 15f6         	slli	a1, a1, 0x3d
4000415a: 91c1         	srli	a1, a1, 0x30
4000415c: 00b3e533     	or	a0, t2, a1
40004160: 00ae6533     	or	a0, t3, a0
40004164: 00a33823     	sd	a0, 0x10(t1)
40004168: 00c33c23     	sd	a2, 0x18(t1)
4000416c: 02d33023     	sd	a3, 0x20(t1)
40004170: 02e33423     	sd	a4, 0x28(t1)
40004174: 02f33823     	sd	a5, 0x30(t1)
40004178: 03033c23     	sd	a6, 0x38(t1)
4000417c: 00532223     	sw	t0, 0x4(t1)
40004180: 0310000f     	fence	rw, w
40004184: 0608ae23     	sw	zero, 0x7c(a7)
40004188: 8082         	ret

000000004000418a <dbuf_tp_ll_gen>:
4000418a: 3fffd897     	auipc	a7, 0x3fffd
4000418e: fbe88893     	addi	a7, a7, -0x42
40004192: 07488293     	addi	t0, a7, 0x74
40004196: 4305         	li	t1, 0x1
40004198: 0662a2af     	amoadd.w.aqrl	t0, t1, (t0)
4000419c: 0848a303     	lw	t1, 0x84(a7)
400041a0: 04536e63     	bltu	t1, t0, 0x400041fc <dbuf_tp_ll_gen+0x72>
400041a4: 0888b883     	ld	a7, 0x88(a7)
400041a8: 02029313     	slli	t1, t0, 0x20
400041ac: 01a35313     	srli	t1, t1, 0x1a
400041b0: 989a         	add	a7, a7, t1
400041b2: 0058a223     	sw	t0, 0x4(a7)
400041b6: 02023283     	ld	t0, 0x20(tp)
400041ba: 01c29283     	lh	t0, 0x1c(t0)
400041be: 00589423     	sh	t0, 0x8(a7)
400041c2: c01022f3     	rdtime	t0
400041c6: 0108b303     	ld	t1, 0x10(a7)
400041ca: 02c2         	slli	t0, t0, 0x10
400041cc: 134e         	slli	t1, t1, 0x33
400041ce: 03335313     	srli	t1, t1, 0x33
400041d2: 00a8a023     	sw	a0, 0x0(a7)
400041d6: 15f6         	slli	a1, a1, 0x3d
400041d8: 91c1         	srli	a1, a1, 0x30
400041da: 00b2e533     	or	a0, t0, a1
400041de: 00a36533     	or	a0, t1, a0
400041e2: 00a8b823     	sd	a0, 0x10(a7)
400041e6: 00c8bc23     	sd	a2, 0x18(a7)
400041ea: 02d8b023     	sd	a3, 0x20(a7)
400041ee: 02e8b423     	sd	a4, 0x28(a7)
400041f2: 02f8b823     	sd	a5, 0x30(a7)
400041f6: 0308bc23     	sd	a6, 0x38(a7)
400041fa: 8082         	ret
400041fc: 0310000f     	fence	rw, w
40004200: 0008a023     	sw	zero, 0x0(a7)
40004204: 8082         	ret

0000000040004206 <umem_tp_gen>:
40004206: 3fffd897     	auipc	a7, 0x3fffd
4000420a: f4288893     	addi	a7, a7, -0xbe
4000420e: 07488293     	addi	t0, a7, 0x74
40004212: 4385         	li	t2, 0x1
40004214: 0672a32f     	amoadd.w.aqrl	t1, t2, (t0)
40004218: 07c88293     	addi	t0, a7, 0x7c
4000421c: 0e72a2af     	amoswap.w.aqrl	t0, t2, (t0)
40004220: 00028363     	beqz	t0, 0x40004226 <umem_tp_gen+0x20>
40004224: 8082         	ret
40004226: 0788a283     	lw	t0, 0x78(a7)
4000422a: 00128393     	addi	t2, t0, 0x1
4000422e: 0678ac23     	sw	t2, 0x78(a7)
40004232: 0848a383     	lw	t2, 0x84(a7)
40004236: 0053f2b3     	and	t0, t2, t0
4000423a: 0888b383     	ld	t2, 0x88(a7)
4000423e: 02029e13     	slli	t3, t0, 0x20
40004242: 01ae5e13     	srli	t3, t3, 0x1a
40004246: 93f2         	add	t2, t2, t3
40004248: 0063a223     	sw	t1, 0x4(t2)
4000424c: 02023303     	ld	t1, 0x20(tp)
40004250: 01c31303     	lh	t1, 0x1c(t1)
40004254: 00639423     	sh	t1, 0x8(t2)
40004258: c0102373     	rdtime	t1
4000425c: 0103be03     	ld	t3, 0x10(t2)
40004260: 0342         	slli	t1, t1, 0x10
40004262: 1e4e         	slli	t3, t3, 0x33
40004264: 033e5e13     	srli	t3, t3, 0x33
40004268: 00a3a023     	sw	a0, 0x0(t2)
4000426c: 15f6         	slli	a1, a1, 0x3d
4000426e: 91c1         	srli	a1, a1, 0x30
40004270: 00b36533     	or	a0, t1, a1
40004274: 00ae6533     	or	a0, t3, a0
40004278: 00a3b823     	sd	a0, 0x10(t2)
4000427c: 00c3bc23     	sd	a2, 0x18(t2)
40004280: 02d3b023     	sd	a3, 0x20(t2)
40004284: 02e3b423     	sd	a4, 0x28(t2)
40004288: 02f3b823     	sd	a5, 0x30(t2)
4000428c: 0808a603     	lw	a2, 0x80(a7)
40004290: 40567533     	andn	a0, a2, t0
40004294: 0303bc23     	sd	a6, 0x38(t2)
40004298: c511         	beqz	a0, 0x400042a4 <umem_tp_gen+0x9e>
4000429a: 0310000f     	fence	rw, w
4000429e: 0608ae23     	sw	zero, 0x7c(a7)
400042a2: 8082         	ret
400042a4: 1141         	addi	sp, sp, -0x10
400042a6: e406         	sd	ra, 0x8(sp)
400042a8: 0888b583     	ld	a1, 0x88(a7)
400042ac: 40c2f533     	andn	a0, t0, a2
400042b0: 1502         	slli	a0, a0, 0x20
400042b2: 8169         	srli	a0, a0, 0x1a
400042b4: 95aa         	add	a1, a1, a0
400042b6: 0a88b683     	ld	a3, 0xa8(a7)
400042ba: 0b08b503     	ld	a0, 0xb0(a7)
400042be: 2605         	addiw	a2, a2, 0x1
400042c0: e046         	sd	a7, 0x0(sp)
400042c2: 9682         	jalr	a3
400042c4: 6882         	ld	a7, 0x0(sp)
400042c6: 60a2         	ld	ra, 0x8(sp)
400042c8: 0141         	addi	sp, sp, 0x10
400042ca: bfc1         	j	0x4000429a <umem_tp_gen+0x94>

00000000400042cc <ring_db>:
400042cc: 1101         	addi	sp, sp, -0x20
400042ce: ec22         	sd	s0, 0x18(sp)
400042d0: e826         	sd	s1, 0x10(sp)
400042d2: e44a         	sd	s2, 0x8(sp)
400042d4: e04e         	sd	s3, 0x0(sp)
400042d6: 02023683     	ld	a3, 0x20(tp)
400042da: 0006e403     	lwu	s0, 0x0(a3)
400042de: 56fd         	li	a3, -0x1
400042e0: 9281         	srli	a3, a3, 0x20
400042e2: 00d40663     	beq	s0, a3, 0x400042ee <ring_db+0x22>
400042e6: 0004069b     	sext.w	a3, s0
400042ea: 02c69863     	bne	a3, a2, 0x4000431a <ring_db+0x4e>
400042ee: 0110000f     	fence	w, w
400042f2: 2a101613     	bseti	a2, zero, 0x21
400042f6: 6214         	ld	a3, 0x0(a2)
400042f8: 8a85         	andi	a3, a3, 0x1
400042fa: fef5         	bnez	a3, 0x400042f6 <ring_db+0x2a>
400042fc: 0805453b     	zext.h	a0, a0
40004300: 08b54533     	pack	a0, a0, a1
40004304: 1c000593     	li	a1, 0x1c0
40004308: 2a159593     	bseti	a1, a1, 0x21
4000430c: e188         	sd	a0, 0x0(a1)
4000430e: 6462         	ld	s0, 0x18(sp)
40004310: 64c2         	ld	s1, 0x10(sp)
40004312: 6922         	ld	s2, 0x8(sp)
40004314: 6982         	ld	s3, 0x0(sp)
40004316: 6105         	addi	sp, sp, 0x20
40004318: 8082         	ret
4000431a: 892a         	mv	s2, a0
4000431c: 89ae         	mv	s3, a1
4000431e: 00823583     	ld	a1, 0x8(tp)
40004322: 84b2         	mv	s1, a2
40004324: 0806453b     	zext.h	a0, a2
40004328: 4895         	li	a7, 0x5
4000432a: 00000073     	ecall
4000432e: c501         	beqz	a0, 0x40004336 <ring_db+0x6a>
40004330: 02023503     	ld	a0, 0x20(tp)
40004334: c104         	sw	s1, 0x0(a0)
40004336: 0110000f     	fence	w, w
4000433a: 2a101513     	bseti	a0, zero, 0x21
4000433e: 610c         	ld	a1, 0x0(a0)
40004340: 8985         	andi	a1, a1, 0x1
40004342: fdf5         	bnez	a1, 0x4000433e <ring_db+0x72>
40004344: 0809453b     	zext.h	a0, s2
40004348: 09354533     	pack	a0, a0, s3
4000434c: 1c000593     	li	a1, 0x1c0
40004350: 2a159593     	bseti	a1, a1, 0x21
40004354: e188         	sd	a0, 0x0(a1)
40004356: 00823583     	ld	a1, 0x8(tp)
4000435a: 0804453b     	zext.h	a0, s0
4000435e: 4895         	li	a7, 0x5
40004360: 00000073     	ecall
40004364: d54d         	beqz	a0, 0x4000430e <ring_db+0x42>
40004366: 02023503     	ld	a0, 0x20(tp)
4000436a: c100         	sw	s0, 0x0(a0)
4000436c: b74d         	j	0x4000430e <ring_db+0x42>

000000004000436e <_dpacc_flexio_dev_arg_unpack_rpc_dtrace_flush>:
4000436e: 6108         	ld	a0, 0x0(a0)
40004370: 8582         	jr	a1

0000000040004372 <_dpacc_flexio_dev_arg_unpack_rpc_dtrace_init>:
40004372: 6108         	ld	a0, 0x0(a0)
40004374: 8582         	jr	a1

0000000040004376 <_dpacc_flexio_dev_arg_unpack_rpc_dtrace_release>:
40004376: 6108         	ld	a0, 0x0(a0)
40004378: 8582         	jr	a1

000000004000437a <_dpacc_flexio_dev_arg_unpack_rpc_dtrace_start>:
4000437a: 6108         	ld	a0, 0x0(a0)
4000437c: 8582         	jr	a1

000000004000437e <_dpacc_flexio_dev_arg_unpack_rpc_dtrace_stop>:
4000437e: 6108         	ld	a0, 0x0(a0)
40004380: 8582         	jr	a1

0000000040004382 <flexio_dev_simx_print_putc>:
40004382: 8082         	ret

0000000040004384 <flexio_dev_send_en_ctrl_set>:
40004384: 4629         	li	a2, 0xa
40004386: c110         	sw	a2, 0x0(a0)
40004388: 450d         	li	a0, 0x3
4000438a: c188         	sw	a0, 0x0(a1)
4000438c: 8082         	ret

000000004000438e <rpc_debug_buf_set>:
4000438e: 1141         	addi	sp, sp, -0x10
40004390: e406         	sd	ra, 0x8(sp)
40004392: 4685         	li	a3, 0x1
40004394: 00d51c63     	bne	a0, a3, 0x400043ac <rpc_debug_buf_set+0x1e>
40004398: 00001517     	auipc	a0, 0x1
4000439c: aa550613     	addi	a2, a0, -0x55b
400043a0: 4591         	li	a1, 0x4
400043a2: 4501         	li	a0, 0x0
400043a4: 8d8fe0ef     	jal	0x4000247c <flexio_dev_msg>
400043a8: 557d         	li	a0, -0x1
400043aa: a035         	j	0x400043d6 <rpc_debug_buf_set+0x48>
400043ac: 0015b513     	seqz	a0, a1
400043b0: 3fffc697     	auipc	a3, 0x3fffc
400043b4: c5068693     	addi	a3, a3, -0x3b0
400043b8: fff50713     	addi	a4, a0, -0x1
400043bc: 40e6f533     	andn	a0, a3, a4
400043c0: 8df9         	and	a1, a1, a4
400043c2: 8d4d         	or	a0, a0, a1
400043c4: fc060593     	addi	a1, a2, -0x40
400043c8: 8df9         	and	a1, a1, a4
400043ca: 04058593     	addi	a1, a1, 0x40
400043ce: 00000097     	auipc	ra, 0x0
400043d2: 036080e7     	jalr	0x36(ra) <__ebreak>
400043d6: 60a2         	ld	ra, 0x8(sp)
400043d8: 0141         	addi	sp, sp, 0x10
400043da: 8082         	ret

00000000400043dc <_dpacc_flexio_dev_arg_unpack_rpc_debug_buf_set>:
400043dc: 6118         	ld	a4, 0x0(a0)
400043de: 6514         	ld	a3, 0x8(a0)
400043e0: 6910         	ld	a2, 0x10(a0)
400043e2: 87ae         	mv	a5, a1
400043e4: 853a         	mv	a0, a4
400043e6: 85b6         	mv	a1, a3
400043e8: 8782         	jr	a5

00000000400043ea <flexio_hal_outbox_write_cq_db>:
400043ea: 2a101613     	bseti	a2, zero, 0x21
400043ee: 6214         	ld	a3, 0x0(a2)
400043f0: 8a85         	andi	a3, a3, 0x1
400043f2: fef5         	bnez	a3, 0x400043ee <flexio_hal_outbox_write_cq_db+0x4>
400043f4: 08a5c533     	pack	a0, a1, a0
400043f8: 10000593     	li	a1, 0x100
400043fc: 2a159593     	bseti	a1, a1, 0x21
40004400: e188         	sd	a0, 0x0(a1)
40004402: 8082         	ret

0000000040004404 <__ebreak>:
40004404: 00100073     	ebreak
