; SEL0433 - Aplicacao de Microprocessadores
; Projeto 01 - Checkpoint 03
; Alexandre Augusto Novarino Britto - 14754672
; Eduardo Magaldi Magno - 15448780

ORG 0000h
JMP INICIO

; Tabela com os codigos hexadecimais de cada numero no display de 7 segmentos
TABELA:
DB 0C0h, 0F9h, 0A4h, 0B0h, 99h, 92h, 82h, 0F8h, 80h, 90h

ORG 0100h
INICIO:
	MOV DPTR, #TABELA ; Armazena a tabela no DPTR
	; Determina qual dos 4 displays sera utilizado (00 -> LSB, o display mais a direita)
	CLR P3.3 
	CLR P3.4
	; Ativa e configura o contador externo: Bit 6 (C/T) em nivel alto, para atuar como contador. Bits 5 e 4 (M1 e M0) estao em '1' e '0', configurando o Modo 2 (8 bits com reload automatico)
	MOV TMOD, #01100000b ; Contador no modo 1 
	SETB TR1
	; Escrevendo 246 no contador, para ajustar o overflow a sequencia de 0 a 9:
	MOV TH1, #0F6h 
	MOV TL1, #0F6h
	; Definicao do estado padrao do motor
	SETB F0	 ; Inicia a variavel de estado (F0) em nivel logico alto, para ser condizente com o estado inicial das chaves
	; Estado inicial do motor no sentido horario:
 	SETB P3.0 ; Coloca o pino P3.0 em nivel alto
 	CLR P3.1 ; Coloca o pino P3.1 em nivel baixo

LEITURA:
	CALL VERIFICA_CHAVE ; Chama a sub-rotina para ler a chave de direcao
	CALL CONTAGEM ; Processamento da Contagem
	SJMP LEITURA

VERIFICA_CHAVE:
	JB F0, ESTADO_ATUAL_UM ; Se F0 for 1, desvia para a logica correspondente

ESTADO_ATUAL_ZERO:
	; F0 = 0. Checa se a chave P2.7 indica um estado diferente (1)
	JB P2.7, CHAMA_MUDANCA ; Se a chave for 1, desvia para alterar o sentido
	RET ; Se a chave for 0, retorna ao laco principal

ESTADO_ATUAL_UM:
    ; F0 = 1. Checa se a chave P2.7 indica um estado diferente (0)
    JNB P2.7, CHAMA_MUDANCA ; Se a chave for 0, desvia para alterar o sentido
    RET ; Se a chave for 1, retorna ao laco principal

CHAMA_MUDANCA:
    CALL INVERTE_MOTOR ; Chama a rotina que atua no hardware do motor
    RET  

INVERTE_MOTOR: 
    ; Executa a mudanca de direcao alternando os niveis logicos
    CPL F0 ; Inverte a variavel de estado do motor
    CPL P3.0 ; Inverte o acionamento do pino P3.0
    CPL P3.1 ; Inverte o acionamento do pino P3.1
	MOV TL1, #0F6h ; Reseta o contador para contar as voltas no estado atual do motor. O valor é o mesmo de 246, para ajustar o overflow a sequencia de 0 a 9.
    RET

CONTAGEM:
	MOV A, TL1 ; Le o contador de voltas atual 
	CLR C ; Limpa o carry para a operacao de subtracao
	SUBB A, #0F6h ; Subtrai o valor de 246, para obter a contagem de 0 a 9
	MOVC A, @A+DPTR ; Busca o padrao no display (CP1)
	MOV C, F0 ; Usa C para armazenar F0, para que o ponto decimal do display seja aceso ou apagado de acordo com o estado do motor. Ponto apagado = sentido horario, ponto aceso = sentido anti-horario.
	MOV ACC.7, C ; Move o valor do carry para o bit 7 do acumulador, correspondente ao ponto decimal do display.
	MOV P1, A ; Atualiza o display de 7 segmentos
	RET


	



