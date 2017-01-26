**
** registreerimine.fxp
**
 PARAMETER tcOper, tcDok, tnId
 IF EMPTY(coNfig.reGister)
      RETURN .T.
 ENDIF
 tcOper = IIF(EMPTY(tcOper), SPACE(1), tcOper)
 tcDok = IIF(EMPTY(tcDok), SPACE(1), tcDok)
 tnId = IIF(EMPTY(tnId), 0, tnId)
 WITH odB
      .usE('v_raamat','v_raamat',gnHandle,.T.)
      INSERT INTO v_raamat (reKvid, usErid, opEratsioon, doKument, doKid)  ;
             VALUES (grEkv, guSerid, tcOper, tcDok, tnId)
      leRror = .cuRsorupdate('v_raamat')
      IF VARTYPE(leRror)='N'
           leRror = IIF(leRror>0, .T., .F.)
      ENDIF
      IF leRror=.F. .AND. coNfig.deBug=1
           SET STEP ON
      ENDIF
      USE IN v_Raamat
 ENDWITH
 RETURN leRror
ENDFUNC
*
