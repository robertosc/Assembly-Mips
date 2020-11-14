main:
    # Se crean estos load adress para reemplazar a los j $ra, que no se pueden realizar con branch
    la $s2,Final # tiene dirección de final
    la $s3,DespuesCiclo # tiene dirección de DespuesCiclo
    addi $s0, $zero,3 # Numero de ingreso es el numero de la sumatoria 
    addi $s1, $zero,1 # Guardar un 1 en s1
    addi $t0,$s0,0 # poner en t0 el valor de s0
    addi $sp,$zero,100
    # sustituyendo el jal, se carga la dirección justamente PC+4 después del j Ciclo
    la $ra,Final 
    beq $zero, $zero,Ciclo # salto a ciclo, sustituyendo j con un beq que siempre se cumple
    nop 
    nop
    nop
Final:
    addi $v0,$zero,1 # imprimir entero
    addi $a0, $t1,0  # t1 tiene el resultado al igual que a0
    li $v0,10 # Finalizar programa
    beq $zero, $zero,FinalizarPrograma
Ciclo:  
    beq $t0,$s1,Return1 # Si t0==1 se va hacia función return1   
    addi $sp,$sp,-8 # Reservar memoria
    sw $ra,4($sp) # Guardo dirección de regreso
    sw $t0,0($sp) # Guardo n
    addi $t0,$t0,-1 # diminuyo n
    la $ra,DespuesCiclo # sustituyendo jal como guardar PC+4
    beq $zero, $zero,Ciclo # salto a ciclo, sustituyendo j con un beq que siempre se cumple 
DespuesCiclo:
    lw $t0,0($sp)    # Cargar valor de n
    lw $ra,4($sp)    # ra= secuencia anterior
    addi $sp,$sp,8   # elimina memora
    add $t1,$t0,$t1 # n +sum(anterior)
    beq $ra,$s2,Final # salto a dirección ra que puede ser a Final o a DespuesCiclo
    beq $ra,$s3,DespuesCiclo # salto a dirección ra 
Return1:
    addi $t1,$zero,1
    beq $ra,$s2,Final # salto a dirección ra que puede ser a Final o a DespuesCiclo
    beq $ra,$s3,DespuesCiclo # salto a dirección ra   
FinalizarPrograma: