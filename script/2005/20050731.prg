*!*	Set Step On
*!*	If !Used ('config')
*!*		Use config In 0
*!*	Endif

*!*	Create Cursor curKey (versia m)
*!*	Append Blank
*!*	Replace versia With 'EELARVE' In curKey
*!*	Create Cursor v_account (admin Int Default 1)
*!*	Append Blank
*!*	*!*	*!*	*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*!*	*!*	*gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	*!*	*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')

*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

*!*	*!*	gnhandle = SQLConnect ('NjlvPg','vlad','490710')
*!*	*!*		gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*				gnHandle = SQLConnect ('gordin','vlad','490710')
*!*			gversia = 'PG'

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
&& ��������� ��������� �������

=update_curprinter()

=update_tolk()
Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
*!*				If File (lcdata)
*!*					Open Data (lcdata) Exclusive
*!*					lcdataproc = lcdefault+'\tmp\buhdata5_20050225.sql'
*!*					If File (lcdataproc)
*!*						Append proc from (lcdataproc) overwrite
*!*						If Dbused('buhdata5')
*!*							Set Database To buhdata5
*!*							Close Databases
*!*						Endif
*!*						If Used('buhdata5')
*!*							Use In buhdata5
*!*						Endif
*!*						Use (lcdata) In 0 Exclusive
*!*						Select buhdata5
*!*						Locate For objectid = 3
*!*						Append Memo buhdata5.Code From (lcdataproc) Overwrite
*!*						Use

*!*				Endif
			Open Data (lcdata) Exclusive
			Compile Database (lcdata)
				Open Data (lcdata)
				Set Database To buhdata5
				Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
				Set Default To (lcdefault)
*!*				Endif
		Endscan
		Use In qryKey
	Case gversia = 'PG'
		=sqlexec (gnHandle,'begin transaction')
		Select qryKey
*!*			Scan For Mline(qryKey.Connect,1) = 'PG'

			lError = _alter_pg ()
			If Vartype (lError ) = 'N'
				lError = Iif( lError = 1,.T.,.F.)
			Endif
			If lError = .F.
				=sqlexec (gnHandle,'rollback')
			Else
				=sqlexec (gnHandle,'commit')
			Endif

*		Endif

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
* parandame tbl struktuur

	* journal1
	
	If !Used('journal1')
		Use journal1 In 0
	Endif
	Select journal1
	lnObj = Afields(aObj)
	Use In journal1
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('PROJ'))
	If lnElement < 1
		ALTER TABLE  journal1 ADD COLUMN PROJ  c(20) DEFAULT SPACE(1)	
	Endif
	If Used('journal1')
		Use In journal1
	ENDIF

	DROP VIEW curjournal_
	CREATE SQL VIEW curjournal_ as ;
	 SELECT Journal.id, Journal.rekvid, Journal.kpv, Journal.asutusid,;
  		 MONTH(Journal.kpv) AS kuu, YEAR(Journal.kpv) AS aasta,;
  		 LEFT(MLINE(Journal.selg,1),254) AS selg, Journal.dok, Journal1.summa,;
  		 Journal1.valsumma, Journal1.valuuta, Journal1.kuurs, Journal1.kood1,;
  		 Journal1.kood2, Journal1.kood3, Journal1.kood4, Journal1.kood5, Journal1.proj,;
  		 Journal1.tunnus, Journal1.deebet, Journal1.kreedit, Journal1.lisa_d, Journal1.lisa_k,;
  		 IIF(ISNULL(Asutus.id),SPACE(120),LEFT(RTRIM(Asutus.nimetus)+SPACE(1)+RTRIM(Asutus.omvorm),120)) AS asutus,;
  		 Journalid.number, LEFT(MLINE(Journal.muud,1),254) AS muud, LEFT(Userid.ametnik,120) AS kasutaja ;
  FROM   buhdata5!Journal   INNER JOIN buhdata5!Journal1 ON  Journal.id = Journal1.parentid ;
    INNER JOIN buhdata5!journalid  ON  Journal.id = ( journalid ) ;
    INNER JOIN buhdata5!Userid  ON  Journal.userid = Userid.id ;
     LEFT OUTER JOIN Asutus   ON  Journal.asutusid = Asutus.id 


	=DBSETPROP('CURJOURNAL_',"VIEW","FetchAsNeeded",.T.)

	CREATE SQL VIEW curtsd_ as ;
