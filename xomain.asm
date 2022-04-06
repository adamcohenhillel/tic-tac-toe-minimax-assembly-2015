;Adam Cohen Hillel ExEgol Project
;Build At: April 2015
;Herzog School, Kfar Sava
;Gvahim
;
IDEAL
;-------------------------------------------------------------
; PRINT_Vertical_LINE - print on Screen A vertical (|) Line
;-------------------------------------------------------------
; Input:
; 	xstart   
;   ystart  
;	len
; Output:
; 	vertical Line On Screen
; Registers Used
;	  BX, CX, AX, DX
;  
;----------------------------------------------------------	
MACRO PRINT_Vertical_LINE xstart, ystart, len
	local @@PrintAnahiLineLoop
	
	mov cx, len
	xor bx, bx
	@@PrintAnahiLineLoop:
	push cx
	push bx
	
	add bx, ystart
	mov dx,bx ;dx - y
	mov cx, xstart ;cx - x
	mov bh,0h
	mov al,[colorLine]
	mov ah,0ch
	int 10h
	
	pop bx
	push bx
	
	add bx, ystart
	mov dx,bx ;dx - y
	mov cx, xstart+1 ;cx - x
	mov bh,0h
	int 10h
	
	pop bx
	inc bx
	pop cx
	loop @@PrintAnahiLineLoop
	
ENDM PRINT_Vertical_LINE

;-------------------------------------------------------------
; PRINT_Horizontal_LINE - print on Screen A Horizontal (-) Line
;-------------------------------------------------------------
; Input:
; 	xstart   
;   ystart  
;	len
; Output:
; 	Horizontal Line On Screen
; Registers Used
;	  BX, CX, AX, DX
;  
;----------------------------------------------------------	
MACRO PRINT_Horizontal_LINE xstart, ystart, len
	local @@PrintOfkeLineLoop
	
	mov cx, len
	xor bx, bx
	@@PrintOfkeLineLoop:
	push cx
	push bx
	
	add bx, xstart
	mov dx,ystart ;dx - y
	mov cx, bx ;cx - x
	mov bh,0h
	mov al,[colorLine]
	mov ah,0ch
	int 10h
	
	pop bx
	push bx
	
	add bx, xstart
	mov dx, ystart +1 ;dx - y
	mov cx, bx ;cx - x
	mov bh,0h
	int 10h
	
	pop bx
	inc bx
	pop cx
	loop @@PrintOfkeLineLoop
	
ENDM PRINT_Horizontal_LINE

macro PUSH_PARAMS
	
	xor ah,ah
	mov al,[tempT+0]
	push ax
	mov al,[tempT+1]
	push ax
	mov al,[tempT+2]
	push ax
	mov al,[tempT+3]
	push ax
	mov al,[tempT+4]
	push ax
	mov al,[tempT+5]
	push ax
	mov al,[tempT+6]
	push ax
	mov al,[tempT+7]
	push ax
	mov al,[tempT+8]
	push ax
	
	push dx

endm

macro GET_PARAMS
	 
	mov dx,[bp+4]

	mov ax,[bp+6]
	mov [tempT+8],al
	mov ax,[bp+8]
	mov [tempT+7],al
	mov ax,[bp+10]
	mov [tempT+6],al
	mov ax,[bp+12]
	mov [tempT+5],al
	mov ax,[bp+14]
	mov [tempT+4],al
	mov ax,[bp+16]
	mov [tempT+3],al
	mov ax,[bp+18]
	mov [tempT+2],al
	mov ax,[bp+20]
	mov [tempT+1],al
	mov ax,[bp+22]
	mov [tempT+0],al

endm

CurrentScore equ [byte bp-2]   ; check if -3 is the right one

MODEL small
STACK 100h

DATASEG
; --------------------------
BoolXORO db 'X'
TheMatz db    "---"
		db    "---"
		db    "---"  

		tempT db "---------"
		maxScore db ?
		
OwinMessage    	db 13,10,10,"   ********* O Is The Winner *********$"
XwinMessage    	db 13,10,10,"   ********* X Is The Winner *********$"
NoWin           db 13,10,10,"  ********There is no winner *********$" 
oneTriple db "---"

OisPlaying    	db 13,10,10,"  O Is Now Playing$"
XisPlaying    	db 13,10,10,"  X Is Now Playing$"
PressRorE       db 13,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,"* PRESS 'e' to exit OR 'r' to restart  *$" 

OpenMessage db 13,10,10,"TIC-TAC-TOI is a game for two players",10
			db 	"who take turns marking the spaces in a",10,"3*3 grid.",10
			db	"The player who succeeds in placing three respective marks in a ",10
			db	"horizontal, vertical, or diagonal row",10,"wins the game.",10,10,10
			db  "Press 1 for two players,",10
			db  "Press 2 for play against the computer $"	
PlaceOnMat1 dw '-'
PlaceOnMat2 dw '-'

countIfWin db 0

CheckIfTeko db 0

colorLine db 02h

TheCircle db "----------*******--------|"
		  db "-------**-------**-------|"
		  db "-----**-----------**-----|"
		  db "----*---------------*----|"
		  db "---*-----------------*---|"
		  db "--*-------------------*--|"
		  db "--*-------------------*--|"
		  db "-*---------------------*-|"
		  db "-*---------------------*-|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "*-----------------------*|"
		  db "-*---------------------*-|"
		  db "-*---------------------*-|"
		  db "--*-------------------*--|"
		  db "--*-------------------*--|"
		  db "---*-----------------*---|"
		  db "----*---------------*----|"
		  db "-----**-----------**-----|"
		  db "-------**-------**-------|"
		  db "---------*******---------|"
x dw 0
y dw 0
FirstPos dw 0
PlayerOrComputer db 1
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
	; Graphic mode
	mov ax, 13h
	int 10h
	
	;Show Start Message
	mov dx,offset OpenMessage
	mov ah,9
	int 21h
	
	;Peska Kelet From Keyboard
	mov ah,00h 
	int 16h
	;If Pressed 1 is Against Computer, If PRESSED 2 TWO PLAYERS
	cmp al, '1'
	je AgaisntComputer
	mov [PlayerOrComputer], 2
	jmp PreStart
AgaisntComputer:
	mov [PlayerOrComputer], 1
PreStart:
	; Graphic mode
	mov ax, 13h
	int 10h
	
	call PrintGameBoard
;Initializes the mouse
	mov ax,0h
	int 33h

TheStart:
	call Print_Game_State

;Show mouse
	mov ax,1h
	int 33h

	cmp [PlayerOrComputer], 1
	je MouseLP
	cmp [BoolXORO], 'O'
	jne ThePlayerTurn
	call PcTurn
	call PcMakeTheTurn
	jmp CheckIfSomeoneWin
ThePlayerTurn:

MouseLP:
	;The Mouse Button Press Piska
	mov ax,5h
	int 33h
	cmp bx, 01h ; check left mouse click
	jne MouseLP
	
	call MakeCircleOrExPosition
	cmp al, 's'
	je TheStart
	
	;Hide Mouse Before Print:
	;
	mov ax, 02h
	int 33h


;-------------------------------------------------------------
;Loop Of Game If There is Winner Or Not, if game is done or Replay!!!
;-------------------------------------------------------------
	cmp [BoolXORO], 'O'
	je JmpToprintO

	push dx
	push cx
	;Check If There is alerady value in that place
	mov ax, [PlaceOnMat2]
	mov bx, [PlaceOnMat1]
	dec ax
	dec bx
	call ReadCell
	cmp cl, '-'
	jne containPlay
	;------------------
	mov [BoolXORO], 'O'
	pop cx
	pop dx
	;print X
	call Print_X_Symbol_Proc
	;Enter the value to the array
	call InputCell
	jmp CheckIfSomeoneWin


	JmpToprintO:
	push dx
	push cx
	;Check If There is alerady value in that place
	mov ax, [PlaceOnMat2]
	mov bx, [PlaceOnMat1]
	dec ax
	dec bx
	call ReadCell
	cmp cl, '-'
	jne containPlay
	;-------------------
	mov [BoolXORO], 'X'
	;Enter the value to the array
	call InputCell
	pop cx
	pop dx
	;Print O
	call PrintCircle
	
