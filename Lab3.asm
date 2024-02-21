/***

Universidad del Valle de Guatemala
IE2023: Programación de Microcontroladores
Lab3.asm
Autor: Alexander Rosales
Proyecto: Laboratorio 3
Hardware: ATMEGA328P
Creado: 14/02/2024
Última Modificación: 14/02/2024

***/
/***************************************

Video: https://youtu.be/g55-EuxWnZk

/***************************************
/***
ENCABEZADO
***/
.INCLUDE "M328PDEF.INC" //librería con nombres
.CSEG //Empieza el codigo
.ORG 0x00 //Se inicia en la posición 00

JMP EmpezarCodigo

.ORG 0x0008 
JMP Boton

.ORG 0x0020
JMP FlagCheck

EmpezarCodigo:

/*
STACK POINTER
*/
//Registro en la memoria que nos indica el rango en donde se guardarán las variables locales 
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17


/**
CONFIGURACIÓN
**/
Setup:

	LDI R16, 0b1000_0000 //Activar el prescaler
	STS CLKPR, R16
	LDI R16, 0b0000_0001 //8M
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

	//Interrupciones

	LDI R16, 0b0000_0010 //Botones
	STS PCICR, R16
	LDI R16, 0b0000_0011
	STS PCMSK1, R16

	LDI R16, 0b0000_0001
	STS TIMSK0, R16

	SEI

	RCALL T0 //Se inicia el Timer

	LDI R16, 0
	LDI R17, 0
	LDI R18, 0 //Contador Bits
	LDI R19, 0 // Output de Bits
	LDI R20, 0
	LDI R21, 0
	LDI R22, 0
	LDI R23, 0
	LDI R24, 0
	LDI R25, 0 // Output de Display Segundos
	LDI R26, 0 // Output de Display Segundos
	LDI R27, 0 // Output de Display Segundos
	LDI R28, 0 // Output de Display Decenas 

	
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R26, Z
	OUT PORTD, R26

	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R24, Z
	OUT PORTD, R24
	

/**
Code
**/

Loop:
	
	LDI R16, 0x0F
	AND R19, R16
	LDI R16, 0b_0001_0000
	OR R19, R16
	OUT PORTB, R19
	OUT PORTD, R26

	RCALL Delay

	LDI R16, 0x0F
	AND R19, R16
	LDI R16, 0b_0010_0000
	OR R19, R16
	OUT PORTB, R19
	OUT PORTD, R24
	
	RCALL Delay 


	RJMP Loop
	


FlagCheck:	
	
	LDI R25, 178
	OUT TCNT0, R25

	INC R20
	
	CPI R20, 100
	BRNE RegresarFlag

	CLR R20
	INC R27
	CPI R27, 10
	BREQ ReiniciarContador1
	SeguirContador1:	

	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	
	ADD ZL, R27
	LPM R26, Z

	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	
	ADD ZL, R28
	LPM R24, Z

RegresarFlag:
	RETI

ReiniciarContador1:
	LDI R27, 0
	INC R28
	CPI R28, 6
	BREQ ReiniciarContador2
	SeguirContador2:
	RJMP SeguirContador1

ReiniciarContador2:
	LDI R28, 0
	RJMP SeguirContador2

T0:
	LDI R16, (1 << CS02) | (1 << CS00) //Configuración del pre escalado a 1024
	OUT TCCR0B, R16

	LDI R25, 178
	OUT TCNT0, R25

	RET

Delay:
	LDI R16, 255
	LDI R17, 100
	loop_delay:
		DEC R16
		BRNE loop_delay
		LDI R16, 255
		DEC R17
		BRNE loop_delay
		RET
Boton:
	MOV R22, R20
	IN R18, PINC

	SBRS R18, PC1
	INC R19
	SBRS R18, PC0
	DEC R19

	RETI


Tabla: .DB 0x3F, 0x6, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x67 //0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71