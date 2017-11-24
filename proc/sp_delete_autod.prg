**
** sp_delete_autod.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 odB.usE('v_auto','cursor1')
 SELECT cuRsor1
 DELETE NEXT 1
 leRror = odB.cuRsorupdate('cursor1','v_auto')
 IF leRror=.F.
      MESSAGEBOX('Viga', 'Kontrol')
 ENDIF
 RETURN .T.
ENDFUNC
*
