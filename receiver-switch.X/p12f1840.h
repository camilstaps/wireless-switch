#ifndef P12F1840_H
#define	P12F1840_H

#pragma config CLKOUTEN = OFF
#pragma config FCMEN = ON
#pragma config MCLRE = OFF
#pragma config WDTE = OFF
#pragma config CPD = OFF
#pragma config FOSC = INTOSC
#pragma config BOREN = ON
#pragma config IESO = ON
#pragma config PWRTE = ON
#pragma config CP = OFF
#pragma config PLLEN = OFF
#pragma config LVP = OFF
#pragma config WRT = ALL
#pragma config STVREN = ON
#pragma config BORV = LO

#define SWITCH( x )   LATAbits.LATA2 = x

void bsp_init();

inline void bsp_wait_ms(unsigned char x);

#endif	/* P12F1840_H */

