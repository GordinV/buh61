*!*	If !Used ('config')
*!*		Use config In 0
*!*	Endif

*!*	Create Cursor curKey (versia m)
*!*	Append Blank
*!*	Replace versia With 'EELARVE' In curKey
*!*	Create Cursor v_account (admin Int Default 1)
*!*	Append Blank
*!*	*!*	*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')

*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

*!*	gnhandle = SQLConnect ('NjlvPg','vlad','490710')
*!*	*!*	gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	*!*	*gnHandle = SQLConnect ('datelviru','vladislav','490710')
*!*	gversia = 'PG'
Local lError

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
&& обновляем параметры отчетов

*=update_curprinter()
*update_tolk()

lcFile = 'eelarve/curprinter.dbf'
Use (lcFile) In 0 Alias curPrinter

Select curPrinter
Locate For Lower(objekt) = 'aruanne' And Id = 201
If !Found()
* lisamine
	Append Blank
	Replace Id With 201,;
		objekt With 'Aruanne ',;
		nimetus1 With 'Оборотная ведомость по субсчетам (TP kood)          ',;
		nimetus2 With 'Kliendikaibeandmik   (TP kood)          ',;
		procfail With 'eelarve\kaibeAsutusandmik_report3',;
		reportfail With 'eelarve\kaibeAsutusandmik_report3',;
		reportvene With 'eelarve\kaibeAsutusandmik_report3' In curPrinter
Endif

Use In curPrinter

return

Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
			If File (lcdata)
*			lcdataproc = lcdefault+'\tmp\0811proc.prn'
*			If File (lcdataproc)
*					Append proc from (lcdataproc) overwrite
				If Dbused('buhdata5')
					Set Database To buhdata5
					Close Databases
				Endif
*!*						If Used('buhdata5')
*!*							Use In buhdata5
*!*						Endif
*!*						Use (lcdata) In 0 Exclusive
*!*						Select buhdata5
*!*						Locate For objectid = 3
*!*						Append Memo buhdata5.Code From (lcdataproc) Overwrite
*!*						Use

*			Endif
*			Open Data (lcdata) Exclusive
*			Compile Database (lcdata)
				Open Data (lcdata)
				Set Database To buhdata5
				Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
				Set Default To (lcdefault)
			Endif
		Endscan
		Use In qryKey
	Case gversia = 'PG'
*		=sqlexec (gnHandle,'begin transaction')
		lError = _alter_pg ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
