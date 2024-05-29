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
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2


#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8


#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10


#Input E
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 5, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 8, 3, 8, 0, 10, 4, 11


# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1


# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10 #O indice do centroide corresponde ao do culster (0, k-1)
k:           .word 3
L:           .word 10


# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:   .zero  16384 #(16Bits por cord max possivel 32x32=1024)

# Guarda os ultimos centroids de forma a verificar se estes alteraram
lastcentroids:  .zero 128 

#Dados usados no algoritmo LCG para gerar numeros pseudo aleatorios
seed:       .word 12345        # Valor da seed
a:          .word 1664525      # Numero aleatorio para multiplicar
c:          .word 1013904223   # Incremento
m:          .word 32           # Valor maximo gerar entre 0 e 32


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
    li a2 white                     # Carrega a cor branca para a2
    li a0 32                        # Carrega o tamanho da LED matrix para a0
    addi sp sp -4
    sw ra 0(sp)
        ledxloop:
            li a1 32                # Carrega o tamanho da LED matrix para a1
        
            ledyloop:
                addi sp sp -8
                sw a0 0(sp)         # Salvaguarda coordenada x 
                sw a1 4(sp)         # Salvaguarda coordenada y
                jal printPoint      # Pinta o ponto (x,y) de branco
                lw a0 0(sp)         # Carrega a coordenada x para a0
                lw a1 4(sp)         # Carrega a coordenada y para a1
                addi sp sp 8
                addi a1 a1 -1
                bgez a1 ledyloop    # Verifica se pintou o ultimo ponto
        
            addi a0 a0 -1
            bgtz a0 ledxloop        # Verifica se pintou o ultimo ponto
            
    lw ra 0(sp)
    addi sp sp 4
    jr ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    li t0 1                         # Carrega o valor 1 para t0
    lw t1 k                         # Carrega k para t1
    la s1 points                    # Carrega o endereco do vetor points para s1
    lw s0 n_points                  # Carrega numero de pontos no vetor para s0
    addi s0 s0 -1                   # Temp inverter o loop
    bne t1 t0 kmaior1pc             # Verifica se k e maior ou igual a 1
    k1pc:
        slli t0 s0 3                # Carrega o endereco do ultimo ponto do vetor para t1
        add t1 s1 t0
        lw a0 0(t1)                 # Carrega a coordenada x para a0
        lw a1 4(t1)                 # Carrega a coordenada y para a1
        la t3 colors                # Carrega o endereco das cores para t3
        lw a2 0(t3)                 # Carrega a cor para a2 (vermelho)
        addi sp sp -12
        sw s1 0(sp)                 # Salvaguarda endereco do vetor points
        sw s0 4(sp)                 # Salvaguarda numero de pontos do vetor
        sw ra 8(sp)
        jal printPoint              # Pinta o ponto (x,y) de branco
        lw s1 0(sp)                 # Carrega coordenada x para a0
        lw s0 4(sp)                 # Salvaguarda numero de pontos do vetor para s0
        lw ra 8(sp)
        addi sp sp 12
        addi s0 s0 -1
        bgez s0 k1pc
    jr ra

    jr ra

    kmaior1pc:
        
        li t0 0                     # Comeca o ciclo de 0 a n_points
       
        km1printloop:

            slli t1 t0 4            # Calcula o offset de 4 no vetor cluster (id, x, y)
            la t2 clusters          # Carrega o endereco do vetor cluster
            add t1 t2 t1            # Adiciona o offset ao endereco base do vetor
            lw a0 4(t1)             # Carrega a cordenada X
            lw a1 8(t1)             # Carrega a cordenada Y

            lw t1 0(t1)             # Carrega o indice do culster a que o ponto pertence
            slli t1 t1 2            # Calcula o offset com base no indice para o vetor cor
            la t2 colors            # Carrega o endereco do vetor colors
            add t2 t2 t1            # Adiciona o offset ao endereco base do vetor
            lw a2 0(t2)             # Carrega a cor pretendida no registro a2

            addi sp sp -8           # Guarda alguns registros antes da chamada
            sw t0 0(sp)
            sw ra 4(sp)
            jal printPoint          # Chama a funcao para dar print do ponto 
            lw t0 0(sp)
            lw ra 4(sp)
            addi sp sp 8            # Carrega os registros guardados anteriormente
            addi t0 t0 1
            lw t1 n_points          # Carrega o numero de pontos
            blt t0 t1 km1printloop  # Compara o atual ponto com o numero existente
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw t0 k 
    addi t0 t0 -1                   # Decrementa o n de pontos de modo a coincidir com o indice do array
    addi sp sp -4                   # Guarda o return adress na stack (decrementa o stack pointer)
    sw ra 0(sp)
    printloop:                      # Loop para percorrer o vetor centroids e chamar o printPoints para cada coordenada
        addi sp sp -4
        sw t0 0(sp)
        la t1 centroids
        slli t0 t0 3
        add t1 t1 t0
        lw a0 0(t1)
        lw a1 4(t1)
        li a2 black                 # Define a cor usada para fazer o print dos centroides
        jal printPoint
        lw t0 0(sp)
        addi sp sp 4
        addi t0 t0 -1
        bgez t0 printloop
    lw ra 0(sp)                     # Carrega o return adress da stack (restaura a posição do stack pointer)
    addi sp sp 4
    jr ra
    

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

    lw ra 0(sp)
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
                    bltz t4 loopkcluster
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

            li s2 0                    #Acumulador Cord X
            li s3 0                    #Acumulador Cord Y
            li s4 0                    #N
                                   
            bgez s1 loopkcluster

    fimloop:
    lw ra 0(sp)                     # Carrega o return adress da stack (restaura a posição do stack pointer)
    addi sp sp 4
    jr ra

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    addi sp sp -4               # Move o stack pointer de forma a guardar o registros necessarios
    sw ra 0(sp)                 # Guarda na stack o return adress

    la a0 k                     # Coloca k=1 (caso nao esteja a 1)
    li t0 1
    sw t0 0(a0)
    
    jal cleanScreen             # Chamadas de funcoes usada no mainSingleCluster
    jal printClusters
    jal calculateCentroids
    jal printCentroids
    
    lw ra 0(sp)                 # Restaura o return adress
    addi sp sp 4                # Restaura a posição do stack pointer
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0 a0 a2                        # Diferenaca entre as cordenadas X (x1-x2) 
    sub t1 a1 a3                        # Diferenaca entre as cordenadas Y (y1-y2)

    bgtz t0 y                           # Caso a diferenca seja negativa, passa a positivo caso contrario salta para o y 
    neg t0 t0
    y:
        bgtz t1 fim                     # Caso a diferenaca seja negativa passa a positivo caso contrario salta para fim 
        neg t1 t1
    
    fim:
        add a0 t0 t1                    # Guarda no registro que a manhattanDistance
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
   lw t1 k
   li s1 64                     #Maior distancia possivel numa matriz 32x32
   addi t1 t1 -1
   loopcentroids:
        la t0 centroids         # Carrega o endereco do vetor centroids
        slli t2 t1 3            # Calcula o offset de 3 no vetor centroids (x, y)
        add t2 t0 t2            # Adiciona o offset ao endereco base do vetor
        lw a2 0(t2)             # Carrega a cordenada x
        lw a3 4(t2)             # Carrega a cordenada y
        addi sp sp -16          # Abre espaco na stack para guardar registros temp
        sw ra 0(sp)
        sw t1 4(sp)             
        sw a0 8(sp)
        sw a1 12(sp)
        jal manhattanDistance   # Chama a funcao "manhattanDistance" para calcular a distancia
        add t3 a0 zero          # Guarda a distancia calculada
        lw ra 0(sp)                 
        lw t1 4(sp)             
        lw a0 8(sp)             
        lw a1 12(sp)            
        addi sp sp 16           # Fecha espaco na stack

        bgt t3 s1 next          # Verifica se a distancia e menor que a anterior
        add s1 t3 zero          # Guarda a menor distancia
        add s2 t1 zero          # Guarda o indice do cluster
        next:
            addi t1 t1 -1       
            bgez t1 loopcentroids       # Verifica se ainda nao percorreu todos os centroids

    add a0 s2 zero              # Guarda o indice do cluster mais proximo
    jr ra


