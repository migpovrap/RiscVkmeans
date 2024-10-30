.data

centroids:   .word 0,0, 10,0, 0,10 
k:           .word 3
#L:           .word 10

   
newline:  .string "\n"
space: .string " "


seed:       .word 12345
a:          .word 1664525
c:          .word 1013904223
m:          .word 32


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

    li a7 30
    ecall
    
    
    lw t0, seed
    add t0, t0, a0
    
    slli t1, a1, 16 
    add t0, t0, t1

    
    lw t1, a
    lw t2, c
    lw t3, m

   
    mul t4, t0, t1
    add t4, t4, t2
    rem t0, t4, t3
    la t5 seed
    sw t0  0(t5)
    bgez t0 positive1
    neg t0 t0
    positive1:
    add s0, t0, zero


    lw t0, seed
    lw t1, a
    lw t2, c
    lw t3, m

    mul t4, t0, t1
    add t4, t4, t2
    rem t0, t4, t3
    la t5 seed
    sw t0 0(t5)
    bgez t0 positive2
    neg t0 t0
    positive2:
    add s1, t0, zero

    jr ra
    
    
initializeCentroids:
    la t0 centroids
    lw t1 k
    addi t1 t1 -1
    loopgencord:
        addi sp sp -12
        sw t0 0(sp)
        sw t1 4(sp)
        sw ra 8(sp)
        jal randomgencord
        lw t0 0(sp)
        lw t1 4(sp)
        lw ra 8(sp)
        addi sp sp 12

        slli t2 t1 3 
        add t3 t0 t2
        sw s0 0(t3)
        sw s1 4(t3)

        addi t1 t1 -1
        bgez t1 loopgencord
    jr ra