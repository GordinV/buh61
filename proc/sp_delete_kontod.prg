**
** sp_delete_kontod.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 WITH odB
      .opEntransaction()
      .usE('v_library','cursor1')
      .usE('v_kontoinf','cursor2')
      .usE('v_subkonto','cursor3')
      SELECT cuRsor3
      DELETE NEXT 1
      SELECT cuRsor2
      DELETE NEXT 1
      SELECT cuRsor1
      DELETE NEXT 1
      leRror = .cuRsorupdate('cursor3','v_subkonto')
      IF leRror=.T.
           leRror = .cuRsorupdate('cursor2','v_kontoinf')
      ENDIF
      IF leRror=.T.
           leRror = .cuRsorupdate('cursor1','v_library')
      ENDIF
      IF leRror=.T.
           .coMmit
      ELSE
           .roLlback()
           MESSAGEBOX('Viga', 'Kontrol')
           IF coNfig.deBug=1
                SET STEP ON
           ENDIF
      ENDIF
 ENDWITH
 USE IN cuRsor1
 USE IN cuRsor2
 USE IN cuRsor3
 RETURN .T.
ENDFUNC
*