*!*			If lError = .F.
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

	If !Used('nomenklatuur')
		Use nomenklatuur In 0
	Endif
	Select nomenklatuur
	lnObj = Afields(aObj)
	Use In nomenklatuur
	If lnObj < 1
		Return .F.
	Endif

	lnElement = Ascan(aObj,Upper('KBM'))
	If lnElement < 1
		Alter Table nomenklatuur Add Column kbm Int Default 0
	Endif

	Alter Table palk_taabel1 Alter kokku N(14,4)
	Alter Table  palk_taabel1 Alter Column  too N(14,4)
	Alter Table  palk_taabel1 Alter Column paev N(14,4)
	Alter Table  palk_taabel1 Alter Column ohtu N(14,4)
	Alter Table  palk_taabel1 Alter Column oo N(14,4)
	Alter Table  palk_taabel1 Alter Column tahtpaev N(14,4)
	Alter Table  palk_taabel1 Alter Column puhapaev N(14,4)
	Alter Table  palk_taabel1 Alter Column uleajatoo N(14,4)


	Use In palk_taabel1

	If !Used('pv_kaart')
		Use pv_kaart In 0
	Endif
	Select pv_kaart
	lnObj = Afields(aObj)
	Use In pv_kaart
	If lnObj < 1
		Return .F.
	Endif

	lnElement = Ascan(aObj,Upper('PARHIND'))
	If lnElement < 1
		Alter Table pv_kaart Add parhind  N(14,4)
		Update pv_kaart Set parhind = soetmaks
	Endif
	Use In pv_kaart

	Drop View curPohivara_

	Create Sql View curPohivara_ As;
		SELECT Library.Id, Library.kood, Library.nimetus, Library.rekvid,;
		pv_kaart.vastisikid, Asutus.nimetus As vastisik, pv_kaart.algkulum,;
		pv_kaart.kulum, pv_kaart.soetmaks, pv_kaart.parhind, pv_kaart.soetkpv,;
		Grupp.nimetus As Grupp, pv_kaart.konto, pv_kaart.gruppid,;
		pv_kaart.tunnus, pv_kaart.mahakantud,;
		IIF(pv_kaart.kulum>0,"Pohivara","Vaikevahendid") As liik,;
		LEFT(Mline(pv_kaart.muud,1),254) As rentnik;
		FROM     buhdata5!Library ;
		INNER Join buhdata5!pv_kaart ;
		ON  Library.Id = pv_kaart.parentid ;
		INNER Join buhdata5!Asutus ;
		ON  pv_kaart.vastisikid = Asutus.Id ;
		INNER Join buhdata5!Library Grupp ;
		ON  pv_kaart.gruppid = Grupp.Id



	Create 	Sql View curpalkoper_ As;
		SELECT Library.tun1, Library.tun2, Library.tun3, Library.tun4,;
		Library.tun5, Library.nimetus, Asutus.nimetus As isik,;
		Asutus.Id As isikid,;
		IIF(Isnull(Journalid.Number),0,Journalid.Number) As Journalid,;
		Palk_oper.journal1id, Palk_oper.kpv, Palk_oper.Summa, Palk_oper.Id,;
		Palk_oper.libid, Palk_oper.rekvid, Tooleping.pank, Tooleping.aa, Tooleping.osakondid,;
		IIF(liik=1,"+",Iif(liik=2.Or.liik=6.Or.liik=4.Or.liik=8,"-",Iif(liik=7.And.asutusest=0,"-","%"))) As liik,;
		IIF(tund=1,"KOIK",Iif(tund=2,"PAEV",Iif(tund=3,"OHT",Iif(tund=4,"OO",Iif(tund=5,"PUHKUS",Iif(tund=6,"PUHA","ULETOO")))))) As tund,;
		IIF(maks=1,"JAH","EI ") As maks;
		FROM ;
		buhdata5!Palk_oper ;
		INNER Join buhdata5!Library ;
		ON  Palk_oper.libid = Library.Id ;
		INNER Join buhdata5!palk_lib ;
		ON  palk_lib.parentid = Library.Id ;
		INNER Join buhdata5!Tooleping ;
		ON  Palk_oper.lepingid = Tooleping.Id ;
		INNER Join buhdata5!Asutus ;
		ON  Tooleping.parentid = Asutus.Id ;
		LEFT Outer Join buhdata5!Journalid ;
		ON  Palk_oper.Journalid = Journalid.Journalid




*!*		lnObj = Adbobjects(laObj,'TABLE')

*!*		lnresult = Ascan(laObj,'TMP_VIIVIS')
*!*		If lnresult = 0
*!*			Create Table tmp_viivis (dkpv d Default Date(), Timestamp c(20),  Id Int, rekvid Int,  asutusid Int,  konto c(20),;
*!*				algjaak N(14,4), algkpv d,  arvnumber c(20), tahtaeg d, Summa N(14,4), ;
*!*				tasud1 d,  tasun1 N(14,4),  paev1 Int,  volg1 N(14,4), ;
*!*				tasud2 d,  tasun2 N(14,4),  paev2 Int,  volg2 N(14,4), tasud3 d,  tasun3 N(14,4),;
*!*				paev3 Int,   volg3 N(14,4),   tasud4 d,   tasun4 N(14,4),   paev4 Int,  volg4 N(14,4),;
*!*				tasud5 d,   tasun5 N(14,4),  paev5 Int,  volg5 N(14,4),  tasud6 d,  tasun6 N(14,4),  paev6 Int,;
*!*				volg6 N(14,4))
*!*			Index On Timestamp Tag Timestamp
*!*			Index On dkpv Tag dkpv
*!*			Index On rekvid Tag rekvid
*!*		Endif

*!*		lnresult = Ascan(laObj,'VANEMTASU1')
*!*		If lnresult = 0
*!*			Create Table vanemtasu1 (Id Int Autoinc Primary Key , isikkood c(20) , nimi c(254), vanemkood c(20), vanemnimi c(254), aadress m, muud m)
*!*			Index On isikkood Tag isikkood
*!*		Endif

*!*		lnresult = Ascan(laObj,'VANEMTASU2')
*!*		If lnresult = 0
*!*			Create Table vanemtasu2 (Id Int Autoinc Primary Key , isikId Int, tunnus c(20), ;
*!*			rekvid Int, algkpv d Default Date(), loppkpv d, jaak Y, grupp c(40), muud m)
*!*			Index On isikId Tag isikId
*!*			Index On rekvid Tag rekvid
*!*			Index On algkpv Tag algkpv
*!*			Index On loppkpv Tag loppkpv
*!*		Endif

*!*		lnresult = Ascan(laObj,'VANEMTASU3')
*!*		If lnresult = 0
*!*			Create Table vanemtasu3 (Id Int Autoinc Primary Key , rekvid Int, journalId Int, dokpropId Int,;
*!*				USERID Int, opt Int Default 1, kpv d, konto c(20), tp c(20), Summa Y, tunnus c(20), muud m)
*!*			Index On rekvid Tag rekvid
*!*			Index On kpv Tag kpv
*!*			Index On journalId Tag journalId
*!*			Index On dokpropId Tag dokpropId
*!*			Index On opt Tag opt
*!*			Index On tunnus Tag tunnus


*!*		Endif

*!*		lnresult = Ascan(laObj,'VANEMTASU4')
*!*		If lnresult = 0
*!*			Create Table vanemtasu4 (Id Int Autoinc Primary Key , parentId Int, isikId Int, ;
*!*				maksjakood c(20), maksjanimi c(254),;
*!*				NomId Int, kogus Y, hind Y, Summa Y, konto c(20), tp c(20), ;
*!*				kood1 c(20), kood2 c(20), kood3 c(20), kood4 c(20), kood5 c(20), number c(20), muud m)
*!*			Index On parentId Tag parentId
*!*			Index On isikId Tag isikId
*!*			Index On NomId Tag NomId
*!*			Index On number Tag number

*!*			Create Trigger On vanemtasu4   For Insert  As trigi_vanemtasu4()
*!*			Create Trigger On vanemtasu4   For Update  As trigu_vanemtasu4()
*!*			Create Trigger On vanemtasu4   For Delete  As trigd_vanemtasu4()


*!*		Endif

	=setpropview()

* menu records

*!*		If !Used('menumodul')
*!*			Use menumodul In 0
*!*		Endif
*!*		If !Used('menupohi')
*!*			Use menupohi In 0 Order Id
*!*		Endif
*!*		If !Used('menuisik')
*!*			Use menuisik In 0
*!*		Endif

*!*		Select menupohi
*!*		scan For Alltrim(Upper(Pad)) = Alltrim(Upper('varad'))
*!*			SELECT menuisik
*!*			LOCATE FOR parentid = menupohi.id
*!*			If !Found()
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			ENDIF
*!*			SELECT menumodul
*!*			LOCATE FOR id = menupohi.id
*!*			IF !FOUND()
*!*				Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'LADU')
*!*			ENDIF
*!*		Endscan

*!*	TEXT
*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Asutused')) And Alltrim(Bar) = '9'
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Расчет пени'+Chr(13)+'EST CAPTION=Viivise arvestamine'
*!*			lcproc = "=nObjekt('do form viivis with curAsutused.id')"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Asutused','9',lcproc, lcOmandus, 1)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*		Endif

*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Lapsed')) And Empty(Bar)
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Дети'+Chr(13)+'EST CAPTION=Lapsed'
*!*	*		lcproc = "=nObjekt('do form viivis with curAsutused.id')"
*!*			lcproc = ''

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Добавить запись '+Chr(13)+'EST CAPTION=Lisamine'+Chr(13)+'KeyShortCut=CTRL+A'
*!*			lcproc = "gcWindow.add"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','1',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*			lcOmandus = 'RUS CAPTION=Внести изменения'+Chr(13)+'EST CAPTION=Muutmine'+Chr(13)+'KeyShortCut=CTRL+E'

