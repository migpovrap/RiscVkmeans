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
calculateCentroids:
    li t0 1
    lw t1 k
    addi sp sp -4
    sw ra 0(sp)
    bne t1 t0 kmaior1cc
    k1cc:
        lw t1 n_points 
        addi t1 t1 -1
        li s1 0
        li s2 0
        k1loop:
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
        div s1 s1 t1
        div s2 s2 t1
        la a0 centroids
        sw s1 0(a0) 
        sw s2 4(a0)

    lw ra 0(sp)
    addi sp sp 4
    jr ra

    kmaior1cc:
        lw s1 k
        li s4 0
        loopkcluster:                
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
                    lw t1 0(t0)
                    lw t2 4(t0)
                    lw t3 8(t0)
                    addi t4 t4 -1
                    bne s1 t1 sumcords
                    add s2 s2 t2
                    add s3 s3 t3

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
            div s3 s3 s4

            la t0 centroids
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

            li s2 0
            li s3 0
            li s4 0
                                   
            bgez s1 loopkcluster

    fimloop:
    lw ra 0(sp)
    addi sp sp 4
    jr ra



#(With debug prints for the cluster ids and point)
### generatevectorcluster

generatevectorcluster:
    
    li t2 0
    genloopvc:  
        la t1 points
        slli t3 t2 3
        add t3 t1 t3
        lw a0 0(t3)
        lw a1 4(t3)
        addi sp sp -12
        sw t2 0(sp)
        sw ra 4(sp)
        sw t3 8(sp)
        jal nearestCluster
        lw t2 0(sp)
        lw ra 4(sp)
        lw t3 8(sp)
        addi sp sp 12

        lw a1 0(t3)         
        lw a2 4(t3)

        la t0 clusters
        slli t3 t2 4
        add t3 t0 t3
        sw a0 0(t3)
        sw a1 4(t3)
        sw a2 8(t3)

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

        addi t2 t2 1
        lw t0 n_points
        blt t2 t0 genloopvc

    jr ra
