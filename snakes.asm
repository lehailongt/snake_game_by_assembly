
.model small
.stack 100h
.data
     hd1 db '       X    Snake game    O         $'
     hd2 db 'huong dan cach di chuyen con ran X  $'
     hd4 db 'w : di len tren      $'
     hd5 db 'a : di sang trai     $'
     hd6 db 's : di xuong duoi    $'
     hd7 db 'd : di sang phai     $'
     hd8 db 'chu y:                                    $'
     hd9 db 'phim bam khong hop le se bi bo qua        $'
     hd10 db 'ran co the di lui duoc                   $'
     hd11 db 'an ban ki phim gi de bat dau choi......  $'
     kq1 db 'so diem ban da dat duoc: $'
     kq2 db 'Chuc mung ban da chien thang tro choi$'
     diem1 db 'Score : $'
     dong db 13, 10, '$'
     begin_row db 5
     end_row db 20
     begin_column db 20
     end_column db 60
     snake_x db 10
     snake_y db 40
     toa_do_x db 100 dup(?)
     toa_do_y db 100 dup(?)
     app_x db ?
     app_y db ?
     len_snake db 0
     score db 0
     score_max db 8
.code

ngau_nhien macro a, b, c
    local ket
    mov ah, 0
    int 1ah
    mov ax, 0
    mov al, dl
    mov bl, b
    sub bl, 2
    div bl
    cmp ah, a
    jg ket
    add ah, a
    add ah, 3
    ket:
    mov al, ah
    mov ah, 0
    mov bl, 2
    div bl
    mov ah, 0
    mul bl
    mov c, al
ngau_nhien endm

toa_do_moi macro a, b 
    local lap, ket
    mov ch, 0
    mov cl, len_snake
    lea di, a
    lea si, a
    inc si
    lap: 
        dec cx
        cmp cx, 0
        jng ket
        mov dx, [si] 
        mov [di], dx
        inc si
        inc di
        jmp lap
    ket:
    mov dl, b
    mov [di], dl
toa_do_moi endm 

them_toa_do_snake macro a, b  
    mov ch, 0
    mov cl, len_snake
    lea di, toa_do_x
    add di, cx
    mov dl, a
    mov [di], dl
    lea di, toa_do_y
    add di, cx
    mov dl, b
    mov [di], dl
    inc cl
    mov len_snake, cl
them_toa_do_snake endm

gan_toa_do macro a, b, c
    pusha
    mov ah, 2
    mov bh, 0
    mov dh, a
    mov dl, b
    int 10h
    mov ah, 2
    mov dl, c
    int 21h
    popa   
gan_toa_do endm

main proc
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    ;call border
    call huongdan
    mov ah, 1
    mov cx, 2600h
    int 10h
    mov ah, 1
    int 21h
    call choi

    mov ah, 4ch
    int 21h    
main endp

choi proc
    mov ax, 0003h
    int 10h
    call border
    call hiendiem
    them_toa_do_snake snake_x, snake_y
    call sinh_apple
    call in_ran
    mov ah, 1
    mov cx, 2600h
    int 10h
    game_loop:
        mov ah, 8
        int 21h
        cmp al, 'w'
        je len_tren
        cmp al, 's'
        je xuong_duoi
        cmp al, 'a'
        je sang_trai
        cmp al, 'd'
        je sang_phai
        jmp game_loop
        
    len_tren:
        dec snake_x
        jmp check
    xuong_duoi:
        inc snake_x
        jmp check
    sang_trai:
        sub snake_y, 2
        jmp check
    sang_phai:
        add snake_y, 2
        jmp check
            
    check:
        mov dh, snake_x
        mov dl, snake_y
        
        cmp dh, begin_row
        je game_over
        cmp dh, end_row
        je game_over
        cmp dl, begin_column
        je game_over
        cmp dl, end_column
        je game_over
        
        cmp dh, app_x
        jne lap_tiep
        cmp dl, app_y
        jne lap_tiep
        jmp an
    an: 
        them_toa_do_snake snake_x, snake_y
        mov dl, score 
        inc dl
        mov score, dl
        cmp dl, score_max
        je call ket_thuc
        call sinh_apple
        jmp lap_tiep
    lap_tiep:
        call hiendiem 
        lea di, toa_do_x
        lea si, toa_do_y
        gan_toa_do [di], [si], ' '
        toa_do_moi toa_do_x, snake_x
        toa_do_moi toa_do_y, snake_y
        call in_ran
        gan_toa_do app_x, app_y, 'O'
        jmp game_loop
    game_over: 
        call ket_thuc 
    ret     