### randomgencord
#Gera um par de coordenadas aleatórias
# Argumentos: nenhum
# Retorno:
# s0: x
# s1: y

randomgencord:

    li a7 30                   #System Call usada para carregar o tempo em (ms) os primeiros 32bits no reg a0 e os segundos no reg a1 
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
    
### initializeCentroids
# Inicializa o vetor centroids com cordenadas geradas de forma pseudo aletoria pela funcao randomgencord
# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    la t0 centroids
    lw t1 k
    addi t1 t1 -1               # Decrementa o K para contar de forma correta de 0-2 (0,1,2) em vez de (0,1,2,3)
    loopgencord:
        addi sp sp -12          # Abre espaco na stack para guardar registros temp necessarios para esta funcao 
        sw t0 0(sp)
        sw t1 4(sp)
        sw ra 8(sp)             # Guarda o endereco de retorno
        jal randomgencord       # Chama a funcao random que devolve no s0 e s1 duas cordenadas aleatorias
        lw t0 0(sp)
        lw t1 4(sp)
        lw ra 8(sp)             # Restaura o endereco de retorno
        addi sp sp 12

        slli t2 t1 3            # Bitshift usado para calcular o offset usado para guardar dados no vetor centroids
        add t3 t0 t2            # Adiciona ao endereco base de centroids o offset necesario
        sw s0 0(t3)             # Guarda o s0 cordenada X no vetor centroids na posicao correta
        sw s1 4(t3)             # Guarda o s1 cordenada Y no vetor centroids na posicao correta

        addi t1 t1 -1           # Decrementa o contador K numero de centroids
        bgez t1 loopgencord     # Jump para o inicio caso ainda nao seja menor que zero
    jr ra


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

        addi t2 t2 1        # Incrementa o indice do cluster
        lw t0 n_points      # Carrega o numero de pontos
        blt t2 t0 genloopvc # Verifica se ainda nao percorreu todos os pontos

    jr ra

