; ��������������� ���������
    #include p16f873a.inc
    __CONFIG _HS_OSC & _WDT_OFF            ;
    ORG H'000'                  ;������ ������
CNT EQU H'7F'                   ;����������� �������� ��������
                                ;� ������� H'7F' (���� 0)
CNTSUMM EQU H'7E'               ;����������� �������� �������� 
                                ;� ������� H'7E' (���� 0)  
REPEATER EQU H'7D'  
TEMP EQU H'7C'                
; ������ ������������ 2-10 ����� � ���
     BCF STATUS,RP1             ; T �������� ���� ��������� 0
     BCF STATUS,RP0             ; -

     MOVLW H'20'                ;�������� � ������� ������� ������
                                ;������� ��� � ����� 0
     MOVWF FSR                  ;���������� ��������� �����
                                ;� ������� ����. ���������
     CLRF CNT                   ;�������� ������� �������
M10: MOVF CNT,W                 ;��������� �������� �������� � ������� �������
     MOVWF INDF                 ;��������� ��������� ������ � �������� ����������
POH
     INCF FSR,F                 ;���������� ������ ���
                                ;� �������� ��������� ���������
     INCF CNT,F                 ;���������� �������� �� 1
     MOVF CNT,W 
 M2:
     ANDLW H'0F'                ; �������� � � 0F
     XORLW H'0A'                ; ��������� � 0A
     BTFSS STATUS,Z             ; ���� �� ���������, ������ ����� �������
     GOTO M10                   ; ����� ������������ �2
     MOVF CNT,W                 ; ��������� ������� �
     ADDLW H'6'
     MOVWF CNT                  ;��������� ����� �������� �������
     MOVF CNT,W                 ;� ������� �������
     XORLW H'90'                ;���������� ��� � ��������� ��������� +1
     BTFSS STATUS,Z             ;���� ���������, �� ������ ����� ���� �������
     GOTO M10                   ;���� �� ���������, �� �������
    
;������������ � ������ 3 ������ ���� ���������� �����
     MOVLW H'0'                  ;�������� ���������� �������� � ������� �������
     MOVWF CNTSUMM
     MOVLW H'1F'                 ;�������� ���������� �������� � ������� �������
     MOVWF CNT 
                     
M3:
     INCF CNT,F
     INCF CNTSUMM,F              ;���������� �������� �� 1
     MOVF CNTSUMM,W              ;������� �������� � ������� �������
     XORLW H'3'                  ;��������� � 3
     BTFSS STATUS,Z              ;���� �� ���������, ������ ����� �������
     GOTO M3                     ;����� ������������ �3
     CLRF CNTSUMM                ;�������� ������� �������
                                 ;��������� �������� �������� � ������� �������
     MOVF CNT,W                  ;�
     MOVWF FSR                   ;�������� �������� � �������� ����������
     DECF FSR,F
     DECF FSR,F                  ;�������� ����� � ������� �������
     MOVF INDF,W
     MOVWF REPEATER
     INCF REPEATER
     INCF FSR,F
MSUM:
     ADDLW H'01'
     MOVWF TEMP
     MOVF TEMP,W
     ANDLW H'F0'
     XORLW H'A0'
     BTFSC STATUS,Z
     GOTO CLRTEMP
CLRTEMPCONT:
     MOVF TEMP,W
     ANDLW H'0F'
     XORLW H'0A'
     BTFSC STATUS,Z
     GOTO ADD6
ADD6CONT:
     DECF REPEATER,F
     MOVF REPEATER,W
     ANDLW H'0F'
     XORLW H'0F'
     BTFSC STATUS,Z
     GOTO MINUS6
MINUS6CONT:
     MOVF TEMP,W
     INCF REPEATER,F
     DECFSZ REPEATER,F
     GOTO MSUM

     ;ADDWF INDF,W                ;�
     INCF FSR,F
     MOVWF INDF
     MOVF CNT,W                   ;� ������� �������
     XORLW H'79'                  ;���������� ��� � ��������� ��������� +1
     BTFSS STATUS,Z 
     GOTO M3                      ;����� ������������ �3
     GOTO  WROTE_EEPROM

; �������������� ��������
ADD6:
    MOVLW H'06'
    ADDWF TEMP
    GOTO ADD6CONT

MINUS6:
    MOVLW H'06'
    SUBWF REPEATER,F
    GOTO MINUS6CONT

CLRTEMP:
    MOVLW H'01'
    MOVWF TEMP
    GOTO CLRTEMPCONT


WROTE_EEPROM:
;����������� �� ��� � EEPROM
     MOVLW H'79'              ;�������� � ������� �������
                              ;������ ������� ��� � ����� 0
     MOVWF FSR                ;���������� ��������� �����
                              ;� ������� ����. ���������
     CLRF CNT                 ;�������� ������� ������� ������ EEPROM
M20: BSF STATUS,RP1 ; T �������� ���� ��������� 3
     BSF STATUS,RP0 ; -
     BTFSC EECON1,WR ; T �������� ��������� ����������
                     ; � ������ � EEPROM
     GOTO  M20       ; -
     BCF  STATUS,RP1 ; T �������� ���� ��������� 1
     BSF  STATUS,RP0 ; -
     MOVF CNT,W      ;��������� �������� �������� � ������� �������
     BSF STATUS,RP1  ; T �������� ���� ��������� 2
     BCF  STATUS,RP0 ; -
     MOVWF EEADR     ;��������� ����� ��������� ������ � �������� ������
     MOVF INDF,W     ;��������� ������ �� ���������� ���
                     ;� ������� �������
     MOVWF EEDATA    ;� ��������� �� � �������� ������ EEPROM
     BSF   STATUS,RP1 ; T �������� ���� ��������� 3
     BSF   STATUS,RP0 ; -
     BCF   EECON1,EEPGD ;�������� EEPROM
     BSF   EECON1,WREN  ;��������� ������
     BCF   INTCON,GIE   ;��������� ����������
     MOVLW H'55'        ; �
     MOVWF EECON2       ; �
     MOVLW H'AA'        ; + ������������ ������������������ �� ���� ������
     MOVWF EECON2       ; �
     BSF   EECON1,WR    ; -
     BCF   EECON1,WREN  ;��������� ������
     BCF   STATUS,RP1 ; T �������� ���� ��������� 1
     BSF   STATUS,RP0 ; -
     DECF  FSR,F      ;���������� ������ ���
                      ;� �������� ��������� ���������
     DECF  FSR,F
     DECF  FSR,F
     INCF  CNT,F      ;���������� �������� �� 1
     MOVF  CNT,W      ;��������� ����� �������� ��������
                      ;� ������� �������
     XORLW H'20'      ;���������� ��� � ��������� ��������� +1
     BTFSS STATUS,Z   ;���� ��������� �� ������ ����� ���� �������
     GOTO  M20        ;���� ���, �� ������� � �����������
                      ;��������� ������

M30  GOTO  M30                    ;������������� �����
     END                         ;����� ���������
