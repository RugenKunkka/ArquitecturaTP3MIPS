// prueba6.asm
// Probar: J, JAL
// SIN RIESGOS

// J    = Salto incondicional
// JAL  = 

// Aca la prueba es ver que 5,6,7,8 quedaron intactos!!!!!!

Label1:	
	addi 	r1 , r15, 2 //PC = 0	r01 = ? 
	addi 	r2 , r16, 2 //PC = 1	r02 = 20
	addi 	r3 , r17, 2 //PC = 2	r03 = 21
	addi 	r4 , r18, 2 //PC = 3	r04 = 23
	addi 	r30 , r19, 2 //PC = 3	r04 = 23
	jal		Label3
	and     r6 , r20, 0 // No se deberia ejecutar
	andi 	r7 , r21, 0 // No se deberia ejecutar
	andi 	r5 , r23, 0 // No se deberia ejecutar
	andi 	r8 , r24, 0 // No se deberia ejecutar
Label3:		
	andi 	r1 , r15, 0
	andi 	r2 , r16, 0
	andi 	r3 , r17, 0
	andi 	r4 , r18, 0
	addi 	r30 , r18, 2
	j		Label2
	addi 	r6 , r21, 2	// No se deberia ejecutar
	addi 	r7 , r22, 2	// No se deberia ejecutar
	addi 	r5 , r20, 2	// No se deberia ejecutar
	addi 	r8 , r23, 2	// No se deberia ejecutar
Label2:
	addi 	r1 , r15, 1
	addi 	r2 , r16, 1
	addi 	r3 , r17, 1
	addi 	r4 , r18, 1
	halt
		