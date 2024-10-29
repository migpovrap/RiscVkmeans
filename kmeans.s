#
# IAC 2023/2024 k-means
# 
# Grupo: 26
# Campus: TagusPark
#
# Autores:
# 110126, Antonio Hernani Rebelo de Carvalho Correia
# 109686, Miguel Povoa Raposo
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


# Variables in Memory
.data

#Input A - Slanted Line
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8


#Input B - Cross
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


# Centroids and k values to use in the first part of the project:
#centroids:   .word 0,0
#k:           .word 1


# Centroids, k and L to use in the second part of the project:
centroids:   .word 0,0, 10,0, 0,10 #The indice of the centtroid corresponds to the clsuter (0, k-1)
k:           .word 3
L:           .word 10

# Below there are declared the clsuters vectors and other data structures for the second part
clusters:   .zero  16384 #(16Bits wich gives a maximum led matrix size of 32x32=1024)

# Stores the last centroids to check if they have changed
lastcentroids:  .zero 128 

# Data used for the pseudo random LCG algorithm generator
seed:       .word 12345        # Seed value
a:          .word 1664525      # Random number to multiply
c:          .word 1013904223   # Increment
m:          .word 32           # Maximun value to generate between 0 - 32 


# Color data to use for the led matrix

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Colors of the clusters 0, 1, 2, etc...

.equ         black      0
.equ         white      0xffffff



# Code
 
.text
    # Calls the main function of the project for the first part only one cluster
    # jal mainSingleCluster
    # Calls the main function of the project
    jal mainKMeans
    
    # Closes the program (using system call)
    li a7, 10
    ecall


### printPoint
# Prinst the point (x,y) on the LED matrix with the color passed as an argument
# Note: the implementation of this function is already provided by the teachers
# It is an auxiliary function that should be called by all functions that print to LED matrix.
# Arguments:
# a0: x
# a1: y
# a2: color

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
# Cleans all points in the LED matrix
# Arguments: nenhum
# Returns: nenhum

cleanScreen:
    li a2 white                               # Loads white color
    li a0 32                                  # Loads the size of the LED matrix
    addi sp sp -4
    sw ra 0(sp)
        ledxloop:
            li a1 32                          # Loads the size of the LED matrix
        
            ledyloop:
                addi sp sp -8
                sw a0 0(sp)                   # Stores the x coordinate 
                sw a1 4(sp)                   # Stores the y coordinate
                jal printPoint                # Prints the point (x,y) in white
                lw a0 0(sp)                   # Loads the x coordinate
                lw a1 4(sp)                   # Loads the y coordinate
                addi sp sp 8
                addi a1 a1 -1
                bgez a1 ledyloop              # Checks if the last point was printed
        
            addi a0 a0 -1
            bgtz a0 ledxloop                  # Checks if the last point was printed
            
    lw ra 0(sp)
    addi sp sp 4
    jr ra
    
### printClusters
# Prints the clusters to the LED matrix with the correct color.
# Arguments: nenhum
# Returns: nenhum

printClusters:
    li t0 1                                   # Loads the value 1
    lw t1 k                                   # Loads k
    la s1 points                              # Loads the adress of the points vector
    lw s0 n_points                            # Loads number of points in the vector
    addi s0 s0 -1                             # Inverts the loop temporary
    bne t1 t0 kmaior1pc                       # Checks if k is bigger or equal to 1
    k1pc:
        slli t0 s0 3                          # Loads the adress of the last point in the vector
        add t1 s1 t0
        lw a0 0(t1)                           # Loads the x coordinate
        lw a1 4(t1)                           # Loads the y coordinate
        la t3 colors                          # Loads the adress of the colors vector
        lw a2 0(t3)                           # Loads the color red
        addi sp sp -12
        sw s1 0(sp)                           # Stores the adress of the point vectors
        sw s0 4(sp)                           # Stores the number of points in the vectors
        sw ra 8(sp)
        jal printPoint                        # Print the (x, y) point in white 
        lw s1 0(sp)                           # Loads the adress of the point vectors
        lw s0 4(sp)                           # Loads the number of points in the vectors
        lw ra 8(sp)
        addi sp sp 12
        addi s0 s0 -1
        bgez s0 k1pc
    jr ra

    kmaior1pc:
        
        li t0 0                               # Starts the cycle at zero for n_points
       
        km1printloop:

            slli t1 t0 4                      # Adds the offset of 4 to the cluster vector (id, x, y)
            la t2 clusters                    # Loads the adress of the cluster vector
            add t1 t2 t1                      # Adds the offset to the base adress of the vector
            lw a0 4(t1)                       # Loads the X coordinate
            lw a1 8(t1)                       # Loads the Y coordinate

            lw t1 0(t1)                       # Loads the index of the point in the cluster
            slli t1 t1 2                      # Calculates the offset based on the index for the color vector
            la t2 colors                      # Loads the adress of the colors vector
            add t2 t2 t1                      # Adds the offset to the base adress of the vector
            lw a2 0(t2)                       # Loads the color into the a2 register

            addi sp sp -8                     # Stores some register before the jump call
            sw t0 0(sp)
            sw ra 4(sp)
            jal printPoint                    # Call the function to print a point
            lw t0 0(sp)
            lw ra 4(sp)
            addi sp sp 8                      # Loads the register saved before the jump
            addi t0 t0 1
            lw t1 n_points                    # Loads the number of point in the vector
            blt t0 t1 km1printloop            # Continues the loop if there are more points to print in the vector

    jr ra


