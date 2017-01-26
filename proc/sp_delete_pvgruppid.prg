 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 leRror = .T.
 WITH odB
      .usE('v_library')
 cKood = '%'
tcNimetus = '%'
tcKonto = '%'
tcVastIsik = '%'
tcGrupp = ltrim(rtrim(library.nimetus))+'%'
tnSoetmaks1 = 0
tnSoetmaks2 = 99999999
tdSoetkpv1 = DATE(1900,1,1)
tdSoetkpv2 = DATE()
tnTunnus = 1
.use ('curPohivara','qryPohivara')
IF RECCOUNT('qryPohivara') < 1
	tnTunnus = 0
	.use ('curPohivara','qryPohivara')
endif
IF RECCOUNT('qryPohivara') > 0
	SELECT qryPohivara
	LOCATE FOR GRUPPID = TNID
	IF FOUND()
		lError = .f.
	endif
ENDIF
USE IN qryPohivara
 IF lError = .f.
 	MESSAGEBOX(IIF(config.keel = 2,'Ei saa kustuda PV grupp','Удаление группы запрещено'),'Kontrol')
 endif
RETURN .f.
      .opEntransaction()
      SELECT v_library
      DELETE NEXT 1
      leRror = .cuRsorupdate('v_library')
      IF leRror=.F.
           .roLlback()
      ELSE
           .coMmit
      ENDIF
 ENDWITH
 RETURN .T.
ENDFUNC
*
