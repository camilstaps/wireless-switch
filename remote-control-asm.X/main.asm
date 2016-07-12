    include <p12lf1840.inc>

    __CONFIG _CONFIG1, _CLKOUTEN_OFF & _FCMEN_ON & _MCLRE_ON & _WDTE_OFF & _CPD_OFF & _FOSC_INTOSC & _BOREN_ON & _IESO_ON & _PWRTE_ON & _CP_OFF
    __CONFIG _CONFIG2, _PLLEN_OFF & _LVP_OFF & _WRT_ALL & _STVREN_ON & _BORV_LO
    
RFM_OFFSET      EQU 0x20
DELAY_OFFSET    EQU 0x30
SPI_OFFSET      EQU 0x40

SPI_PIN_SDO     EQU 0x00
SPI_PIN_SCK     EQU 0x01
SPI_PIN_SDI     EQU 0x02
SPI_PIN_CS      EQU 0x04
  
movff macro from, to
    banksel from
    movf    from, W
    banksel to
    movwf   to
    endm
  
movlf macro arg, file
    banksel file
    movlw   arg
    movwf   file
    endm

spi_enable macro
    banksel LATA
    bcf        LATA, SPI_PIN_CS
    endm

spi_disable macro
    banksel LATA
    bsf        LATA, SPI_PIN_CS
    endm

spi_init macro
    banksel TRISA
    bcf        TRISA, SPI_PIN_SDO ; Ports
    bcf        TRISA, SPI_PIN_SCK
    bsf        TRISA, SPI_PIN_SDI
    bcf        TRISA, SPI_PIN_CS
    spi_disable
    banksel    SSP1STAT
    clrf       SSP1STAT           ; When to sample / transmit
    clrf       SSP1CON1           ; SPI master mode, Fosc / 4, clock low when idle
    bsf        SSP1CON1, SSPEN    ; Enable SPI
    endm

spi_writel macro arg
    movlw   arg
    call    spi_write
    endm

spi_writef macro reg
    banksel reg
    movf    reg, W
    call    spi_write
    endm
    
delay macro time
    banksel DELAY_H
    movlw   time
    call    _delay
    endm

RESET_VECTOR CODE 0x0000          ; processor reset vector
    goto    start                 ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

start:
    banksel PORTA
    clrf    PORTA
    banksel LATA
    clrf    LATA
    banksel TRISA
    clrf    TRISA
    
    spi_init
    
main:
    movlw   0xcc
    call    spi_write
    delay   0x05
    goto    main
    
;;; SPI
  
SPI_TEMP    EQU SPI_OFFSET + 0x00

spi_write:
    banksel SPI_TEMP
    movwf   SPI_TEMP                ; Store argument
    banksel SSP1BUF                 ; Clear buffer
    movf    SSP1BUF, W
    spi_enable
    bcf     SSP1CON1, WCOL          ; Clear collision detection bit
    movff   SPI_TEMP, SSP1BUF       ; Move data to buffer
    btfsc   SSP1CON1, WCOL          ; Continue until success
    goto    $-3
    spi_disable
    return
    
spi_read:
    banksel SSP1STAT
    btfss   SSP1STAT, BF            ; Wait for data
    goto    $-1
    movf    SSP1BUF, W
    return

;;; RFM70
    
RFM_REG	    EQU RFM_OFFSET + 0x00
RFM_VAL     EQU RFM_OFFSET + 0x01
RFM_TEMP    EQU RFM_OFFSET + 0x02
RFM_BUF_1   EQU RFM_OFFSET + 0x03
RFM_BUF_2   EQU RFM_OFFSET + 0x04
RFM_BUF_3   EQU RFM_OFFSET + 0x05
RFM_BUF_4   EQU RFM_OFFSET + 0x06
RFM_BUF_5   EQU RFM_OFFSET + 0x07

rfm70_fill_buffer_5 macro val1, val2, val3, val4, val5
    movlf   val1, RFM_BUF_1
    movlf   val2, RFM_BUF_2
    movlf   val3, RFM_BUF_3
    movlf   val4, RFM_BUF_4
    movlf   val5, RFM_BUF_5
    endm

rfm70_write_buffer_5:
    spi_writef RFM_REG
    spi_writef RFM_BUF_1
    spi_writef RFM_BUF_2
    spi_writef RFM_BUF_3
    spi_writef RFM_BUF_4
    spi_writef RFM_BUF_5
    return

rfm70_write_register:
    ; Register in RFM_REG, value in RFM_VAL
    banksel RFM_REG
    movf    RFM_REG, W
    iorlw   0x20                ; Write register
    call    spi_write
    movf    RFM_VAL, W
    call    spi_write
    return

rfm70_read_register_w:
    ; Register in W
    call    spi_write
    call    spi_read
    return

rfm70_init:
    delay   0x32
    ; Set registers 0-8
    movlf   0x09, RFM_REG
rfm70_init_1:
    decfsz  RFM_REG, F
    goto    rfm70_init_2
    movf    RFM_REG, W
    call    rfm70_init_table
    movwf   RFM_VAL
    call    rfm70_write_register
    goto    rfm70_init_1
rfm70_init_2:
    ; Set register 23
    movlf   0x17, RFM_REG
    clrf    RFM_VAL
    call    rfm70_write_register
    ; Set addresses
    rfm70_fill_buffer_5 0x02, 0x03, 0x04, 0x05, 0x06 ; Some address
    movlf   0x0a, RFM_REG           ; RX address pipe 2
    call    rfm70_write_buffer_5
    movlf   0x0b, RFM_REG           ; RX address pipe 1
    call    rfm70_write_buffer_5
    movlf   0x10, RFM_REG           ; TX address
    call    rfm70_write_buffer_5
    ; Extra features
    movlw   0x1d
    call    rfm70_read_register_w
    addlw   0x00
    btfsc   STATUS, Z
    goto    $+4
    movlf   0x50, RFM70_REG
    movlf   0x73, RFM70_VAL
    call    rfm70_write_register
    ; Dynamic payload
    movlf   0x12, RFM70_REG
    movlf   0x3f, RFM70_VAL
    call    rfm70_write_register
    movlf   0x13, RFM70_REG
    movlf   0x07, RFM70_REG
    call    rfm70_write_register
    return

rfm70_init_table:
    addwf   PCL
    retlw   0x0f            ; 0: receive, enabled, CRC2, enable interrupts
    retlw   0x3f            ; 1: auto-ack on all pipes enabled
    retlw   0x03            ; 2: enable pipes 0 and 1
    retlw   0x03            ; 3: 5 byte addresses
    retlw   0xff            ; 4: auto retransmission delay 4000ms, 15 times
    retlw   0x0a            ; 5: channel 10
    retlw   0x37            ; 6: data rate 1Mbit, power 5dbm, LNA gain high
    retlw   0x07            ; 7
    retlw   0x00            ; 8: clear Tx packet counters

;;; UTILITIES
    
DELAY_H     EQU DELAY_OFFSET + 0x00
DELAY_L     EQU DELAY_OFFSET + 0x01
    
_delay:
    movwf   DELAY_H
    movlw   0xff
    decfsz  DELAY_H, F
    goto    $+2
    return
    movwf   DELAY_L
    decfsz  DELAY_L, F
    goto    $-1
    goto    $-6
    
    END
