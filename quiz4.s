# La lista debe definirse en el .data, en este caso la listaA tiene menos datos
.data 
numero: .word 0x0488FF19
listaA: .word 0xFFFFFFFF, 20, 0xF999999F,20, 30, 40, 50, 70, 100, 0x00
listaB: .space 32

#####Disclaimer: EL PROGRAMA NO CORRE PARA 100 DATOS PORQUE NO SE LE HAN PASADO EN LISTA, HABRÍA QUE AÑADIRLOS
.text
main:
	li $t0, 100 			#Cargamos 100
	la $t1, listaA 			#Dirección listaA

	lw $t2, numero 			#cargo el num para sumar
	la $t3, listaB 			#cargo dir de listaB

	li $t4, 0				#contador i = 0

	j ciclo

ciclo:
    sltu $t5, $t4, $t0		#$t5=1 si i<100
    beq $t5, $0, termina        #$t5==0 termina
    sll $t4, $t4, 2 		#ix4
    
	add $t5, $t4, $t1       #$t5=listaA+(ix4)

    lw $t6,0($t5)         	#$t6=listaA[ix4]

    addu $v1, $t6, $t2      #$v1=listaA[ix4]+num

	#Acarreo check
    nor $t8, $t6, $0        #Se complementa
    sltu $t8, $t8, $t2		#Se verifica si (2^32 -1) < $t6 + $t2
    bne $t8, $0, complementa	#Si lo anterior se cumplió, hay overflow

	j guarda					

complementa: 
    nor $v1, $v1, $0 #complementa de listaA[ix4]
	j guarda

guarda: 
    sw $v1, 0($t3)          #listaB[i]=listaA[i] guarda!!!
    addi $t4, $t4, 1        #i++
    addi $t3, $t3, 4        #aumentamos listaB en 4
    j ciclo				

termina:
    li $v0, 10				#Termina el programa
    syscall