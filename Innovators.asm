;Program Description: Tic Tac Toe Game
include emu8086.inc

.data  

    game_draw  	       db "    |   |   ",0dh, 0ah,
	               db "    |   |   ",0dh, 0ah,
		       db "    |   |   ",0dh, 0ah,
		       db " ---+---+---",0dh, 0ah,
		       db "    |   |   ",0dh, 0ah,
    	      	       db "    |   |   ",0dh, 0ah,
		       db "    |   |   ",0dh, 0ah,
		       db " ---+---+---",0dh, 0ah,
		       db "    |   |   ",0dh, 0ah,
	               db "    |   |   ",0dh, 0ah,
		       db "    |   |   ",0dh, 0ah, "$"  
                  
    new_line db 0dh, 0ah, "$"

    positions db 9 DUP(?)                      ;store offsets of each position
    
    isWin db 0                                 ;true or false
     
    player db "0$" 
    
    game_over_message db "CONGRAULATION", "$"
        
    game_start_message db "TIC TAC TOE", "$"
    
    player_message db "PLAYER $"   
    
    win_message db " WIN!$"   
    
    type_message db "ENTER A POSITION: $"
    
    pos_error_message db "This Position in use", 0dh, 0ah,
                      db "Type Another Position: $"
    
    count db 9  
ends

.code
start:
    ; set segment registers
    mov     ax, data
    mov     ds, ax

    ; game start   
    call    set_positions
     
main PROC
    dec count
     
    call    clear_screen   
    
    mov     dx, offset game_start_message 
    call    print
    
    mov     dx, offset new_line 
    call    print
    
    mov     dx, offset new_line
    call    print                       
    
    mov     dx, offset player_message
    call    print
    
    mov     al, player
    add     al, 1
    putc    al
    
    mov     dx, offset new_line
    call    print    
    
    mov     dx, offset game_draw
    call    print    
    
    mov     dx, offset new_line
    call    print    
    
    mov     dx, offset type_message    
    call    print            
    
   label:
                        
    ; read draw position                   
    call    read_keyboard
                        
    ; calculate draw position                   
    sub     al, 49               
    mov     bh, 0
    mov     bl, al
    
    call    check_cell                                  
                                  
    call    update_draw                                    
                                                          
    call    check_line  
                       
    ; check if game ends                   
    cmp     isWin, 1  
    je      game_over  
    
    call    change_player 
    
    cmp     count, 0
    je      game_end
            
    jmp     main
main ENDP   

change_player proc   
    mov     si, offset player     ; Used to load the offset player into si register
    xor     [si], 1               ; make turn for each player player0 -> player1   player1 -> player0
    
    ret
change_player ENDP          

update_draw proc
    mov     bl, positions[bx] 
    mov     bh, 0
    
    mov     si, offset player
    
    cmp     [si], "0"
    je      draw_x     
                  
    cmp     [si], "1"
    je      draw_o              
                  
    draw_x:
    mov     cl, "x"
    jmp     update

    draw_o:          
    mov     cl, "o"  
    jmp     update    
          
    update:         
    mov     [bx], cl
      
    ret
update_draw ENDP

check_cell proc    
    mov     bl, positions[bx] 
    mov     bh, 0
    
    cmp     [bx], "x"
    je      try_again
    
    cmp     [bx], "o"
    je      try_again
    
    mov     bh, 0
    mov     bl, al
    
    ret
    
    try_again:
    mov     dx, offset new_line
    call    print
    
    mov     dx, offset pos_error_message
    call    print
    
    jmp     label
check_cell ENDP
     
check_line proc
    mov     cx, 0
    
    check_line_loop:     
    cmp     cx, 0
    je      first_line
    
    cmp     cx, 1
    je      second_line
    
    cmp     cx, 2
    je      third_line  
     
    ;cmp     isWin 1 
    call    check_column
    ret    
        
    first_line:    
    mov     si, 0   
    jmp     do_check_line   

    second_line:    
    mov     si, 3
    jmp     do_check_line
    
    third_line:    
    mov     si, 6
    jmp     do_check_line        

    do_check_line:
    inc     cx
  
    mov     bh, 0
    mov     bl, positions[si]
    mov     al, [bx]
    cmp     al, " "
    je      check_line_loop
    
    inc     si
    mov     bl, positions[si]    
    cmp     al, [bx]
    jne     check_line_loop 
      
    inc     si
    mov     bl, positions[si]  
    cmp     al, [bx]
    jne     check_line_loop
                 
                         
    mov     isWin, 1
    ret                
