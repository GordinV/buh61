PARAMETER tnLeping, tdKpv, tnTyyp
*!*	LOCAL lnSumma, llOpt
*!*	lnSumma = 0
*!*	WITH odb
*!*		IF tnTyyp=3
*!*			IF  .NOT. USED('qryconfig')
*!*				.usE('v_palk_config','qryconfig')
*!*			ENDIF
*!*			lnSumma = frOund(qrYconfig.miNpalk/28,1)
*!*			RETURN lnSumma
*!*		ENDIF

*!*	tnId = tnleping
*!*	IF !USED ('comTootajad')
*!*		.use ('comTootajad')
*!*	ENDIF
*!*	SELECT comTootajad
*!*	LOCAte for id = tnleping
*!*		tcNimetus = '%'
*!*		tcIsik = ltrim(rtrim(comTootajad.nimetus))+'%'
*!*		tcLiik = '+%'
*!*		tcTund = '%'
*!*		tcMaks = '%'
*!*		dkPv2 = DATE(YEAR(tdKpv), MONTH(tdKpv), 1)
*!*		dkPv1 = GOMONTH(tdKpv, -6)
*!*		tnSumma1 = -999999999
*!*		tnSumma2 = 999999999
*!*		.usE('curPalkOper','qrypluus')
*!*		IF RECCOUNT('qrypluus')>0
*!*			* MUUDETUD 22/08/2005
*!*			SELECT SUM(suMma) AS suMma, MONTH(kpV) AS kuU, YEAR(kpV) AS aaSta,  ;
*!*				(GOMONTH(DATE(YEAR(kpV), MONTH(kpV), 1), 1)-1-DATE(YEAR(kpV),  ;
*!*				MONTH(kpV), 1))-puHapaevad(DATE(YEAR(kpV), MONTH(kpV), 1), ;
*!*				GOMONTH(DATE(YEAR(kpV), MONTH(kpV), 1), 1)-1) AS paEvad FROM  ;
*!*				qrypluus GROUP BY kpV ORDER BY kpV   INTO CURSOR qry1
*!*	*		where lepingid = tnLeping	
*!*			USE IN qrypluus
*!*			lnSumma = 0
*!*			llOpt = .F.
*!*			SCAN
*!*				IF EMPTY(lnSumma)
*!*					lnSumma = qry1.suMma
*!*				ENDIF
*!*				IF lnSumma<>qry1.suMma
*!*					llOpt = .T.
*!*					EXIT
*!*				ENDIF
*!*			ENDSCAN
*!*			IF llOpt=.T.
*!*				SELECT SUM(suMma) AS suMma, SUM(paEvad) AS paEvad FROM qry1  ;
*!*					INTO CURSOR qry2
*!*				lnSumma = qry2.suMma/qry2.paEvad
*!*			ENDIF
*!*			IF lnSumma=0
*!*				llOpt = .F.
*!*				tnId = tnLeping
*!*				.usE('qryTooleping')
*!*				lnSumma = qrYtooleping.paLk
*!*				USE IN qrYtooleping
*!*			ENDIF
*!*		ENDIF
*!*		IF llOpt=.F. .AND. lnSumma>0
*!*			lnSumma = lnSumma/(GOMONTH(DATE(YEAR(tdKpv), MONTH(tdKpv), 1), 1)-1- ;
*!*				DATE(YEAR(tdKpv), MONTH(tdKpv), 1))- ;
*!*				puHapaevad(DATE(YEAR(tdKpv), MONTH(tdKpv), 1), ;
*!*				GOMONTH(DATE(YEAR(tdKpv), MONTH(tdKpv), 1), 1)-1)
*!*		ENDIF
*!*		IF USED('qry1')
*!*			USE IN qry1
*!*		ENDIF
*!*		IF USED('qry2')
*!*			USE IN qry2
*!*		ENDIF
*!*	ENDWITH
*!*	RETURN lnSumma
RETURN 0
ENDFUNC
*
