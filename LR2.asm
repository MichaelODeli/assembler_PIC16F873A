; предварительные настройки
    #include p16f873a.inc
    __CONFIG _HS_OSC & _WDT_OFF            ;
    ORG H'000'                  ;вектор сброса
CNT EQU H'7F'                   ;определение регистра счетчика
                                ;с адресом H'7F' (банк 0)
CNTSUMM EQU H'7E'               ;определение регистра счётчика 
                                ;с адресом H'7E' (банк 0)  
REPEATER EQU H'7D'  
TEMP EQU H'7C'                
; запись возрастающих 2-10 чисел в ОЗУ
     BCF STATUS,RP1             ; T выбираем банк регистров 0
     BCF STATUS,RP0             ; -

     MOVLW H'20'                ;загрузка в рабочий регистр адреса
                                ;первого РОН в банке 0
     MOVWF FSR                  ;записываем начальный адрес
                                ;в регистр косв. адресации
     CLRF CNT                   ;обнуляем регистр счетчик
M10: MOVF CNT,W                 ;загружаем значение счетчика в рабочий регистр
     MOVWF INDF                 ;сохраняем очередной отсчет в косвенно адресуемый
POH
     INCF FSR,F                 ;увеличение адреса РОН
                                ;в регистре косвенной адресации
     INCF CNT,F                 ;увеличение счетчика на 1
     MOVF CNT,W 
 M2:
     ANDLW H'0F'                ; побитное И с 0F
     XORLW H'0A'                ; сравнение с 0A
     BTFSS STATUS,Z             ; если не совпадают, скачок через команду
     GOTO M10                   ; вызов подпрограммы М2
     MOVF CNT,W                 ; загружаем счетчик в
     ADDLW H'6'
     MOVWF CNT                  ;загружаем новое значение счетчка
     MOVF CNT,W                 ;в рабочий регистр
     XORLW H'90'                ;сравниваем его с последним значением +1
     BTFSS STATUS,Z             ;если совпадают, то скачек через одну команду
     GOTO M10                   ;если не совпадают, то возврат
    
;суммирование в каждой 3 ячейке пары предыдущих чисел
     MOVLW H'0'                  ;загрузка начального значения в рабочий регистр
     MOVWF CNTSUMM
     MOVLW H'1F'                 ;загрузка начального значения в рабочий регистр
     MOVWF CNT 
                     
M3:
     INCF CNT,F
     INCF CNTSUMM,F              ;увеличение счётчика на 1
     MOVF CNTSUMM,W              ;перенос счётчика в рабочий регистр
     XORLW H'3'                  ;сравнение с 3
     BTFSS STATUS,Z              ;если не совпадают, скачок через команду
     GOTO M3                     ;вызов подпрограммы М3
     CLRF CNTSUMM                ;обнуляем регистр счетчик
                                 ;загружаем значение счетчика в рабочий регистр
     MOVF CNT,W                  ;Т
     MOVWF FSR                   ;загрузка счётчика в косвенно адресуемый
     DECF FSR,F
     DECF FSR,F                  ;загрузка числа в рабочий регистр
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

     ;ADDWF INDF,W                ;Т
     INCF FSR,F
     MOVWF INDF
     MOVF CNT,W                   ;в рабочий регистр
     XORLW H'79'                  ;сравниваем его с последним значением +1
     BTFSS STATUS,Z 
     GOTO M3                      ;вызов подпрограммы М3
     GOTO  WROTE_EEPROM

; дополнительные операции
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
;копирование из ОЗУ в EEPROM
     MOVLW H'79'              ;загрузка в рабочий регистр
                              ;адреса первого РОН в банке 0
     MOVWF FSR                ;записываем начальный адрес
                              ;в регистр косв. адресации
     CLRF CNT                 ;обнуляем регистр счетчик адреса EEPROM
M20: BSF STATUS,RP1 ; T выбираем банк регистров 3
     BSF STATUS,RP0 ; -
     BTFSC EECON1,WR ; T проверка окончания предыдущей
                     ; ¦ записи в EEPROM
     GOTO  M20       ; -
     BCF  STATUS,RP1 ; T выбираем банк регистров 1
     BSF  STATUS,RP0 ; -
     MOVF CNT,W      ;загружаем значение счетчика в рабочий регистр
     BSF STATUS,RP1  ; T выбираем банк регистров 2
     BCF  STATUS,RP0 ; -
     MOVWF EEADR     ;сохраняем адрес очередной ячейки в регистре адреса
     MOVF INDF,W     ;считываем данные из очередного РОН
                     ;в рабочий регистр
     MOVWF EEDATA    ;и сохраняем их в регистре данных EEPROM
     BSF   STATUS,RP1 ; T выбираем банк регистров 3
     BSF   STATUS,RP0 ; -
     BCF   EECON1,EEPGD ;выбираем EEPROM
     BSF   EECON1,WREN  ;разрешаем запись
     BCF   INTCON,GIE   ;запрещаем прерывания
     MOVLW H'55'        ; ¬
     MOVWF EECON2       ; ¦
     MOVLW H'AA'        ; + обязательная последовательность из пяти команд
     MOVWF EECON2       ; ¦
     BSF   EECON1,WR    ; -
     BCF   EECON1,WREN  ;запрещаем запись
     BCF   STATUS,RP1 ; T выбираем банк регистров 1
     BSF   STATUS,RP0 ; -
     DECF  FSR,F      ;увеличение адреса РОН
                      ;в регистре косвенной адресации
     DECF  FSR,F
     DECF  FSR,F
     INCF  CNT,F      ;увеличение счетчика на 1
     MOVF  CNT,W      ;загружаем новое значение счетчика
                      ;в рабочий регистр
     XORLW H'20'      ;сравниваем его с последним значением +1
     BTFSS STATUS,Z   ;если совпадают то скачек через одну команду
     GOTO  M20        ;если нет, то переход к копированию
                      ;очередной ячейки

M30  GOTO  M30                    ;зацикливаемся здесь
     END                         ;конец программы
