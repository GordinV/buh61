LOCAL lnresult
gnhandle = SQLCONNECT('narvalvpg','vlad','490710')
IF gnhandle < 1
	MESSAGEBOX('Viga, uhendus')
	SET STEP ON 
	return
ENDIF
lnresult = 0
lcString  = "select library.kood, tooleping.parentid, tooleping.id from tooleping inner join library on tooleping.osakondId = library.id where tooleping.rekvid = 13"

lnResult = SQLEXEC(gnhandle,lcString,'qryTootajad')
IF lnResult > 0
	=SQLEXEC(gnHandle,'begin work')
	SELECT qryTootajad
	SCAN
		WAIT WINDOW STR(RECNO('qryTootajad'))+'-'+STR(RECCOUNT('qryTootajad')) nowait
 		lcTunnus = qryTootajad.kood
*		lcTT = IIF(lcTunnus = '820101' or lcTunnus = '820101','08201','08105')
		lcString = "update journal1 set tunnus = '"+lcTunnus+"' where EMPTY(tunnus) "+;
		" and parentid in (select journalid from palk_oper where MONTH(kpv) = 6 and rekvid = 13 and journalid > 0 and "+;
		" lepingId =  "+STR(qryTootajad.id)+")"


		lnResult = SQLEXEC(gnhandle,lcString)
		IF lnresult < 1
			exit
		ENDIF
		
	ENDSCAN
	SET STEP ON 
	IF lnresult < 1
		=SQLEXEC(gnHandle,'rollback work')
		MESSAGEBOX('Viga')
		SET STEP ON 
	ELSE
		=SQLEXEC(gnHandle,'commit work')
		MESSAGEBOX('Ok')
		SET STEP ON 
 	endif		
ENDIF


=SQLDISCONNECT(gnhandle)