SELECT Palk_oper.id, Palk_oper.rekvid, Asutus.regkood AS isikukood,;
  Asutus.nimetus AS isik, Tooleping.pohikoht AS pohikoht,;
  Tooleping.osakondid AS tooleping, Tooleping.resident AS resident,;
  Tooleping.riik AS riik, Tooleping.toend AS toend,;
  Tooleping.osakondid AS osakondid, Palk_lib.liik, Palk_lib.asutusest,;
  Palk_lib.algoritm, Palk_oper.kpv, Palk_oper.summa,;
  STR(Palk_lib.liik,1)+"-"+STR(Palk_kaart.tulumaar,2) AS form,;
  IIF(Palk_lib.liik=1,0.00,0.00) AS palk26,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="02",Palk_oper.summa,0.00) AS palk_02,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="03",Palk_oper.summa,0.00) AS palk_03,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="04",Palk_oper.summa,0.00) AS palk_04,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="05",Palk_oper.summa,0.00) AS palk_05,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="06",Palk_oper.summa,0.00) AS palk_06,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="07",Palk_oper.summa,0.00) AS palk_07,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="08",Palk_oper.summa,0.00) AS palk_08,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="09",Palk_oper.summa,0.00) AS palk_09,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="10",Palk_oper.summa,0.00) AS palk_10,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="11",Palk_oper.summa,0.00) AS palk_11,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="12",Palk_oper.summa,0.00) AS palk_12,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="13",Palk_oper.summa,0.00) AS palk_13,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="14",Palk_oper.summa,0.00) AS palk_14,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="15",Palk_oper.summa,0.00) AS palk_15,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="16",Palk_oper.summa,0.00) AS palk_16,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="17",Palk_oper.summa,0.00) AS palk_17,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="18",Palk_oper.summa,0.00) AS palk_18,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="19",Palk_oper.summa,0.00) AS palk_19,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="19a",Palk_oper.summa,0.00) AS palk_19a,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="20",Palk_oper.summa,0.00) AS palk_20,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.tululiik="21",Palk_oper.summa,0.00) AS palk_21,;
  IIF(Palk_lib.liik=1.AND.Palk_kaart.tulumaar=>15.AND.Palk_kaart.tulumaar<26,Palk_oper.summa,0.00) AS palk15,;
  IIF(Palk_lib.liik=1.AND.Palk_kaart.tulumaar=>10.AND.Palk_kaart.tulumaar<15,Palk_oper.summa,0.00) AS palk10,;
  IIF(Palk_lib.liik=1.AND.Palk_kaart.tulumaar>0.AND.Palk_kaart.tulumaar<10,Palk_oper.summa,0.00) AS palk5,;
  IIF(Palk_lib.liik=1.AND.Palk_kaart.tulumaar=0,Palk_oper.summa,0.00) AS palk0,;
  IIF(Palk_lib.liik=7.AND.Palk_lib.asutusest=0,Palk_oper.summa,0.00) AS tm,;
  IIF(Palk_lib.liik=7.AND.Palk_lib.asutusest=1,Palk_oper.summa,0.00) AS atm,;
  IIF(Palk_lib.liik=8,Palk_oper.summa,0.00) AS pm,;
  IIF(Palk_lib.liik=4,Palk_oper.summa,0.00) AS tulumaks,;
  IIF(Palk_lib.liik=5,Palk_oper.summa,0.00) AS sotsmaks,;
  IIF(Palk_lib.elatis=1.AND.Palk_lib.liik=2,Palk_oper.summa,0.00) AS elatis,;
  IIF(Palk_lib.liik=1.AND.Palk_lib.sots=1,Palk_oper.summa,0.00) AS palksots;
 FROM ;
     buhdata5!comTooleping_ ;
    INNER JOIN buhdata5!palk_oper ;
   ON  Comtooleping_.id = Palk_oper.lepingid ;
    INNER JOIN buhdata5!asutus ;
   ON  Asutus.id = Comtooleping_.parentid ;
    INNER JOIN buhdata5!palk_lib ;
   ON  Palk_oper.libid = Palk_lib.parentid ;
    INNER JOIN buhdata5!palk_kaart ;
   ON  (Palk_kaart.lepingid = palk_oper.lepingid AND palk_kaart.libid = palk_oper.libId)

	=DBSETPROP('CURTSD_',"VIEW","FetchAsNeeded",.T.)
	
	
	=setpropview()
* menu records

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
	locate For Alltrim(Upper(Pad)) = 'PROJEKTID'
	If !Found()
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=�������'+Chr(13)+'EST CAPTION=Projektid',;
			"oProjektid = nObjekt('projektid','oprojektid',0)", 1,'Library','38')

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


		Insert Into menupohi (omandus, level_, Pad ) Values ;
			('RUS CAPTION=�������'+CHR(13)+'EST CAPTION=Projektid',;
			 2,'PROJEKTID')


		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=�������� ������'+CHR(13)+'EST CAPTION=Lisamine'+CHR(13)+'KeyShortCut=CTRL+A',;
			"gcWindow.add()", 2,'PROJEKTID','1')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������ ���������'+CHR(13)+'EST CAPTION=Muutmine'+CHR(13)+'KeyShortCut=CTRL+E',;
			"gcWindow.edit()", 2,'PROJEKTID','2')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������� ������'+CHR(13)+'EST CAPTION=Kustutamine'+CHR(13)+'KeyShortCut=CTRL+DEL',;
			"gcWindow.delete()", 2,'PROJEKTID','3')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������'+CHR(13)+'EST CAPTION=Tr�kk'+CHR(13)+'KeyShortCut=CTRL+P',;
			"gcWindow.print()", 2,'PROJEKTID','4')



	Endif

	Select menupohi
	Scan For Upper(Pad) = 'PROJEKTID'
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
	Select menupohi
	locate For Alltrim(Upper(Pad)) = 'URITUSED'
	If !Found()
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=�����������'+Chr(13)+'EST CAPTION=�ritused',;
			"oUritused = nObjekt('Uritused','oUritused',0)", 1,'Library','381')

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


		Insert Into menupohi (omandus, level_, Pad ) Values ;
			('RUS CAPTION=�����������'+CHR(13)+'EST CAPTION=�ritused',;
			 2,'URITUSED')


		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=�������� ������'+CHR(13)+'EST CAPTION=Lisamine'+CHR(13)+'KeyShortCut=CTRL+A',;
			"gcWindow.add()", 2,'URITUSED','1')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������ ���������'+CHR(13)+'EST CAPTION=Muutmine'+CHR(13)+'KeyShortCut=CTRL+E',;
			"gcWindow.edit()", 2,'URITUSED','2')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������� ������'+CHR(13)+'EST CAPTION=Kustutamine'+CHR(13)+'KeyShortCut=CTRL+DEL',;
			"gcWindow.delete()", 2,'URITUSED','3')
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			('RUS CAPTION=������'+CHR(13)+'EST CAPTION=Tr�kk'+CHR(13)+'KeyShortCut=CTRL+P',;
			"gcWindow.print()", 2,'URITUSED','4')



	Endif

	Select menupohi
	Scan For Upper(Pad) = 'URITUSED'
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

	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


