**
** sp_delete_lausendid.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 LOCAL leRror
 leRror = .T.
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 WITH odB
      .usE('qrylausendid')
      IF RECCOUNT('qrylausendid')>0
           leRror = .F.
      ENDIF
      USE IN qrYlausendid
      IF leRror=.T.
           .usE('v_lausend','cursor1')
           SELECT cuRsor1
           DELETE NEXT 1
           .opEntransaction()
           leRror = .cuRsorupdate('cursor1','v_lausend')
           IF leRror=.F.
                .roLlback()
                MESSAGEBOX('Viga', 'Kontrol')
           ELSE
                .coMmit()
           ENDIF
           USE IN cuRsor1
      ENDIF
 ENDWITH
 RETURN .T.
ENDFUNC
*
