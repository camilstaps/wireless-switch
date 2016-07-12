#include <pic12lf1840.h>

#include <string.h>

#include "p12f1840.h"
#include "rfm70.h"

void main(void) {
    bsp_init();
    rfm70_init();
    
    unsigned char n = 0;
    unsigned char len, pipe;
    unsigned char rx_buf[RFM70_MAX_PACKET_LEN];
    
    while (1) {
//        LATAbits.LATA2 = ~LATAbits.LATA2;
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
        bsp_wait_ms(2);
        
        rfm70_mode_receive();
        if (rfm70_receive(&pipe, rx_buf, &len)) {
            if (len == 10 && strncmp(rx_buf, "turn it on", 10) == 0) {
                SWITCH(1);
            } else if (len == 11 && strncmp(rx_buf, "turn it off", 11) == 0) {
                SWITCH(0);
            }
        }
    }
}
