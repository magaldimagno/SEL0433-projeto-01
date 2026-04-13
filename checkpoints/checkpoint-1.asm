; SEL0433 - Aplicação de Microprocessadores
; Projeto 01 - Checkpoint 01
; Alexandre Augusto Novarino Britto - 14754672
; Eduardo Magaldi Magno - 15448780

ORG 0000h
JMP INICIO

; Tabela com os códigos hexadecimais de cada número no display de 7 segmentos
TABELA:
DB 0C0h, 0F9h, 0A4h, 0B0h, 99h, 92h, 82h, 0F8h, 80h, 90h

ORG 0100h
INICIO:
	MOV DPTR, #TABELA ; Armazena a tabela no DPTR (único registrador de 16 bits)
	; Determina qual dos 4 displays será utilizado (00 -> LSB, o display mais à direita)
	CLR P3.3 
	CLR P3.4

CHECK: ; Rotina de checagem. A partir de qual chave está selecionada, é escolhido o número do display. A preferência é dada ao LSB (0 em relação ao 7)
	JNB P2.0, SW0
	JNB P2.1, SW1
	JNB P2.2, SW2
	JNB P2.3, SW3
	JNB P2.4, SW4
	JNB P2.5, SW5
	JNB P2.6, SW6
	JNB P2.7, SW7
	SJMP CHECK

; A partir da chave selecionada, coloca o número no acumulador, que será usado como ponteiro para qual número será ativado no display
SW0:
	MOV A, #00h
	SJMP VIEW

SW1:
	MOV A, #01h
	SJMP VIEW

SW2:
	MOV A, #02h
	SJMP VIEW

SW3:
	MOV A, #03h
	SJMP VIEW

SW4:
	MOV A, #04h
	SJMP VIEW

SW5:
	MOV A, #05h
	SJMP VIEW

SW6:
	MOV A, #06h
	SJMP VIEW

SW7:
	MOV A, #07h
	SJMP VIEW

; Coloca o número escolhido no display, usando o ACC como ponteiro da tabela. 
VIEW:
	MOVC A, @A+DPTR
	MOV P1, A
	SJMP CHECK

END