### printCentroids
# Prints the centroids to the led matrix
# Note: the color black should be used to print the centroids
# Arguments: none
# Return: none

printCentroids:
    lw t0 k 
    addi t0 t0 -1                             # Converts from the number of points 
    addi sp sp -4                             # Stores the return adress in the stack (decrements the stack pointer)
    sw ra 0(sp)
    printloop:                                # Loops truh the vector to print all points in the centroid
        addi sp sp -4                         
        sw t0 0(sp)    
        la t1 centroids                       # Loads the adress of the centroids vector
        slli t0 t0 3                          # Calculates the offset of 3 for the vector centroids (x, y)
        add t1 t1 t0                          # Adds the offset to the vector centroids base adress
        lw a0 0(t1)                           # Loads the X coordinate
        lw a1 4(t1)                           # Loads the Y coordinate
        li a2 black                           # Defines the color used to print the centroids (black)
        jal printPoint                        # Prints the centroids
        lw t0 0(sp)
        addi sp sp 4
        addi t0 t0 -1
        bgez t0 printloop                     # Checks if it has passes trough all the centroids
    lw ra 0(sp)                               # Loads the stack return adress (restores the stack pointer positions)
    addi sp sp 4
    jr ra
    

### calculateCentroids
# Calculates the k centroids, based on the current distribution of points associated with each cluster
# Arguments: none
# Return: none

