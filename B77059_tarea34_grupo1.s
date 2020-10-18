.data
intro: .asciiz "Tarea 3 y 4 de curso Estructuras de Compuradores I"
lista: .word 12, 4, 10, -1
error_overflow: .asciiz "\nOverflow!!!!"
sum_lista: .asciiz "\nSumatoria de la lista: "
mediana_par: .asciiz "\nMediana caso par: "
mediana_impar: .asciiz "\nMediana caso impar: "
promedio_str: .asciiz "\nPromedio de la lista: "

.text

.globl main

main:
	jal bubble_sort
	jal media
	jal clear_temp
	jal desvesta
	li $v0, 10
	syscall

	j main

media:
	li $t0, 0					#Acá tenemos i
	la $a0, lista

	##Reinicio variables a 0##
	li $t2, 0
	li $t4, 0

	sw $ra, 0($sp)

	jal sumatoria

	la $a0, sum_lista
	li $v0, 4
	syscall
	move $a0, $t2
	li $v0, 1
	syscall

	div $t2, $t0		#División promedio!!!!!
	
	mflo $v0			#No cambiar
	mfhi $t3
	li $t1, 2			

	#Se redondea el dato usando los residuos
	div $t0, $t1		#n/2
	mflo $t1

	slt $t1, $t1, $t3
	beq $t1, $0, print_and_return

	addi $v0, $v0, 1

	j print_and_return

print_and_return:
	move $t8, $v0

	la $a0, promedio_str
	li $v0, 4
	syscall

	move $a0, $t8
	li $v0, 1
	syscall

	move $v0, $t8

	lw $ra, 0($sp)
	jr $ra

clear_temp:
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	jr $ra

sumatoria:
	sll $t1, $t0, 2				#ix4

	add $t4, $a0, $t1
	lw $t4, 0($t4)				#Creo que está de mas

	
	slt $t3, $0, $t4			#Revisamos si es negativo
	beq $t3, $0, retorno		#Si no es negativo, 

	addu $t2, $t2, $t4			#$t2 = t2 + lista
	#Checkear rebase
	nor $t3, $t2, $4			#t3 = ~t2
	sltu $t3, $t3, $t4			#2^32-1<t2+t4

	bne $t3, $0, overflow

	addi $t0, $t0, 1			#i = i+1
	j sumatoria

retorno:
	jr $ra

desvesta:
	la $a0, lista
	li $t1, 0
	#Traemos promedio en $v0
	sw $ra, 0($sp)
	j sumatoria_desvesta

sumatoria_desvesta:
	sll $t2, $t1, 2
	addu $t3, $a0, $t2

	lw $t3, 0($t3)
	slt $t4, $t3, 0
	bne $t4, $0, div_desvesta			#Si $t3<0 llegamos al final
	addi $t1, $t1, 1					#Sumamos i++

	sub $t3, $t3, $v0					#Restamos A[i*4]-media

	multu $t3, $t3						#Potencia a la 2
	
	mflo $t3

	add $v1, $v1, $t3
	j sumatoria_desvesta

div_desvesta:
	divu $v1, $t1
	mflo $v0

	#Se redondea el dato usando los residuos
	div $t0, $t1		#n/2
	mflo $t1

	slt $t1, $t1, $v1
	beq $t1, $0, sqrt_desvesta

	addi $v0, $v0, 1

	j sqrt_desvesta

sqrt_desvesta:


overflow:
	la $a0, error_overflow
	li $v0, 4
	syscall
	li $v0, -1
	li $v1, -1

	j retorno


bubble_sort:
	la $a0, lista			#top
	li $t0, 0	 			#swap
	li $v0, 0				#pD

	j bubble_loop

	bubble_loop:
		sll $t1, $v0, 2
		addu $t1, $t1, $a0

		lw $t2, 0($t1)			#Cargo A[i]
		slt $t3, $0, $t2

		beq $t3, $0, end_bubble_loop

		##Acá estaba i++
		lw $t4 4($t1)		#Tomamos el dato próximo A[i*4+1]
		
		slt $t3, $0, $t4					#Si A[i*4+1]>0, sigue
		beq $t3, $0, end_bubble_loop
		addi $v0, $v0, 1

		slt $t5, $t4, $t2
		beq $t5, $0, bubble_loop

		sw $t2, 4($t1) 
		sw $t4, 0($t1)

		addi $t0, $0, 1				#Swap = 1
		j bubble_loop

	end_bubble_loop:
		bne $t0, $0, bubble_sort	#Si swap es 1, itera de nuevo
		la $a0, lista
		li $t3, 2
		div $v0, $t3
		
		mfhi $t4
		mflo $t5
		
		sll $t5, $t5, 2
		add $a0, $a0, $t5
		lw $v0, 0($a0)

		bne $t4, $0, caso_medio_par

		move $t8, $v0					#Movemos resultado para no tener inconvenientes al imprimir

		la $a0, mediana_impar
		li $v0, 4
		syscall

		move $a0, $t8
		li $v0, 1
		syscall
		move $v0, $t8

		jr $ra
	caso_medio_par:					##En este caso el medio es la mitad de dos datos
		lw $v1, 4($a0)

		add $v0, $v0, $v1			
		div $v0, $t3
		mflo $v0

		addi $t8, $v0, 1			#Redondeo hacia arriba

		la $a0, mediana_impar
		li $v0, 4
		syscall

		move $a0, $t8
		li $v0, 1
		syscall

		move $v0, $t8

		jr $ra