CheckIfSomeoneWin:
	call CheckWin
	
	mov dx,offset NoWin
	
	cmp al,'X'
	jz Xwin
	cmp al,'O'
	jz Owin
	mov al, [CheckIfTeko]
	cmp al, 8
	je Results
	inc al
	mov [CheckIfTeko], al
	jmp containPlay
Xwin:
	mov dx,offset XwinMessage
	jmp Results
Owin:
	mov dx,offset OwinMessage
	jmp Results
results:
	call ClearScreenText
	mov [BoolXORO], '-' 
	;Peska Print to screen "xxxx $"
	mov ah,9
	int 21h
	jmp EndGame

containPlay:
	jmp TheStart


EndGame:
	call Print_Game_State
	;Peska Kelet From Keyboard
	; Wait for key press
	mov ah,00h 
	int 16h
	;------
	cmp al, 'e'
	je ExitFromGame
	cmp al, 'r'
	je ResetTheGame
	jmp EndGame
	
ResetTheGame:
	call ResetTheGameProc
	jmp PreStart
ExitFromGame:
; Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
;-------------------------------------------------------------
;-------------------------------------------------------------
	
exit:
	mov ax, 4c00h
	int 21h

;========================================
;Description: Print Game state, who is now playing
;========================================
proc Print_Game_State
	
	mov dx,offset PressRorE
	cmp [BoolXORO], 'X'
	jz PrintXisPlaying
	cmp [BoolXORO], 'O'
	jz PrintOisPlaying
	jmp PrintGameState
PrintXisPlaying:
	call ClearScreenText
	mov dx,offset XisPlaying
	jmp PrintGameState
PrintOisPlaying:
	call ClearScreenText
	mov dx,offset OisPlaying
	jmp PrintGameState
PrintGameState:
	mov ah,9
	int 21h
ret
endp Print_Game_State

;========================================
;Description: Read one byte from 2D array 
;Input: ax = row  
;		bx = col 
;Output:  cl = Cell value
;========================================
proc ReadCell
	push ax
	push bx
	
    mov si,3
	mul si
	add ax , bx
	mov si,ax
	mov bx, offset TheMatz
	mov cl,[bx + si]
	
	pop bx
	pop ax
	ret
endp ReadCell

;========================================
;Description: Put one byte on 2D array 
;Input: ax = row  
;		bx = col 
;========================================
proc InputCell
	push ax
	push bx
	
    mov si,3
	mul si
	add ax , bx
	mov si, ax
	mov bx, offset TheMatz
	cmp [BoolXORO], 'O'
	je EnterOtoArray
	mov [byte bx + si],'O'
	jmp endEnterToArr
EnterOtoArray:
	mov [byte bx + si],'X'
endEnterToArr:
	pop bx
	pop ax
	ret
endp InputCell

;=============================================================
; Cehck if There is a Winner in TheMatz
;=============================================================
; output:
; al='-' no win
; al ='X' X win
; al ='O' O win
;=============================================================
proc CheckWin

	push cx
	 
	push bx
	 
    ;Now check 3 rows
    mov cx,3
    mov bx , offset TheMatz  ; check first row
NextRow:	
	call CheckTriple
	cmp al,'-'
	jnz WinFound
	add bx, 3  ; check next row
	loop NextRow 
	 
	   ; Now check 3 Columns
	 mov cx,0
nextCol:	 
	 mov bx,offset TheMatz
	 add bx,cx
	 call getCol ; set first column into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz WinFound
	 inc cx
	 cmp cx,3
	 jnz nextCol
	  
	 
	   ; Now check 2 Diagonals 
	 mov bx,offset TheMatz
	 call get1Diagonal ; set first diagonal into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz WinFound
	 
	 
	 mov bx,offset TheMatz
	 add bx,2
	 call get2Diagonal ; set first diagonal into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz WinFound
	 jmp NoWinFound
WinFound:	
	 ; 
	 ;
NoWinFound:	
	;
	;
	pop bx
	pop cx
	ret
endp CheckWin

