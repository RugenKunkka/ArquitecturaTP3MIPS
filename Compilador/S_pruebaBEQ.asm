Label1:	
	ori	r1 , r18 , 1
	ori	r2 , r18 , 1
	ori	r3 , r18 , 3
	ori	r4 , r18 , 4
	ori	r5 , r18 , 5
	beq r1 , r2 , Label3
	ori r6, r18, 6
	ori r7, r18, 7
	ori r8, r18, 8
	ori r9, r18, 9
	ori r10, r18, 10
Label3:		
	ori r11, r18, 11
	ori r12, r18, 12
	ori r13, r18, 13
	ori r14 , r18, 14
	ori r15 , r18, 15
	beq r11 , r12 , Label2
	ori r16 , r18, 16
	ori r17 , r18, 17
	ori r19 , r18, 19
	ori r20 , r18, 20
Label2:
	ori r21 , r18, 21
	halt
