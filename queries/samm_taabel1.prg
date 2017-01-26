Local  lnResult
if empty (gnKuu) or empty (gnAasta )
	do form period
endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif

If !used('curSource')
	Create cursor curSource (id int, kood c(20), nimetus c(120))
Endif
If !used('curValitud')
	Create cursor curValitud (id int, kood c(20), nimetus c(120))
Endif
Create cursor curResult (Id int, osakondId int)
lnStep = 1
Do while lnStep > 0
	Do case
		Case lnStep = 1
			Do get_osakonna_list
		Case lnStep = 2
			Do get_isiku_list
		Case lnStep > 2
			Do arvutus
	Endcase
Enddo
If used('curSource')
	Use in curSource
Endif
If used('curvalitud')
	Use in curValitud
Endif
If used('curResult')
	Use in curResult
Endif
if used ('qryPuhkused')
	use in qryPuhkused
endif


Procedure arvutus
	Local lError
&&	=sqlexec(gnHandle,'BEGIN TRANSACTION')
	oDb.opentransaction()
	Select distinc id from curResult where !empty(curResult.id) into cursor recalc1
	Select recalc1
	Scan
		lError=edit_oper(recalc1.Id)
		If lError = .t.
			lError=save_oper()
		Endif
		If lError = .f.
			Exit
		Endif
	Endscan
	If lError = .t.
		oDb.commit
	Else
		oDb.rollback
		Messagebox('Viga','Kontrol')
	Endif
	lnStep = 0
Endproc

Procedure edit_oper
	Parameter tnid
	If !used ('qryTaabel1')
		tcOsakond = '%%'
		tcAmet = '%%'
		tcisik = '%%'
		tnKokku1 = 0
		tnKokku2 = 999
		tnToo1 = 0
		tnToo2 = 999
		tnPuhk1 = 0
		tnPuhk2 = 999
		tnKuu1 = gnKuu
		tnKuu2 = gnKuu
		tnAasta1 = gnAasta
		tnAasta2 = gnAasta
		odb.use ('curTaabel1','qryTaabel1')
	Endif
	odb.use('v_taabel1','v_taabel1',.t.)
	Select qryTaabel1
	Locate for tooleping = tnid and kuu = gnKuu and aasta = gnAasta
	If !found ()
		select v_taabel1
		Append blank
		Replace tooleping with tnid,;
			kuu with gnKuu,;
			aasta with gnAasta in v_taabel1
		lError=del_taabel1_twin(tnId, gnkuu, gnaasta)			
	else
		tnid = qryTaabel1.id
		oDb.dbreq('v_taabel1',gnHandle,'v_taabel1')
	Endif
	tnid = qryTaabel1.tooleping
	Do queries\calc_taabel1 with tnId
Endproc

Procedure save_oper
	Select v_taabel1
	lresult = odb.cursorupdate ('v_taabel1')
	tnid = v_taabel1.id
	return lResult 
Endproc 


Procedure get_osakonna_list
	If used('query1')
		Use in query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odb.use('curOsakonnad','qryOsakonnad')
	Select curSource
	If reccount('curSource') > 0
		Zap
	Endif
	Append from dbf('qryOsakonnad')
	Use in qryOsakonnad
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Do form forms\samm with '1', iif(config.keel = 2,'Osakoonad','Подразделения'),iif(config.keel = 2,;
		'Valitud osakonnad','Выбранные подразделения') to nResult
	If nResult = 1
		Select distinc id from curValitud  into cursor query1
		Select query1
		Scan
			Insert into curResult (osakondId);
				values (query1.id)
		Endscan
		Use in query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
Endproc

Procedure get_isiku_list
	If used('query1')
		Use in query1
	Endif
	odb.use('curKaader','qryKaader')
	Select curSource
	If reccount('curSource') > 0
		Zap
	Endif
	Select isikukood as kood, left(rtrim(isik)+space(1)+rtrim(amet),120) as nimetus, id from qryKaader where osakondId in (select osakondId from curResult);
		into cursor query1
	Select curSource
	Append from dbf('query1')
	Use in query1
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Do form forms\samm with '2', iif(config.keel = 2,'Tццtajad','Работники'),;
		iif(config.keel = 2,'Valitud tццtajad','Выбранные работники') to nResult
	If nResult = 1
		Select distinc id from curValitud into cursor query1
		Select query1
		Scan
			Insert into curResult (id);
				values (query1.id)
		Endscan
		Use in query1
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
	Return
