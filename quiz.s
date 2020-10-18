.data 
numero: .word 0x0488FF19
lista: .word 0xFFFFFFFF, 20, 20, 30, 40, 50, 70, 100, 0x00
arrayB: .space 32

.text
main:
	li $t0, 8#100 # contador final=100
	la $t1, lista #Dirección lista

	lw $t2, numero #cargo el número
	la $s1, arrayB #cargo el arrayB

	li $t3, 0 #contador i

	j loop

loop:
    sltu $t4, $t3, $t0                #$t4=0 si i<100
    beq $t4, $zero, end           #$t4=0 cierra el programa
    sll $t4, $t3, 2 #i*4
    add $t5, $t4, $t1                #$t5=lista+i*4

    lw $t6,0($t5)                      #$t6=lista[i]

    addu $t8, $t6, $t2              #$t8=lista[i]+numero

    nor $t7, $t6, $0              #verifico si hay carry

    sltu $t7, $t7, $t2				#Se verifica que (2^32 -1) < $t6 + $t2

    bne $t7, $0, complemento

	#Si no hay overflow, se guarda la suma tal y como está, si no, se niega
	j store

complemento: 
    nor $t8, $t8, $0 #complemento de A
	j store

store: 
    sw $t6, 0($s1)          #arrayB[i]=lista[i] guarda!!!
    addi $t3, $t3, 1        #i++ para a
    addi $s1, $s1, 4          #i++ para b
    j loop
end:
    li $v0, 10
    syscall