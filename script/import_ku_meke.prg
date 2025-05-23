l_test = .F.
gnHandleKu = 0
If (l_test)
	gnHandle = 0
	gUserId = 0
	get_test_data()
Endif

* file

lcFile = Getfile('csv','Impordi fail asukoht')

If Empty(lcFile)
	Return .F.
Endif
Create Cursor Log (objekt c(20), asutus Int, rekv Int, lausend_id Int)

Create Cursor tmpCsv (kpv d, deebet c(20), kreedit c(20), Summa c(20), objekt c(20))

* import

Append From (lcFile) Type Delimited With Character ';'

* loading objekt
Wait Window 'Objektide nimekirja laadimine...' Nowait
TEXT TO l_sql TEXTMERGE noshow
	SELECT * from library WHERE library = 'OBJEKT'
ENDTEXT

l_error = SQLEXEC(gnHandle, l_sql, 'v_objektid')

If l_error < 0
	_Cliptext = l_sql
	Messagebox('Viga p�ringus, objekt',0 + 48,'Viga')
	Set Step On
	Return .F.
Endif

*!*	l_error = SQLEXEC(gnHandleKu, l_sql, 'v_objektid_ku')

*!*	If l_error < 0
*!*		Messagebox('Viga p�ringus',0 + 48,'Viga')
*!*		Set Step On
*!*		Return .F.
*!*	Endif

*parsing
Select tmpCsv
Go Top

Scan
	Wait Window 'import, kiri nr. ' + Alltrim(Str(Recno('tmpCsv'))) + 'objekt: ' +  Alltrim(tmpCsv.objekt) + '/' + Alltrim(Str(Reccount('tmpCsv'))) Timeout 1
* find objekt
	Select v_objektid
	Locate For Alltrim(kood) = Alltrim(tmpCsv.objekt)
	If Found()
		Wait Window 'Objekt ' + Alltrim(tmpCsv.objekt) + ' leitud...' Nowait
	Else
		Messagebox('Objekt ei leidnud')
		Loop
*!*			Select v_objektid_meke
*!*			Locate For Alltrim(kood) = Alltrim(tmpCsv.objekt)
*!*			If Found()
*!*				Wait Window 'Objekt ' + Alltrim(tmpCsv.objekt) + ' ei leidnud, objekti import...'
*!*	TEXT TO l_sql TEXTMERGE NOSHOW
*!*							INSERT INTO library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud)
*!*							values (1, '<<v_objekt_meke.kood>>','<<v_objekt_meke.nimetus>>','OBJEKT',<<v_objekt_meke.tun1>>,
*!*							<<v_objekt_meke.tun2>>,<<v_objekt_meke.tun3>>,<<v_objekt_meke.tun4>>,<<v_objekt_meke.tun5>>,'<<v_objekt_meke.muud>>')

*!*	ENDTEXT

*!*				l_error = SQLEXEC(gnHandleKu, l_sql)

*!*				If l_error < 0
*!*					Messagebox('Viga p�ringus',0 + 48,'Viga')
*!*					Set Step On
*!*					Return .F.
*!*				Else
*!*					Insert Into v_objektid_ku (kood, nimetus, tun1, tun2, tun3, tun4, tun5, muud) ;
*!*						VALUES (v_objekt_meke.kood, v_objekt_meke.nimetus, v_objekt_meke.tun1, v_objekt_meke.tun2, v_objekt_meke.tun3, v_objekt_meke.tun4, ;
*!*						v_objekt_meke.tun5, v_objekt_meke.muud)

*!*					Wait Window  'Objekt ' + Alltrim(tmpCsv.objekt) + ' ei leidnud, objekti import... edu'
*!*				Endif
*!*			Endif
	Endif
* find rekv
	Wait Window  'Rekv... ' + Alltrim(v_objektid.nimetus)  Nowait

TEXT TO l_sql textmerge NOSHOW
	SELECT id FROM rekv WHERE nimetus ilike '%<<v_objektid.nimetus>>%'
ENDTEXT
	l_error = SQLEXEC(gnHandle, l_sql, 'v_rekv')

	If l_error < 0 Or Reccount('v_rekv') = 0
		_Cliptext = l_sql
		Messagebox('Viga p�ringus v�i puudub asutus',0 + 48,'Viga')

		Loop
	Endif
	Select v_rekv

* find asutus
	Wait Window  'Asutus... ' + Alltrim(v_objektid.nimetus)  Nowait

TEXT TO l_sql TEXTMERGE noshow
	SELECT id FROM asutus WHERE nimetus ilike '%<<v_objektid.nimetus>>%' order by id desc limit 1