*!*			lcproc = "gcWindow.edit"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','2',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Удалить запись'+Chr(13)+'EST CAPTION=Kustutamine'+Chr(13)+'KeyShortCut=CTRL+DEL'

*!*			lcproc = "gcWindow.delete"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','3',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Печать'+Chr(13)+'EST CAPTION=Trьkkimine'+Chr(13)+'KeyShortCut=CTRL+P'

*!*			lcproc = "gcWindow.print"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','4',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*			lcOmandus = 'RUS CAPTION=Расчет начислений'+Chr(13)+'EST CAPTION=Arvestamine'

*!*			lcproc = "gcWindow.vanemtasuarv"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','5',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*		Endif


*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = Alltrim(Upper('VANEMTASU')) And Empty(Bar)
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Родительская плата '+Chr(13)+'EST CAPTION=Vanemate tasu'
*!*	*		lcproc = "=nObjekt('do form viivis with curAsutused.id')"
*!*			lcproc = ''

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Lapsed','',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Добавить запись '+Chr(13)+'EST CAPTION=Lisamine'+Chr(13)+'KeyShortCut=CTRL+A'
*!*			lcproc = "gcWindow.add"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('VANEMTASU','1',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*			lcOmandus = 'RUS CAPTION=Внести изменения'+Chr(13)+'EST CAPTION=Muutmine'+Chr(13)+'KeyShortCut=CTRL+E'

*!*			lcproc = "gcWindow.edit"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('VANEMTASU','2',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Удалить запись'+Chr(13)+'EST CAPTION=Kustutamine'+Chr(13)+'KeyShortCut=CTRL+DEL'

*!*			lcproc = "gcWindow.delete"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('VANEMTASU','3',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			lcOmandus = 'RUS CAPTION=Печать'+Chr(13)+'EST CAPTION=Trьkkimine'+Chr(13)+'KeyShortCut=CTRL+P'

*!*			lcproc = "gcWindow.print"
*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('VANEMTASU','4',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*		Endif




*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Vanemtasu')) And Alltrim(Bar) = '5'
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Расчет родительской платы'+Chr(13)+'EST CAPTION=Vanemtasu arvestamine'
*!*			lcproc = "gcWindow.vanemtasuarv"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Vanemtasu','5',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*		Endif

*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Library')) And Bar= '41'
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Дети'+Chr(13)+'EST CAPTION=Lapsed'
*!*			lcproc = "oLapsed = nObjekt('Lapsed','oLapsed')"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Library','41',lcproc, lcOmandus, 1)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*		Endif
*!*	ENDTEXT


	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


Function _alter_pg

	If v_account.admin < 1
		Return .T.
	Endif


	Wait Window 'Db parandus' Nowait
	lcFile = 'tmp/fnc_muudatused20041022.sql'
	If File(lcFile)

		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


*!*		lcString = " select id from menupohi where UPPER(pad) = 'FILE' and bar = '39'"
*!*		lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*		If Reccount('qrymenupohi') < 1

*!*			lcOmandus = 'RUS CAPTION=Родительская плата'+Chr(13)+'EST CAPTION=Vanemate tasu'
*!*			lcproc = [oVanemtasu = nObjekt("vanemtasu","oVanemtasu",0)]

*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('File','39','"+lcproc+"','"+lcOmandus+"', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'FILE' and bar = '39'"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif


*!*		Endif

*!*		lcString = " select id from menupohi where UPPER(pad) = UPPER('VANEMTASU') and EMPTY(bar)"
*!*		lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*		If Reccount('qrymenupohi') < 1
*!*			lcOmandus = 'RUS CAPTION=Родительская плата '+Chr(13)+'EST CAPTION=Vanemate tasu'
*!*			lcproc = ''
*!*	*		[=nObjekt("do form viivis ")]

*!*			lcString = "Insert Into menupohi (Pad,  proc_, omandus, level_) Values "+;
*!*				"('VANEMTASU','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'VANEMTASU' and EMPTY(bar)"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif


*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif


*!*			lcOmandus = 'RUS CAPTION=Добавить запись '+Chr(13)+'EST CAPTION=Lisamine'+Chr(13)+'KeyShortCut=CTRL+A'
*!*			lcproc = "gcWindow.add"

*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('VANEMTASU','1','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'VANEMTASU' and bar = '1'"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcOmandus = 'RUS CAPTION=Внести изменения'+Chr(13)+'EST CAPTION=Muutmine'+Chr(13)+'KeyShortCut=CTRL+E'
*!*			lcproc = "gcWindow.edit"

*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('VANEMTASU','2','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'VANEMTASU' and bar = '2'"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcOmandus = 'RUS CAPTION=Удалить запись'+Chr(13)+'EST CAPTION=Kustutamine'+Chr(13)+'KeyShortCut=CTRL+DEL'
*!*			lcproc = "gcWindow.delete"

*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('VANEMTASU','3','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'VANEMTASU' and bar = '3'"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcOmandus = 'RUS CAPTION=Печать'+Chr(13)+'EST CAPTION=Trьkkimine'+Chr(13)+'KeyShortCut=CTRL+P'
*!*			lcproc = "gcWindow.print"


*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('VANEMTASU','4','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'VANEMTASU' and bar = '4'"
*!*			lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*		Endif

Endfunc








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




Function CHECK_obj_pg
	Parameters tcObjType, tcObjekt
	Do Case
		Case Upper(tcObjType) = 'TABLE'
			cString = "select relid from pg_stat_all_tables where UPPER(relname) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'GROUP'
			cString = "select groName from pg_group where UPPER(groName) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'VIEW'
			cString = "select viewname from pg_views where UPPER(viewname) = '"+;
				UPPER(tcObjekt)+"'"

		Case Upper(tcObjType) = 'PROC'
			cString = "select proname from pg_proc where UPPER(proname) = '"+;
				UPPER(tcObjekt)+"'"

	Endcase
	lError = SQLEXEC (gnHandle,cString,'qryHelp')
	If Reccount('qryhelp') < 1
		Return .F.
	Else
		Return .T.
	Endif
Endfunc


Function check_field_pg
	Parameters tcTable, tcObjekt
	Local lnFields, lnElement
	If Empty(tcTable) Or Empty(tcObjekt)
		Return .T.
	Endif
	cString = "select * from "+tcTable+" order by id limit 1"
	lError = SQLEXEC (gnHandle,cString,'qryFld')
	If lError < 1
		Return .F.
	Endif
	Select qryFld
	lnFields = Afields(atbl)
	lnElement = Ascan(atbl,Upper(tcObjekt))
	Use In qryFld
	If lnElement > 0
		lnCol = Asubscript(atbl, lnElement,2)
		If lnCol <> 1
			Return .F.
		Endif
		lnRaw = Asubscript(atbl, lnElement,1)
		Return atbl(lnRaw,2)
	Else
		Return .F.
	Endif
Endfunc

Function execute_sql
	Parameters tcString, tcCursor
	If !Used('qryLog')
		Create Cursor qryLog (Log m)
		Append Blank
	Endif

	If Empty(tcCursor)
		lError = SQLEXEC(gnHandle,tcString)
	Else
		lError = SQLEXEC(gnHandle,tcString, tcCursor)
	Endif
	lcError = ' OK'
	If lError < 1
		Set Step On
		lnErr = Aerror(err)
		If lnErr > 0
			lcError = err(1,3)
		Endif
	Endif
	Replace qryLog.Log With tcString +lcError+Chr(13) Additive In qryLog
	Return lError


Function update_curprinter

	lcFile = 'eelarve\curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For Lower(objekt) = 'aruanne' And Id = 200
	If !Found()
* lisamine
		Append Blank
		Replace Id With 200,;
			objekt With 'Aruanne ',;
			nimetus1 With 'Оборотная ведомость по субсчетам (Tunnus)          ',;
			nimetus2 With 'Kliendikaibeandmik   (tunnus)          ',;
			procfail With 'kaibeAsutusandmik_report2 ',;
			reportfail With 'kaibeAsutusandmik_report2 ',;
			reportvene With 'kaibeAsutusandmik_report2 ' In curPrinter
	Endif

	Use In curPrinter

	lcFile = 'curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For Lower(objekt) = 'aruanne' And Id = 200
	If !Found()
* lisamine
		Append Blank
		Replace Id With 200,;
			objekt With 'Aruanne ',;
			nimetus1 With 'Оборотная ведомость по субсчетам (Tunnus)          ',;
			nimetus2 With 'Kliendikaibeandmik   (tunnus)          ',;
			procfail With 'kaibeAsutusandmik_report2 ',;
			reportfail With 'kaibeAsutusandmik_report2 ',;
			reportvene With 'kaibeAsutusandmik_report2 ' In curPrinter
	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With 'Родительская плата (ведомость)',;
*!*			nimetus2 With 'Laste vanematetasu andmik',;
*!*			procfail With 'vanemtasu_report1',;
*!*			reportfail With 'vanemtasu_report1',;
*!*			reportvene With 'vanemtasu_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 3
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 3,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With 'счета',;
*!*			nimetus2 With 'Arved',;
*!*			procfail With 'vanemtasu_report2',;
*!*			reportfail With 'vanemtasu_report2',;
*!*			reportvene With 'vanemtasu_report2' In curPrinter
*!*	Endif


*!*	Locate For Lower(objekt) = 'lapsed' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With 'Список',;
*!*			nimetus2 With 'Laste nimikiri',;
*!*			procfail With 'lapsed_report1',;
*!*			reportfail With 'lapsed_report1',;
*!*			reportvene With 'lapsed_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'lapsed' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With 'Должники',;
*!*			nimetus2 With 'Vхlnikud',;
*!*			procfail With 'lapsed_report2',;
*!*			reportfail With 'lapsed_report2',;
*!*			reportvene With 'lapsed_report2' In curPrinter
*!*	Endif


*!*	Use In curPrinter

*!*	lcFile = 'curprinter.dbf'
*!*	Use (lcFile) In 0 Alias curPrinter

*!*	Select curPrinter
*!*	Locate For Lower(objekt) = 'viivis' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'viivis',;
*!*			nimetus1 With 'Расчет пени',;
*!*			nimetus2 With 'Viivise arvestamine',;
*!*			procfail With 'viivis_report1',;
*!*			reportfail With 'viivis_report1',;
*!*			reportvene With 'viivis_report1' In curPrinter
*!*	ENDIF

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With 'Родительская плата (ведомость)',;
*!*			nimetus2 With 'Laste vanematetasu andmik',;
*!*			procfail With 'vanemtasu_report1',;
*!*			reportfail With 'vanemtasu_report1',;
*!*			reportvene With 'vanemtasu_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 3
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 3,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With 'счета',;
*!*			nimetus2 With 'Arved',;
*!*			procfail With 'vanemtasu_report2',;
*!*			reportfail With 'vanemtasu_report2',;
*!*			reportvene With 'vanemtasu_report2' In curPrinter
*!*	Endif


*!*	Locate For Lower(objekt) = 'lapsed' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With 'Список',;
*!*			nimetus2 With 'Laste nimikiri',;
*!*			procfail With 'lapsed_report1',;
*!*			reportfail With 'lapsed_report1',;
*!*			reportvene With 'lapsed_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'lapsed' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With 'Должники',;
*!*			nimetus2 With 'Vхlnikud',;
*!*			procfail With 'lapsed_report2',;
*!*			reportfail With 'lapsed_report2',;
*!*			reportvene With 'lapsed_report2' In curPrinter
*!*	Endif

	Use In curPrinter
Endfunc


Function update_tolk
	If !Used('tolk')
		Use tolk In 0
	Endif
	Select tolk
	Count To lnCount For objektid = 'viivis'
	If lnCount < 16
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblasutus','Организация:','Asutus:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKpv','Дата:','Kuupдev:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblviivis','Пеня (%):','Viivis (%):')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblkood','Код:','Kood:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnArvesta','Расчет','Arvesta')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnUusArve','Счет','Arve')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKokku','Итого:','Kokku:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column1.header1','Счет','Konto')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column2.header1','Пояснение','Selgitus')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column3.header1','Номер','Number')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column4.header1','Сумма','Summa')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column5.header1','Срок','Tдhtaeg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column6.header1','Оплачено','Makstud')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column7.header1','Долг','Vхlg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column8.header1','Пени','Viivis')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column9.header1','Кол-во дней','Pдevade arv')
	Endif


Endfunc
