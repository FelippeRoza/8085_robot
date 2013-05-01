DELAY	EQU 10H		;para rotina atraso
CMD 	EQU 20H
CHAVES 	EQU 21H
LEDS 	EQU 22H
LETECLA EQU 02E7H
MOSTRAA EQU 036EH
MOSTRAD EQU 0363H     

;-----------inicializacoes-------------

    	ORG 2000H

	MVI A,02H

    	OUT CMD
	CALL WR_TG	;posiciona o alvo
	LXI SP,PILHA
	LXI H,21D1H	;posiciona o robo no inicio do mapa
	CALL FRENTE
	


;-----------programa-------------------
	

LOOP:	CALL CMPARE
	CALL OBSTX	
	;CALL ATRASO
	IN CHAVES	;identifica obstaculo dinamico
	CPI 01
	JZ DESVX
	JMP LOOP

DESVIA: CALL DIR
	JMP LOOP



;---------subrotinas locomocao-----------
	ORG 2070H

FRENTE:	PUSH PSW	;como o A sera alterado, seu valor atual
	MVI A,07H	;e guardado na pilha por precaucao
	OUT LEDS
	INX H;		;faz o robo andar pra frente
	JMP VOLTA

TRAS:	PUSH PSW
	DCX H		;faz o robo andar pra tras
	MVI A,03H
	OUT LEDS	;output nos leds, simbolizando os drivers
	JMP VOLTA	;que acionam os motores

DIR:	PUSH PSW
	MVI A,06H
	OUT LEDS
	MOV A,L
	ADI 10H
	MOV L,A
	JMP VOLTA	

ESQ:	PUSH PSW
	MVI A,05H
	OUT LEDS	
	MOV A,L
	ADI F0H
	MOV L,A
	JMP VOLTA

PARA:	PUSH PSW	;o robo para, em caso extremo
	MVI A,00H
	OUT LEDS
	JMP TRETA

VOLTA: 	POP PSW		;somente para nao repetir os dois comandos
	RET		;quatro vezes
;----------------------------------------
;--------subrotinas de comparacao--------
OBSTX:	INX H		;verifica se tem obstaculo a frente
	PUSH PSW
	MOV A,M
	DCX H
	CPI FFH
	JZ DESVX
	POP PSW
	CALL FRENTE
	RET
DESVX:	POP PSW
	CALL DIR
	CALL FRENTE
	CALL FRENTE
	CALL ESQ
	RET

OBSTY:
;---------mais subrotinas----------------
TRETA: 	PUSH H		;para o robo mostrar onde travou
	MVI D, 00H
	MVI E, 0EH	
	CALL MOSTRAD	;sinaliza que o robo travou
	POP H
	JMP TRETA

WR_TG:	LXI H,TARGETX
	MOV B,M
	INX H
	MOV C,M
	PUSH B
	POP H
	MVI M,55H
	
	RET

CMPARE: MOV A,M
	CPI 55H
	JZ SUCESSO
	RET

SUCESSO: MVI A,FFH
	OUT LEDS
	CALL ATRASO
	MVI A,00H
	OUT LEDS
	JMP SUCESSO

ATRASO:	MVI C,DELAY	;"Atraso" equivalente a 80 iterações;
ATRASO2:DCR C 		;C := C - 1
	JNZ ATRASO2 ; 	Sai do laço se C == 0
	RET
;-----------pilha------------------------
	DS 16
PILHA: 	DB FF

;------Declaracao das variaveis-----------	 
	ORG 2120
TARGETX	DB 21		;vetor [xy], com um nibble para x e um para y
TARGETY DB DE
DIREC	DB 00		;indica a direcao que o robo esta se movendo
	ORG 21C0H
MAPA	DB FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF
MAPA2	DB FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF

	END

