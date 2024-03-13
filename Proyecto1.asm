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
	
	Tabla: .DB 0x7E,0x30,0x5B,0x3B,0x35,0x2F,0x6F,0x38,0x7F,0x3D

	.def Config = R19
	.def Estado = R20
	.def Dos_Puntos = R24
	.def AlarmaON = R23
	.def Cada500ms = R22

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
	CLR R21 //Uso Multiple
	CLR R22	//Contador de 500ms
	CLR R23 //SonarAlarma
	CLR R24 //Dos Puntos
	CLR R25 //Contador segundos de la bandera TOV0 
	CLR R26 //Contador minuto de la bandera TOV0
	CLR R27 //Delay
	CLR R28 //Delay
	CLR R29 //Contador de MS

	//RAM
	.equ DisplayConfigurando = 0x0100 //Nos indica cual de los 4 display estamos configurando

	.equ RELOJ1 = 0x0101 //Display 1 RELOJ
	.equ RELOJ2 = 0x0102 //Display 2 RELOJ
	.equ RELOJ3 = 0x0103 //Display 3 RELOJ
	.equ RELOJ4 = 0x0104 //Display 4 RELOJ

	.equ RELOJ1Config = 0x0105 //Display 1 CONFIGURANDO RELOJ 
	.equ RELOJ2Config = 0x0106 //Display 2 CONFIGURANDO RELOJ
	.equ RELOJ3Config = 0x0107 //Display 3 CONFIGURANDO RELOJ
	.equ RELOJ4Config = 0x0108 //Display 4 CONFIGURANDO RELOJ
	
	.equ FECHA1 = 0x0111 //Display 1 FECHA
	.equ FECHA2 = 0x0112 //Display 2 FECHA
	.equ FECHA3 = 0x0113 //Display 3 FECHA
	.equ FECHA4 = 0x0114 //Display 4 FECHA

	.equ FECHA1Config = 0x0115 //Display 1 CONFIGURANDO FECHA
	.equ FECHA2Config = 0x0116 //Display 2 CONFIGURANDO FECHA
	.equ FECHA3Config = 0x0117 //Display 3 CONFIGURANDO FECHA
	.equ FECHA4Config = 0x0118 //Display 4 CONFIGURANDO FECHA

	.equ ALARMA1 = 0x0121 //Display 1 ALARMA
	.equ ALARMA2 = 0x0122 //Display 2 ALARMA
	.equ ALARMA3 = 0x0123 //Display 3 ALARMA
	.equ ALARMA4 = 0x0124 //Display 4 ALARMA

	.equ ALARMA1Config = 0x0125 //Display 1 CONFIGURANDO ALARMA
	.equ ALARMA2Config = 0x0126 //Display 2 CONFIGURANDO ALARMA
	.equ ALARMA3Config = 0x0127 //Display 3 CONFIGURANDO ALARMA
	.equ ALARMA4Config = 0x0128 //Display 4 CONFIGURANDO ALARMA

	.equ Contador500msDesactualizado = 0x010A 
	 
	STS RELOJ1, R16
	STS RELOJ2, R16
	STS RELOJ3, R16
	STS RELOJ4, R16
	STS RELOJ1Config, R16
	STS RELOJ2Config, R16
	STS RELOJ3Config, R16
	STS RELOJ4Config, R16

	LDI R16, 1
	STS FECHA1, R16
	STS FECHA2, R16
	STS FECHA3, R16
	STS FECHA4, R16

	CLR R16
	STS FECHA1Config, R16
	STS FECHA2Config, R16
	STS FECHA3Config, R16
	STS FECHA4Config, R16

	LDI R16, 1
	STS ALARMA1, R16
	STS ALARMA2, R16
	STS ALARMA3, R16
	STS ALARMA4, R16

	CLR R16
	STS ALARMA1Config, R16
	STS ALARMA2Config, R16
	STS ALARMA3Config, R16
	STS ALARMA4Config, R16
	STS DisplayConfigurando, R16

	STS Contador500msDesactualizado, R16

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

CLR R16
STS Contador500msDesactualizado, Cada500ms

Loop:

	CPI AlarmaON, 1
	BRNE EjecutarLoopConEstados

	//Millis :D
	CLR R16
		LDS R16, Contador500msDesactualizado
		CP R16, Cada500ms
		BREQ NoAumentarContador500
			MOV R16, Cada500ms
			STS Contador500msDesactualizado, R16
			INC R18
			CPI R18, 3
			BRNE NoAumentarContador500
			CLR R18
	NoAumentarContador500:

	//--------------------LED
		LDI R16, 0b_0001_0000
		OUT PORTB, R16

		//Selector Dependiendo de R18
			LDI R17, 0

			CPI R18, 0
			BRNE Salto1_LEDAlarma
			LDI R17, 0b0000_1000
			Salto1_LEDAlarma:

			CPI R18, 1
			BRNE Salto2_LEDAlarma
			LDI R17, 0b0000_0100
			Salto2_LEDAlarma:

			CPI R18, 2
			BRNE Salto3_LEDAlarma
			LDI R17, 0b0001_0000
			Salto3_LEDAlarma:

		OUT PORTD, R17
	
		RCALL Delay
	//--------------------LED

	RJMP Loop
	EjecutarLoopConEstados:
	
	SBRC R29, 0
	RJMP DosPuntosOn
	LDI Dos_Puntos, 0b0000_0000
	SeguirDosPuntos:
	

	SBRS Config, 0
	RJMP LoopNormal
	RJMP LoopConfig
	RJMP Loop
	

	//------------------------------ LOOP NORMAL ------------------------------
	LoopNormal:
		//---------------------D1
			CLR R17

			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display1
				LDS R17, RELOJ1
				Salto1_Display1:

				CPI Estado, 1
				BRNE Salto2_Display1
				LDS R17, FECHA1
				Salto2_Display1:

				CPI Estado, 2
				BRNE Salto3_Display1
				LDS R17, ALARMA1
				Salto3_Display1:

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_1000
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17

			RCALL Delay
		//---------------------D1

		//---------------------D2
			CLR R17

			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display2
				LDS R17, RELOJ2
				Salto1_Display2:

				CPI Estado, 1
				BRNE Salto2_Display2
				LDS R17, FECHA2
				Salto2_Display2:

				CPI Estado, 2
				BRNE Salto3_Display2
				LDS R17, ALARMA2
				Salto3_Display2:

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0010
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//---------------------D2

		//---------------------D3
			CLR R17
		
			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display3
				LDS R17, RELOJ3
				Salto1_Display3:

				CPI Estado, 1
				BRNE Salto2_Display3
				LDS R17, FECHA3
				Salto2_Display3:

				CPI Estado, 2
				BRNE Salto3_Display3
				LDS R17, ALARMA3
				Salto3_Display3:

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0100
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17

			RCALL Delay
		//---------------------D3

		//---------------------D4
			CLR R17
		
			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display4
				LDS R17, RELOJ4
				Salto1_Display4:

				CPI Estado, 1
				BRNE Salto2_Display4
				LDS R17, FECHA4
				Salto2_Display4:

				CPI Estado, 2
				BRNE Salto3_Display4
				LDS R17, ALARMA4
				Salto3_Display4:

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_0001
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay 
		//---------------------D4

		//--------------------LED
		LDI R16, 0b_0001_0000
		OUT PORTB, R16

		//Selector Dependiendo del Estado
			CPI Estado, 0
			BRNE Salto1_LED
			LDI R17, 0b0000_1000
			Salto1_LED:

			CPI Estado, 1
			BRNE Salto2_LED
			LDI R17, 0b0000_0100
			Salto2_LED:

			CPI Estado, 2
			BRNE Salto3_LED
			LDI R17, 0b0001_0000
			Salto3_LED:

		OR R17, Dos_Puntos
		OUT PORTD, R17
	
		RCALL Delay
		//--------------------LED
		
	RJMP Loop
	//------------------------------ LOOP NORMAL ------------------------------

	//------------------------------ LOOP CONFIG ------------------------------
	LoopConfig:

		CLR R18
		LDS R18, DisplayConfigurando

		CPI R18, 0
		BREQ SaltarD1_1
		RJMP NoSaltarD1
		SaltarD1_1:
		SBRC R29, 1
		RJMP SaltarD1_2
		NoSaltarD1:

		//---------------------D1
			CLR R17

			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display1Config
				LDS R17, RELOJ1Config
				Salto1_Display1Config:

				CPI Estado, 1
				BRNE Salto2_Display1Config
				LDS R17, FECHA1Config
				Salto2_Display1Config:

				CPI Estado, 2
				BRNE Salto3_Display1Config
				LDS R17, ALARMA1Config
				Salto3_Display1Config:

			RCALL SetTabla
			ADD ZL, R17
			LPM R17, Z

			LDI R16, 0b_0000_1000
			OUT PORTB, R16
			OR R17, Dos_Puntos
			OUT PORTD, R17

			RCALL Delay
		//---------------------D1

		SaltarD1_2:
		CPI Estado, 1
		BRNE SeguirParpadeoNormalD2
		CPI R18, 0
		BREQ SaltarD2_1
		SeguirParpadeoNormalD2:
		CPI R18, 1
		BREQ SaltarD2_1
		RJMP NoSaltarD2
		SaltarD2_1:
		SBRC R29, 1
		RJMP SaltarD2_2
		NoSaltarD2:

		//---------------------D2
			CLR R17
			
			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display2Config
				LDS R17, RELOJ2Config
				Salto1_Display2Config:

				CPI Estado, 1
				BRNE Salto2_Display2Config
				LDS R17, FECHA2Config
				Salto2_Display2Config:

				CPI Estado, 2
				BRNE Salto3_Display2Config
				LDS R17, ALARMA2Config
				Salto3_Display2Config:

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
			
			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display3Config
				LDS R17, RELOJ3Config
				Salto1_Display3Config:

				CPI Estado, 1
				BRNE Salto2_Display3Config
				LDS R17, FECHA3Config
				Salto2_Display3Config:

				CPI Estado, 2
				BRNE Salto3_Display3Config
				LDS R17, ALARMA3Config
				Salto3_Display3Config:

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
		CPI Estado, 1
		BRNE SeguirParpadeoNormalD4
		CPI R18, 2
		BREQ SaltarD4_1
		SeguirParpadeoNormalD4:
		CPI R18, 3
		BREQ SaltarD4_1
		RJMP NoSaltarD4
		SaltarD4_1:
		SBRC R29, 1
		RJMP SaltarD4_2
		NoSaltarD4:

		//---------------------D4
			CLR R17
			
			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_Display4Config
				LDS R17, RELOJ4Config
				Salto1_Display4Config:

				CPI Estado, 1
				BRNE Salto2_Display4Config
				LDS R17, FECHA4Config
				Salto2_Display4Config:

				CPI Estado, 2
				BRNE Salto3_Display4Config
				LDS R17, ALARMA4Config
				Salto3_Display4Config:

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

		//--------------------LED
			LDI R16, 0b_0001_0000
			OUT PORTB, R16

			//Selector Dependiendo del Estado
				CPI Estado, 0
				BRNE Salto1_LEDConfig
				LDI R17, 0b0000_1000
				Salto1_LEDConfig:

				CPI Estado, 1
				BRNE Salto2_LEDConfig
				LDI R17, 0b0000_0100
				Salto2_LEDConfig:

				CPI Estado, 2
				BRNE Salto3_LEDConfig
				LDI R17, 0b0001_0000
				Salto3_LEDConfig:

			OR R17, Dos_Puntos
			OUT PORTD, R17
	
			RCALL Delay
		//--------------------LED

	RJMP Loop
	//------------------------------ LOOP CONFIG ------------------------------
		
	

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
	INC Cada500ms
	RJMP SeguirMedioSegundo

Flag0Check:	
	
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R21

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
	BRNE RegresarFlagTimer0

	CLR R25
	INC R26
	CPI R26, 1
	BRNE RegresarFlagTimer0

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
	BRNE SeguirFinalReloj
	RJMP ReiniciarDia
	
	SeguirFinalReloj:
	RegresarFlagTimer0:

	CLR R16
	CLR R17
	LDS R16, RELOJ1
	LDS R17, ALARMA1
	CP R16, R17
	BRNE NoSonarAlarma
		CLR R16
		CLR R17
		LDS R16, RELOJ2
		LDS R17, ALARMA2
		CP R16, R17
		BRNE NoSonarAlarma
			CLR R16
			CLR R17
			LDS R16, RELOJ3
			LDS R17, ALARMA3
			CP R16, R17
			BRNE NoSonarAlarma
				CLR R16
				CLR R17
				LDS R16, RELOJ4
				LDS R17, ALARMA4
				CP R16, R17
				BRNE NoSonarAlarma
				LDI AlarmaON, 1
				CLR R18
				PUSH R18
	NoSonarAlarma:

	POP R16
	POP R17
	POP R18 
	POP R21
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

		//R18 Contiene el numero correspondiente al mes 
		CLR R18
		LDS R18, FECHA2Config
		LDI R17, 10
		MUL R18, R17
		MOV R18, R0
		CLR R17
		LDS R17, FECHA1Config
		ADD R18, R17
		
		CLR R17
		LDS R17, FECHA4

		CLR R16
		LDS R16, FECHA3
		INC R16
		CPI R16, 10
		BRNE SaltarIncrementoF2
		INC R17
		CLR R16
		SaltarIncrementoF2:
		
		//Verificaciones de Reinicio de Días
		CLR R21

		CPI R18, 2 //Verificación Febrero
		BRNE Verificacion1_Incremento_Fecha
			CPI R17, 3
			BRNE Verificacion1_Incremento_Fecha
			LDI R21, 1
			CLR R17
			LDI R16, 1
			RJMP TerminarIncrementoFecha
		Verificacion1_Incremento_Fecha:

		CPI R18, 4 //Verificación Meses con 30 Días 
		BREQ Incremento2_Fecha
		CPI R18, 6
		BREQ Incremento2_Fecha 
		CPI R18, 9
		BREQ Incremento2_Fecha 
		CPI R18, 11
		BREQ Incremento2_Fecha 
		RJMP Verificacion2_Incremento_Fecha
		Incremento2_Fecha:
			CPI R17, 3
			BRNE Verificacion2_Incremento_Fecha
			CPI R16, 1
			BRNE Verificacion2_Incremento_Fecha
			LDI R21, 1
			CLR R17
			LDI R16, 1
			RJMP TerminarIncrementoFecha
		Verificacion2_Incremento_Fecha:

		CPI R18, 1  //Verificación Meses con 31 Días 
		BREQ Incremento3_Fecha
		CPI R18, 3
		BREQ Incremento3_Fecha
		CPI R18, 5
		BREQ Incremento3_Fecha
		CPI R18, 7
		BREQ Incremento3_Fecha
		CPI R18, 8
		BREQ Incremento3_Fecha
		CPI R18, 10
		BREQ Incremento3_Fecha
		CPI R18, 12
		BREQ Incremento3_Fecha
		RJMP Verificacion3_Incremento_Fecha
		Incremento3_Fecha:
			CPI R17, 3
			BRNE Verificacion3_Incremento_Fecha
			CPI R16, 2
			BRNE Verificacion3_Incremento_Fecha
			LDI R21, 1
			CLR R17
			LDI R16, 1
			RJMP TerminarIncrementoFecha
		Verificacion3_Incremento_Fecha:

		TerminarIncrementoFecha:
		STS FECHA3, R16
		STS FECHA4, R17

		CPI R21, 1
		BRNE NoAumentarMes

		CLR R16
		CLR R17
		LDS R16, FECHA1
		LDS R17, FECHA2

		INC R16
		CPI R16, 10
		BRNE SaltarIncrementoDecimaMes
			CLR R16
			INC R17
		SaltarIncrementoDecimaMes:
		CPI R17, 1
		BRNE SaltarAN // Año Nuevo
		CPI R16, 3
		BRNE SaltarAN // Año Nuevo
			CLR R17
			LDI R16, 1

		SaltarAN:

		STS FECHA1, R16
		STS FECHA2, R17

		NoAumentarMes:

		RJMP RegresarFlagTimer0