;----------------------------------------------------------
;  Enter to oneTriple the colums values
;----------------------------------------------------------
; Input:
;  	input bx =index cell to start col (array + 0 ,1,2)
; Output:
;     output = oneTriple
; Registers Used:
;	   AX  BH
;    
;---------------------------------------------------------- 
proc getCol
	 
	push ax
	 
	mov al,[byte bx ]
	mov [byte oneTriple],al
	mov al,[byte bx +3  ]
	mov [byte oneTriple +1],al
	mov al,[byte bx +6  ]
	mov [byte oneTriple +2],al
	
	pop ax
	ret
endp getCol

;----------------------------------------------------------
;  Enter to oneTriple the Diagonal values
;----------------------------------------------------------
; Input:
;  	bx =index cell to start 
; Output:
;     output = oneTriple
; Registers Used:
;	   AX  BH
;    
;---------------------------------------------------------- 
proc get1Diagonal
	 stop:
	push ax
	 
	mov al,[byte bx ]
	mov [byte oneTriple],al
	mov al,[byte bx +4  ]
	mov [byte oneTriple +1],al
	mov al,[byte bx +8  ]
	mov [byte oneTriple +2],al
	
	pop ax
	ret
endp get1Diagonal

;----------------------------------------------------------
;  Enter to oneTriple the Diagonal values
;----------------------------------------------------------
; Input:
;  	bx =index cell to start 
; Output:
;     output = oneTriple
; Registers Used:
;	   AX  BH
;    
;---------------------------------------------------------- 
proc get2Diagonal
	 
	push ax
	 
	mov al,[byte bx  ]
	mov [byte oneTriple],al
	mov al,[byte bx + 2  ]
	mov [byte oneTriple +1],al
	mov al,[byte bx +4  ]
	mov [byte oneTriple +2],al
	
	pop ax
	ret
endp get2Diagonal

;----------------------------------------------------------
;  Check araay (3) if all equals
;----------------------------------------------------------
; Input:
;  	bx = Triple Offset - addrsss of 3 bytes that contain 3 symboles
; Output:
;      al='-' no win al ='X' X win al ='O' O win
; Registers Used:
;	   AX  BH   
;---------------------------------------------------------- 
proc CheckTriple
	
	mov ah,[byte bx]   ; mov first
	
	cmp ah,'-'
	jz @@NoWin
	mov al,[byte bx+1]
	cmp al,ah
	jne @@NoWin
	mov al,[byte bx+2]
	cmp al,ah
	jne @@NoWin
	jmp Win
@@NoWin:
	mov al,'-'
Win:	
	 
	ret
endp CheckTriple
;----------------------------------------------------------
;  Print X to the screen  
;----------------------------------------------------------
; Input:
;   	cx - X axis
;		dx - Y axis
; Output:
;     O print to screen 
; Registers Used:
;	   AX ES DI CX DX BH
; Description:
;  
; print X to screen. start pos: (cx,dx)
;    
;----------------------------------------------------------  
proc Print_X_Symbol_Proc
	push ax
	push bx
	
	mov bx, cx
	mov ax, dx
	mov si, cx
	add si, 20
	mov cx, 20
	
@@PrintXLineLoopProc:
	push cx
	push bx
	push ax
	push si
	
	mov dx,ax ;dx - y
	mov cx, bx ;cx - x
	mov bh,0h
	mov al,0ch
	mov ah,0ch
	int 10h
	
	pop si
	pop ax
	pop bx
	push bx
	push ax
	push si
	
	mov dx,ax ;dx - y
	mov cx, si ;cx - x
	mov bh,0h
	mov al,0ch
	mov ah,0ch
	int 10h
	
	pop si
	pop ax
	pop bx
	inc ax
	inc bx
	dec si
	pop cx
	loop @@PrintXLineLoopProc
	
	pop bx
	pop ax
	ret
endp Print_X_Symbol_Proc
;----------------------------------------------------------
;  Print O to the screen  
;----------------------------------------------------------
; Input:
;   	cx - X axis
;		dx - Y axis
; Output:
;     O print to screen 
; Registers Used:
;	   AX ES DI CX DX BH
; Description:
;  
; print O to screen. start pos: (cx,dx)
;    
;---------------------------------------------------------- 
proc PrintCircle
push cx
push bx
push dx

mov [x], cx
mov [y], dx
mov [FirstPos], cx

mov cx, 650
mov bx, offset TheCircle

PrintCircleLoop:
	push cx
	push bx
	
	cmp [byte bx], '-'
	je prnitBlackDot
	cmp [byte bx], '*'
	je prnitRedDot
	;Next Line
	inc [y]
	mov cx, [FirstPos]
	mov [x], cx
	jmp endTheSongle
prnitRedDot:
	mov bh,0h
	mov cx,[x]
	mov dx,[y]
	mov al,0Bh
	mov ah,0ch
	int 10h
	jmp endTheSongle
prnitBlackDot:
	mov bh,0h
	mov cx,[x]
	mov dx,[y]
	mov al,0h
	mov ah,0ch
	int 10h

endTheSongle:
pop bx
inc bx
inc [x]
pop cx
loop  PrintCircleLoop

pop dx
pop bx
pop cx
ret
endp PrintCircle

;----------------------------------------------------------
;  Procedure Clear Screen Text  Mode  
;----------------------------------------------------------
; Input:
;   	None
; Output:
;     Screen , and Cursor 
; Registers Used:
;	   AX ES DI CX DX BH
; Description:
;  
; Color Black all Screen 80 X 24 and bring Cursor to start
;    
;---------------------------------------------------------- 
Proc ClearScreenText
    push ax
	push cx
	push bx
	push dx
	
	mov ax,0B800h
	mov es,ax          ; es:di - video memory
	xor di,di
    mov cx,80*24
    mov al,00d         ; ASCII
    mov ah,02h        ; color 2 is green
    ;mov es:[di],ax     ;add di,2  Stores a byte, word from the AL, AX
	rep stosw
	;move Cursor to top left  
    xor DX,DX
	mov dl, 0
	mov bh, 0
	mov ah, 2  ; change cursor position
	int 10h
    
	pop dx
	pop bx
	pop cx
	pop ax
	
	ret
endp ClearScreenText

;----------------------------------------------------------
;  Print Game Board, Grapicha
;----------------------------------------------------------
; Input:
;   	None
; Output:
;     Screen   
;---------------------------------------------------------- 
proc PrintGameBoard
;-------------------------------------------------------------
;Print The Limits of the screen
;-------------------------------------------------------------
	mov [colorLine], 0ah
	PRINT_Horizontal_LINE 0, 0, 320 ;Ofke Line UP
	PRINT_Horizontal_LINE 0, 198, 320 ;Ofke Line Down
	PRINT_Vertical_LINE 0, 0, 200 ; Anahi Line Left
	PRINT_Vertical_LINE 318, 0, 200 ; Anahi Line Right
	mov [colorLine], 0bh
	PRINT_Horizontal_LINE 0, 5, 320 ;Ofke Line UP 2
	PRINT_Horizontal_LINE 0, 193, 320 ;Ofke Line Down 2
	PRINT_Vertical_LINE 5, 0, 200 ; Anahi Line Left 2
	PRINT_Vertical_LINE 313, 0, 200 ; Anahi Line Right 2
	mov [colorLine], 0Ch
	PRINT_Horizontal_LINE 0, 10, 320 ;Ofke Line UP 2
	PRINT_Horizontal_LINE 0, 187, 320 ;Ofke Line Down 2
	PRINT_Vertical_LINE 10, 0, 200 ; Anahi Line Left 2
	PRINT_Vertical_LINE 307, 0, 200 ; Anahi Line Right 2

	

;-------------------------------------------------------------

