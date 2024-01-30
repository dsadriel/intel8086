

;====================================================================
;	          UNIVERSIDADE FEDERAL DO RIO GRANDE DO SUL
;           INSTITUTO DE INFORMÁTICA – INFORMÁTICA APLICADA
;        Arquitetura e Organização de Computadores I – 2023/2
;                     Trabalho de Programação
;                    Processador 8086 da INTEL
; 				     Adriel de Souza | 00579100
;====================================================================


.model small
.stack


; ===================================================================
;                             DADOS
; ===================================================================
.data
STRINGBUFFER db 256 dup (0) ; Buffer para string
CHARBUFFER	db 0 			; Buffer para char
INPUTFILE db 256 dup (0) ; Nome do arquivo de entrada
OUTPUTFILE db 256 dup (0) ; Nome do arquivo de saída
TENSION db 127 ; Tensão padrão
ERROR db 0 ; Flag de erro
FILEHANDLE dw 0 ; Handle de arquivo

CURRENTLINE dw 0 ; Linha atual do arquivo de entrada
TOTALTIME dw 0 ; Tempo total de medições
TENSIONQUALITY db 0 ; Qualidade da tensão
NOTENSION dw 0 ; Tempo sem tensão

; Variáveis para as tensões de cada fase
F1 db 0
F2 db 0
F3 db 0

; Mensagens
; Erros
E_i_withOutParams db "Opcao [-i] sem parametro", 0
E_o_withOutParams db "Opcao [-o] sem parametro", 0
E_v_withOutParams db "Opcao [-v] sem parametro", 0
E_v_outOfRange db "Parametro da opção [-v] deve ser 127 ou 220", 0
E_lineError_1 db "Linha ", 0
E_lineError_2 db " inválida: ", 0

E_inputFileError db "Erro ao abrir o arquivo de entrada", 0
E_outputFileError db "Erro ao abrir o arquivo de saída", 0

; Resultados
O_inputFile db "Arquivo de entrada: ", 0
O_tension db "Valor da tensão: ", 0
O_totalTime db "Tempo total de medições: ", 0
O_tensionQuality db "Qualidade da tensão: ", 0
O_noTension db "Tempo sem tensão: ", 0
; Outras
I_end db "fim", 0

CR equ 13 ; Carriage Return
LF equ 10 ; Line Feed


; ===================================================================
;                            CÓDIGO
; ===================================================================
.code
	;--------------------------------------------------------------------
	;                            PROGRAMA PRINCIPAL
	;--------------------------------------------------------------------
	.startup
	
	;********************************************************************
	; 1) Ler e interpretar as informações da linha de comando.
	;		i) Caso a linha de comando tenha informações inválidas, 
	;          seu programa deve informar o erro e encerrar.
	;********************************************************************

	; Realiza a leitura da linha de comando e a coloca em STRINGBUFFER
	; *Inicio do código disponibilizado pelo professor na especificação do trabalho
	push ds ; Salva as informações de segmentos
	push es
	mov ax,ds ; Troca DS com ES para poder usa o REP MOVSB
	mov bx,es
	mov ds,bx
	mov es,ax
	mov si,80h ; Obtém o tamanho do string da linha de comando e coloca em CX
	mov ch,0
	mov cl,[si]
	mov ax,cx ; Salva o tamanho do string em AX, para uso futuro
	mov si,81h ; Inicializa o ponteiro de origem
	lea di,STRINGBUFFER ; Inicializa o ponteiro de destino
	rep movsb
	pop es ; retorna as informações dos registradores de segmentos
	pop ds
	; *Fim do código disponibilizado pelo professor na especificação do trabalho
	
	; Realiza o processamento da linha de comando
	; call processCommandLine

	; Verifica se houve algum erro na linha de comando
	cmp ERROR, 1
	je exit

	;********************************************************************
	; 2) Ler e interpretar as informações do arquivo de dados de entrada.
	;		i) Caso o arquivo de dados de entrada tenha linhas inválidas, 
	;          seu programa deve informar na  tela o nú mero de  TODAS as 
	;          linhas  onde  foi   identificado  o  erro  e  o  conteúdo 
	;		   correspondente. Então, o programa deve encerrar.
	; 3) Processar os dados do arquivo de dados.
	;********************************************************************

	; Realiza a leitura do arquivo de entrada
	mov ah, 3dh ; Abre o arquivo
	mov al, 0 ; Modo de leitura
	lea dx, INPUTFILE ; Nome do arquivo de entrada
	int 21h
	jnc fileReadSucess ; Se ocorreu algum erro, encerra o programa

	; COMENTAR
	

	fileReadSucess:
	mov FILEHANDLE, ax ; Salva o handle do arquivo de entrada em FILEHANDLE
	
	
	lea bx, INPUTFILE
	lea dx, STRINGBUFFER
	;call readLine

	;; # fclose();

	; Se ocorreu algum erro durante o processamento do arquivo de entrada, encerra o programa
	cmp ERROR, 1
	je exit


	;********************************************************************
	; 4) Gerar relatório de informações na tela.
	;********************************************************************
	
	; Exibe os resultados no console
	;call printResults




	;********************************************************************
	; 5) Gerar arquivo de relatório.
	;********************************************************************

	; Realiza a escrita do arquivo de saída
	mov ah, 3ch ; Cria o arquivo
	mov al, 0 ; Modo de escrita
	lea dx, OUTPUTFILE ; Nome do arquivo de saída
	int 21h
	jc exit ; Se ocorreu algum erro, encerra o programa	
	mov FILEHANDLE, ax ; Salva o handle do arquivo de saída em FILEHANDLE
	;call writeResults
	;; # fclose();

	; 6) Encerrar seu programa.		

