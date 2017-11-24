**
** sp_delete_lepingud.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 odB.usE('v_leping2','cursor2')
 odB.usE('v_leping1','cursor1')
 SELECT cuRsor2
 DELETE ALL
 SELECT cuRsor1
 DELETE ALL
 odB.opEntransaction()
 leRror = odB.cuRsorupdate('cursor2','v_leping2')
 IF leRror=.T.
      leRror = odB.cuRsorupdate('cursor1','v_leping1')
 ENDIF
 IF leRror=.F.
      odB.roLlback()
      MESSAGEBOX('Viga', 'Kontrol')
 ELSE
      odB.coMmit()
 ENDIF
 USE IN cuRsor1
 USE IN cuRsor2
 RETURN leRror
ENDFUNC
*
