Set Safety Off

If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
*gnhandle = sqlconnect ('buhdata5zur','zinaida','159')
*gnhandle = SQLConnect ('mssql60')
*,'vladislav','490710')
*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
*gversia = 'MSSQL'
*grekv = 2
*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

gnhandle = SQLConnect ('pg60')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 1
gversia = 'PG'


Local lError

If v_account.admin < 1
	Return .T.
Endif
*!*	If !Used ('key')
*!*		Use Key In 0
*!*	Endif
*!*	Select Key
*!*	lnFields = Afields (aObjekt)
*!*	Create Cursor qryKey From Array aObjekt
*!*	Select qryKey
*!*	Append From Dbf ('key')
*!*	Use In Key
*!*	=secure('OFF')

Do Case
	Case gversia = 'VFP'
*!*			lcdefault = Sys(5)+Sys(2003)
*!*			Select qryKey
*!*			Scan For Mline(qryKey.Connect,1) = 'FOX'
*!*				lcdata = Mline(qryKey.vfp,1)
*!*				If File (lcdata)
*!*					Open Data (lcdata)
*!*	*!*					lcdataproc = lcdefault+'\tmp\0909proc.prn'
*!*	*!*					If file (lcdataproc)
*!*	*!*						Append proc from (lcdataproc) overwrite
*!*	*!*					Endif
*!*					Set Default To Justpath (lcdata)
		lError =  _alter_vfp()
*!*					Close Data
*!*					Set Default To (lcdefault)
*!*				Endif
*!*			Endscan
*!*			Use In qryKey
	Case gversia = 'MSSQL'
		=sqlexec (gnhandle,'BEGIN WORK')
		Set Step On

		lError = _alter_mssql ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
		Set Step On
		If lError = .F.
			=sqlexec (gnhandle,'rollback')
		Else
			=sqlexec (gnhandle,'commit')
		Endif
	Case gversia = 'PG'
		lcdefault = Sys(5)+Sys(2003)
		=sqlexec (gnhandle,'begin work')
		Set Step On
		SET DEFAULT TO script
		lError = _alter_pg ()
		Set Default To (lcdefault)
		SET DEFAULT TO 
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
		If lError = .F.
			=sqlexec (gnhandle,'ROLLBACK WORK')
		Else
			=sqlexec (gnhandle,'COMMIT WORK')
			Wait Window 'Grant access to views' Nowait
			lError =pg_grant_views()
			Wait Window 'Grant access to tables' Nowait
			lError = pg_grant_tables()
		Endif
Endcase
If Used('qryLog')
	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif

*!*	If lError = .f.
*!*		Messagebox ('Viga')
*!*	Endif
If gversia <> 'VFP'
	=sqldisconnect (gnhandle)
*!*	else
*!*		set data to buhdata5
*!*		close data
Endif
Return lError



Function _alter_vfp
	Local lnObj, lnElement

	Wait Window 'Tbl. saldo struktuuri uuendamine ' Nowait
	Set Step On
	If !Empty(check_field_vfp('SALDO','saldo'))
		lcString = "alter table saldo drop column saldo "
		&lcString
	Endif
	If !Empty(check_field_vfp('SALDO','period'))
		If !Used('saldo')
			Use saldo In 0 Excl
		Endif
		Delete Tag period
		lcString = "alter table saldo drop column period "
		&lcString
		Use In saldo
	Endif
	If Empty(check_field_vfp('SALDO','kuu'))
		lcString = "alter table saldo add column kuu int default 0"
		&lcString
	Endif
	If Empty(check_field_vfp('SALDO','aasta'))
		lcString = "alter table saldo add column aasta int default 0"
		&lcString
	Endif
	If Empty(check_field_vfp('SALDO','asutusId'))
		lcString = "alter table saldo add column asutusId int default 0"
		&lcString
	Endif


	Wait Window 'Tbl. MENUPOHI struktuuri uuendamine ' Nowait
	If !Empty(check_field_vfp('MENUPOHI','menu'))
		lcString = "alter table menupohi drop column menu "
		&lcString
	Endif
	If Empty(check_field_vfp('MENUPOHI','PAD'))
		lcString = "alter table menupohi add column pad c(60) default space (20) "
		&lcString
	Endif
	If Empty(check_field_vfp('MENUPOHI','BAR'))
		lcString = "alter table menupohi add column bar c(60) default space (20) "
		&lcString
	Endif
	If Empty(check_field_vfp('MENUPOHI','IDX'))
		lcString = "alter table menupohi add column idx int 0 "
		&lcString
	Endif
	If !Used('menupohi')
		Use menupohi In 0
	Endif
	If Reccount('menupohi') = 0
&& IMPORT MENU BAR

		Select *,Left('FULL',40) As versia From menubar ;
			UNION All;
			select *,Left('EELARVE',40) As versia From eelarve\menubar;
			UNION All;
			select *,Left('PALK',40) As versia From palk\menubar;
			UNION All;
			select *,Left('LADU',40) As versia From ladu\menubar;
			UNION All;
			select *,Left('KASSA',40) As versia From kassa\menubar;
			UNION All;
			select *,Left('PV',40) As versia From Pv\menubar;
			UNION All;
			select *,Left('RAAMA',40) As versia From raama\menubar;
			UNION All;
			select *,Left('TEEN',40) As versia From teen\menubar;
			INTO Cursor qryMenu

		Select Distinct npad, dbfname From qryMenu Into Cursor qryMenuIndex
		Select qryMenuIndex
		Scan
			Wait Window 'MENUPOHI uuendamine '+qryMenuIndex.dbfname Nowait

			Insert Into menupohi (Pad, level_) Values ;
				(qryMenuIndex.npad,  ;
				IIF(Alltrim(Upper(qryMenuIndex.dbfname)) = 'MAIN',1,2))
			Select qryMenu
			lCount = 0
			Scan For npad = qryMenuIndex.npad And ;
					qryMenu.dbfname = qryMenuIndex.dbfname
				If lCount = 0
					lcOmandus = 'RUS CAPTION='+Ltrim(Rtrim(qryMenu.promptorg))+Chr(13)+;
						'EST CAPTION='+Ltrim(Rtrim(qryMenu.promptsub))+Chr(13)+;
						IIF(!Empty(qryMenu.Message),'MESSAGE='+qryMenu.Message+Chr(13),'')

					Replace Omandus With lcOmandus In menupohi
				Endif
				If qryMenu.versia <> 'FULL' And  qryMenu.versia <> 'EELARVE'
					Insert Into menumodul (parentid, Modul) Values (menupohi.Id, qryMenu.versia)
				Endif
			Endscan
		Endscan
