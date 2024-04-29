;CREATE GRAPHICAL BORDER
border macro color,rbeg,rend,cbeg,cend
           mov ah,6h
           mov al,0
           mov bh,color
           mov ch,rbeg
           mov cl,cbeg
           mov dh,rend
           mov dl,cend
           int 10h
endm

;full screen bg
f_screen macro color
             mov ah,6h        ; draw box function
             mov al,00h       ; no of lines to scroll up
             mov bh, color
             mov cx,0
             mov dx,189fh     ;full src quadrant fill
             int 10h          ;interupt use for graphics
endm

;Msgs print
msg macro toprint
         lea dx,toprint
         mov ah,9
         int 21h
endm

;set new cursor position
new_position macro rpos,cpos
                 mov ah,2       ;print
                 mov bh,0       ;pg number
                 mov dh,rpos    ;set row to this new position
                 mov dl,cpos    ;set col to this new position
                 int 10h
endm

;---------------------------------------------Code Starts------------------------------------------------
.model small
.stack 100h
.data
 
    number      db 145d                                                     ;storing right answer in the var "number"

    ;Msg's to display
    welcome1    db " Welcome $"
    welcome2    db " To the World of NUMBER HUNTER $"
    instruction db "INSTRUCTION: $"
    range       db '( You have only 5 trials to guess the correct number )$'
    namemsg     db 'Enter Player Name: $'
    gameName    db '        NUMBER HUNTER!!!    $'
    attempt     db 'Attempts left: $'
    startMsg    db 'Please enter a number between 0 & 255: $'
    lessMsg     db '(Hint:  Value is Less) $'
    moreMsg     db '(Hint:  Value is More) $'
    overflowMsg db '(Error! - Number is out of given range) $'
    loser       db 'You loose the game as all Trials Ended! $'
    winner      db 'CONGRATS, You guess the Correct Number. $'
    retry       db 'Play Again [Press (Y/N) or (y/n) ] ? $'

    gamer       db 20 dup('$')
    guess       db ?                                                        ;variable used to store value user entered
    errorCheck  db ?                                                        ;variable to check if entered value is in range
    
 
.code
    ;Printing the title of game in a square graphical box
    ;1st screen interaction ( instruc msg + taking name as an input)
