If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*gnhandle = sqlconnect ('NARVA','vladislav','490710')
*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
gversia = 'MSSQL'
grekv = 1

grekv = 1
gnHandle = 1
gversia = 'VFP'
Local lError

If v_account.admin < 1
	Return .T.
Endif
If !Used ('key')
	Use Key In 0
Endif
Select Key
lnFields = Afields (aObjekt)
Create Cursor qryKey From Array aObjekt
Select qryKey
Append From Dbf ('key')
Use In Key
=secure('OFF')

Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
			If File (lcdata)
				Open Data (lcdata)
*!*					lcdataproc = lcdefault+'\tmp\0909proc.prn'
*!*					If file (lcdataproc)
*!*						Append proc from (lcdataproc) overwrite
*!*					Endif
*!*					Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
				Set Default To (lcdefault)
			Endif
		Endscan
		Use In qryKey
	Case gversia = 'MSSQL'
*		=sqlexec (gnHandle,'begin transaction')
		lError = _alter_mssql ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
*!*			If lError = .f.
*!*				=sqlexec (gnHandle,'rollback')
*!*			Else
*!*				=sqlexec (gnHandle,'commit')
*!*			Endif
Endcase

*!*	If lError = .f.
*!*		Messagebox ('Viga')
*!*	Endif
If gversia <> 'VFP'
	=sqldisconnect (gnHandle)
*!*	else
*!*		set data to buhdata5
*!*		close data
Endif
Return lError

Function _alter_vfp

