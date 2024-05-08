//Riesgo de datos
//Riesgo LDE (RAW)
//Instrucciones tipo R

// segundo operando se adelanta
addu 1, 1, 1
addu 3, 5, 1

// primer operando se adelanta
addu 5, 3, 1

// caso del load
lw 7, 1(0) // rt, desplazamiento(base)
nor 9, 7, 0
halt 

// resultados:
// r1=2
// r3=7
// r5=9
// r7=a001
// r9=ffff5ffe