#define __SFR_OFFSET 0x00 
#include "avr/io.h" 
.global main 
 
main: 
    ; Set PD7 sebagai output untuk relay
    SBI DDRD, 7 
    ; Counter delay (25 x 0.2s = 5s)
    LDI R16, 25 

    ; Konfigurasi interrupt
    LDI R23, (1<<INT0) 
    OUT EIMSK, R23 
    LDI R23, (1<<ISC01) 
    STS EICRA, R23 
    SEI 

    ; Inisialisasi I2C dengan prescaler dan bit rate
    LDI   R21, 1<<TWPS0 
    STS   TWSR, R21     ; prescaler 4 (TWSR)
    LDI   R21, 12 
    STS   TWBR, R21 
    LDI   R21, (1<<TWEN) 
    STS   TWCR, R21 
    CLR   R18 
    CLR   R19 

    loop: 
        ; Delay 0.2s sebanyak 25 kali (R16)
        CPI R16, 1
        BRSH delay_timer_0_2s_hop
        balikdaridelay:
        
        ; Menyalakan relay ketika delay berakhir
        CPI R16, 0
        BREQ relaySwitch_hop
        
        DEC R16
        balikdariswitching:

        ; Instruksi I2C
        RCALL I2C_start 
        LDI   R27, 0b10010000 
        RCALL I2C_write 
        MOV   R27, R19 
        RCALL I2C_write 
        RCALL I2C_stop 
        SBI   DDRB, 1 
        CBI   PORTB, 1 
        RCALL delay_20ms 
        SBI   PORTB, 1 
        CBI   DDRB, 1 
    ; Pembacaan DHT11 
    w1: SBIC  PINB, 1 
        RJMP  w1 
    w2: SBIS  PINB, 1 
        RJMP  w2 
    w3: SBIC  PINB, 1 
        RJMP  w3 
        RCALL DHT11_reading 
        MOV   R19, R18 
        RCALL DHT11_reading 
        RCALL DHT11_reading 

        ; Menyalakan relay ketika humidity < 50%
        CPI R19, 0x32
        BRLO turnOn

        RJMP  loop 

; Perantara Break  
delay_timer_0_2s_hop:
  RJMP delay_timer_0_2s  
relaySwitch_hop:
  RJMP relaySwitch

I2C_start: 
  LDI   R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN) 
  STS   TWCR, R21 
  wt1: 
    LDS   R21, TWCR 
    SBRS  R21, TWINT 
    RJMP  wt1 
  RET 
 
I2C_write: 
  STS   TWDR, R27 
  LDI   R21, (1<<TWINT)|(1<<TWEN) 
  STS   TWCR, R21 
  wt2: 
    LDS   R21, TWCR 
    SBRS  R21, TWINT 
    RJMP  wt2 
  RET 

I2C_stop: 
  LDI   R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN) 
  STS   TWCR, R21 
  RET 
 
DHT11_reading: 
    LDI   R17, 8 
    CLR   R18 
w4: SBIS  PINB, 1 
    RJMP  w4 
    RCALL delay_timer0 
    SBIS  PINB, 1 
    RJMP  skp 
    SEC 
    ROL   R18 
    RJMP  w5 
skp:LSL   R18            
w5: SBIC  PINB, 1 
    RJMP  w5 
    DEC   R17 
    BRNE  w4 
    RET 
 
delay_20ms: 
    LDI   R21, 255 
    l1_20ms:  
      LDI   R22, 210 
      l2_20ms:  
        LDI   R23, 2 
        l3_20ms:  
          DEC   R23 
          BRNE  l3_20ms 
          DEC   R22 
          BRNE  l2_20ms 
          DEC   R21 
          BRNE  l1_20ms 
    RET 
 
relaySwitch:
  ; Reset Counter Delay
  LDI R16, 25 

  ; Cek kondisi sinyal relay (current state)
  IN R24, PORTD 
  ANDI  R24, 0x80
  CPI   R24, 0x80
  BRNE turnOn

  ; mematikkan relay
  LDI R20, 0x0
  OUT PORTD, R20 
  RJMP balikdariswitching

  ; menyalakan relay
  turnOn:
    LDI R20, 0x80
    OUT PORTD, R20 

  RJMP balikdariswitching

; Generator delay 0.2s
delay_timer_0_2s: 
  .EQU value, 62410  
  LDI R20, hi8(value) 
  STS TCNT1H, R20 
  LDI R20, lo8(value)

  STS TCNT1L, R20  
  LDI R20, 0b00000000 
  STS TCCR1A, R20 
  LDI R20, 0b00000101 
  STS TCCR1B, R20 
  l3: 
    IN R20, TIFR1  
    SBRS R20, TOV1  
    RJMP l3  
    LDI R20, 1<<TOV1  
    OUT TIFR1, R20  
    LDI R20, 0b00000000  
    STS TCCR1B, R20  
    RJMP balikdaridelay 
 
; setup delay dengan timer0
delay_timer0: 
  CLR   R20 
  OUT   TCNT0, R20 
  LDI   R20, 100 
  OUT   OCR0A, R20 
  LDI   R20, 0b00001010 
  OUT   TCCR0B, R20 
cTimer0:  
  IN    R20, TIFR0 
  SBRS  R20, OCF0A 
  RJMP  cTimer0 
  CLR   R20 
  OUT   TCCR0B, R20 

  LDI   R20, (1<<OCF0A) 
  OUT   TIFR0, R20 
  RET 