ENDTEXT

	l_error = SQLEXEC(gnHandle, l_sql, 'v_asutus')

	If l_error < 0
		_Cliptext = l_sql
		Messagebox('Viga p�ringus, asutus',0 + 48,'Viga')
		Set Step On
		Loop
	Endif

	If Reccount('v_asutus') = 0
		Wait Window  'Asutus... puudub, import... ' + Alltrim(v_objektid.nimetus)  Nowait

* create new asutus
TEXT TO l_sql TEXTMERGE noshow
		INSERT INTO asutus (rekvid, regkood, nimetus, omvorm, aadress)
			VALUES  (<<STR(gRekv)>>,'<<ALLTRIM(tmpCsv.objekt)>>','<<ALLTRIM(v_objektid.nimetus)>>','KU','<<ALLTRIM(v_objektid.nimetus)>>') returning id
ENDTEXT
		l_error = SQLEXEC(gnHandle, l_sql, 'v_asutus')

		If l_error < 0
			_Cliptext = l_sql
			Messagebox('Viga p�ringus, uus asutus',0 + 48,'Viga')
			Set Step On
			Loop
		Endif
		Wait Window  'Asutus... puudub, import...�nnestus ' + Alltrim(v_objektid.nimetus)  Nowait

	Endif


* kontrol
*!*	TEXT TO l_sql TEXTMERGE noshow
*!*		SELECT id FROM journal WHERE selg = 'Tihhomirova' AND kpv = '<<Dtoc(tmpCsv.kpv,1)>>'::Date and asutusid = <<v_asutus.id>> and muud = 'Import'
*!*	ENDTEXT
*!*		l_error = SQLEXEC(gnHandle, l_sql, 'v_lausend')

*!*		If l_error < 0
*!*			_Cliptext = l_sql
*!*			Messagebox('Viga p�ringus, journal',0 + 48,'Viga')
*!*			Set Step On
*!*			Loop
*!*		Endif

*!*		If Reccount('v_lausend') > 0
*!*			l_id = v_lausend.Id

*!*	TEXT TO l_sql TEXTMERGE noshow
*!*				DELETE FROM journal1 WHERE parentid = <<l_id>>
*!*	ENDTEXT
*!*			l_error = SQLEXEC(gnHandle, l_sql, 'v_lausend')

*!*			If l_error < 0
*!*				_Cliptext = l_sql
*!*				Messagebox('Viga p�ringus, delete journal1',0 + 48,'Viga')
*!*				Set Step On
*!*				Loop
*!*			Endif

*!*		Else
*!*			l_id = 0
*!*		Endif
l_id = 0

* lausendi salvestamine
	Wait Window  'Lausend... '  Nowait
TEXT To l_sql textmerge Noshow
			Select sp_salvesta_journal(<<l_id>>, <<v_rekv.Id>>, <<gUserId>>, '<<Dtoc(tmpCsv.kpv,1)>>'::Date, <<v_asutus.id>>, 'Tihhomirova', '', 'Import', 0) as id
ENDTEXT
	l_error = SQLEXEC(gnHandle, l_sql, 'v_lausend')

	If l_error < 0
		_Cliptext = l_sql
		Messagebox('Viga p�ringus, new lausend',0 + 48,'Viga')
		Set Step On
		Loop
	Endif

TEXT To l_sql textmerge Noshow
			Select sp_salvesta_journal1(0, <<v_lausend.Id>>, <<STRTRAN(tmpCsv.summa, ',', '.')>>,
				''::varchar, 'Import'::text, ''::varchar, ''::varchar, ''::varchar,
				''::varchar, ''::varchar,'<<tmpCsv.deebet>>'::varchar,'800699'::varchar,
				'<<tmpCsv.kreedit>>'::varchar,'800699'::varchar,'EUR'::varchar,1,<<STRTRAN(tmpCsv.summa, ',', '.')>>,''::varchar,''::varchar) as id
ENDTEXT
	l_error = SQLEXEC(gnHandle, l_sql, 'v_lausend1')

	If l_error < 0
		_Cliptext = l_sql
		Messagebox('Viga p�ringus, new lausend, kiri',0 + 48,'Viga')
		Set Step On
		Loop
	Endif


	Wait Window  'Lausend... �nnestus'  Nowait
	Insert Into Log(objekt, asutus, rekv, lausend_id) Values (tmpCsv.objekt, v_asutus.Id, v_rekv.Id, v_lausend.Id)


Endscan

* finish

If (l_test)
	=SQLDISCONNECT(gnHandle)
*	=SQLDISCONNECT(gnHandleKu)
Endif

Function get_test_data
	gnHandle = SQLConnect('meke')
	If gnHandle < 0
		Messagebox('Viga �henduses')
		Return .F.
	Endif

	gnHandleKu = SQLConnect('KU')
	If gnHandle < 0
		Messagebox('Viga �henduses (KU)')
		Return .F.
	Endif
	gUserId = 1
Endfunc
