**
** systoolbars.fxp
**
 PARAMETER toPt
 IF EMPTY(toPt)
      toPt = 0
 ENDIF
 IF toPt=0
      HIDE WINDOW "Standard"
      HIDE WINDOW "Command"
 ELSE
      SHOW WINDOW "Standard"
      SHOW WINDOW "Command"
 ENDIF
ENDPROC
*
