#                                                               
#           Tarea 2    -    Manejo strings                        
#         Estructuras de Computadoras Digitales I               
#       Realizada por Roberto Sánchez Cárdenas B77059           
#                                                               
#  	Este programa realiza ciertos manejos a strings. Cambia 
#	el orden y modifica mayusculas o minusculas. Tiene un string
#	predeterminado para pruebas. El programa no termina hasta 
#	cerras el simulador.                                                                     
  

.data 				#Se debe poner antes de definir variables
menu_s:  .asciiz "Menú de opciones disponibles:\n1. Leer una frase\n2. Convertir primera letra de cada palabra en mayúscula\n3. Invetir orden de las palabras\n4. Pasar todas las mayúsculas a minúsculas y viceversa\n\nIngrese la opción deseada -> "
end_s:  .asciiz "Terminado. \nDesarrollado por Roberto Sánchez Cárdenas - B77059 - IE-0321\n\n"
error_s: .asciiz "\n***Error. Opción no disponible. Por favor ingrese un número de opción válido.***\n\n"
op1_s: .asciiz "\nAcción: Leer una frase\n\nIngrese algún texto con solo letras sin acentos de tamaño válido: "
op2_s: .asciiz "\nAcción: Convertir primera letra de cada palabra en mayúscula\n\nFrase a modificar: "
op3_s: .asciiz "\nAcción: Invetir orden de las palabras\n\nFrase a modificar: "
op4_s: .asciiz "\nAcción: Pasar todas las mayúsculas a minúsculas y viceversa\n\nFrase a modificar: "
op1_exito: .asciiz "Frase leida con éxito, se usará para las operaciones seleccionadas."
op_final: .asciiz "\nFrase modificada: "
entrada: .asciiz "Tareas muy largas\n"
.text			 	#Es necesario cuando se va a poner texto

.globl main 		#Se declara la funcion global

main:
	jal menu
	j main

menu:
	li $v0, 4
	la $a0, menu_s
	syscall

	li $v0, 5
	syscall

	#### Se revisa que entrada esté entre 0<v0<5, también que no sean caracteres indeseados ####
	slt $t0, $0, $v0
	slti $t1, $v0, 5
	bne $t0, $t1, error

	la $v1, entrada				# Entrada es mensaje de interes
	
	##### Hasta este punto traigo main en $ra, se hace tipo switch case#####
	li $t0, 1					# Cargamos numero de opción
	beq $v0, $t0, opcion1		# Saltamos si es igual al número cargado

	li $t0, 2
	beq $v0, $t0, opcion2

	li $t0, 3
	beq $v0, $t0, opcion3

	li $t0, 4
	beq $v0, $t0, opcion4

retorno:						#Se devuelve a $ra
	jr $ra

error:							#Mensaje de error y vuelve a main
	li $v0, 4
	la $a0, error_s
	syscall
	j main	

opcion1:
	li $v0, 4
	la $a0, op1_s
	syscall

	li $v0, 8
	la $a0, entrada
	syscall

	move $v1, $a0
	li $t2, 0

	li $t1, 10								#Carga EOL-linefeed

	jal longitud							#Checkea si tamano es válido, si no sigue pidiendo

	longitud:
		lbu $t0, 0($v1)
		beq $t0, $t1, check_long			#Cuando encontramos 0 checkeamos tamano
		addi $t2, $t2, 1					#Contamos caracteres
		addi $v1, $v1, 1					#Aumentamos puntero del string
		j longitud

	check_long:
		sub $v1, $v1, $t2
		bne $t2, $0, main					#Tamaño ok, vuelve a main

		#Si tamano no válido, vuelve a pedir frase
		j opcion1

opcion2:									#Traemos frase en v1, demás registros no importan
	li $v0, 4								#Opcion 2
	la $a0, op2_s
	syscall

	move $a0, $v1
	syscall

	addi $t0, $0, 96#'a'					#Cargo a para comparar
	addi $t4, $0, 32						#Cargo espacio
	addi $t6, $0, 64#antes A

	addi $t5, $0, 10						#Line feed, EOL

	lbu $a0, 0($v1)							#Cargo primer char de mensaje de interes
	li $v0, 4
	la $a0, op_final
	syscall

	lbu $a0, 0($v1)
	li $v0, 11
	
	j check_case



	check_case:						#revisa si letra es minuscula o espacio
		slt $t2, $t0, $a0
		slti $t3, $a0, 123#'z'
		beq $t2, $t3, cambio

		j incremento				#Me carga el char actual y el siguiente


	cambio:							#Se pasa de min a mayusc
		andi $a0, $a0, 223
		#sb $a0, 0($v1)				#Se guarda el cambio en entrada
		j incremento

	cambio_2:						#Cambia de may a min
		ori $a0, $a0, 32
		j incremento
	

	incremento:	
		syscall
		lbu $t1, 0($v1)					#Cargamos el char actual y el siguiente
		lbu $a0, 1($v1)
		addi $v1, $v1, 1

		beq $t1, $t4, check_case		#Vemos si el actual es un espacio y revisamos si el siguiente es letra min
		
		slt $t2, $t6, $a0				#Reviso si es mayuscula para pasar a min
		slti $t3, $a0, 91
		beq $t2, $t3, cambio_2

		beq $a0, $t5, finaliza_op2
		j incremento					#Si no, incrementamos

	finaliza_op2:						#Se imprime el final y vuelve a main
		syscall
		j ultimo_EOL


opcion3:
	li $v0, 4
	la $a0, op3_s
	syscall
	move $a0, $v1
	syscall

	li $t1, 10								#Cargo EOL
	addi $t4, $0, 32						#Cargo espacio
	li $t2, 0								#Cargo t2 = 0
	
	jal longitud_v2							#Obtengo longitud en t2 para empezar de der->izq
	
	#Retorna acá con tamaño ok, tenemos tamaño en t2
	li $t3, 0
	
	li $v0, 4
	la $a0, op_final
	syscall

	li $v0, 11								#Cargo para imprimir caractres
	jal buscar_espacio


	longitud_v2:							#Funcion para longitud reutilizable
		lbu $t0, 0($v1)
		beq $t0, $t1, check_long_v2			#Cuando encontramos 0 checkeamos tamano
		addi $t2, $t2, 1					#Contamos caracteres
		addi $v1, $v1, 1					#Aumentamos puntero del string
		j longitud_v2
	
	check_long_v2:
		bne $t2, $0, retorno					#Tamaño ok, vuelve a opcion3
		j opcion1
	
	buscar_espacio:							#En t2 traigo long y comienzo de derecha a izquierda
		addi $t3, $t3, 1
		addi $v1, $v1, -1					#Resto 1 para ir hacia atras hasta espacio
		lbu $a0, 0($v1)
		#syscall
		beq $a0, $t4, carga_posicion
		beq $t3, $t2, imprime_palabra_final
		j buscar_espacio

	carga_posicion:									#Carga posición de espacio en t0 para no perderlo
		move $t0, $v1
		j imprime_palabra
	
	imprime_palabra:								#Imprime palabras de espacio en adelante
		addi $t0, $t0, 1
		lbu $a0, 0($t0)
		beq $a0, $t1, primer_espacio				#Si llega a EOL imprime un espacio
		syscall	
		beq $a0, $t4, buscar_espacio
		j imprime_palabra

	primer_espacio:
		move $a0, $t4
		syscall
		j buscar_espacio
	
	ultimo_EOL:
		li $a0, 10
		syscall
		syscall
		j main

	imprime_palabra_final:							#imprime palabra final a la cual se le debe añadir un espacio
		beq $a0, $t4, ultimo_EOL
		lbu $a0, 0($v1)
		syscall
		addi $v1, $v1, 1
		j imprime_palabra_final	



opcion4:
	li $v0, 4
	la $a0, op4_s
	syscall
	la $a0, entrada
	syscall

	addi $t0, $0, 96 #'a'				#Cargo lo que esta antes de a 
	addi $t1, $t1, 64#'A'

	addi $t4, $0, 32				#Cargo espacio
	addi $t5, $0, 10				#Line feed, EOL

	li $v0, 4
	la $a0, op_final
	syscall

	li $v0, 11

	j check_case_v2

		check_case_v2:					#revisa si letra es minuscula o espacio
			lbu $a0, 0($v1)
			slt $t2, $t0, $a0
			slti $t3, $a0, 123#'z'				#123 es despues de z en decimal
			beq $t2, $t3, cambio_min_may

			slt $t2, $t1, $a0
			slti $t3, $a0, 91#'Z'
			beq $t2, $t3, cambio_may_min

			j incremento_op4				#Me carga el char actual y el siguiente

		cambio_min_may:
			andi $a0, $a0, 223
			sb $a0, 0($v1)
			j incremento_op4

		cambio_may_min:
			ori $a0, $a0, 32
			sb $a0, 0($v1)
			j incremento_op4

		incremento_op4:
			syscall
			addi $v1, $v1, 1
			beq $a0, $t5, finaliza_op4
			j check_case_v2

		finaliza_op4:
			syscall
			j main

