 LPARAMETER lcEncr
 maXno = 100
 lcEncr = UPPER(ALLTRIM(lcEncr))
 IF lcEncr<>'ON' .AND. lcEncr<>'OFF'
      RETURN MESSAGEBOX("Pass ON or OFF for encryption/decryption!")
 ENDIF
 lnFields = FCOUNT()
 FOR j = 1 TO lnFields
      lcField = FIELD(j)
      DO CASE
           CASE TYPE(lcField)$'CM'
                REPL ALL &LCFIELD WITH CONVRT(LCENCR,&LCFIELD)
      ENDCASE
 ENDFOR
ENDFUNC
*
FUNCTION CONVRT
 LPARAMETER lcEncrypt, lcString
 IF PARAMETERS()<2
      MESSAGEBOX('Pass two arguments, [On Off] and string')
      RETURN
 ENDIF
 lcEncrypt = UPPER(ALLTRIM(lcEncrypt))
 IF lcEncrypt='ON'
      lnLen = LEN(ALLTRIM(lcString))
      lcNewstring = ''
      FOR i = 1 TO lnLen
           IF i<maXno
                lcChar = CHR(ASC(SUBSTR(lcString, i, 1))+i)
           ELSE
                lcChar = CHR(ASC(SUBSTR(lcString, i, 1))+1)
           ENDIF
           lcNewstring = lcNewstring+lcChar
      ENDFOR
      reTval = lcNewstring
 ELSE
      lnLen = LEN(ALLTRIM(lcString))
      lcNewstring = ''
      FOR i = 1 TO lnLen
           IF i<maXno
                lcChar = CHR(ASC(SUBSTR(lcString, i, 1))-i)
           ELSE
                lcChar = CHR(ASC(SUBSTR(lcString, i, 1))-1)
           ENDIF
           lcNewstring = lcNewstring+lcChar
      ENDFOR
      reTval = lcNewstring
 ENDIF
 RETURN (reTval)
ENDFUNC
*
