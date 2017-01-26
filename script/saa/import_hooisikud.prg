Create Cursor qryAsutuseIndeks (asutusSourceId Int, asutusDestId Int)

gnHandleSource = SQLConnect('saakoopia')
If gnHandleSource < 0
	Messagebox('Viga, gnHandleSource')
	Return
Endif


gnHandleDest = SQLConnect('NarvaLvPg')
If gnHandleDest < 0
	Messagebox('Viga, gnHandleDest')
	Return
Endif

* asutused

lcString = "select * from asutus where id in (select isikid from hooleping) or id in (select distinct hooldekoduid from hooleping) or id in (select distinct omavalitsusid from hooleping)"
lnError = SQLEXEC(gnHandleSource,lcString,'qryAsutus')
If lnError < 0
	_Cliptext = lcString
	Messagebox('Viga')
Endif

If lnError > 0
	lcString = "select * from hooleping"
	lnError = SQLEXEC(gnHandleSource,lcString,'qryHooleping')
	If lnError < 0
		_Cliptext = lcString
		Messagebox('Viga')
	Endif
Endif
If lnError > 0
	Select qryAsutus
	Scan
		Wait Window 'Kooperimine :'+ALLTRIM(qryAsutus.nimetus) Nowait
		lcString = "select id from asutus where regkood = '"+Alltrim(qryAsutus.regkood)+"' order by id desc limit 1"
		lnError = SQLEXEC(gnHandleDest,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
		If Reccount('tmpId') = 0
			lnId = 0
		Else
			lnId = tmpId.Id
		Endif

		lcString = "select sp_salvesta_asutus("+Str(lnId)+","+Alltrim(Str(qryAsutus.rekvid))+",'"+Alltrim(qryAsutus.regkood)+"','"+;
			ALLTRIM(qryAsutus.nimetus)+"','"+Alltrim(qryAsutus.omvorm)+"','"+Alltrim(qryAsutus.aadress)+"','"+;
			ALLTRIM(qryAsutus.kontakt)+"','"+Alltrim(qryAsutus.tel)+"','"+Alltrim(qryAsutus.faks)+"','"+;
			ALLTRIM(qryAsutus.email)+"','"+Alltrim(Iif(Isnull(qryAsutus.muud),Space(1),qryAsutus.muud))+"','"+;
			ALLTRIM(qryAsutus.tp)+"')"

		lnError = SQLEXEC(gnHandleDest,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
		Insert Into qryAsutuseIndeks (asutusSourceId, asutusDestId) Values (qryAsutus.Id,tmpId.sp_salvesta_asutus)
	ENDSCAN
	lcString = "delete from hooleping"
	lnError = SQLEXEC(gnHandleDest,lcString)
	IF lnError < 0
		SET STEP ON 
	endif
	Select qryHooLeping
	Scan
		Wait Window 'Hooleping:'+Alltrim(Str(Recno('qryHooLeping')))+'/'+Alltrim(Str(Reccount('qryHooLeping'))) Nowait
		Select qryAsutuseIndeks
		Locate For asutusSourceId = qryHooLeping.isikId
		If !Found()
			Set Step On
			Exit
		Endif

		lnIsikId = qryAsutuseIndeks.asutusDestId
		Locate For asutusSourceId = qryHooLeping.hooldekoduid
		If !Found()
			Set Step On
			Exit
		Endif

		lnHooldekoduId = qryAsutuseIndeks.asutusDestId
		Locate For asutusSourceId = qryHooLeping.OmavalitsusId
		If !Found()
			lnKovId = 0
		else	
			lnKOVId = qryAsutuseIndeks.asutusDestId		
		Endif

		lcString = "select sp_salvesta_hooleping(0,64,"+Alltrim(Str(lnIsikId))+","+Alltrim(Str(lnHooldekoduId))+",'"+;
			ALLTRIM(qryHooLeping.Number)+"',"+Alltrim(Str(lnKOVId))+",DATE(2013,01,01),DATE(2013,12,31),"+;
			ALLTRIM(STR(qryHooleping.summa,16,2))+","+ALLTRIM(STR(qryHooleping.osa,16,2))+",'"+;
			ALLTRIM(IIF(ISNULL(qryHooleping.muud),SPACE(1),qryHooleping.muud))+"')"

		lnError = SQLEXEC(gnHandleDest,lcString)
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif


	Endscan
Endif


=SQLDISCONNECT(gnHandleSource)
=SQLDISCONNECT(gnHandleDest)
