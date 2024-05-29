// prueba5.asm
// Probar instrucciones de salto condicional (inmediato): 
// BEQ, BNE
// SIN RIESGOS

Label2:
	addi 	r1, r15, 7          //PC = 0	1F(r1) 	  
	addi 	r14, r16, 16        //PC = 1	20(r14) N.F 
	addi 	r15, r17, 16        //PC = 2	21(r15) N.F 
	addi 	r18, r19, 16        //PC = 3	23(r18)  
	beq 	r1, r22, Label1     //PC = 4  	
	addi 	r3, r10, 16	        //PC = 5    N.E
	addi 	r4, r11, 16	        //PC = 6    N.E
	addi 	r5, r12, 16         //          N.E
	addi 	r6, r13, 16         //          N.E
Label1:	
	addi 	r7, r14, 100        //PC = 10   r7 = 84
	addi 	r8, r9, 1           //          r8 = 0a
	bne 	r1, r22, Label2
	addi 	r14, r16, 1         //          N.E
	addi 	r15, r17, 1         //          N.E
	halt


//	bne 	$s, $t, Label2		//