&& IMPORT ITEM BAR

		Select *,Left('FULL',40) As versia From menuitem ;
			UNION All;
			select *,Left('EELARVE',40) As versia From eelarve\menuitem;
			UNION All;
			select *,Left('PALK',40) As versia From palk\menuitem;
			UNION All;
			select *,Left('LADU',40) As versia From ladu\menuitem;
			UNION All;
			select *,Left('KASSA',40) As versia From kassa\menuitem;
			UNION All;
			select *,Left('PV',40) As versia From Pv\menuitem;
			UNION All;
			select *,Left('RAAMA',40) As versia From raama\menuitem;
			UNION All;
			select *,Left('TEEN',40) As versia From teen\menuitem;
			INTO Cursor qryMenu

		Select Distinct npad, nbar, dbfname From qryMenu Into Cursor qryMenuIndex
		Select qryMenuIndex
		Scan
			Wait Window 'MENUPOHI uuendamine '+qryMenuIndex.dbfname Nowait

			Insert Into menupohi (Pad, Bar, level_) Values ;
				(qryMenuIndex.npad, qryMenuIndex.nbar, ;
				IIF(Alltrim(Upper(qryMenuIndex.dbfname)) = 'MAIN',1,;
				IIF(Left(qryMenuIndex.npad,3) = 'COM',3,2)))
			Select qryMenu
			lCount = 0
			Scan For npad = qryMenuIndex.npad And nbar = qryMenuIndex.nbar And;
					qryMenu.dbfname = qryMenuIndex.dbfname
				If lCount = 0
					lcOmandus = 'RUS CAPTION='+Ltrim(Rtrim(qryMenu.promptorg))+Chr(13)+;
						'EST CAPTION='+Ltrim(Rtrim(qryMenu.promptsub))+Chr(13)+;
						IIF(!Empty(qryMenu.Message),'MESSAGE='+qryMenu.Message+Chr(13),'')+;
						IIF(!Empty(qryMenu.SkipFor),'SKIPFOR='+qryMenu.SkipFor+Chr(13),'')+;
						IIF(!Empty(qryMenu.HotKey),'KeyShortCut='+qryMenu.HotKey+Chr(13),'')

					Replace proc_ With qryMenu.action,;
						Omandus With lcOmandus In menupohi
					Insert Into menuisik (parentid, gruppId, jah) Values ;
						(menupohi.Id, 'PEAKASUTAJA',1)
					Insert Into menuisik (parentid, gruppId, jah) Values ;
						(menupohi.Id, 'KASUTAJA',1)
					Insert Into menuisik (parentid, gruppId, jah) Values ;
						(menupohi.Id, 'ADMIN',1)
					lCount = 1
				Endif
				If qryMenu.versia <> 'FULL' And  qryMenu.versia <> 'EELARVE'
					Insert Into menumodul (parentid, Modul) Values (menupohi.Id, qryMenu.versia)
				Endif
			Endscan
		Endscan

	Endif



	Wait Window 'Tbl. PALK_LIB struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('PALK_LIB','konto'))
		lcString = "alter table palk_lib add column konto c(20) default space (20) "
		&lcString
	Endif


	Wait Window 'Tbl. aa struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('AA','tp'))
		lcString = "alter table aa add column tp c(20) default space (20) "
		&lcString
	Endif

	Wait Window 'Tbl. gruppomandus struktuuri uuendamine ' Nowait
	If check_field_vfp('GRUPPOMANDUS','kood1') = 'I'
		lcString = "alter table gruppomandus drop column kood1 "
		&lcString
		lcString = "alter table gruppomandus add column kood1 c(20) default space (20) "
		&lcString
	Endif
	If check_field_vfp('GRUPPOMANDUS','kood2') = 'I'
		lcString = "alter table gruppomandus drop column kood2 "
		&lcString
		lcString = "alter table gruppomandus add column kood2 c(20) default space(20)"
		&lcString
	Endif
	If check_field_vfp('GRUPPOMANDUS','kood3') = 'I'
		lcString = "alter table gruppomandus drop column kood3 "
		&lcString
		lcString = "alter table gruppomandus add column kood3 c(20) default space(20)"
		&lcString
	Endif
	If check_field_vfp('GRUPPOMANDUS','kood4') = 'I'
		lcString = "alter table gruppomandus drop column kood4 "
		&lcString
		lcString = "alter table gruppomandus add column kood4 c(20) default space(20)"
		&lcString
	Endif
	If check_field_vfp('GRUPPOMANDUS','kood5')='I'
		lcString = "alter table gruppomandus drop column kood5 "
		&lcString
		lcString = "alter table gruppomandus add column kood5 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('GRUPPOMANDUS','KONTO'))
		lcString = "alter table gruppomandus add column konto c(20) default space(20)"
		&lcString
	Endif


	Wait Window 'Tbl. pv_oper struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('PV_OPER','kood1'))
		lcString = "alter table pv_oper add column kood1 c(20) default space (20) "
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','kood2'))
		lcString = "alter table pv_oper add column kood2 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','kood3'))
		lcString = "alter table pv_oper add column kood3 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','kood4'))
		lcString = "alter table pv_oper add column kood4 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','kood5'))
		lcString = "alter table pv_oper add column kood5 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','KONTO'))
		lcString = "alter table pv_oper add column konto c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','TP'))
		lcString = "alter table pv_oper add column tp c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','TUNNUS'))
		lcString = "alter table pv_oper add column tunnus c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PV_OPER','AsutusId'))
		lcString = "alter table pv_oper add column asutusId int default 0"
		&lcString
	Endif

	Wait Window 'Tbl. palk_oper struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('PALK_OPER','kood1'))
		lcString = "alter table palk_oper add column kood1 c(20) default space (20) "
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','kood2'))
		lcString = "alter table palk_oper add column kood2 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','kood3'))
		lcString = "alter table palk_oper add column kood3 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','kood4'))
		lcString = "alter table palk_oper add column kood4 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','kood5'))
		lcString = "alter table palk_oper add column kood5 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','KONTO'))
		lcString = "alter table palk_oper add column konto c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','TP'))
		lcString = "alter table palk_oper add column tp c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('PALK_OPER','TUNNUS'))
		lcString = "alter table palk_oper add column tunnus c(20) default space(20)"
		&lcString
	Endif


	Wait Window 'Tbl. mk1 struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('MK1','kood1'))
		lcString = "alter table mk1 add column kood1 c(20) default space (20) "
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','kood2'))
		lcString = "alter table mk1 add column kood2 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','kood3'))
		lcString = "alter table mk1 add column kood3 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','kood4'))
		lcString = "alter table mk1 add column kood4 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','kood5'))
		lcString = "alter table mk1 add column kood5 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','KONTO'))
		lcString = "alter table mk1 add column konto c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','TP'))
		lcString = "alter table mk1 add column tp c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('MK1','TUNNUS'))
		lcString = "alter table mk1 add column tunnus c(20) default space(20)"
		&lcString
	Endif



	Wait Window 'Tbl. arv struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('ARV','objektId'))
		lcString = "alter table arv add column objektId int default 0 "
		&lcString
	Endif

	Wait Window 'Tbl. arv1 struktuuri uuendamine ' Nowait
	If check_field_vfp('ARV1','kood1') = 'I'
		lcString = "alter table arv1 drop column kood1 "
		&lcString
		lcString = "alter table arv1 add column kood1 c(20) default space (20) "
		&lcString
	Endif
	If check_field_vfp('ARV1','kood2') = 'I'
		lcString = "alter table arv1 drop column kood2 "
		&lcString
		lcString = "alter table arv1 add column kood2 c(20) default space(20)"
		&lcString
	Endif
	If check_field_vfp('ARV1','kood3') = 'I'
		lcString = "alter table arv1 drop column kood3 "
		&lcString
		lcString = "alter table arv1 add column kood3 c(20) default space(20)"
		&lcString
	Endif
	If check_field_vfp('ARV1','kood4') = 'I'
		lcString = "alter table arv1 drop column kood4 "
		&lcString
		lcString = "alter table arv1 add column kood4 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('ARV1','kood5'))
		lcString = "alter table arv1 add column kood5 c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('ARV1','KONTO'))
		lcString = "alter table arv1 add column konto c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('ARV1','TP'))
		lcString = "alter table arv1 add column tp c(20) default space(20)"
		&lcString
	Endif
	If Empty(check_field_vfp('ARV1','KBMTA'))
		lcString = "alter table arv1 add column kbmta y default 0"
		&lcString
	Endif
	If Empty(check_field_vfp('ARV1','ISIKID'))
		lcString = "alter table arv1 add column isikid INT default 0"
		&lcString
	Endif

	If !Empty(CHECK_obj_VFP('TABLE','SORDER1'))

		Wait Window 'Tbl. sorder2 struktuuri uuendamine ' Nowait
		If check_field_vfp('SORDER2','kood1') = 'I'
			lcString = "alter table sorder2 drop column kood1 "
			&lcString
			lcString = "alter table sorder2 add column kood1 c(20) default c(20) "
			&lcString
		Endif
		If check_field_vfp('SORDER2','kood2') = 'I'
			lcString = "alter table sorder2 drop column kood2 "
			&lcString
			lcString = "alter table sorder2 add column kood2 c(20) default c(20)"
			&lcString
		Endif
		If check_field_vfp('SORDER2','kood3') = 'I'
			lcString = "alter table sorder2 drop column kood3 "
			&lcString
			lcString = "alter table sorder2 add column kood3 c(20) default c(20)"
			&lcString
		Endif
		If check_field_vfp('SORDER2','kood4') = 'I'
			lcString = "alter table sorder2 drop column kood4 "
			&lcString
			lcString = "alter table sorder2 add column kood4 c(20) default c(20)"
			&lcString
		Endif
		If Empty(check_field_vfp('SORDER2','kood5'))
			lcString = "alter table sorder2 add column kood5 c(20) default c(20)"
			&lcString
		Endif
		If Empty(check_field_vfp('SORDER2','KONTO'))
			lcString = "alter table sorder2 add column konto c(20) default c(20)"
			&lcString
		Endif
		If Empty(check_field_vfp('SORDER1','tyyp'))
			lcString = "alter table sorder1 add column tyyp int default 1"
			&lcString
		Endif
		If Empty(check_field_vfp('SORDER2','TP'))
			lcString = "alter table sorder2 add column tp c(20) default c(20)"
			&lcString
		Endif
	Endif
	If Empty(CHECK_obj_VFP('TABLE','KORDER1'))