;-------------------------------------------------------------
;Print The Game Board
;-------------------------------------------------------------
	mov [colorLine], 0Dh
	PRINT_Horizontal_LINE 64, 40, 192 ;
	PRINT_Horizontal_LINE 64, 160, 192 ;
	PRINT_Vertical_LINE 64, 40, 120 ;
	PRINT_Vertical_LINE 256, 40, 120 ; 
	
	PRINT_Vertical_LINE 59, 45, 110 ;
	PRINT_Vertical_LINE 261, 45, 110 ;
	PRINT_Vertical_LINE 54, 50, 100 ;
	PRINT_Vertical_LINE 266, 50, 100 ;
	PRINT_Vertical_LINE 49, 55, 90 ;
	PRINT_Vertical_LINE 271, 55,90 ;
	PRINT_Vertical_LINE 44, 60, 80 ;
	PRINT_Vertical_LINE 276, 60,80 ;
	PRINT_Vertical_LINE 39, 65, 70 ;
	PRINT_Vertical_LINE 281, 65,70 ;
	PRINT_Vertical_LINE 34, 70, 60 ;
	PRINT_Vertical_LINE 286, 70,60 ;
	PRINT_Vertical_LINE 29, 75, 50 ;
	PRINT_Vertical_LINE 291, 75,50 ;
	PRINT_Vertical_LINE 24, 80, 40 ;
	PRINT_Vertical_LINE 296, 80,40 ;
	PRINT_Vertical_LINE 19, 85, 30 ;
	PRINT_Vertical_LINE 301, 85,30 ;

	
	mov [colorLine], 0Eh
	PRINT_Horizontal_LINE 64, 80, 192 ;
	PRINT_Horizontal_LINE 64, 120, 192 ;
	PRINT_Vertical_LINE 128, 40, 120 ;
	PRINT_Vertical_LINE 192, 40, 120 ; 
;-------------------------------------------------------------
ret
endp PrintGameBoard

;===***description**=======================================
;This Proc Reset The game to his first values
;==========================================================
proc ResetTheGameProc
	mov [BoolXORO], 'X' 
	mov [CheckIfTeko], 0
	mov bx, offset TheMatz
	mov si, offset tempT
	mov cx, 9
ReserArrayAfterPressesReset:
	mov [byte bx],'-'
	mov [byte si], '-'
	inc bx
	inc si
loop ReserArrayAfterPressesReset
	mov [PlaceOnMat1], '-'
	mov [PlaceOnMat2], '-'
	mov ah, 0
	mov al, 2
	int 10h
ret
endp ResetTheGameProc

 ; output : si the place to put the compute decision 
 proc PcTurn
	mov cx,9
	xor bx,bx
	mov [maxScore],-128
	xor si,si
	
@@NextCell:	
	cmp [byte TheMatz +bx],'-'
	je @@Cont1 
	jmp @@NextLoop

@@Cont1:	
	mov dl,1    ; 1 = player -1 = PC
	mov dh,6  ; depth
	call BuildTempMat
	mov [tempT +bx],'O'
	push bx
	push cx
	
	PUSH_PARAMS  ;   dl = turn dh = depth , 
	call miniMax  ; input 11 words in stack output ah = score
	pop cx
	pop bx
	
	 
	mov [tempT +bx],'-'
	cmp [maxScore],ah
	jnl @@NextLoop
	mov [maxScore],ah
	mov si,bx
@@NextLoop:
	inc bx
	dec cx
	cmp cx,0
	jz @@Cont2
	jmp @@NextCell
	
	
@@Cont2:	
	ret
endp PcTurn



;===***NameProc**==========================================
;MiniMax
;==========================================================
;===***description**=======================================
;This Proc Find the best place for the computer to put the circle,
;The Proc tries every option than posibily and give for any option a score
;the best score will be the one the computer will do
;==========================================================
; input: STRACK:: dl = turn
;		 		  dh = depth
;				  10 words [tempT]	
;==========================================================
proc miniMax
	
	push bp
	mov bp,sp
	sub sp,2
	
	GET_PARAMS
	;call print_temp
;stop:	
	
	cmp dh,0 ;depth
	jg  @@NextCheck1
	jmp GetScoreofCurrentMat
@@NextCheck1:	
	call CheckFull  ; bx = 1 = full
	cmp bx,1  ; schec if full
	jnz  @@NextCheck2
	jmp GetScoreofCurrentMat
@@NextCheck2:
	call CheckWin2
	cmp al,'-'
	jz  @@NextCheck3
	jmp GetScoreofCurrentMat
@@NextCheck3:

; preparations for minimax call ------------------------------------
;------------------------------------
;------------------------------------
;------------------------------------

	mov CurrentScore,-128
	cmp dl,1 ;Payer turn = dl = 1
	jne @@Cont2
	mov CurrentScore,+127

@@Cont2:
	mov cx,9
	xor bx,bx
@@NextCell2:	
	cmp [byte tempT +bx],'-'
	je @@Cont3 
	jmp @@NextLoop
	
@@Cont3:
	cmp dl,1
	jz PlayerMove
	mov [tempT +bx],'O'
	jmp @@Cont4
PlayerMove:
	mov [tempT +bx],'X'
@@Cont4:	
	neg dl    ; 1 = player -1 = PC
	dec dh
	
	push cx
	push bx
	PUSH_PARAMS  ;   dl = turn dh = depth , ;Save Tempt to array

	call miniMax  ; input 11 words in stack output ah = score
	
	pop bx
	pop cx
	
	push ax
	GET_PARAMS
	pop ax
	
	mov [tempT +bx],'-'
	
	cmp dl,1
	jz PlayerMin
	
	cmp CurrentScore,ah
	jnl @@NextLoop
	mov CurrentScore,ah
	jmp @@NextLoop

PlayerMin:
	cmp CurrentScore,ah
	jng @@NextLoop
	mov CurrentScore,ah

@@NextLoop:
	inc bx
	dec cx
	cmp cx,0
	je @@Cont5
	jmp @@NextCell2
	
@@Cont5:
	mov ah,CurrentScore
	
	jmp @@ret
;------------------------------------	
	
GetScoreofCurrentMat:
	call getScore
	jmp @@ret

@@ret:
	add sp,2
	pop bp
	ret 20
endp miniMax


;===***description**==========================================
;Check If Tempt is full
;=============================================================
; output: bx = 1 - full
;		  bx = 0 - empty
;=============================================================
proc CheckFull
	mov bx,0
	
@@NextCell:	
	cmp [tempT + bx],'-'
	jz foundEmpty
	inc bx
	cmp bx,9
	jb @@NextCell
	mov bx,1
	jmp @@ret
	
foundEmpty:
	mov bx,0
@@ret:
	ret
endp CheckFull

;===***description**==========================================
;Make Points to computer or to player
;=============================================================
;output: ah=  -10 - player points
;		 ah=  +10 - computer points
;		 ah=   0    no pints 
;=============================================================
proc getScore
	call CheckWin2
	cmp al,'-'
	jz @@NoWin
	cmp al,'O'
	jz @@PcWin
	mov ah,-10
	jmp @@ret
@@NoWin:
	mov ah,0
	jmp @@ret

@@PcWin:
	mov ah,10
	
@@ret:
	ret
endp getScore
 
 
  
;===***description**==========================================
; Move TheMatz Vlues to tempT
;=============================================================
; output: non
;=============================================================
proc BuildTempMat
	push cx
	push bx
	push ax
	
	mov cx,9
	xor bx,bx
	
@@NextCell:
	mov al,[TheMatz +bx]
	mov [tempT +bx],al
	inc bx
	loop @@NextCell
	
	
	 
	pop ax
	pop bx
	pop cx
	ret
endp BuildTempMat

;===***description**==========================================
; Cehck if There is a Winner in tempT
;=============================================================
; output:
; al='-' no win
; al ='X' X win
; al ='O' O win
;=============================================================
proc CheckWin2
	push cx
	push bx
	 
    ;Now check 3 rows
    mov cx,3
    mov bx , offset tempT  ; check first row
@@NextRow:	
	call CheckTriple
	cmp al,'-'
	jnz @@WinFound
	add bx, 3  ; check next row
	loop @@NextRow 
	 
	   ; Now check 3 Columns
	 mov cx,0
@@nextCol:	 
	 mov bx,offset tempT
	 add bx,cx
	 call getCol ; set first column into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz @@WinFound
	 inc cx
	 cmp cx,3
	 jnz @@nextCol
	  
	 
	   ; Now check 2 Diagonals 
	 mov bx,offset tempT
	 call get1Diagonal ; set first diagonal into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz @@WinFound
	 
	 
	 mov bx,offset tempT
	 add bx,2
	 call get2Diagonal ; set first diagonal into oneTriple
	 mov bx , offset oneTriple  ; check first row
	 call CheckTriple
	 cmp al,'-'
	 jnz @@WinFound
	 jmp @@NoWinFound
