SET STEP on
gnHandleNarva = SQLCONNECT('NarvaLvPg')
IF gnHandleNarva < 1 
	MESSAGEBOX('gnHandleNarva','Viga')
	SET STEP ON 
	return
ENDIF
gnHandleNJ = SQLCONNECT('njlv2012')
IF gnHandleNJ < 1 
	MESSAGEBOX('gnHandleNJ','Viga')
	SET STEP ON 
	return
ENDIF

lnError = SQLEXEC(gnHandleNarva,"select * from library where LTRIM(RTRIM(library)) = 'TULUDEALLIKAD'",'tmpLib')

IF lnError > 0
	lnError = SQLEXEC(gnHandleNJ,"select * from library where LTRIM(RTRIM(library)) = 'TULUDEALLIKAD'",'tmpLibNJ')

	SELECT tmpLib
	SCAN
		WAIT WINDOW 'Loen:'+ALLTRIM(STR(RECNO('tmpLib')))+'/'+ALLTRIM(STR(RECCOUNT('tmpLib'))) nowait
		* loeme njlv andmed
		SELECT tmpLibNJ
		LOCATE FOR kood = tmplib.kood
		IF FOUND() AND tmpLibNJ.tun5 <> tmplib.tun5
			lcString = "update library set tun5 = "+STR(tmplib.tun5) +" where id = "+STR(tmpLibNJ.id)
			lnError = SQLEXEC(gnHandleNJ,lcString)
			IF lnError < 1
				SET STEP ON 
				exit
			ENDIF
		ENDIF	
	ENDSCAN
	
ELSE
	SET STEP ON 
ENDIF

=SQLDISCONNECT(gnHandleNarva)
=SQLDISCONNECT(gnHandleNJ)