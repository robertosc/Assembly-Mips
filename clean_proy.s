main:
	addi $a0, $0, 5			#Se carga el n número de sum(n)
	addi $t1, $0, 5			#Se carga una copia
	addi $t0, $0, 1			#Se carga un comodín para salto
	la $ra, end				#Se guarda $ra
	beq $t0, $t0, sum_recursive	#Se salta,emulando incondicional
	nop

sum_recursive:
	addi $sp, $sp, 8		#Muevo en pila, positivo por ser DrMips
	sw $ra, 0($sp)			#Guardo el $ra
	sw $a0, 4($sp)			#guardo el n enesimo dato
	slt $t2, $a0, $t0		#comparo
	beq $t2, $0, min		#salto
	addi $v0, $0, 0			#Cargo un 0 en $v0 par hacer la sumatoria bien
	addi $sp, $sp, 8		#Sumo 8 para eliminar el 0 que se guardó
	beq $t0, $t0, post	


min:
	addi $a0, $a0, -1		#Resto hasta llegar a 0
	la $ra, post
	beq $t0, $t0, sum_recursive #Vuelve a sum siempre
	nop

post:
	lw $a0, 4($sp)			#Cargo dato
	lw $ra, 0($sp)		
	addi $sp, $sp, -8		#resto a sp para lectura correcta
	add $v0, $v0, $a0		#sumatoria
	slt $t2, $a0, $t1	
	beq $t2, $0, end		
	beq $t0, $t0, post
end: