Local lError
Clear All


lnSumma = 0
lnrec = 0
lnrekvId = 72
lnrekvIdvana = 21
lnError = 0

gnHandle = SQLConnect('narvalvpg','vlad','654')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif


lnPvGruppIdVana = 558560
lnPvGruppId = 124725


lcString = 'select * from curpohivara where rekvid = '+ STR(lnRekvIdvana) +' and gruppid = '+str(lnPvGruppIdVana,9)
lnError = SQLEXEC(gnhandle,lcString,'qryPV' )
IF lnError < 0
	SET STEP ON 
	return
ENDIF

*SET STEP ON 
lnresult=SQLEXEC(gnHandle,'begin work')

	Select qryPV
	SCAN  
		WAIT WINDOW STR(RECNO('qryPV'))+'-'+STR(RECCOUNT('qryPV')) + qryPV.kood nowait
		* new kaart
		
		lcString = "select * from curPohivara where rekvid = "+ STR(lnRekvId,9) + " and kood ='" + LTRIM(RTRIM(qryPV.kood))+ "' order by id desc limit 1"
		lnError = SQLEXEC(gnhandle,lcString,'qryPVuut' )
		IF lnError < 0
			SET STEP ON 
			exit
		endif
		IF RECCOUNT('qryPVuut') = 0
			* teeme uut kaart
		
			lcString = "insert into library(rekvid, kood, nimetus, library,tun1, tun2, tun3, tun4, tun5, muud) "+;
				" select "+str( lnRekvId,9)+", kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud from library where id = "+;
				 str(QRYpv.ID,9) 

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif

		* UUT ID

			lcString = "select id from library where rekvid = "+ STR(lnRekvId,9) + " order by id desc limit 1"
			lnError = SQLEXEC(gnhandle,lcString,'qryPVId' )
			IF lnError < 0
				SET STEP ON 
				exit
			endif

		* pv_kaart
		
		
			lcString = "insert into pv_kaart (parentid, vastisikId, soetmaks, soetkpv, kulum, algkulum, gruppid, konto, mahakantud,"+;
				"otsus, muud, tunnus, parhind) "+;
				" SELECT "+ str(qryPVId.id,9)+", Pv_kaart.vastisikid, Pv_kaart.soetmaks, Pv_kaart.soetkpv, Pv_kaart.kulum, Pv_kaart.algkulum, "+;
				str(lnPvGruppId,9)+", Pv_kaart.konto, Pv_kaart.mahakantud, Pv_kaart.otsus, 'NARVA NOORTE MEREMEESTE KLUBI',Pv_kaart.tunnus, Pv_kaart.parhind "+;
				" FROM pv_kaart where parentid = "+str(QRYpv.ID,9) 
 
			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif
			
		* pv_oper				
			* paigutus
			
			lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
	  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
	  			" select " + STR(qryPVId.id,9) + ",21467, doklausid, lausendid, 0, 0, liik, kpv,"+;
	  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
	  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and liik = 1 and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif


			* kulum
			
			lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
	  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
	  			" select " + STR(qryPVId.id,9) + ",8541, doklausid, lausendid, 0, 0, liik, kpv,"+;
	  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
	  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and liik = 2 and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif

			* parandus
			
			lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
	  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
	  			" select " + STR(qryPVId.id,9) + ",8640, doklausid, lausendid, 0, 0, liik, kpv,"+;
	  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
	  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and liik = 3 and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif

			* mahakandmine
			
			lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
	  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
	  			" select " + STR(qryPVId.id,9) + ",8649, doklausid, lausendid, 0, 0, liik, kpv,"+;
	  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
	  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and liik = 4 and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif
			* umberhindamine
			
			lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
	  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
	  			" select " + STR(qryPVId.id,9) + ",21466, doklausid, lausendid, 0, 0, liik, kpv,"+;
	  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
	  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and liik = 5 and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

			lnError = SQLEXEC(gnhandle,lcString )
			IF lnError < 0
				SET STEP ON 
				exit
			endif

		endif
	ENDSCAN


If lnError > 0
	=SQLEXEC(gnHandle,'commit work')
	Messagebox('Ok, summa:'+Str(lnSumma,12,2))
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif




=SQLDISCONNECT(gnHandle)

	

FUNCTION get_tunnus
LOCAL lcString
IF EMPTY(curTt.f)
	RETURN 0
ENDIF
lcString = "SELECT id from library where kood = '"+ALLTRIM(curTt.f)+"' and library = 'TUNNUS' and rekvid = 119"
IF SQLEXEC(gnHandle,lcString) < 0
	MESSAGEBOX('Viga')
	lTulemus = .f.
	SET STEP ON 
ELSE
	RETURN sqlresult.id
ENDIF

ENDFUNC



Function transdigit

	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc
