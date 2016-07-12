#include <pic12lf1840.h>

#include "p12f1840.h"
#include "rfm70.h"

void main(void) {
    bsp_init();
    rfm70_init();
    
    unsigned char n = 0;
    unsigned char len, pipe;
    unsigned char rx_buf[RFM70_MAX_PACKET_LEN];
    
    while (1) {
//        LATAbits.LATA0 = ~LATAbits.LATA0;
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
//        bsp_wait_ms(250);
        bsp_wait_ms(2);
        
        if (++n == 50) {
            rfm70_mode_transmit();
            rfm70_transmit_message("turn it on", 10);
            bsp_wait_ms(100);
            rfm70_mode_receive();
        }
        
        if (++n > 100) {
            rfm70_mode_transmit();
            rfm70_transmit_message("turn it off", 11);
            bsp_wait_ms(100);
            rfm70_mode_receive();
            n = 0;
        }
        
        if (rfm70_receive(&pipe, &rx_buf, &len)) {
            rfm70_register_write(RFM70_CMD_FLUSH_RX, 0);
        }
    }
}
