LOCAL lError
IF !used ('curArved')
	tcAsutus = '%'
	tcNumber = '%'
	tdKpv1 = date(year(date()),1,1)
	tdKpv2 = date(year(date()),12,31)
	tdTaht1 = date(year(date())-1,1,1)
	tdTaht2 = date()+365*10
	tnSumma1 = -9999999
	tnSumma2 = 999999999
	tdTasud1 = date(year(date())-2,1,1)
	tdTasud2 = date()+365*10
	tnLiik = 0
	oDb.use('curArved')
ENDIF
SET classlib to tasudok additive
oTasudok = createobject ('tasudok')
oDb.opentransaction()
WITH oTasudok
	SELECT curArved
	SCAN
		WAIT window 'Arve number: '+curArved.number nowait
		.arvId = curArved.id
		.kpv = curArved.tasud
		lError = .arvtasumine(.t.)
		IF lError = .f.
			oDb.rollback()
			MESSAGEBOX ('Viga')
			EXIT
		ENDIF
	ENDSCAN
	IF lError = .f.
		RETURN .f.
	ENDIF
	tnLiik = 1
	oDb.dbreq('curArved')
	SELECT curArved
	SCAN
		WAIT window 'Arve number: '+curArved.number nowait
		.arvId = curArved.id
		.kpv = curArved.tasud
		lError = .arvtasumine(.t.)
		IF lError = .f.
			oDb.rollback()
			MESSAGEBOX ('Viga')
			EXIT
		ENDIF
	ENDSCAN
	IF lError = .t.
		oDb.commit()
		=messagebox ('Ok')
	ENDIF
ENDWITH
RETURN lError