&& создаем новуб таблицу


		Wait Window 'Tbl. korder1 tццtamine ' Nowait
		cDefault = Sys(5)+Sys(2003)
		If !Used('sorder1')
			Use sorder1
		Endif

		Select sorder1
		lcPath = Dbf('sorder1')
		Set Default To Justpath (lcPath)

		lnFields = Afields(laTbl)
		laTbl(1,12) = 'KORDER1'

		Create Table korder1 From Array laTbl
		If Reccount('sorder1') > 0
			Select sorder1.*,1 As tyyp From sorder1 Into Cursor queryKO1
			Select Top 1 Id From sorder1 Order By Id Desc Into Cursor queryKOID
			If Reccount('queryKOID') > 0
				lnId = queryKOID.Id
			Else
				lnId = 1
			Endif

			Select korder1
			Append From Dbf('queryKO1')
			Use In queryKO1
			Use In queryKOID
			Use In sorder1
		Endif
		Alter Table korder1 Alter Column Id Int Autoinc Nextvalue lnId
		Set Default To (cDefault)

	Endif


	If Empty(CHECK_obj_VFP('TABLE','KORDER2'))

&& создаем новуб таблицу
		cDefault = Sys(5)+Sys(2003)
		If !Used ('SORDER2')
			Use SORDER2 In 0
		Endif
		Select SORDER2
		lnFields = Afields(laTbl)
		laTbl(1,12) = 'KORDER2'
		Create Table korder2 From Array laTbl

		If Reccount('sorder2') > 0
			Select SORDER2.*,1 As tyyp From sorder1 Into Cursor queryKO2
			Select Top 1 Id From SORDER2 Order By Id Desc Into Cursor queryKOID
			If Reccount('queryKOID') > 0
				lnId = queryKOID.Id
			Else
				lnId = 1
			Endif

			Select korder2
			Append From Dbf('queryKO2')
			Use In queryKO2
			Use In queryKOID
			Use In SORDER2
		Endif

		Alter Table korder2 Alter Column Id Int Autoinc Nextvalue lnId

		Set Default To (cDefault)
	Endif


	Wait Window 'Tbl. dokprop struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('DOKPROP','asutusId'))
		lcString = "alter table dokprop aDD column asutusid int default 0 "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','konto'))
		lcString = "alter table dokprop aDD column konto c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kood1'))
		lcString = "alter table dokprop aDD column kood1 c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kood2'))
		lcString = "alter table dokprop aDD column kood2 c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kood3'))
		lcString = "alter table dokprop aDD column kood3 c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kood4'))
		lcString = "alter table dokprop aDD column kood4 c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kood5'))
		lcString = "alter table dokprop aDD column kood5 c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','kbmkonto'))
		lcString = "alter table dokprop aDD column kbmkonto c(20) default SPACE(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKPROP','tyyp'))
		lcString = "alter table dokprop aDD column tyyp int default 1 "
		&lcString
	Endif
	If !Empty(check_field_vfp('DOKPROP','kbmlausendId'))
		lcString = "alter table dokprop drop column kbmlausendId "
		&lcString
	Endif
	If !Empty(check_field_vfp('DOKPROP','kbmumard'))
		lcString = "alter table dokprop drop column kbmumard "
		&lcString
	Endif
	If !Empty(check_field_vfp('DOKPROP','summaumard'))
		lcString = "alter table dokprop drop column summaumard "
		&lcString
	Endif


	Wait Window 'Tbl. nomenklatuur struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('NOMENKLATUUR','ulehind'))
		lcString = "alter table nomenklatuur aDD column ulehind y "
		&lcString
	Endif
	If Empty(check_field_vfp('NOMENKLATUUR','kogus'))
		lcString = "alter table nomenklatuur aDD column kogus y "
		&lcString
	Endif


	Wait Window 'Tbl. asutus struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('ASUTUS','Tp'))
		lcString = "alter table asutus add column Tp int default SPACE(20) "
		&lcString
	Endif

	Wait Window 'Tbl. library struktuuri uuendamine ' Nowait
	If Empty(check_field_vfp('LIBRARY','tun1'))
		lcString = "alter table library add column tun1 int default 0 "
		&lcString
	Endif
	If Empty(check_field_vfp('LIBRARY','tun2'))
		lcString = "alter table library add column tun2 int default 0 "
		&lcString
	Endif
	If Empty(check_field_vfp('LIBRARY','tun3'))
		lcString = "alter table library add column tun3 int default 0 "
		&lcString
	Endif
	If Empty(check_field_vfp('LIBRARY','tun4'))
		lcString = "alter table library add column tun4 int default 0 "
		&lcString
	Endif
	If Empty(check_field_vfp('LIBRARY','tun5'))
		lcString = "alter table library add column tun5 int default 0 "
		&lcString
	Endif
