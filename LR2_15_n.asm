; ��������������� ���������
    #include p16f873a.inc
    __CONFIG _HS_OSC & _WDT_OFF
    ORG H'000'                ;������ ������
CNT        EQU H'FF'          ;����������� �������� �������� � ������� FF (���� 1)
DATA_CNT   EQU H'FE'
TEMP_DATA  EQU H'FD'
DATA_CNT0  EQU H'7D'
TEMP_DATA0 EQU H'7F'

CLRF CNT
CLRF TEMP_DATA
MOVLW H'FF'
MOVWF DATA_CNT

; ������� eeprom, ����� ������ ������� � POH (� 99, ��� ����� ����, ������ ���������� �����)
M20: BSF    STATUS,RP1    ;�������� ���� ��������� 3
     BSF    STATUS,RP0    
     BTFSC  EECON1,WR     ;�������� ��������� ����������
                          ;������ � EEPROM
     GOTO   M20           

     BCF    STATUS,RP1    ;�������� ���� ��������� 1
     BSF    STATUS,RP0    
     MOVF   CNT,W         ;��������� �������� �������� � ������� �������

     BSF    STATUS,RP1    ;�������� ���� ��������� 2
     BCF    STATUS,RP0    
     MOVWF  EEADR         ;��������� ����� ��������� ������ � �������� ������
     MOVF   DATA_CNT,W    ;��������� ������ �� �������� ����������
     DECF   DATA_CNT,F
     MOVWF  EEDATA        ;� ��������� ��� � �������� ������ EEPROM

     BSF    STATUS,RP1    ;�������� ���� ��������� 3
     BSF    STATUS,RP0    
     BCF    EECON1,EEPGD  ;�������� EEPROM
     BSF    EECON1,WREN   ;��������� ������
     BCF    INTCON,GIE    ;��������� ����������

     MOVLW  H'55'         ; �
     MOVWF  EECON2        ; �
     MOVLW  H'AA'         ; + ������������ ������������������ �� ���� ������
     MOVWF  EECON2        ; �
     BSF    EECON1,WR     ; -

     BCF    EECON1,WREN   ;��������� ������
     BCF    STATUS,RP1    ;�������� ���� ��������� 1
     BSF    STATUS,RP0    
     INCF   FSR,F         ;���������� ������ ���
                          ;� �������� ��������� ���������
     INCF   CNT,F         ;���������� �������� �� 1
     MOVF   CNT,W         ;��������� ����� �������� ��������
                          ;� ������� �������
     XORLW  H'80'         ;���������� ��� � ��������� ��������� +1
     BTFSS  STATUS,Z      ;���� ��������� �� ������ ����� ���� �������
     GOTO   M20           ;���� ���, �� ������� � �����������
                          ;��������� ������



; ��������� 1 ����� ������ �� eeprom � ���� 1 (����� �� ������ ����� � ����� 3)
     BSF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'A0'
     CLRF   DATA_CNT
     MOVWF  DATA_CNT     ; ���������� DATA_CNT ��� ��������� ������� ����� 1, � ������� ����� ���������� ������
     
     MOVLW  H'66'
     CLRF   CNT
     MOVWF  CNT          ; ���������� CNT ��� ��������� ������� EEPROM

     BCF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'20'
     MOVWF  DATA_CNT0    ; ���������� DATA_CNT0 ��� ��������� ������� ����� 0, � ������� ����� ���������� ������

EEPROMREAD_1:
     BSF    STATUS,RP0   ; ����� ����� 1, � ������� �������� ��������
     BCF    STATUS,RP1
     MOVF   CNT,W        ; �������� ����� ������ � ���. ��������

     BSF    STATUS,RP1   ; ������� ���� 2
     BCF    STATUS,RP0   ; 
     MOVWF  EEADR        ; ������� ������ ������ eeprom � ��������������� �������
     
     BSF    STATUS,RP1   ; ������� ���� 3
     BSF    STATUS,RP0   
     BCF    EECON1,EEPGD ; ������� EEPROM ������
     BSF    EECON1,RD    ; ���������������� ������
     
     BSF    STATUS,RP1
     BCF    STATUS,RP0   ; ������� ���� 2
     MOVF   EEDATA,W     ; ��������� EEDATA � ������� ��������
     
     BSF    STATUS, RP0  ; �������� ���� 1
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA    ; ��������� �������� �� �������� �������� � ������� TEMP_DATA
     
     MOVF   DATA_CNT,W
     MOVWF  FSR          ; ��������� ������ ��� ��������� � ������� ��������� ���������
     
     MOVF   TEMP_DATA,W
     MOVWF  INDF         ; ��������� ������ �� TEMP_DATA � �������, �������� � FSR

     MOVF   TEMP_DATA, W ; ��������� ����� � ������� �������
     BCF    STATUS, RP0  ; ��������� � ���� 0
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA0   ; �������� ����� �� ��������� �������
     MOVF   DATA_CNT0,W  ; �������� ����� �������� � ������� �������
     MOVWF  FSR          ; ��������� ������ ��� ��������� � ������� ��������� ���������
     MOVF   TEMP_DATA0,W
     MOVWF  INDF         ; ��������� ������ �� TEMP_DATA0 � �������, �������� � FSR
     INCF   DATA_CNT0,F
     
     BSF    STATUS, RP0  ; �������� ���� 1
     BCF    STATUS, RP1
     INCF   DATA_CNT,F   ; ����������� �������� �������� ������� ���
     INCF   CNT,F        ; ����������� �������� �������� ������� EEPROM
     XORLW  H'90'        ;���������� ��� � ��������� ��������� +1
     BTFSS  STATUS,Z     ;���� ���������, �� ������ ����� ���� �������
     GOTO   EEPROMREAD_1



; ��������� 2 ����� ������ �� eeprom � ���� 1 (����� �� ������ ����� � ����� 3)
     BSF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'AA'
     CLRF   DATA_CNT
     MOVWF  DATA_CNT     ; ���������� DATA_CNT ��� ��������� ������� ����� 1, � ������� ����� ���������� ������ (AA)
     
     MOVLW  H'76'
     CLRF   CNT
     MOVWF  CNT          ;���������� CNT ��� ��������� ������� EEPROM (76)

     BCF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'2A'
     MOVWF  DATA_CNT0    ; ���������� DATA_CNT0 ��� ��������� ������� ����� 0, � ������� ����� ���������� ������

EEPROMREAD_2:
     BSF    STATUS,RP0   ; ����� ����� 1, � ������� �������� ��������
     BCF    STATUS,RP1
     MOVF   CNT,W        ; �������� ����� ������ � ���. ��������

     BSF    STATUS,RP1   ; ������� ���� 2
     BCF    STATUS,RP0   ; 
     MOVWF  EEADR        ; ������� ������ ������ eeprom � ��������������� �������
     
     BSF    STATUS,RP1   ; ������� ���� 3
     BSF    STATUS,RP0   
     BCF    EECON1,EEPGD ; ������� EEPROM ������
     BSF    EECON1,RD    ; ���������������� ������
     
     BSF    STATUS,RP1
     BCF    STATUS,RP0   ; ������� ���� 2
     MOVF   EEDATA,W     ; ��������� EEDATA � ������� ��������
     
     BSF    STATUS, RP0  ; �������� ���� 1
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA    ; ��������� �������� �� �������� �������� � ������� TEMP_DATA
     
     MOVF   DATA_CNT,W
     MOVWF  FSR          ; ��������� ������ ��� ��������� � ������� ��������� ���������
     
     MOVF   TEMP_DATA,W
     MOVWF  INDF         ; ��������� ������ �� TEMP_DATA � �������, �������� � FSR


     MOVF   TEMP_DATA, W ; ��������� ����� � ������� �������
     BCF    STATUS, RP0  ; ��������� � ���� 0
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA0   ; �������� ����� �� ��������� �������
     MOVF   DATA_CNT0,W  ; �������� ����� �������� � ������� �������
     MOVWF  FSR          ; ��������� ������ ��� ��������� � ������� ��������� ���������
     MOVF   TEMP_DATA0,W
     MOVWF  INDF         ; ��������� ������ �� TEMP_DATA0 � �������, �������� � FSR
     INCF   DATA_CNT0,F
     
     BSF    STATUS, RP0  ; �������� ���� 1
     BCF    STATUS, RP1
     INCF   DATA_CNT,F   ; ����������� �������� �������� ������� ���
     INCF   CNT,F        ; ����������� �������� �������� ������� EEPROM

     MOVF   CNT,W        ; �������� ����� ������ � ���. ��������
     XORLW  H'7F'        ;���������� ��� � ��������� ��������� +1
     BTFSS  STATUS,Z     ;���� ���������, �� ������ ����� ���� �������
     GOTO   EEPROMREAD_2

M30  GOTO    M30          ;������������� �����
     END                  ;����� ���������
