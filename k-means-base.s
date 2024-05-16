#
# IAC 2023/2024 k-means
# 
# Grupo: 26
# Campus: TagusPark
#
# Autores:
# 110126, António Hernani Rebelo de Carvalho Correia
# 109686, Miguel Póvoa Raposo
# 110286, Pedro Miguel Ledo Santos Nazareth
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
n_points:    .word 5
points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10 #O indice do centroide corresponde ao do culster (0, k-1)
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    jal cleanScreen

    jal printClusters
    

    jal mainSingleCluster
    jal cleanScreen
    jal printClusters
    jal printCentroids

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1 
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE 
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecr?
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li a2 white # Carrega a cor branca para a2
    li a0 32 # Carrega o tamanho da LED matrix para a0
    addi sp sp -4
    sw ra 0(sp)
        ledxloop:
            li a1 32 # Carrega o tamanho da LED matrix para a1
        
            ledyloop:
                addi sp sp -8
                sw a0 0(sp) # Salvaguarda coordenada x 
                sw a1 4(sp) # Salvaguarda coordenada y
                jal printPoint # Pinta o ponto (x,y) de branco
                lw a0 0(sp) # Carrega a coordenada x para a0
                lw a1 4(sp) # Carrega a coordenada y para a1
                addi sp sp 8
                addi a1 a1 -1
                bgez a1 ledyloop # Verifica se pintou o ultimo ponto
        
            addi a0 a0 -1
            bgtz a0 ledxloop # Verifica se pintou o ultimo ponto
            
    lw ra 0(sp)
    addi sp sp 4
    jr ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    li t0 1 # Carrega o valor 1 para t0
    lw t1 k # Carrega k para t1
    la s1 points # Carrega o endereco do vetor points para s1
    lw s0 n_points # Carrega numero de pontos no vetor para s0
    addi s0 s0 -1 #Temp inverter o loop
    bne t1 t0 kmaior1pc # Verifica se k e maior ou igual a 1
    k1pc:
        slli t0 s0 3 # Carrega o endereco do ultimo ponto do vetor para t1
        add t1 s1 t0
        lw a0 0(t1) # Carrega a coordenada x para a0
        lw a1 4(t1) # Carrega a coordenada y para a1
        la t3 colors # Carrega o endereco das cores para t3
        lw a2 0(t3) # Carrega a cor para a2 (vermelho)
        addi sp sp -12
        sw s1 0(sp) # Salvaguarda endereco do vetor points
        sw s0 4(sp) # Salvaguarda numero de pontos do vetor
        sw ra 8(sp)
        jal printPoint # Pinta o ponto (x,y) de branco
        lw s1 0(sp) # Carrega coordenada x para a0
        lw s0 4(sp) # Salvaguarda numero de pontos do vetor para s0
        lw ra 8(sp)
        addi sp sp 12
        addi s0 s0 -1
        bgez s0 k1pc

    kmaior1pc:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw t0 k 
    addi t0 t0 -1 #Decrementa o n de pontos de modo a coincidir com o indice do array
    addi sp sp -4 #Guarda o return adress na stack (decrementa o stack pointer)
    sw ra 0(sp)
    printloop: #Loop para percorrer o vetor centroids e chamar o printPoints para cada coordenada
        addi sp sp -4
        sw t0 0(sp)
        la t1 centroids
        slli t0 t0 3
        add t1 t1 t0
        lw a0 0(t1)
        lw a1 4(t1)
        li a2 black #Define a cor usada para fazer o print dos centroides
        jal printPoint
        lw t0 0(sp)
        addi sp sp 4
        addi t0 t0 -1
        bgez t0 printloop
    lw ra 0(sp) #Carrega o return adress da stack (restaura a posição do stack pointer)
    addi sp sp 4
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    li t0 1
    lw t1 k
    addi sp sp -4 #Guarda o return adress na stack (decrementa o stack pointer)
    sw ra 0(sp)
    bne t1 t0 kmaior1cc #Verifica se estamos me k= ou k>1
    k1cc:
        lw t1 n_points 
        addi t1 t1 -1 #Decrementa o n de pontos de modo a coincidir com o indice do array
        li s1 0 #Inicializa a zero os acumuladores da soma para a média
        li s2 0
        k1loop: #Loop para somar todos os pontos x (no s1) e y (no s2)
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
        div s1 s1 t1 #Calcula a média das coordenadas
        div s2 s2 t1
        la a0 centroids #Guarada as coordenadas médias na posição 0 do vetor centroids (para k=1)
        sw s1 0(a0) 
        sw s2 4(a0)
    
    kmaior1cc:
    # POR IMPLEMENTAR (2a parte)
    lw ra 0(sp) #Carrega o return adress da stack (restaura a posição do stack pointer)
    addi sp sp 4
    jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    addi sp sp -4
    sw ra 0(sp)
    #1. Coloca k=1 (caso nao esteja a 1)
    la a0 k
    li t0 1
    sw t0 0(a0)
    #2. cleanScreen
    jal cleanScreen
    #3. printClusters
    jal printClusters
    #4. calculateCentroids
    jal calculateCentroids
    #5. printCentroids
    jal printCentroids
    #6. Termina
    lw ra 0(sp)
    addi sp sp 4
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0 a0 a2 # (x1-x2)
    sub t1 a1 a3 # (y1-y2)

    bgtz t0 x
    neg t0 t0
    x:
        bgtz t1 fim
        neg t1 t1
    
    fim:
        add a0 t0 t1
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
   lw t1 k
   li s1 46 #Maior distancia possivel numa matriz 32x32
   addi t1 t1 -1
   loopcentroids:
        la t0 centroids
        slli t2 t1 3
        add t2 t0 t2
        lw a2 0(t2)
        lw a3 4(t2)
        addi sp sp -16
        sw ra 0(sp)
        sw t1 4(sp)
        sw a0 8(sp)
        sw a1 12(sp)
        jal manhattanDistance
        add t3 a0 zero
        lw ra 0(sp)
        lw t1 4(sp)
        lw a0 8(sp)
        lw a1 12(sp)  
        addi sp sp 16

        bgt t3 s1 next
        add s1 t3 zero
        add s2 t1 zero
        next:
            addi t1 t1 -1
            bgez t1 loopcentroids

    add a0 s2 zero
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra
