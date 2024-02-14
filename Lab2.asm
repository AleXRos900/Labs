/*************

Universidad del Valle de Guatemala
IE2023: Programación de Microcontroladores
Lab2.asm
Autor: Alexander Rosales
Proyecto: Laboratorio 2
Hardware: ATMEGA328P
Creado: 06/02/2024
Última Modificación: 11/02/2024

*************/



/************************************************************

VIDEO DE LABORATORIO: https://youtu.be/UtxkZes-1vY

*************************************************************/



/*************
ENCABEZADO
*************/
.INCLUDE "M328PDEF.INC" //librería con nombres
.CSEG //Empieza el codigo
.ORG 0x00 //Se inicia en la posición 00


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
	OUT PORTD, R16

	RCALL T0 //Se inicia el Timer


	LDI R20, 0 //Reservado para contar con el timer
	LDI R17, 0 //Reservado para la sumatoria de leds
	LDI R25, 0 //Reservado para SABER cuando se activo la bandera TOV0
	LDI R26, 0 //Display
	LDI R27, 0 //Contar Botones

	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	LPM R26, Z
	OUT PORTD, R26

/**************
Code
**************/
Loop:

	IN R18, PINC //Comparar que los botones no están presionados para entrar al selector
	LDI R16, 0b0000_0011
	AND R18, R16
	CPSE R18, R16
	RJMP Next
	RCALL Selector
	Next:
	 
	OUT PORTD, R26

	CP R27, R17 //Se compara si el contador en binario y el display tienene el mismo valor
	BREQ Led_Alarma //Si tienen el mismo valor, entrará a la subrutina del led alarma
	LDI R19, 0b0000_0000

	LED_A_ON:
	OR R19, R17
	OUT PORTB, R19

	RJMP FlagCheck //Se checkea el timer

	Led_Alarma:
	LDI R19, 0b0010_0000
	RJMP LED_A_ON
	

Selector:
	RCALL Delay // En este delay es cuando se debe presionar el botón 
	
	IN R18, PINC //Se lee el pin y se entra a la subrutina correspondiente

	SBRS R18, PC1
	RCALL Sumar
	SBRS R18, PC0
	RCALL Restar

	RET

Sumar:
	RCALL Delay //Se implementa el antirebote
	IN R18, PINC
	SBRC R18, PC1
	RET

	INC R27 //Está parte del codigo es para crear un loop de numeros en el display
	CPI R27, 16 
	BREQ NextSuma

	SeguirSuma:
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)

	ADD ZL, R27 //R27 nos indica el numero que tiene que mostrar el display 
	LPM R26, Z
	RET

	NextSuma:
	LDI R27, 0
	JMP SeguirSuma

Restar:
	RCALL Delay //Se implementa el antirebote
	IN R18, PINC
	SBRC R18, PC0
	RET

	DEC R27 //Está parte del codigo es para crear un loop de numeros en el display
	CPI R27, -1
	BREQ NextResta

	SeguirResta:
	LDI ZL, LOW (Tabla << 1)
	LDI ZH, HIGH (Tabla << 1)
	
	ADD ZL, R27
	LPM R26, Z
	RET

	NextResta:
	LDI R27, 15
	JMP SeguirResta

FlagCheck:
	
	IN R25, TIFR0 //Leer flag
	CPI R25, (1 << TOV0) //Leer si la bandera de desbordamiento está encendida 
	BRNE Loop

	LDI R25, 61 //Haciendo los calculos se concluyó que 61 era lo que se tenía que esperar con 2mhz y un prescalado de 1024
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
	CP R17,	R28 //Cuando el contador binario sea mayor al display, este se reinicia 
	BRPL ReiniciarLed

	SeguirLeds:
	RJMP Loop

ReiniciarLed:
LDI R17, 0
RJMP SeguirLeds

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

Tabla: .DB 0x3F, 0x6, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71