/***

Universidad del Valle de Guatemala
IE2023: Programación de Microcontroladores
Lab3.asm
Autor: Alexander Rosales
Proyecto: Proyecto 1
Hardware: ATMEGA328P
Creado: 20/02/2024
Última Modificación: 20/02/2024

***/

/***
ENCABEZADO
***/
.INCLUDE "M328PDEF.INC" //librería con nombres
.CSEG //Empieza el codigo
.ORG 0x00 //Se inicia en la posición 00

JMP EmpezarCodigo

.ORG 0x0008
JMP IBotones

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
	
	.def Config = R19
	.def Estado = R20

	LDI R16, 0b1000_0000 //Activar el prescaler
	STS CLKPR, R16
	LDI R16, 0b0000_0001 //8M
	STS CLKPR, R16

	LDI R16, 0b0000_0000 //Se configura el puerto c como entradas 
	OUT DDRC, R16

	LDI R16, 0x00 //Se desactiva la led de TX y RX que constantemente está encendida
	STS UCSR0B, R16

	LDI R16, 0b1111_1111 //Se configura puerdo B Y D como salidas 
	OUT DDRB, R16
	OUT DDRD, R16

	//Interrupciones

	LDI R16, 0b0000_0010 //Botones
	STS PCICR, R16
	LDI R16, 0b0000_1111
	STS PCMSK1, R16

	LDI R16, 0b0000_0001
	STS TIMSK0, R16

	SEI

	RCALL T0 //Se inicia el Timer

	CLR R16	//Uso Multiple
	CLR R17 //Uso Multiple
	CLR R18 //
	CLR R19	//Config
	CLR R20 //Estado
	CLR R21 //
	CLR R22	//
	CLR R23 //
	CLR R24 // 
	CLR R25 //Contador de la bandera TOV0 
	CLR R26 //Reloj
	CLR R27 //Reloj
	CLR R28 //Reloj
	CLR R29 //Reloj

	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R16, Z
	OUT PORTD, R16

/**
Code
**/

Loop:

	CPI Estado, 0
	BREQ LoopReloj
	CPI Estado, 1
	BREQ LoopFecha
	CPI Estado, 2
	BREQ LoopAlarma
	RJMP Loop

	//----------- Reloj --------------- 
	LoopReloj:
		//--------------------D1
		
		RCALL SetTabla
		ADD ZL, R26
		LPM R17, Z

		LDI R16, 0b_0000_1000
		OUT PORTB, R16
		OUT PORTD, R17

		RCALL Delay

		//---------------------D2

		RCALL SetTabla
		ADD ZL, R27
		LPM R17, Z

		LDI R16, 0b_0000_0010
		OUT PORTB, R16
		OUT PORTD, R17
	
		RCALL Delay

		//---------------------D3

		RCALL SetTabla
		ADD ZL, R28
		LPM R17, Z

		LDI R16, 0b_0000_0100
		OUT PORTB, R16
		OUT PORTD, R17

		RCALL Delay

		//---------------------D4

		RCALL SetTabla
		ADD ZL, R29
		LPM R17, Z

		LDI R16, 0b_0000_0001
		OUT PORTB, R16
		OUT PORTD, R17
	
		RCALL Delay 
		
	RJMP Loop
	//----------- Reloj ---------------
		
	//----------- Fecha ---------------
	LoopFecha:
		LDI R16, 0b_0000_0000
		OUT PORTB, R16
		LDI R17, 0
		OUT PORTD, R17
	RJMP Loop
	//----------- Fecha ---------------


	//----------- Alarma ---------------
	LoopAlarma:
		LDI R16, 0b_0000_0000
		OUT PORTB, R16
		LDI R17, 0
		OUT PORTD, R17
	RJMP Loop
	//----------- Alarma ---------------
	
	

/**************************************************************************
---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---
**************************************************************************/
FlagCheck:	
	
	LDI R16, 178
	OUT TCNT0, R16

	INC R25
	
	CPI R25, 1
	BRNE RegresarFlag

	CLR R25
	INC R26

	CPI R26, 10
	BREQ ReiniciarContador1
	SeguirContador1:	

	CPI R29, 2
	BREQ ReiniciarDia
	SeguirFinalReloj:

RegresarFlag:
	RETI

	ReiniciarContador1:
		LDI R26, 0
		INC R27
		CPI R27, 6
		BREQ ReiniciarContador2
		SeguirContador2:
		RJMP SeguirContador1

	ReiniciarContador2:
		LDI R27, 0
		INC R28
		CPI R28, 10
		BREQ ReiniciarContador3
		SeguirContador3:
		RJMP SeguirContador2

	ReiniciarContador3:
		LDI R28, 0
		INC R29
		RJMP SeguirContador3

	ReiniciarDia:
		CPI R28, 4
		BREQ Reinicio
		SalirReinicio:
		RJMP SeguirFinalReloj

	Reinicio:
		CLR R26
		CLR R27
		CLR R28
		CLR R29
		RJMP SalirReinicio

/**************************************************************************
---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---
**************************************************************************/

T0:
	LDI R16, (1 << CS02) | (1 << CS00) //Configuración del pre escalado a 1024
	OUT TCCR0B, R16

	LDI R16, 178
	OUT TCNT0, R16

	RET

Delay:
	LDI R16, 255
	LDI R17, 50
	loop_delay:
		DEC R16
		BRNE loop_delay
		LDI R16, 255
		DEC R17
		BRNE loop_delay
		RET

ToggleConfig:
	LDI R17, 1
	EOR Config, R17
	RET

IBotones:

	IN R16, PINC

	SBRS R16, PC3
	RCALL ToggleConfig
	
	SBRC Config, 0
	JMP Botones_Modo_Config

	//Botones Modo Estado
	SBRS R16, PC1
	INC Estado
	SBRS R16, PC0
	DEC Estado

	CPI Estado, 3
	BREQ ReiniciarEstadoDerecha
	CPI Estado, -1
	BREQ ReiniciarEstadoIzquierda
	RJMP Salir_IBotones

	Botones_Modo_Config:
	RJMP Salir_IBotones


	Salir_IBotones:
	RETI


ReiniciarEstadoDerecha:
LDI Estado, 0
RJMP Salir_IBotones

ReiniciarEstadoIzquierda:
LDI Estado, 2
RJMP Salir_IBotones

SetTabla:
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	RET

Tabla: .DB 0x7E,0x30,0x5B,0x3B,0x35,0x2F,0x6F,0x38,0x7F,0x3D
