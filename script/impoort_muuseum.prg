gnHandleNarva = SQLConnect('NarvaLvPg')
If gnHandleNarva < 0
	Messagebox('Viga, uhendus Narva')
	Return
Endif
gnHandleMuuseum = SQLConnect('muuseum')
If gnHandleMuuseum < 0
	Messagebox('Viga, uhendus Muuseum')
	Return
Endif

* vanaandmed
Set Step On
=fncSelData()
=insToolepingud()
*=insAsutuseStruktuur()
*=insPalkLibData()
*=InsNomData()

=SQLDISCONNECT(gnHandleNarva)
=SQLDISCONNECT(gnHandleMuuseum)

Function insToolepingud
*tmpTootajad
*tmpAa
*tmpLepingud

	lnError = SQLEXEC(gnHandleMuuseum,"delete from palk_kaart")
	lnError = SQLEXEC(gnHandleMuuseum,"delete from tooleping")
	lnError = SQLEXEC(gnHandleMuuseum,"delete from asutusaa")
	lnError = SQLEXEC(gnHandleMuuseum,"select id, tun1 as vanaid from library where library in ('OSAKOND','AMET')",'qryLib')

	Select tmpTootajad
	lcString = "select * from asutus "
	lnError = SQLEXEC(gnHandleMuuseum,lcString,'qryAsu')
	If lnError < 0
		Set Step On
		Return
	Endif
	lcString = "select id,kood from library where library = 'PALK' "
	lnError = SQLEXEC(gnHandleMuuseum,lcString,'qryPalkLib')
	If lnError < 0
		Set Step On
		Return
	ENDIF
	
	Select tmpTootajad
	lcCursor = 'tmpTootajad'
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
		Select qryAsu
		Locate For Alltrim(regkood) = Alltrim(tmpTootajad.regkood)
		If !Found()
			lnAsutusId = 0
		Else
			lnAsutusId = qryAsu.Id
		Endif
		If Empty(lnAsutusId)
			lcString = "insert into asutus( rekvid , regkood, nimetus,omvorm , aadress, kontakt, tel,faks ,email , muud , tp , mark ) values (1,'"+;
				ALLTRIM(tmpTootajad.regkood)+"','"+Alltrim(tmpTootajad.nimetus)+"','"+ALLTRIM(tmpTootajad.omvorm)+"','"+Alltrim(tmpTootajad.aadress)+"','"+Alltrim(tmpTootajad.kontakt)+"','"+;
				ALLTRIM(tmpTootajad.tel)+"','"+Alltrim(tmpTootajad.faks)+"','"+Alltrim(tmpTootajad.email)+"','"+;
				ALLTRIM(Iif(Isnull(tmpTootajad.muud),Space(1),tmpTootajad.muud))+"','800699','"+;
				ALLTRIM(Iif(Isnull(tmpTootajad.Mark),Space(1),tmpTootajad.Mark))+"')"
			lnError = SQLEXEC(gnHandleMuuseum,lcString)
			If lnError < 0
				_Cliptext = lcString
				Set Step On
				Exit
			Endif
			lnError = SQLEXEC(gnHandleMuuseum,"select id from asutus order by id desc limit 1",'tmpId')
			If lnError < 0
				Set Step On
				Exit
			Endif
			lnAsutusId = tmpId.Id
		Endif
* asutusaa
		Select tmpAa
		Scan For parentid = tmpTootajad.Id
			lcString = "insert into asutusaa (parentid , aa, pank) values ("+;
				STR(lnAsutusId)+",'"+Alltrim(tmpAa.aa)+"','"+Alltrim(tmpAa.pank)+"')"
			lnError = SQLEXEC(gnHandleMuuseum,lcString)
			If lnError < 0
				_Cliptext = clstring
				Set Step On
				Exit
			Endif
		Endscan
		If lnError < 0
			Exit
		Endif

