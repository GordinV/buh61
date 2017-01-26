Parameter tdKpv, nTulud, nKulud
Local lError
lError = .t.
With oDb
	lError = .use('comLausend','comLausendKinnitamine',.t.)
	lError = .dbreq('comLausendKinnitamine',0,'comLausend')
	lError = .use ('v_journal','v_journal',.t.)
	lError = .use ('v_journal1','v_journal1',.t.)
	dKpv1 = date(year(tdKpv),month (tdKpv),1)
	dKpv2 = date(year(tdKpv),month (tdKpv),1)
	lError = .use ('v_saldod','v_saldod',.t.)
	Index on konto tag konto
	lError = .opentransaction()
Endwith
lnYear = year (dkpv1)
lnMonth = month (dKpv1)+1
if lnMonth > 12
	lnMonth = 1
	lnYear = lnYear + 1
endif
lError = oDb.exec ("sp_saldo ",str(grekv)+", "+str(lnmonth,2)+","+str(lnyear,4)+",'%'", 'qrySaldod' )
if lError = .f. and config.debug = 1
	set step on
	glError = .t.
	return .f.
endif
select qrySaldod
index on alltrim(konto) tag konto
set order to konto
If !empty(nTulud) and lError = .t.
	lError=queryLausend (nTulud)
Endif
If lError = .t.
	Select v_journal1
	Scan
*!*			If !used('v_saldod')
*!*				oDb.use ('v_saldod','v_saldod',.t.)
*!*	&&			Index on konto tag konto
*!*	&&			oDb.dbreq('v_saldod',gnHandle,'v_saldod')
*!*			Endif
		Select qrysaldod
		seek alltrim(v_journal1.deebet)
		If found ()
			lnSumma = qrysaldod.kreedit - qrysaldod.deebet  
			Replace v_journal1.summa with  lnSumma  in v_journal1
		Endif
	Endscan
	Select v_journal1
	Delete for empty (v_journal1.summa )
	Count to lnCount
	If lnCount > 0
		lError = savelausend()
	Endif
Endif
If lError = .t. and !empty(nKulud)
	lError=queryLausend (nKulud)
	Select v_journal1
	Scan
*!*			If !used('v_saldod')
*!*				oDb.use ('v_saldod','v_saldod',.t.)
*!*				Index on konto tag konto
*!*				oDb.dbreq('v_saldod',gnHandle,'v_saldod')
*!*			Endif
		Select qrysaldod
		seek alltrim(v_journal1.kreedit)
		If found ()
			lnSumma = qrysaldod.deebet - qrysaldod.kreedit  
			Replace v_journal1.summa  with lnSumma in v_journal1
		Endif
	Endscan
	Select v_journal1
	Delete for empty (v_journal1.summa )
	Count to lnCount
	If lnCount > 0
		lError = savelausend()
	Endif
Endif
With oDb
	If lError = .t.
		.commit()
&&		Messagebox ( iif (config.keel = 2,'Operatsioon on edukalt','Операция прошла успешно'),'Kontrol')
	Else
		If lError = .f. and config.debug = 1
			Set step on
		Endif
		.rollback()
		Messagebox ( iif (config.keel = 2,'Viga','Ошибка'),'Kontrol')
		glError = .t.
	Endif
Endwith
Return lError

Function recalcsaldo
*!*	if gVersia = 'VFP'
*!*		lError = sp_update_saldod (0,v_journal.id)
*!*	else
*!*		cString = 'sp_update_saldo '+alltrim(str (0))+','+alltrim(str ( v_journal.Id))
*!*		lError = sqlexec(gnHandle,cString)
*!*		lError = iif(lError > 0,.t.,.f.)
*!*	endif
	Return


Function savelausend
	Local lError
	Select v_journal1
	Sum summa to lnSumma
	If lnSumma <> 0
		lError=oDb.cursorupdate('v_journal', 'v_journal')
		If lError = .t. and !empty( v_journal.id)
			tnId = v_journal.id
			Select v_journal1
			Update v_journal1 set;
				parentId = tnId
			lError=oDb.cursorupdate('v_journal1', 'v_journal1')
		Endif
		If lError = .f. and config.debug = 1
*!*				lError=recalcsaldo()
*!*	&&			do form operatsioon with 'EDIT',
			Set step on
		Endif
	Endif
	Return lError

Function queryLausend
	Parameter tnId
	If empty(tnId)
		Return .f.
	Endif
	With oDb
		.use('v_journal','v_journal',.t.)
		.use('TYHIASUTUS')
		Select v_journal
		Insert into v_journal (rekvId, userId, kpv, asutusid) values (grekv, gUserid, tdKpv,tyhiasutus.id)
		.use('v_journal1','v_journal1',.t.)
		oDb.use('v_doklausheader','query1')
		If reccount('query1') > 0
			oDb.use('v_doklausend','query2')
		Endif
		Replace v_journal.selg with query1.selg in v_journal
		Use in query1
		Select query2
		Scan
			Select comLausendKinnitamine
			Locate for id = query2.lausendId
			Insert into v_journal1 (lausendId, nimetus, deebet, kreedit, kood1, kood2, kood3, kood4);
				values (query2.lausendId, comLausendKinnitamine.nimetus, comLausendKinnitamine.deebet,;
				comLausendKinnitamine.kreedit, query2.kood1, query2.kood2, query2.kood3, query2.kood4)
			Select v_journal1
		Endscan
	Endwith
	Use in query2
	If reccount('v_journal1') < 1
		Return .f.
	Else
		Return .t.
	Endif
Endproc