check_line ENDP  
    
check_column PROC
    mov     cx, 0
    
    check_column_loop:     
    cmp     cx, 0
    je      first_column
    
    cmp     cx, 1
    je      second_column
    
    cmp     cx, 2
    je      third_column  
    
    call    check_diagonal
    ret    
        
    first_column:    
    mov     si, 0   
    jmp     do_check_column   

    second_column:    
    mov     si, 1
    jmp     do_check_column
    
    third_column:    
    mov     si, 2
    jmp     do_check_column        

    do_check_column:
    inc     cx
  
    mov     bh, 0
    mov     bl, positions[si]
    mov     al, [bx]
    cmp     al, " "
    je      check_column_loop
    
    add     si, 3
    mov     bl, positions[si]    
    cmp     al, [bx]
    jne     check_column_loop 
      
    add     si, 3
    mov     bl, positions[si]  
    cmp     al, [bx]
    jne     check_column_loop
                 
                         
    mov     isWin, 1
    ret
check_column ENDP  

check_diagonal PROC 
    
     mov     cx, 0
  
    check_diagonal_loop:     
    cmp     cx, 0
    je      first_diagonal
    
    cmp     cx, 1
    je      second_diagonal                         
    
    ret    
        
    first_diagonal:    
    mov     si, 0                
    mov     dx, 4
    jmp     do_check_diagonal   

    second_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     do_check_diagonal       

    do_check_diagonal:
    inc     cx
  
    mov     bh, 0
    mov     bl, positions[si]
    mov     al, [bx]
    cmp     al, " "
    je      check_diagonal_loop
    
    add     si, dx
    mov     bl, positions[si]    
    cmp     al, [bx]
    jne     check_diagonal_loop 
      
    add     si, dx
    mov     bl, positions[si]  
    cmp     al, [bx]
    jne     check_diagonal_loop
                 
                         
    mov     isWin, 1
    ret  
check_diagonal ENDP  

game_over PROC 
    call    clear_screen       
    
    call    change_background_color
    
    mov     dx, offset game_start_message 
    call    print
    
    mov     dx, offset new_line
    call    print
    
    mov     dx, offset new_line
    call    print                          
    
    mov     dx, offset game_draw
    call    print    
    
    mov     dx, offset new_line
    call    print

    mov     dx, offset game_over_message
    call    print
    
    mov     dx, offset new_line
    call    print  
    
    mov     dx, offset player_message
    call    print
    
    mov     dx, offset player
    call    print
    
    mov     dx, offset win_message
    call    print
    
    

    jmp     game_end    
game_over  ENDP   
    
set_positions PROC
    mov     si, offset game_draw ; 
    add     si, 16
    lea     bx, positions  
        
    mov     cx, 9   
    
    loop_1:
    cmp     cx, 6
    je      add_44                
    
    cmp     cx, 3
    je      add_44
    
    jmp     add_4 
    
    add_44:
    add     si, 44
    jmp     add_4     
      
    add_4:                                
    mov     [bx], si 
    add     si, 4
                        
    inc     bx               
    loop    loop_1 
 
    ret  
set_positions ENDP

print:      ; print dx content  
    mov     ah, 9
    int     21h   
    
    ret 
        
;============================================================;
; Read from keyboard                                         ;
; Receives: on input from user and store input in al         ;
;============================================================;    
read_keyboard:  ; read keybord and return content in al
    mov     ah, 1       
    int     21h  
    
    ret
    
;============================================================;
; Change Background Color If any player win                  ;
;============================================================;
change_background_color:
    mov     ah, 09
    mov     bh, 00
    mov     al, 20h
    mov     cx, 800h
    mov     bl, 02Fh   ; 02f green Color
    int     10h
    
    ret        
        
game_end: endp
          
code ends

DEFINE_CLEAR_SCREEN

end start
