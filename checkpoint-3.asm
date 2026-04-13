; SEL0433 - Aplicação de Microprocessadores
; Projeto 01 - Checkpoint 03
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
	; Ativa e configura o contador externo: Bit 6 (C/T) em nível alto, para atuar como contador. Bits 5 e 4 (M1 e M0) estão em '0' e '1', configurando o Modo 1 (16 bits)
	MOV TMOD, #01010000b ; Contador no modo 1 
	SETB TR1
	; Definição do estado padrão do motor
	SETB F0	 ; Inicia a variável de estado (F0) em nível lógico alto, para ser condizente com o estado inicial das chaves
	; Estado inicial do motor no sentido horário:
   SETB P3.0	 ; Coloca o pino P3.0 em nível alto
   CLR P3.1 ; Coloca o pino P3.1 em nível baixo

LEITURA:
	CALL VERIFICA_CHAVE ; Chama a sub-rotina para ler a chave de direção
	CALL CONTAGEM ; Processamento da Contagem
	SJMP LEITURA

VERIFICA_CHAVE:
	JB F0, ESTADO_ATUAL_UM ; Se F0 for 1, desvia para a lógica correspondente

ESTADO_ATUAL_ZERO:
	; F0 é 0. Checa se a chave P2.7 indica um estado diferente (1)
	JB P2.7, CHAMA_MUDANCA ; Se a chave for 1, desvia para alterar o sentido
	RET ; Se a chave for 0, retorna ao laço principal

ESTADO_ATUAL_UM:
    ; F0 é 1. Checa se a chave P2.7 indica um estado diferente (0)
    JNB P2.7, CHAMA_MUDANCA ; Se a chave for 0, desvia para alterar o sentido
    RET ; Se a chave for 1, retorna ao laço principal

CHAMA_MUDANCA:
    CALL INVERTE_MOTOR ; Chama a rotina que atua no hardware do motor
    RET  

INVERTE_MOTOR: 
    ; Executa a mudança de direção alternando os níveis lógicos
    CPL F0 ; Inverte a variável de estado do motor
    CPL P3.0 ; Inverte o acionamento do pino P3.0
    CPL P3.1 ; Inverte o acionamento do pino P3.1
    RET

CONTAGEM:
	MOV A, TL1 ; Lê o contador de voltas atual 
	MOVC A, @A+DPTR ; Busca o padrão no display (CP1)
	MOV P1, A ; Atualiza o display de 7 segmentos
	RET
	