main proc
                    mov          ax,@data
                    mov          ds,ax

                    f_screen     00000100b                ;full screen bg
                    new_position 7,33                     ;set new cursor position

    ;Displaying introductory & input messages
                    msg          welcome1                 ;welcome msg
                    call         enterkey
                    call         double_tabkey
                    call         tabkey
                    ; call         tabkey
                    msg          welcome2
                    
                    new_position 12,0                     ;set new cursor position
                    msg          instruction              ;instruction msg
                    call         tabkey
                    msg          range
                    
                    new_position 17,0                     ;set new cursor position
                    msg          namemsg

                    mov          si, offset gamer

    data_inp:                                             ;taking name as input
                    mov          ah,1
                    int          21h
                    cmp          al,13
                    je           inp_end

                    mov          [si],al
                    inc          si
                    jmp          data_inp

    inp_end:        
                    f_screen     01100100b                ;full screen background

    ;border display
                    border       11000000b,0,0,0,90       ;top
                    border       11000000b,26,26,0,90     ;bottom
                    border       11000000b,2,2,0,90       ;title/heading bottom

    heading:        
                    border       00000100b,1,1,0,90       ;title content bg
                    new_position 1,25                     ;setting new cursor position

                    msg          gameName                 ;Displaying game as TITLE

    trial:          
                    new_position 2,0                      ;setting new cursor position

                    mov          bl,05                    ;setting no of trials as 5 (fixed)

    start:          
                    CMP          bl,0h                    ; comparing bl with 0
                    JE           loose
                    call         enterkey
                    msg          attempt
                    mov          dl, bl
                    add          dl,48
                    mov          ah, 2
                    int          21h
                    DEC          bl

 
                    mov          ax,@data
                    mov          ds,ax
 
    ;--BEGIN assigning 0 to all registers and variables.
                    mov          ax, 0
                    mov          cx, 0
                    mov          dx, 0
   
                    mov          si, OFFSET guess         ; get address of 'guess' variable in si.
                    mov          [si], ax                 ; set 'guess' to 0 (decimal)
 
                    mov          si, OFFSET errorCheck    ; get address of 'errorCheck' variable in si.
                    mov          [si], ax                 ; set 'errorCheck' to 0 (decimal)
    ; --- END assigning
 
                    mov          ax, @data                ; get address of data to AX
                    mov          ds, ax                   ; set 'data segment' to value of AX which is 'address of data'
                    call         enterkey

                    msg          startMsg
    
                    mov          cl, 0                    ; set CL to 0  (Counter)
                    mov          dx, 0                    ; set DX to 0  (Data register used to store user input)
                    JMP          while1

    loose:          

                    mov          ax, @data                ; get address of data to AX
                    mov          ds, ax                   ; set 'data segment' to value of AX which is 'address of data'

                    call         final_box
                    msg          loser
                    JMP          exit

    ; -- BEGIN reading user input
    while1:         
 
                    CMP          cl, 9d                   ; compare CL with 5d (5 is the maximum number of digits allowed)
                    JG           endwhile                 ; IF CL > 5 then JUMP to 'endwhile' label
 
                    MOV          ah, 1                    ; Read character from STDIN into AL (for DOS interrupt)
                    INT          21h                      ; DOS INT 21h (DOS interrupt)
 
                    CMP          al, 13                   ; compare input value with 0Dh which is ASCII code for ENTER key
                    JE           endwhile                 ; IF AL = 13,i.e Enter key pressed, JUMP to 'endwhile'
 
                    SUB          al, 30h                  ; subtract 30h from input ASCII value to get actual number.
                    MOV          dl, al                   ; Move input value to DL
                    PUSH         dx                       ; Push DL into stack, to get it read to read next input

                    INC          cl                       ; Increment CL (Counter)
                    JMP          while1                   ; JUMP back to label 'while' if reached


    endwhile:       
    ; -- END reading user input
 
                    DEC          cl                       ; decrement CL by one to reduce increament made in last iteration
 
                    CMP          cl, 02h                  ; compare CL with 02, because only 3 numbers can be accepted as IN RANGE
                    JG           overflow                 ; IF CL (number of input characters) is greater than 3 JUMP to 'overflow' label
 
                    MOV          si, OFFSET errorCheck    ; get address of 'errorCheck' variable in si.
                    MOV          [si], cl                 ; set 'errorCheck' to value of CL
 
                    MOV          cl, 0                    ; set CL to 0, because counter is used in next section again



    ; -- BEGIN processing user input
 
    ; -- Create actual NUMERIC representation of number read from user as three characters

    while2:         
 
                    CMP          cl,errorCheck
                    JG           endwhile2
 
                    POP          dx                       ; POP DX value stored in stack, (from least-significant-digit to most-significant-digit)
 
                    MOV          ch, 0                    ; clear CH which is used in inner loop as counter
                    MOV          al, 1d                   ; initially set AL to 1   (decimal)
                    MOV          dh, 10d                  ; set DH to 10  (decimal)
 
    ; -- BEGIN loop to create power of 10 for related position of digit
    ; --  IF CL is 2  (maximum condition)
    ; --   1st loop will produce  10^0
    ; --   2nd loop will produce  10^1
    ; --   3rd loop will produce  10^2
    while3:         
 
                    CMP          ch, cl                   ; compare CH with CL
                    JGE          endwhile3                ; IF CH >= CL, JUMP to 'endwhile3
 
                    MUL          dh                       ; AX = AL * DH whis is = to (AL * 10)
 
                    INC          ch                       ; increment CH
                    JMP          while3
 
    endwhile3:      
    ; -- END power calculation loop
 
    ; now AL contains 10^0, 10^1 or 10^2 depending on the value of CL
 
                    MUL          dl                       ; AX = AL * DL, which is actual positional value of number
 
                    JO           overflow                 ; If there is an overflow JUMP to 'overflow'label (for values above 300)
 
                    MOV          dl, al                   ; move result of multiplication to DL
                    ADD          dl, guess                ; add result (actual positional value of number) to value in 'guess' variable
 
                    JC           overflow                 ; If there is an overflow JUMP to 'overflow'label (for values above 255 to 300)
 
                    MOV          si, OFFSET guess         ; get address of 'guess' variable in si.
                    MOV          [si], dl                 ; set 'guess' to value of DL
 
                    INC          cl                       ; increment CL counter
 
                    JMP          while2                   ; JUMP back to label 'while2'
 
    endwhile2:      
    ; -- END processing user input
 
                    MOV          ax, @data                ; get address of data to AX
                    MOV          ds, ax                   ; set 'data segment' to value of AX which is 'address of data'
 
                    MOV          dl, number               ; load original 'number' to DL
                    MOV          dh, guess                ; load guessed 'number' to DH
 
                    CMP          dh, dl                   ; compare DH and DL (DH - DL)
 
                    JC           greater                  ; if DH (GUESS) < DL (NUMBER) comparision will cause a Carry. Becaus of that if carry has been occured print that 'number is more'
                    JE           equal                    ; IF DH (GUESS) = DL (NUMBER) print that guess is correct
                    JG           lower                    ; IF DH (GUESS) > DL (NUMBER) print that number is less


    equal:          

                    call         final_box
                    msg          winner
                    JMP          exit                     ; JUMP to end of the program
 
    greater:        
                    msg          moreMsg
                    call         enterkey
                    JMP          start                    ; JUMP to beginning of the program
 
    lower:          
                    msg          lessMsg
                    call         enterkey
 
                    JMP          start                    ; JUMP to beginning of the program
 
    overflow:       
                    call         enterkey
                    msg          overflowMsg
                    call         enterkey
    
                    JMP          start                    ; JUMP to beginning of the program

    exit:           
 
    ; -- Ask user if they want to play again if guess was successful
    retry_while:    
                    call         double_enterkey
                    call         double_tabkey

                    msg          retry

                    MOV          ah, 1                    ; Read character from STDIN into AL (for DOS interrupt)
                    INT          21h                      ; DOS INT 21h (DOS interrupt)
 
                    CMP          al, 110                  ; check if input is 'n'
                    JE           return_to_DOS            ; call 'return_to_DOS' label is input is 'n'

                    CMP          al, 78                   ; check if input is capital 'N'
                    JE           return_to_DOS            ; call 'return_to_DOS' label is input is 'n'
 
                    CMP          al, 121                  ; check if input is 'y'
                    JE           restart                  ; call 'restart' label is input is 'y' ..

                    CMP          al, 89                   ; check if input is capital 'Y'
                    JE           restart                  ; call 'restart' label is input is 'y' ..
                              
 
                    JMP          retry_while              ; if input is neither 'y' nor 'n' re-ask the same question
 
    retry_endwhile: 
 
    restart:        
                    sub          number,5d                ; Changing the Correct Answer Value
                    JMP          inp_end                  ; JUMP to begining of program
    return_to_DOS:  
                    f_screen     00001111b                ;full screen background

                    new_position 1,0                      ;setting new cursor position

                    MOV          ah, 4ch                  ; Return to ms-dos
                    INT          21h                      ; DOS INT 21h (DOS interrupt)
