CLEAR all
WAIT WINDOW 'Ühendan narvalv' nowait
gnHdlNarvalv = SQLCONNECT('NarvaLvPg','vlad','490710')
IF gnHdlNarvalv < 0
	SET STEP ON 
	RETURN
ENDIF
WAIT WINDOW 'Ühendan narvalv: edukalt' TIMEOUT 1
WAIT WINDOW 'Ühendan koopia4' nowait

gnHdlKoopia4 = SQLCONNECT('koopia4','vlad','490710')
IF gnHdlKoopia4 < 0
	SET STEP ON 
	RETURN
ENDIF
WAIT WINDOW 'Ühendan koopia4: edukalt' TIMEOUT 1
WAIT WINDOW 'select Journal' nowait
lcString = 'select * from journal where rekvId = 11'
lError = SQLEXEC(gnHdlKoopia4,lcString,'v_journal')
IF lError < 1
	SET STEP ON 
	return
endif
WAIT WINDOW 'select Journal: edukalt' TIMEOUT 1
WAIT WINDOW 'select Journal1' nowait

lcString = 'select * from journal1 where parentid in (select id from journal where rekvId = 11)'
lError = SQLEXEC(gnHdlKoopia4,lcString,'v_journal1')
IF lError < 1
	SET STEP ON 
	return
ENDIF
WAIT WINDOW 'select Journal1: edukalt' nowait
*!*	WAIT WINDOW 'select JournalId' nowait
*!*	lcString = 'select * from journalId where journalid in (select id from journal where rekvId = 11)'
*!*	lError = SQLEXEC(gnHdlKoopia4,lcString,'v_journalId')
*!*	IF lError < 1
*!*		SET STEP ON 
*!*		return
*!*	endif
	lnresult = 0
		lnSumma = 0
		lnRec = 0
lnresult = SQLEXEC(gnHdlNarvalv,'begin work')
IF lnResult < 1
	SET STEP ON 
endif
SELECT v_journal
SCAN
	WAIT WINDOW STR(RECNO('v_journal'))+'-'+STR(RECCOUNT('v_journal')) nowait
		lcdate = "date ("+STR(YEAR(v_journal.kpv),4)+","+STR(MONTH(v_journal.kpv),2)+","+STR(DAY(v_journal.kpv),2)+")"
		lcSelg = v_journal.selg
		lnStart = AT("'",lcSelg)
		IF lnStart > 0
				lcSelg = SPACE(1)
		ENDIF
		lnStart = AT('"',lcSelg)
		IF lnStart > 0
			lcSelg = SPACE(1)
		ENDIF
		
	
			lcString = "insert into journal (kpv, asutusId, rekvId, userId, selg, dok, muud) values ("+;
				lcdate+","+STR(v_journal.AsutusId,9)+",11,"+STR(v_journal.userid,9)+",'"+lcSelg+"','"+v_journal.Dok+"','"+v_journal.Muud+"')"

			lnresult = SQLEXEC(gnHdlNarvalv,lcString)


		If lnresult > 0

			lcString = 'select id from journal where rekvid = 11 order by id desc limit 1'
			lnresult = SQLEXEC(gnHdlNarvalv,lcString,'qrylastId')
			IF RECCOUNT('qrylastId') < 1
				lnResult = -1
			endif
			
		Endif


		If lnresult > 0 
			SELECT v_journal1
			SCAN FOR parentId = v_journal.id
			lcString = "insert into journal1 (parentId, deebet, lisa_d, kreedit, lisa_k, summa, tunnus, kood1, kood2, kood3, kood4, kood5) values ("+;
				STR(qryLastid.Id)+",'"+v_journal1.Deebet+"','"+v_journal1.lisa_d+"','"+v_journal1.Kreedit+"','"+v_journal1.lisa_k+"',"+STR(v_journal1.Summa,12,4)+",'"+;
				v_journal1.tunnus+"','"+v_journal1.Kood1+"','"+v_journal1.Kood2+"','"+v_journal1.Kood3+"','"+v_journal1.Kood4+"','"+v_journal1.Kood5+"')"

			lnSumma = lnSumma + v_journal1.Summa
	
			lnrec = lnrec  + 1
			lnresult = SQLEXEC(gnHdlNarvalv,lcString)
			ENDSCAN
			
		Endif
		If lnresult > 0
			lcString = "select number from journalId where journalId = "+STR(v_journal.id,9)
			lnresult = SQLEXEC(gnHdlNarvalv,lcString,'v_journalId')
			
		ENDIF
		If lnresult > 0
			lcString = " UPDATE journalId set number = "+STR(v_journalId.number,9)+" where journalId = "+STR(qryLastid.Id,9)
			lnresult = SQLEXEC(gnHdlNarvalv,lcString)
		ENDIF
		IF lnresult < 1
			exit
		endif
			
ENDSCAN
IF lnResult > 0
	=SQLEXEC(gnHdlNarvalv,'commit')
	MESSAGEBOX('Ok'+STR(lnSumma,12,2)+'-'+STR(lnrec,9))
ELSE
	=SQLEXEC(gnHdlNarvalv,'rollback')
	SET STEP ON 

endif





IF gnHdlKoopia4 > 0
	=SQLDISCONNECT(gnHdlKoopia4)
ENDIF




IF gnHdlNarvalv > 0
	=SQLDISCONNECT(gnHdlNarvalv)
ENDIF

