.MODEL SMALL
.STACK 100H
.DATA
    num DB ?
    prompt DB 'Enter an integer (-128 to +127): $'
    errorMsg DB 13,10,'Out of range!.$'
    resultMsg DB 13,10,'Inverse: $'
    nanMsg DB 'NaN$'
    decimal DB '0.000$'
    isInvalid DB 0    

READINT MACRO numVar
    LOCAL input_loop, check_negative, positive_num, check_range, valid, invalid
    
    
    MOV AH, 09H
    LEA DX, prompt
    INT 21H
    
    XOR BX, BX       
    MOV CL, 0        
    MOV isInvalid, 0 
    
    
    MOV AH, 01H
    INT 21H
    
    
    CMP AL, '-'
    JNE positive_num
    MOV CL, 1        
    JMP input_loop
    
positive_num:
    CMP AL, '0'
    JB invalid
    CMP AL, '9'
    JA invalid
    SUB AL, '0'
    MOV BL, AL
    
input_loop:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE check_range
    
    CMP AL, '0'
    JB invalid
    CMP AL, '9'
    JA invalid
    
    SUB AL, '0'
    MOV CH, AL
    
    MOV AL, BL
    MOV AH, 10
    IMUL AH
    JO invalid
    ADD AL, CH
    JO invalid
    MOV BL, AL
    JMP input_loop
    
check_range:
    CMP CL, 1
    JNE check_positive
    CMP BL, 128
    JA invalid
    NEG BL          
    JMP valid
    
check_positive:
    CMP BL, 127
    JA invalid
    
valid:
    MOV numVar, BL
    JMP done
    
invalid:
    MOV isInvalid, 1 
    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H
    MOV numVar, 0
    
done:
ENDM

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    READINT num
    
    
    CMP isInvalid, 1
    JE exit         
    
    MOV AH, 09H
    LEA DX, resultMsg
    INT 21H
    
    CMP num, 0
    JE show_nan
    
    
    MOV AL, num
    CBW
    MOV BX, AX
    
    
    MOV decimal, '0'
    MOV decimal+1, '.'
    MOV decimal+2, '0'
    MOV decimal+3, '0'
    MOV decimal+4, '0'
    MOV decimal+5, '$'
    
    CMP BX, 0
    JGE positive
    MOV decimal, '-'
    NEG BX
    LEA SI, decimal
    JMP calculate
    
positive:
    LEA SI, decimal
    
calculate:
    MOV AX, 1000
    CWD
    IDIV BX
    
   
    MOV CX, 3
    LEA DI, decimal+4
    
digit_loop:
    MOV DX, 0
    MOV BX, 10
    DIV BX
    ADD DL, '0'
    MOV [DI], DL
    DEC DI
    LOOP digit_loop
    
    MOV AH, 09H
    MOV DX, SI
    INT 21H
    JMP exit
    
show_nan:
    MOV AH, 09H
    LEA DX, nanMsg
    INT 21H
    
exit:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN