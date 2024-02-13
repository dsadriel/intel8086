

;====================================================================
;	          UNIVERSIDADE FEDERAL DO RIO GRANDE DO SUL
;           INSTITUTO DE INFORMÁTICA – INFORMÁTICA APLICADA
;        Arquitetura e Organização de Computadores I – 2023/2
;                     Trabalho de Programação
;                    Processador 8086 da INTEL
; 				     Adriel de Souza | 00579100
;====================================================================
; Problemas conhecidos:
; FIXME: Não verifica EOF apenas a string "fim"


.model small
.stack

; ===================================================================
;                            CONSTANTES
; ===================================================================

CR equ 13 ; Carriage Return
LF equ 10 ; Line Feed
TAB equ 9 ; Tab
MAXSTRING equ 256 ; Tamanho máximo de uma string

; ===================================================================
;                             DADOS
; ===================================================================
.data
STRINGBUFFER db MAXSTRING dup (0) ; Buffer para string
STRINGBUFFER2 db MAXSTRING dup (0) ; Buffer para string
CHARBUFFER	db 0 			; Buffer para char
INPUTFILE db 'a.in', 0; Nome do arquivo de entrada
db MAXSTRING-4 dup (0) ; Buffer para string
OUTPUTFILE db 'a.out', 0 ; Nome do arquivo de saída
db MAXSTRING-4 dup (0) ; Buffer para string
TENSION dw 127 ; Tensão padrão
ERROR db 0 ; Flag de erro
FILEHANDLE dw 0 ; Handle de arquivo

CURRENTLINE dw 0 ; Linha atual do arquivo de entrada
TOTALTIME dw 0 ; Tempo total de medições
TENSIONQUALITY dw 0 ; Qualidade da tensão
NOTENSION dw 0 ; Tempo sem tensão
FILE_EOF db 0 ; Flag de final de arquivo

; Variáveis para as tensões de cada fase
TENSIONPHASES dw 3 dup (0)


; Mensagens
; Erros
E_i_withOutParams db "Opcao [-i] sem parametro", CR, LF, 0
E_o_withOutParams db "Opcao [-o] sem parametro", CR, LF, 0
E_v_withOutParams db "Opcao [-v] sem parametro", CR, LF, 0
E_v_outOfRange db "Parametro da opcao [-v] deve ser 127 ou 220", CR, LF, 0
E_lineError_1 db "Linha ", 0
E_lineError_2 db " invalida: ", 0

E_inputFileError db "Erro ao abrir o arquivo de entrada", CR, LF, 0
E_outputFileError db "Erro ao abrir o arquivo de saída", CR, LF, 0

; Resultados
O_inputFile db "Arquivo de entrada: ", 0
O_outputFile db "Arquivo de saida: ", 0
O_tension db "Valor da tensao: ", 0
O_totalTime db "Tempo total de medicoes: ", 0
O_tensionQuality db "Qualidade da tensao: ", 0
O_noTension db "Tempo sem tensao: ", 0

; Outras
I_end db "fim", 0
S_newLine db CR, LF, 0

; Variáveis auxiliares
auxb_1 db 0
auxw_1 dw 0
current dw 0

; Variáveis utulizadas por prociementos disponibilizados pelo professor

sw_n	dw	0
sw_f	db	0
sw_m	dw	0

