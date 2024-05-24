/*
 * PWM.h
 *
 * Created: 21/05/2024 19:44:18
 *  Author: Alex
 */ 

#ifndef PWM_H_
#define PWM_H_

#include <avr/io.h>


void ConfigTimer0 ();
void ConfigTimer1 ();
void ConfigTimer2 ();

void UpDutyC_S1(uint16_t DutyUpgradeS1);
void UpDutyC_S2(uint16_t DutyUpgradeS2);
void UpDutyC_S3(uint16_t DutyUpgradeS3);
void UpDutyC_S4(uint16_t DutyUpgradeS4);
void UpDutyC_S5(uint16_t DutyUpgradeS5);

#endif /* PWM1_H_ */