T0:
	LDI R16, (1 << CS02) | (1 << CS00) //Configuración del pre escalado a 1024
	OUT TCCR0B, R16

	LDI R16, 178
	OUT TCNT0, R16

	RET

/**************************************************************************
---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---RELOJ---
**************************************************************************/


/**************************************************************************
----BOTONES---BOTONES---BOTONES---BOTONES---BOTONES---BOTONES---BOTONES----
**************************************************************************/

CargarDatosConfig:

	CPI Estado, 0
	BRNE N1_CargaDatosConfig

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

	N1_CargaDatosConfig:
	CPI Estado, 1
	BRNE N2_CargaDatosConfig

		CLR R17
		LDS R17, FECHA1Config
		STS FECHA1, R17

		CLR R17
		LDS R17, FECHA2Config
		STS FECHA2, R17

		CLR R17
		LDS R17, FECHA3Config
		STS FECHA3, R17

		CLR R17
		LDS R17, FECHA4Config
		STS FECHA4, R17

	N2_CargaDatosConfig:
	CPI Estado, 2
	BRNE N3_CargaDatosConfig

		CLR R17
		LDS R17, ALARMA1Config
		STS ALARMA1, R17

		CLR R17
		LDS R17, ALARMA2Config
		STS ALARMA2, R17

		CLR R17
		LDS R17, ALARMA3Config
		STS ALARMA3, R17

		CLR R17
		LDS R17, ALARMA4Config
		STS ALARMA4, R17

	N3_CargaDatosConfig:

	RET

