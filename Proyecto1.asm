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
JMP Flag0Check

EmpezarCodigo:

/*
STACK POINTER
*/
//Registro en la memoria que nos indica el rango en donde se guardarán las variables locales 
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17


/*------------------MEMORIA RAM--------------------

| Dirección de memoria | Descripción           |
|----------------------|-----------------------|
| 0x0100 - 0x08FF      | Memoria RAM (2048 B)  |

--------------------MEMORIA RAM------------------*/

/**
CONFIGURACIÓN
**/
Setup:
	
	.def Config = R19
	.def Estado = R20
	.def Dos_Puntos = R24

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
	CLR R18 //Uso Multiple
	CLR R19	//Config
	CLR R20 //Estado
	CLR R21 //
	CLR R22	//
	CLR R23 //
	CLR R24 //Dos Puntos
	CLR R25 //Contador segundos de la bandera TOV0 
	CLR R26 //Contador minuto de la bandera TOV0
	CLR R27 //Delay
	CLR R28 //Delay
	CLR R29 //Contador de MS

	//RAM

	.equ RELOJ1 = 0x0101 //Display 1 RELOJ
	.equ RELOJ2 = 0x0102 //Display 2 RELOJ
	.equ RELOJ3 = 0x0103 //Display 3 RELOJ
	.equ RELOJ4 = 0x0104 //Display 4 RELOJ

	.equ RELOJ1Config = 0x0105 //Display 1 RELOJ
	.equ RELOJ2Config = 0x0106 //Display 2 RELOJ
	.equ RELOJ3Config = 0x0107 //Display 3 RELOJ
	.equ RELOJ4Config = 0x0108 //Display 4 RELOJ
	.equ DisplayConfigurando = 0x0109

	STS RELOJ1, R16
	STS RELOJ2, R16
	STS RELOJ3, R16
	STS RELOJ4, R16
	STS RELOJ1Config, R16
	STS RELOJ2Config, R16
	STS RELOJ3Config, R16
	STS RELOJ4Config, R16
	STS DisplayConfigurando, R16

	
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R16, Z
	OUT PORTD, R16

/**
Code
**/

DosPuntosOn:
	LDI Dos_Puntos, 0b1000_0000
RJMP SeguirDosPuntos

Loop:
	
	CPI R29, 1
	BREQ DosPuntosOn
	LDI Dos_Puntos, 0b0000_0000
	SeguirDosPuntos:
	

	SBRS Config, 0
	RJMP LoopNormal
	
	//--Loop Congif--

		CPI Estado, 0
		BRNE NLC1
		RJMP LoopRelojConfig
		NLC1:

		CPI Estado, 1
		BRNE NLC2
		RJMP LoopFechaConfig
		NLC2:

		CPI Estado, 2
		BRNE NLC3
		RJMP LoopAlarmaConfig
		NLC3:

	RJMP Loop
	
	LoopNormal:

		CPI Estado, 0
		BRNE NLN1
		RJMP LoopReloj
		NLN1:

		CPI Estado, 1
		BRNE NLN2
		RJMP LoopFecha
		NLN2:

		CPI Estado, 2
		BRNE NLN3
		RJMP LoopAlarma
		NLN3:

	RJMP Loop

	//----------- Reloj --------------- 
	LoopReloj:
		//--------------------D1
		
		CLR R17
		LDS R17, RELOJ1

		RCALL SetTabla
		ADD ZL, R17
		LPM R17, Z

		LDI R16, 0b_0000_1000
		OUT PORTB, R16
		OR R17, Dos_Puntos
		OUT PORTD, R17

		RCALL Delay

		//---------------------D2

		CLR R17
		LDS R17, RELOJ2

		RCALL SetTabla
		ADD ZL, R17
		LPM R17, Z

		LDI R16, 0b_0000_0010
		OUT PORTB, R16
		OR R17, Dos_Puntos
		OUT PORTD, R17
	
		RCALL Delay

		//---------------------D3

		CLR R17
		LDS R17, RELOJ3

		RCALL SetTabla
		ADD ZL, R17
		LPM R17, Z

		LDI R16, 0b_0000_0100
		OUT PORTB, R16
		OR R17, Dos_Puntos
		OUT PORTD, R17

		RCALL Delay

		//---------------------D4

		CLR R17
		LDS R17, RELOJ4

		RCALL SetTabla
		ADD ZL, R17
		LPM R17, Z

		LDI R16, 0b_0000_0001
		OUT PORTB, R16
		OR R17, Dos_Puntos
		OUT PORTD, R17
	
		RCALL Delay 

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0000_1000
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED
		
	RJMP Loop

	LoopRelojConfig:

		CLR R18
		LDS R18, DisplayConfigurando

		
		CPI R18, 0
		BREQ SaltarD1_1
		RJMP NoSaltarD1
		SaltarD1_1:
		SBRC R29, 1
		RJMP SaltarD1_2
		NoSaltarD1:

		//--------------------D1
			CLR R17
			LDS R17, RELOJ1Config

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_1000
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17

			RCALL Delay
		//--------------------D1

		SaltarD1_2:
		CPI R18, 1
		BREQ SaltarD2_1
		RJMP NoSaltarD2
		SaltarD2_1:
		SBRC R29, 1
		RJMP SaltarD2_2
		NoSaltarD2:

		//---------------------D2
			CLR R17
			LDS R17, RELOJ2Config

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0010
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------D2

		SaltarD2_2:
		CPI R18, 2
		BREQ SaltarD3_1
		RJMP NoSaltarD3
		SaltarD3_1:
		SBRC R29, 1
		RJMP SaltarD3_2
		NoSaltarD3:

		//---------------------D3
			CLR R17
			LDS R17, RELOJ3Config

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0100
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17

			RCALL Delay
		//---------------------D3

		SaltarD3_2:
		CPI R18, 3
		BREQ SaltarD4_1
		RJMP NoSaltarD4
		SaltarD4_1:
		SBRC R29, 1
		RJMP SaltarD4_2
		NoSaltarD4:

		//---------------------D4
			CLR R17
			LDS R17, RELOJ4Config

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0001
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------D4
	SaltarD4_2:

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0000_1000
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED

	RJMP Loop
	//----------- Reloj ---------------
		
	//----------- Fecha ---------------
	LoopFecha:
		LDI R16, 0b_0000_0000
		OUT PORTB, R16
		LDI R17, 0
		OUT PORTD, R17

		RCALL Delay

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0000_0100
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED

	RJMP Loop

	LoopFechaConfig:
		LDI R16, 0b_0000_1111
		OUT PORTB, R16
		LDI R17, 1
		OUT PORTD, R17

		RCALL Delay

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0000_0100
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED

	RJMP Loop
	//----------- Fecha ---------------


	//----------- Alarma ---------------
	LoopAlarma:
		LDI R16, 0b_0000_0000
		OUT PORTB, R16
		LDI R17, 0
		OUT PORTD, R17

		RCALL Delay

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0001_0000
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED

	RJMP Loop

	LoopAlarmaConfig:
		LDI R16, 0b_0000_1111
		OUT PORTB, R16
		LDI R17, 1
		OUT PORTD, R17

	RCALL Delay

		//---------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16
			LDI R17, 0b0001_0000
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------LED
	RJMP Loop
	//----------- Alarma ---------------
	
	

/**************************************************************************
---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---
**************************************************************************/
DecimaSegundo:
	LDI R16, 2
	EOR R29, R16
	RJMP SeguirDecimaSegundo

MedioSegundo:
	LDI R16, 1
	EOR R29, R16
	RJMP SeguirMedioSegundo

Flag0Check:	
	
	LDI R16, 178
	OUT TCNT0, R16

	INC R25 //Cada vez que la vandera TOV0 se encuienda, R25 suma 1
	
	SBRS R25, 0
	RJMP DecimaSegundo
	SeguirDecimaSegundo:

	CPI R25, 50
	BREQ MedioSegundo
	SeguirMedioSegundo:

	CPI R25, 100
	BRNE RegresarFlag

	CLR R25
	INC R26
	CPI R26, 60
	BRNE RegresarFlag

	CLR R26

	CLR R16
	LDS R16, RELOJ1
	INC R16
	STS RELOJ1, R16

	CPI R16, 10
	BREQ ReiniciarContador1
	SeguirContador1:	

	CLR R16
	LDS R16, RELOJ4
	CPI R16, 2
	BREQ ReiniciarDia
	SeguirFinalReloj:

RegresarFlag:
	RETI

	ReiniciarContador1:
		LDI R16, 0
		STS RELOJ1, R16

		CLR R16
		LDS R16, RELOJ2
		INC R16
		STS RELOJ2, R16

		CPI R16, 6

		BREQ ReiniciarContador2
		SeguirContador2:
		RJMP SeguirContador1

	ReiniciarContador2:
		LDI R16, 0
		STS RELOJ2, R16

		CLR R16
		LDS R16, RELOJ3
		INC R16
		STS RELOJ3, R16

		CPI R16, 10

		BREQ ReiniciarContador3
		SeguirContador3:
		RJMP SeguirContador2

	ReiniciarContador3:
		LDI R16, 0
		STS RELOJ3, R16

		CLR R16
		LDS R16, RELOJ4
		INC R16
		STS RELOJ4, R16

		RJMP SeguirContador3

	ReiniciarDia:
		CLR R16
		LDS R16, RELOJ3
		CPI R16, 4
		BREQ Reinicio
		SalirReinicio:
		RJMP SeguirFinalReloj

	Reinicio:
		CLR R16
		STS RELOJ1, R16
		STS RELOJ2, R16
		STS RELOJ3, R16
		STS RELOJ4, R16

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
	LDI R27, 255
	LDI R28, 10
	loop_delay:
		DEC R27
		BRNE loop_delay
		LDI R27, 255
		DEC R28
		BRNE loop_delay
		RET

CargarDatosConfig:
	CLR R17
	LDS R17, RELOJ1Config
	STS RELOJ1, R17

	CLR R17
	LDS R17, RELOJ2Config
	STS RELOJ2, R17

	CLR R17
	LDS R17, RELOJ3Config
	STS RELOJ3, R17

	CLR R17
	LDS R17, RELOJ4Config
	STS RELOJ4, R17
	RET

CargarDatosActuales:
	CLR R17
	LDS R17, RELOJ1
	STS RELOJ1Config, R17

	CLR R17
	LDS R17, RELOJ2
	STS RELOJ2Config, R17

	CLR R17
	LDS R17, RELOJ3
	STS RELOJ3Config, R17

	CLR R17
	LDS R17, RELOJ4
	STS RELOJ4Config, R17
	RET

ToggleConfig:
	LDI R17, 1
	EOR Config, R17
	SBRS Config, 0
	RCALL CargarDatosConfig
	SBRC Config, 0
	RCALL CargarDatosActuales
	RET

ReiniciarDisplayConfigurando:
	LDI R17, 0
	RJMP SeguirReiniciarDisplayConfigurando

ConfigSiguienteDigito:
	CLR R17
	LDS R17, DisplayConfigurando
	INC R17
	CPI R17, 4
	BREQ ReiniciarDisplayConfigurando
	SeguirReiniciarDisplayConfigurando:
	STS DisplayConfigurando, R17
	RET


IBotones:

	IN R16, PINC

	SBRS R16, PC2
	RCALL ConfigSiguienteDigito

	SBRS R16, PC3
	RCALL ToggleConfig
	
	SBRC Config, 0
	RJMP Botones_Modo_Config

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

ReiniciarEstadoDerecha:
	LDI Estado, 0
	RJMP Salir_IBotones

ReiniciarEstadoIzquierda:
	LDI Estado, 2
	RJMP Salir_IBotones

	//Botones Modo Config
Botones_Modo_Config:

		CPI Estado, 0
		BREQ ConfigReloj
		//CPI Estado, 1
		//BREQ ConfigFecha
		//CPI Estado, 2
		//BREQ ConfigAlarma
		RJMP Salir_IBotones

	ConfigReloj:
		LDI R17, 0
		//IN R16, PINC

		SBRS R16, PC1
		INC R17
		SBRS R16, PC0
		DEC R17

		CLR R16
		LDS R16, DisplayConfigurando
		CPI R16, 0
		BREQ OperacionRelojDisplay1
		CPI R16, 1
		BREQ OperacionRelojDisplay2
		CPI R16, 2
		BREQ OperacionRelojDisplay3
		CPI R16, 3
		BREQ OperacionRelojDisplay4

		OperacionRelojDisplay1:
			CLR R16
			LDS R16, RELOJ1Config
			ADD R16, R17

			CPI R16, 10
			BREQ Reset_R1_UP
			CPI R16, -1
			BREQ Reset_R1_DOWN

			SeguirORD1:
			STS RELOJ1Config, R16
			RJMP Salir_IBotones

		Reset_R1_UP:
		LDI R16, 0
		RJMP SeguirORD1

		Reset_R1_DOWN:
		LDI R16, 9
		RJMP SeguirORD1

		OperacionRelojDisplay2:
			CLR R16
			LDS R16, RELOJ2Config
			ADD R16, R17

			CPI R16, 6
			BREQ Reset_R2_UP
			CPI R16, -1
			BREQ Reset_R2_DOWN

			SeguirORD2:
			STS RELOJ2Config, R16
			RJMP Salir_IBotones

		Reset_R2_UP:
		LDI R16, 0
		RJMP SeguirORD2

		Reset_R2_DOWN:
		LDI R16, 5
		RJMP SeguirORD2

		OperacionRelojDisplay3:
			CLR R16
			LDS R16, RELOJ3Config
			ADD R16, R17

			CLR R18
			LDS R18, RELOJ4Config
			CPI R18, 2
			BRNE Seguir_COM_ORD
			CPI R16, 5
			BREQ Reset_R3_UP

			Seguir_COM_ORD:
			CPI R16, 10
			BREQ Reset_R3_UP
			CPI R16, -1
			BREQ Reset_R3_DOWN

			SeguirORD3:
			STS RELOJ3Config, R16
			RJMP Salir_IBotones

		Reset_R3_UP:
		LDI R16, 0
		RJMP SeguirORD3

		Reset_R3_DOWN:
		LDI R16, 9
		RJMP SeguirORD3

		OperacionRelojDisplay4:
			CLR R16
			LDS R16, RELOJ4Config
			ADD R16, R17

			CPI R16, 3
			BREQ Reset_R4_UP
			CPI R16, -1
			BREQ Reset_R4_DOWN

			SeguirORD4:
			STS RELOJ4Config, R16
			RJMP Salir_IBotones

		Reset_R4_UP:
		LDI R16, 0
		STS RELOJ3Config, R16
		RJMP SeguirORD4

		Reset_R4_DOWN:
		LDI R16, 2
		RJMP SeguirORD4


	Salir_IBotones:
	RETI


SetTabla:
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	RET

Tabla: .DB 0x7E,0x30,0x5B,0x3B,0x35,0x2F,0x6F,0x38,0x7F,0x3D
