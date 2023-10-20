; предварительные настройки
    #include p16f873a.inc
    __CONFIG _HS_OSC & _WDT_OFF
    ORG H'000'                ;вектор сброса
CNT        EQU H'FF'          ;определение регистра счетчика с адресом FF (банк 1)
DATA_CNT   EQU H'FE'
TEMP_DATA  EQU H'FD'
DATA_CNT0  EQU H'7D'
TEMP_DATA0 EQU H'7F'

CLRF CNT
CLRF TEMP_DATA
MOVLW H'FF'
MOVWF DATA_CNT

; сначала eeprom, потом только перенос в POH (с 99, без учета букв, только десятичные числа)
M20: BSF    STATUS,RP1    ;выбираем банк регистров 3
     BSF    STATUS,RP0    
     BTFSC  EECON1,WR     ;проверка окончания предыдущей
                          ;записи в EEPROM
     GOTO   M20           

     BCF    STATUS,RP1    ;выбираем банк регистров 1
     BSF    STATUS,RP0    
     MOVF   CNT,W         ;загружаем значение счетчика в рабочий регистр

     BSF    STATUS,RP1    ;выбираем банк регистров 2
     BCF    STATUS,RP0    
     MOVWF  EEADR         ;сохраняем адрес очередной ячейки в регистре адреса
     MOVF   DATA_CNT,W    ;считываем данные из счетчика переменных
     DECF   DATA_CNT,F
     MOVWF  EEDATA        ;и сохраняем его в регистре данных EEPROM

     BSF    STATUS,RP1    ;выбираем банк регистров 3
     BSF    STATUS,RP0    
     BCF    EECON1,EEPGD  ;выбираем EEPROM
     BSF    EECON1,WREN   ;разрешаем запись
     BCF    INTCON,GIE    ;запрещаем прерывания

     MOVLW  H'55'         ; ¬
     MOVWF  EECON2        ; ¦
     MOVLW  H'AA'         ; + обязательная последовательность из пяти команд
     MOVWF  EECON2        ; ¦
     BSF    EECON1,WR     ; -

     BCF    EECON1,WREN   ;запрещаем запись
     BCF    STATUS,RP1    ;выбираем банк регистров 1
     BSF    STATUS,RP0    
     INCF   FSR,F         ;увеличение адреса РОН
                          ;в регистре косвенной адресации
     INCF   CNT,F         ;увеличение счетчика на 1
     MOVF   CNT,W         ;загружаем новое значение счетчика
                          ;в рабочий регистр
     XORLW  H'80'         ;сравниваем его с последним значением +1
     BTFSS  STATUS,Z      ;если совпадают то скачек через одну команду
     GOTO   M20           ;если нет, то переход к копированию
                          ;очередной ячейки



; переносим 1 часть данных из eeprom в банк 1 (такие же данные будут в банке 3)
     BSF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'A0'
     CLRF   DATA_CNT
     MOVWF  DATA_CNT     ; используем DATA_CNT как указатель адресов банка 1, в которые нужно записывать данные
     
     MOVLW  H'66'
     CLRF   CNT
     MOVWF  CNT          ; используем CNT как указатель адресов EEPROM

     BCF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'20'
     MOVWF  DATA_CNT0    ; используем DATA_CNT0 как указатель адресов банка 0, в которые нужно записывать данные

EEPROMREAD_1:
     BSF    STATUS,RP0   ; выбор банка 1, в котором хранятся счетчики
     BCF    STATUS,RP1
     MOVF   CNT,W        ; Записать адрес ячейки в раб. региистр

     BSF    STATUS,RP1   ; Выбрать банк 2
     BCF    STATUS,RP0   ; 
     MOVWF  EEADR        ; перенос адреса ячейки eeprom в соответствующий регистр
     
     BSF    STATUS,RP1   ; Выбрать банк 3
     BSF    STATUS,RP0   
     BCF    EECON1,EEPGD ; Выбрать EEPROM память
     BSF    EECON1,RD    ; Инициализировать чтение
     
     BSF    STATUS,RP1
     BCF    STATUS,RP0   ; Выбрать банк 2
     MOVF   EEDATA,W     ; Сохраняем EEDATA в рабочем регистре
     
     BSF    STATUS, RP0  ; выбираем банк 1
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA    ; переносим значение из рабочего регистра в регистр TEMP_DATA
     
     MOVF   DATA_CNT,W
     MOVWF  FSR          ; переносим отсчет для адресации в регистр косвенной адресации
     
     MOVF   TEMP_DATA,W
     MOVWF  INDF         ; переносим данные из TEMP_DATA в регистр, заданный в FSR

     MOVF   TEMP_DATA, W ; переносим число в рабочий регистр
     BCF    STATUS, RP0  ; переходим в банк 0
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA0   ; помещаем число во временный регистр
     MOVF   DATA_CNT0,W  ; помещаем адрес регистра в рабочий регистр
     MOVWF  FSR          ; переносим отсчет для адресации в регистр косвенной адресации
     MOVF   TEMP_DATA0,W
     MOVWF  INDF         ; переносим данные из TEMP_DATA0 в регистр, заданный в FSR
     INCF   DATA_CNT0,F
     
     BSF    STATUS, RP0  ; выбираем банк 1
     BCF    STATUS, RP1
     INCF   DATA_CNT,F   ; увеличиваем значение счетчика адресов РОН
     INCF   CNT,F        ; увеличиваем значение счетчика адресов EEPROM
     XORLW  H'90'        ;сравниваем его с последним значением +1
     BTFSS  STATUS,Z     ;если совпадают, то скачек через одну команду
     GOTO   EEPROMREAD_1



; переносим 2 часть данных из eeprom в банк 1 (такие же данные будут в банке 3)
     BSF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'AA'
     CLRF   DATA_CNT
     MOVWF  DATA_CNT     ; используем DATA_CNT как указатель адресов банка 1, в которые нужно записывать данные (AA)
     
     MOVLW  H'76'
     CLRF   CNT
     MOVWF  CNT          ;используем CNT как указатель адресов EEPROM (76)

     BCF    STATUS, RP0
     BCF    STATUS, RP1
     MOVLW  H'2A'
     MOVWF  DATA_CNT0    ; используем DATA_CNT0 как указатель адресов банка 0, в которые нужно записывать данные

EEPROMREAD_2:
     BSF    STATUS,RP0   ; выбор банка 1, в котором хранятся счетчики
     BCF    STATUS,RP1
     MOVF   CNT,W        ; Записать адрес ячейки в раб. региистр

     BSF    STATUS,RP1   ; Выбрать банк 2
     BCF    STATUS,RP0   ; 
     MOVWF  EEADR        ; перенос адреса ячейки eeprom в соответствующий регистр
     
     BSF    STATUS,RP1   ; Выбрать банк 3
     BSF    STATUS,RP0   
     BCF    EECON1,EEPGD ; Выбрать EEPROM память
     BSF    EECON1,RD    ; Инициализировать чтение
     
     BSF    STATUS,RP1
     BCF    STATUS,RP0   ; Выбрать банк 2
     MOVF   EEDATA,W     ; Сохраняем EEDATA в рабочем регистре
     
     BSF    STATUS, RP0  ; выбираем банк 1
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA    ; переносим значение из рабочего регистра в регистр TEMP_DATA
     
     MOVF   DATA_CNT,W
     MOVWF  FSR          ; переносим отсчет для адресации в регистр косвенной адресации
     
     MOVF   TEMP_DATA,W
     MOVWF  INDF         ; переносим данные из TEMP_DATA в регистр, заданный в FSR


     MOVF   TEMP_DATA, W ; переносим число в рабочий регистр
     BCF    STATUS, RP0  ; переходим в банк 0
     BCF    STATUS, RP1
     MOVWF  TEMP_DATA0   ; помещаем число во временный регистр
     MOVF   DATA_CNT0,W  ; помещаем адрес регистра в рабочий регистр
     MOVWF  FSR          ; переносим отсчет для адресации в регистр косвенной адресации
     MOVF   TEMP_DATA0,W
     MOVWF  INDF         ; переносим данные из TEMP_DATA0 в регистр, заданный в FSR
     INCF   DATA_CNT0,F
     
     BSF    STATUS, RP0  ; выбираем банк 1
     BCF    STATUS, RP1
     INCF   DATA_CNT,F   ; увеличиваем значение счетчика адресов РОН
     INCF   CNT,F        ; увеличиваем значение счетчика адресов EEPROM

     MOVF   CNT,W        ; Записать адрес ячейки в раб. региистр
     XORLW  H'7F'        ;сравниваем его с последним значением +1
     BTFSS  STATUS,Z     ;если совпадают, то скачек через одну команду
     GOTO   EEPROMREAD_2

M30  GOTO    M30          ;зацикливаемся здесь
     END                  ;конец программы
