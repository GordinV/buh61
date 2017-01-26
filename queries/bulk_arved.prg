set step on
set point to '.'
gRekv = 1
gUserId = 1
gnHandle = sqlconnect ('buhdata5','zinaida','159')
If gnHandle < 0
	Messagebox ('Connection')
	Return .f.
Endif
set step on
If vartype ( oDb ) <> 'O'
	Set classlib to classes\classlib
	oDb = createobject ( 'db')
Endif
oDb.use('comLausendRemote')
llError =sqlexec(gnHandle,'BEGIN TRANSACTION')
if llError < 1
	messagebox('Transaction')
	set step on
	return .f.
endif
llError = arvlist()
if llError = .f.
	=sqlexec(gnHandle,'ROLLBACK TRANSACTION')
else
	lnAnswer = messagebox('Save ?',1+16+0,'Kontrol')
	if lnAnswer = 1
		=sqlexec(gnHandle,'COMMIT TRANSACTION')
	else
		=sqlexec(gnHandle,'ROLLBACK TRANSACTION')
	endif
endif
=SQLDISCONNECT(gnhandle)


Function arvlist
	local lError
	oDb.use('comLausend','comLausendJournal',.t.)
	oDb.dbreq('comLausendJournal',0,'comLausend')			
	cString = " select id from arv where journalid < 1 AND KPV >='20020430'"
	lResult = sqlexec (gnHandle, cString, 'arvlist')
	If lResult < 1
		Messagebox ('Viga')
		Set step on
		Return .f.
	Endif
	Select arvlist
	Scan 
		lError = lausend ()
		If lError = .t.
			lError = savelausend()
		Endif
		if lError = .f.
			exit
		endif
	Endscan
	Return lError

Function savelausend
	Local lError
	lError=oDb.cursorupdate('v_arvjournal', 'v_journal')
	If lError = .t. and !empty( v_arvjournal.id)
		tnid = v_arvjournal.id
		Select v_arvjournal1
		Update v_arvjournal1 set;
			parentId = tnid
		lError=oDb.cursorupdate('v_arvjournal1', 'v_journal1')
		If lError = .t.
			Replace v_arv.journalid with tnid
			lError=oDb.cursorupdate('v_arv')
		Endif
	Endif
	Return lError

Function updatesaldo
	Select v_arvjournal1
	If vartype (oSaldo1)  <> 'O'
		Set classlib to classes\saldo1
		oSaldo1 = createobject ( 'saldo1')
	Endif
	With oSaldo1
		Scan
			tnid = v_arvjournal1.lausendId
			.deebet =  v_arvjournal1.deebet
			.kreedit =   v_arvjournal1.kreedit
			.summa = v_arvjournal1.Summa
			.kpv = v_arvjournal.kpv
			.asutusid = v_arvjournal.asutusid
			.updsaldo
			ldKpv = iif(empty(ldKpv),date(), ldKpv)
			nAsutusId = iif ( empty (nAsutusId), 0, nAsutusId)
			Do queries\recalc_saldod with ldKpv,v_arvjournal.kpv ,v_arvjournal1.deebet, v_arvjournal1.kreedit, nAsutusId, v_arvjournal.asutusid
			If !empty(nAsutusId)
				.updsubkonto(nAsutusId)
			Endif
		Endscan
		Do queries\updpohikonto with str(year(.kpv),4), str(month(.kpv),2),'%%'
		Do queries\updpohikonto1 with str(year(.kpv),4), str(month(.kpv),2),'%%'
	Endwith
	Return

Function lausend
	oDb.use ('v_journal','v_arvjournal',.t.)
	oDb.use ('v_journal1','v_arvjournal1',.t.)
	tnid = arvlist.id
	oDb.use ('v_arv','v_arv')
	oDb.use ('v_arvread','v_arvread')
	select v_arvread
	scan
		Do queries\arv1_lausend 
	endscan
	If reccount ('v_arvjournal') > 0 and reccount ('v_arvjournal1') > 0
		Return .t.
	Else
		Return .f.
	Endif
