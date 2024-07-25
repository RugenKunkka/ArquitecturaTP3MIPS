Label1:	
	ori	r1 , r18 , 1
	ori	r2 , r18 , 2
	ori	r3 , r18 , 3
	ori	r4 , r18 , 4
	ori	r5 , r18 , 5
	bne r1 , r2 , Label3 //salta
	ori r6, r18, 6
	ori r7, r18, 7
	ori r8, r18, 8
	ori r9, r18, 9
	ori r10, r18, 10
Label3:		
	ori r11, r18, 11
	ori r12, r18, 11
	ori r13, r18, 13
	ori r14 , r18, 14
	ori r15 , r18, 15
	bne r11 , r12 , Label2 //no salta
	ori r16 , r18, 16
	ori r17 , r18, 17
	ori r19 , r18, 19
	ori r20 , r18, 20
Label2:
	ori r21 , r18, 21
	halt
// Reg1: 00000001  Reg2: 00000002
// Reg3: 00000003  Reg4: 00000004  Reg5: 00000005  Reg6: 00000000
// Reg7: 00000007  Reg8: 00000000  Reg9: 00000000  Reg10: 00000000
// Reg11: 0000000B  Reg12: 0000000B  Reg13: 0000000D  Reg14: 0000000E
// Reg15: 0000000F  Reg16: 00000010  Reg17: 00000011  Reg18: 00000000
// Reg19: 00000013  Reg20: 00000014   Reg21: 00000015