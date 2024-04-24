/*
 * PWM1.c
 *
 * Created: 23/04/2024 08:47:39
 *  Author: Alex
 */ 
#include "PWM1.h"

void Init_PWM1_Fast_A()
{
	DDRD |= (1 << DDB1);
	TCCR1A = 0;
	TCCR1B = 0;
	
	TCCR1A |= (1 << WGM10); //Modo de opreacion 14, fast
	TCCR1B |= (1 << WGM13) | (1 << WGM12);
	
	TCCR1B |= (1 << CS12) | (1 << CS10); //Prescaler 1024
	
	TCCR1A |= (1 << COM1A1); //Cuando OC1A haga match, la salida se pondra en 0
	
	ICR1L = 0x4D; //77
	ICR1H = 0x00;

}

void UpDutyC1(uint8_t DutyUpgrade1)
{
	OCR1AL = DutyUpgrade1;
	OCR1AH = 0x00;
}

void Init_PWM2()
{
	
}

void UpDutyC2(uint8_t DutyUpgrade1)
{
	OCR1AL = DutyUpgrade1;
	OCR1AH = 0x00;
}
