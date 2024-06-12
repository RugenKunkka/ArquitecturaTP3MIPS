// prueba2.asm
// Probar instrucciones I-Type
// ADDI ANDI ORI XORI SLTI, LUI
// SIN RIESGOS

// TODO
addi 1, 2 , 1		// r1=1
andi 3, 4 , 1 		// r3=1
ori  5, 6 , 1 		// 7(r5 )  = 6 OR  1 #7
xori 7, 8 , 1 		// 9(r7 )  = 7 XOR 1 #8
SLTI 9, 10, 1 		// 0(r9 )  = A  <  1 
SLTI 11, 12, 100 	// r11 = 0001
lui  13, 1			// 1 << 16 = 10000 
halt  
