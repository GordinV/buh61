 PARAMETER tnId
 LOCAL leRror
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 WITH odB
      leRror = .usE('CHKNOMID')
      IF RECCOUNT('CHKNOMID')>0
           USE IN chKnomid
           MESSAGEBOX(IIF(coNfig.keEl=2, 'Ei saa kustuta kiri',  ;
                     'Удаление записи не разрешено'), 'kontrol')
           RETURN .F.
      ENDIF
      IF USED('CHKNOMID')
           USE IN chKnomid
      ENDIF
      .opEntransaction()
      .usE('v_nomenklatuur','cursor1')
      .usE('v_ladu_grupp','cursor2')
      SELECT cuRsor1
      DELETE NEXT 1
      SELECT cuRsor2
      DELETE ALL
      leRror = .cuRsorupdate('cursor1','v_nomenklatuur')
      IF leRror=.T.
           leRror = .cuRsorupdate('cursor2','v_ladu_grupp')
      ENDIF
      IF leRror=.T.
           .coMmit()
      ELSE
           .roLlback
      ENDIF
 ENDWITH
 USE IN cuRsor1
 USE IN cuRsor2
 RETURN leRror
ENDFUNC
*
