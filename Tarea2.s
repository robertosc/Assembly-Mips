.data 				#Se debe poner antes de definir variables
menu_s:  .asciiz "Menú de opciones disponibles:\n1. Leer una frase\n2. Convertir primera letra de cada palabra en mayúscula\n3. Invetir orden de las palabras\n4. Pasar todas las mayúsculas a minúsculas y viceversa\n\nIngrese la opción deseada -> "
end_s:  .asciiz "Terminado. \nDesarrollado por Roberto Sánchez Cárdenas - B77059 - IE-0321\n\n"
error_s: .asciiz "\n***Error. Opción no disponible. Por favor ingrese un número de opción válido.***\n\n"
op1_s: .asciiz "\nAcción: Leer una frase\n\nIngrese algún texto con solo letras sin acentos de tamaño válido: "
op2_s: .asciiz "\nAcción: Convertir primera letra de cada palabra en mayúscula\n"
op3_s: .asciiz "\nAcción: Invetir orden de las palabras\n"
op4_s: .asciiz "\nAcción: Pasar todas las mayúsculas a minúsculas y viceversa\n"
op1_exito: .asciiz "Frase leida con éxito, se usará para las operaciones seleccionadas."
entrada: .asciiz "los perros son excelentes mascotas"
coma: .asciiz ""
cierra: .asciiz ""
enter: .asciiz ""
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

	la $v1, entrada				# C
	
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

	li $t1, 10

	jal longitud			#Checkea si tamano es válido, si no sigue pidiendo

	longitud:
		lbu $t0, 0($v1)
		beq $t0, $t1, check_long			#Cuando encontramos 0 checkeamos tamano
		addi $t2, $t2, 1				#Contamos caracteres
		addi $v1, $v1, 1				#Aumentamos puntero del string
		j longitud

	check_long:
		sub $v1, $v1, $t2
		bne $t2, $0, main				#Tamaño ok, vuelve a main

		#Si tamano no válido, vuelve a pedir frase
		j opcion1

opcion2:							#Traemos frase en v1
	li $v0, 4
	la $a0, op2_s
	syscall

	lbu $a0, 0($v1)					#Guardamos inicio en a0
	
	li $t1, 96
	slt $t3, $t1, $a0
	slti $t4, $a0, 'z'
	beq $t3, $t4, cambio_min_mayusc

	li $t5, 32						#Cargamos decimal de espacio 0x20
	jal busca_espacio


	j main


	busca_espacio:
		lbu $a0, 0($v1)
		beq $a0, $t5, inicio_palabras
		addi $v1, $v1, 1
		j busca_espacio


	inicio_palabras:				#Buscamos las palabras después de un espacio
		addi $v1, $v1, 1
		lbu $a0, 0($v1)
		slt $t3, $t1, $a0
		slti $t4, $a0, 'z'
		beq $t3, $t4, cambio_min_mayusc

	cambio_min_mayusc:				#Acá se hacen los cambios de minuscula a minuscula
		andi $a0, $a0, 223
		li $v0, 11
		syscall

		li $v0, 10
		syscall
		
		jr $ra

	aumenta:



opcion3:
	li $v0, 4
	la $a0, op3_s
	syscall
	jr $ra

opcion4:
	li $v0, 4
	la $a0, op4_s
	syscall
	jr $ra
