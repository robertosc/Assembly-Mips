Ejemplo de curso
.data
	intro: .asciiz "\n\n\nEste programa calcula las raices reales de una ecuación cuadrática del tipo ax^2+bx+c=0\n"
	readA: .asciiz "\nDigite el valor de a: "
	readB: .asciiz "\nDigite el valor de b: "
	readC: .asciiz "\nDigite el valor de c: "
	disc: .asciiz "\nEl valor del discriminante es: "
	discRaiz: .asciiz "\nEl valor de la raiz del discriminante es: "
	sol: .asciiz "\nLas soluciones para la ecuación son: "
	x1: .asciiz "\nx1: "
	x2: .asciiz "\nx2: "
	sollin: .asciiz "\nLa ecuación es lineal con solución: "
	nosol: .asciiz "\nLa ecuación no tiene soluciones reales. "
	noeq: .asciiz "\nLa ecuación corresponde a una recta paralela al eje x. "

.text
main:

	li $v0, 4
	la $a0, intro
	syscall

#leer a
	li $v0, 4
	la $a0, readA
	syscall

	li $v0, 6 #Lee un float que queda en $f0
	syscall	

	mov.s $f1, $f0 #mueve el número leído de $f0 a $f1

#leer b
	li $v0, 4	
	la $a0, readB
	syscall

	li $v0, 6 #Lee un float que queda en $f0
	syscall	

	mov.s $f2, $f0 #mueve el número leído de $f0 a $f2

#leer c
	li $v0, 4
	la $a0, readC
	syscall

	li $v0, 6 #Lee un float que queda en $f0
	syscall	

	mov.s $f3, $f0 #mueve el número leído de $f0 a $f3	

	sub.s $f0, $f0, $f0 #cargar cero en $f0

	#mtc1 $0, $f0 #También se puede con el registro zero
	#cvt.s.w $f0, $f0  #Convierte un valor entero en un registro punto flotante en un valor en punto flotante

	c.eq.s $f1, $f0 #Pone cond en 1 si $f1==$f0
	bc1t checkB #si cond es 1 salta a la etiqueta


#Guardamos los registros $f1, $f2 y $f3 en la pila para pasarselos a la función discriminante
	addi $sp, $sp, -12
	s.s $f1, 8($sp)
	s.s $f2, 4($sp)
	s.s $f3, 0($sp)
	jal discriminante #se define que la función recibe los parámetros por la pila y por ahí devuelve el resultado
	l.s $f12, 0($sp)
	addi $sp, $sp, 12

#imprime el valor del discriminante
	li $v0, 4
	la $a0, disc
	syscall

	li $v0, 2
	syscall

#Evalua si el discriminante<0
	c.lt.s $f12, $f0 #Pone cond en 1 si $f1<$f0
	bc1t noRaices #si cond es 1 salta a la etiqueta	

#Guardamos el discriminante en la pila para pasarselo a la funcion raiz
	addi $sp, $sp, -4
	s.s $f12, 0($sp)
	jal raiz #se define que la función recibe los parámetros por la pila y por ahí devuelve el resultado
	l.s $f12, 0($sp)
	addi $sp, $sp, 4

#imprime el valor de la raiz del discriminante
	li $v0, 4
	la $a0, discRaiz
	syscall

	li $v0, 2
	syscall	

#calcular -b
	addi $t0, $0, -1
	mtc1 $t0, $f0 #se transfiere un valor de un registro entero a uno flotante
	cvt.s.w $f0, $f0  #Convierte un valor entero en un registro punto flotante en un valor en punto flotante	
	mul.s $f4, $f2, $f0 #en $f4 tengo -b

#calcular 2a
	addi $t0, $0, 2
	mtc1 $t0, $f0 #se transfiere un valor de un registro entero a uno flotante
	cvt.s.w $f0, $f0  #Convierte un valor entero en un registro punto flotante en un valor en punto flotante	
	mul.s $f5, $f1, $f0 #en $f5 tengo 2a