exit:
	.exit




;--------------------------------------------------------------------
;                            PROCEDIMENTOS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;	fgetc(char* b:dx, FILE* f:bx)
;	ENTRADA:
;		dx: ponteiro para buffer do char
;		bx: file handle
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;--------------------------------------------------------------------
fgetc proc near
	push 	cx
	push 	ax

	mov		cx,1			; Tamanho de leitura (1 byte)
	mov		ah,3fh	
	int		21h

	jnc 	fgetcRET		; Se não tiver erro de leitura, retorna
	cmp		ax, 1
	je		fgetcRET		; Se a quantidade de bytes lida for igual a 1, retorna
	stc 					; Caso contrário define a flag da carry para 1
	
	fgetcRET:	
	pop ax
	pop cx
	ret
	
fgetc endp

;--------------------------------------------------------------------
;	fgets(char* s:dx, FILE* f:bx, int max:cx)
;	ENTRADA:
;		dx: ponteiro para buffer do char
;		cx: tamanho máximo da string
;		bx: file handle
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;--------------------------------------------------------------------
fgets proc near
	push bx
	push cx
	push dx

	cmp cx,-1	; Se a tamanho máximo for -1, define o tamanho para 256
	jne fgets1
	mov cx, 256

	fgets1:
	mov byte ptr [dx], 0 ; Limpar o primeiro char 


	fgetsL:
		call fgetc
		jc fgetsError		; Se teve algum erro

		; Se for CR ou LF encerra a leitura da string	
		cmp byte ptr [dx], CR
		je fgetsCR
		cmp byte ptr [dx], LF
		je fgetsLF

		; Incrementa o ponteiro e retorna ao loop
		inc dx
		loop fgetsL
	
	jmp fgetsEND

	fgetsCR:
		call fgetc
		cmp byte ptr [dx], LF
		jne fgetsDecFile	; Se não for um LF decrementa a posição atual do arquivo
		jmp fgetsEND
	fgetsLF:
		call fgetc
		cmp byte ptr [dx], CR
		jne fgetsDecFile ; Se não for um CR decrementa a posição atual do arquivo
		jmp fgetsEND

	
	fgetsDecFile:
		mov ah, 42h
		mov al, 01h
		mov dx, -1
		int 21h
		dec dx



	fgetsEND:
		dec dx
		mov [dx], 0; Insiere o '\0' no final da string
		pop dx
		pop cx
		pop bx		
		jmp fgetsENDP

	fgetsError:
		pop dx			
		mov [dx], 0		; Define o primeiro char da string como '\0'
		stc				; Define a flag de carry = 1
		pop cx
		pop bx
fgetsENDP: 
fgets endp

; void formatTime(int t:AX){
; 	if(t <= 60)
; 		return t;
; 	if(t > 3600)
; 		t /= 60;
	
; 	int l = t/60;
; 	int r = t%60;
	
; 	return //l:r
; }

; void toLower(char *c:AX){
; 	while(*c != '\0'){
; 		if(*c >= 'a' && *c <= 'z')
; 			*c = *c - 32;
; 	}
; }

; int:BX strcmp_(char *a:AX, char *b:AX){
; 	BX = 0;
	
; 	while(*b != '\0'){
; 		BX -= *b;
; 		b++;
; 	}
	
; 	while(*a != '\0'){
; 		BX += *b;
; 		a++;
; 	}
	
; 	//return BX
; }

; void printError(int line:BX, char *line:DX){
; 	printString(msg);
; 	printInt(line:BX);
; 	printString(line:DX);
; }


; 



;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
	
