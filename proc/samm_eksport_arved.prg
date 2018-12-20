Parameter tnLepingId, tdKpv, tnPreliminary
If !Empty(tdKpv)
	ldArvKpv = tdKpv
Else
*	ldArvKpv = Gomonth(Date(Year(Date()),Month(Date()),1),1)-1
	ldArvKpv = date()
ENDIF

Local lnResult
With odB

	If Empty(tnLepingId)
		tnLepingId = 0
	Endif

	If  .Not. Used('curSource')
		Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
	Endif
	If  .Not. Used('curValitud')
		Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
	Endif
	Create Cursor curResult (Id Int, teEnused N (1), objektid N (1))

	lnStep = 1
	Do While lnStep>0
		Do Case
			Case lnStep=1
				Do geT_nom_list
			Case lnStep=2
				Do geT_objektide_list

			Case lnStep=3
				Do arVutus
		Endcase
	Enddo
	If Used('v_arv')
		Use In v_arv
	Endif
	If Used('v_arvread')
		Use In v_arvread
	Endif
	If Used('curSource')
		Use In curSource
	Endif
	If Used('curvalitud')
		Use In curValitud
	Endif
	If Used('curResult')
		Use In curResult
	Endif
Endwith
Endproc
*
Procedure arVutus
	Local leRror, l_objekt_ids, l_nom_ids
	l_objekt_ids = ''
	l_nom_ids = ''
	
	* objektid
	SELECT curResult
	Select Distinct Id From curResult Where objektid = 1 Into Cursor recalc1
	Select recalc1
	SCAN
		l_objekt_ids = l_objekt_ids + IIF(LEN(l_objekt_ids)>0,',','') + ALLTRIM(STR(recalc1.id))
	ENDSCAN
	
	IF EMPTY(l_objekt_ids) 
		l_objekt_ids = '0'
	ENDIF

	l_objekt_ids = '(' + l_objekt_ids + ')'
	
	* noms
	
	
	Select Distinct Id From curResult Where teEnused = 1 Into Cursor recalc1
	Select recalc1
	SCAN
		l_nom_ids = l_nom_ids + IIF(LEN(l_nom_ids)>0,',','') + ALLTRIM(STR(recalc1.id))
	ENDSCAN
	IF EMPTY(l_nom_ids) 
		l_nom_ids = '0'
	ENDIF
	
	l_nom_ids = '(' + l_nom_ids + ')'
	
	
	TEXT TO lcString TEXTMERGE noshow
			select a.kpv, asutus.regkood, a.summa, objekt.kood   
			from curArved a
			inner join asutus on a.asutusid = asutus.id
			inner join rekv on rekv.id = a.rekvid			
			inner join library objekt on upper(rekv.nimetus) = upper(objekt.nimetus)			
			where a.id in (select parentid from arv1 where nomid in (SELECT ID FROM nomenklatuur where dok = 'ARV' and id in <<l_nom_ids>>))
			and objekt.id in <<l_objekt_ids>>	
	ENDTEXT
	
	l_error = SQLEXEC(gnHandle,lcString, 'tmp_query')
	IF l_error < 0 
		MESSAGEBOX('Viga',0+48,'Error')
		_cliptext = lcString
	ELSE
		SELECT tmp_query
		SET point to '.'
		Copy To kt.csv TYPE DELIMITED WITH CHARACTER ';'
		IF FILE('kt.csv')
			messagebox('File kt.csv edukalt salvestatud',0+64,'Eksport') 
		ENDIF
		
	ENDIF
	
	lnStep = 0
Endproc
*
Procedure geT_nom_list
	If Used('query1')
		Use In query1
	ENDIF
	
	TEXT TO lcString TEXTMERGE noshow

		SELECT distinct Nomenklatuur.kood, Nomenklatuur.nimetus, Nomenklatuur.id 
		FROM  Nomenklatuur 
		where dok = 'ARV'
		ORDER BY Nomenklatuur.kood	
	ENDTEXT
	l_error = SQLEXEC(gnHandle, lcString, 'query1')	
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif
	Do Form Forms\samm  To nrEsult With '1', Iif(coNfig.keEl=2, 'Teenused',  ;
		'Услуги'), Iif(coNfig.keEl=2, 'Valitud teenused', 'Выбранные услуги'), ldArvKpv
	If nrEsult=1
		ldArvKpv = gdKpv


		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where teEnused=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, teEnused) Values (query1.Id, 1)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
*


Procedure geT_objektide_list
	If Used('query1')
		Use In query1
	ENDIF
	
	TEXT TO lcString TEXTMERGE noshow

		SELECT distinct kood, nimetus, id 
		FROM  library
		where library = 'OBJEKT'
		ORDER BY kood	
	ENDTEXT
	l_error = SQLEXEC(gnHandle, lcString, 'query1')	
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif
	Do Form Forms\samm  To nrEsult With '2', Iif(coNfig.keEl=2, 'Objektid',  ;
		'Objektid'), Iif(coNfig.keEl=2, 'Valitud objektid', 'Valitud objektid'), ldArvKpv
	If nrEsult=1
		ldArvKpv = gdKpv


		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where objektid=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, objektid) Values (query1.Id, 1)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
