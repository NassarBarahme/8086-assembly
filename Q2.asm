.model small
.stack 100h

.data
    prompt1 db 13,10,'Enter first string (max 20 chars):$'
    prompt2 db 13,10,'Enter second string (max 20 chars):$'
    result_msg db 13,10,'Concatenated result: $'

    string1 db 21
            db ?
            db 21 dup(?)

    string2 db 21
            db ?
            db 21 dup(?)

    s3 db 42 dup('$')

.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax

  
    mov ah, 09h
    lea dx, prompt1
    int 21h

    mov ah, 0Ah
    lea dx, string1
    int 21h

    
    mov si, offset string1 + 2
    mov al, string1 + 1
    xor ah, ah
    add si, ax
    mov byte ptr [si], 0

    
    mov ah, 09h
    lea dx, prompt2
    int 21h

    mov ah, 0Ah
    lea dx, string2
    int 21h

    
    mov si, offset string2 + 2
    mov al, string2 + 1
    xor ah, ah
    add si, ax
    mov byte ptr [si], 0

   
    lea ax, string2 + 2
    push ax
    lea ax, string1 + 2
    push ax
    call concat
    add sp, 4

   
    mov ah, 09h
    lea dx, result_msg
    int 21h

    lea dx, s3
    int 21h

    
    mov ah, 4Ch
    int 21h


concat proc near
    push bp
    mov bp, sp
    sub sp, 4          
    push bx
    push cx
    push dx
    push si
    push di

    
    mov si, [bp+4] 
    mov di, [bp+6] 

   
skip_space1:
    mov al, [si]
    cmp al, ' '
    jne done_skip1
    inc si
    jmp skip_space1
done_skip1:
    mov word ptr [bp-2], si   

skip_space2:
    mov al, [di]
    cmp al, ' '
    jne done_skip2
    inc di
    jmp skip_space2
done_skip2:
    mov word ptr [bp-4], di   

    
    mov bx, 0
    mov si, word ptr [bp-2]
    push si
count1:
    cmp byte ptr [si], 0
    je len1_done
    inc si
    inc bx
    jmp count1
len1_done:
    pop si

    mov cx, 0
    mov di, word ptr [bp-4]
    push di
count2:
    cmp byte ptr [di], 0
    je len2_done
    inc di
    inc cx
    jmp count2
len2_done:
    pop di

    
    cmp bx, cx
    jle s1_first

    
    lea bx, s3
    mov si, word ptr [bp-4]
    call strcpy
    dec bx
    mov si, word ptr [bp-2]
    call strcpy
    jmp concat_done

s1_first:
    lea bx, s3
    mov si, word ptr [bp-2]
    call strcpy
    dec bx
    mov si, word ptr [bp-4]
    call strcpy

concat_done:
    
    mov byte ptr [bx-1], '$'

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
concat endp


strcpy proc near
    push ax
copy_loop:
    lodsb
    mov [bx], al
    inc bx
    test al, al
    jnz copy_loop
    pop ax
    ret
strcpy endp

end start