DEBUGMSG db "DEBUG", CR, LF, 0


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

	; Verifica se o argumento -i foi utilizada
	mov al, 'i'
	lea dx, INPUTFILE
	call getCommandLineArgument
	
	; Verifica se houve algum erro na busca do argumento
	cmp ERROR, 1
	jne getCMDo
	lea bx, E_i_withOutParams
	call puts
	jmp exitProgram

	getCMDo:
	; Verifica se o argumento -o foi utilizada
	mov al, 'o'
	lea dx, OUTPUTFILE
	call getCommandLineArgument

	; Verifica se houve algum erro na busca do argumento
	cmp ERROR, 1
	jne getCMDv
	lea bx, E_o_withOutParams
	call puts
	jmp exitProgram

	getCMDv:
	; Verifica se o argumento -v foi utilizada
	mov al, 'v'
	lea dx, STRINGBUFFER2
	call getCommandLineArgument

	; Verifica se houve algum erro na busca do argumento
	cmp ERROR, 1
	jne getCMDvParse
	lea bx, E_v_withOutParams
	call puts
	jmp exitProgram
	
	getCMDvParse:
	; Verifica se o valor de tensão foi informado
	cmp STRINGBUFFER2, 0
	je getCMDvParseEnd

	; Verifica se o valor de tensão é válido
	lea bx, STRINGBUFFER2
	call atoi
	mov TENSION, ax

	cmp TENSION, 127
	je getCMDvParseEnd
	cmp TENSION, 220
	je getCMDvParseEnd
	; Se o valor de tensão não é válido, exibe uma mensagem de erro e encerra o programa
	lea bx, E_v_outOfRange
	call puts
	jmp exitProgram

	getCMDvParseEnd:

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
	jnc fileReadSucess 

	; Se ocorreu algum erro ao abrir o arquivo, exibe a uma mensagem erro e encerra o programa
	lea bx, E_inputFileError
	call puts
	lea bx, O_inputFile
	call puts
	lea bx, INPUTFILE
	call puts
	jmp exitProgram

	fileReadSucess:
	mov FILEHANDLE, ax ; Salva o handle do arquivo de entrada em FILEHANDLE
	
	mov CURRENTLINE, 0 ; Inicializa a variável que armazena a linha atual do arquivo de entrada
	inputFileLoop:		
		inc CURRENTLINE ; Incrementa a linha atual do arquivo de entrada

		; Se o arquivo de entrada estiver no final, encerra o loop
		cmp FILE_EOF, 1
		je readFileEnd	

		; Realiza a leitura de uma linha do arquivo de entrada
		mov ax, FILEHANDLE
		lea bx, STRINGBUFFER
		call fgets
		

		; Se a linha lida for menor que 3, pula para o manipulador de erro
		cmp cx, 3
		jl inputLineError

		; Verifica se é o final do arquivo se for encerra o loop
		call checkEOFMarker
		jc readFileEnd

		call parseLine
		jc inputLineError

		; Verifica se os valores das tensões estão dentro do intervalo
		call checkTensionsForQuality
		jc inputLineNext
		inc TENSIONQUALITY

		inputLineNext:
		; Verifica se todas as tensões estão abaixo de 10
		call checkLowTensions
		jnc inputLineNext2
		inc NOTENSION


		inputLineNext2:
		jmp inputFileLoop

		; Manipulador de erro
		inputLineError:
		lea bx, E_lineError_1
		call puts
		
		mov ax, CURRENTLINE
		lea bx, STRINGBUFFER2
		call itoa
		call puts

		lea bx, E_lineError_2
		call puts
		lea bx, STRINGBUFFER
		call puts
		lea bx, S_newLine
		call puts
		mov ERROR, 1
		jmp inputFileLoop

	readFileEnd:
	; Fecha o arquivo de entrada
	mov ah, 3eh
	mov bx, FILEHANDLE ; File handle
	int 21h

	cmp ERROR, 1
	je exitProgram
	
	;********************************************************************
	; 4) Gerar relatório de informações na tela.
	;********************************************************************
	
	; Exibe os resultados no console
	mov ax, CURRENTLINE
	mov TOTALTIME, ax
	dec TOTALTIME
	call printResultsToScreen

	;********************************************************************
	; 5) Gerar arquivo de relatório.
	;********************************************************************

	; Realiza a escrita do arquivo de saída
	mov ah, 3ch ; Cria o arquivo
	mov al, 0 ; Modo de escrita
	lea dx, OUTPUTFILE ; Nome do arquivo de saída
	int 21h
	jc exitProgram ; Se ocorreu algum erro, encerra o programa	
	mov FILEHANDLE, ax ; Salva o handle do arquivo de saída em FILEHANDLE
	
	call writeResultsToFile

	; Fecha o arquivo de saída
	mov ah, 3eh
	mov bx, FILEHANDLE ; File handle
	int 21h

	; 6) Encerrar seu programa.		

exitProgram:
	nop
	.exit

;--------------------------------------------------------------------
;                            PROCEDIMENTOS
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;	fgetc(char* b:bx, FILE* f:ax)
;	ENTRADA:
;		bx: ponteiro para buffer do char
;		ax: file handle
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;--------------------------------------------------------------------
fgetc proc near
	push 	ax
	push 	bx
	push 	cx

	mov 	dx, bx
	mov 	bx, ax
	mov 	FILE_EOF, 0


	mov		cx,1			; Tamanho de leitura (1 byte)
	mov		ah,3Fh	
	int		21h
	cmp		ax, 0			; Se for EOF retorna 0
	je 		fgetcEOF
	jnc 	fgetcRET		; Se não tiver erro de leitura, retorna
	mov byte ptr [bx], 0
	
	fgetcEOF:
	mov FILE_EOF, 1
	fgetcRET:	
	pop cx
	pop bx
	pop ax
	ret
	
fgetc endp

;--------------------------------------------------------------------
;	fgets(FILE* f:ax, char* s:bx)
;	ENTRADA:F
;		ax: file handle
;		bx: ponteiro para buffer do char
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;		cx: número de chars lidos
;--------------------------------------------------------------------
fgets proc near
	push ax	
	push dx
	push bx

	mov cx, 255

	fgets1:
	mov byte ptr [bx], 0 ; Limpar o primeiro char 


	fgetsL:
		call fgetc
		jc fgetsError		; Se teve algum erro
		cmp FILE_EOF, 1
		je fgetsEND			; Se for EOF encerra

		; Se for CR ou LF encerra verifica o próximo digito
		cmp byte ptr [bx], CR
		je fgetsCR
		cmp byte ptr [bx], LF
		je fgetsLF

		cmp byte ptr [bx], 0 ; Se for o final da string, encerra o procedimento
		je fgetsEND			

		; Incrementa o ponteiro e retorna ao loop
		inc bx
		loop fgetsL
	
	jmp fgetsEND

	fgetsCR:
		call fgetc
		cmp byte ptr [bx], LF
		jne fgetsDecFile ; Se não for um LF decrementa a posição atual do arquivo
		jmp fgetsEND
	fgetsLF:
		call fgetc
		cmp byte ptr [bx], CR
		jne fgetsDecFile ; Se não for um CR decrementa a posição atual do arquivo
		jmp fgetsEND

	
	fgetsDecFile:
		mov ah, 42h
		mov al, 01h
		mov dx, -1
		int 21h
		dec dx

	fgetsError:
		pop bx			
		mov [bx], 0		; Define o primeiro char da string como '\0'
		push bx
		stc				; Define a flag de carry = 1
		mov cx, 255		; Retorna o contador para o máximo
		
	fgetsEND:
		mov [bx], 0		; Insere o '\0' no final da string
		neg cx
		add cx, 255
		pop bx
		pop dx
		pop ax
		jmp fgetsENDP


fgetsENDP: 
fgets endp

;--------------------------------------------------------------------
;	checkEOFMarker(char* str:bx)
;	ENTRADA: 
;		bx: ponteiro para string
;	SAIDA:
;		CF=1 se iguais, CF=0 caso contrário
;--------------------------------------------------------------------

checkEOFMarker proc near
	cmp byte ptr [bx], 'f'
	jne checkEOFMarkerNE
	cmp byte ptr [1 + bx], 'i'
	jne checkEOFMarkerNE
	cmp byte ptr [2 + bx], 'm'
	jne checkEOFMarkerNE
	cmp byte ptr [3 + bx], 0
	jne checkEOFMarkerNE
	stc
	ret
	checkEOFMarkerNE:
		clc
		ret
checkEOFMarker endp

;--------------------------------------------------------------------
;  subString(char* dst:dx, char* src:bx,  int start:ax, int size:cx)
;	ENTRADA:
;     dx: ponteiro para destino
;     bx: ponteiro para origem
;     ax: posição inicial
;     cx: tamanho
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;--------------------------------------------------------------------
subString proc near
	push si
	push di
	mov si, bx
	add si, ax

	mov di, dx

	subStringLoop:
		mov al, [si]
		mov [di], al
		inc si
		inc di
		loop subStringLoop
	
	;Não conseui fazer com movsb e não entendi o motivo
	;cld
	;rep movsb

	; Adiciona o '\0' no final da string
	mov byte ptr [di], 0

	pop di
	pop si
	ret
subString endp
; 

;--------------------------------------------------------------------

;--------------------------------------------------------------------
parseLine proc near
	push si
	; Busca o primeiro número
	lea si, STRINGBUFFER
	dec si
	mov current, 0
	
	clc ; Limpa a flag de carry

	; Separa a linha em 3 partes com base na virgula
	parseLineNext:
		cmp current, 4 ; Verifica se todas as fases foram lidas
		jg parseLineEnd

		inc si
		cmp byte ptr [si], ','
		je parseLineSplit
		cmp byte ptr [si], 0
		je parseLineSplit
		jmp parseLineNext
		

		parseLineSplit:		
		inc si
		lea dx, STRINGBUFFER2 ; Destino
		mov bx, bx ; String origem
		mov ax, 0
		mov cx, si ; Final da substring
		sub cx, bx ; Tamanho da substring
;		cmp cx, 0 ; Verifica se a substring tem tamanho maior que 0
;		je parseLineFindError
		call subString
	
		; Verifica se a substring tem tamanho maior que 0
		lea bx, STRINGBUFFER2
		call strLen
		cmp cx, 0 ; Verifica se a substring tem tamanho maior que 0
		je parseLineFindError
		
		; Remove os espaços em branco
		lea bx, STRINGBUFFER2
		call trimWhitespace
		jc parseLineFindError


		; Verifica se a substring possui apenas números
		lea bx, STRINGBUFFER2
		mov ah, '9'
		mov al, '0'
		call stringRange
		jc parseLineFindError
		

		; Converte a substring para um número
		lea bx, STRINGBUFFER2
		call atoi

		; Verifica se o número está dentro do intervalo
		cmp ax, 0
		jl parseLineFindError
		cmp ax, 499
		jg parseLineFindError

		; Salva o número
		mov bx, TENSIONPHASES
		add bx, current
		mov [bx], ax
		add current, 2

		; Atualiza o ponteiro para a próxima substring e reinicia o loop
		mov bx, si
		jmp parseLineNext

	; Verifica se todas as fases foram lidas e se estão dentro do intervalo
	parseLineEnd:
		cmp current, 6
		jne parseLineFindError
		jmp parseLineRET

	parseLineFindError:
		stc
		mov ERROR, 1
	
	parseLineRET:
		pop si
		ret
parseLine endp

;--------------------------------------------------------------------
;  getCommandLineArgument(char key:al, char* dest:dx)
;	ENTRADA:
;		STRINGBUFFER: string com os argumentos da linha de comando
;	SAIDA:
;		ERROR=1 se houve erro, ERROR=0 caso contrário
;--------------------------------------------------------------------
getCommandLineArgument proc near
	; al = flag i ou o
	push ax
	push bx
	push cx

	lea bx, STRINGBUFFER
	mov cx, 0
	mov ERROR, 0

	dec bx
	parseCommandLineNext:
		inc bx

		; Verifica se é o final da string
		cmp byte ptr [bx], 0
		je parseCommandLineEmpty

		; Verifica se é o início de um argumento
		cmp byte ptr [bx], '-'
		jne parseCommandLineNext
		cmp byte ptr [1 + bx], al
		jne parseCommandLineNext

		; Verifica se o argumento está vazio
		cmp byte ptr [2 + bx], 0
		je parseCommandLineEmptyError
		
		; Verifica o argumento é correto
		cmp byte ptr [2 + bx], ' '
		jne parseCommandLineNext
		
		add bx, 3 ; Pula para o conteúdo do argumento
		mov auxw_1, bx ; Salva o início do argumento
		parseCommandLineRead:
			cmp byte ptr [bx], ' ' ; Verifica se é o final do argumento
			je parseCommandLineEnd

			cmp byte ptr [bx], 0 ; Verifica se é o final da string
			je parseCommandLineEnd

			inc cx
			inc bx
			jmp parseCommandLineRead
	
	parseCommandLineEnd:
		cmp cx, 0
		je parseCommandLineEmptyError

		mov ax, 0 ; Define a posição inicial para 0
		mov bx, auxw_1 ; Define o ponteiro para o início do argumento
		mov dx, dx ; Define o ponteiro para o destino
		mov cx, cx ; Define o tamanho do argumento
		call subString
		jmp parseCommandLineRet

	parseCommandLineEmptyError:
		mov ERROR, 1

	parseCommandLineEmpty:
	parseCommandLineRet:
	pop cx	
	pop bx
	pop ax

	ret
getCommandLineArgument endp

;--------------------------------------------------------------------
;  strLen(char *string:bx)
;	ENTRADA:
;		BX: string a ser medida
;	SAIDA:
;		CX: tamanho da string
;--------------------------------------------------------------------
strLen proc near
	push bx
	mov cx, 0
	strLenLoop:
		cmp byte ptr [bx], 0
		je strLenEnd
		inc bx
		inc cx
		jmp strLenLoop
	strLenEnd:
	pop bx
	ret
strLen endp

;--------------------------------------------------------------------
;  stringRange(char *string:bx, char min:al, char max:ah)
;	ENTRADA:
;		BX: string para verificar
;		AL: valor mínimo
;		AH: valor máximo
;	SAIDA:
;		Carry=1 se fora do intervalo, Carry=0 caso contrário
;--------------------------------------------------------------------
stringRange proc near
	push bx
	clc ; Limpa a flag de carry
	stringRangeLoop:
		cmp byte ptr [bx], 0
		je stringRangeEnd
		cmp byte ptr [bx], al
		jl stringRangeError
		cmp byte ptr [bx], ah
		jg stringRangeError
		inc bx
		jmp stringRangeLoop

	stringRangeError:
		stc ; Define a flag de carry = 1
	stringRangeEnd:
	pop bx
	ret
stringRange endp

;--------------------------------------------------------------------
;  trimWhitespace(char *string:bx)
;	ENTRADA:
;		BX: string remover os espaços em branco
;	SAIDA:
;		BX: string sem espaços em branco
;       Carry=1 se houve erro, Carry=0 caso contrário
;--------------------------------------------------------------------
trimWhitespace proc near
	push ax 
	push cx
	push si
	push bx
	; AX: Sincio da string
	; CX: tamanho da string
	mov si, bx
	mov cx, 0
	dec si

	; Busca o primeiro caractere diferente de espaço
	trimWhitespaceFStart:
		inc si
		cmp byte ptr [si], 0
		je trimWhitespaceError
		cmp byte ptr [si], ' '
		je trimWhitespaceFStart
		cmp byte ptr [si], TAB
		je trimWhitespaceFStart
	
	mov ax, si ; Salva o início da string
	
	; Busca o último caractere diferente de espaço
	pop bx ; Recupera o início da string
	push bx ; Salva o início da string

	call strLen
	mov si, bx ; Inicializa o ponteiro para o final da string
	add si, cx ; Adiciona o tamanho da string
	
	; Busca o último caractere diferente de espaço
	trimWhitespaceFEnd:
		dec si
		cmp byte ptr [si], ' '
		je trimWhitespaceFEnd
		cmp byte ptr [si], TAB
		je trimWhitespaceFEnd
		
	; Copia a string para o início da string original
		pop dx ; Recupera o início da string
		push dx ; Salva o início da string

	; Verifica se a string tem tamanho maior que 0

	mov bx, ax ; Inicializa o ponteiro para o início da substring
	mov ax, 0 ; Inicializa a posição inicial
	mov cx, si ; Inicializa o tamanho da string
	sub cx, bx ; Calcula o tamanho da string

	;cmp cx, 0 ; Verifica se a string tem tamanho maior que 0
	;jle trimWhitespaceError

	call subString
	
	trimWhitespaceEnd:
	pop bx
	pop si
	pop cx
	pop ax
	ret

	trimWhitespaceError:
		stc
		jmp trimWhitespaceEnd

trimWhitespace endp

;--------------------------------------------------------------------
;  checkTensionsForQuality()
;	SAIDA:
;       Carry=1 se fora do intervalo, Carry=0 caso contrário
;--------------------------------------------------------------------
checkTensionsForQuality proc near
	push ax
	push bx
	push cx
	push dx
	clc 	; Limpa a flag de carry

	mov ax, TENSION 
	add ax, 10 ; Tolera +10V de variação
	mov dx, TENSION
	sub dx, 10 ; Tolera -10V de variação

	; Verifica se a tensão está dentro do intervalo
	mov cx, 2
	mov bx, TENSIONPHASES
	checkTensionsForQualityLoop:
		cmp [bx], dx
		jl checkTensionsForQualityNotInRange
		cmp [bx], ax
		jg checkTensionsForQualityNotInRange
		add bx, 2
		loop checkTensionsForQualityLoop
	
	jmp checkTensionsForQualityRET

	checkTensionsForQualityNotInRange:
	stc

	checkTensionsForQualityRET:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
checkTensionsForQuality endp

;--------------------------------------------------------------------
;  checkLowTensions()
;	SAIDA:
;       Carry=1 se todas a tensões estiver abaixo de 10, Carry=0 caso contrário
;--------------------------------------------------------------------
checkLowTensions proc near
	push ax
	push bx
	push cx
	push dx

	mov ax, 10

	; Verifica se a tensão está dentro do intervalo
	mov cx, 3
	mov bx, TENSIONPHASES
	checkLowTensionsLoop:
		cmp [bx], ax
		jg checkLowTensionsMoreThan10
		add bx, 2
		loop checkLowTensionsLoop
	
	stc
	jmp checkLowTensionsRET		
	
	checkLowTensionsMoreThan10:
		clc
		jmp checkLowTensionsRET

	checkLowTensionsRET:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
checkLowTensions endp

;--------------------------------------------------------------------
;  printResultsToScreen()
;	SAIDA:
;       Imprime os resultados na tela
;--------------------------------------------------------------------
printResultsToScreen proc near
	push ax
	push bx
	push si
	
	lea bx, O_inputFile
	lea si, INPUTFILE
	call puts2

	lea bx, O_outputFile
	lea si, OUTPUTFILE
	call puts2

	mov ax, TENSION
	lea bx, STRINGBUFFER
	call itoa
	lea bx, O_tension
	lea si, STRINGBUFFER
	call puts2

	mov ax, TOTALTIME
	lea bx, STRINGBUFFER
	call formatTime
	lea bx, O_totalTime
	lea si, STRINGBUFFER
	call puts2

	mov ax, TENSIONQUALITY
	lea bx, STRINGBUFFER
	call formatTime
	lea bx, O_tensionQuality
	lea si, STRINGBUFFER
	call puts2

	mov ax, NOTENSION
	lea bx, STRINGBUFFER
	call formatTime
	lea bx, O_noTension
	lea si, STRINGBUFFER
	call puts2

	pop si
	pop bx
	pop ax
	ret

printResultsToScreen endp

;--------------------------------------------------------------------
;  writeResultsToFile()
;	SAIDA:
;       Imprime os resultados na tela
;--------------------------------------------------------------------
writeResultsToFile proc near
	
	push ax
	push bx
	push dx
	push cx

	lea dx, O_inputFile
	lea si, INPUTFILE
	call fputs2

	lea dx, O_outputFile
	lea si, OUTPUTFILE
	call fputs2

	mov ax, TENSION
	lea bx, STRINGBUFFER
	call itoa
	lea dx, O_tension
	lea si, STRINGBUFFER
	call fputs2

	mov ax, TOTALTIME
	lea bx, STRINGBUFFER
	call formatTime
	lea dx, O_totalTime
	lea si, STRINGBUFFER
	call fputs2

	mov ax, TENSIONQUALITY
	lea bx, STRINGBUFFER
	call formatTime
	lea dx, O_tensionQuality
	lea si, STRINGBUFFER
	call fputs2

	mov ax, NOTENSION
	lea bx, STRINGBUFFER
	call formatTime
	lea dx, O_noTension
	lea si, STRINGBUFFER
	call fputs2

	pop cx
	pop dx
	pop bx
	pop ax
	ret
writeResultsToFile endp 

;--------------------------------------------------------------------
;  puts2(char* s:si, char* s:bx)
;	ENTRADA:
;		 SI: ponteiro para string
;		 BX: ponteiro para string
;--------------------------------------------------------------------
puts2 proc near
	push bx

	call puts
	mov bx, si
	call puts
	lea bx, S_newLine
	call puts

	pop bx
	ret 
puts2 endp

;--------------------------------------------------------------------
;  fputs2(char* s:si, char* s:dx)
;	ENTRADA:
;		 SI: ponteiro para string
;		 DX: ponteiro para string
;--------------------------------------------------------------------
fputs2 proc near
	push dx

	call fputs
	mov dx, si
	call fputs
	lea dx, S_newLine
	call fputs

	pop dx
	ret 
fputs2 endp


;--------------------------------------------------------------------
;  fputs(char* s:dx)
;	ENTRADA:
;		dx: ponteiro para string
;	SAIDA:
;		CF=0 se sucesso, CF=1 caso contrário
;--------------------------------------------------------------------
fputs proc near
	push dx

	mov bx, dx
	call strLen

	mov bx, FILEHANDLE
	mov ah, 40h ; Escreve no arquivo
	int 21h
	cmp ax, cx ; Verifica se o número de bytes escritos é igual ao tamanho da string
	jne fputsError
	jmp fputsRET

	fputsError:
	stc
	fputsRET:
	pop dx
	ret

fputs endp
;--------------------------------------------------------------------
;  itoa(int value:ax, char* dest:bx)
;	ENTRADA:
;		AX: valor a ser convertido
;		BX: ponteiro para destino
;	SAIDA:
;		BX: string com o valor convertido
;--------------------------------------------------------------------
; TODO: Substituir por código proprio
itoa proc near
    push ax         ; Save AX register
    push bx         ; Save BX register
    push dx         ; Save DX register
    push di         ; Save DI register

    xor cx, cx      ; Clear CX register (will be used as counter)
    mov di, bx      ; DI = Destination (BX points to the destination string)

    mov bx, 10      ; BX = 10 (for dividing)

convert_loop:
    xor dx, dx      ; Clear DX
    div bx          ; Divide AX by BX (quotient in AX, remainder in DX)
    add dl, '0'     ; Convert remainder to ASCII
    push dx         ; Store the digit on the stack
    inc cx          ; Increment counter

    test ax, ax     ; Check if quotient is zero
    jnz convert_loop ; If not zero, continue the loop

store_loop:
    pop dx          ; Retrieve digit from stack
    mov [di], dl    ; Store digit in destination buffer
    inc di          ; Move to next position in buffer
    loop store_loop ; Continue until counter (CX) becomes zero

    mov [di], 0   ; Null-terminate the string

    pop di          ; Restore DI register
    pop dx          ; Restore DX register
    pop bx          ; Restore BX register
    pop ax          ; Restore AX register
    ret             ; Return from procedure
itoa endp

;--------------------------------------------------------------------
;  formatTime(int value:ax, char* dest:bx)
;	ENTRADA:
;		AX: valor a ser convertido
;		BX: ponteiro para destino
;	SAIDA:
;		BX: string com o valor convertido
;--------------------------------------------------------------------
formatTime proc near
	push ax
	push bx
	push cx
	push dx

	cmp ax, 60 ; Verifica se o valor é menor que 60, ou seja, se é menor que 1 minuto
	jl formatTimeJustITOA
	cmp ax,	3600 ; Verifica se o valor é menor que 3600, ou seja, se é menor que 1 hora
	jl formatTimeMinutes
	
	; Horas
	; Divisão inteira por 3600
	mov dx, 0
	mov cx, 3600
	div cx		; AX = Horas, DX = Resto
	
	call itoa
	cmp ax, 10
	jge formatTime2Digits
	mov byte ptr [bx+1], ':'
	add bx, 2
	mov ax, dx
	jmp formatTimeMinutes

	formatTime2Digits:
		mov byte ptr [bx+2], ':'
		add bx, 3
		mov ax, dx

	formatTimeMinutes:
	; Minutos
	; Divisão inteira por 60
	mov dx, 0
	mov cx, 60
	div cx		; AX = Minutos, DX = Resto
	
	call itoa
	cmp ax, 10
	jge formatTime2Digits_
	mov byte ptr [bx+1], ':'
	mov byte ptr [bx+2], 0
	add bx, 2
	mov ax, dx
	jmp formatTimeSeconds

	formatTime2Digits_:
		mov byte ptr [bx+2], ':'
		add bx, 3
		mov ax, dx

	
	formatTimeSeconds:
	; Segundos
	; Coloca os segundos no destino
	cmp ax, 10
	jge formatTimeJustITOA
	mov byte ptr [bx], '0'
	inc bx
	formatTimeJustITOA:
	call itoa

	mov byte ptr [bx+2], 0
	pop dx
	pop cx
	pop bx
	pop ax
	ret	

formatTime endp


;####################################################################
;       Os procedimentos abaixo foram adaptados dos códigos 
; disponibilizados pelo professor no material de apoio da disciplina
;####################################################################

;--------------------------------------------------------------------
;Escrever um string na tela
;void puts(char *s:BX) {
;	while(*s!='\0') {
;		putchar(*s)
; 		++s;
;	}
;   putchar('\n');
;}
;--------------------------------------------------------------------
puts	proc	near

;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

;	putchar(*s)
	push	bx
	mov		ah,2
	int		21H
	pop		bx

;		++s;
	inc		bx

	jmp		puts

ps_1:
	ret
	
puts	endp

;--------------------------------------------------------------------
;Converte um ASCII-DECIMAL para HEXA
;Entra: (S) -> DS:BX -> Ponteiro para o string de origem
;Sai:	(A) -> AX -> Valor "Hex" resultante
;Algoritmo:
;	A = 0;
;	while (*S!='\0') {
;		A = 10 * A + (*S - '0')
;		++S;
;	}
;	return
;--------------------------------------------------------------------
atoi	proc near

		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		ret

atoi	endp


debugM proc near
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	lea bx, DEBUGMSG
	call puts

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
debugM endp
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
	