*!*		IF FILE ('scriptLib.prn')
*!*			CREATE CURSOR runSCRIPT(script m)
*!*			SET MEMOWIDTH TO 8000
*!*			APPEND BLANK
*!*			APPEND MEMO runSCRIPT.script from scriptLib.prn as 1252
*!*			lnRows = MEMLINES(runScript.script)
*!*			IF lnRows > 0
*!*				FOR i = 1 to lnRows
*!*					Wait Window 'Tbl. library importeerimine '+STR(i)+'/'+STR(lnRows) Nowait
*!*					lcString = MLINE(runScript.script,i)
*!*					IF !EMPTY(lcString) AND (LEFT(LTRIM(lcString),1) <> '*' OR LEFT(LTRIM(lcString),1)<> '&')
*!*						&lcString
*!*					endif
*!*				endfor
*!*			endif
*!*				ERASE scriptLib.prn recycle
*!*		endif

	Wait Window 'Tbl. klassiflib struktuuri uuendamine ' Nowait
	If check_field_vfp('KLASSIFLIB','kood1') = 'I'
		lcString = "alter table klassiflib drop column kood1 "
		&lcString
		lcString = "alter table klassiflib add column kood1 c(20) "
		&lcString
	Endif
	If check_field_vfp('KLASSIFLIB','kood2') = 'I'
		lcString = "alter table klassiflib drop column kood2 "
		&lcString
		lcString = "alter table klassiflib add column kood2 c(20) "
		&lcString
	Endif
	If check_field_vfp('KLASSIFLIB','kood3') = 'I'
		lcString = "alter table klassiflib drop column kood3 "
		&lcString
		lcString = "alter table klassiflib add column kood3 c(20) "
		&lcString
	Endif
	If check_field_vfp('KLASSIFLIB','kood4') = 'I'
		lcString = "alter table klassiflib drop column kood4 "
		&lcString
		lcString = "alter table klassiflib add column kood4 c(20) "
		&lcString
	Endif
	If check_field_vfp('KLASSIFLIB','kood5') = 'I'
		lcString = "alter table klassiflib drop column kood5 "
		&lcString
		lcString = "alter table klassiflib add column kood5 c(20) "
		&lcString
	Endif
*!*		If !EMPTY(check_field_vfp('KLASSIFLIB','lausendId'))
*!*			lcString = "alter table doklausend drop column lausendId "
*!*			&lcString
*!*		endif
	If Empty(check_field_vfp('KLASSIFLIB','KONTO'))
		lcString = "alter table klassiflib add column konto c(20) "
		&lcString
	Endif


	Wait Window 'Tbl. doklausend struktuuri uuendamine ' Nowait
	If check_field_vfp('DOKLAUSEND','kood1') = 'I'
		lcString = "alter table doklausend drop column kood1 "
		&lcString
		lcString = "alter table doklausend add column kood1 c(20) "
		&lcString
	Endif
	If check_field_vfp('DOKLAUSEND','kood2') = 'I'
		lcString = "alter table doklausend drop column kood2 "
		&lcString
		lcString = "alter table doklausend add column kood2 c(20) "
		&lcString
	Endif
	If check_field_vfp('DOKLAUSEND','kood3') = 'I'
		lcString = "alter table doklausend drop column kood3 "
		&lcString
		lcString = "alter table doklausend add column kood3 c(20) "
		&lcString
	Endif
	If check_field_vfp('DOKLAUSEND','kood4') = 'I'
		lcString = "alter table doklausend drop column kood4 "
		&lcString
		lcString = "alter table doklausend add column kood4 c(20) "
		&lcString
	Endif
	If check_field_vfp('DOKLAUSEND','kood5') = 'I'
		lcString = "alter table doklausend drop column kood5 "
		&lcString
		lcString = "alter table doklausend add column kood5 c(20) "
		&lcString
	Endif