calculateCentroids:
    li t0 1
    lw t1 k                                   # Loads the number of clusters
    addi sp sp -4                             # Stores the return adress in the stack
    sw ra 0(sp)
    bne t1 t0 kmaior1cc                       # Checks in wich condition we are k = 1 or k > 1
    k1cc:
        lw t1 n_points 
        addi t1 t1 -1                         # Decrement the number of points to match the array index
        li s1 0                               # Initializes the sum accumulators to zero used for the average
        li s2 0
        k1loop:                               # Loop to sum all x points (in s1) and y points (in s2)
            la a0 points                      # Loads the adress of the vector points
            slli t2 t1 3                      # Calculates an offset of 3 for the points vector (x, y)
            add a0 a0 t2                      # Adds the offset to the base adress of the vector
            lw t2 0(a0)                       # Loads the X coordinate
            lw t3 4(a0)                       # Loads the Y coordinate
            add s1 s1 t2
            add s2 s2 t3
            addi t1 t1 -1
            bgez t1 k1loop
        lw t1 n_points
        div s1 s1 t1                          # Calculate the average of the coordinates
        div s2 s2 t1
        la a0 centroids                       # Store the average coordinates in position 0 of the centroids vector (for k=1)
        sw s1 0(a0) 
        sw s2 4(a0)

    lw ra 0(sp)                               # Load the return address from the stack (restore the stack pointer position)
    addi sp sp 4
    jr ra

    kmaior1cc:                                # Calculate the centroids for k > 1
        lw s1 k                               # Number of existing centroids
        li s4 0                               # Number of points summed per cluster (to calculate the centroid)
        loopkcluster:                         # Loop to traverse all clusters                         
            bgtz s4 savecentroids             # If s4>0, it indicates that a centroid has been calculated for the current cluster (it will store them in the centroids array)
            lw t4 n_points
            addi t4 t4 -1                     # The indices of the points in the vector points are (0 to (npoints-1))
            addi s1 s1 -1                     # The cluster indices are 0, 1, 2, not 0, 1, 2, 3
            bltz s1 fimloop                   # When s1 < 0, the centroids for all clusters have already been calculated
                sumcords:
                    bltz t4 loopkcluster      # When t4 < 0, the points vector has been traversed for a given vector
                    la t0 clusters            
                    slli t1 t4 4              # Uses a bitshift of 4, which means 16 bits for the clusters vector (id, x, y)
                    add t0 t0 t1
                    lw t1 0(t0)               # Load the index of the cluster point
                    lw t2 4(t0)               # Load the X coordinate of the cluster point
                    lw t3 8(t0)               # Load the Y coordinate of the cluster point
                    addi t4 t4 -1             # Decrement the counter of the points array for each cluster
                    bne s1 t1 sumcords        # If the index of the current point is not equal to the cluster we are in (0,1,2), move to the next point
                    add s2 s2 t2              # Accumulator  for coordinate X
                    add s3 s3 t3              # Accumulator  for coordinate Y
                    addi s4 s4 1              # Increment the counter of points summed for the same cluster used to calculate the centroid
                    bgez t4 sumcords          # Execute the sumcords for the points from 0 to (npoints-1) in the vector

            savecentroids:                    # Calculates the centroid and stores it in the correct position in the centroids vector
            div s2 s2 s4                      # Calculation of the X of the centroid (average of the coordinates) s4 the number of points summed
            div s3 s3 s4                      # Calculation of the X of the centroid (average of the coordinates) s4 the number of points summed

            la t0 centroids       
            slli t1 s1 3                      # Calculates the offset based on the s1 cluster index and the centroids in the vector for k=3 (0,1,2)
            add t0 t0 t1                      # Add the calculated offset to the base address of the vector
            sw s2 0(t0)                       # Store the X coordinate in the correct position of the centroids array
            sw s3 4(t0)                       # Store the Y coordinate in the correct position of the centroids array

            li s2 0                           # Reset the X coordinate accumulator to zero
            li s3 0                           # Reset the Y coordinate accumulator to zero
            li s4 0                           # Resets the counter of the number of summed points to zero
                                   
            bgez s1 loopkcluster              # Executes the loop for s1 number of centroids (k)

    fimloop:
    lw ra 0(sp)                               # Load the return address from the stack (restore the stack pointer position)
    addi sp sp 4
    jr ra

### mainSingleCluster
# Main function for the fisrt part of the project
# Arguments: none
# Return: none

mainSingleCluster:
    addi sp sp -4                             # Move the stack pointer to save the necessary registers
    sw ra 0(sp)                               # Save the return address on the stack

    la a0 k                                   # Load the address of k
    li t0 1
    sw t0 0(a0)
    
    jal cleanScreen                           # Function calls used in mainSingleCluster
    jal printClusters
    jal calculateCentroids
    jal printCentroids
    
    lw ra 0(sp)                               # Restores the return address
    addi sp sp 4                              # Restore the stack pointer position
    jr ra



### manhattanDistance
# Calculates the Manhattan distance between (x0, y0) and (x1, y1)
# Arguments:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Return:
# a0: distance

manhattanDistance:
    sub t0 a0 a2                              # Difference between the X coordinates (x1 - x2)
    sub t1 a1 a3                              # Difference between the Y coordinates (y1 - y2)

    bgtz t0 y                                 # If the difference is negative, make it positive; otherwise, jump to y
    neg t0 t0
    y:
        bgtz t1 fim                           # If the difference is negative, make it positive; otherwise, jump to the end.
        neg t1 t1
    
    fim:
        add a0 t0 t1                          # Store in the register the Manhattan distance
    jr ra


### nearestCluster
# Determines the nearest centroid to a given point (x, y).
# Arguments:
# a0, a1: (x, y) point
# Return:
# a0: cluster index

nearestCluster:
   lw t1 k
   li s1 64                                   # Maximum possible distance in a 32x32 matrix
   addi t1 t1 -1
   loopcentroids:
        la t0 centroids                       # Load the address of the centroids vector
        slli t2 t1 3                          # Calculate the offset of 3 in the centroids vector (x, y)
        add t2 t0 t2                          # Add the offset to the base address of the vector
        lw a2 0(t2)                           # Load the X coordinate
        lw a3 4(t2)                           # Load the Y coordinate
        addi sp sp -16                        # Opens space in the stack to save temporary registers
        sw ra 0(sp)
        sw t1 4(sp)             
        sw a0 8(sp)
        sw a1 12(sp)
        jal manhattanDistance                 # Calls the function "manhattanDistance" to calculate the distance
        add t3 a0 zero                        # Store the calculated distance
        lw ra 0(sp)                 
        lw t1 4(sp)             
        lw a0 8(sp)             
        lw a1 12(sp)            
        addi sp sp 16                         # Free space on the stack

        bgt t3 s1 next                        # Check if the distance is less than the previous one
        add s1 t3 zero                        # Stores the smallest distance
        add s2 t1 zero                        # Store the cluster index
        next:
            addi t1 t1 -1       
            bgez t1 loopcentroids             # Check if all centroids have not been traversed yet

    add a0 s2 zero                            # Stores the index of the nearest cluster
    jr ra