choi endp

sinh_apple proc
    ngau_nhien begin_row, end_row, app_x
    ngau_nhien begin_column, end_column, app_y
    gan_toa_do app_x, app_y, 'O'
    ret
sinh_apple endp

in_ran proc
    lea di, toa_do_x
    lea si, toa_do_y 
    mov ch, 0
    mov cl, len_snake
    cmp cx, 1
    jng ket
    gan_toa_do [di], [si], '.'
    inc di
    inc si
    lapin:
        dec cx
        cmp cx, 1
        jng ket
        gan_toa_do [di], [si], 'x' 
        inc si
        inc di
        jmp lapin
    ket:  
        gan_toa_do [di], [si], 'X'
    ret
in_ran endp 

ket_thuc proc
    mov ax, 3
    int 10h
    mov ah, 2
    mov bh, 0
    mov dh, 10
    mov dl, 20
    int 10h 
    mov ah, 9
    mov dl, score
    cmp dl, score_max
    jl thua
    lea dx, kq2
    int 21h
    jmp het
    thua:
    lea dx, kq1
    int 21h
    mov ah, 2
    mov dl, score
    add dl, '0'
    int 21h
    het:
    ret
ket_thuc endp 

hiendiem proc
    mov ah, 2
    mov bh, 0
    mov dh, 3
    mov dl, 35
    int 10h
    mov ah, 9
    lea dx, diem1
    int 21h
    mov ah, 2
    mov dh, 0
    mov dl, score
    add dx, '0'
    int 21h
    ret
hiendiem endp

huongdan proc
    mov ah, 13h
    mov bh, 0
    mov dl, begin_column
    add dl, 2
    mov dh, begin_row
    add dh, 2
    mov bl, 07h
    
    mov cx, 35
    lea bp, hd1
    int 10h
    add dh, 2
    lea bp, hd2
    int 10h
    
    mov cx, 20
    add dl, 10
    add dh, 1
    lea bp, hd4 
    int 10h
    add dh, 1
    lea bp, hd5
    int 10h  
    add dh, 1
    lea bp, hd6
    int 10h
    add dh, 1
    lea bp, hd7
    int 10h
    
    mov cx, 40
    sub dl, 10
    add dh, 1
    lea bp, hd8
    int 10h
    add dl, 5
    add dh, 1
    lea bp, hd9
    int 10h
    add dh, 1
    lea bp, hd10
    int 10h
    add dh, 1
    lea bp, hd11
    int 10h
    
    ret
huongdan endp

border proc
    pusha
    mov ah, 2
    mov dh, begin_row
    mov dl, begin_column
    int 10h
     
    mov ah, 0ah
    mov bh, 0
    mov al, '#'
    mov ch, 0
    mov cl, end_column
    sub cl, begin_column
    int 10h
    
    mov ah, 2
    mov dh, end_row
    mov dl, begin_column
    int 10h
    
    mov ah, 0ah
    mov bh, 0
    mov al, '#'
    mov ch, 0
    mov cl, end_column
    sub cl, begin_column
    int 10h
    mov cl, begin_row
    mov dl, begin_column 
    
    lap:
        gan_toa_do cl, begin_column, '#'
        gan_toa_do cl, end_column, '#'
        inc cl 
        cmp cl, end_row
        jng lap
        
    popa
    ret
border endp