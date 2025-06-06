gnHandle = SQLCONNECT('narvalvpg')
IF gnHandle < 1
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF


lcString = "SELECT * from doklausheader WHERE rekvid = 127 ORDER BY id"

lnError = SQLEXEC(gnHandle,lcString, 'tmpDokPea')
IF lnError < 0
	messagebox('Viga')
	SET STEP ON 
ENDIF
IF USED('tmpDokPea')
	SELECT tmpDokPea
	SCAN
		WAIT WINDOW 'import :'+STR(RECNO('tmpDokPea'))+'/'+STR(RECCOUNT('tmpDokPea')) nowait
		lcString = 'SELECT * from doklausend WHERE parentid = '+STR(tmpDokPea.id)
		lnError = SQLEXEC(gnHandle,lcString, 'tmpDokLaus')
		IF lnError < 1 OR !USED('tmpDokPea')
			MESSAGEBOX('Viga')
			SET STEP on
			exit
		ENDIF		

		lcString = "insert into doklausheader (rekvid, dok, proc_ , selg,  muud) values (128,'"+;
			tmpDokPea.dok+"','"+tmpDokPea.proc_+"','"+tmpDokPea.selg+"','"+IIF(ISNULL(tmpDokPea.muud),SPACE(1),tmpDokPea.muud)+"')"

		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			MESSAGEBOX('Viga')
			SET STEP ON 
			exit
		ENDIF
		lcString = "select id from  doklausheader where rekvid = 128 order by id desc limit 1"
		lnError = SQLEXEC(gnHandle,lcstring,'tmpId')
		IF lnError < 0 or !USED('tmpId') OR EMPTY(tmpId.id)
			MESSAGEBOX('Viga')
			SET STEP ON 
			exit
		ENDIF
		SELECT tmpDokLaus
		scan
			lcString = "insert into doklausend (parentid, summa,muud,kood1,kood2,kood3,kood4,kood5,deebet,kreedit,lisa_d,lisa_k) values("+;
				STR(tmpId.id)+","+STR(tmpDokLaus.summa,14,2)+",'"+IIF(ISNULL(tmpDokLaus.muud),SPACE(1),tmpDokLaus.muud)+"','"+;
				tmpDokLaus.kood1+"','"+tmpDokLaus.kood2+"','"+tmpDokLaus.kood3+"','"+tmpDokLaus.kood4+"','"+tmpDokLaus.kood5+"','"+;
				tmpDokLaus.deebet+"','"+tmpDokLaus.kreedit+"','"+tmpDokLaus.lisa_d+"','"+tmpDokLaus.lisa_k+"')"
				
			lnError = SQLEXEC(gnHandle,lcString)	
			IF lnError < 0
				MESSAGEBOX('Viga')
				SET STEP ON 
				exit
			ENDIF
			
		ENDSCAN
		IF lnError < 0
			exit
		ENDIF
				
	ENDSCAN
	
ENDIF


=SQLDISCONNECT(gnHandle)