*!*		=DBSETPROP('MK1','TABLE','DeleteTrigger','TRIGD_MK()')

	If !Used('menumodul')
		Use menumodul In 0
	Endif
	If !Used('menupohi')
		Use menupohi In 0 Order Id
	Endif
	If !Used('menuisik')
		Use menuisik In 0
	Endif
	Select menupohi
	Scan For Upper(Pad) = 'MK1'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan

	Scan For Upper(Pad) = 'KORDERID'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan

	Scan For Upper(Pad) = 'ARVED'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan

	Scan For Upper(Pad) = 'PUUDUMISED'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'TOOGRAAFIK'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'PALKJAAK'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'ASUTUSED'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'NOMENKLATUUR'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'POHIVARA'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'PVGRUPPID'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'DOK'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'GRUPPID'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'LADUARVED'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'LADUJAAK'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan
	Scan For Upper(Pad) = 'KULUTAITM'
		Select menumodul

		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
		Endif
		Select menuisik
		Locate For parentid =  menupohi.Id
		If !Found()
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
		Endif
	Endscan

	Use In menuisik
	Use In menumodul
	Use In menupohi

	If !Used('korder2')
		Use korder2 In 0
	Endif
	Select korder2
	lnObj = Afields(aObj)
	Use In korder2
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('TUNNUS'))
	If lnElement < 1
		Alter Table korder2 Add Column tunnus c(20) Not Null Default Space(1)
	Endif
	If Used('korder2')
		Use In korder2
	Endif


	If !Used('leping2')
		Use leping2 In 0
	Endif
	Select leping2
	lnObj = Afields(aObj)
	Use In leping2
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('KBM'))
	If lnElement < 1
		Alter Table leping2 Add Column kbm Int Not Null Default 1
	Endif
	If Used('leping2')
		Use In leping2
	Endif

	If !Used('palk_lib')
		Use palk_lib In 0
	Endif
	Select palk_lib
	lnFields = Afields(aObj)
	Use In palk_lib
	If lnFields < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('ELATIS'))
	If lnElement < 1
		Alter Table palk_lib Add Column elatis Int Not Null Default 0
	Endif
	lnElement = Ascan(aObj,Upper('TULULIIK'))
	If lnElement < 1
		Alter Table palk_lib Add Column tululiik c(6) Not Null Default Space(1)
	Endif

	If Used('palk_lib')
		Use In palk_lib
	Endif

	If !Used('tooleping')
		Use tooleping In 0
	Endif
	Select tooleping
	lnFields = Afields(aObj)
	Use In tooleping
	If lnFields < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('TOEND'))
	If lnElement < 1
		Alter Table tooleping Add Column toend Date Not Null Default {}
	Endif

	lnElement = Ascan(aObj,Upper('RESIDENT'))
	If lnElement < 1
		Alter Table tooleping Add Column resident Int Not Null Default 1
	Endif

	lnElement = Ascan(aObj,Upper('RIIK'))
	If lnElement < 1
		Alter Table tooleping Add Column riik c(3) Not Null Default Space(1)
	Endif

	If Used('tooleping')
		Use In tooleping
	Endif

	If !Used('palk_taabel1')
		Use palk_taabel1 In 0
	Endif
	Select palk_taabel1
	lnFields = Afields(aObj)
	Use In palk_taabel1
	If lnFields < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('ULEAJATOO'))
	If lnElement < 1
		Alter Table palk_taabel1 Add Column uleajatoo Int Not Null Default 0
	Endif

	If Used('palk_taabel1')
		Use In palk_taabel1
	Endif

	lnDbObj = Adbobjects(laView,'VIEW')
	If lnDbObj < 1
		Return .F.
	ENDIF
	

	Create Sql View curkassakuludetaitmine_;
	AS;
	 SELECT kuu, aasta, curjournal_.rekvid, sum(summa) AS summa, curjournal_.kood5 AS kood, space(1) AS eelarve,; 
	 	curjournal_.kood1 AS tegev, curjournal_.tunnus AS tun   ;
	 	FROM curjournal_   JOIN kassakulud ON trim(deebet) like rtrim(kassakulud.kood); 
	 	inner  JOIN kassakontod ON rtrim(curjournal_.kreedit) like rtrim(kassakontod.kood);
	 	GROUP BY aasta, kuu, curjournal_.rekvid, curjournal_.deebet, curjournal_.kood1, curjournal_.tunnus,;
	 	curjournal_.kood5  
	 		
	lnElement = Ascan(laView,Upper('curladuJaak_'))
	If lnElement > 0
		Drop View  curladuJaak_
	Endif

	Create Sql View curladuJaak_;
	AS;
	SELECT ladu_jaak.rekvid, ladu_jaak.hind, ladu_jaak.jaak as jaak, ladu_jaak.kpv, nomenklatuur.kood, ;
		nomenklatuur.nimetus,  nomenklatuur.uhik, grupp.nimetus as grupp, nomenklatuur.kogus as minjaak ;
		FROM ladu_jaak  INNER JOIN nomenklatuur ON  ladu_jaak.nomid = nomenklatuur.id  ;
		inner join ladu_grupp on ladu_grupp.nomId = nomenklatuur.id ;
		inner join library grupp on grupp.id = ladu_grupp.parentid 


	lnElement = Ascan(laView,Upper('curPohivara_'))
	If lnElement > 0
		Drop View  curPohivara_
	Endif

	Create Sql View curPohivara_;
		AS;
		SELECT Library.Id, Library.kood, Library.nimetus, Library.rekvid,;
		Pv_kaart.vastisikid, Asutus.nimetus As vastisik, Pv_kaart.algkulum,;
		Pv_kaart.soetmaks, Pv_kaart.soetkpv, Grupp.nimetus As Grupp,;
		Pv_kaart.konto, Pv_kaart.gruppid, Pv_kaart.tunnus, Pv_kaart.mahakantud,;
		IIF(Pv_kaart.tunnus=1,"Pohivara","Vaikevahendid") As liik, Left(Mline(Pv_kaart.muud,1),254) As rentnik;
		FROM ;
		buhdata5!Library ;
		INNER Join buhdata5!Pv_kaart ;
		ON  Library.Id = Pv_kaart.parentid ;
		INNER Join buhdata5!Asutus ;
		ON  Pv_kaart.vastisikid = Asutus.Id ;
		INNER Join buhdata5!Library Grupp ;
		ON  Pv_kaart.gruppid = Grupp.Id


	lnElement = Ascan(laView,Upper('curKulum_'))
	If lnElement > 0
		Drop View  curKulum_
	Endif


	Create Sql View curKulum_;
		AS;
		SELECT Library.Id, pv_oper.liik, pv_oper.Summa, pv_oper.kpv, Library.rekvid,;
		Grupp.nimetus As Grupp, ;
		nomenklatuur.kood, nomenklatuur.nimetus As opernimi,;
		Pv_kaart.soetmaks, Pv_kaart.soetkpv,;
		Pv_kaart.kulum, Pv_kaart.algkulum,;
		Pv_kaart.gruppid, Pv_kaart.konto, ;
		Pv_kaart.tunnus, Asutus.nimetus As vastisik,;
		library.kood As ivnum,     Library.kood As invnum,;
		library.nimetus As pohivara;
		FROM Library INNER Join  pv_oper On   Library.Id = pv_oper.parentid ;
		INNER Join   Pv_kaart On Library.Id = Pv_kaart.parentid ;
		INNER Join Library Grupp On    Pv_kaart.gruppid = Grupp.Id ;
		INNER Join Asutus On Pv_kaart.vastisikid = Asutus.Id ;
		INNER Join nomenklatuur On pv_oper.nomId = nomenklatuur.Id


	lnElement = Ascan(laView,Upper('cursaldo'))
	If lnElement > 0
		Drop View  cursaldo
	Endif

	Create Sql View cursaldo As  ;
		Select Date(2000,01,01) As kpv, kontoinf.rekvid, Library.kood As konto, ;
		IIF( kontoinf.algsaldo >= 0, Val(Str(kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As deebet, ;
		IIF( kontoinf.algsaldo < 0 , Val(Str(-1 * kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As kreedit, ;
		1 As OPT, 000000000 As asutusid  From Library INNER Join kontoinf On Library.Id = kontoinf.parentid ;
		where algsaldo <> 0;
		union All  ;
		Select Date(Iif(Empty(aasta),1999,aasta), Iif(Empty(kuu),1,kuu),1) As kpv, rekvid, konto,  ;
		VAL(Str(dbkaibed,12,4))  As deebet, Val(Str(krkaibed,12,4)) As kreedit, 3 As OPT, asutusid  ;
		from saldo  Where saldo.asutusid > 0 And !Empty(kuu) And !Empty(aasta);
		AND dbkaibed <> 0 And krkaibed <> 0;
		union All  ;
		SELECT kpv, rekvid, deebet As konto, Val(Str(Summa,12,4)) As deebet,  Val(Str(000000000.0000,12,4)) As kreedit,;
		4 As OPT, asutusid  From curJournal_  ;
		union All  ;
		SELECT kpv, rekvid, kreedit As konto, ;
		VAL(Str(000000000.0000,12,4)) As deebet, Val(Str(Summa,12,4))  As kreedit, 4 As OPT, asutusid ;
		from curJournal_


	lnElement = Ascan(laView,Upper('cursaldoasutus'))
	If lnElement > 0
		Drop View  cursaldoasutus
	Endif

	Create Sql View cursaldoasutus As  ;
		SELECT Date(2000, 1, 1) As kpv, subkonto.rekvid, Library.kood As konto,;
		IIF(subkonto.algsaldo >= 0, Val(Str(subkonto.algsaldo,12,2)),Val(Str(0,12,2))) As deebet,;
		IIF(subkonto.algsaldo < 0, - 1 * Val(Str(subkonto.algsaldo,12,2)),Val(Str(0,12,2))) As kreedit,;
		2 As OPT, subkonto.asutusid   From Library  INNER Join subkonto On Library.Id = subkonto.kontoid ;
		WHERE algsaldo <> 0;
		UNION All  ;
		SELECT Iif(Empty(saldo.aasta),{},Date(saldo.aasta, saldo.kuu, 1)) As kpv, saldo.rekvid, saldo.konto,;
		VAL(Str(saldo.dbkaibed,12,2)) As deebet,;
		VAL(Str(saldo.krkaibed,12,2)) As kreedit, 3 As OPT, saldo.asutusid   ;
		FROM saldo  Where saldo.asutusid > 0 And !Empty(kuu) And !Empty(aasta);
		AND dbkaibed <> 0 And krkaibed <> 0;
		UNION All  ;
		SELECT kpv, rekvid, deebet As konto, Val(Str(Summa,12,2)) As deebet,;
		VAL(Str(0,12,2)) As kreedit, 4 As OPT, asutusid   From curJournal_;
		UNION All  ;
		SELECT kpv, rekvid, kreedit As konto, Val(Str(0,12,2)) As deebet, Val(Str(Summa,12,2)) As kreedit, 4 As OPT, asutusid ;
		FROM curJournal_

	lnElement = Ascan(laView,Upper('qryKassaTulutaitm_'))
	If lnElement > 0
		Drop View  qryKassaTulutaitm_
	Endif


	Create Sql View qryKassaTulutaitm_  As ;
		SELECT  curJournal_.kpv, curJournal_.rekvid, rekv.nimetus, curJournal_.tunnus As tun, Summa, ;
		curJournal_.kood5 As kood,;
		space(1) As eelarve, curJournal_.kood1 As tegev;
		fROM curJournal_  INNER  Join kassatulud On Trim(curJournal_.kreedit) Like Trim(kassatulud.kood)+'%';
		INNER Join kassakontod On Trim(curJournal_.deebet) Like Trim(kassakontod.kood)+'%';
		JOIN rekv On curJournal_.rekvid = rekv.Id

	lError = DBSetProp('qryKassaTulutaitm_ ','View','FetchAsNeeded',.T.)

	lnElement = Ascan(laView,Upper('CURPALKOPER_'))
	If lnElement > 0
		Drop View  curpalkoper_
	Endif

	Create Sql View curpalkoper_;
		AS;
		SELECT  Library.tun1, Library.tun2, Library.tun3, Library.tun4, Library.tun5, ;
		library.nimetus, Asutus.nimetus As isik, Asutus.Id As isikId,;
		iif(Isnull(journalid.Number),000000000,journalid.Number) As journalid, palk_oper.journal1Id, palk_oper.kpv,;
		palk_oper.Summa, palk_oper.Id, palk_oper.libId, palk_oper.rekvid, tooleping.pank, tooleping.aa, ;
		iif (liik = 1,'+', Iif (liik = 2 Or liik = 6 Or liik = 4 Or liik = 8, '-', ;
		iif (liik = 7 And asutusest = 0,'-', '%'))) As liik,;
		iif (tund = 1, 'KOIK', ;
		iif (tund = 2, 'PAEV', Iif (tund = 3, 'OHT', Iif (tund = 4,'OO',;
		iif (tund = 5, 'PUHKUS', 'PUHA'))))) As tund, ;
		iif (maks = 1, 'JAH', 'EI ') As maks ;
		FROM buhdata5!palk_oper ;
		INNER Join    buhdata5!Library On  palk_oper.libId = Library.Id  ;
		INNER Join buhdata5!palk_lib On palk_lib.parentid = Library.Id  ;
		INNER Join buhdata5!tooleping On palk_oper.Lepingid = tooleping.Id  ;
		INNER Join buhdata5!Asutus On tooleping.parentid = Asutus.Id;
		LEFT Outer Join buhdata5!journalid On palk_oper.journalid = journalid.journalid

	lError = DBSetProp('curPalkOper_','View','FetchAsNeeded',.T.)

	lnElement = Ascan(laView,Upper('CURTSD_'))
	If lnElement > 0
		Drop View curtsd_
	Endif

	Create Sql View curtsd_;
		as;
		Select  palk_oper.Id, palk_oper.rekvid, Asutus.regkood As isikukood, Asutus.nimetus As isik,;
		tooleping.pohikoht As pohikoht, tooleping.osakondId As tooleping, tooleping.resident As resident,;
		tooleping.riik As riik, tooleping.toend As toend, tooleping.osakondId As osakondId, ;
		palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, ;
		palk_oper.kpv, palk_oper.Summa, Str(palk_lib.liik,1)+'-'+Str(palk_kaart.tulumaar,2) As Form,;
		iif (palk_lib.liik = 1,  palk_oper.Summa, 000000000.00 ) As palk26,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '02', palk_oper.Summa, 000000000.00) As palk_02,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '03', palk_oper.Summa, 000000000.00) As palk_03,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '04', palk_oper.Summa, 000000000.00) As palk_04,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '05', palk_oper.Summa, 000000000.00) As palk_05,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '06', palk_oper.Summa, 000000000.00) As palk_06,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '07', palk_oper.Summa, 000000000.00) As palk_07,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '08', palk_oper.Summa, 000000000.00) As palk_08,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '09', palk_oper.Summa, 000000000.00) As palk_09,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '10', palk_oper.Summa, 000000000.00) As palk_10,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '11', palk_oper.Summa, 000000000.00) As palk_11,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '12', palk_oper.Summa, 000000000.00) As palk_12,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '13', palk_oper.Summa, 000000000.00) As palk_13,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '14', palk_oper.Summa, 000000000.00) As palk_14,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '15', palk_oper.Summa, 000000000.00) As palk_15,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '16', palk_oper.Summa, 000000000.00) As palk_16,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '17', palk_oper.Summa, 000000000.00) As palk_17,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '18', palk_oper.Summa, 000000000.00) As palk_18,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '19', palk_oper.Summa, 000000000.00) As palk_19,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '19a', palk_oper.Summa, 000000000.00) As palk_19a,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '20', palk_oper.Summa, 000000000.00) As palk_20,;
		iif (palk_lib.liik = 1 And palk_lib.tululiik = '21', palk_oper.Summa, 000000000.00) As palk_21,;
		iif (palk_lib.liik = 1 And palk_kaart.tulumaar >= 15 And palk_kaart.tulumaar < 26, palk_oper.Summa, 000000000.00) As palk15,;
		iif (palk_lib.liik = 1 And palk_kaart.tulumaar >= 10 And palk_kaart.tulumaar < 15, palk_oper.Summa, 000000000.00) As palk10,;
		iif (palk_lib.liik = 1 And palk_kaart.tulumaar > 0 And palk_kaart.tulumaar < 10, palk_oper.Summa, 000000000.00) As palk5,;
		iif (palk_lib.liik = 1 And palk_kaart.tulumaar = 0, palk_oper.Summa, 000000000.00) As palk0,;
		iif (palk_lib.liik = 7 And palk_lib.asutusest = 0,palk_oper.Summa, 000000000.00) As tm,;
		iif (palk_lib.liik = 7 And palk_lib.asutusest = 1 , palk_oper.Summa , 000000000.00) As atm,;
		iif (palk_lib.liik = 8, palk_oper.Summa, 0000000000.00) As pm,;
		iif (palk_lib.liik = 4, palk_oper.Summa, 0000000000.00) As tulumaks, ;
		iif (palk_lib.liik = 5,  palk_oper.Summa,  000000000.00) As sotsmaks, ;
		IIF (palk_lib.elatis = 1 And palk_lib.liik = 2, palk_oper.Summa, 000000000.00) As elatis, ;
		iif (palk_lib.liik = 1 AND palk_lib.sots = 1, palk_oper.Summa, 0000000000.00) As palksots;
		FROM buhdata5!comTooleping_ INNER Join buhdata5!palk_oper On comTooleping_.Id = palk_oper.Lepingid  ;
		INNER Join buhdata5!Asutus On Asutus.Id = comTooleping_.parentid ;
		INNER Join buhdata5!palk_lib On palk_oper.libId = palk_lib.parentid ;
		INNER Join buhdata5!palk_kaart On palk_kaart.Lepingid = comTooleping_.Id


