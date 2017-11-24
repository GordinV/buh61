**
** returnedvalue.fxp
**
 LPARAMETER tcValue, tnOrder
 LOCAL lrEturn, lnPosition
 lnPosition = 0
 lrEturn = ''
 IF  .NOT. EMPTY(tcValue) .AND. TYPE('tcValue')='C'
      DO CASE
           CASE LEFT(tcValue, 1)='N'
                lnPosition = AT(';', tcValue)
                IF lnPosition>0
                     lrEturn = VAL(IIF(tnOrder=1, SUBSTR(tcValue, 2,  ;
                               lnPosition-2), RIGHT(tcValue, LEN(tcValue)- ;
                               lnPosition)))
                ENDIF
           CASE LEFT(tcValue, 1)='D'
                lnPosition = AT(';', tcValue)
                IF lnPosition>0
                     lrEturn = CTOD(IIF(tnOrder=1, SUBSTR(tcValue, 2,  ;
                               lnPosition-2), RIGHT(tcValue, LEN(tcValue)- ;
                               lnPosition)))
                ENDIF
      ENDCASE
 ELSE
      MESSAGEBOX('Viga: wrong parameter', 'Kontrol')
      RETURN ''
 ENDIF
 RETURN lrEturn
ENDFUNC
*
