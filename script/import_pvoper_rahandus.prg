Local lError
Clear All


lnSumma = 0
lnrec = 0
lnrekvId = 63
lnrekvIdvana = 1
lnError = 0

gnHandle = SQLConnect('narvalvpg','vlad','654')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lcString = 'select * from curpohivara where rekvid = '+ STR(lnRekvIdvana)
lnError = SQLEXEC(gnhandle,lcString,'qryPV' )
IF lnError < 0
	SET STEP ON 
	return
ENDIF

SET STEP ON 
lnresult=SQLEXEC(gnHandle,'begin work')

	Select qryPV
	SCAN  FOR kood <> '113107'
		WAIT WINDOW STR(RECNO('qryPV'))+'-'+STR(RECCOUNT('qryPV')) + qryPV.kood nowait
		* new kaart
		
		lcString = "select * from curPohivara where rekvid = "+ STR(lnRekvId,9) + " and kood ='" + LTRIM(RTRIM(qryPV.kood))+ "' order by id desc limit 1"
		lnError = SQLEXEC(gnhandle,lcString,'qryPVuut' )
		IF lnError < 0
			SET STEP ON 
			exit
		endif
		IF RECCOUNT('qryPVuut') > 0
		lcString = "insert into pv_oper ( parentid ,nomid , doklausid , lausendid , journalid , journal1id , liik, kpv,"+;
  			" summa ,  muud , kood1 , kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj) "+;
  			" select " + STR(qryPVuut.id,9) + ",nomid, doklausid, lausendid, journalid, journal1id, liik, kpv,"+;
  			" summa,  muud, kood1, kood2, kood3, kood4, kood5 , konto, tp, asutusid, tunnus, proj from pv_oper where parentid = " + STR(qryPV.id) +;
  			" and not EMPTY(pv_oper.kpv) and not EMPTY(pv_oper.parentid) and not EMPTY(liik) and not EMPTY(pv_oper.nomid) "

		lnError = SQLEXEC(gnhandle,lcString )
		IF lnError < 0
			SET STEP ON 
			exit
		endif

		lcString =  " select id,nomid from pv_oper where parentid = " + STR(qryPVuut.id)
		lnError = SQLEXEC(gnhandle,lcString,'qryPVoper' )
		IF lnError < 0
			SET STEP ON 
			exit
		endif
		SELECT qryPVoper
		SCAN
			WAIT WINDOW 'PV oper' nowait
			IF qryPVoper.nomid = 1 
				lnNomId = 6325
			ELSE
			
				lcString = "select * from nomenklatuur where rekvid = 63 and vanaid = " + STR(qryPVoper.nomid) 			
				lnError = SQLEXEC(gnhandle,lcString,'qryNom' )
				IF lnError < 0
					SET STEP ON 
					exit
				endif
					lnNomid = qryNom.id
			ENDIF
			lcString = "update pv_oper set nomid = " + STR(lnNomid,9) + " where id = " + STR(qryPVoper.id,9) 
			lnError = SQLEXEC(gnhandle,lcString)
			IF lnError < 0
				SET STEP ON 
				exit
			endif
		endscan
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
lcString = "SELECT id from library where kood = '"+ALLTRIM(curTt.f)+"' and library = 'TUNNUS' and rekvid = 62"
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

