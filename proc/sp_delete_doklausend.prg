**
** sp_delete_doklausend.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 odB.usE('v_doklausend','cursor1')
 SELECT cuRsor1
 DELETE NEXT 1
 odB.cuRsorupdate('cursor1','v_doklausend')
 USE IN cuRsor1
 RETURN .T.
ENDFUNC
*
