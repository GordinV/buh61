Local lError
Clear All


lnSumma = 0
lnrec = 0
lnrekvId = 114
lTulemus = .t.
*SET STEP ON 
lcFile = 'c:\avpsoft\files\buh61\tmp\ko2.xls'
*lcFile1 = GETFILE()
If !File(lcFile)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif


Import From (lcFile) TYPE XLS SHEET '0922060'
* lcAsutus = '0810502 Narva Kunstikool'
 lcRekvId = ALLTRIM(STR(LNrEKVID,3))
* 6 kool
lcNumber = '1'

select a as allikas, b as tegev, c as kulu, f as selg, d as summa, e as tunnus From KO2 WHERE ALLTRIM(a) <> 'w' Into Cursor curKO

gnHandle = SQLConnect('narvalvpg','vlad')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif
*/lnresult=SQLEXEC(gnHandle,'begin work')


lcString = "insert into taotlus (rekvid,koostajaid,ametnikid,aktseptid,kpv,number,aasta,muud, staatus) values ("+;
	lcRekvId+",60,0,0,DATE(2013,01,01),'"+lcNumber+"',2013,'import',1)"

lnError = SQLEXEC(gnHandle,lcString)
IF lnError < 0
	SET STEP ON 
	return
ENDIF

lcString = "select id from taotlus order by id desc limit 1"

lnError = SQLEXEC(gnHandle,lcString,'qryId')

IF lnError < 0 OR !USED('qryId')
	SET STEP ON 
	return
ENDIF

lTulemus = .f.

*brow
SELECT curKO

SCAN
	WAIT WINDOW 'Import:'+ STR(RECNO('curKo'))+'/'+STR(RECCOUNT('curKo')) nowait
	lcKulu = ALLTRIM(curKo.kulu)
*!*		IF !EMPTY(curKo.kulu2)
*!*			lcKulu = curKo.kulu2
*!*		ENDIF 
*!*		IF !EMPTY(curKo.kulu3)
*!*			lcKulu = curKo.kulu3
*!*		ENDIF 
	lcAllikas = curKo.allikas
	IF VAL(ALLTRIM(curKO.summa)) > 0 
		lcString = "insert into taotlus1 (parentid, eelprojid, eelarveid,kood1,kood2,kood3,kood4,kood5,proj,tunnus,summa,selg,markused) values ("+;
		STR(qryId.id,9)+",0,0,'"+curKo.tegev+"','"+lcAllikas+"','','','"+lcKulu+"','','"+ALLTRIM(curKo.tunnus)+"',"+curKO.summa+",'"+curKO.selg+"','import')"

		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			lTulemus = .f. 
			SET STEP on
			EXIT
		ELSE
			lTulemus = .t.
		ENDIF
	ENDIF
	
	
ENDSCAN

USE IN curKO

*!*	If lTulemus = .t.
*!*		=SQLEXEC(gnHandle,'commit work')
*!*	Else
*!*		Set Step On
*!*		=SQLEXEC(gnHandle,'rollback work')
*!*	Endif

=SQLDISCONNECT(gnHandle)
return