#primera solución
	add.s $f6, $f4, $f12 #$f6=-b+sqrt(dis)
	div.s $f6, $f6, $f5  #$f6=(-b+sqrt(dis))/2a

#segunda solución
	sub.s $f7, $f4, $f12 #$f7=-b-sqrt(dis)
	div.s $f7, $f7, $f5  #$f7=(-b+sqrt(dis))/2a

#imprimir resultados
	li $v0, 4
	la $a0, sol
	syscall

	li $v0, 4
	la $a0, x1
	syscall

	li $v0, 2
	mov.s $f12, $f6
	syscall

	li $v0, 4
	la $a0, x2
	syscall

	li $v0, 2
	mov.s $f12, $f7
	syscall

	j main

checkB:
	c.eq.s $f2, $f0 #Pone cond en 1 si $f1==$f0
	bc1t noEq #si cond es 1 salta a la etiqueta

#calcular -c
	addi $t0, $0, -1
	mtc1 $t0, $f0 #se transfiere un valor de un registro entero a uno flotante
	cvt.s.w $f0, $f0  #Convierte un valor entero en un registro punto flotante en un valor en punto flotante	
	mul.s $f4, $f3, $f0 #en $f4 tengo -c	

	div.s $f12, $f4, $f2 #$f12=-c/b

	li $v0, 4
	la $a0, sollin
	syscall

	li $v0, 4
	la $a0, x1
	syscall

	li $v0, 2
	syscall

	j main

noEq:
	li $v0, 4
	la $a0, noeq
	syscall	

	j main


noRaices:
	li $v0, 4
	la $a0, nosol
	syscall	

	j main

discriminante:
	addi $sp, -16
	s.s $f0, 12($sp) 
	s.s $f1, 8($sp)
	s.s $f2, 4($sp)
	s.s $f3, 0($sp)

	l.s $f3, 16($sp)
	l.s $f2, 20($sp)
	l.s $f1, 24($sp)

#calcular 4a
	addi $t0, $0, 4
	mtc1 $t0, $f0 #se transfiere un valor de un registro entero a uno flotante
	cvt.s.w $f0, $f0  #Convierte un valor entero en un registro punto flotante en un valor en punto flotante	
	mul.s $f0, $f1, $f0 #en $f0 tengo 4a
	mul.s $f0, $f3, $f0 #en $f0 tengo 4ac

	mul.s $f2, $f2, $f2	 #en $f2 tengo b^2
	sub.s $f0, $f2, $f0

	s.s $f0, 16($sp)

	l.s $f3, 0($sp)
	l.s $f2, 4($sp)
	l.s $f1, 8($sp)
	l.s $f0, 12($sp) 
	addi $sp, 16
	jr $ra

raiz:
	addi $sp, -16
	s.s $f0, 12($sp) 
	s.s $f1, 8($sp)
	s.s $f2, 4($sp)
	s.s $f3, 0($sp)

	l.s $f0, 16($sp) #$f0=N

	addi $t0, $0, 2
	mtc1 $t0, $f1 #se transfiere un valor de un registro entero a uno flotante
	cvt.s.w $f1, $f1  #f1=2 Convierte un valor entero en un registro punto flotante en un valor en punto flotante	

	div.s $f2, $f0, $f1 #$f2=x=N/2 valor inicial de la semilla

	addi $t0, $0, 20 #numero de iteraciones

iterRaiz:
	div.s $f3, $f0, $f2 #$f3=N/x
	add.s $f3, $f2, $f3 #$f3=x+N/x
	div.s $f2, $f3, $f1 ##$f2=(x+N/x)/2

	beq $t0, $0, retRaiz
	addi $t0, $t0, -1
	j iterRaiz

retRaiz:
	s.s $f2, 16($sp)

	l.s $f3, 0($sp)
	l.s $f2, 4($sp)
	l.s $f1, 8($sp)
	l.s $f0, 12($sp) 
	addi $sp, 16
	jr $ra	
	