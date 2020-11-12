#                                                               
#      	Tarea 3-4    -    Aritmética y punto flotante                        
#         Estructuras de Computadoras Digitales I               
#       Realizada por Roberto Sánchez Cárdenas B77059           
#                                                               
#                                                                       
#		La presente tarea tiene como fin implementar algunos                           
#   	cálculos sobre arrays de números enteros que se pasan
#		por medio del .data, a estos arrays se les mide la media
#		(promedio), desviación estándar y la mediana del array.
#		Los cálculos se realizan en este orden de modo que se 
#		aprovecha el cálculo de la media para obtener la desviación
#		estándar por medio de la siguiente fórmula
#
#					SD=sqrt(sum(A[i]-mean(A)))
#
#		Para obtener la raíz cuadrada se utiliza el método numérico
#		de Newton. Si queremos x=sqrt(A) se realiza una iteración de
#		0 a A/2, y se itera sobre la siguiente ecuación.
#
#				x = (x-A/x)/2, donde inicialmente x = A
#
#		Este programa trabaja solo con enteros para obtener la desvesta, 
#		por lo que tiene un nivel bajo de exactitud. Todos los resultados
#		se redondean hacia abajo en las raices. Ejemplo, si queremos raíz
#		de 15 [sqrt(15)] = 3.87, el programa da como resultado 3.
#
#
#		Si al calcular la media se obtiene rebase, se pasa a una fun-
#		cion que la calcula usando el punto flotante.
#
#		El programa está diseñado para ser corrido en MIPS y no toma 
#		ninguna opción o dato de entrada.

.data
intro: .asciiz "Tarea 3 y 4 de curso Estructuras de Computadores I\n\nSe calcula la media, desviación estandar y mediana respectivamente para 3 arrays distintos, en el tercer caso hay overflow. El orden se puede modificar. Todos los cálculos se obtienen con enteros, por lo que no son exactos, solo el caso de overflow."
lista: .word 4, 6, 12, 19, 1, 34, 3, 2, 1, -1
lista1: .word 1, 2, 10, 20, -1
lista2: .word 0x71234569, 0x7F943255, 0x5F432201, 0x72746491 -1
error_overflow: .asciiz "\nSe dio Overflow al sumar enteros, se calcula promedio en número flotante: "
sum_lista: .asciiz "\nSumatoria de la lista: "
mediana_par: .asciiz "\nMediana caso par: "
mediana_impar: .asciiz "\nMediana caso impar: "
promedio_str: .asciiz "\nPromedio de la lista: "
promedio_str_float: .asciiz "\nPromedio de la lista en flotante: "
sum_desvesta_str: .asciiz "\nSe debe sacar raiz cuadrada de: "
desvesta_str: .asciiz "\nDesviación estandar entera: "
calculos_media: .asciiz "\n\n\n\nCálculo del promedio"
calculos_desv: .asciiz "\n\nCálculo del desviación estándar"
calculos_mediana: .asciiz "\n\nCálculo del mediana con algoritmo bubble sort"
float_zero: .float 0.0
.text

.globl main

main:
	#En esta función se llaman las demás, se llaman varias veces debido a que en todos
	#los casos se debe unas una array distinto y los datos de a0 se modifican al imprimir.
	la $a0, intro
	li $v0, 4
	syscall

	la $a0, lista
	jal media
	la $a0, lista
	jal desvesta
	la $a0, lista
	jal clear_temp
	jal bubble_sort

	la $a0, lista1
	jal media
	la $a0, lista1
	jal desvesta
	la $a0, lista1
	jal clear_temp
	jal bubble_sort

	la $a0, lista2
	jal media
	la $a0, lista2
	jal desvesta
	la $a0, lista2
	jal clear_temp
	jal bubble_sort

	li $v0, 10			#Termina
	syscall




media:	#Calcula promedio
	li $t0, 0					#Acá tenemos i
	move $t2, $a0
	li $v0, 4
	la $a0, calculos_media
	syscall
	move $a0, $t2

	##Reinicio variables a 0##
	li $t2, 0
	li $t4, 0

	#Guardamos dirección del main para volver
	sw $ra, 0($sp)

	jal sumatoria

	la $a0, sum_lista			#imprime
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
	li $t8, -1					
	beq $v0, $t8, retorno		#Revisamos si $v0 == -1, que viene al obtener un overflow para saltar
	
	move $t2, $a0
	li $v0, 4
	la $a0, calculos_desv
	syscall
	move $a0, $t2
	li $t2, 0
	
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
	divu $v1, $t1				#sum/N
	mflo $v0
	mfhi $t3

	sw $ra, 0($sp)

	#Se redondea el dato usando los residuos
	li $t4, 2
	div $t1, $t4		#n/2

	mflo $t1

	slt $t2, $t1, $t3
	beq $t2, $0, print_suma_desv

	addi $v0, $v0, 1

	j print_suma_desv

print_suma_desv:		#Imprimimos el valor al que le sacamos la raiz
	move $t0, $v0

	la $a0, sum_desvesta_str
	li $v0, 4
	syscall

	move $a0, $t0
	li $v0, 1
	syscall

	div $t0, $t4
	mflo $t1

	li $t2, 0
	move $t3, $t0				#Guardamos sumatoria en t3 para manipular
	j sqrt_desvesta

