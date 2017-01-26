**
** viimane_paev.fxp
**
 PARAMETER tnAasta, tnKuu
 IF EMPTY(tnKuu) .OR. VARTYPE(tnKuu)<>'N' .OR. tnKuu>12
      tnKuu = MONTH(DATE())
 ENDIF
 IF EMPTY(tnAasta) .OR. VARTYPE(tnAasta)<>'N'
      tnAasta = YEAR(DATE())
 ENDIF
 DIMENSION amOnth(12)
 amOnth(1) = 31
 amOnth(2) = 28
 amOnth(3) = 31
 amOnth(4) = 30
 amOnth(5) = 31
 amOnth(6) = 30
 amOnth(7) = 31
 amOnth(8) = 31
 amOnth(9) = 30
 amOnth(10) = 31
 amOnth(11) = 30
 amOnth(12) = 31
 IF tnKuu=2
      ldAte = DATE(tnAasta, 2, amOnth(2))+1
      IF MONTH(ldAte)=2
           amOnth(2) = 29
      ENDIF
 ENDIF
 RETURN amOnth(tnKuu)
ENDFUNC
*