Function _alter_pg

	If v_account.admin > 0 Or v_account.peakasutaja > 0

		IF EMPTY(check_field_pg('JOURNAL1', 'PROJ'))
		lcFile = 'tmp/sql_muuda_journal1.sql'

		If File(lcFile)
			Wait Window 'Db parandus:'+lcFile Nowait
			Create Cursor pg_proc (Proc m)
			Append Blank
			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
			lcString = pg_proc.Proc
			If execute_sql(lcString) < 0
				Return .F.
			Endif
		ENDIF
	ENDIF

	lcFile = 'tmp/sp_salvetsa_journal1.sql'

		If File(lcFile)
			Wait Window 'Db parandus:'+lcFile Nowait
			Create Cursor pg_proc (Proc m)
			Append Blank
			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
			lcString = pg_proc.Proc
			If execute_sql(lcString) < 0
				Return .F.
			Endif
		ENDIF


		lcFile = 'tmp/20050731.sql'

		If File(lcFile)
			Wait Window 'Db parandus:'+lcFile Nowait
			Create Cursor pg_proc (Proc m)
			Append Blank
			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
			lcString = pg_proc.Proc
			If execute_sql(lcString) < 0
				Return .F.
			Endif
		ENDIF
	
	Endif


*!*
*!*		lcFile = 'tmp/gen_palkoper.sql'
*!*		Wait Window 'Db parandus:'+lcFile Nowait
*!*		If File(lcFile)
*!*			Create Cursor pg_proc (Proc m)
*!*			Append Blank
*!*			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
*!*			lcString = pg_proc.Proc
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*		Endif

*menu

	lcString = " select id from menupohi where UPPER(pad) = UPPER('PROJEKTID') "
	lError = sqlexec(gnHandle,lcString,'qrymenupohi')

		If Reccount('qrymenupohi') < 1

		lcOmandus = 'RUS CAPTION=�������'+Chr(13)+'EST CAPTION=Projektid'
		lcproc = [oProjektid =nObjekt("projektid","oprojektid",0)]


		lcString = "Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values "+;
			"('"+lcOmandus+"','"+lcproc+"',1,"+"'Library','38')"

		If execute_sql(lcString,'menupohi') < 0
			Return .F.
		ENDIF
		IF !USED('sqlresult')
			lcstring = 'select id from menupohi order by id desc limit 1'
			=SQLEXEC(gnHandle,lcstring,'sqlresult')
		ENDIF
			lcmenuid = ALLTRIM(STR(sqlresult.id))
			USE IN sqlresult
		
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'EELARVE')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+lcmenuid+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+lcmenuid+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif



		lcOmandus = 'RUS CAPTION=�������'+Chr(13)+'EST CAPTION=Projektid'

		lcString = "Insert Into menupohi (Pad, omandus, level_) Values "+;
			"('PROJEKTID','"+lcOmandus+"', 2)"

		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = " select id from menupohi where UPPER(pad) = 'PROJEKTID' order by id desc limit 1"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif



	lcString = " select id from menupohi where UPPER(pad) = UPPER('PROJEKTID') and pad = '2' "
	lError = sqlexec(gnHandle,lcString,'qrymenupohi')

	If Reccount('qrymenupohi') < 1

		lcOmandus = 'RUS CAPTION=�������� ������'+Chr(13)+'EST CAPTION=Lisamine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'PROJEKTID','1','gcWindow.add')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'PROJEKTID' and bar = '1'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


* edit
		lcOmandus = 'RUS CAPTION=�������������'+Chr(13)+'EST CAPTION=Muutmine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'PROJEKTID','2','gcWindow.edit')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'PROJEKTID' and bar = '2'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


* kustuta
		lcOmandus = 'RUS CAPTION=�������'+Chr(13)+'EST CAPTION=Kustutamine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar,proc_) Values "+;
			"('"+lcOmandus+"', 2, 'PROJEKTID','3','gcWindow.delete')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'PROJEKTID' and bar = '3'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

