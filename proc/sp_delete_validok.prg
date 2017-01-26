**
** sp_delete_validok.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 odB.usE('v_dokprop','cursor1')
 SELECT cuRsor1
 DELETE NEXT 1
 odB.cuRsorupdate('cursor1','v_dokprop')
 RETURN .T.
ENDFUNC
*