@@WinFound:	
	 ; 
	 ;
@@NoWinFound:	
	;
	;
	pop bx
	pop cx
	ret
endp CheckWin2
;===***description**==========================================
; FIND THE PLACE ON 2D ARRAY TO PUT CIRCLE OF COMPUTER
;=============================================================
proc PcMakeTheTurn
	mov bx, offset TheMatz
	mov [byte bx + si], 'O'
	mov [BoolXORO],'X'
	
	cmp si, 0
	jz @@Zero
	cmp si, 1
	jz @@One
	cmp si, 2
	jz @@Two
	cmp si, 3
	jz @@Tree
	cmp si, 4
	jz @@Four
	cmp si, 5
	jz @@Five
	cmp si, 6
	jz @@Six
	cmp si, 7
	jz @@Seven
	mov cx, 192
	mov dx, 120
	jmp @@MakeCurrect
@@Zero:
mov cx, 64
mov dx, 40
jmp @@MakeCurrect
@@One:
mov cx, 128
mov dx, 40
jmp @@MakeCurrect
@@Two:
mov cx, 192
mov dx, 40
jmp @@MakeCurrect
@@Tree:
mov cx, 64
mov dx, 80
jmp @@MakeCurrect
@@Four:
mov cx, 128
mov dx, 80
jmp @@MakeCurrect
@@Five:
mov cx, 192
mov dx, 80
jmp @@MakeCurrect
@@Six:
mov cx, 64
mov dx, 120
jmp @@MakeCurrect
@@Seven:
mov cx, 128
mov dx, 120

@@MakeCurrect:
	add cx, 25
	add dx, 10
	call PrintCircle
	ret
endp PcMakeTheTurn
;===***description**==========================**FOR DEBUG**===
; Print TheMatz to screen FOR DEBUG
;=============================================================
; output:
; Screen
;=============================================================
proc PrintMatz
	push cx
	push bx
	mov cx, 9
	mov bx, offset TheMatz
JmpPrintMatz:
	mov dl, [byte bx]
	mov ah, 2
	int 21h
	inc bx
loop JmpPrintMatz
	pop bx
	pop cx
	ret
endp PrintMatz

;===***description**==========================================
;Make Good Pusition To Print X or O
;I get the place the mouse clicked, and i circle the answer
;(if i get 69 it will be 65 at the end)
;=============================================================
; output: al = 's' = Jmp TheStart
;		  cx - new 	X
;		  DX - new  Y
;
; INPUT:  CX - X
;		  DX - Y
;=============================================================
proc MakeCircleOrExPosition
shr cx,1 ; adjust cx to range 0-319, to fit screen (div 2)
	;;I get the place the mouse clicked, and i circle the answer
	;;(if i get 69 it will be 65 at the end)
	push dx ;;SAVE dx cus i will use it now and i will need it later 
	mov bx, 64 ; mov bx 64, i want to div the number i got in CX (x line) in 64
	mov ax,cx ; mov ax the number i got from mouse click
	xor dx, dx ; dx = 0
	div bx ; bx/ax
	mov [PlaceOnMat1], ax ;Result can be 1,2,3,4,5
	mul bx; ax*bx (bx is 64)
	mov cx, ax ;save the result to cx

	pop dx ;; pop the cx i was pushed,
	mov bx, 40
	mov ax,dx
	xor dx, dx
	div bx
	mov [PlaceOnMat2], ax
	mul bx
	mov dx, ax


Make_Good_Position:
	add cx, 25 ;i added to cx (X line) 25, it is good place on screen, look nice
	add dx, 10 ;same here, but added 10, cus its smaller

	cmp cx, 256 ;Check if the click is bigger than it should be
	ja StartOver
	cmp dx, 160 ;Check if the click is bigger than it should be
	ja StartOver
	cmp cx, 64 ;Check if the click is smaller than it should be
	jb StartOver
	cmp dx, 40 ;Check if the click is smaller than it should be
	jb StartOver
	mov al, '-'
	jmp @@ret
	;jb - jump below
	;ja - jump above
StartOver:
	mov al, 's'
@@ret:
	ret
endp MakeCircleOrExPosition
END start


