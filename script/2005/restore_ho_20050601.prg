gnhandleNew = SQLConnect ('koopia','vlad','490710')
If gnhandleNew < 0
	Messagebox('Viga New connection','Kontrol')
	Set Step On
	Return
Endif

gnhandleOld = SQLConnect ('narvalvpg','vlad','490710')
If gnhandleOld < 0
	Messagebox('Viga Old connection','Kontrol')
	Set Step On
	Return
Endif


* select palk_oper from new db
SET STEP ON 
lcString = "select * from palk_oper where rekvId = 31 and (kpv = DATE(2004,12,31) or kpv = DATE(2005,01,01))"
WAIT WINDOW 'select new palkoper' NOWAIT 
lError = SQLEXEC(gnHandleNew,lcString,'qryPalkOperNew')
IF lError < 1
	MESSAGEBOX('Viga')
	SET STEP ON 
ENDIF

*!*	SELECT qryPalkOperNew
*!*	MESSAGEBOX(STR(RECCOUNT('qryPalkOperNew')))

lcString = "select * from journal where rekvId = 31 and id in (select journalId from palk_oper where rekvId = 31 and (kpv = DATE(2004,12,31) or kpv = DATE(2005,01,01)))"
WAIT WINDOW 'select new journal' NOWAIT 
lError = SQLEXEC(gnHandleNew,lcString,'qryJournal')
IF lError < 1
	MESSAGEBOX('Viga')
	SET STEP ON 
ENDIF

*!*	SELECT qryJournal
*!*	MESSAGEBOX(STR(RECCOUNT('qryJournal')))

lcString = "select * from journal1 where parentid in (select journalId from palk_oper where rekvId = 31 and (kpv = DATE(2004,12,31) or kpv = DATE(2005,01,01)))"
WAIT WINDOW 'select new journal1' NOWAIT 
lError = SQLEXEC(gnHandleNew,lcString,'qryJournal1')
IF lError < 1
	MESSAGEBOX('Viga')
	SET STEP ON 
ENDIF

*!*	SELECT qryJournal1
*!*	MESSAGEBOX(STR(RECCOUNT('qryJournal1')))



*!*		WAIT WINDOW 'Palkoper delete' nowait
*!*		IF lError > 0
*!*			lcString = " delete from palk_oper where rekvId = 31 and kpv >= DATE(2004,12,30) and kpv <= DATE(2005,01,01)"
*!*			lError = SQLEXEC(gnHandleOld,lcString)
*!*		ENDIF

lError = SQLEXEC(gnhandleOld,'begin work')
IF lError < 0
	MESSAGEBOX('Viga'+lcString)
	return
ENDIF

SET STEP ON 
SELECT qryJournal
SCAN 
	WAIT WINDOW 'Dok: '+STR(qryJournal.id,9)+STR(RECNO('qryJournal'),9)+'-'+STR(RECCOUNT('qryJournal'),9) nowait
	SELECT qryJournal1
	LOCATE FOR parentid = qryJournal.id
	IF !FOUND()
		SET STEP ON 
		lError = -1
		exit
	endif
	
	SELECT qryPalkOperNew
	LOCATE FOR journalid = qryJournal.id
	IF !FOUND()
		SET STEP ON 
		lError = -1
		exit
	endif

	* delete journal from old db
*!*		IF lError > 0
*!*			lcString = " delete from journal where id = " +STR(qryJournal.id,9)+" and rekvid = 31"
*!*			lError = SQLEXEC(gnHandleOld,lcString)
*!*		ENDIF
*!*		IF lError > 0
*!*			lcString = " delete from palk_oper where id = " +STR(qryPalkOperNew.id,9)+" and rekvId = 31 and journalId = "+STR(qryJournal.id,9)
*!*			lError = SQLEXEC(gnHandleOld,lcString)
*!*		ENDIF
	IF lError > 0
			lcString = " select sp_salvesta_journal(0,31,"+;
				STR(qryJournal.userId,9)+","+;
				IIF(qryJournal.kpv = DATE(2004,12,31),"date(2004,12,31)","date(2004,12,30)")+","+;
				STR(qryJournal.asutusId,9)+",'"+;
				qryJournal.selg+"','"+;
				qryJournal.dok+"','"+;
				qryJournal.muud+"')"
		lError = SQLEXEC(gnHandleOld,lcString,'qryId')		
		IF !USED('qryId') OR RECCOUNT('qryId') < 0
			lError = -1
		ENDIF
	ENDIF
	IF lError > 0
		lcString = "insert into journal1 (parentid,summa,kood1,kood2,kood3,kood4 ,kood5, deebet,lisa_k,kreedit,lisa_d, tunnus) values ("+;
			STR(qryId.sp_salvesta_journal,9)+","+;
			STR(qryJournal1.summa,12,2)+",'"+;
			qryJournal1.kood1+"','"+;
			qryJournal1.kood2+"','"+;
			qryJournal1.kood3+"','"+;
			qryJournal1.kood4+"','"+;
			qryJournal1.kood5+"','"+;
			qryJournal1.deebet+"','"+;
			qryJournal1.lisa_k+"','"+;
			qryJournal1.kreedit+"','"+;
			qryJournal1.lisa_d+"','"+;
			qryJournal1.tunnus+"')"
		lError = SQLEXEC(gnHandleOld,lcString)		
				
	ENDIF
	IF lError > 0
		lcString = " insert into palk_oper (rekvid,libid,lepingid,kpv ,summa,doklausid,journalid,journal1id,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus) values (31,"+;
			STR(qryPalkOperNew.libId,9)+","+;
			STR(qryPalkOperNew.lepingId,9)+","+;
			IIF(qryPalkOperNew.kpv = DATE(2004,12,31),"date(2004,12,31)","date(2004,12,30)")+","+;
			STR(qryPalkOperNew.summa,12,2)+","+;
			STR(qryPalkOperNew.doklausId,9)+","+;
			STR(qryId.sp_salvesta_journal,9)+","+;
			STR(qryPalkOperNew.journal1id,9)+",'"+;
			qryPalkOperNew.kood1+"','"+;
			qryPalkOperNew.kood2+"','"+;
			qryPalkOperNew.kood3+"','"+;
			qryPalkOperNew.kood4+"','"+;
			qryPalkOperNew.kood5+"','"+;
			qryPalkOperNew.konto+"','"+;
			qryPalkOperNew.tp+"','"+;
			qryPalkOperNew.tunnus+"')"

		lError = SQLEXEC(gnHandleOld,lcString)		

	endif				
	IF lError < 0  
		exit
	endif
ENDSCAN
lPalkoper = .f.
lJournal = .f.
lJournal1 = .f.

*!*	IF lError > 0
*!*	* test
*!*		WAIT WINDOW 'test palk_oper' nowait
*!*		lcString = "select count(id) as count from palk_oper where rekvid = 31 and kpv = DATE(2004,12,31)"
*!*			lError = SQLEXEC(gnHandleOld,lcString,'qryTest')		
*!*		IF USED('qryTest') AND qryTest.count = RECCOUNT('qryPalkOperNew')
*!*			lPalkoper = .t.

*!*			lcString = "select summa(summa) as summa from palk_oper where rekvid = 31 and kpv = DATE(2004,12,31)"
*!*			lError = SQLEXEC(gnHandleOld,lcString,'qryTest')		
*!*			SELECT qryPalkOperNew
*!*			SUM summa TO lnSumma
*!*			IF !USED('qryTest') or qryTest.summa <> lnSumma
*!*				lPalkoper = .f.
*!*			ENDIF
*!*			
*!*		ELSE
*!*			WAIT WINDOW 'test palk_oper - No' TIMEOUT 1
*!*		ENDIF
*!*		
*!*		WAIT WINDOW 'test journal' nowait
*!*			lcString = "select count(id) as count from journal where rekvid = 31 and kpv = DATE(2004,12,31) and id in (select id from palk_oper where rekvid = 31 and kpv = DATE(2004,12,31))"
*!*			lError = SQLEXEC(gnHandleOld,lcString,'qryTest')		
*!*		IF USED('qryTest') AND qryTest.count = RECCOUNT('qryJournal')
*!*			lJournal = .t.
*!*		ELSE
*!*			WAIT WINDOW 'test Journal - No' TIMEOUT 1
*!*		ENDIF

*!*		WAIT WINDOW 'test journal1' nowait
*!*			lcString = "select count(id) as count from journal1 where parentid in (select id from palk_oper where rekvid = 31 and kpv = DATE(2004,12,31))"
*!*			lError = SQLEXEC(gnHandleOld,lcString,'qryTest')		
*!*		IF USED('qryTest') AND qryTest.count = RECCOUNT('qryJournal1')
*!*			lJournal1 = .t.
*!*		ELSE
*!*			WAIT WINDOW 'test Journal1 - No' TIMEOUT 1
*!*		ENDIF

*!*		WAIT WINDOW 'test journal1' nowait
*!*			lcString = "select sum(summa) as summa from journal1 where parentid in (select id from palk_oper where rekvid = 31 and kpv = DATE(2004,12,31))"
*!*			lError = SQLEXEC(gnHandleOld,lcString,'qryTest')
*!*			SELECT qryJournal1
*!*			SUM summa TO lnSumma		
*!*		IF USED('qryTest') AND qryTest.summa = lnSumma
*!*			lJournal1 = .t.
*!*		ELSE
*!*			WAIT WINDOW 'test Journal1 - No' TIMEOUT 1
*!*		ENDIF

*!*		IF lJournal = .t. and lPalkoper = .t. and lJournal1 = .t.
*!*			MESSAGEBOX('Ok')
*!*		ELSE
*!*			lError = -1
*!*		ENDIF
*!*		

*!*	ENDIF

SET STEP ON 

IF lError > 0
	lError = SQLEXEC(gnhandleOld,'commit work')
ELSE
	lError = SQLEXEC(gnhandleOld,'rollback work')
endif

IF lError < 0
	SET STEP ON 
ENDIF


* delete palk_oper from old db

*!*	lcString = "delete from palk_oper where rekvId = 31 and kpv = DATE(2004,12,31) "
*!*	WAIT WINDOW 'delete old palkoper' NOWAIT 
*!*	lError = SQLEXEC(gnHandleNew,lcString,'qryPalkOperNew')
*!*	IF lError < 1
*!*		MESSAGEBOX('Viga')
*!*		SET STEP ON 
*!*	ENDIF


* insert new palk_oper into old

IF gnhandleNew > 0
	=SQLDISCONNECT(gnHandleNew)
ENDIF
IF gnhandleOld > 0
	=SQLDISCONNECT(gnHandleOld)
ENDIF
