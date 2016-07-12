#include <xc.h>

void bsp_init() {
    TRISA = 0x00;
}

inline void bsp_wait_ms(unsigned char x) {
    OPTION_REGbits.PSA = 1;     // No prescaler
    OPTION_REGbits.T0CS = 0;    // Timer 0: Fosc / 4
    // Assumes a 500kHz clock
    for (; x > 0; x--) {
        TMR0 = 0;
        while (TMR0 < 125);
    }
}
