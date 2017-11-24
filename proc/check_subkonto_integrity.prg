**
** check_subkonto_integrity.fxp
**
 WITH odB
      leRror = odB.usE('subkontoindex')
      IF leRror=.F.
           MESSAGEBOX('Viga: creating index table')
           RETURN .F.
      ENDIF
      IF  .NOT. USED('subkontoindex') .OR. RECCOUNT('subkontoindex')<1
           RETURN .T.
      ENDIF
      lnKontoid = 0
      .opEntransaction()
      SELECT suBkontoindex
      INDEX ON koNtoid TAG koNtoid
      SET ORDER TO kontoid
      leRror = .T.
      SCAN
           IF lnKontoid<>suBkontoindex.koNtoid
                IF USED('v_subkonto')
                     leRror = .cuRsorupdate('v_subkonto')
                ENDIF
                IF leRror=.T.
                     IF lnKontoid>0
                          DO queries\recalc_subkontod WITH YEAR(DATE()),  ;
                             RTRIM(qrYlibrary.koOd), .T.
                     ELSE
                          lnKontoid = suBkontoindex.koNtoid
                     ENDIF
                     tnId = suBkontoindex.koNtoid
                     leRror = .usE('v_subkonto','v_subkonto')
                     = CURSORSETPROP('buffering', 5)
                     leRror = .usE('v_library','QRYlIBRARY')
                     IF leRror=.F. .OR.  .NOT. USED('v_subkonto') .OR.   ;
                        .NOT. USED('qryLibrary')
                          EXIT
                     ENDIF
                ENDIF
           ENDIF
           IF leRror=.F.
                EXIT
           ENDIF
           WAIT WINDOW NOWAIT 'Arvestan konto :'+ALLTRIM(qrYlibrary.koOd)
           SELECT v_Subkonto
           APPEND BLANK
           REPLACE v_Subkonto.koNtoid WITH suBkontoindex.koNtoid,  ;
                   v_Subkonto.asUtusid WITH suBkontoindex.asUtusid, aaSta  ;
                   WITH YEAR(DATE()) IN v_Subkonto
           lnKontoid = suBkontoindex.koNtoid
      ENDSCAN
      IF USED('v_subkonto') .AND. leRror=.T.
           leRror = .cuRsorupdate('v_subkonto')
           DO queries\recalc_subkontod WITH YEAR(DATE()),  ;
              RTRIM(qrYlibrary.koOd)
      ENDIF
      IF leRror=.F.
           .roLlback()
           MESSAGEBOX('Viga, salvestamine')
      ELSE
           .coMmit()
      ENDIF
      WAIT WINDOW NOWAIT ''
 ENDWITH
 IF USED('subkontoindex')
      USE IN suBkontoindex
 ENDIF
 IF USED('qryLibrary')
      USE IN qrYlibrary
 ENDIF
 IF USED('v_subkonto')
      USE IN v_Subkonto
 ENDIF
ENDFUNC
*
