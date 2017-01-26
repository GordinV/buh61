parameter tnLausend
Local  lnResult
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
&&tnDok = 1
If !used('curSource')
	Create cursor curSource (id int, kood c(20), nimetus c(120))
Endif
If !used('curValitud')
	Create cursor curValitud (id int, kood c(20), nimetus c(120))
Endif
If !used('curResult')
	Create cursor curResult (id int, lausendId int, dokId int)
Endif
oDb.use('curlausDok1')
oDb.use('v_lausd','curresult',.t.)
select curresult 
append from dbf('curlausDok1')
lnStep = 1
Do while lnStep > 0
	Do case
		Case lnStep = 1
			Do get_lausendid_list
*!*			Case lnStep = 2
*!*				Do get_lepingu_list
*!*			Case lnStep > 2
*!*				Do arvutus
	Endcase
Enddo
If used('curSource')
	Use in curSource
Endif
If used('curvalitud')
	Use in curValitud
Endif

Function get_lausendid_list
	oDb.use('comDok','comDokSamm',.t.)
	oDb.dbreq('comDokSamm',0,'comDok')
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Select comDokSamm
	Scan 
		Insert into curSource (id, kood, nimetus ) values (comDokSamm.id,;
			alltrim(comDokSamm.KOOD),rtrim(comDokSamm.nimetus))
		select curResult
		locate for lausendId = comDokSamm.id
		if found() 
			Insert into curValitud (id, kood, nimetus ) values (comDokSamm.id,;
				alltrim(comDokSamm.kood),rtrim(comDokSamm.nimetus))
			delete from curSource where id = comDokSamm.id
		endif
	Endscan
	Do form forms\samm with '1', iif(config.keel = 2,'Lausendid','Проводки'),iif(config.keel = 2,;
		'Valitud lausendid','Выбранные проводки') to nResult
	If nResult = 1
		Select distinc id from curValitud into cursor query1
		select query1
		scan
			select curResult
			locate for lausendId = query1.id
			if !found()
				insert into curResult (lausendId, dokid);
					values (tnLausend, curValitud.id)
			endif
		endscan
		select curresult
		select id from curresult where id not in (select id from query1 where query1.id > 1) and curResult.id > 0 into cursor qry1
		select qry1
		scan for id > 0
			select curResult
			delete for id = qry1.id
		endscan
		Use in query1
		Select curValitud
		Zap
		lnStep = 0
		lError = oDb.cursorupdate('curResult','v_lausd',gnHandle)
		if lError = .f.
			set step on
		endif
	Endif
	If nResult = 0
		lnStep = 0
	Endif

	Return
