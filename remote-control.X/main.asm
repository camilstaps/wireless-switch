    include <p12lf1840.inc>

    __CONFIG _CONFIG1, _CLKOUTEN_OFF & _FCMEN_ON & _MCLRE_ON & _WDTE_OFF & _CPD_OFF & _FOSC_INTOSC & _BOREN_ON & _IESO_ON & _PWRTE_ON & _CP_OFF
    __CONFIG _CONFIG2, _PLLEN_OFF & _LVP_OFF & _WRT_ALL & _STVREN_ON & _BORV_LO
    
SPI_PIN_SDO EQU 0x00
SPI_PIN_SCK EQU 0x01
SPI_PIN_SDI EQU 0x02
SPI_PIN_CS  EQU 0x04
  
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
    bsf        LATA, SPI_PIN_CS
    endm
    
spi_disable macro
    banksel LATA
    bcf        LATA, SPI_PIN_CS
    endm
    
spi_init macro
    banksel TRISA
    bcf        TRISA, SPI_PIN_SDO ; Ports
    bcf        TRISA, SPI_PIN_SCK
    bsf        TRISA, SPI_PIN_SDI
    bcf        TRISA, SPI_PIN_CS
    banksel    SSP1STAT
    clrf       SSP1STAT           ; When to sample / transmit
    clrf       SSP1CON1           ; SPI master mode, Fosc / 4, clock low when idle
    bsf        SSP1CON1, SSPEN    ; Enable SPI
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
    call    delay
    goto    main
    
;;; SPI
  
SPI_TEMP    EQU 0x40

spi_write:
    banksel SPI_TEMP
    movwf   SPI_TEMP              ; Store argument
    banksel SSP1BUF               ; Clear buffer
    movf    SSP1BUF, W
    spi_enable
    bcf     SSP1CON1, WCOL        ; Clear collision detection bit
    movff   SPI_TEMP, SSP1BUF     ; Move data to buffer
    btfsc   SSP1CON1, WCOL        ; Continue until success
    goto    $-3
    spi_disable
    return
    
;;; RFM70
    
rfm70_init:
    delay   0x32
    return

;;; UTILITIES
    
DELAY_H     EQU 0x20
DELAY_L     EQU 0x21
    
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