sqrt_desvesta:
	#comenzamos a calcular raiz, en t1 tendremos x/2, en t0 = sum/n = x
	#queremos raiz de t0, t2 será contador i=0
	#copiamos x en $t3

	sltu $t5, $t2, $t1					#i<N/2 para terminal
	beq $t5, $0, end_desvesta

	#Operacion t3 = (t3+ t0/t3)/2
	#Calculamos $t0/$t3
	move $t4, $t3
	div $t0, $t4
	mflo $t5 
	jal redondeo

	add $t3, $t5, $t3

	#(t3+t0/t3)/2
	li $t4, 2
	div $t3, $t4
	mflo $t5
	jal redondeo

	move $t3, $t5

	addi $t2, $t2, 1			#i++

	j sqrt_desvesta

end_desvesta:		#Imprime resultado de desvesta y retorna
	la $a0, desvesta_str
	li $v0, 4
	syscall

	move $a0, $t3
	li $v0, 1
	syscall
	
	lw $ra, 0($sp)
	jr $ra

redondeo:
	#Traemos dato a redondear en t5 y div en t4
	mfhi $t6
	li $t7, 2
	div $t4, $t7

	mflo $t4
	slt $t7, $t4, $t6
	beq $t7, $0, retorno

	addi $t5, $t5, 1
	jr $ra



overflow:
	la $a0, error_overflow
	li $v0, 4
	syscall
	li $v0, -1
	li $v1, -1
	
	#la $a0, lista	
	li $t0, 0					#Cntador
	l.s $f12, float_zero
	j promedio_float

promedio_float:
	sll $t1, $t0, 2				#i*4
	add $t1, $a0, $t1

	lw $t2, 0($t1)				#A[i*4]	

	slt $t1, $0, $t2			#A[i*4]>0
	beq $t1, $0, fin_prom_float
	addi $t0, $t0, 1			#i++
	
	mtc1 $t2, $f1				#Conversion a flotante
	cvt.s.w $f1, $f1			#Guardamos en puntero flotante

	add.s $f12, $f12, $f1		#Suma flotante

	j promedio_float


fin_prom_float:				#Se divide entre N e imprime
	la $a0, sum_lista
	li $v0, 4
	syscall

	li $v0, 2
	syscall

	mtc1 $t0, $f2
	cvt.s.w $f2, $f2

	div.s $f12, $f12, $f2			#Division flotante
	la $a0, promedio_str_float
	li $v0, 4
	syscall

	li $v0, 2
	syscall

	li $v0, -1
	

	li $v0, 10
	syscall

bubble_sort:
	move $t2, $a0
	li $v0, 4
	la $a0, calculos_mediana
	syscall
	move $a0, $t2

	j bubble_sort_rest

bubble_sort_rest:
	li $t2, 0
	li $t0, 0	 			#swap
	li $v0, 0				#pD

	j bubble_loop

	bubble_loop:				#implementación de algoritmo bubble sort
		sll $t1, $v0, 2
		addu $t1, $t1, $a0

		lw $t2, 0($t1)			#Cargo A[i]
		slt $t3, $0, $t2

		beq $t3, $0, end_bubble_loop

		##Acá estaba i++
		lw $t4 4($t1)		#Tomamos el dato próximo A[i*4+1]
		
		addi $v0, $v0, 1
		slt $t3, $0, $t4					#Si A[i*4+1]>0, sigue
		beq $t3, $0, end_bubble_loop

		slt $t5, $t4, $t2
		beq $t5, $0, bubble_loop

		sw $t2, 4($t1) 				#intercambiamos datos
		sw $t4, 0($t1)				

		addi $t0, $0, 1				#Swap = 1
		j bubble_loop

	end_bubble_loop:
		bne $t0, $0, bubble_sort_rest	#Si swap es 1, itera de nuevo
		#la $a0, lista
		li $t3, 2
		div $v0, $t3

		
		
		mfhi $t4
		mflo $t5
		
		sll $t5, $t5, 2
		add $a0, $a0, $t5
		lw $v0, 0($a0)

		beq $t4, $0, caso_medio_par

		move $t8, $v0					#Movemos resultado para no tener inconvenientes al imprimir

		la $a0, mediana_impar
		li $v0, 4
		syscall

		move $a0, $t8
		li $v0, 1
		syscall
		move $v0, $t8

		jr $ra
	caso_medio_par:					##En este caso el medio es la mitad de dos datos del medio
		lw $v1, -4($a0)

		add $v0, $v0, $v1			
		div $v0, $t3
		mflo $v0
		mfhi $t0

		beq $t0, $0, print_media_par
		addi $v0, $v0, 1			#redondeo hacia arriba

		j print_media_par
	
	print_media_par:

		move $t0, $v0
		la $a0, mediana_par
		li $v0, 4
		syscall

		move $a0, $t0
		li $v0, 1
		syscall

		move $v0, $t0

		jr $ra

