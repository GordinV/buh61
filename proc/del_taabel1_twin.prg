**
** del_taabel1_twin.fxp
**
Parameter tnTooleping, tnKuu, tnAasta
Local leRror
leRror = .T.
If EMPTY(tnTooleping) .OR. EMPTY(tnKuu) .OR. EMPTY(tnAasta)
	Return .F.
Endif
With odB
	.usE('del_taabel1_twin')
	Select deL_taabel1_twin
	Delete ALL
*!*	      .opEntransaction()
	leRror = .cuRsorupdate('del_taabel1_twin')
*!*	      IF leRror=.T.
*!*	           .coMmit()
*!*	      ELSE
*!*	           .roLlback()
*!*	      ENDIF
Endwith
Return leRror
Endfunc
*
