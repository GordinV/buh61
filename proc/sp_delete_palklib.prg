**
** sp_delete_palklib.fxp
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
      .usE('v_palk_lib','cursor2')
      SELECT cuRsor1
      DELETE NEXT 1
      leRror = .cuRsorupdate('cursor1','v_palk_lib')
      IF leRror=.T.
           leRror = .cuRsorupdate('cursor1','v_library')
      ENDIF
      IF leRror=.F.
           .roLlback()
           MESSAGEBOX('Viga', 'Kontrol')
           IF coNfig.deBug=1
                SET STEP ON
           ENDIF
      ELSE
           .coMmit()
      ENDIF
 ENDWITH
 RETURN .T.
ENDFUNC
*
