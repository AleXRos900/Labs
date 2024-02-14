/*************

Universidad del Valle de Guatemala
IE2023: Programación de Microcontroladores
Lab3.asm
Autor: Alexander Rosales
Proyecto: Laboratorio 3
Hardware: ATMEGA328P
Creado: 14/02/2024
Última Modificación: 14/02/2024

*************/

/*************
ENCABEZADO
*************/
.INCLUDE "M328PDEF.INC" //librería con nombres
.CSEG //Empieza el codigo
.ORG 0x00 //Se inicia en la posición 00

JMP EmpezarCodigo

.ORG 0x0008 
JMP Boton

EmpezarCodigo:
/***
STACK POINTER
***/
//Registro en la memoria que nos indica el rango en donde se guardarán las variables locales 
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

/**************
CONFIGURACIÓN
**************/
Setup:

	LDI R16, 0b1000_0000 //Activar el prescaler
	STS CLKPR, R16
	LDI R16, 0b0000_0011 //2M
	STS CLKPR, R16

	LDI R16, 0b0000_0000 //Se configura el puerto c como entradas pullup
	OUT DDRC, R16
	LDI R16, 0b1111_1111
	OUT PORTC, R16

	LDI R16, 0x00 //Se desactiva la led de TX y RX que constantemente está encendida
	STS UCSR0B, R16

	LDI R16, 0b1111_1111 //Se configura 
	OUT DDRB, R16
	OUT DDRD, R16

	LDI R16, 0b0000_0010
	STS PCICR, R16
	LDI R16, 0b0000_0011
	STS PCMSK1, R16

	RCALL T0 //Se inicia el Timer

	LDI R18, 0 //Contador Bits
	/*
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R26, Z
	OUT PORTD, R26
	*/

/**************
Code
**************/

Loop:
	
	OUT PORTB, R18

	RJMP Loop
	

/*
FlagCheck:
	
	IN R25, TIFR0 //Leer flag
	CPI R25, (1 << TOV0) //Leer si la bandera de desbordamiento está encendida 
	BRNE Loop

	LDI R25, 61
	OUT TCNT0, R25
	SBI TIFR0, TOV0

	INC R20
	CPI R20, 10
	BRNE Loop

	CLR R20
	INC R17

	LDI R16, 0b0000_1111
	AND R17, R16

	MOV R28, R27
	INC R28
	CP R17,	R28
	BRPL ReiniciarLed

	SeguirLeds:
	RJMP Loop

ReiniciarLed:
LDI R17, 0
RJMP SeguirLeds

*/
T0:
	LDI R16, (1 << CS02) | (1 << CS00) //Configuración del pre escalado a 1024
	OUT TCCR0B, R16

	LDI R25, 61
	OUT TCNT0, R25

	RET

Delay:
	LDI R16, 100
	loop_delay:
		DEC R16
		BRNE loop_delay
		RET
Boton:
	RCALL Delay
	IN R18, PINC

	SBRS R18, PC1
	INC R18
	SBRS R18, PC0
	DEC R18

	LDI R16, 0x0F
	AND R18, R16

	RETI

Tabla: .DB 0x3F, 0x6, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71