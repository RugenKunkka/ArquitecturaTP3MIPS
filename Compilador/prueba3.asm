// prueba3.asm
// Probar ADDU, SUBU, AND, OR, XOR, SLT, SLL, SRL, SRA, SLLV, SRLV, SRAV
// SIN RIESGOS.
// Aritmetico:	duplica valores
// Logico:		rellena con ceros
// 13 instrucciones + 4 ciclos llenado del pipe => PC: 11(HEX) 17(DEC)
ori 13 , 5, 1
ori 14 , 6, 2
ori 15 , 7, 3
ori 16 , 8, 4
ori 17 , 8, 5
ori 18 , 8, 6
ori 19 , 8, 7
ori 20 , 8, 8
ori 21 , 8, 9
ori 22 , 8, 10
ori 23 , 8, 11
ori 24 , 8, 12
addu 1 , 13, 14		// 1+2=3
subu 2 , 16, 15		// 4-3=1
and  3 , 17, 18		// 5 & 6= 100 = 4 en hexa
or   4 , 19, 20		// 7 | 8 = 1111 = F
xor  5 , 21, 22		//  9 xor 10 = 0011 = 3
slt  6 , 23, 24		//  slt 11 12 = 1 
halt		