### randomgencord
# Generates a pair of random coordinates
# Arguments: none
# Return:
# s0: x
# s1: y

randomgencord:

    li a7 30                                  # System Call used to load the time in (ms) the first 32 bits in reg a0 and the second in reg a1 
    ecall
    
    
    lw t0, seed                               # Load the initial seed
    add t0, t0, a0                            # Add the first 32 bits to the seed
    
    slli t1, a1, 16                           # Execute an SSLI of 16 bits on the second 32 bits
    add t0, t0, t1                            # Adds the value obtained from the above operation to the seed

                                              # Loads necessary constants for the LCG
    lw t1, a
    lw t2, c
    lw t3, m

                                              # Executes the LCG once (Coordinate X)
    mul t4, t0, t1                            # t4 = (seed + time) * a
    add t4, t4, t2                            # t4 = t4 + c
    rem t0, t4, t3                            # t0 = t4 % m
    la t5 seed
    sw t0  0(t5)                              # Save the new seed
    bgez t0 positive1                         # Used to check if the generated number is not negative
    neg t0 t0                                 # If this becomes positive
    positive1:
    add s0, t0, zero                          # Store the first X coordinate

                                              # Execute the LCG a second time (Coordinate Y)
    lw t0, seed                               # Load the new seed
    lw t1, a
    lw t2, c
    lw t3, m

    mul t4, t0, t1                            # t4 = seed * a
    add t4, t4, t2                            # t4 = t4 + c
    rem t0, t4, t3                            # t0 = t4 % m
    la t5 seed
    sw t0 0(t5)                               # Save the new seed
    bgez t0 positive2
    neg t0 t0
    positive2:
    add s1, t0, zero                          # Save the second coordinate Y

    jr ra
    
### initializeCentroids
# Initializes the centroids vector with pseudo-random coordinates generated by the randomgencord function
# Arguments: none
# Return: none

initializeCentroids:
    la t0 centroids
    lw t1 k
    addi t1 t1 -1                             # Decrement K to count correctly from 0-2 (0,1,2) instead of (0,1,2,3)
    loopgencord:
        addi sp sp -12                        # Opens space on the stack to save temporary registers needed for this function
        sw t0 0(sp)
        sw t1 4(sp)
        sw ra 8(sp)                           # Save the return address
        jal randomgencord                     # Calls the random function that returns two random coordinates in s0 and s1
        lw t0 0(sp)
        lw t1 4(sp)
        lw ra 8(sp)                           # Restore the return address
        addi sp sp 12

        slli t2 t1 3                          # Bitshift used to calculate the offset for storing data in the centroids vector
        add t3 t0 t2                          # Adds the necessary offset to the base address of centroids
        sw s0 0(t3)                           # Stores the X coordinate in the centroids vector at the correct position
        sw s1 4(t3)                           # Store the Y coordinate in the centroids vector at the correct position

        addi t1 t1 -1                         # Decrement the counter K number of centroids
        bgez t1 loopgencord                   # Jump to the beginning if it is not yet less than zero
    jr ra


### generatevectorcluster
# Generates the clusters vector from the centroids and the nearestCluster function
# In the clusters vector, the data is stored as (id, x, y) where id is the cluster number and its coordinates
# Arguments: none
# Return: none

