#ifndef _12F1840_RFM70_H_
#define _12F1840_RFM70_H_

#include <xc.h>
#include "p12f1840.h"

#define RFM70_SCK( x )   LATAbits.LATA1 = x
#define RFM70_MOSI( x )  LATAbits.LATA0 = x ? 1 : 0
#define RFM70_MISO       LATAbits.LATA2
#define RFM70_CSN( x )   LATAbits.LATA4 = x
#define RFM70_CE( x )    LATAbits.LATA5 = x

#define RFM70_PIN_DIRECTION { \
   TRISAbits.TRISA0 = 0; \
   TRISAbits.TRISA1 = 0; \
   TRISAbits.TRISA2 = 1; \
   TRISAbits.TRISA4 = 0; \
   TRISAbits.TRISA5 = 0; \
}

#define RFM70_WAIT_US( x )
#define RFM70_WAIT_MS( x ) bsp_wait_ms( x )

#include "rfm70.h"

#endif