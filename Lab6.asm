/*
 * Lab6.c
 *
 * Created: 24/04/2024 13:54:45
 * Author : Alex
 */ 


#include <avr/io.h>
#define F_CPU 16000000

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdio.h>

void setup(void);
void init_adc(void);
void InitUsart (void);

void writeUART(char caracter);
void writeTextUart (char * Texto);

volatile uint8_t Pot = 0;
volatile char BufferRX;
volatile char ASCII;

volatile uint8_t Estado = 0;
volatile uint8_t menu = 0;


int main(void)
{
	
	cli();
	setup();
	InitUsart();
	init_adc();	
	sei();
    /* Replace with your application code */
		
    while (1) 
    {
		
		if ((Estado == 0) && (menu == 0))
		{
			writeTextUart("Elija una opcion \r\n 1) Leer Potenciometro \r\n 2) Escribir ACSII \r\n" );
			menu = 1;
		}
		if ((Estado == 0) && (BufferRX == 49)) {Estado = 1;}
		if ((Estado == 0) && (BufferRX == 50)) {Estado = 2;}
			
		if ((Estado == 1) && (menu == 1))
		{
			PORTB = Pot >> 2;
			PORTD = Pot << 6;
			char POTE[20];
			sprintf(POTE, "%d", Pot);
			writeTextUart(POTE);
			writeTextUart("\r\n");
			menu = 2;
			
		}
		if ((Estado == 2) && (menu == 1))
		{
			writeTextUart("Ingrese el ASCII \r\n ");
			menu = 3;
		}
		
		
    }
}

void writeUART(char Texto)
{
	while(!(UCSR0A & (1 << UDRE0)));
	UDR0 = Texto;
}

ISR(USART_RX_vect)
{
	BufferRX = UDR0;
	writeUART(BufferRX);
	writeTextUart("\r\n");
	if (Estado == 2)
	{
		ASCII = UDR0;
		PORTB = BufferRX >> 2;
		PORTD = BufferRX << 6;
	}
	if (menu == 2)
	{
		menu = 0;
		Estado = 0;
	}
	if ((Estado == 2) && (menu == 3))
	{
		menu = 2;
	}
}

void writeTextUart (char * Texto)
{
	uint8_t i;
	for(i = 0; Texto[i] != '\0'; i++)
	{
		while(!(UCSR0A & (1 << UDRE0)));
		UDR0 = Texto[i];
	}
}

void setup()
{
	DDRB = 0xFF;
	DDRD = 0xFE; 
	
	DDRD &= ~(1<<DDD0);
	DDRD |= (1 << DDD1);
	
}

void InitUsart()
{
	UCSR0A = 0;
	
	//Modo fast
	UCSR0A |= (1 << U2X0);
	
	UCSR0B = 0;
	
	//Habilitar la interrupcion de Lectura
	UCSR0B |= (1 << RXCIE0);
	//Hanilitamos Tx y Rx 
	UCSR0B |= (1 << RXEN0) | (1 << TXEN0) ;
	
	UCSR0C = 0; //8bits, No paridad, 1 bit de stop
	UCSR0C |= (1 <<	UCSZ01) | (1 << UCSZ00);
	
	//Baudrate de 57600
	UBRR0 = 34;	
	
}

void init_adc()
{
	ADCSRA = 0;
	ADCSRA |= (1 << ADEN); //Habilita el ADC
	ADCSRA |= (1 << ADATE); //Habilita el auto trigger
	ADCSRA |= (1 << ADIE); //Habilita la mascara de interrupción
	
	ADCSRA |= (1 << ADPS2); //Configura el prescaler a 128
	ADCSRA |= (1 << ADPS1);
	ADCSRA |= (1 << ADPS0);

	ADCSRB = 0;
	
	ADMUX = 0;
	ADMUX |= (1 << REFS0);
	ADMUX |= (1 << ADLAR); //Justificado a la Izquierda
	ADMUX |= 0b00000000; //Analogico 7
	
	ADCSRA |= (1 << ADSC);
}

ISR(ADC_vect)
{
	Pot = ADCH;
	ADCSRA |= (1 << ADIF);	
}
