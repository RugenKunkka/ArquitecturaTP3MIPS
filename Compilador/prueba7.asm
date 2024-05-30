// prueba6.asm
// Probar: J, JAL
// SIN RIESGOS

// J    = Salto incondicional
// JAL  = 

// Aca la prueba es ver que 5,6,7,8 quedaron intactos!!!!!!

Label1:	
	ori	r1 , r10 , 1
	ori	r2 , r11 , 2
	addi 	r3 , r12, 3 //PC = 0	r01 = 2
	addi 	r4 , r13, 4 //PC = 4	r02 = 2
	addi 	r5 , r14, 5 //PC = 8	r03 = 2
	addi 	r6 , r15, 6 //PC = 8	r03 = 2
	jal		Label3
	and     r1 , r2, 0 // No se deberia ejecutar XXXX 2(que es r2)*0=0
	andi 	r3 , r4, 0 // No se deberia ejecutar
	andi 	r5 , r6, 0 // No se deberia ejecutar
Label3:		
	ori     r10, r1, 3
	ori     r11, r2, 3
	ori     r12, r3, 3
	j		Label2
	ori     r13, r4, 3//no se deberian de ejecutar estas ori
	ori     r14, r5, 3
	ori     r15, r6, 3
	ori     r15, r7, 3
Label2:
	addi 	r20 , r1, 1
	addi 	r21 , r2, 1
	addi 	r22 , r3, 1
	addi 	r23 , r4, 1
	halt