*!*		Local lnObj, lnElement
*!*		lnObj = Adbobjects(laObj,'TABLE')
*!*		If lnObj < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(laObj,Upper('PALK_TMPL'))
*!*		If lnElement > 0
*!*			Return .T.
*!*		Endif
*!*		lcString = "create table palk_tmpl (id int default next_number ('PALK_TMPL') PRIMARY KEY,"+;
*!*			'parentid int default 0, libId int default 0, summa y default 100, percent_  int default 1,'+;
*!*			'tulumaks int default 1, tulumaar int default 26, tunnusid int default 0)'
*!*		&lcString
*!*		If Used ('palk_tmpl')
*!*			Use In palk_tmpl
*!*		Endif
	lError = DBSetProp('curTsd_','View','FetchAsNeeded',.T.)

	=setpropview()
	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


Function _alter_mssql


	cString = "sp_help"
	lError = sqlexec (gnHandle,cString)
	If lError > 0
		If Used ('sqlresult')
			Select sqlresult
			Locate For Upper(Name) = 'PALK_TMPL' And object_type = 'user table'
			If !Found ()
				cString = 'create table dbo.palk_tmpl (id int IDENTITY (1, 1) NOT NULL  PRIMARY KEY,'+;
					'parentid int NOT NULL default 0, libId int NOT NULL default 0, summa money NOT NULL default 100,'+;
					'percent_  int NOT NULL default 1,'+;
					'tulumaks int NOT NULL default 1, tulumaar int NOT NULL default 26, tunnusid int NOT NULL default 0)'

				lError = sqlexec(gnHandle, cString)

				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT,  DELETE  ON dbo.palk_tmpl  TO dbkasutaja'
				= sqlexec(gnHandle, cString)
				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.palk_tmpl  TO dbpeakasutaja'
				= sqlexec(gnHandle, cString)
				cString = 'GRANT  SELECT  ON dbo.palk_tmpl  TO dbadmin'
				= sqlexec(gnHandle, cString)

			Endif

		Endif
	Endif

	If Used ('sqlresult')
		Use In sqlresult
	Endif
	If lError < 0
		Return .F.
	Endif