main endp                                                 ; EXIT from Register

    ;`````````````````````````````````````PROCEDURE STARTS FROM HERE```````````````````````````````````````

    ;ENTER KEY
enterkey proc

                    MOV          dx,10
                    MOV          ah,2
                    INT          21h
                    MOV          dx,13
                    MOV          ah,2
                    INT          21h

                    RET
enterkey endp

    ;Twice Time ENTER KEY
double_enterkey proc

                    MOV          dx,10
                    MOV          ah,2
                    INT          21h
                    MOV          dx,13
                    MOV          ah,2
                    INT          21h

                    MOV          dx,10
                    MOV          ah,2
                    INT          21h
                    MOV          dx,13
                    MOV          ah,2
                    INT          21h

                    RET
double_enterkey endp

    ;TAB KEY
tabkey proc
                    mov          dx,9
                    mov          ah,2
                    int          21h
                    ret
tabkey endp

    ;Twice Time TAB KEY
double_tabkey proc
                    mov          dx,9
                    mov          ah,2
                    int          21h

                    mov          dx,9
                    mov          ah,2
                    int          21h
                    ret
double_tabkey endp

    ;FINAL MSGS BOX AT CENTER OF SCREEN
final_box proc
                    border       0000110b,8,16,10,70      ;box appear
                    mov          ah,2                     ;print
                    mov          bh,0                     ;pg number
                    mov          dh,10                    ;set row to this new position
                    mov          dl,13                    ;set col to this new position
                    int          10h

                    lea          dx,gamer
                    mov          ah,9
                    int          21h
                   
                    call         double_enterkey
                    call         double_tabkey
                    ret
final_box endp

end main                                    ;EXIT
