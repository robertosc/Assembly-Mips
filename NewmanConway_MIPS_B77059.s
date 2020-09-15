#                                                               
#           Tarea 1    -    Recursividad doble                        
#         Estructuras de Computadoras Digitales I               
#       Realizada por Roberto Sánchez Cárdenas B77059           
#                                                               
#                                                                       
#       Este programa en MIPS pide al usuario un número n para
#		el cuál calcula la sucesión de Newman-Conway. El principal
#		reto de esta tarea radicó en el manejo correcto de memoria, 
#		puesto que al ser 100% iterativo, la memoria tiende a sobre-
#		escribirse a si misma. La función programada viene dada por:
#
#		P(0) = P(1) = P(2) = 1
#		P(n) = P(P(n-1)) + P(n-P(n-1)) n>2
#                                                               
#       Si se introducen valores validos de n (n>0), se imprime   
#       el resultado de la sucesión en consola.                             
#                                                                


.data 				#Se debe poner antes de definir variables
str:  .asciiz "Ingrese el número (n) hasta el que desea calcular la sucesión de Newman-Conway: "
str1:  .asciiz "Retorno 1\n"
str2:  .asciiz "Terminado. \nDesarrollado por Roberto Sánchez Cárdenas - B77059 - IE-0321"
str3: .asciiz "Suma\n"
str4: .asciiz "enter:"
abre: .asciiz "\nLa sucesión de Newman-Canway de 0 a n viene dada por:\n\n{"
coma: .asciiz ","
cierra: .asciiz "}\n"
enter: .asciiz "\n"
.text			 	#Es necesario cuando se va a poner texto

.globl main 		#Se declara la funcion global

main:
	addi $v0, $0, 4
	la $a0, str
	syscall
	addi $v0, $0, 5
	syscall

	slt $t0, $v0, $0		#Comprobamos que sea un numero positivo
	bne $t0, $0, exit		#salimos
	
	move $t1, $v0			#t1 modificable
	move $t0, $v0
	
	jal save_main

	li $v0, 4
	la $a0, str2

	syscall
	li $v0, 10
	syscall

logica:
	#Se verifica antes de guardar para no guardar los num <3
	slti $t2, $t1, 3		#si t1<3 caso base
	bne $t2, $0, ret1		#Si $a0 > 3, salta a base

	#push
	addi $sp, $sp, -20
	sw $t1, 4($sp)			#Guardamos lo que se devolvió en v0 en el syscall
	sw $ra, 0($sp)  		#Guardamos función

	#Restamos hasta llegar a base
	addi $t1, $t1, -1		#Como no conocemos un valor directo restamos 1
	jal logica				#Modifica ra $ra= jal logica 2 + 4

	####################Tenemos P(n-1)#########################
	#P(n) = P(P(n-1)) + P(n-P(n-1))

	sw $t4, 16($sp)		
	lw $t3, 4($sp)
	sub $t1, $t3, $t4		#Resta de n-P(n-1) 
	
	#lw $t4, 8($sp)			#Si esta linea está, en la primera iter me carga un 0, si no está funciona bien
							#Pero la necesito para cargar el dato de pila para los demás casos.
	jal logica

	#######################aquí tenemos P(n-1) y n-P(n-1)##########################
	sw $t4, 12($sp)
	lw $t4, 16($sp)
	add $t1, $0, $t4		#Movemos P(n-1) a t1 para P(P(n-1))
	jal logica				#Calculo P(P(n-1))

	##########################Tenemos P(P(n-1) y P(n-P(n-1))############################
	lw $t6, 12($sp)			#Cargamos P(P(n-1))
	add $t4, $t4, $t6	
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	sw $t4, 8($sp)			
	jr $ra


ret1: #Retorna 1
	addi $t4, $0, 1			#Guardamos 1 en $t4
	jr $ra

exit:
	li $v0, 1
	move $a0, $t4
	syscall
	li $v0, 4
	la $a0, str2			#Cargamos mensaje de terminado
	syscall
	li $v0, 10
	syscall
	#jr $ra

loop:
	move $t1, $t5
	jal logica 	  			#Debe ser un jump porque esta posición no queremos guardala en reg
	addi $t5, $t5, 1		#Sumamos uno a la sucesión t5++

	li $v0, 1
	move $a0, $t4
	syscall					#Imprime número de sucesión
	
	slt $t2, $t0, $t5
	bne $t2, $0, endLoop	#Lógica while
	
	li $v0, 4
	la $a0, coma			#Imprime coma
	syscall
	j loop

save_main:
	##Imprime {
	li $v0, 4
	la $a0, abre
	syscall

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t5, 0				#Cargamos t5 = 0 para hacer while

	j loop

endLoop:					#Carga posición en main
	##Imprimimos }
	addi $v0, $0, 4
	la $a0, cierra
	syscall

	addi $v0, $0, 4
	la $a0, enter
	syscall

	lw $ra, 0($sp)
	jr $ra
