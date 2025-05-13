#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

int main() {
    char message[101];
    int key = 0;
    char choice = '\0';
    int len;

    printf("Enter message (up to 100 characters): ");
    fgets(message, sizeof(message), stdin);

   
    size_t l = strlen(message);
    if (l > 0 && message[l - 1] == '\n') {
        message[l - 1] = '\0';
    }


    while (1) {
        char temp[10];
        printf("Enter key (1-25): ");
        fgets(temp, sizeof(temp), stdin);
        key = atoi(temp); 

        if (key >= 1 && key <= 25) {
            break;
        }
        else {
            printf("Invalid key. Please enter a number between 1 and 25.\n");
        }
    }

   
    while (1) {
        char temp[10];
        printf("Choose (E)ncrypt or (D)ecrypt: ");
        fgets(temp, sizeof(temp), stdin);

        if (strlen(temp) > 0) {
            choice = temp[0];
        }

        if (choice == 'E' || choice == 'e' || choice == 'D' || choice == 'd') {
            break;
        }
        else {
            printf("Invalid choice. Please enter E or D.\n");
        }
    }

    len = strlen(message);

    __asm {
        mov ecx, len
        lea esi, message

        loop_start :
        cmp ecx, 0
            je loop_end

            mov al, byte ptr[esi]
            cmp al, 'A'
                jl not_alpha
                cmp al, 'Z'
                jle upper_case

                cmp al, 'a'
                jl not_alpha
                cmp al, 'z'
                jle lower_case

                jmp not_alpha

                upper_case :
            cmp choice, 'E'
                je encrypt_upper
                cmp choice, 'e'
                je encrypt_upper
                jmp decrypt_upper

                encrypt_upper :
            add al, byte ptr key
                cmp al, 'Z'
                jle store_char
                sub al, 26
                jmp store_char

                decrypt_upper :
            sub al, byte ptr key
                cmp al, 'A'
                jge store_char
                add al, 26
                jmp store_char

                lower_case :
            cmp choice, 'E'
                je encrypt_lower
                cmp choice, 'e'
                je encrypt_lower
                jmp decrypt_lower

                encrypt_lower :
            add al, byte ptr key
                cmp al, 'z'
                jle store_char
                sub al, 26
                jmp store_char

                decrypt_lower :
            sub al, byte ptr key
                cmp al, 'a'
                jge store_char
                add al, 26
                jmp store_char

                store_char :
            mov byte ptr[esi], al

                not_alpha :
            inc esi
                dec ecx
                jmp loop_start

                loop_end :
    }

    printf("Output: %s\n", message);

    return 0;
}