CargarDatosActuales:

	CPI Estado, 0
	BRNE N1_CargaDatosActuales
	
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

	N1_CargaDatosActuales:
	CPI Estado, 1
	BRNE N2_CargaDatosActuales
	
		CLR R17
		LDS R17, FECHA1
		STS FECHA1Config, R17

		CLR R17
		LDS R17, FECHA2
		STS FECHA2Config, R17

		CLR R17
		LDS R17, FECHA3
		STS FECHA3Config, R17

		CLR R17
		LDS R17, FECHA4
		STS FECHA4Config, R17

	N2_CargaDatosActuales:
	CPI Estado, 1
	BRNE N3_CargaDatosActuales
	
		CLR R17
		STS ALARMA1Config, R17
		STS ALARMA2Config, R17
		STS ALARMA3Config, R17
		STS ALARMA4Config, R17

	N3_CargaDatosActuales:

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

ApagarAlarma:
	CLR AlarmaOn
RET

IBotones:

	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R21

	IN R16, PINC

	SBRS R16, PC3
	RCALL ToggleConfig

	SBRS R16, PC2
	RCALL ApagarAlarma
	
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

		SBRS R16, PC2
		RCALL ConfigSiguienteDigito

		CPI Estado, 0
		BRNE NBMC1 
		RJMP ConfigReloj
		
		NBMC1:
		CPI Estado, 1
		BRNE NBMC2
		RJMP ConfigFecha

		NBMC2:
		CPI Estado, 2
		BRNE NBMC3
		RJMP ConfigAlarma

		NBMC3:
		RJMP Salir_IBotones

