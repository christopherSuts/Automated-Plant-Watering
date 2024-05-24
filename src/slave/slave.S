#define __SFR_OFFSET 0x00 
#include "avr/io.h" 
.global main 
 
main: 
  ; Setup register UDR
  CLR R24 
  STS UCSR0A, R24 
  STS UBRR0H, R24
  ; baudrate 9600, 103 = [16MHz / (16*9600)] - 1 
  LDI R24, 103 
  STS UBRR0L, R24 
  LDI R24, 1<<RXEN0 | 1<<TXEN0  
  STS UCSR0B, R24 
  LDI R24, 1<<UCSZ00 | 1<<UCSZ01 
  STS UCSR0C, R24 
 
LCD_write:
  ; konstanta untuk konversi ASCII
  LDI   R23, 48      
  LDI   R24, 7        ;chars 0-->9 & A-->F

  ; setup LCD
  LDI   R16, 0xFF
  OUT   DDRD, R16     ;set port D o/p untuk data
  OUT   DDRB, R16     ;set port B o/p untuk command
  CBI   PORTB, 0      ;EN = 0
  RCALL delay_ms      ;delay untuk menunggu LCD menyala

  RCALL LCD_init     

  RCALL disp_msg     

  LDI   R16, 0xC0     ;set cursor ke baris 2
  RCALL command_wrt
  RCALL delay_ms

  LDI   R19, 48       ;konstanta konversi ASCII
  RJMP  mainloop      ;display ADC 8-bit value pada LCD

LCD_buffer: 
  LDS R27, UCSR0A 
  SBRS R27, UDRE0 
  RJMP LCD_buffer 
  RET 
 
ASCII_MSD: 
  MOV R23, R16 
  ANDI R16, 0xF0 
  SWAP R16 
  SUBI R16, -48 
  MOV R28, R16 
  SUBI R28, 58 
  BRPL A_F_D1 
  l1: 
    RET  
A_F_D1: 
  SUBI R16, -7 
  RJMP l1 
 
ASCII_LSD: 
  MOV R16, R23 
  ANDI R16, 0x0F 
  SUBI R16, -48 
  MOV R28, R16 
  SUBI R28, 58 
  BRPL A_F_D0 
  l2: 
    RET 
A_F_D0: 
  SUBI R16, -7 
  RJMP l2 
 
printval: 
  MOV R16, R29 

  RCALL ASCII_MSD 
  RCALL LCD_buffer 
  STS UDR0, R16 
    
  RCALL ASCII_LSD 
  RCALL LCD_buffer 
  STS UDR0, R16 
  RCALL LCD_buffer 
  LDI R16, 0x0A 
  STS UDR0, R16 
    
  RCALL LCD_buffer 
  LDI R16, 0x0D 
  STS UDR0, R16 
  RET 

LCD_init:
  LDI   R16, 0x33     ;init LCD untuk data 4-bit 
  RCALL command_wrt   ;mengirim command ke register
  RCALL delay_ms
  LDI   R16, 0x32     ;init LCD untuk data 4-bit 
  RCALL command_wrt
  RCALL delay_ms
  LDI   R16, 0x28     ;LCD 2 lines, 5x7 matrix
  RCALL command_wrt
  RCALL delay_ms
  LDI   R16, 0x0C     ;disp ON, cursor OFF
  RCALL command_wrt
  LDI   R16, 0x01     ;clear LCD
  RCALL command_wrt
  RCALL delay_ms
  LDI   R16, 0x06     ;shift cursor right
  RCALL command_wrt
  RET  

command_wrt:
    MOV   R27, R16
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    CBI   PORTB, 1      ;RS = 0 for command
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us

    MOV   R27, R16
    SWAP  R27           ;swap nibbles
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    RET

data_wrt:
    MOV   R27, R16
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 1      ;RS = 1 for data
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;make wide EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us

    MOV   R27, R16
    SWAP  R27           ;swap nibbles
    ANDI  R27, 0xF0     ;mask low nibble & keep high nibble
    OUT   PORTD, R27    ;o/p high nibble to port D
    SBI   PORTB, 0      ;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI   PORTB, 0      ;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay in micro seconds
    RET

delay_short:            ;very short delay, 3 cycles
  NOP
  NOP
  RET

delay_us:               ;delay 100us
  LDI   R20, 90
l1_delay_us: RCALL delay_short
  DEC   R20
  BRNE  l1_delay_us
  RET

delay_ms:               ;delay 20ms
    LDI   R21, 40
l2_delay_ms: RCALL delay_us
    DEC   R21
    BRNE  l2_delay_ms
    RET

delay_sec:              ;nested loop subroutine (max delay 3.11s)
    LDI   R20, 255      ;outer loop counter 
l3: LDI   R21, 255      ;mid loop counter
l4: LDI   R22, 40       ;inner loop counter to give 0.5s delay
l5: DEC   R22           ;decrement inner loop
    BRNE  l5            ;loop if not zero
    DEC   R21           ;decrement mid loop
    BRNE  l4            ;loop if not zero
    DEC   R20           ;decrement outer loop
    BRNE  l3            ;loop if not zero
    RET                 ;return to caller

disp_msg:
    LDI   R31, hi8(msg)
    LDI   R30, lo8(msg) ;Z points to string msg
l6: LPM   R16, Z+       ;load character of msg into R16
    CPI   R16, 0        ;check if R16=0 (end of string)
    BREQ  ext           ;if yes, exit
    RCALL data_wrt      ;if no, display character on LCD
    RJMP  l6            ;loop back & get next character
ext:RET
msg: .ascii "Humidity Level :" 

mainloop: 
  ; konfigurasi I2C
  RCALL I2C_init 
  RCALL I2C_listen 
  RCALL I2C_read 

  ; print data humidity hex pada serial monitor
  RCALL printval 

  CLR   R25           ;set counter1, initial value 0
  CLR   R23           ;set counter2, initial value 0
  MOV R16, R29

  ; Konversi nilai hex menjadi decimal
  l7: CPI   R16, 100      ;compare R16 with 100
  Ret:BRMI  l8            ;jump when R16 < 100
      INC   R25           ;increment counter1 by 1
      SUBI  R16, 100      ;R16 = R16 - 100
      RJMP  l7

  l8: CPI   R16, 10       ;compare R16 with 10
      BRMI  dsp           ;jump when R16 < 10
      INC   R23           ;increment counter2 by 1
      SUBI  R16, 10       ;R16 = R16 - 10
      RJMP  l8

  dsp:PUSH  R16           ;save a copy of R16 in STACK
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt  
      RCALL data_wrt   

      MOV   R16, R23      ;mid digit in ASCII dec
      ADD   R16, R19
      RCALL data_wrt      ;display mid digit on LCD

      POP   R16           ;get back from STACK stored copy of R16
      ADD   R16, R19      ;LSD in ASCII dec
      RCALL data_wrt      ;display LSD on LCD
      LDI R27, 0

      RCALL delay_sec     ;delay 0.5s

      LDI   R16, 0xC0     ;posisikan kursor pada baris 2
      RCALL command_wrt
      RCALL delay_ms
      RJMP  mainloop 
 
I2C_init: 
  LDI   R21, 0b10010000 
  STS   TWAR, R21 
  LDI   R21, (1<<TWEN) 
  STS   TWCR, R21 
  LDI   R21, (1<<TWINT)|(1<<TWEN)|(1<<TWEA) 
  STS   TWCR, R21 
  RET 
 
I2C_listen: 
  LDS   R21, TWCR 
  SBRS  R21, TWINT 
  RJMP  I2C_listen 
  RET 
 
I2C_read: 
  LDI   R21, (1<<TWINT)|(1<<TWEA)|(1<<TWEN) 
  STS   TWCR, R21 
wt: LDS   R21, TWCR 
  SBRS  R21, TWINT 
  RJMP  wt 
  LDS   R29, TWDR 
  RET 
