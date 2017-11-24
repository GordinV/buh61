Parameter tnAasta, tcKonto, tOpt
wait window 'Saldo arvutamine' nowait
if gVersia = 'VFP'
	lResult = sp_create_saldo1_tabel (gRekv, tnAasta, tcKonto)
else
	cString =  'sp_create_saldo1_tabel '+str(gRekv)+','+str(tnAasta)+",'"+tcKonto+"'"
	lresult = sqlexec(gnHandle,cString)
	lresult = iif (lResult > 0,.t.,.f.)
endif
if lResult = .f.

	_cliptext = cString
	messagebox ('Viga','Kontrol')
	if config.debug = 1
		set step on
	endif
	return .f.
endif
dkpv1 = date(tnAasta, 1,1)
dKpv2 = date(tnAasta,12,31)
if gVersia = 'VFP'
	lcString = "sp_calc_saldod1(gRekv, dKpv1,dKpv2, tcKonto)"
	lError = EVALUATE(lcString)
else
	cString = "sp_calc_saldod1 "+str (gRekv)+",'"+;
		dtoc(dKpv1,1)+"','"+dtoc(dKpv2,1)+"','"+;
		tcKonto + "'"
		lresult = sqlexec(gnHandle,cString)
		lresult = iif (lResult > 0,.t.,.f.)
endif
if lResult = .f.
	_cliptext = cString
	messagebox ('Viga','Kontrol')
	if config.debug = 1
		set step on
	endif
	return .f.
endif
if lResult = .T. and tOpt = .t.
	messagebox ('Operatsioon on edukalt','Kontrol')
endif
return .t.