//---------------- BOTONES CONFIGURACIÓN RELOJ ----------------
	ConfigReloj:
		LDI R17, 0
		IN R16, PINC

		SBRS R16, PC1
		INC R17
		SBRS R16, PC0
		DEC R17

		CLR R16
		LDS R16, DisplayConfigurando
		
		CPI R16, 0
		BRNE NEXT1_ConfigReloj
		RJMP OperacionRelojDisplay1
		NEXT1_ConfigReloj:

		CPI R16, 1
		BRNE NEXT2_ConfigReloj
		RJMP OperacionRelojDisplay2
		NEXT2_ConfigReloj:
		
		CPI R16, 2
		BRNE NEXT3_ConfigReloj
		RJMP OperacionRelojDisplay3
		NEXT3_ConfigReloj:
		
		CPI R16, 3
		BRNE NEXT4_ConfigReloj
		RJMP OperacionRelojDisplay4
		NEXT4_ConfigReloj:
		RJMP Salir_IBotones

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
			CPI R16, 4
			BREQ Reset_R3_UP
			CPI R16, -1
			BREQ Reset_R3_DOWN_2

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

		Reset_R3_DOWN_2:
		LDI R16, 3
		RJMP Seguir_COM_ORD

		OperacionRelojDisplay4:
			CLR R16
			LDS R16, RELOJ4Config
			ADD R16, R17

			CPI R16, 2
			BRNE Seguir_Display3_Check_Range
			//Display3_Check_Range
			CLR R18
			LDS R18, RELOJ3Config
			CPI R18, 4
			BRLO Seguir_Display3_Check_Range
			//Reset_Display3_BC_Display4 (Reinicia el Display 3 porque el Display 4 lo indica)
			CLR R18
			STS RELOJ3Config, R18
			Seguir_Display3_Check_Range:

			CPI R16, 3
			BREQ Reset_R4_UP
			CPI R16, -1
			BREQ Reset_R4_DOWN

			SeguirORD4:
			STS RELOJ4Config, R16

			RJMP Salir_IBotones

		Reset_R4_UP:
		LDI R16, 0
		RJMP SeguirORD4

		Reset_R4_DOWN:
		LDI R16, 2
		RJMP SeguirORD4
//---------------- BOTONES CONFIGURACIÓN RELOJ ----------------

