/*******

Universidad del Valle de Guatemala
IE2023: Programación de Microcontroladores
Prelab1.asm
Autor: Alexander Rosales
Proyecto: Prelaboratorio 1
Hardware: ATMEGA328P
Creado: 30/01/2024
Última Modificación: 05/01/2024

*******/


/*******
ENCABEZADO
*******/
.INCLUDE "M328PDEF.INC" //librería con nombres
.CSEG //Empieza el codigo
.ORG 0x00 //Se inicia en la posición 00


/*******
STACK POINTER
*******/
//Registro en la memoria que nos indica el rango en donde se guardarán las variables locales 
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17


/*******
CONFIGURACIÓN
*******/
Setup:
	
	LDI R16, 0b1000_0000 //Habilitamos el poder modificar la pre escalado de la frecuecia
	STS CLKPR, R16
	LDI R16, 0b0000_0100 //Al cargar este registro, se configura para que la frecuencia se divida por 16
	STS CLKPR, R16
	

	LDI R16, 0b0000_0000 
	OUT DDRC, R16 //Establecer el puerto c como entrada
	LDI R16, 0b1111_1111
	OUT PORTC, R16 //Habilitar los pull ups

	LDI R16, 0b1111_1111 //Configurar los leds como salidas
	OUT DDRB, R16

	LDI R16, 0b1111_1111 //Configurar los leds como salidas
	OUT DDRD, R16

	LDI R18, 0b0000_0000 //Datos 1
	LDI R19, 0b0000_0000 //Datos 2

	LDI R22, 0b0000_0000 //Resultado

	LDI R28, 0b0000_0000


/*******
MAIN CODE
*******/

Loop:
	
	LDI R16, 0b0000_1111 //Limpiamos el nyble cor
	AND R19, R16
	AND R18, R16

	CPSE R18, R28 //Saltamos el multiplexeo si los contadores están en 0, esto con el objetivo de mostrar el resultado
	RCALL Multiplex

	CPSE R19, R28
	RCALL Multiplex
	
	IN R20, PINC

    SBRS R20, PC4
	RJMP Intermedio 

	SBRS R20, PC1
	RJMP Loop
	SBRS R20, PC0
	RJMP Loop
	SBRS R20, PC2
	RJMP Loop
	SBRS R20, PC3
	RJMP Loop
	RJMP Choose

Multiplex:
	LDI R22, 0b0000_0000
	LDI R23, 0b0000_0000

	LDI R16, (1 << PD7) //Multiplex
	OUT PORTD, R16
	OUT PORTB, R18

	RCALL delay2

	LDI R16, (1 << PD6)
	OUT PORTD, R16
	OUT PORTB, R19

	RCALL delay2
	RET

Choose:
	RCALL delay3
	
	IN R20, PINC

	SBRS R20, PC1
	RJMP IncrementarBlue
	SBRS R20, PC0
	RJMP DecrementarBlue

	SBRS R20, PC3
	RJMP IncrementarRed
	SBRS R20, PC2
	RJMP DecrementarRed

	RJMP Loop

Intermedio:
	CPSE R18, R28
	RJMP Resultado
	RJMP Loop

Resultado:
	
	LDI R16, 0b0000_1111

	AND R18, R16
	SWAP R18

	AND R19, R16
	SWAP R19

	ADC R18, R19
	BRCS Carry
	RJMP NoCarry
	Carry:
		LDI R23, 0b0010_0000

	NoCarry:

		MOV R22, R18
		LDI R18, 0b0000_0000
		LDI R19, 0b0000_0000

		SWAP R22
		LSL R22
		LSL R22

		OUT PORTB, R23
		OUT PORTD, R22

		RJMP Loop


DecrementarBlue:

	RCall delay
	IN R20, PINC
	SBRC R20, PC0
	RJMP Loop

	DEC R18 //Codigo para decrementar
	RJMP Loop

IncrementarBlue:

	RCALL delay
	IN R20, PINC
	SBRC R20, PC1
	RJMP Loop

	INC R18 //Codigo para incrementar
	RJMP Loop

DecrementarRed:

	RCall delay
	IN R20, PINC
	SBRC R20, PC2
	RJMP Loop

	DEC R19 //Codigo para decrementar
	RJMP Loop

IncrementarRed:

	RCALL delay
	IN R20, PINC
	SBRC R20, PC3
	RJMP Loop

	INC R19 //Codigo para incrementar
	RJMP Loop
	
delay:
	LDI R16, 150
	loop_delay:
		DEC R16
		BRNE loop_delay
		RET

delay2:
	LDI R16, 50
	loop_delay2:
		DEC R16
		BRNE loop_delay2
		RET

delay3:
	LDI R16, 255
	LDI R17, 3
	loop_delay3:
		DEC R16
		BRNE loop_delay3
		LDI R16, 255
		DEC R17
		BRNE loop_delay3
		RET