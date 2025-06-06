
Parameter is_test
*is_test = .F.
Set Step On
l_count = 0

* for test
If Type('gnHandle') = 'U'
	is_test = .T.
	gnHandle = SQLConnect('KU')
	cOdbc = 'meke'
	cKasutaja = 'vlad'
	cPass = '490710'
	l_kpv1 = Date(2018,05,01)
	l_kpv2 = Date(2018,05,31)
	gUserId = 1
Else
	cKasutaja = oDb.login
	cPass = oDb.Pass
	cOdbc = oDb.ODBC
	l_kpv1 = fltrArved.kpv1
	l_kpv2 = fltrArved.kpv2
Endif

WAIT WINDOW 'connectiong..' nowait
* conncetion with MEKE
gnHandleMeke = SQLConnect(cOdbc,cKasutaja, cPass)

If gnHandleMeke < 0
	WAIT WINDOW 'Viga, ei saa uhendada MEKE andmebaasiga'
*	=Messagebox('Viga, ei saa uhendada MEKE andmebaasiga',0+16,'Viga')
	Return .F.
Endif

WAIT WINDOW 'connectiong..ok' nowait

* parameters
TEXT TO lcParams TEXTMERGE noshow
	select array_to_string(array_agg(quote_literal(ltrim(rtrim(nimetus)))),',') as params from rekv
ENDTEXT
l_error = SQLEXEC(gnHandle,lcParams,'qryRekv')
If l_error < 1
	WAIT WINDOW 'Viga paringus' + lcParams
*	Messagebox('Viga paringus' + lcParams,0+16,'Viga')
	_Cliptext = lcParams
	Return .F.
Endif


* Select arved from MEKE
*!*	l_kpv1 = 'date(' + STR(YEAR(l_kpv1),4) + ','+ STR(MONTH(l_kpv1),2) + ',' + STR(DAY(l_kpv1)) + ')'
*!*	l_kpv2 = 'date(' + STR(YEAR(l_kpv2),4) + ','+ STR(MONTH(l_kpv2),2) + ',' + STR(DAY(l_kpv2)) + ')'

TEXT TO lcSql TEXTMERGE noshow
	SELECT id, number, kpv, UPPER(LTRIM(RTRIM(asutus)))::varchar(250) as asutus
	FROM curArved
	WHERE LTRIM(RTRIM(upper(asutus))) in (<<qryRekv.params>>)
	AND kpv >= quote_literal(<<DTOC(l_kpv1,1)>>)::date
	and kpv <= quote_literal(<<DTOC(l_kpv2,1)>>)::date

ENDTEXT

l_error = SQLEXEC(gnHandleMeke,lcSql,'qryArved')
If l_error < 1
	WAIT WINDOW 'Viga paringus' + lcSql
*	Messagebox('Viga paringus' + lcSql,0+16,'Viga')
	_Cliptext = lcSql
	Return .F.
Endif

Select qryArved
Scan
	Wait Window 'Import arve nr. ' + Alltrim(qryArved.Number) + ','+Alltrim(qryArved.asutus) + '..' Nowait


* prepare new arve

* 1. rekvid

TEXT TO lcSql TEXTMERGE NOSHOW
	SELECT r.id,(select l.id
			from dokprop d
			inner join library l on l.id = d.parentid
			where l.kood = 'ARV'
			AND l.REKVID = r.id order by l.id desc limit 1) as doklausid,
	(select id from asutus where regkood = '10337120' limit 1) as asutusid
	FROM rekv r WHERE UPPER(LTRIM(RTRIM(r.nimetus))) = '<<UPPER(ALLTRIM(qryArved.asutus))>>'
ENDTEXT

	l_error = SQLEXEC(gnHandle,lcSql,'qryRekv')
	If l_error < 1
		WAIT WINDOW 'Viga paringus' + lcSql
*		Messagebox('Viga paringus' + lcSql,0+16,'Viga')
		_Cliptext = lcSql
		Return .F.
	Endif
	If Reccount('qryRekv') < 1
		Continue
	Endif

* check if arve is available

TEXT TO lcSql TEXTMERGE noshow
	SELECT count(id)::integer as kontrol FROM arv WHERE number = '<<Alltrim(qryArved.Number)>>' AND asutusid = <<qryRekv.asutusid>>
ENDTEXT
	l_error = SQLEXEC(gnHandle,lcSql,'qryKontrol')
	If l_error < 1
		WAIT WINDOW 'Viga paringus' + lcSql
*		Messagebox('Viga paringus' + lcSql,0+16,'Viga')
		_Cliptext = lcSql
		Return .F.
	Endif

	If qryKontrol.kontrol =  0



TEXT TO lcSql TEXTMERGE NOSHOW
	SELECT * from arv WHERE id = <<qryArved.id>>
ENDTEXT

		l_error = SQLEXEC(gnHandleMeke,lcSql,'qryArv')
		If l_error < 1
			WAIT WINDOW 'Viga paringus'
*			Messagebox('Viga paringus',0+16,'Viga')
			_Cliptext = lcSql
			Return .F.
		Endif

TEXT TO lcSql TEXTMERGE noshow
	SELECT sp_salvesta_arv(0,<<qryRekv.id>>,<<gUserId>>,<<0>>,<<IIF(ISNULL(qryRekv.doklausid),0,qryRekv.doklausid)>>,<<1>>,<<0>>,'<<qryArv.number>>',
	'<<DTOC(qryArv.kpv,1)>>'::date,<<qryRekv.asutusid>>,<<0>>,'<<ALLTRIM(qryArv.lisa)>>','<<DTOC(qryArv.tahtaeg,1)>>'::date,
	 <<qryArv.kbmta>>,<<qryArv.kbm>>,<<qryArv.summa>>,null,null,'<<ALLTRIM(qryArv.muud)>>',<<qryArv.jaak>>,<<0>>) as id
ENDTEXT

		l_error = SQLEXEC(gnHandle,lcSql,'qryArvId')
		If l_error < 1
			WAIT WINDOW 'Viga paringus'
*			Messagebox('Viga paringus',0+16,'Viga')
			_Cliptext = lcSql
			Return .F.
		Endif

* select arv1



TEXT TO lcSql TEXTMERGE NOSHOW
	SELECT arv1.*, n.kood, n.nimetus
		from arv1
		INNER JOIN nomenklatuur n ON arv1.nomid = n.id
		WHERE parentid = <<qryArved.id>>
ENDTEXT

		l_error = SQLEXEC(gnHandleMeke,lcSql,'qryArv1')
		If l_error < 1
		WAIT WINDOW 'Viga paringus'+ lcSql 
*			Messagebox('Viga paringus' + lcSql,0+16,'Viga')
			_Cliptext = lcSql
			Exit
			Return .F.
		Endif
		Scan
* find nomid
TEXT TO lcSql TEXTMERGE noshow
				SELECT id FROM nomenklatuur
					WHERE LTRIM(RTRIM(kood)) = '<<alltrim(qryArv1.kood))>>'
					and rekvid = <<qryRekv.id>>
ENDTEXT
			l_error = SQLEXEC(gnHandle,lcSql,'qryNomId')
			If l_error < 1
			WAIT WINDOW 'Viga paringus'+ lcSql 
*				Messagebox('Viga paringus',0+16,'Viga')
				_Cliptext = lcSql
				Exit
				Return .F.
			Endif
			If Reccount('qryNomId') < 1
				Wait Window 'Importing nomns ...' Nowait
* new nom
TEXT TO lcSql TEXTMERGE noshow
						INSERT INTO nomenklatuur  (rekvid, kood, nimetus, dok)
							values (<<qryRekv.id>>,'<<qryArv1.kood>>','<<qryArv1.nimetus>>','ARV')
							returning id
ENDTEXT
				l_error = SQLEXEC(gnHandle,lcSql,'qryNomId')
				If l_error < 1
				WAIT WINDOW 'Viga paringus'+ lcSql 
*					Messagebox('Viga paringus' ,0+16,'Viga')
					_Cliptext = lcSql
					Exit
					Return .F.
				Endif
				Wait Window 'Importing nomns ...success ' + Alltrim(Str(qryNomId.Id)) Timeout 2

			Endif

TEXT TO lcSql TEXTMERGE noshow
			Select sp_salvesta_arv1(0,<<qryArvId.Id>>,<<qryNomId.Id>>,<<qryArv1.kogus>>,<<qryArv1.hind>>,<<qryArv1.soodus>>,
			<<qryArv1.kbm>>,<<qryArv1.maha>>,<<qryArv1.Summa>>,'<<qryArv1.muud>>','<<qryArv1.kood1>>','<<qryArv1.kood2>>',
			'<<qryArv1.kood3>>','<<qryArv1.kood4>>','<<qryArv1.kood5>>','<<qryArv1.konto>>','<<qryArv1.tp>>',
			<<qryArv1.kbmta>>,<<0>>,'<<qryArv1.tunnus>>','EUR',1,'<<qryArv1.proj>>')

ENDTEXT


			l_error = SQLEXEC(gnHandle,lcSql,'qryArv1Id')
			If l_error < 1
			WAIT WINDOW 'Viga paringus'+ lcSql 
*				Messagebox('Viga paringus',0+16,'Viga')
				_Cliptext = lcSql
				Exit
				Return .F.
			Endif


		Endscan


		If Iif(Isnull(qryRekv.doklausid),0,qryRekv.doklausid) > 0 Then
			Wait Window 'Import arve nr. ' + Alltrim(qryArved.Number) + '..konteerimine' Nowait


TEXT TO lcsql TEXTMERGE noshow
			SELECT GEN_LAUSEND_ARV(<<qryArvId.Id>>)
ENDTEXT


			l_error = SQLEXEC(gnHandle,lcSql,'qryLausend')
			If l_error < 1
			WAIT WINDOW 'Viga paringus'+ lcSql 
*				Messagebox('Viga paringus',0+16,'Viga')
				_Cliptext = lcSql
				Exit
				Return .F.
			Endif
		Endif


		If Reccount('qryArv1Id') > 0 And  Reccount('qryArvId') > 0
			Wait Window 'Import arve nr. ' + Alltrim(qryArved.Number) + '..success' Timeout 2
		Else
			Messagebox('Import not success',0+16,'Error')
			Set Step On
			Exit
		Endif
		l_count = l_count + 1
	Else
		Wait Window 'Import arve nr. ' + Alltrim(qryArved.Number) + ','+Alltrim(qryArved.asutus) + '.. juba tehtud' Timeout 2
	Endif
Endscan


If (is_test)
	=SQLDISCONNECT(gnHandle)
Endif
=SQLDISCONNECT(gnHandleMeke)

=Messagebox('Kokku importeeritud:' + Alltrim(Str(l_count)) + ' arved',0+64,'Tulemus')
