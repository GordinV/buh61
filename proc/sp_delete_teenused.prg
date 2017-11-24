**
** sp_delete_teenused.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 DO sp_delete_arved WITH tnId
 RETURN .T.
ENDFUNC
*
