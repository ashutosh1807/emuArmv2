; Author Ashutosh Agarwal
.main:
    MOV sp, #100000 ; initialise sp
    ;Hardcode an array
    MOV r1, #3
    STR r1, [r0], #4
    MOV r1, #6
    STR r1, [r0], #4
    MOV r1, #8
    STR r1, [r0], #4
    MOV r1, #12
    STR r1, [r0], #4
    MOV r1, #17
    STR r1, [r0], #4
    MOV r1, #22
    STR r1, [r0], #4
    MOV r1, #45
    STR r1, [r0], #4
    MOV r1, #67
    STR r1, [r0], #4
    MOV r1, #99
    STR r1, [r0], #4
    MOV r1, #2089
    STR r1, [r0], #4
    MOV r1, #30001
    STR r1, [r0], #4

    ;REGISTERS THAT WILL BE USED THROUGHOUT THE CODE
    ;	R1 = FIRST
    ;	R2 = LAST
    ;	R3 = MIDDLE
    ;	R4 = THE KEY
    ;	R5 = ADDRESS OF THE LIST
    ;   R6 = Index of location (-1 if not present)
    ;   R7 = arr[mid]

    MOV r5, #0 ; Memory address of array
    MOV r1, #0 ; lb
    MOV r2, #10 ; ub = sizeOfArray -1
    MOV r4, #99 ; <================ Enter desired search value here
    MOV r6, #-1 ; If not present index has to be -1
    BL .recursiveBinarySearch
    BL .stop

.recursiveBinarySearch:
    CMP r1, r2 ; r1 > r2 ?
    MOVGT pc, lr
    ADD r3, r1, r2 ; first + last
	MOV r3, r3, ASR #1 ; (first + last) / 2
    LDR r7, [r5, r3, lsl #2]
    CMP r7, r4 ; arr[mid] > sear ?
    MOVEQ r6, r3
    MOVEQ pc, lr
    SUBGT r2, r3, #1 ; ub = half - 1
    ADDLT r1, r3, #1 ; lb = half + 1
    STMFD sp!, {lr}
    BL .recursiveBinarySearch
    LDMFD sp!, {pc}

    .stop:
        .print r6