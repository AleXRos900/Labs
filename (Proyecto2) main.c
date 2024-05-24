/*
 * MainCode.c
 *
 * Created: 21/05/2024 18:31:13 (XD)
 * Author : Alex
 * Programación de microcontroladores
 * Proyecto 2
 * 
 */ 

#define F_CPU 8000000

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdio.h>
#include <avr/eeprom.h>

#include "PWM/PWM.h"

volatile uint8_t POTLeyendo = 1;
volatile uint8_t POT1 = 0;
volatile uint8_t POT2 = 0;
volatile uint8_t POT3 = 0;
volatile uint8_t POT4 = 0;
volatile uint8_t POT5 = 0;

volatile uint16_t DutyUpgradeS1 = 0;
volatile uint16_t DutyUpgradeS2 = 0;
volatile uint16_t DutyUpgradeS3 = 0;
volatile uint16_t DutyUpgradeS4 = 0;
volatile uint16_t DutyUpgradeS5 = 0;

volatile uint8_t Modo = 1;
volatile uint8_t NoRegistroEEprom  = 1;

uint8_t* PunteroEE = 0; 

unsigned char EEMEM POT1_P1;
unsigned char EEMEM POT2_P1;
unsigned char EEMEM POT3_P1;
unsigned char EEMEM POT4_P1;
unsigned char EEMEM POT5_P1;

unsigned char EEMEM POT1_P2;
unsigned char EEMEM POT2_P2;
unsigned char EEMEM POT3_P2;
unsigned char EEMEM POT4_P2;
unsigned char EEMEM POT5_P2;

unsigned char EEMEM POT1_P3;
unsigned char EEMEM POT2_P3;
unsigned char EEMEM POT3_P3;
unsigned char EEMEM POT4_P3;
unsigned char EEMEM POT5_P3;

unsigned char EEMEM POT1_P4;
unsigned char EEMEM POT2_P4;
unsigned char EEMEM POT3_P4;
unsigned char EEMEM POT4_P4;
unsigned char EEMEM POT5_P4;

void writeTextUart (char * Texto);
void InitUsart(void);

volatile char BufferRX;
volatile char ASCII;

void setup(void);

void init_adc(void);
void GuardarEprom(void);

void setup()
{
	
	CLKPR = (1 << CLKPCE);  // Habilita la modificación del CLKPR
	CLKPR = (1 << CLKPS0);  // Divide la frecuencia por 2 
	
	PCICR = 0;
	PCICR |= (1 << PCIE0) | (1 << PCIE1) | (1 << PCIE2);
	
	PCMSK0 = 0;
	PCMSK0 |= (1 << PCINT5);
	
	PCMSK1 = 0;
	PCMSK1 |= (1 << PCINT13);
	
	PCMSK2 = 0;
	PCMSK2 |= (1 << PCINT20);
	
	
	DDRD = 0b11101110;
	DDRB = 0b00011111;
	DDRC = 0x00;
	PORTC = 0x00;

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

int main(void)
{
	cli();
	setup();
	
	ConfigTimer0();
	ConfigTimer1();
	ConfigTimer2();

	init_adc();
	sei();
	
    while (1) 
    {
		switch (NoRegistroEEprom)
		{
			case 1: PORTD = (PORTD & 0b01111011); break;
				
			case 2: PORTD = (PORTD & 0b01111011) | (1 << PD7); break;
				
			case 3: PORTD = (PORTD & 0b01111011) | (1 << PD2); break;
			
			case 4: PORTD = (PORTD & 0b01111011) | (1 << PD2) | (1 << PD7); break;
				
		}
		
		switch (Modo)
		{
			case 1:
				PORTD = (PORTD & 0b11110111) | (1 << PD3);
				PORTB = (PORTB & 0b01101110);
			break;
			
			case 2:
				PORTD = (PORTD & 0b11110111);
				PORTB = (PORTB & 0b01101110) | (1 << PB4);
			break;
			
			case 3:
				PORTD = (PORTD & 0b11110111) | (1 << PD3);
				PORTB = (PORTB & 0b01101110) | (1 << PB4);
			break;
		}
		
		DutyUpgradeS1 = ((POT1 * (19 - 6)) / 255) + 6;
		DutyUpgradeS2 = ((POT2 * (19 - 6)) / 255) + 6;
		DutyUpgradeS3 = ((POT3 * (62 - 31)) / 255) + 31;
		DutyUpgradeS4 = ((POT4 * (62 - 31)) / 255) + 31;
		DutyUpgradeS5 = ((POT5 * (19 - 6)) / 255) + 6;

		UpDutyC_S1(DutyUpgradeS1);
		UpDutyC_S2(DutyUpgradeS2);
		UpDutyC_S3(DutyUpgradeS3);
		UpDutyC_S4(DutyUpgradeS4);
		UpDutyC_S5(DutyUpgradeS5);
	
	}
}

//-------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------ADC-----------------------------------------------------
//-------------------------------------------------------------------------------------------------------------

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
		
	ADCSRA |= (1 << ADSC);
}

ISR(ADC_vect)
{
	ADCSRA &= ~(1 << ADEN);
	
	switch (POTLeyendo)
	{
		case 1:
			POTLeyendo++;
			ADMUX = (ADMUX & 0xF0) | 0x01;  // Configura la lectura del canal A1
			POT1 = ADCH;
		break;

		case 2:
			POTLeyendo++;
			ADMUX = (ADMUX & 0xF0) | 0x02;  // Configura la lectura del canal A2
			POT2 = ADCH;
		break;

		case 3:
			POTLeyendo++;
			ADMUX = (ADMUX & 0xF0) | 0x03;  // Configura la lectura del canal A3
			POT3 = ADCH;
		break;

		case 4:
			POTLeyendo++;
			ADMUX = (ADMUX & 0xF0) | 0x04;  // Configura la lectura del canal A4
			POT4 = ADCH;
		break;

		case 5:
			POTLeyendo = 1;
			ADMUX = (ADMUX & 0xF0);  // Configura la lectura del canal A0
			POT5 = ADCH;
		break;
	}
	
	ADCSRA |= (1 << ADEN);
	ADCSRA |= (1 << ADSC);  // Comienza la siguiente conversión

}

//-------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------ADC-----------------------------------------------------
//-------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------BOTONES-----------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------

ISR(PCINT0_vect) 
{
	if (!(PINB & (1 << PB5)))
	{ 
		NoRegistroEEprom++;
		if (NoRegistroEEprom == 5) { NoRegistroEEprom = 1; }
			
		if (Modo == 3)
		{
			switch (NoRegistroEEprom)
			{
				case 1:
					POT1 = eeprom_read_byte(&POT1_P1);
					POT2 = eeprom_read_byte(&POT2_P1);
					POT3 = eeprom_read_byte(&POT3_P1);
					POT4 = eeprom_read_byte(&POT4_P1);
					POT5 = eeprom_read_byte(&POT5_P1);
				break;
				
				case 2:
					POT1 = eeprom_read_byte(&POT1_P2);
					POT2 = eeprom_read_byte(&POT2_P2);
					POT3 = eeprom_read_byte(&POT3_P2);
					POT4 = eeprom_read_byte(&POT4_P2);
					POT5 = eeprom_read_byte(&POT5_P2);
				break;
				
				case 3:
					POT1 = eeprom_read_byte(&POT1_P3);
					POT2 = eeprom_read_byte(&POT2_P3);
					POT3 = eeprom_read_byte(&POT3_P3);
					POT4 = eeprom_read_byte(&POT4_P3);
					POT5 = eeprom_read_byte(&POT5_P3);
				break;
				
				case 4:
					POT1 = eeprom_read_byte(&POT1_P4);
					POT2 = eeprom_read_byte(&POT2_P4);
					POT3 = eeprom_read_byte(&POT3_P4);
					POT4 = eeprom_read_byte(&POT4_P4);
					POT5 = eeprom_read_byte(&POT5_P4);
				break;
			}
		}
	}
}

ISR(PCINT1_vect) 
{
	if (!(PINC & (1 << PC5))) 
	{ 
		Modo++;
		if (Modo == 4) {Modo = 1;}
		if (Modo == 1) {ADCSRA |= (1 << ADEN); ADCSRA |= (1 << ADSC);}
		if (Modo != 1) {ADCSRA &= ~(1 << ADEN);}
	}
}

ISR(PCINT2_vect)
{

	if ((!(PIND & (1 << PD4))) && (Modo != 3))
	{
		GuardarEprom();
	}
	
}


//-----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------BOTONES-----------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------EEPROM-----------------------------------------------------
//----------------------------------------------------------------------------------------------------------------

void GuardarEprom()
{
	// 1-5 EEprom (Registro 1 EEPROM) 
	// 6-10 EEprom (Registro 2 EEPROM)
	// 11-15 EEprom (Registro 3 EEPROM)
	// 16-20 EEprom (Registro 4 EEPROM)
	switch (NoRegistroEEprom)
	{
		case 1:
			eeprom_write_byte(&POT1_P1, POT1);
			PunteroEE++;
			eeprom_write_byte(&POT2_P1, POT2);
			PunteroEE++;
			eeprom_write_byte(&POT3_P1, POT3);
			PunteroEE++;
			eeprom_write_byte(&POT4_P1, POT4);
			PunteroEE++;
			eeprom_write_byte(&POT5_P1, POT5);
		break;
		
		case 2:
			eeprom_write_byte(&POT1_P2, POT1);
			PunteroEE++;
			eeprom_write_byte(&POT2_P2, POT2);
			PunteroEE++;
			eeprom_write_byte(&POT3_P2, POT3);
			PunteroEE++;
			eeprom_write_byte(&POT4_P2, POT4);
			PunteroEE++;
			eeprom_write_byte(&POT5_P2, POT5);
		break;
		
		case 3:
			eeprom_write_byte(&POT1_P3, POT1);
			PunteroEE++;
			eeprom_write_byte(&POT2_P3, POT2);
			PunteroEE++;
			eeprom_write_byte(&POT3_P3, POT3);
			PunteroEE++;
			eeprom_write_byte(&POT4_P3, POT4);
			PunteroEE++;
			eeprom_write_byte(&POT5_P3, POT5);
		break;
		
		case 4:
			eeprom_write_byte(&POT1_P4, POT1);
			PunteroEE++;
			eeprom_write_byte(&POT2_P4, POT2);
			PunteroEE++;
			eeprom_write_byte(&POT3_P4, POT3);
			PunteroEE++;
			eeprom_write_byte(&POT4_P4, POT4);
			PunteroEE++;
			eeprom_write_byte(&POT5_P4, POT5);
		break;	
		
	}
	

}

//----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------EEPROM-----------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
