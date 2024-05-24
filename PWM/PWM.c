/*
 * PWM.c
 *
 * Created: 21/05/2024 19:44:39
 *  Author: Alex
 */ 

#include "PWM.h"
#include <avr/io.h>

void ConfigTimer0()
{
	TCCR0A = 0;
	TCCR0A |= (1 << COM0A1) | (1 << COM0B1); //Configura el modo fast de ambos pines
	TCCR0A |= (1 << WGM01) | (1 << WGM00); //Configurar el modo 7
	
	TCCR0B = 0;
	//TCCR0B |= (1 << WGM02); //Configurar el modo FAST con top FF
	
	TCCR0B |= (1 << CS00) | (1 << CS02); //Preescaler de 1024 con una frecuencia de reloj de 8M para poder tener un periodo de actualización de 32ms
	
}


void ConfigTimer1()
{

	DDRB |= (1 << DDB1) | (1 << DDB2);
	
	TCCR1A = 0;
	TCCR1A |= (1 << COM1A1) | (1 << COM1B1); //Configura el modo fast de ambos pines
	TCCR1A |= (1 << WGM11);  //Configurar el modo 14
	
	TCCR1B = 0;
	TCCR1B |= (1 << WGM13) | (1 << WGM12); 
	TCCR1B |= (1 << CS12); //Con un preescaler de 256, queriendo un pwm de 50hz, teniendo una frecuencia de reloj de 8M, el TOP queda con un valor de 624
	
	ICR1 = 624;

}

void ConfigTimer2()
{
	TCCR2A = 0;
	TCCR2A |= (1 << COM2A1); //Configura el modo fast 
	TCCR2A |= (1 << WGM21) | (1 << WGM20); //Configurar el modo 
	
	TCCR2B = 0;
	//TCCR2B |= (1 << WGM22); //Configurar el modo FAST con top FF
	
	TCCR2B |= (1 << CS20) | (1 << CS22) | (1 << CS21); //Preescaler de 1024 con una frecuencia de reloj de 8M para poder tener un periodo de actualización de 32ms
	
}


void UpDutyC_S1(uint16_t DutyUpgradeS1)
{
	OCR0A = DutyUpgradeS1;
}

void UpDutyC_S2(uint16_t DutyUpgradeS2)
{
	OCR0B = DutyUpgradeS2;
}

void UpDutyC_S3(uint16_t DutyUpgradeS3)
{
	OCR1A = DutyUpgradeS3;
}

void UpDutyC_S4(uint16_t DutyUpgradeS4)
{
	OCR1B = DutyUpgradeS4;
}

void UpDutyC_S5(uint16_t DutyUpgradeS5)
{
	OCR2A = DutyUpgradeS5;
}
