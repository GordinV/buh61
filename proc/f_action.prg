 LPARAMETER tpAd, tbAr
 SELECT acTion FROM menuitem WHERE npAd=tpAd AND nbAr=tbAr INTO CURSOR menu1
 = ALINES(amEnu, meNu1.acTion, .T.)
 lnCount = ALEN('aMenu', 1)
 IF lnCount=1
      lcAction = amEnu(1)
      IF  .NOT. EMPTY(lcAction)
           &lcAction
      ENDIF
 ELSE
      FOR ij = 1 TO lnCount
           lcAction = amEnu(ij)
           IF  .NOT. EMPTY(lcAction) .AND. lnCount>=ij
                &lcAction
           ENDIF
      ENDFOR
 ENDIF
 IF USED('menu1')
      USE IN meNu1
 ENDIF
 RETURN
ENDPROC
*