* tooleping
		Select 	tmpLepingud
		Scan For parentid = tmpTootajad.Id
			lnLepingid = 0
			Select qryLib
			Locate For vanaid = tmpLepingud.osakondId
			If Found()
				lnOsakondId = qryLib.Id
			Else
				lnOsakondId = 0
			Endif
			Locate For vanaid = tmpLepingud.ametid
			If Found()
				lnAmetId = qryLib.Id
			Else
				lnAmetId = 0
			Endif
			If lnOsakondId > 0 And lnAmetId > 0
				lcString = " select sp_salvesta_tooleping(0,"+Str(lnAsutusId)+","+Str(lnOsakondId)+","+Str(lnAmetId)+","+;
					fnc_kpv(tmpLepingud.algab)+","+ fnc_kpv(tmpLepingud.lopp)+"," +Str(tmpLepingud.toopaev)+","+;
					STR(tmpLepingud.palk,16,2)+","+Str(tmpLepingud.palgamaar)+","+Str(tmpLepingud.pohikoht)+","+;
					STR(tmpLepingud.koormus)+","+Str(tmpLepingud.ametnik)+","+Str(tmpLepingud.tasuliik)+","+Str(tmpLepingud.pank)+",'"+;
					ALLTRIM(tmpLepingud.aa)+"','" +Alltrim(Iif(Isnull(tmpLepingud.muud),Space(1),tmpLepingud.muud))+"',1,"+;
					STR(tmpLepingud.resident)+",'"+tmpLepingud.riik+"',"+fnc_kpv(tmpLepingud.toend)+",'"+;
					ALLTRIM(tmpLepingud.valuuta)+"',1)"
				lnError = SQLEXEC(gnHandleMuuseum,lcString,'tmpLepingId')
				If lnError < 0
					_Cliptext = lcString
					Set Step On
					Exit
				Endif
				lnLepingid = tmpLepingId.sp_salvesta_tooleping
			Endif
*tmpPKaart
			If lnLepingid > 0
				Select tmpPKaart
				Scan For lepingid = tmpLepingud.Id
					Select tmpPLibrary
					Locate For Id = tmpPKaart.libId
					Select qryPalkLib
					Locate For Alltrim(kood) = Alltrim(tmpPLibrary.kood)
					If Found()
						lnLibId = qryPalkLib.Id
					Else
						lnLibId = 0
					Endif
					If lnLibId > 0
						lcString = "select sp_salvesta_palk_kaart(0,"+Str(lnAsutusId)+","+ Str(lnLepingid)+","+ Str(lnLibId) +","+;
							STR(tmpPKaart.Summa,16,2)+","+ Str(tmpPKaart.percent_)+","+Str(tmpPKaart.tulumaks)+ ","+Str(tmpPKaart.tulumaar)+ ","+;
							STR(tmpPKaart.Status)+",'"+Alltrim(Iif(Isnull(tmpPKaart.muud),Space(1),tmpPKaart.muud))+"',"+;
							STR(tmpPKaart.alimentid)+",0,'"+tmpPKaart.valuuta+"',"+Str(Iif(tmpPKaart.valuuta = 'EUR',1,1/15.5466),16,4)+")"
						lnError = SQLEXEC(gnHandleMuuseum,lcString)
						If lnError < 0
							_Cliptext = lcString
							Set Step On
							Exit
						Endif
					Endif
				Endscan
			Endif
			If lnError < 0
				Exit
			Endif
		Endscan
		If lnError < 0
			Exit
		Endif

	Endscan
	If lnError < 0
		Messagebox('Viga')
		Set Step On
	Endif


Endfunc



Function insAsutuseStruktuur
*tmpOsakond
*tmpAmet
*tmpPAsutus


	lnError = SQLEXEC(gnHandleMuuseum,"DELETE from library where library IN ('AMET','OSAKOND')")
	If lnError < 0
		Set Step On
		Return
	Endif
	Select tmpOsakond
	lcCursor = 'tmpOsakond'
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
*!*		SELECT qryLib
*!*		LOCATE FOR ALLTRIM(kood) = ALLTRIM(tmpOsakond.kood)
*!*		IF FOUND()
*!*			lnLibId = qryLib.id
*!*		ELSE
		lnLibId = 0
*!*		endif
		lcString = " select sp_salvesta_library("+Str(lnLibId)+",1,'"+Alltrim(tmpOsakond.kood)+"','"+Alltrim(tmpOsakond.nimetus)+"','OSAKOND','"+;
			ALLTRIM(Iif(Isnull(tmpOsakond.muud),Space(1),tmpOsakond.muud))+"',"+Str(tmpOsakond.Id)+","+Str(tmpOsakond.tun2)+","+Str(tmpOsakond.tun3)+","+Str(tmpOsakond.tun4)+","+;
			STR(tmpOsakond.tun5)+")"
		lnError = SQLEXEC(gnHandleMuuseum,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
		lnLibId = tmpId.sp_salvesta_library
*!*		lnString = "update library set vanaid = "+STR(tmpOsakond.id) +" where id = " + STR(lnLIbId)
*!*		lnError = SQLEXEC(gnhandleMuuseum,lcString)
*!*		IF lnError < 0
*!*			_cliptext = lcstring
*!*			SET STEP ON
*!*			exit
*!*		ENDIF
	Endscan
	Select tmpAmet
	lcCursor = 'tmpAmet'
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
*!*		SELECT qryLib
*!*		LOCATE FOR ALLTRIM(kood) = ALLTRIM(tmpOsakond.kood)
*!*		IF FOUND()
*!*			lnLibId = qryLib.id
*!*		ELSE
		lnLibId = 0
*!*		endif
		lcString = " select sp_salvesta_library("+Str(lnLibId)+",1,'"+Alltrim(tmpAmet.kood)+"','"+Alltrim(tmpAmet.nimetus)+"','AMET','"+;
			ALLTRIM(Iif(Isnull(tmpAmet.muud),Space(1),tmpAmet.muud))+"',"+Str(tmpAmet.Id)+","+Str(tmpAmet.tun2)+","+Str(tmpAmet.tun3)+","+Str(tmpAmet.tun4)+","+;
			STR(tmpAmet.tun5)+")"
		lnError = SQLEXEC(gnHandleMuuseum,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
*!*		lnLibId = tmpId.sp_salvesta_library
*!*		lnString = "update library set vanaid = "+STR(tmpAmet.id) +" where id = " + STR(lnLIbId)
*!*		lnError = SQLEXEC(gnhandleMuuseum,lcString)
*!*		IF lnError < 0
*!*			_cliptext = lcstring
*!*			SET STEP ON
*!*			exit
*!*		ENDIF
	Endscan
	lcString = "select id, tun1 as vanaid from library where library in ('OSAKOND','AMET')"
	lnError = SQLEXEC(gnHandleMuuseum,lcString,'qryLib')
	If lnError < 0
		_Cliptext = lcString
		Set Step On
		Return
	Endif

	lnError = SQLEXEC(gnHandleMuuseum,'delete from palk_asutus')
	If lnError < 1
		Set Step On
	Endif

	Select tmpPAsutus
	lcCursor = 'tmpPAsutus'
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
		Select qryLib
		Locate For vanaid = tmpPAsutus.osakondId
		If !Found()
			Continue
		Endif
		lnOsakondId = qryLib.Id
		Select qryLib
		Locate For vanaid = tmpPAsutus.AmetId
		If !Found()
			Continue
		Endif
		lnAmetId = qryLib.Id
		lcString = " INSERT INTO  palk_asutus (rekvid,osakondid,ametid,kogus,vaba,palgamaar) values (1,"+;
			STR(lnOsakondId)+","+Str(lnAmetId)+","+Str(tmpPAsutus.kogus,12,2)+","+Str(tmpPAsutus.vaba,12,2)+","+Str(tmpPAsutus.palgamaar)+")"
		lnError = SQLEXEC(gnHandleMuuseum,lcString)
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
	Endscan

Endfunc



Function insPalkLibData
* tmpPLibrary
*tmpPalkLib
*tmpKlLib
	lnError = SQLEXEC(gnHandleMuuseum,"select * from library where library = 'PALK'",'qryLib')
	If lnError < 0
		Set Step On
		Return
	Endif

	lcCursor = 'tmpPLibrary'
	Select tmpPLibrary
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
		Select qryLib
		Locate For Alltrim(kood) = Alltrim(tmpPLibrary.kood)
		If Found()
			lnLibId = qryLib.Id
		Else
			lnLibId = 0
		Endif
		lcString = " select sp_salvesta_library("+Str(lnLibId)+",1,'"+Alltrim(tmpPLibrary.kood)+"','"+Alltrim(tmpPLibrary.nimetus)+"','PALK','"+;
			ALLTRIM(Iif(Isnull(tmpPLibrary.muud),Space(1),tmpPLibrary.muud))+"',"+Str(tmpPLibrary.TUN1)+","+Str(tmpPLibrary.tun2)+","+Str(tmpPLibrary.tun3)+","+Str(tmpPLibrary.tun4)+","+;
			STR(tmpPLibrary.tun5)+")"
		lnError = SQLEXEC(gnHandleMuuseum,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
		lnLibId = tmpId.sp_salvesta_library
* palk_lib
		Select tmpPalkLib
		Locate For parentid = tmpPLibrary.Id
		If !Found()
			Set Step On
			Exit
		Endif

		lcString = "select id from palk_lib where parentid = "+Str(lnLibId)
		lnError = SQLEXEC(gnHandleMuuseum,lcString,'tmpId')
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
		If Reccount('tmpId') > 0 And tmpId.Id > 0
			lnPalkLibId = tmpId.Id
		Else
			lnPalkLibId = 0
		Endif

		lcString = "select sp_salvesta_palk_lib("+Str(lnPalkLibId)+","+Str(lnLibId)+","+ Str(tmpPalkLib.liik)+","+ Str(tmpPalkLib.tund)+","+;
			STR(tmpPalkLib.maks)+"," +Str(tmpPalkLib.palgafond)+","+ Str(tmpPalkLib.asutusest)+",'"+Alltrim(tmpPalkLib.algoritm)+"','"+;
			ALLTRIM(Iif(Isnull(tmpPalkLib.muud),Space(1),tmpPalkLib.muud))+"',"+ Str(tmpPalkLib.Round,12,4)+","+Str(tmpPalkLib.sots)+",'"+tmpPalkLib.konto+"',"+Str(tmpPalkLib.elatis)+",'"+;
			ALLTRIM(tmpPalkLib.tululiik)+"')"

		lnError = SQLEXEC(gnHandleMuuseum,lcString)
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
*tmpKlLib
		Select tmpKlLib
		Locate For libId = tmpPLibrary.Id
		If !Found()
			Continue
		Endif

		lnError = SQLEXEC(gnHandleMuuseum,"select id from klassiflib where libid = "+Str(lnLibId),'tmpId')
		If lnError < 0
			Set Step On
			Exit
		Endif
		If Reccount('tmpId') > 1
			lcString = "delete from klassiflib where id = "+Str(tmpId.Id)
			lnError = SQLEXEC(gnHandleMuuseum,lcString)
			If lnError < 0
				Set Step On
				Exit
			Endif
		Endif
		lcString = "insert into klassiflib (libid,tyyp,kood1,kood2,kood3,kood4,kood5,konto) values ("+;
			STR(lnLibId)+","+Str(tmpKlLib.tyyp)+",'"+Alltrim(tmpKlLib.kood1)+"','"+Alltrim(tmpKlLib.kood2)+"','"+;
			ALLTRIM(tmpKlLib.kood3)+"','"+Alltrim(tmpKlLib.kood4)+"','"+Alltrim(tmpKlLib.kood5)+"','"+Alltrim(tmpKlLib.konto)+"')"
		lnError = SQLEXEC(gnHandleMuuseum,lcString)
		If lnError < 0
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
	Endscan

Endfunc



Function InsNomData
*tmpNom
*tmpNomLib

	lnError = SQLEXEC(gnHandleMuuseum,"select * from nomenklatuur",'qryNom')
	If lnError < 0
		Set Step On
		Return
	Endif

	Set Step On
	lcCursor = 'tmpNom'
	Select tmpNom
	Scan
		Wait Window lcCursor+Alltrim(Str(Recno(lcCursor)))+'/'+Alltrim(Str(Reccount(lcCursor))) Nowait
		Select qryNom
		Locate For Alltrim(qryNom.kood) = Alltrim(tmpNom.kood)
		If Found()
			lnNomId = qryNom.Id
		Else
* insert
			lcString = "insert into nomenklatuur (rekvid, doklausid, dok , kood , nimetus ,uhik ,hind ,muud ,ulehind, kogus) values (1,"+;
				STR(tmpNom.doklausid)+",'"+tmpNom.dok+"','"+tmpNom.kood+"','"+tmpNom.nimetus+"','"+tmpNom.uhik+"',"+Str(tmpNom.hind,16,2)+",'"+;
				tmpNom.muud+"',"+Str(tmpNom.ulehind,16,2)+","+Str(tmpNom.kogus,16,4)+")"
			lnError = SQLEXEC(gnHandleMuuseum,lcString)
			If lnError > 0
				lnError = SQLEXEC(gnHandleMuuseum,"select id from noimenklatuur order by id desc limit 1",'tmpId')
				If Used('tmpId')
					lnNomId = tmpId.Id
				Else
					lnNomId = 0
				Endif

			Else
				lnNomId = 0
				_Cliptext = lcstrring
				Set Step On
				Exit
			Endif
		Endif
		If lnNomId > 0
			Select tmpNomLib
			Scan For nomid = tmpNom.Id
				lcString = " INSERT INTO klassiflib (nomid,tyyp,kood1,kood2,kood3,kood4, kood5,konto) values ("+;
					STR(lnNomId,9)+","+Str(tmpNomLib.tyyp)+",'"+tmpNomLib.kood1+"','"+tmpNomLib.kood2+"','"+;
					tmpNomLib.kood3+"','"+tmpNomLib.kood4+"','"+tmpNomLib.kood5+"','"+tmpNomLib.konto+"')"

				lnError = SQLEXEC(gnHandleMuuseum,lcString)
				If lnError < 0
					_Cliptext = lcString
					Set Step On
					Exit
				Endif
			Endscan
			If lnError < 0
				Exit
			Endif
			lnNomId = 0
		Endif
	Endscan

Endfunc




Function fncSelData
* tootajad
	If !Used('tmpTootajad')
		Wait Window 'Loading asutus' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from asutus where id in (select parentid from tooleping where rekvid = 15)",'tmpTootajad')
		If lnError < 0
			Set Step On
		Endif
	Endif
	If Used('tmpTootajad') And !Used('tmpAa')
		Wait Window 'Loading asutusaa' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from asutusaa where parentid in (select parentid from tooleping where rekvid = 15)",'tmpAa')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If Used('tmpAa') And !Used('tmpNom')
		Wait Window 'Loading tmpNom' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from nomenklatuur where rekvid = 15",'tmpNom')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If Used('tmpNom') And !Used('tmpNomLib')
		Wait Window 'Loading tmpNomLib' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from klassiflib where nomid in (select id from nomenklatuur where rekvid = 15)",'tmpNomLib')
		If lnError < 0
			Set Step On
		Endif
	Endif


	If Used('tmpAa') And !Used('tmpLepingud')
		Wait Window 'Loading lepingud' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select tooleping.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta "+;
		" from tooleping left outer join dokvaluuta1 ON (dokvaluuta1.dokid = tooleping.id and dokvaluuta1.dokliik = 19) "+;
		" where rekvid = 15",'tmpLepingud')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If !Used('tmpPKaart')
		Wait Window 'Loading PalkKaart' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select palk_kaart.*, Ifnull(dokvaluuta1.valuuta,'EEK')::varchar AS VALUUTA "+;
			" from palk_kaart left outer join dokvaluuta1 ON(palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) "+;
			" where lepingid in (select id from tooleping where rekvid = 15)",'tmpPKaart')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If !Used('tmpOsakond')
		Wait Window 'Loading tmpOsakond' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from library where rekvid = 15 and library like 'OSAKOND%'",'tmpOsakond')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If  !Used('tmpAmet')
		Wait Window 'Loading tmpAmet' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from library where rekvid = 15 and library like 'AMET%'",'tmpAmet')
		If lnError < 0
			Set Step On
		Endif
	Endif

	If !Used('tmpPAsutus')
		Wait Window 'Loading tmpPAsutus' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from palk_asutus where rekvid = 15",'tmpPAsutus')
		If lnError < 0
			Set Step On
		Endif
	Endif
	If !Used('tmpPLibrary')
		Wait Window 'Loading tmpPLibrary' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from library where rekvid = 15 and library = 'PALK'",'tmpPLibrary')
		If lnError < 0
			Set Step On
		Endif
	Endif
	If Used('tmpPLibrary') And !Used('tmpPalkLib')
		Wait Window 'Loading tmpPalkLib' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from palk_lib where parentid in (select id from library where rekvid = 15 and library = 'PALK')",'tmpPalkLib')
		If lnError < 0
			Set Step On
		Endif
	Endif
	If Used('tmpPalkLib') And !Used('tmpKlLib')
		Wait Window 'Loading tmpKlLib' Nowait
		lnError = SQLEXEC(gnHandleNarva, "select * from klassiflib where libid in (select id from library where rekvid = 15)",'tmpKlLib')
		If lnError < 0
			Set Step On
		Endif
	Endif

Endfunc



Function fnc_kpv
	Lparameters tdKpv
	Local lcKpv
	If Empty(tdKpv) Or Isnull(tdKpv)
		Return 'null'
	Endif
	lcKpv = "date("+Str(Year(tdKpv),4)+","+Str(Month(tdKpv),2)+","+Str(Day(tdKpv),2)+")"

	Return lcKpv
Endfunc
