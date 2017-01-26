**
** readformula.fxp
**
 PARAMETER tcString, tnId, tnOpt
 LOCAL lcSumma, lnSumma
 IF EMPTY(tnOpt)
      tnOpt = 0
 ELSE
      tnOpt = 1
 ENDIF
 lcSumma = ''
 IF EMPTY(tcString) .OR. EMPTY(tnId)
      RETURN IIF(tnOpt=0, 0, '')
 ENDIF
 IF  .NOT. USED('qryLeping2')
      odB.usE('v_leping2','qryleping2')
 ENDIF
 noCcurs = OCCURS('?', tcString)
 FOR i = 1 TO noCcurs
      lnStart1 = ATC('?', tcString, 1)
      lfOund = .F.
      icHar = lnStart1
      DO WHILE lfOund=.F.
           lcChar = SUBSTR(tcString, icHar, 1)
           IF lcChar=CHR(127) .OR. EMPTY(lcChar) .OR. lcChar=CHR(43) .OR.  ;
              lcChar=CHR(45) .OR. lcChar=CHR(42) .OR. lcChar=CHR(47)
                lfOund = .T.
           ELSE
                icHar = icHar+1
           ENDIF
      ENDDO
      lnStart2 = icHar-1
      lcKood = SUBSTR(tcString, lnStart1+1, lnStart2-lnStart1)
      SELECT qrYleping2
      LOCATE FOR UPPER(LTRIM(RTRIM(koOd)))=UPPER(lcKood)
      IF FOUND()
           lcSumma = ALLTRIM(STR(qrYleping2.suMma, 12, 2))
      ELSE
           lcSumma = '0'
      ENDIF
      tcString = STUFF(tcString, lnStart1, LEN(lcKood)+1, lcSumma)
 ENDFOR
 lnSumma = 0
 lnSumma = EVALUATE(tcString)
 RETURN IIF(tnOpt=0, lnSumma, tcString)
ENDFUNC
*