generatevectorcluster:
    
    li t2 0
    genloopvc:  
        la t1 points                          # Load the address of the points array
        slli t3 t2 3                          # Calculates the offset of 3 in the points vector (x, y)
        add t3 t1 t3                          # Adds the offset to the base address of the vector
        lw a0 0(t3)                           # Loads X coordinate
        lw a1 4(t3)                           # Loads Y coordinate
        addi sp sp -12                        # Opens space on the stack to save temporary registers
        sw t2 0(sp)
        sw ra 4(sp)
        sw t3 8(sp)
        jal nearestCluster                    # Calls the nearestCluster function to calculate the nearest cluster
        lw t2 0(sp)
        lw ra 4(sp)
        lw t3 8(sp)
        addi sp sp 12                         # Free space on the stack

        lw a1 0(t3)         
        lw a2 4(t3)

        la t0 clusters                        # Load the address of the clusters array
        slli t3 t2 4                          # Calculates the offset of 4 in the clusters vector (id, x, y)
        add t3 t0 t3                          # Add the offset to the base address of the clusters vector
        sw a0 0(t3)                           # Stores the cluster id
        sw a1 4(t3)                           # Store the x coordinate of the cluster
        sw a2 8(t3)                           # Store the y coordinate of the cluster

        addi t2 t2 1                          # Increment the cluster index
        lw t0 n_points                        # Load the number of points
        blt t2 t0 genloopvc                   # Check if all points have not been traversed yet

    jr ra

### checkcentroidsupdate
# Checks if there was a change in the centroids vector by comparing it with a previous copy
# Arguments: 
# a0: 0 to only update the vector 
# Return: a0 1 if there was a change

checkcentroidsupdate:

    beqz a0 updatevecor                       # If a0 is zero, go to updatevector


    lw t2 k                                   # Load the number of clusters
    addi t2 t2 -1               
    checkloop:                                # Loop to compare all clusters
        la t0 lastcentroids                   # Load the address of the vector lastcentroids
        la t1 centroids                       # Load the address of the centroids vector
        slli t3 t2 3                          # Calculate the offset of 3 in the centroids vector (x, y)
        add t0 t0 t3                          # Add the offset to the base address of the vector lastcentroids
        add t1 t1 t3                          # Add the offset to the base address of the centroids vector
        lw t3 0(t1)                           # Load the coordinates (x, y) of the pair of centroids
        lw t4 4(t1)
        lw t5 0(t0)
        lw t6 4(t0)
        bne t3 t5 vectormodified              # Check if there was a change in the x coordinate
        bne t4 t6 vectormodified              # Check if there was a change in the y coordinate
        addi t2 t2 -1               
        bgez t2 checkloop                     # Check if all points have not been traversed yet
        j updatevecor

    vectormodified:
        li a0 1                               # If there was a change, return 1

    updatevecor:    
        lw t2 k                               # Load the number of clusters
        addi t2 t2 -1           
        loopupdate:
            slli t3 t2 3                      # Calculates the offset of 3 in the centroids vector (x, y)
            la t0 lastcentroids               # Load the address of the vector lastcentroids
            la t1 centroids                   # Load the address of the centroids vector
            add t0 t0 t3                      # Add the offset to the base address of the vector lastcentroids
            add t1 t1 t3                      # Add the offset to the base address of the centroids vector
            lw t3 0(t1)                       # Load the coordinates (x,y) of the centroid
            lw t4 4(t1)
            sw t3 0(t0)                       # Stores the coordinates (x,y) of the centroid in lastcentroids
            sw t4 4(t0)             
            addi t2 t2 -1
            bgez t2 loopupdate                # Checks if all centroids have not been traversed yet

    jr ra

### mainKMeans
# Executes the k-means algorithm.
# Arguments: none
# Return: none

mainKMeans:  
    addi sp sp -8                   
    sw ra 0(sp)                               # Save the return address on the stack
    jal cleanScreen                           # Executes the functions for the first iteration of k-means
    jal initializeCentroids
    jal generatevectorcluster
    li a0 0                                   # Load the value 0 into the correct register so that the function checkcentroidsupdate only updates its vector and does not check it
    jal checkcentroidsupdate
    jal printClusters
    jal printCentroids

    lw s1 L                                   # Number or the maximum number of iterations of the algorithm
    Kmeansloop:
        sw s1 4(sp)                           # Save the counter on the stack
        jal cleanScreen
        jal calculateCentroids
        jal generatevectorcluster
        jal printClusters
        jal printCentroids

        li a0 2                               # A random value to verify the response of the function checkcentroidsupdate
        li a1 2
        jal checkcentroidsupdate 
        lw s1 4(sp)                           # Restore the counter 
        beq a0 a1 endkmeans                   # If the value of register a0 is not changed by the function checkcentroidsupdate, there is no update to the centroids, and the algorithm stops
        
        addi s1 s1 -1
        bgez s1 Kmeansloop

    endkmeans:   
        lw ra 0(sp)                           # Restore the return address
        addi sp sp 8
    jr ra