//---------------- BOTONES CONFIGURACIÓN FECHA ----------------
	ConfigFecha:
		LDI R17, 0
		IN R16, PINC

		SBRS R16, PC1
		INC R17
		SBRS R16, PC0
		DEC R17

		CLR R16
		LDS R16, DisplayConfigurando
		CPI R16, 0
		BREQ OperacionFechaDisplay1
		CPI R16, 1
		BREQ CorrerUnDisplayConfigurando
		CPI R16, 2
		BREQ OperacionFechaDisplay3
		CPI R16, 3
		BREQ CorrerUnDisplayConfigurando2

		CorrerUnDisplayConfigurando:
			LDI R16, 2
			STS DisplayConfigurando, R16
		RJMP Salir_IBotones

		CorrerUnDisplayConfigurando2:
			 CLR R16
			 STS DisplayConfigurando, R16
		RJMP Salir_IBotones

		OperacionFechaDisplay1:
			CLR R16
			LDS R16, FECHA1Config
			ADD R16, R17

			CLR R18
			LDS R18, FECHA2Config

			CPI R16, 10
			BREQ Reset_F1_UP
			CPI R16, -1
			BREQ Reset_F1_DOWN
			
			SeguirOFD1:

			CPI R18, 1
			BRNE SaltarReinicioMeses
			CPI R16, 3
			BREQ Reset_F2_UP
			SaltarReinicioMeses:
			CPI R18, -1
			BREQ Reset_F2_DOWN

			SeguirOFD2:

			STS FECHA1Config, R16
			STS FECHA2Config, R18
			RJMP Salir_IBotones

		Reset_F1_UP:
		LDI R16, 0
		INC R18
		RJMP SeguirOFD1

		Reset_F1_DOWN:
		LDI R16, 9
		DEC R18
		RJMP SeguirOFD1

		Reset_F2_UP:
		LDI R16, 1
		CLR R18
		RJMP SeguirOFD2

		Reset_F2_DOWN:
		LDI R18, 1
		LDI R16, 2
		RJMP SeguirOFD2

		OperacionFechaDisplay3:
			CLR R16
			LDS R16, FECHA3Config
			ADD R16, R17
			MOV R21, R17

			//R17 tenrá el numero del Mes en que está 
			CLR R17
			LDS R17, FECHA2Config
			LDI R18, 10
			MUL R17, R18
			MOV R17, R0
			CLR R18
			LDS R18, FECHA1Config
			ADD R17, R18

			CLR R18
			LDS R18, FECHA4Config

			CPI R21, 1
			BRNE DONW_FECHA
			RCALL Reset_F3_UP
			DONW_FECHA:
			RCALL Reset_F3_DOWN

			STS FECHA3Config, R16
			STS FECHA4Config, R18
			RJMP Salir_IBotones

		Reset_F3_UP:

		CPI R16, 10
		BRNE SeguirComprobandoUP0_Meses
			CLR R16
			INC R18
		SeguirComprobandoUP0_Meses:

		CPI R17, 2
		BRNE SeguirComprobandoUP1_Meses
			CPI R18, 3
			BRNE SeguirComprobandoUP1_Meses
			CLR R18
			LDI R16, 1
			RET
		SeguirComprobandoUP1_Meses:
		
		CPI R17, 4
			BREQ ReiniciarCon30DiasUP
		CPI R17, 6
			BREQ ReiniciarCon30DiasUP
		CPI R17, 9
			BREQ ReiniciarCon30DiasUP
		CPI R17, 11
			BREQ ReiniciarCon30DiasUP
		RJMP SeguirComprobandoUP2_Meses

		ReiniciarCon30DiasUP:
			CPI R18, 3
				BRNE SeguirComprobandoUP2_Meses
			CPI R16, 1
				BRSH Reiniciar30UP
				RJMP SeguirComprobandoUP2_Meses
				
				Reiniciar30UP:
				CLR R18
				LDI R16, 1
				RET
		SeguirComprobandoUP2_Meses:

		CPI R17, 1
			BREQ ReiniciarCon31DiasUP
		CPI R17, 3
			BREQ ReiniciarCon31DiasUP
		CPI R17, 5
			BREQ ReiniciarCon31DiasUP
		CPI R17, 7
			BREQ ReiniciarCon31DiasUP
		CPI R17, 8
			BREQ ReiniciarCon31DiasUP
		CPI R17, 10
			BREQ ReiniciarCon31DiasUP
		CPI R17, 12
			BREQ ReiniciarCon31DiasUP
		RET

		ReiniciarCon31DiasUP:
			CPI R18, 3
				BRNE Terminar_Reset_F3_UP
			CPI R16, 2
				BRNE Terminar_Reset_F3_UP
			CLR R18
			LDI R16, 1

		Terminar_Reset_F3_UP:
		RET

		Reset_F3_DOWN:
		CPI R16, -1
		BRNE SeguirComprobandoDOWN0_Meses
			LDI R16, 9
			DEC R18
		SeguirComprobandoDOWN0_Meses:

		CPI R17, 2
		BRNE SeguirComprobandoDOWN1_Meses
			CPI R16, 0
			BRNE SeguirComprobandoDOWN1_Meses
			CPI R18, 0
			BRNE SeguirComprobandoDOWN1_Meses
			LDI R18, 2
			LDI R16, 9
			RET
		SeguirComprobandoDOWN1_Meses:

		CPI R17, 4
			BREQ ReiniciarCon30DiasDOWN
		CPI R17, 6
			BREQ ReiniciarCon30DiasDOWN
		CPI R17, 9
			BREQ ReiniciarCon30DiasDOWN
		CPI R17, 11
			BREQ ReiniciarCon30DiasDOWN
		RJMP SeguirComprobandoDOWN2_Meses

		ReiniciarCon30DiasDOWN:
			CPI R16, 0
			BRNE SeguirComprobandoDOWN2_Meses
			CPI R18, 0
			BRNE SeguirComprobandoDOWN2_Meses
			LDI R18, 3
			CLR R16
			RET
		SeguirComprobandoDOWN2_Meses:

		CPI R17, 1
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 3
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 5
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 7
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 8
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 10
			BREQ ReiniciarCon31DiasDOWN
		CPI R17, 12
			BREQ ReiniciarCon31DiasDOWN
		RET

		ReiniciarCon31DiasDOWN:
			CPI R16, 0
			BRNE Terminar_Reset_F3_DOWN
			CPI R18, 0
			BRNE Terminar_Reset_F3_DOWN
			LDI R18, 3
			LDI R16, 1
			RET

		Terminar_Reset_F3_DOWN:
		RET

//---------------- BOTONES CONFIGURACIÓN FECHA ----------------

