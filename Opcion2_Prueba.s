.data
menu: .asciiz "\nMenu de opciones:\n1. Leer una frase.\n2. Primera Letra De Cada Palabra En Mayúscula Las Demás En Minúscula.\n3. Invertir el orden de las palabras dentro de la frase.\n4.Cambiar todas las letras minúsculas a mayúsculas, y las mayúsculas a minúsculas."
error: .asciiz "\nLa opción ingresada es incorrecta. Por favor ingrese una opción del menú."
input1: .asciiz "\nIngrese una frase.\n"
error1: .asciiz "\nEl string ingresado es muy grande. Por favor ingrese otro.\n"
Nuevo1: .asciiz "\nLa nueva frase es:\n"
input: .asciiz "String De Prueba\n"
.text			 	        # Se usará texto

.globl main 		        # Declaración de la función main

main:
    li $v0, 4               # Syscall imprimir string
    la $a0, menu            # Se imprimen las opciones del menú
    syscall

    li $v0, 5               # Syscall leer int
    syscall

    move $t0, $v0           # Movemos la opción ingresada a $t0

    li $v0, 4
    la $a0, input
    syscall

    jal el_menu                

el_menu:
    slti $t6, $t0, 5            # Si $t0 < 5 , $t1 = 1 
    beq $t6, $zero, excepcion   # Manejo de excepciones 

    slti $t6, $t0, 1            # Si $t0 < 1 , $t1 = 1
    bne $t6, $zero, excepcion   # Manejo de excepciones

    la $t1, input

    li $t2, 1
    beq $t0, $t2, mode1 

    li $t2, 2
    beq $t0, $t2, mode2
  
    #li $t2, 3
    #beq $t0, $t2, mode3

    li $t2, 4
    beq $t0, $t2, mode4   

#Manejo de excepciones
excepcion:
    li $v0, 4           # Syscall imprimir caracteres
    la $a0, error       # Se pasa la cadena a $a0
    syscall

mode1: 
    li $v0, 4                     #Imprimir string  
    la $a0, input1                #Esta es la opción 1
    syscall 
    
    li $a1, 0x7fffffff            # Se define un valor grande en $a1                      
    la $a0, input                 # Se guarda entrada en input
    li $v0, 8                     # $a0 = buffer
    syscall

    move $t1, $a0               # Cargo el string en $t1
    li $t2, 0                  # Cargo un cero en $t3 = i
    li $t3, 10                  # Cargo valor de Line Feed en $t4
    j loop1

    loop1:
        lbu $t4, 0($t1)             # $t1 = str[i]
        beq $t4, $t3, tamano_     # Cuando llego a line feed, verifico que el tamaño sea aceptado  
        addi $t1, $t1, 1            # +1 al puntero del array 
        addi $t2, $t2, 1            # Contador -> Tamaño del array, i = $t3
        jal loop1

    tamano_:
        slt $t2 ,$t2, $a1               # Si $t3 < $a1, $t3 = 1
        beq $t2, $zero, muy_grande      # Si el string es más grande de lo permitido, tira error
        jal main

    muy_grande:
        li $v0, 4               #Imprimir string
        la $a0, error1         #Si el string es muy grande, el programa pide otro
        syscall

        jal mode1

mode2:
    li $v0, 4                   # Imprimir string
    la $a0, Nuevo1              # Esta es la opción 2
    syscall                    

    lbu $a0, 0($t1)             # De main traigo input en $t1

    li $t0, 32                  # Cargo space en $t1
    li $t3, 10                  # Cargo Line feed en $t2
    li $t8, 'z'                 # Cargo valor numérico de z
    
    j firstdigit

    firstdigit: #a0 < a abcde

        sltiu $t5, $a0, 'a'           # Si $t4 < 65 , $t4 = 1 
        bne $t5, $zero, f_d_space   # Si el caracter tiene valor menor a 65, sig caracter

        sltu $t7, $t8, $a0          # Si z < $t4 , $t5 = 1
        bne $t7, $zero, f_d_space   # Si z < $t4 , vamos a sig posición

        j CapsM
        
    f_d_space:
        li $v0, 11 
        syscall
        lbu $t6, 0($t1)
        lbu $a0 1($t1)

        addi $t1, $t1, 1            # Puntero ahora apunta a posición i++
        beq $t6, $t0, firstdigit    # Si 
        beq $a0, $t3, main         # Si $a0 tiene el último elemento, termina función



        j verifica

    verifica:
        # Aquí ya sabemos que el caracter $a0 es una letra, sabemos que el caracter que viene antes no es un espacio
        # Sabemos que el caracter tiene que, obligatoriamente, ser una letra MINUSCULA
        ori $a0, $a0, 32
        j f_d_space

    CapsM:
        andi $a0, $a0, 223   # Máscara and para forzar cero y convertir a mayúscula
        j f_d_space 

mode4:
    li $v0, 4                   # Imprimir string
    la $a0, Nuevo1              # Esta es la opción 2
    syscall                    

    li $t2, 32                  # Cargo space en $t1
    li $t3, 10                  # Cargo Line feed en $t2 
    li $t8, 'z'                 # Cargo valor ASCII de 'z' 

    j funcion
 
    funcion: 
        lbu $a0, 0($t1)
        beq $a0, $t2, continuar     # Si el caracter es un espacio, continua al siguiente caracter
        beq $a0, $t3, main

        sltiu $t5, $a0, 'a'           # Si $t4 < 65 , $t4 = 1 
        bne $t5, $zero, ACapsMin   # Si el caracter tiene valor menor a 65, sig caracter

        sltu $t7, $t8, $a0          # Si z < $t4 , $t5 = 1
        bne $t7, $zero, ACapsMin   # Si z < $t4 , vamos a sig posición

        j ACapsMay

    ACapsMin:
        
        andi $a0, $a0, 32   # Máscara and para forzar cero y convertir a mayúscula
        j continuar
        
    ACapsMay:
       
        ori $a0, $a0, 223   # Máscara or para forzar uno y convertir a mayúscula 
        j continuar 

    continuar:
        li $v0, 11 
        syscall

        addi $t1, $t1, 1            # Aumenta el puntero del array en 1
        j funcion