### checkcentroidsupdate
# Verifica se houve alteracao do vetor centroids comparando o com uma copia previa
# Argumentos: 
# a0: 0 Para so atualizar o vetor 
# Retorno: a0 1 se houve alteracao

checkcentroidsupdate:

    beqz a0 updatevecor         # Se a0 e zero, vai para updatevecor


    lw t2 k                     # Carrega o numero de clusters
    addi t2 t2 -1               
    checkloop:                  # Loop para ccomprar todos os clusters
        la t0 lastcentroids     # Carrega o endereco do vetor lastcentroids
        la t1 centroids         # Carrega o endereco do vetor centroids
        slli t3 t2 3            # Calcula o offset de 3 no vetor centroids (x, y)
        add t0 t0 t3            # Adiciona o offset ao endereco base do vetor lastcentroids
        add t1 t1 t3            # Adiciona o offset ao endereco base do vetor centroids
        lw t3 0(t1)             # Carrega as cordenadas (x,y) do par de centroids
        lw t4 4(t1)
        lw t5 0(t0)
        lw t6 4(t0)
        bne t3 t5 vectormodified    # Verifica se houve alteração na cordenada x
        bne t4 t6 vectormodified    # Verifica se houve alteração na cordenada y
        addi t2 t2 -1               
        bgez t2 checkloop           # Verifica se ainda nao percorreu todos os pontos
        j updatevecor

    vectormodified:
        li a0 1                     # Se houve alteracao, retorna 1

    updatevecor:    
        lw t2 k                     # Carrega o numero de clusters
        addi t2 t2 -1           
        loopupdate:
            slli t3 t2 3            # Calcula o offset de 3 no vetor centroids (x, y)
            la t0 lastcentroids     # Carrega o endereco do vetor lastcentroids
            la t1 centroids         # Carrega o endereco do vetor centroids
            add t0 t0 t3            # Adiciona o offset ao endereco base do vetor lastcentroids
            add t1 t1 t3            # Adiciona o offset ao endereco base do vetor centroids
            lw t3 0(t1)             # Carrega as cordenadas (x,y) do centroid
            lw t4 4(t1)
            sw t3 0(t0)             # Guarda as coordenadas (x,y) do centroid em lastcentroids
            sw t4 4(t0)             
            addi t2 t2 -1
            bgez t2 loopupdate      # Verifica se ainda nao percorreu todos os centroids

    jr ra

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    addi sp sp -8                   
    sw ra 0(sp)                     # Guarda o return adress na stack
    jal cleanScreen                 # Executa as funcoes para a primeira vez do kmeans
    jal initializeCentroids
    jal generatevectorcluster
    li a0 0                         # Carrega o valor 0 no registro correto para que a funcao checkcentroidsupdate so atualize o seu vetor e nao verifique
    jal checkcentroidsupdate
    jal printClusters
    jal printCentroids

    lw s1 L                         # Numero  o numero maximo de iteracoes do algoritmo
    Kmeansloop:
        sw s1 4(sp)                 # Guarda o contador na stack
        jal cleanScreen
        jal calculateCentroids
        jal generatevectorcluster
        jal printClusters
        jal printCentroids

        li a0 2                    # Um valor aliatorio de forma a verificar a resposta da funcao checkcentroidsupdate
        li a1 2
        jal checkcentroidsupdate 
        lw s1 4(sp)                # Restaura o contador 
        beq a0 a1 endkmeans        # Caso o valor do registro a0 nao seja alterado pela funcao checkcentroidsupdate ja nao existe atualizacao do centroids interrompe o algoritmo
        
        addi s1 s1 -1
        bgez s1 Kmeansloop

    endkmeans:   
        lw ra 0(sp)               # Restaura o return adress
        addi sp sp 8
    jr ra
