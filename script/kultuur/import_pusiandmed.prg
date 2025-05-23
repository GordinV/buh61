gnHandle = SQLConnect('narvalvpg')
If gnHandle < 0
	Messagebox('Uhenduse viga')
	Return
ENDIF

*lib

Wait Window 'Lib paring...' Nowait
lcString = "select * from library where rekvid = 66 and library in( 'DOK','PVGRUPP') union all "+;
" select * from library where rekvid = 119 and library in ('PROJ','URITUS') "
lnError = SQLEXEC(gnHandle,lcString,'qryLib')
If lnError < 0
	Messagebox('SQL viga')
	Set Step On
Endif

*Pusiandmed

Wait Window 'lib Salvestamine...' Timeout 1
	Select qryLib
	Scan
		Wait Window 'Salvestamine...'+Str(Recno('qryLib'),3)+'/'+Str(Reccount('qryLib')) Nowait
		lcString = "select id from library where rekvid = 125 and library = '"+qryLib.library +"' and kood = '"+Alltrim(qryLib.kood)+"'"
		lnError = SQLEXEC(gnHandle,lcString,'qryId')
		lnId = '0'
		If Used('qryId') And Reccount('qryId') > 0
			lnId = Str(qryId.Id)
			lnError = SQLEXEC(gnHandle,lcString)
			If lnError < 0
				Messagebox('Viga')
				_Cliptext = lcString
				Set Step On
				Exit
			Endif

		Endif

		lcString = "select sp_salvesta_library("+lnId+", 125, '"+Alltrim(qryLib.kood)+"','"+ Alltrim(qryLib.nimetus)+"','"+qryLib.library+"','"+;
			IIF(Isnull(qryLib.muud),'',qryLib.muud)+"',"+ Str(qryLib.tun1)+","+ Str(qryLib.tun2)+","+Str(qryLib.tun3)+","+Str(qryLib.tun4)+","+Str(qryLib.tun5)+")"
		lnError = SQLEXEC(gnHandle,lcString,'qryId')
		If lnError < 0 Or !Used('qryId') Or qryId.sp_salvesta_library <= 0
			Messagebox('Viga')
			_Cliptext = lcString
			Set Step On
			Exit
		Endif
	endscan

*!*	*palk
*!*	Wait Window 'Lib paring...' Nowait
*!*	lcString = "select * from library where rekvid = 66 and library = 'PALK'"
*!*	lnError = SQLEXEC(gnHandle,lcString,'qryLib')
*!*	If lnError < 0
*!*		Messagebox('SQL viga')
*!*		Set Step On
*!*	Endif

*!*	If lnError > 0
*!*		Wait Window 'palkLib paring...' Nowait
*!*		lcString = "select * from palk_lib where parentid in (select id from library where rekvid = 66 and library = 'PALK')"
*!*		lnError = SQLEXEC(gnHandle,lcString,'qryPalkLib')
*!*		If lnError < 0
*!*			Messagebox('SQL viga')
*!*			Set Step On
*!*		Endif
*!*	Endif
*!*	If lnError > 0
*!*		Wait Window 'klassiflib paring...' Nowait
*!*		lcString = "select * from klassiflib where libid in (select id from library where rekvid = 66 and library = 'PALK')"
*!*		lnError = SQLEXEC(gnHandle,lcString,'qryKlassifLib')
*!*		If lnError < 0
*!*			Messagebox('SQL viga')
*!*			Set Step On
*!*		Endif
*!*	Endif

*!*	*nom
*!*	Wait Window 'nomenklatuur paring...' Nowait
*!*	lcString = "select nomenklatuur.*,ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  "+;
*!*		" from nomenklatuur left outer join dokvaluuta1 on nomenklatuur.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 17 where rekvid = 66 and dok = 'ARV'"
*!*	lnError = SQLEXEC(gnHandle,lcString,'qryNom')
*!*	If lnError < 0
*!*		Messagebox('SQL viga')
*!*		Set Step On
*!*	Endif

*!*	If lnError > 0
*!*		Wait Window 'klassiflib paring...' Nowait
*!*		lcString = "select * from klassiflib where Nomid in (select id from nomenklatuur where rekvid = 66 and dok = 'ARV')"
*!*		lnError = SQLEXEC(gnHandle,lcString,'qryKlassifLibNom')
*!*		If lnError < 0
*!*			Messagebox('SQL viga')
*!*			Set Step On
*!*		Endif
*!*	Endif


*!*	Set Step On
*!*	If lnError > 0
*!*		Wait Window 'nom Salvestamine...' Timeout 1
*!*		Select qryNom
*!*		Scan
*!*			Wait Window 'Salvestamine...'+Str(Recno('qryNom'),3)+'/'+Str(Reccount('qryNom')) Nowait

*!*			lcString = "select id from nomenklatuur where rekvid = 125 and dok = 'ARV' and kood = '"+Alltrim(qryNom.kood)+"'"
*!*			lnError = SQLEXEC(gnHandle,lcString,'qryId')
*!*			lnId = '0'
*!*			If Used('qryId') And Reccount('qryId') > 0
*!*				lnId = Str(qryId.Id)
*!*				lcString = "delete from klassiflib where nomid = "+lnId
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*			Endif

*!*			lcString = "select  sp_salvesta_nomenklatuur("+lnId+",125, "+Str(qryNom.doklausId)+",'"+ qryNom.dok +"','"+qryNom.kood+"','"+;
*!*				qryNom.nimetus+"','"+qryNom.uhik+"',"+ Str(qryNom.hind,14,4)+",'" +Iif(Isnull(qryNom.muud),Space(1),qryNom.muud)+"',"+;
*!*				STR(qryNom.ulehind,14,4)+","+Str(qryNom.kogus,14,4)+",'"+Iif(Isnull(qryNom.formula),Space(1),qryNom.formula)+"','"+;
*!*				qryNom.valuuta+"',"+Str(qryNom.kuurs,14,4)+")"

*!*			lnError = SQLEXEC(gnHandle,lcString,'qryId')
*!*			If lnError < 0 Or !Used('qryId') Or qryId.sp_salvesta_nomenklatuur <= 0
*!*				Messagebox('Viga')
*!*				_Cliptext = lcString
*!*				Set Step On
*!*				Exit
*!*			Endif
*!*			Select qryKlassifLibNom
*!*			Scan For nomid = qryNom.Id
*!*				lcString = "insert into klassiflib (nomid, palklibid,libid,tyyp,tunnusid, kood1,kood2, kood3,kood4,kood5,konto,proj) values ("+;
*!*					STR(qryId.sp_salvesta_nomenklatuur)+", 0,0,"+Str(qryKlassifLibNom.tyyp)+",0,'"+qryKlassifLibNom.kood1+"','"+qryKlassifLibNom.kood2+"','"+;
*!*					qryKlassifLibNom.kood3+"','"+qryKlassifLibNom.kood4+"','"+qryKlassifLibNom.kood5+"','"+qryKlassifLibNom.konto+"','"+qryKlassifLibNom.Proj+"')"
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*			Endscan


*!*		Endscan

*!*		Wait Window 'palk Salvestamine...' Timeout 1
*!*		Select qryLib
*!*		Scan
*!*			Wait Window 'Salvestamine...'+Str(Recno('qryLib'),3)+'/'+Str(Reccount('qryLib')) Nowait
*!*			lcString = "select id from library where rekvid = 125 and library = 'PALK' and kood = '"+Alltrim(qryLib.kood)+"'"
*!*			lnError = SQLEXEC(gnHandle,lcString,'qryId')
*!*			lnId = '0'
*!*			If Used('qryId') And Reccount('qryId') > 0
*!*				lnId = Str(qryId.Id)
*!*				lcString = "delete from palk_lib where parentid = "+lnId
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*				lcString = "delete from klassiflib where libid = "+lnId
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif

*!*			Endif

*!*			lcString = "select sp_salvesta_library("+lnId+", 125, '"+Alltrim(qryLib.kood)+"','"+ Alltrim(qryLib.nimetus)+"','PALK','"+;
*!*				IIF(Isnull(qryLib.muud),'',qryLib.muud)+"',"+ Str(qryLib.tun1)+","+ Str(qryLib.tun2)+","+Str(qryLib.tun3)+","+Str(qryLib.tun4)+","+Str(qryLib.tun5)+")"
*!*	*		WAIT WINDOW LEFT(lcString,120) nowait
*!*	*!*	*		IF TYPE(lcString) <> 'C'
*!*	*!*				MESSAGEBOX('Viga')
*!*	*!*				lnError = -1
*!*	*!*				SET STEP ON
*!*	*!*				EXIT
*!*	*!*			ENDIF
*!*			lnError = SQLEXEC(gnHandle,lcString,'qryId')
*!*			If lnError < 0 Or !Used('qryId') Or qryId.sp_salvesta_library <= 0
*!*				Messagebox('Viga')
*!*				_Cliptext = lcString
*!*				Set Step On
*!*				Exit
*!*			Endif
*!*	* palk_lib
*!*			Select qryPalkLib
*!*			Scan For parentid = qryLib.Id

*!*				lcString = "insert into palk_lib (parentid, liik, tund, maks, palgafond, asutusest, lausendid, algoritm, muud, round, sots, konto,elatis,tululiik) values ("+;
*!*					STR(qryId.sp_salvesta_library)+","+ Str(qryPalkLib.liik)+","+ Str(qryPalkLib.tund)+","+ Str(qryPalkLib.maks)+","+ Str(qryPalkLib.palgafond)+","+;
*!*					STR(qryPalkLib.asutusest)+","+ Str(qryPalkLib.lausendid)+",'"+ qryPalkLib.algoritm+"','"+Iif(Isnull(qryPalkLib.muud),Space(1),qryPalkLib.muud)+"',"+;
*!*					STR(qryPalkLib.Round,4,2)+","+ Str(qryPalkLib.sots)+",'"+ qryPalkLib.konto+"',"+Str(qryPalkLib.elatis)+",'"+qryPalkLib.tululiik+"')"
*!*	*	WAIT WINDOW LEFT(lcString,120) nowait
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*			Endscan
*!*			Select qryKlassifLib
*!*			Scan For libid =  qryLib.Id
*!*				lcString = "insert into klassiflib (nomid, palklibid,libid,tyyp,tunnusid, kood1,kood2, kood3,kood4,kood5,konto,proj) values ("+;
*!*					"0, 0,"+Str(qryId.sp_salvesta_library)+","+Str(qryKlassifLib.tyyp)+",0,'"+qryKlassifLib.kood1+"','"+qryKlassifLib.kood2+"','"+;
*!*					qryKlassifLib.kood3+"','"+qryKlassifLib.kood4+"','"+qryKlassifLib.kood5+"','"+qryKlassifLib.konto+"','"+qryKlassifLib.Proj+"')"
*!*				lnError = SQLEXEC(gnHandle,lcString)
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					_Cliptext = lcString
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*			Endscan

*!*		Endscan
*!*	Endif


=SQLDISCONNECT(gnHandle)

