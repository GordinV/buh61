Set step on
grekv = 1
If !used ('config')
	Use config in 0
Endif
If !dbused ('palkdata')
	Open data temp\dbase\palkdata
Endif
Set data to palkdata
gnHandle = sqlconnect ('buhdata5','zinaida','159')
If gnHandle < 1
	=Messagebox('Viga','Kontrol')
	return
Endif
Set classlib to classes\classlib
oDb = createobject ('db')
If vartype (oDb) <>'O'
	Messagebox('Viga','Kontrol')
else
&&	lError=get_isikud()
&&	lError = create_palkkaart()
	lError = get_palk_arv()
Endif
=sqldisconnect(gnHandle)

Function get_palk_arv
	Select Cl.coode, Cl.client, Cl.regnumber, Cl.address,;
		Staff_kaart.num,;
		Staff_kaart.codeid, Staff_kaart.koodid,;
		Staff_kaart.alates, Staff_kaart.lopp, Staff_kaart.force,;
		Staff_kaart.maar, Staff_kaart.palk, Staff_kaart.pohikoht,;
		Staff_kaart.tooaeg, Staff_kaart.ametnik;
		FROM  palkdata!Cl INNER JOIN palkdata!Staff_kaart ;
		ON  Cl.coode = Staff_kaart.coode;
		into cursor qryisikud
oDb.use ('v_palk_oper','v_palk_oper',.t.)
select qryIsikud
scan
	If !used ('comPalkLib')
		oDb.use ('comPalkLib')
	Endif
	tnParent1 = 0
	tnParent2 = 999999999
	If !used ('comTooleping')
		oDb.use ('comTooleping')
	Endif
	oDb.use ('v_palk_kaart','v_palk_kaart',.t.)
	Select qryisikud
	Scan
		Select * from palk_arv where toimikId = qryisikud.num into cursor qryKaart
		Select qryKaart
		Scan
			select comTooleping
			locate for isikukood = qryisikud.regnumber
			Select comPalkLib
			do case
				case qryKaart.code = 'TULUMAKS'
					lnLib = 1803
				case qryKaart.code = 'SOTSMAKS'
					lnLib = 1804
				otherwise
					Locate for alltrim(upper(kood)) = upper(alltrim(qryKaart.code))
					lnLib = comPalkLib.id
			endcase
			select v_palk_oper
			append blank
			replace rekvid with 1,;
				libId with lnLib,;
				lepingid with comTooleping.id,;
				kpv with date (2002,05,31),;
				summa with qryKaart.summa,;
				doklausid with 0,;
				journalid with 0 in v_palk_oper
		endscan
endscan
endscan
	oDb.opentransaction()
	On error 
	lerror = oDb.cursorupdate ('v_palk_oper')
	If lError = .f.
		oDb.rollback
	Else
		oDb.commit
	Endif

return


Function get_isikud
	oDb.opentransaction()
	On error
	Select Cl.num, Cl.coode, Cl.client, Cl.regnumber, Cl.address,;
		Staff_kaart.num,;
		Staff_kaart.codeid, Staff_kaart.koodid,;
		Staff_kaart.alates, Staff_kaart.lopp, Staff_kaart.force,;
		Staff_kaart.maar, Staff_kaart.palk, Staff_kaart.pohikoht,;
		Staff_kaart.tooaeg, Staff_kaart.ametnik;
		FROM  palkdata!Cl INNER JOIN palkdata!Staff_kaart ;
		ON  Cl.coode = Staff_kaart.coode;
		into cursor qryisikud
	Select qryisikud
	Scan
		oDb.use ('v_asutus','v_asutus',.t.)
		oDb.use ('v_tooleping','v_tooleping',.t.)
		Select v_asutus
		Append blank
		Replace rekvid with 1,;
			regkood with qryisikud.regnumber,;
			aadress with qryisikud.address,;
			nimetus with qryisikud.client
		Select v_tooleping
		Append blank
		Do case
			Case qryisikud.koodid = 1
				lnOsakond = 1772
			Case qryisikud.koodid = 2
				lnOsakond = 1773
			Case qryisikud.koodid = 3
				lnOsakond = 1774
			Case qryisikud.koodid = 10
				lnOsakond = 1775
		Endcase
		Do case
			Case qryisikud.koodid = 1 and qryisikud.codeid = 3
				lnAmet = 1776
			Case qryisikud.koodid = 1 and qryisikud.codeid = 22
				lnAmet = 1777
			Case qryisikud.koodid = 1 and qryisikud.codeid = 23
				lnAmet = 1778
			Case qryisikud.koodid = 2 and qryisikud.codeid = 7
				lnAmet = 1779
			Case qryisikud.koodid = 2 and qryisikud.codeid = 9
				lnAmet = 1780
			Case qryisikud.koodid = 2 and qryisikud.codeid = 11
				lnAmet = 1781
			Case qryisikud.koodid = 2 and qryisikud.codeid = 20
				lnAmet = 1782
			Case qryisikud.koodid = 2 and qryisikud.codeid = 21
				lnAmet = 1783
			Case qryisikud.koodid = 2 and qryisikud.codeid = 24
				lnAmet = 1784
			Case qryisikud.koodid = 3 and qryisikud.codeid = 6
				lnAmet = 1785
			Case qryisikud.koodid = 10 and qryisikud.codeid = 18
				lnAmet = 1786
			Case qryisikud.koodid = 10 and qryisikud.codeid = 19
				lnAmet = 1787
			Case qryisikud.koodid = 10 and qryisikud.codeid = 25
				lnAmet = 1788
		Endcase
		lError = oDb.cursorupdate ('v_asutus')
		If lError = .t.
			Update v_tooleping set parentid = v_asutus.id
			Select v_tooleping
			Replace v_tooleping.osakondid with lnOsakond,;
				ametid with lnAmet,;
				algab with qryisikud.alates,;
				lopp with qryisikud.lopp,;
				toopaev with qryisikud.force,;
				palgamaar with qryisikud.maar,;
				palk with qryisikud.palk,;
				pohikoht with 1,;
				koormus with qryisikud.tooaeg,;
				ametnik with 0,;
				tasuliik with 1 in v_tooleping
			lError = oDb.cursorupdate ('v_tooleping')
		Endif
		If lError = .f.
			Set step on
			Exit
		Endif
	Endscan
	If lError = .f.
		oDb.rollback
	Else
		oDb.commit
	Endif
	Return


Function create_palkkaart
	Local lerror
	Select Cl.coode, Cl.client, Cl.regnumber, Cl.address,;
		Staff_kaart.num,;
		Staff_kaart.codeid, Staff_kaart.koodid,;
		Staff_kaart.alates, Staff_kaart.lopp, Staff_kaart.force,;
		Staff_kaart.maar, Staff_kaart.palk, Staff_kaart.pohikoht,;
		Staff_kaart.tooaeg, Staff_kaart.ametnik;
		FROM  palkdata!Cl INNER JOIN palkdata!Staff_kaart ;
		ON  Cl.coode = Staff_kaart.coode;
		into cursor qryisikud

	If !used ('comPalkLib')
		oDb.use ('comPalkLib')
	Endif
	tnParent1 = 0
	tnParent2 = 999999999
	If !used ('comTooleping')
		oDb.use ('comTooleping')
	Endif
	oDb.use ('v_palk_kaart','v_palk_kaart',.t.)
	Select qryisikud
	Scan
		Select * from palk_lib where toimikId = qryisikud.num into cursor qryKaart
		Select qryKaart
		Scan
			select comTooleping
			locate for isikukood = qryisikud.regnumber
			Select comPalkLib
			Locate for alltrim(upper(kood)) = upper(alltrim(qryKaart.code))
			Select v_palk_kaart
			Append blank
			Replace lepingid with comtooleping.id,;
				parentid with comTooleping.parentid,;
				libId with comPalkLib.id,;
				summa with qryKaart.summa,;
				percent_ with 1,;
				tulumaks with qryKaart.tulumaks,;
				tulumaar with qryKaart.tulumaar in v_palk_kaart
		Endscan
	Endscan
	oDb.opentransaction()
	On error 
	lerror = oDb.cursorupdate ('v_palk_kaart')
	If lError = .f.
		oDb.rollback
	Else
		oDb.commit
	Endif
	Return lerror
