gnHandleSped = SQLConnect('sped','vlad','490710')

lcString = "select * from library "
lError = SQLEXEC(gnHandleSped,lcString,'qryLib')

lcString = "select * from nomenklatuur "
lError = SQLEXEC(gnHandleSped,lcString,'qryNom')

lcString = "select * from dokprop "
lError = SQLEXEC(gnHandleSped,lcString,'qryDok')

lcString = "select * from holidays"
lError = SQLEXEC(gnHandleSped,lcString,'qryHol')

lcString = "select * from klassiflib"
lError = SQLEXEC(gnHandleSped,lcString,'qryKlass')

lcString = "select * from palk_asutus"
lError = SQLEXEC(gnHandleSped,lcString,'qryPalkA')

lcString = "select * from palk_lib"
lError = SQLEXEC(gnHandleSped,lcString,'qryPalkL')

=SQLDISCONNECT(gnHandleSped)

gnHandleEkavid = SQLConnect('ekavid','vlad','490710')
=SQLEXEC(gnHandleEkavid,'begin work')

lcString = "update pg_trigger set tgenabled = false"
lnError = SQLEXEC(gnHandleEkavid,lcString)


lnError = imp_lib() 
lnError = 1
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_nom() 
*!*	ENDIF
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_dok() 
*!*	ENDIF
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_hol() 
*!*	ENDIF
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_klass() 
*!*	ENDIF
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_palkA() 
*!*	ENDIF
*!*	IF !EMPTY(lnError)
*!*		lnError = imp_palkL() 
*!*	ENDIF

IF !EMPTY(lnError)
	lcString = "update pg_trigger set tgenabled = true"
	lnError = SQLEXEC(gnHandleEkavid,lcString)
	=SQLEXEC(gnHandleEkavid,'commit work')
ELSE
	=SQLEXEC(gnHandleEkavid,'rollback work')
ENDIF

=SQLDISCONNECT(gnhandleEkavid)

Function imp_PalkL
	Local lError
		Select qryPalkL
		SCAN
			lcString = "delete from palk_lib where id = "  + STR(qryPalkL.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
		
			lcString = "insert into palk_lib (id, parentid, liik, tund, maks, algoritm, asutusest, palgafond,round,"+;
				" sots,konto,elatis,tululiik, muud) values ("+;
				STR(qryPalkL.Id)+","+STR(qryPalkL.parentId)+","+Str(qryPalkL.liik)+","+Str(qryPalkL.tund)+;
				","+Str(qryPalkL.maks)+",'"+(qryPalkL.algoritm)+"',"+Str(qryPalkL.asutusest)+","+Str(qryPalkL.palgafond)+","+;
				Str(qryPalkL.round,12,2)+","+str(qryPalkL.sots)+",'"+(qryPalkL.konto)+"',"+Str(qryPalkL.elatis)+",'"+(qryPalkL.tululiik)+"','"+;
				IIF(Isnull(qryPalkL.muud),Space(1),qryPalkL.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)

		Endscan
	USE IN qryPalkL
	Return lError
Endfunc


Function imp_PalkA
	Local lError
		Select qryPalkA
		SCAN
			lcString = "delete from palk_asutus where id = "  + STR(qryPalkA.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
				
			Endif
				
			lcString = "insert into palk_asutus (id, rekvid, OsakondId, ametId, kogus, vaba, palgamaar, muud) values ("+;
				STR(qryPalkA.Id)+","+STR(qryPalkA.rekvId)+","+Str(qryPalkA.osakondid)+","+Str(qryPalkA.ametId)+;
				","+Str(qryPalkA.kogus)+","+Str(qryPalkA.vaba)+","+Str(qryPalkA.palgamaar)+",'"+;
				IIF(Isnull(qryPalkA.muud),Space(1),qryPalkA.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryPalkA
	Return lError
Endfunc

Function imp_klass
	Local lError
		Select qryKlass
		SCAN
			lcString = "delete from klassiflib where id = "  + STR(qryKlass.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif
		
		
			lcString = "insert into klassiflib (id, nomid, palklibId, libId, tyyp, tunnusid, kood1, kood2,kood3, kood4, kood5, proj) values ("+;
				STR(qryKlass.Id)+","+STR(qryKlass.nomId)+","+Str(qryKlass.palklibid)+","+Str(qryKlass.libId)+;
				","+Str(qryKlass.tyyp)+","+Str(qryKlass.tunnusId)+",'"+(qryKlass.kood1)+"','"+(qryKlass.kood2)+"','"+;
				(qryKlass.kood3)+"','"+(qryKlass.kood4)+"','"+(qryKlass.kood5)+"','"+(qryKlass.proj)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryKlass
	Return lError
Endfunc


Function imp_hol
	Local lError
		Select qryHol
		SCAN
			lcString = "delete from holidays where id = "  + STR(qryHol.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		
			lcString = "insert into holidays (id, rekvid, kuu, paev, nimetus, luhipaev, muud) values ("+;
				STR(qryHol.Id)+","+STR(qryHol.rekvId)+","+Str(qryHol.kuu)+","+Str(qryHol.paev)+",'"+;
				(qryHol.nimetus)+"',"+str(qryHol.luhipaev)+",'"+IIF(Isnull(qryHol.muud),Space(1),qryHol.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryHol
	Return lError
Endfunc



Function imp_dok
	Local lError
		Select qryDok
		SCAN
			lcString = "delete from dokprop where id = "  + STR(qryDok.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif
		
			lcString = "insert into dokprop (id, parentid, selg, registr, tyyp, asutusId, vaatalaus, konto, kbmkonto,kood1,kood2,kood3,kood4,kood5, muud) values ("+;
				STR(qryDok.Id)+","+STR(qryDok.parentId)+",'"+qryDok.selg+"',"+Str(qryDok.registr)+","+Str(qryDok.tyyp)+ ","+Str(qryDok.asutusId)+","+;
				STR(qryDok.vaatalaus)+",'"+(qryDok.konto)+"','"+(qryDok.kbmkonto)+"','"+(qryDok.kood1)+"','"+(qryDok.kood2)+"','"+(qryDok.kood3)+"','"+(qryDok.kood4)+"','"+(qryDok.kood5)+"','"+IIF(Isnull(qryDok.muud),Space(1),qryDok.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryDok
	Return lError
Endfunc



Function imp_nom
	Local lError
		Select qryNom
		Scan
			lcString = "delete from nomenklatuur where id = "  + STR(qryNom.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif
			lcString = "insert into nomenklatuur (id, rekvid, kood, nimetus, dok, uhik, hind, kogus,formula,  muud) values ("+;
				STR(qryNom.Id)+",1,'"+qryNom.kood+"','"+qryNom.nimetus+"','"+qryNom.dok + "','"+;
				qryNom.uhik+"',"+Str(qryNom.hind,12,2)+","+Str(qryNom.kogus,12,3)+;
				",'"+(qryNom.formula)+"','"+IIF(Isnull(qryNom.muud),Space(1),qryNom.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryNom

	Return lError
Endfunc


Function imp_lib
	Local lError
		Select qryLib
		Scan
			lcString = "delete from library where id = "  + STR(qryLib.id)
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			ENDIF
			IF LEN(ALLTRIM(qryLib.kood)) = 3 AND library = 'KONTOD'
				WAIT WINDOW 'Konto 3 digit, ignoreme' nowait
			else
			lcString = "insert into library (id, rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values ("+;
				STR(qryLib.Id)+",1,'"+qryLib.kood+"','"+qryLib.nimetus+"','"+;
				qryLib.Library+"',"+Str(qryLib.tun1)+","+Str(qryLib.tun2)+","+;
				STR(qryLib.tun3)+","+Str(qryLib.tun4)+","+Str(qryLib.tun5)+",'"+;
				IIF(Isnull(qryLib.muud),Space(1),qryLib.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			ENDIF
			
			If lError < 1
				IF AERROR(err) > 0
					lcErr = err(1,3)
					WAIT WINDOW lcErr 
				ENDIF
			Endif

		Endscan
	USE IN qryLib 

	Return lError
Endfunc
