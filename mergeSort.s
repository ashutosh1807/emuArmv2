.merge:
    ;REGISTERS THAT WILL BE USED IN THIS FUNCTION
    ;r1 = l
    ;r2 = m
    ;r3 = r
    ;r5 = i
    ;r6 = j
    ;r7 = k
    ;r8 = n1
    ;r9 = n2
    ;r4 = &L
    ;r10 = &R
    STMFD sp!, {r0, r1, r2, r3, LR}     ;save the state before entering method call
    @; int n1 = m - l + 1;
    SUB r8, r2, r1       ; r8 = r2-r1 = m-l 
    ADD r8 ,r8, #1       ; n1 = m-l+1
    @; int n2 = r - m;
    SUB r9, r3, r2       ; n2 = r3-r2 = r-m
    @ /* Copy data to temp arrays L[] and R[] */
    STMFD sp!, {r0, r1, r2, r3}
    @; for (i = 0; i < n1; i++)
    MOV r5, #0                  ; i = 0;
    .forL:
        CMP r5, r8                  ; i < n1?
        BGE .forLend               ;end loop if false
        @; L[i] = arr[l + i];
        ADD r2, r1, r5               ; r2 becomes r1 + 1, r2 = l + i
        LDR r3, [r0, r2, lsl #2]     ; r3 = *&A[(l+i)*4] = arr[l+i]
        STR r3, [r4, r5, lsl #2]      ; store arr[l+i] in L[i]
        ADD r5, r5, #1                ;i++
        B .forL
    .forLend:
       LDMFD sp!, {r0, r1, r2, r3}
    STMFD sp!, {r0, r1, r2, r3}
    @; for (i = 0; i < n1; i++)
    MOV r6, #0                  ; j = 0;
    .forR:
        CMP r6, r9                  ; j < n2?
        BGE .forRend               ; end loop if false
        @; R[j] = arr[m + 1 + j]; 
        ADD r1, r2, #1              ; m is in r2, so r1 becomes r2+1 which is m+1
        ADD r1, r1, r6               ; m+1 is in r1, r1 becomes m+1+j
        LDR r3, [r0, r1, lsl #2]     ; load r3 with *[base&A + (m+1+j)*4] aka arr[m+1+j]
        STR r3, [r10, r6, lsl #2]      ; store arr[m+1+j] in R[j], R[j] = arr[m + 1 + j]; 
        ADD r6, r6, #1                ; j++
        B .forR
    .forRend:      
       LDMFD sp!, {r0, r1, r2, r3} 
    @; /* Merge the temp arrays back into arr[l..r]*/
    @; i = 0; // Initial index of first subarray
    MOV r5, #0
    @; j = 0; // Initial index of second subarray 
    MOV r6, #0
    @; k = l; // Initial index of merged subarray 
    MOV r7, r1
    @; while (i < n1 && j < n2){
    .while1: 
        CMP r5, r8                  ; while i < n1 and...
        BGE .finishWhile1             ; end loop if above statement is false
        CMP r6, r9                  ; ... j < n2
        BGE .finishWhile1             ; end loop if above statement is false
        LDR r2, [r4, r5, lsl #2]      ; load r2 with *&L[i*4] (cause of 4 byte alignment)
        LDR r3, [r10, r6, lsl #2]      ; load r3 with *&R[j*4] (cause of 4 byte alignment) 
        ;/*after last instruction r2 holds L[i], r3 holds R[j] */
        @; if (L[i] <= R[j]){
        ;/* conditional assignment r2 = (L[i] <= R[j]) ? r2:r3 is more efficient */
        CMP r2, r3                 ; if (L[i] <= R[j])
        MOVGT r2, r3                 ; r2 is L[i] or R[j] conditionally
        @;     arr[k] = L[i]; 
        STR r2, [r0, r7, lsl #2]      ; store r2 in &A[k*4], A[k] = L[i] or R[j]
        @;     i++; 
        ADDLE r5, r5, #1                ; if r9 is L[i], i++
        @; } 
        @; else { 
        @;     arr[k] = R[j]; 
        @;     j++; 
        ADDGT r6, r6, #1                ; if r9 is R[j], j++ 
        @; } 
        @; k++; 
        ADD r7, r7, #1                ; k++
        B .while1                ; go to the start of the loop
    .finishWhile1:
        @; }
    @; /* Copy the remaining elements of L[], if there are any */
    @; while (i < n1){ 
    .while2: 
        CMP r5, r8
        BGE .while2end
        @;     arr[k] = L[i]; 
        LDR r2,[r4, r5, lsl #2]
        STR r2,[r0, r7, lsl #2]
        @;     i++; 
        ADD r5, r5, #1
        @;     k++; 
        ADD r7, r7, #1
        B .while2
        @; }
    .while2end:
        @; /* Copy the remaining elements of R[], if there are any */
        @; while (j < n2){ 
    .while3: 
        CMP r6, r9
        BGE .while3end
        @;     arr[k] = R[j]; 
        LDR r2, [r10, r6, lsl #2]
        STR r2, [r0, r7, lsl #2]
        @;     j++; 
        ADD r6, r6, #1
        @;     k++; 
        ADD r7, r7, #1
        B .while3
        @; } 
    .while3end:
    LDMFD sp!, {r0, r1, r2, r3, PC}

.mergeSort:
    STMFD sp!, {r0, r1, r2, LR} ;save the state before entering recursive call
    CMP r1, r2 ; is l less than r?
    BGE .mergeSortEnd ; if so end mergesort
    STMFD sp!, {r1, r2} ; save L and R
    SUB r2, r2, r1
    MOV r2, r2, ASR #1
    ADD r2, r2, r1 ; m = l + (r - l) / 2; 
    STMFD sp!, {r2}  ; save m
    BL .mergeSort
    LDMFD sp!, {r3, r1, r2} ; put m into r3 to use in m+1 operation, and estore l and r, r1=l and r2=r
    STMFD sp!,  {r1, r2, r3} ;save r1, r2 and m once again
    add r1, r3, #1 ;r1 = m+1   
    BL .mergeSort
    LDMFD sp!, {r1, r2, r3}
    STMFD sp!, {r2}          ;save r 
    MOV r2, r3         ;r2 = m
    LDMFD sp!, {r3}          ;r3 = r 
    BL .merge 
.mergeSortEnd:            
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
    ;	R1 = FIRST
    ;	R2 = LAST
    ;	R3 = MIDDLE
    MOV r0, #0 ; Memory address of array
    mov r4, #1000 ; Memory address of L[] - To be used in merge function
    MOV r10, #2000 ; Memory address of R[] - To be used in merge function
    MOV r1, #0 ; l
    MOV r2, #5 ; r = sizeOfArray -1
    BL .mergeSort
    ;/* this loop prints the array which should be sorted */
    MOV r5, #0 ;i==0
    .sorted:
        CMP r5, r2
        BEQ .done ;has the loop reached N iterations?, i < n
        LDR  r3, [r0], #4
        .print r3
        ADD  r5, r5, #1
        B .sorted
    .done:


