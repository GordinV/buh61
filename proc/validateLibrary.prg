**
** validatelibrary.fxp
**
 PARAMETER tcAlias, tcKood
 IF  .NOT. USED('v_eel_config')
      odB.usE('v_eel_config')
 ENDIF
 IF v_Eel_config.vaLklassif=0
      RETURN .T.
 ENDIF
 IF EMPTY(tcAlias) .OR.  .NOT. USED(tcAlias) .OR. EMPTY(tcKood)
      RETURN .T.
 ENDIF
 SELECT (tcAlias)
 LOCATE FOR koOd=tcKood
 npArentid = EVALUATE(tcAlias+'.id')
 LOCATE FOR LEFT(ALLTRIM(UPPER(koOd)), LEN(tcKood))=tcKood .AND. id<>npArentid
 IF FOUND() .AND. LEN(ALLTRIM(koOd))>LEN(tcKood)
      RETURN .F.
 ELSE
      RETURN .T.
 ENDIF
ENDFUNC
*
