**
** sp_delete_allikad.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 odB.usE('v_library','cursor1')
 SELECT cuRsor1
 DELETE NEXT 1
 odB.cuRsorupdate('cursor1','v_library')
 RETURN .T.
ENDFUNC
*
