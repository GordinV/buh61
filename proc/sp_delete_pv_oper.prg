**
** sp_delete_pv_oper.fxp
**
 PARAMETER tnId
 LOCAL leRror
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 WITH odB
      .usE('v_pv_oper','cursor1')
      SELECT cuRsor1
      DELETE NEXT 1
      leRror = .cuRsorupdate('cursor1','v_pv_oper')
 ENDWITH
 IF leRror=.T. .AND. USED('v_pv_oper')
      SELECT v_Pv_oper
      DELETE NEXT 1
 ENDIF
 USE IN cuRsor1
 RETURN .T.
ENDFUNC
*
