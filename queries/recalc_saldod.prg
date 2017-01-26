Parameter tdKpv1, tdKpv2, tcDeebet, tcKreedit, tnVanaAsutus, tnUusAsutus
ldStart = min (tdKpv1, tdKpv2)
ldLopp = max (tdKpv1, tdKpv2)
lnVanaAasta = year (tdKpv1 )
lnVanaKuu = month ( tdKpv1 )
lnUusAasta = year ( tdKpv2 )
lnUusKuu = month ( tdKpv2 )
If lnVanaAasta <> lnUusAasta or lnVanaKuu <> lnUusKuu or month (tdKpv2) <> month (date()) 
	cString = " sp_recalc_saldo "+str (grekv) +",'"+;
		dtoc ( ldStart,1) + "','"+dtoc ( date(),1)+"','"+rtrim(tcDeebet)+"%'"
	lError = sqlexec (gnHandle, cString )
	If lError > -1
		cString = " sp_recalc_saldo "+str (grekv) +",'"+;
			dtoc ( ldStart,1) + "','"+dtoc ( date(),1)+"','"+rtrim(tcKreedit)+"%'"
		lError = sqlexec (gnHandle, cString )
	Endif
	If tnVanaAsutus <> tnUusAsutus and lError > -1
		cString = " sp_recalc_saldo1 "+str (grekv) +",'"+;
			dtoc ( ldStart,1) + "','"+dtoc ( date(),1)+"','"+rtrim(tcDeebet)+"%'"
		lError = sqlexec (gnHandle, cString )
		If lError > -1
			cString = " sp_recalc_saldo1 "+str (grekv) +",'"+;
				dtoc ( ldStart,1) + "','"+dtoc ( date(),1)+"','"+rtrim(tcKreedit)+"%'"
			lError = sqlexec (gnHandle, cString )
		Endif

	Endif
Endif
&&do queries\recalc_saldod with ldKpv, date (),cursor1.deebet, cursor1.kreedit
