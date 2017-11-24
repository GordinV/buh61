**
** remove_chr13_from_string.fxp
**
 PARAMETER tcString
 IF VARTYPE(tcString)='C' .AND. CHR(13)$tcString
      DO WHILE ATC(CHR(13), tcString)>0
           tcString = STUFFC(tcString, ATC(CHR(13), tcString), 2, SPACE(1))
      ENDDO
 ENDIF
 RETURN tcString
ENDFUNC
*