//---------------- BOTONES CONFIGURACIÓN ALARMA ----------------
	ConfigAlarma:
		LDI R17, 0
		IN R16, PINC

		SBRS R16, PC1
		INC R17
		SBRS R16, PC0
		DEC R17

		CLR R16
		LDS R16, DisplayConfigurando
		
		CPI R16, 0
		BRNE NEXT1_ConfigAlarma
		RJMP OperacionAlarmaDisplay1
		NEXT1_ConfigAlarma:

		CPI R16, 1
		BRNE NEXT2_ConfigAlarma
		RJMP OperacionAlarmaDisplay2
		NEXT2_ConfigAlarma:
		
		CPI R16, 2
		BRNE NEXT3_ConfigAlarma
		RJMP OperacionAlarmaDisplay3
		NEXT3_ConfigAlarma:
		
		CPI R16, 3
		BRNE NEXT4_ConfigAlarma
		RJMP OperacionAlarmaDisplay4
		NEXT4_ConfigAlarma:
		RJMP Salir_IBotones

		OperacionAlarmaDisplay1:
			CLR R16
			LDS R16, ALARMA1Config
			ADD R16, R17

			CPI R16, 10
			BREQ Reset_A1_UP
			CPI R16, -1
			BREQ Reset_A1_DOWN

			SeguirOAD1:
			STS ALARMA1Config, R16

			RJMP Salir_IBotones

		Reset_A1_UP:
		LDI R16, 0
		RJMP SeguirOAD1

		Reset_A1_DOWN:
		LDI R16, 9
		RJMP SeguirOAD1

		OperacionAlarmaDisplay2:
			CLR R16
			LDS R16, ALARMA2Config
			ADD R16, R17

			CPI R16, 6
			BREQ Reset_A2_UP
			CPI R16, -1
			BREQ Reset_A2_DOWN

			SeguirOAD2:
			STS ALARMA2Config, R16

			RJMP Salir_IBotones

		Reset_A2_UP:
		LDI R16, 0
		RJMP SeguirOAD2

		Reset_A2_DOWN:
		LDI R16, 5
		RJMP SeguirOAD2

		OperacionAlarmaDisplay3:
			CLR R16
			LDS R16, ALARMA3Config
			ADD R16, R17

			CLR R18
			LDS R18, ALARMA4Config
			CPI R18, 2
			BRNE Seguir_COM_OAD
			CPI R16, 4
			BREQ Reset_A3_UP
			CPI R16, -1
			BREQ Reset_A3_DOWN_2

			Seguir_COM_OAD:
			CPI R16, 10
			BREQ Reset_A3_UP
			CPI R16, -1
			BREQ Reset_A3_DOWN

			SeguirOAD3:
			STS ALARMA3Config, R16

			RJMP Salir_IBotones

		Reset_A3_UP:
		LDI R16, 0
		RJMP SeguirOAD3

		Reset_A3_DOWN:
		LDI R16, 9
		RJMP SeguirOAD3

		Reset_A3_DOWN_2:
		LDI R16, 3
		RJMP Seguir_COM_OAD

		OperacionAlarmaDisplay4:
			CLR R16
			LDS R16, ALARMA4Config
			ADD R16, R17

			CPI R16, 2
			BRNE Seguir_Display3_Check_Range_ALARMA
			//Display3_Check_Range
			CLR R18
			LDS R18, ALARMA3Config
			CPI R18, 4
			BRLO Seguir_Display3_Check_Range_ALARMA
			//Reset_Display3_BC_Display4 (Reinicia el Display 3 porque el Display 4 lo indica)
			CLR R18
			STS ALARMA3Config, R18
			Seguir_Display3_Check_Range_ALARMA:

			CPI R16, 3
			BREQ Reset_A4_UP
			CPI R16, -1
			BREQ Reset_A4_DOWN

			SeguirOAD4:
			STS ALARMA4Config, R16

			RJMP Salir_IBotones

		Reset_A4_UP:
		LDI R16, 0
		RJMP SeguirOAD4

		Reset_A4_DOWN:
		LDI R16, 2
		RJMP SeguirOAD4
//---------------- BOTONES CONFIGURACIÓN RELOJ ----------------

	Salir_IBotones:
	POP R16
	POP R17
	POP R18 
	POP R21
	RETI

/**************************************************************************
----BOTONES---BOTONES---BOTONES---BOTONES---BOTONES---BOTONES---BOTONES----
**************************************************************************/

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


SetTabla:
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	RET