Endproc



Function secure
	Lparameters LCENCR
	maxno=100
	LCENCR=Upper(Allt(LCENCR))
	If LCENCR<>'ON' And LCENCR<>'OFF'
		Return Messagebox("Pass ON or OFF for encryption/decryption!")
	Endif
&&SET PROC TO securedata ADDI
* loop through all fields in a table
	lnFields=Fcount()
	For J = 1 To lnFields
		LCFIELD=Field(J)
		Do Case
			Case Type(LCFIELD) $ 'CM'
* replace the all the contents of this particular field
				Repl All &LCFIELD With CONVRT(LCENCR,&LCFIELD)
		Endcase
	Endfor



Procedure CONVRT
	Lparameters lcencrypt,lcString
	If Parameters()<2
		Messagebox('Pass two arguments, [On Off] and string')
		Return
	Endif
	lcencrypt=Upper(Allt(lcencrypt))
* encrypt data
* take a string and shift the data to the right one place
	If lcencrypt='ON'
		lnlen=Len(Allt(lcString))
		lcnewstring=''
* convert the string to the value of the current string + the position
* number of the char in the string.  A string of "ABC" would be converted
* to "BDF"

		For i = 1 To lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=Chr(Asc(Substr(lcString,i,1))+i)
			Else
				lcchar=Chr(Asc(Substr(lcString,i,1))+1)
			Endif
*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Else
		lnlen=Len(Allt(lcString))
		lcnewstring=''
		For i = 1 To lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=Chr(Asc(Substr(lcString,i,1))-i)
			Else
				lcchar=Chr(Asc(Substr(lcString,i,1))-1)
			Endif

*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Endif
	Return (RETVAL)



