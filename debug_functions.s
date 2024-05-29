16, 1, 
17, 2, 
18, 6,
20, 3, 
21, 1, 
17, 4, 
21, 7, 
16, 4, 
21, 6, 
19, 6, 
4, 24, 
6, 24, 
8, 23, 
6, 26, 
5, 26, 
6, 23, 
8, 25, 
7, 26, 
7, 20, 
4, 21, 
4, 10, 
2, 10, 
3, 11, 
2, 12, 
4, 13, 
4, 9, 
4, 8, 
3, 8, 
0, 10, 
4, 11


##Code snipet to debug code, prints info to the terminal



newline:  .string "\n"
space: .string " "
virg: .string ","
virgpoint: .string ";"

#(With debug for points and centroids calculated for k>1) [x,y x,y ... x,y xc,yc ,n_points_sumed]
### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    li t0 1
    lw t1 k
    addi sp sp -4                  # Guarda o return adress na stack (decrementa o stack pointer)
    sw ra 0(sp)
    bne t1 t0 kmaior1cc            # Verifica se estamos me k=1 ou k>1
    k1cc:
        lw t1 n_points 
        addi t1 t1 -1              # Decrementa o n de pontos de modo a coincidir com o indice do array
        li s1 0                    # Inicializa a zero os acumuladores da soma para a média
        li s2 0
        k1loop:                    # Loop para somar todos os pontos x (no s1) e y (no s2)
            la a0 points
            slli t2 t1 3
            add a0 a0 t2
            lw t2 0(a0)
            lw t3 4(a0)
            add s1 s1 t2
            add s2 s2 t3
            addi t1 t1 -1
            bgez t1 k1loop
        lw t1 n_points
        div s1 s1 t1               # Calcula a média das coordenadas
        div s2 s2 t1
        la a0 centroids            # Guarada as coordenadas médias na posição 0 do vetor centroids (para k=1)
        sw s1 0(a0) 
        sw s2 4(a0)

    lw ra 0(sp)                   # Carrega o return adress da stack (restaura a posisao do stack pointer)
    addi sp sp 4
    jr ra

    kmaior1cc:                  # Calcula os centroides para k>1
        lw s1 k                 # Carrega o numero de clusters 
        li s4 0
        loopkcluster:            # Loop para percorrer todos os clusters                         
            bgtz s4 savecentroids     
            lw t4 n_points
            addi t4 t4 -1
            addi s1 s1 -1
            bltz s1 fimloop
                sumcords:
                    blez t4 loopkcluster
                    la t0 clusters
                    slli t1 t4 4
                    add t0 t0 t1
                    lw t1 0(t0)         #Carrega o indice do ponto do cluster
                    lw t2 4(t0)         #Carrega a coordenada X do ponto do cluster
                    lw t3 8(t0)         #Carrega a coordenada Y do ponto do cluster
                    addi t4 t4 -1
                    bne s1 t1 sumcords
                    add s2 s2 t2        #Acumulador Cord X
                    add s3 s3 t3        #Acumulador Cord Y

                    la a0, space
                    li a7 4
                    ecall

                    add a0 t2 zero
                    li a7 1
                    ecall

                    la a0, virg
                    li a7 4
                    ecall

                    add a0 t3 zero
                    li a7 1
                    ecall

                    la a0, space
                    li a7 4
                    ecall

                    addi s4 s4 1        
                    bgez t4 sumcords

            savecentroids:
            div s2 s2 s4
            div s3 s3 s4          #Guarda no vetor centroids i=k s2(x), s3(y)

            la t0 centroids       #Por alguma razao nao chega a esta parte nunca e executada, mudar estrutura de fluxo da funcao
            slli t1 s1 3
            add t0 t0 t1
            sw s2 0(t0)
            sw s3 4(t0)

                    la a0, space
                    li a7 4
                    ecall

                    add a0 s2 zero
                    li a7 1
                    ecall

                    la a0, space
                    li a7 4
                    ecall

                    add a0 s3 zero
                    li a7 1
                    ecall

                    la a0, space
                    li a7 4
                    ecall

                    la a0, virg
                    li a7 4
                    ecall

                    add a0 s4 zero
                    li a7 1
                    ecall

                    la a0, newline
                    li a7 4
                    ecall

            li s2 0                    #Acumulador Cord X
            li s3 0                    #Acumulador Cord Y
            li s4 0                    #N
                                   
            bgez s1 loopkcluster

    fimloop:
    lw ra 0(sp)                     # Carrega o return adress da stack (restaura a posição do stack pointer)
    addi sp sp 4
    jr ra



#(With debug prints for the cluster ids and point)
### generatevectorcluster
# Gera o vetor clusters a partir dos centroids e da funcao nearestCluster
# No vetor clusters os dados sao guardados da seguinte forma (id, x, y) o id o numero do cluster e a suas cordenadas
# Argumentos: nenhum
# Retorno: nenhum

generatevectorcluster:
    
    li t2 0
    genloopvc:  
        la t1 points        # Carrega o endereco do vetor points 
        slli t3 t2 3        # Calcula o offset de 3 no vetor points (x, y)
        add t3 t1 t3        # Adiciona o offset ao endereco base do vetor
        lw a0 0(t3)         # Carrega a cordenada x
        lw a1 4(t3)         # Carrega a cordenada y 
        addi sp sp -12      # Abre espaco na stack para guardar registros temp
        sw t2 0(sp)
        sw ra 4(sp)
        sw t3 8(sp)
        jal nearestCluster  # Chama a funcao nearestCluster para calcular o cluster mais proximo
        lw t2 0(sp)
        lw ra 4(sp)
        lw t3 8(sp)
        addi sp sp 12       # Fecha espaco na stack

        lw a1 0(t3)         
        lw a2 4(t3)

        la t0 clusters      # Carrega o endereco do vetor clusters
        slli t3 t2 4        # Calcula o offset de 4 no vetor clusters (id, x, y)
        add t3 t0 t3        # Adiciona o offset ao endereco base do vetor clusters
        sw a0 0(t3)         # Guarda o id do cluster
        sw a1 4(t3)         # Guarda a cordenada x do cluster
        sw a2 8(t3)         # Guarda a cordenada y do cluster

        li a7 4
        ecall

        la a0, virgpoint
        li a7 4
        ecall

        add a0 a1 zero
        li a7 1
        ecall

        la a0, virg
        li a7 4
        ecall

        add a0 a2 zero
        li a7 1
        ecall

        la a0, newline
        li a7 4
        ecall

        addi t2 t2 1        # Incrementa o indice do cluster
        lw t0 n_points      # Carrega o numero de pontos
        blt t2 t0 genloopvc # Verifica se ainda nao percorreu todos os pontos

    jr ra
