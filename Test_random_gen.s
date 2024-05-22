.data
# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10 #O indice do centroide corresponde ao do culster (0, k-1)
k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    
newline:  .string "\n"
space: .string " "

#Dados usados no algoritmo LCG para gerar numeros pseudo aleatorios
seed:       .word 12345        # Valor da seed
a:          .word 1664525      # Numero aleatorio para multiplicar
c:          .word 1013904223   # Incremento
m:          .word 32           # Valor maximo gerar entre 0 e 32


.text

jal initializeCentroids

la a1 centroids

lw a0 0(a1)
li a7 1
ecall
la a0, space
li a7 4
ecall
lw a0 4(a1)
li a7 1
ecall

la a0, newline
li a7 4
ecall

lw a0 8(a1)
li a7 1
ecall
la a0, space
li a7 4
ecall
lw a0 12(a1)
li a7 1
ecall

la a0, newline
li a7 4
ecall

lw a0 16(a1)
li a7 1
ecall
la a0, space
li a7 4
ecall
lw a0 20(a1)
li a7 1
ecall


li a7 10
ecall


randomgencord:

    li a7 30 #System Call usada para carregar o tempo em (ms) os primeiros 32bits no reg a0 e os segundos no reg a1 
    ecall
    
    
    lw t0, seed                # Carrega a seed inicial
    add t0, t0, a0             # Adiciona os primeiros 32Bits a seed
    
    slli t1, a1, 16            # Executa um ssli dos 16 bits nos segundos 32bits 
    add t0, t0, t1             # Adiciona o valor obtido pela operacao acima a seed

    # Carrega constantes necessárias para o LCG
    lw t1, a
    lw t2, c
    lw t3, m

    # Executa o LCG uma vez (Cordenada X)
    mul t4, t0, t1             # t4 = (seed + tempo) * a
    add t4, t4, t2             # t4 = t4 + c
    rem t0, t4, t3             # t0 = t4 % m
    la t5 seed
    sw t0  0(t5)                # Guarda a nova seed
    bgez t0 positive1           #Usado para verificar se o numero gerado nao e negativo
    neg t0 t0                   #Se este for passa a positivo
    positive1:
    add s0, t0, zero           # Guarda a primeiro cordenada X

    # Executa o LCG segunda vez (Cordenada Y)
    lw t0, seed                # Carrega a nova seed
    lw t1, a
    lw t2, c
    lw t3, m

    mul t4, t0, t1             # t4 = seed * a
    add t4, t4, t2             # t4 = t4 + c
    rem t0, t4, t3             # t0 = t4 % m
    la t5 seed
    sw t0 0(t5)                # Guarda a nova seed
    bgez t0 positive2
    neg t0 t0
    positive2:
    add s1, t0, zero           # Guarda a segunda cordenada Y

    jr ra
    
    
initializeCentroids:
    la t0 centroids
    lw t1 k
    addi t1 t1 -1
    loopgencord:
        addi sp sp -12
        sw t0 0(sp)
        sw t1 4(sp)
        sw ra 8(sp) #Guarda o endereço de retorno
        jal randomgencord
        lw t0 0(sp)
        lw t1 4(sp)
        lw ra 8(sp) #Restaura o endereço de retorno
        addi sp sp 12

        slli t2 t1 3 
        add t3 t0 t2
        sw s0 0(t3)
        sw s1 4(t3)

        addi t1 t1 -1
        bgez t1 loopgencord
    jr ra