*!*		If !EMPTY(check_field_vfp('DOKLAUSEND','lausendId'))
*!*			lcString = "alter table doklausend drop column lausendId "
*!*			&lcString
*!*		endif
	If !Empty(check_field_vfp('DOKLAUSEND','percent_'))
		lcString = "alter table doklausend drop column percent_ "
		&lcString
	Endif
	If !Empty(check_field_vfp('DOKLAUSEND','kbm'))
		lcString = "alter table doklausend drop column kbm"
		&lcString
	Endif
	If Empty(check_field_vfp('DOKLAUSEND','deebet'))
		lcString = "alter table doklausend add column deebet c(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKLAUSEND','kreedit'))
		lcString = "alter table doklausend add column kreedit c(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKLAUSEND','lisa_d'))
		lcString = "alter table doklausend add column lisa_d c(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('DOKLAUSEND','lisa_k'))
		lcString = "alter table doklausend add column lisa_k c(20) "
		&lcString
	Endif
	If !Empty(CHECK_obj_VFP('VIEW','cur_doklausend_'))
		Drop View cur_doklausend_
	Endif

	Wait Window 'Tbl. eelarve struktuuri uuendamine ' Nowait
	If check_field_vfp('EELARVE','kood1') = 'I'
		lcString = "alter table eelarve drop column kood1 "
		&lcString
		lcString = "alter table eelarve add column kood1 c(20) "
		&lcString
	Endif
	If check_field_vfp('EELARVE','kood2') = 'I'
		lcString = "alter table eelarve drop column kood2 "
		&lcString
		lcString = "alter table eelarve add column kood2 c(20) "
		&lcString
	Endif
	If check_field_vfp('EELARVE','kood3') = 'I'
		lcString = "alter table eelarve drop column kood3 "
		&lcString
		lcString = "alter table eelarve add column kood3 c(20) "
		&lcString
	Endif
	If check_field_vfp('EELARVE','kood4') = 'I'
		lcString = "alter table eelarve drop column kood4 "
		&lcString
		lcString = "alter table eelarve add column kood4 c(20) "
		&lcString
	Endif
	If Empty(check_field_vfp('EELARVE','kood5'))
		lcString = "alter table eelarve add column kood5 c(20) "
		&lcString
	Endif

	If Used('eelarve')
		Use In eelarve
	Endif

	Drop View curEelarveKulud_

	Create Sql View curEelarveKulud_;
		AS;
		SELECT  eelarve.Id, eelarve.rekvid, eelarve.aasta, eelarve.allikasId, eelarve.Summa, eelarve.kood1, eelarve.kood2,;
		eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus, rekv.nimetus As asutus, rekv.regkood, rekv.parentid, ;
		iif(Isnull(Parent.nimetus),Space(254),Parent.nimetus) As parasutus, ;
		iif(Isnull(Parent.regkood),Space(20),Parent.regkood) As parregkood ;
		FROM   eelarve INNER Join  rekv On eelarve.rekvid = rekv.Id;
		left Outer Join rekv Parent On Parent.Id = rekv.parentid


	Drop View kassatulud

	Create Sql View kassatulud;
		as;
		select Distinct Left(Ltrim(Rtrim(kood))+'%',20) As kood From Library Where Library = 'KASSATULUD'

	lError = DBSetProp('kassatulud','View','FetchAsNeeded',.T.)


	Drop View kassakulud

	Create Sql View kassakulud;
		as;
		select Distinct Left(Ltrim(Rtrim(kood))+'%',20) As kood From Library Where Library = 'KASSAKULUD'

	lError = DBSetProp('kassakulud','View','FetchAsNeeded',.T.)


	Drop View curKassaTuludeTaitmine_

	Create Sql View curKassaTuludeTaitmine_;
		as;
		select kuu, aasta, curJournal_.rekvid, curJournal_.tunnus As tun, Sum(Summa) As Summa,;
		LEFT(kreedit,4) As kood, curJournal_.kood5 As eelarve, curJournal_.kood1 As tegev;
		from curJournal_ ;
		INNER Join kassatulud On Ltrim(Rtrim(curJournal_.kreedit)) Like Ltrim(Rtrim(kassatulud.kood));
		INNER Join kassakontod On Ltrim(Rtrim(curJournal_.deebet)) Like Ltrim(Rtrim(kassakontod.kood));
		where Left(kreedit,1) = '3';
		group By aasta, kuu , curJournal_.rekvid, curJournal_.kreedit,curJournal_.kood1, curJournal_.kood5, curJournal_.tunnus;
		order By aasta, kuu , curJournal_.rekvid, curJournal_.kreedit,curJournal_.kood1, curJournal_.kood5, curJournal_.tunnus;

	Drop View curKassaKuludeTaitmine_

	Create Sql View curKassaKuludeTaitmine_;
		as;
		select kuu, aasta, curJournal_.rekvid, Sum(Summa) As Summa,;
		LEFT(deebet,4) As kood , curJournal_.kood5 As eelarve,curJournal_.kood1 As tegev,;
		curJournal_.tunnus As tun;
		from curJournal_ ;
		INNER Join kassakulud On curJournal_.deebet Like kassakulud.kood;
		INNER Join kassakontod On curJournal_.kreedit Like kassakontod.kood;
		where (Left(deebet,1) In ('3','4','5') Or Left(deebet,2) = '15');
		group By aasta, kuu , curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus, curJournal_.kood5;
		order By aasta, kuu , curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus, curJournal_.kood5

	Drop View curEelarve_

	Create Sql View curEelarve_;
		AS;
		SELECT eelarve.Id, eelarve.rekvid, eelarve.aasta, eelarve.Summa,;
		eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus As tun,;
		rekv.nimetus, rekv.nimetus As asutus, rekv.regkood,rekv.parentid, ;
		IIF(Isnull(tunnus.kood),Space(20),tunnus.kood) As tunnus,;
		iif(Isnull(Parent.nimetus),Space(254),Parent.nimetus) As parasutus,;
		iif(Isnull(Parent.regkood),Space(20),Parent.regkood) As parregkood;
		From  eelarve INNER Join rekv On eelarve.rekvid = rekv.Id ;
		left Outer Join rekv Parent On Parent.Id = rekv.parentid;
		left Outer Join Library tunnus On eelarve.Tunnusid = tunnus.Id


*!*		Wait Window 'Tbl. Journal1 struktuuri uuendamine ' Nowait
*!*	*!*		If !empty(check_field_vfp('JOURNAL1','lausendId')
*!*	*!*			lcString = "alter table journal1 drop column lausendId "
*!*	*!*			&lcString
*!*	*!*			If Used ('journal1')
*!*	*!*				Use In 'journal1'
*!*	*!*			Endif
*!*	*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','DOKUMENT')
*!*			lcString = "alter table journal1 drop column dokument"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','kood1')
*!*			lcString = "alter table journal1 drop column kood1"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','kood2')
*!*			lcString = "alter table journal1 drop column kood2"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','kood3')
*!*			lcString = "alter table journal1 drop column kood3"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','kood4')
*!*			lcString = "alter table journal1 drop column kood4"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(check_field_vfp('JOURNAL1','kood5')
*!*			lcString = "alter table journal1 drop column kood5"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif


*!*		If !empty(!empty(check_field_vfp('JOURNAL1','DEEBET')
*!*			lcString = "alter table journal1 add column deebet c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KREEDIT')
*!*			lcString = "alter table journal1 add column kreedit c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','LISA_D')
*!*			lcString = "alter table journal1 add column lisa_d c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','LISA_K')
*!*			lcString = "alter table journal1 add column lisa_k c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KOOD1')
*!*			lcString = "alter table journal1 add column kood1 c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KOOD2')
*!*			lcString = "alter table journal1 add column kood2 c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KOOD3')
*!*			lcString = "alter table journal1 add column kood3 c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KOOD4')
*!*			lcString = "alter table journal1 add column kood4 c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KOOD5')
*!*			lcString = "alter table journal1 add column kood5 c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','VALUUTA')
*!*			lcString = "alter table journal1 add column valuuta c(20) DEFAULT SPACE(1)"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','KUURS')
*!*			lcString = "alter table journal1 add column kuurs n(12,6) DEFAULT 1"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif
*!*		If !empty(!empty(check_field_vfp('JOURNAL1','VALSUMMA')
*!*			lcString = "alter table journal1 add column valsumma y DEFAULT 1"
*!*			&lcString
*!*			If Used ('journal1')
*!*				Use In 'journal1'
*!*			Endif
*!*		Endif


	Drop View curJournal_

	Create  Sql View curJournal_;
		AS;
		SELECT journal.Id, journal.rekvid, journal.kpv, journal.asutusid, Month (journal.kpv) As kuu, Year (journal.kpv) As aasta, ;
		left(Mline(journal.selg ,1),254) As selg, journal.dok, journal1.Summa, journal1.valsumma, journal1.valuuta,journal1.kuurs,;
		journal1.kood1,journal1.kood2, journal1.kood3, journal1.kood4,journal1.kood5,;
		journal1.deebet, journal1.kreedit,journal1.lisa_d, journal1.lisa_k, ;
		IIF(Isnull(asutus.Id),Space(120),Left(Rtrim(asutus.nimetus)+Space(1)+Rtrim(asutus.omvorm),120)) As asutus,;
		journal1.tunnus As tunnus, journalid.Number;
		FROM buhdata5!journal INNER Join buhdata5!journal1 On journal.Id = journal1.parentid ;
		INNER Join buhdata5!journalid On journal.Id = journalid ;
		left Outer Join asutus On journal.asutusid = asutus.Id




*!*		lcString = "create table palk_tmpl (id int default next_number ('PALK_TMPL') PRIMARY KEY,"+;
*!*			'parentid int default 0, libId int default 0, summa y default 100, percent_  int default 1,'+;
*!*			'tulumaks int default 1, tulumaar int default 26, tunnusid int default 0)'
*!*		&lcString
*!*		If used ('palk_tmpl')
*!*			Use IN palk_tmpl
*!*		Endif
	Wait Window 'Database uuendamine ' Nowait
	If CHECK_obj_VFP('TABLE','JOURNAL1TMP')
		Drop Table journal1tmp RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','LAUSEND')
		Drop Table lausend RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','LADU_ULEHIND')
		Drop Table ladu_ulehind RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','LADU_MINKOGUS')
		Drop Table ladu_minkogus RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','LAUSDOK')
		Drop Table lausdok RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','SORDER1')
		If Used('sorder1')
			Use In sorder1
		Endif
		Drop Table sorder1 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','SORDER2')
		If Used('sorder2')
			Use In SORDER2
		Endif
		Drop Table SORDER2 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','VORDER1')
		If Used('vorder1')
			Use In vorder1
		Endif
		Drop Table vorder1 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','VORDER2')
		If Used('vorder2')
			Use In vorder2
		Endif
		Drop Table vorder2 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','ARV3')
		If Used('arv3')
			Use In arv3
		Endif
		Drop Table arv3 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','SALDO1')
		If Used('saldo1')
			Use In saldo1
		Endif
		Drop Table saldo1 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','SALDO2')
		If Used('saldo2')
			Use In saldo2
		Endif
		Drop Table saldo2 RECYCLE
	Endif
	If CHECK_obj_VFP('TABLE','TULUDKULUD')
		If Used('tuludkulud')
			Use In tuludkulud
		Endif
		Drop Table tuludkulud RECYCLE
	Endif


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

	Wait Window 'Database uuendamine ' Nowait
	If CHECK_obj_MSSQL('user table','JOURNALTMP')
		= execute_sql("Drop Table journaltmp") < 0
	Endif
*!*		If CHECK_obj_MSSQL('user table','LAUSEND')
*!*			=execute_sql("trancate Table lausend ") < 0
*!*			=execute_sql("Drop Table lausend ") < 0
*!*		Endif
	If CHECK_obj_MSSQL('user table','LAUSDOK')
*!*			=execute_sql("trancate Table lausdok ") < 0
		= execute_sql("Drop Table lausdok") < 0
	Endif
	Wait Window 'Tbl. asutus struktuuri uuendamine ' Nowait

	If Empty(check_field_mssql('ASUTUS','TpId'))
		lcString = "alter table asutus add TpId int default 0 not null"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. doklausend struktuuri uuendamine ' Nowait
	If check_field_mssql('DOKLAUSEND','kood1') = 'int'
		=execute_sql("alter table doklausend drop CONSTRAINT DF_DOKLAUSEND_KOOD1 ")
		If execute_sql( "alter table doklausend drop column kood1 ") < 0
			Return .F.
		Endif
		If execute_sql("alter table doklausend add kood1 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('DOKLAUSEND','kood2') = 'int'
		=execute_sql("alter table doklausend drop CONSTRAINT DF_DOKLAUSEND_KOOD2 ")
		If execute_sql( "alter table doklausend drop column kood2 ") < 0
			Return .F.
		Endif
		If execute_sql("alter table doklausend add kood2 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('DOKLAUSEND','kood3') = 'int'
		=execute_sql("alter table doklausend drop CONSTRAINT DF_doklausend_KOOD3 ")
		If execute_sql( "alter table doklausend drop column kood3 ")< 0
			Return .F.
		Endif
		If execute_sql( "alter table doklausend add kood3 varchar(20) not null DEFAULT space(20)") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('DOKLAUSEND','kood4') = 'int'
		=execute_sql("alter table doklausend drop CONSTRAINT DF_doklausend_KOOD4  ")
		If execute_sql( "alter table doklausend drop column kood4 ") < 0
			Return .F.
		Endif
		If execute_sql( "alter table doklausend add kood4 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif

	Endif

	If check_field_mssql('DOKLAUSEND','kood5') = 'int'
		=execute_sql("alter table doklausend drop CONSTRAINT DF_doklausend_KOOD5  ")
		If execute_sql( "alter table doklausend drop column kood5 ") < 0
			Return .F.
		Endif
		If execute_sql( "alter table doklausend add kood5 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_mssql('DOKLAUSEND','DEEBET'))
		If execute_sql( "alter table doklausend add deebet varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('DOKLAUSEND','kreedit'))
		If execute_sql( "alter table doklausend add kreedit varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('DOKLAUSEND','lisa_d'))
		If execute_sql( "alter table doklausend add lisa_d varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('DOKLAUSEND','lisa_k'))
		If execute_sql( "alter table doklausend add lisa_k varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif


	If execute_sql( "Drop View curEelarve") < 0
		Return .F.
	Endif



	Wait Window 'Tbl. eelarve struktuuri uuendamine ' Nowait
	If check_field_mssql('EELARVE','kood1') = 'int'
		=execute_sql("alter table eelarve drop CONSTRAINT DF_EELARVE_KOOD1 ")
		If execute_sql( "alter table eelarve drop column kood1 ") < 0
			Return .F.
		Endif
		If execute_sql("alter table eelarve add kood1 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('EELARVE','kood2') = 'int'
		=execute_sql("alter table eelarve drop CONSTRAINT DF_EELARVE_KOOD2 ")
		If execute_sql( "alter table eelarve drop column kood2 ") < 0
			Return .F.
		Endif
		If execute_sql("alter table eelarve add kood2 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('EELARVE','kood3') = 'int'
		=execute_sql("alter table eelarve drop CONSTRAINT DF_EELARVE_KOOD3 ")
		If execute_sql( "alter table eelarve drop column kood3 ")< 0
			Return .F.
		Endif
		If execute_sql( "alter table eelarve add kood3 varchar(20) not null DEFAULT space(20)") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('EELARVE','kood4') = 'int'
		=execute_sql("alter table eelarve drop CONSTRAINT DF_EELARVE_KOOD4  ")
		If execute_sql( "alter table eelarve drop column kood4 ") < 0
			Return .F.
		Endif
		If execute_sql( "alter table eelarve add kood4 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif

	Endif


	lcTyyp = check_field_mssql('EELARVE','kood5')
	If !Empty(lcTyyp) And lcTyyp = 'int'
		=execute_sql("alter table eelarve drop CONSTRAINT DF_EELARVE_KOOD5  ")
		If execute_sql( "alter table eelarve drop column kood5 ") < 0
			Return .F.
		Endif
	Endif
	If Empty(lcTyyp) Or lcTyyp = 'int'
		If execute_sql( "alter table eelarve add kood5 varchar(20) not null DEFAULT space(20) ") < 0
			Return .F.
		Endif

	Endif
	If execute_sql( "Drop View curEelarve") < 0
		Return .F.
	Endif

	lcString = "CREATE view curEelarve AS SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasId,"+;
		"eelarve.summa,eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4,eelarve.kood5, rekv.nimetus,"+;
		"eelarve.tunnus as tun, rekv.nimetus as asutus, rekv.regkood, rekv.parentid,isnull (parent.nimetus,space(254)) as parasutus,"+;
		"isnull ( parent.regkood, space(20)) as parregkood,eelarve.tunnusId, isnull(tunnus.kood,space(20)) as tunnus "+;
		"From  eelarve INNER JOIN rekv ON eelarve.rekvid = rekv.id "+;
		"left outer join rekv parent on parent.id = rekv.parentid "+;
		"left outer join library tunnus on eelarve.tunnusId = tunnus.id "
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	=execute_sql( 'GRANT  SELECT  ON curEelarve TO dbkasutaja')
	=execute_sql( 'GRANT  SELECT  ON curEelarve  TO dbpeakasutaja')
	=execute_sql('GRANT  SELECT  ON curEelarve TO dbadmin')





	Wait Window 'Tbl. library struktuuri uuendamine ' Nowait

	If Empty(check_field_mssql('LIBRARY','tun1'))
		If execute_sql("alter table library add tun1 int default 0 not null") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('LIBRARY','tun2'))
		If execute_sql("alter table library add tun2 int default 0 not null") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('LIBRARY','tun3'))
		If execute_sql("alter table library add tun3 int default 0 not null") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('LIBRARY','tun4'))
		If execute_sql("alter table library add tun4 int default 0 not null") < 0
			Return .T.
		Endif
	Endif
	If Empty(check_field_mssql('LIBRARY','tun5'))
		If execute_sql("alter table library add tun5 int default 0 not null") < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. Journal1 struktuuri uuendamine ' Nowait
	If !Empty(check_field_mssql('JOURNAL1','lausendId'))
		=execute_sql("drop index journal1.lausendId ")
		=execute_sql("alter table journal1 drop CONSTRAINT DF_JOURNAL1_LAUSENDiD ")
		If  execute_sql("alter table journal1 drop column lausendId ") < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_mssql('JOURNAL1','DOKUMENT'))
		=execute_sql("alter table journal1 drop DF_journal1_dokument ")
		If execute_sql( "alter table journal1 drop column dokument") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('JOURNAL1','kood1') <> 'varchar'
		=execute_sql("alter table journal1 drop DF_journal1_kood1")
		If execute_sql( "alter table journal1 drop column kood1") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('JOURNAL1','kood2') <> 'varchar'
		=execute_sql("alter table journal1 drop DF_journal1_kood2")
		If execute_sql( "alter table journal1 drop column kood2") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('JOURNAL1','kood3') <> 'varchar'
		=execute_sql("alter table journal1 drop DF_journal1_kood3")
		If execute_sql( "alter table journal1 drop column kood3") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('JOURNAL1','kood4')<> 'varchar'
		=execute_sql("alter table journal1 drop DF_journal1_kood4")
		If execute_sql("alter table journal1 drop column kood4") < 0
			Return .F.
		Endif
	Endif
	If check_field_mssql('JOURNAL1','kood5')<> 'varchar'
		=execute_sql("alter table journal1 drop DF_journal1_kood5")
		If execute_sql( "alter table journal1 drop column kood5") < 0
			Return .F.
		Endif
	Endif


	If Empty(check_field_mssql('JOURNAL1','DEEBET'))
		If execute_sql("alter table journal1 add  deebet varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KREEDIT'))
		If execute_sql( "alter table journal1 add  kreedit varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','LISA_D'))
		If execute_sql( "alter table journal1 add lisa_d varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','LISA_K'))
		If execute_sql( "alter table journal1 add lisa_k varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KOOD1'))
		If execute_sql( "alter table journal1 add kood1 varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KOOD2'))
		If execute_sql( "alter table journal1 add kood2 varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KOOD3'))
		If execute_sql( "alter table journal1 add kood3 varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KOOD4'))
		If execute_sql( "alter table journal1 add kood4 varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KOOD5'))
		If execute_sql( "alter table journal1 add kood5 varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','VALUUTA'))
		If execute_sql("alter table journal1 add valuuta varchar(20) not null DEFAULT SPACE(1)") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','KUURS'))
		If execute_sql( "alter table journal1 add kuurs money not null DEFAULT 1") < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_mssql('JOURNAL1','VALSUMMA'))
		If execute_sql( "alter table journal1 add valsumma money not null DEFAULT 1") < 0
			Return .F.
		Endif
	Endif

	If execute_sql( "Drop View curJournal") < 0
		Return .F.
	Endif

	lcString = "CREATE view curJournal AS "+;
		" SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, datepart (month, journal.kpv) as kuu,"+;
		" datepart (year, journal.kpv) as aasta,cast(journal.selg as char(254)) as selg, journal.tunnusid, journal.dok,"+;
		" journal1.summa,journal1.VALsumma, journal1.VALUUTA, journal1.KUURS,journal1.kood1, journal1.kood2, journal1.kood3,"+;
		" journal1.kood4,journal1.kood5, journal1.deebet, journal1.kreedit, journal1.lisa_d, journal1.lisa_k,"+;
		" journalid.number,left(rtrim(asutus.nimetus)+space(1)+rtrim(asutus.omvorm),120) as asutus, "+;
		" isnull(tunnus.kood,space(20)) as tunnus "+;
		" FROM journal left outer join library tunnus on tunnus.id = journal.tunnusid "+;
		" INNER JOIN journal1 ON journal.id = journal1.parentId "+;
		" INNER JOIN  asutus ON journal.asutusid = asutus.id "+;
		" INNER join journalid on journal.id = journalid.journalid "
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	=execute_sql( 'GRANT  SELECT  ON curJournal TO dbkasutaja')
	=execute_sql( 'GRANT  SELECT  ON curJournal  TO dbpeakasutaja')
	=execute_sql('GRANT  SELECT  ON curJournal TO dbadmin')

	If Used ('sqlresult')
		Use In sqlresult
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


Function CHECK_obj_VFP
	Parameters tcObjType, tcObjekt
	lnObj = Adbobjects(laObj,Upper(tcObjType))
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(laObj,Upper(tcObjekt))
	If lnElement > 0
		Return .T.
	Else
		Return .F.
	Endif

Function check_field_vfp
	Parameters tcTable, tcObjekt
	Local lnFields, lnElement
	If Empty(tcTable) Or Empty(tcObjekt)
		Return .T.
	Endif
	If !Used(tcTable)
		Use (tcTable) In 0
	Endif
	Select (tcTable)
	lnFields = Afields(atbl)
	lnElement = Ascan(atbl,Upper(tcObjekt))
	Use In (tcTable)
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


Function CHECK_obj_MSSQL
	Parameters tcObjType, tcObjekt
	If !Used('qryHelp')
		cString = "sp_help"
		lError = sqlexec (gnhandle,cString,'qryHelp')
	Endif
	Select qryHelp
	Locate For Upper(Name) = tcObjekt And object_type = tcObjType
	If !Found ()
		Return .F.
	Else
		Return .T.
	Endif

Function check_field_mssql
	Parameters tcTable, tcObjekt
	Local lnFields, lnElement
	If Empty(tcTable) Or Empty(tcObjekt)
		Return .T.
	Endif
	cString = "sp_help '"+tcTable+"'"
	lError = sqlexec (gnhandle,cString)
	If lError < 1
		Return .F.
	Endif
	Select sqlresult1
	Locate For Upper(column_name)= Upper(tcObjekt)
	If Found()
		Return sqlresult1.Type
	Else
		Return .F.
	Endif

Function execute_sql
	Parameters tcString, tcCursor
	If !Used('qryLog')
		Create Cursor qryLog (Log m)
		Append Blank
	Endif

	If Empty(tcCursor)
		lError = sqlexec(gnhandle,tcString)
	Else
		lError = sqlexec(gnhandle,tcString, tcCursor)
	Endif
	lcError = ' OK'
	If lError < 1
		lnErr = Aerror(err)
		If lnErr > 0
			lcError = err(1,3)
		Endif
	Endif
	Replace qryLog.Log With tcString +lcError+Chr(13) Additive In qryLog
	Return lError



