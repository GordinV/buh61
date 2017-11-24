Local lError
lError = get_uus_arved()
If lError = .t.
	lError = extract_uus_arved()
Endif
Return lError

Function samm
	Local  lnResult
	If !used('curSource')
		Create cursor curSource (id int, kood c(20), nimetus c(120))
	Endif
	If !used('curValitud')
		Create cursor curValitud (id int, kood c(20), nimetus c(120))
	Endif
	If !used('curResult')
		Create cursor curResult (id int, num int, Id int)
	Endif

	Select num as id, space(1) as kood, nimetus from curUusTeenus where reg = 0 into cursor qry1
	lnStep = 1
	Do while lnStep > 0
		Do case
			Case lnStep = 1
				Select curValitud
				If reccount('curvalitud') > 0
					Zap
				Endif
				Select curSource
				Append from dbf('qry1')
				Use in qry1
				Do form forms\samm with '1', iif(config.keel = 2,'Teenused','Оказанные услуги'),iif(config.keel = 2,;
					'Valitud teenused','Выбранные услуги') to nResult
		Endcase
		If nResult = 1
			Select distinc id from curValitud into cursor query1
			Select query1
			Scan
				Select curResult
				Insert into curResult (num);
					values (query1.id)
			Endscan
			Use in query1
			Select curValitud
			Zap
			lnStep = 0
		Endif
	Enddo
	If used('curSource')
		Use in curSource
	Endif
	If used('curvalitud')
		Use in curValitud
	Endif
	If nResult = 1
		Return .t.
	Else
		Return .f.
	Endif
Endproc


Function register_uus_teenused
	Local lresult
	Select curUusTeenus
	Scan for reg = 0
		If !used ('v_nomenklatuur')
			oDb.use ('v_nomenklatuur','v_nomenklatuur',.t.)
		Endif
		Insert into v_nomenklatuur (rekvid, dok, kood, nimetus, uhik, hind);
			values (gRekv, 'ARV',left(curUusTeenus.nimetus,20), curUusTeenus.nimetus, curUusTeenus.uhik, curUusTeenus.hind)
	Endscan
	If used ('v_nomenklatuur') and reccount ('v_nomenklatuur') > 0
&& salvestan uut operatsioonid
		oDb.opentransaction()
		lError = oDb.cursorupdate('v_nomenklatuur')
		If lError = .t.
			oDb.commit()
		Else
			oDb.rollback()
			Messagebox('Viga','Kontrol')
			If config.debug = 1
				Set step on
			Endif
		Endif
	Endif
	Return


Function arvede_teenuste_analus
	Local lresult, lcNum, llfound
	Create cursor curUusTeenus (id int, num int, nimetus c(120), reg int, uhik c(20), hind y)
	Select tmparv3
	Scan
		lcNum = alltrim(str(tmparv3.num))
		Select comNomRemote
		Locate for lcNum $ comNomRemote.muud while llfound = .f.
		If found ()
&& определяем соответствует ли найденная операция требованиям
			lnLine = atcLine(lcNum,comNomRemote.muud)
			If lnLine > 0
				llfound = .t.
				Insert into curUusTeenus (id, num, nimetus, reg);
					values (comNomRemote.id, tmparv3.num, tmparv3.nimetus, 1)
			Endif
		Endif
		If !found and eof()
&& запись не зарегистрирована
			llfound = .t.
			Insert into curUusTeenus (id, num, nimetus, reg, uhik, hind);
				values (0, tmparv3, tmparv3.nimetus, 0, tmparv3.uhik, tmparv3.hind)
		Endif
	Endscan
	Return lresult

Function get_uus_arved
	Local lresult
	If !directory('earved')
		Mkdir earved
	Endif
*!*	lcDir = sys(2003)
*!*	lcFileSource = lcDir + '\temp\tmparv1.dbf'
*!*	if file(lcFileSource)
*!*		copy file (lcDir + + '\temp\tmparv?.*') to (lcDir + '\earved\tmparv?.*')
*!*	endif
	lresult = .t.
	Return lresult

Function extract_uus_arved
	For i = 1 to 5
		lcDbf = sys(2003)+'\earved\tmparv'+str(i,1)
		Use (lcDbf) in 0
	Endfor
	Create cursor curUusArved (num int, number c(20), kpv d, summa y)
	Select tmparv1
	Scan
		Select comarvremote
		Locate for alltrim(comarvremote.number) = alltrim(str (tmparv1.doknum));
			and comarvremote.kpv = tmparv1.kuupaev;
			and round(comarvremote.summa,1) = round(tmparv1.summa,1)
		If !found()
			Select curUusArved
			Append blank
			Replace num with tmparv1.num,;
				kpv with tmparv1.kuupaev,;
				summa with tmparv1.summa in curUusArved
		Endif
	Endscan
	If reccount ('curUusArved') > 0
&& есть новые номера
		Select curUusArved
		Browse
	Endif
	Return

Function open_teenindus_data
	Local lresult
	If !used ('config')
		Use config in 0
	Endif
	lcData = ltrim(rtrim(config.reserved1))
	If file(lcData)
		Open data (lcData)
	Endif
	If dbused ('teendata')
		lresult = .t.
	Endif
	Return lresult
