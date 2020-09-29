; Author Ashutosh Agarwal
.quickSort:
    ;r5 = i
    ;r6 = j
    ;r7 = high - 1
    STMFD sp!, {r0, r1, r2, LR} ;save the state before entering recursive call
    CMP r1, r2 ; is low less than high?
    BGT .quickSortEnd
    STMFD sp!, {r0, r1, r2}
    LDR r3, [r0, r2, lsl #2]  @ r3 <- a[high]
    SUB r5, r1, #1 ;i = low - 1
    MOV r6, r1 ; j = low
    SUB r7, r2, #1 ;n1 = high - 1
    .partition:
        ;r4 = tmp
        CMP r6, r7
        BGT .finshPartition
        LDR r2, [r0, r6, lsl #2] ; r2 <- arr[j]
        CMP r2, r3
        ADDGE r6, r6, #1
        BGE .partition
        ADD r5, r5, #1
        LDR r1, [r0, r5, lsl #2] ; r1 <- arr[i]
        STR r1, [r0, r6, lsl #2]
        STR r2, [r0, r5, lsl #2]
        ADD r6, r6, #1 
        B .partition
    .finshPartition:
        LDMFD sp!, {r0, r1, r2}
        ADD r5, r5, #1 
        LDR r4, [r0, r5, lsl #2] ; swap(&arr[i + 1], &arr[high]); 
        STR r3, [r0, r5, lsl #2]
        STR r4, [r0, r2, lsl #2] 
        MOV r3, r5 ; pivot = (i+1)
    STMFD sp!, {r0, r1, r2, r3}
    SUB r2, r3, #1
    BL .quickSort
    LDMFD sp!, {r0, r1, r2, r3}
    STMFD sp!, {r0, r1, r2, r3}
    ADD r1, r3, #1
    BL .quickSort
    LDMFD sp!, {r0, r1, r2, r3}

.quickSortEnd:
    LDMFD sp!, {r0, r1, r2, PC}  @ notice put LR into PC to force return

main:
    MOV sp, #100000 ; initialise sp
    ;Hardcode an array
    MOV r1, #8
    STR r1, [r0], #4
    MOV r1, #12
    STR r1, [r0], #4
    MOV r1, #9
    STR r1, [r0], #4
    MOV r1, #3
    STR r1, [r0], #4
    MOV r1, #22
    STR r1, [r0], #4
    MOV r1, #17
    STR r1, [r0], #4
    ;REGISTERS THAT WILL BE USED THROUGHOUT THE CODE
    ;   RO = ADDRESS OF THE LIST
    ;	R1 = LOW
    ;	R2 = HIGH
    ;   R3 = PIVOT
    MOV r0, #0 ; Memory address of array
    MOV r1, #0 ; l
    MOV r2, #5 ; r = sizeOfArray -1
    BL .quickSort
    ;/* this loop prints the array which should be sorted */
    MOV r5, #0 ;i==0
    .sorted:
        CMP r5, r2
        BGT .done ;has the loop reached N iterations?, i < n
        LDR  r3, [r0], #4
        .print r3
        ADD  r5, r5, #1
        B .sorted
    .done: