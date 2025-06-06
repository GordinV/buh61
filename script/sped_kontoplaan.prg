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

lnError = imp_lib() 

IF lnError > 0
	lnError = imp_nom() 
ENDIF
IF lnError > 0
	lnError = imp_dok() 
ENDIF
IF lnError > 0
	lnError = imp_hol() 
ENDIF
IF lnError > 0
	lnError = imp_klass() 
ENDIF
IF lnError > 0
	lnError = imp_palkA() 
ENDIF
IF lnError > 0
	lnError = imp_palkL() 
ENDIF

IF lnError > 0
	=SQLEXEC(gnHandleEkavid,'commit work')
ELSE
	=SQLEXEC(gnHandleEkavid,'rollback work')
ENDIF

=SQLDISCONNECT(gnhandleEkavid)

Function imp_qryPalkL
	Local lError
	lcString = "delete from palk_lib "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryPalkL
		Scan
			lcString = "insert into palk_lib (id, parentid, liik, tund, maks, algoritm, asutusest, palgafond,round,"+;
				" sots,konto,elatis,tululiik, muud) values ("+;
				STR(qryPalkL.Id)+","+STR(qryPalkL.parentId)+","+Str(qryPalkL.liik)+","+Str(qryPalkL.tund)+;
				","+Str(qryPalkL.maks)+",'"+(qryPalkL.algoritm)+"',"+Str(qryPalkL.asutussest)+","+Str(qryPalkL.palgafond)+","+;
				Str(qryPalkL.round,12,2)+","+str(qryPalkL.sots)+",'"+(qryPalkL.konto)+"',"+Str(qryPalkL.elatis)+",'"+(qryPalkL.tululiik)+",'"+;
				IIF(Isnull(qryPalkL.muud),Space(1),qryPalkL.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryPalkL
	Return lError
Endfunc


Function imp_PalkA
	Local lError
	lcString = "delete from palk_asutus "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryPalkA
		Scan
			lcString = "insert into palk_asutus (id, rekvid, OsakondId, ametId, kogus, vaba, palgamaar, tunnusid, muud) values ("+;
				STR(qryPalkA.Id)+","+STR(qryPalkA.rekvId)+","+Str(qryPalkA.osakondid)+","+Str(qryPalkA.ametId)+;
				","+Str(qryPalkA.kogus)+","+Str(qryPalkA.vaba)+","+Str(qryPalkA.palgamaar)+","+Str(qryPalkA.tunnusid)+",'"+;
				IIF(Isnull(qryPalkA.muud),Space(1),qryPalkA.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryPalkA
	Return lError
Endfunc

Function imp_klass
	Local lError
	lcString = "delete from klassiflib "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryKlass
		Scan
			lcString = "insert into klassiflib (id, nomid, palklibId, libId, tyyp, tunnusid, kood1, kood2,kood3, kood4, kood5, proj, muud) values ("+;
				STR(qryKlass.Id)+","+STR(qryKlass.nomId)+","+Str(qryKlass.palklibid)+","+Str(qryKlass.libId)+;
				","+Str(qryKlass.tyyp)+","+Str(qryKlass.tunnusId)+",'"+Str(qryKlass.kood1)+"','"+Str(qryKlass.kood2)+"','"+;
				Str(qryKlass.kood3)+"','"++Str(qryKlass.kood4)+"','"++Str(qryKlass.kood5)+"','"++Str(qryKlass.proj)+"','"+;
				IIF(Isnull(qryKlass.muud),Space(1),qryKlass.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryKlass
	Return lError
Endfunc


Function imp_hol
	Local lError
	lcString = "delete from holidays "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryHol
		Scan
			lcString = "insert into holidays (id, rekvid, kuu, paev, nimetus, luhipaev, muud) values ("+;
				STR(qryHol.Id)+","+STR(qryHol.rekvId)+","+Str(qryHol.kuu)+","+Str(qryHol.paev)+",'"+;
				(qryHol.nimetus)+"',"+str(qryHol.luhipaev)+",'"+IIF(Isnull(qryHol.muud),Space(1),qryHol.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryHol
	Return lError
Endfunc



Function imp_dok
	Local lError
	lcString = "delete from dokprop "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryDok
		Scan
			lcString = "insert into dokprop (id, parentid, selg, registr, tyyp, asutusId, vaatalaus, konto, kbmkonto,kood1,kood2,kood3,kood4,kood5, muud) values ("+;
				STR(qryDok.Id)+","+STR(qryDok.parentId)+",'"+qryDok.selg+","+Str(qryDok.registr)+","+Str(qryDok.asutusId)+","+;
				STR(qryDok.vaatalaus)+",'"+(qryDok.konto)+"','"+(qryDok.kbmkonto)+"','"+(qryDok.kood1)+"','"+(qryDok.kood2)+"','"+(qryDok.kood3)+"','"+(qryDok.kood4)+"','"+(qryDok.kood5)+"','"+IIF(Isnull(qryDok.muud),Space(1),qryDok.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryDok
	Return lError
Endfunc



Function imp_nom
	Local lError
	lcString = "delete from nomenklatuur "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryNom
		Scan
			lcString = "insert into nomenklatuur (id, rekvid, kood, nimetus, uhik, hind, kogus, kbm, muud) values ("+;
				STR(qryNom.Id)+",1,'"+qryNom.kood+"','"+qryNom.nimetus+"','"+;
				qryNom.uhik+"',"+Str(qryNom.hind,12,2)+","+Str(qryNom.kogus,12,3)+","+;
				STR(qryNom.kbm)+",'"+(qryNom.formula)+"','"+IIF(Isnull(qryNom.muud),Space(1),qryNom.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryNom

	Return lError
Endfunc


Function imp_lib
	Local lError
	lcString = "delete from library "
	lError = SQLEXEC(gnHandleEkavid,lcString)
	If lError > 0
		Select qryLib
		Scan
			lcString = "insert into library (id, rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values ("+;
				STR(qryLib.Id)+",1,'"+qryLib.kood+"','"+qryLib.nimetus+"','"+;
				qryLib.Library+"',"+Str(qryLib.tun1)+","+Str(qryLib.tun2)+","+;
				STR(qryLib.tun3)+","+Str(qryLib.tun4)+","+Str(qryLib.tun5)+",'"+;
				IIF(Isnull(qryLib.muud),Space(1),qryLib.muud)+"')"
			lError = SQLEXEC(gnHandleEkavid,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif

		Endscan


	Endif
	USE IN qryLib 

	Return lError
Endfunc