* print
		lcOmandus = 'RUS CAPTION=������'+Chr(13)+'EST CAPTION=Tr�kkimine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'PROJEKTID','4','gcWindow.print')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'PROJEKTID' and bar = '4'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


	ENDIF

	Endif


	lcString = " select id from menupohi where UPPER(pad) = UPPER('URITUSED') "
	lError = sqlexec(gnHandle,lcString,'qrymenupohi')

		If Reccount('qrymenupohi') < 1

		lcString = "Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values "+;
			"('"+lcOmandus+"','"+lcproc+"',1,'Library','381')"
		

		If execute_sql(lcString,'menupohi') < 0
			Return .F.
		ENDIF

		IF !USED('sqlresult')
			=SQLEXEC(gnHandle,'select id from menupohi order by id desc limit 1','sqlresult')
		ENDIF
		
		lcmenuid = ALLTRIM(STR(sqlresult.id))

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'EELARVE')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+lcmenuid+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+lcmenuid+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+lcmenuid+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif






		lcOmandus = 'RUS CAPTION=�����������'+Chr(13)+'EST CAPTION=�ritused'
		lcproc = [oUritused =nObjekt("uritused","oUritused",0)]



		lcOmandus = 'RUS CAPTION=�����������'+Chr(13)+'EST CAPTION=�ritused'

		lcString = "Insert Into menupohi (Pad, omandus, level_) Values "+;
			"('URITUSED','"+lcOmandus+"', 2)"

		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = " select id from menupohi where UPPER(pad) = 'URITUSED' order by id desc limit 1"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif



	lcString = " select id from menupohi where UPPER(pad) = UPPER('URITUSED') and pad = '2' "
	lError = sqlexec(gnHandle,lcString,'qrymenupohi')

	If Reccount('qrymenupohi') < 1

		lcOmandus = 'RUS CAPTION=�������� ������'+Chr(13)+'EST CAPTION=Lisamine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'URITUSED','1','gcWindow.add')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'URITUSED' and bar = '1'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


* edit
		lcOmandus = 'RUS CAPTION=�������������'+Chr(13)+'EST CAPTION=Muutmine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'URITUSED','2','gcWindow.edit')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'URITUSED' and bar = '2'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


* kustuta
		lcOmandus = 'RUS CAPTION=�������'+Chr(13)+'EST CAPTION=Kustutamine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar,proc_) Values "+;
			"('"+lcOmandus+"', 2, 'URITUSED','3','gcWindow.delete')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'URITUSED' and bar = '3'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

* print
		lcOmandus = 'RUS CAPTION=������'+Chr(13)+'EST CAPTION=Tr�kkimine'

		lcString = "Insert Into menupohi (omandus, level_, pad, bar, proc_) Values "+;
			"('"+lcOmandus+"', 2, 'URITUSED','4','gcWindow.print')"

		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = " select id from menupohi where UPPER(pad) = 'URITUSED' and bar = '4'"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')
		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
	
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


	ENDIF

	Endif


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
	lError = sqlexec (gnHandle,cString,'qryHelp')
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
	lError = sqlexec (gnHandle,cString,'qryFld')
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
	ENDIF
	IF USED('sqlresult')
		USE IN sqlresult
	ENDIF
	

	If Empty(tcCursor) OR UPPER(LEFT(LTRIM(tcString),6)) = 'INSERT'
		lError = sqlexec(gnHandle,tcString)
		IF lError > 0 AND !EMPTY(tcCursor)
			lcString = "select id from "+tcCursor+" order by id desc limit 1"
			lError = sqlexec(gnHandle,tcString, 'SQLRESULT')
		ENDIF
		
	Else
		lError = sqlexec(gnHandle,tcString, tcCursor)
	ENDIF
	
	
	
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
	LOCATE FOR UPPER(objekt) = UPPER('Lahetuskulud') AND id = 3
	IF !FOUND()
		APPEND BLANK
		Replace ID WITH 3, OBJEKT WITH 'Lahetuskulud', ;
			nimetus1 WITH '��������� ����� (���������) ',;
			nimetus2 WITH 'Avansiarunne (andmik)  ', ;
			procfail With 'avans_report3',;
			reportfail With 'avans_report3',;
			reportvene With 'avans_report3' In curPrinter
		
	ENDIF
	 


	Locate For Lower(objekt) = 'palkaruanne' And Id = 816
	If !Found()
		APPEND BLANK
		Replace ID WITH 816, OBJEKT WITH 'Palkaruanne', ;
			nimetus1 WITH 'Lapsepuhkuse aruanne',;
			nimetus2 WITH 'Lapsepuhkuse aruanne', ;
			procfail With 'puudumine_report2',;
			reportfail With 'puudumine_report2',;
			reportvene With 'puudumine_report2' In curPrinter
	Endif

	Use In curPrinter

	USE aruanne
	LOCATE FOR id = 816 AND objekt = 'Palkaruanne'
	IF !FOUND()
		APPEND BLANK
		replace id WITH 816, objekt WITH 'Palkaruanne', kpv1 with 1, kpv2 with 1 IN aruanne
	ENDIF
	
*	replace konto WITH 1 IN aruanne
	
	USE IN aruanne

	lcFile = 'curprinter.dbf'
		Use (lcFile) In 0 Alias curPrinter

	Locate For Lower(objekt) = 'palkaruanne' And Id = 816
	If !Found()
		APPEND BLANK
		Replace ID WITH 816, OBJEKT WITH 'Palkaruanne', ;
			procfail With 'puudumine_report2',;
			reportfail With 'puudumine_report2',;
			reportvene With 'puudumine_report2' In curPrinter
	Endif

	LOCATE FOR UPPER(objekt) = UPPER('Lahetuskulud') AND id = 3
	IF !FOUND()
		APPEND BLANK
		Replace ID WITH 3, OBJEKT WITH 'Lahetuskulud', ;
			nimetus1 WITH '��������� ����� (���������) ',;
			nimetus2 WITH 'Avansiarunne (andmik)  ', ;
			procfail With 'avans_report3',;
			reportfail With 'avans_report3',;
			reportvene With 'avans_report3' In curPrinter
		
	ENDIF


	Use In curPrinter


Endfunc


Function update_tolk
	If !Used('tolk')
		Use tolk In 0
	Endif
	Select tolk
	Count To lnCount For objektid = 'projektid'
	If lnCount < 1
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('projektid','.grid.column1.header1','���','Kood')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('projektid','.grid.column2.header1','������������','Nimetus')
	Endif
	Count To lnCount For objektid = 'proj'
	If lnCount < 1
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('proj','.lblKood','���:','Kood:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('proj','.lblNimetus','������������:','Nimetus:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('proj','.lblMuud','����������:','M�rkused:')
	Endif
	Count To lnCount For ALLTRIM(LOWER(objektid)) = 'operatsioon'
	If lnCount < 45
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('OPERATSIOON','.Grid1.Column11.Header1','������','Projekt')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('OPERATSIOON','.Grid1.Column12.Header1','������.','�ritus')
	Endif


Endfunc




FUNCTION sp_kontoplaaniparandused_20050222 
LPARAMETERS tcKood, tcRegkood, tcNimetus, ttMuud 
local	lcRet , lcId 	
WAIT WINDOW 'Parandan tp kood:'+tcKood nowait
*Library
	SELECT  *  FROM library ;
		WHERE (ltrim(rtrim(upper(Nimetus)))=ltrim(rtrim(upper(tcNimetus))) ;
		or ltrim(rtrim(upper(Kood))) = ltrim(rtrim(upper(tcKood))));
		and library = 'TP' INTO CURSOR lrLibr
	
	IF RECCOUNT('lrLibr') > 0 
		IF ltrim(rtrim(upper(lrLibr.Kood))) <> ltrim(rtrim(upper(tcKood))) 
			UPDATE library SET Kood = tcKood WHERE Id=LrLibr.id
		Endif
	else
		INSERT INTO library (rekvid,kood,nimetus,library,muud) VALUES (1,tcKood,tcNimetus,'TP',ttMuud)
	endif
	
*ASUTUS
	SELECT *  FROM asutus ;
		WHERE Regkood = tcRegkood;
		INTO CURSOR  lrAsutus
	if RECCOUNT('lrAsutus') > 0
		IF lrAsutus.tp <> tcKood
			UPDATE asutus SET tp=tcKood WHERE Id=LrAsutus.id
		endif
	endif
CLEAR WINDOW 

ENDFUNC

