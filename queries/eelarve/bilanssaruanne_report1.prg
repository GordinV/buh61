PARAMETER cWhere
IF vartype (cWhere) = 'C' and isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
ENDIF
LOCAL lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
tcTunnus = '%'
lnDeebet = 0
lnKreedit = 0
dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
REPLACE fltrAruanne.kpv1 with dKpv1,;
	fltrAruanne.kpv2 with dKpv2 in fltrAruanne
&& loading algsaldo tableid
WITH oDb
	lError = .exec ("sp_saldo ",str(grekv)+", "+str(Month(dKpv1),2)+","+str(Year(dKpv1),4)+",'%'", 'cursorAlgSaldo' )
	lError = .exec ("sp_saldo ",str(grekv)+", "+str(Month(dKpv2),2)+","+str(Year(dKpv2),4)+",'%'", 'cursorLoppSaldo' )
	.use('v_bilanss')
	SELECT v_bilanss
	INDEX ON VAL(ALLTRIM(v_bilanss.kood)) TAG REANR
	SET ORDER TO REANR

	IF reccount('v_bilanss') = 0
		MESSAGEBOX(iif(config.keel = 2,'Bilanssi read ei leidnud','Строк баланса не найдено'),'Kontrol')
		USE in v_bilanss
		SELECT 0
		RETURN .f.
	ENDIF
	CREATE cursor bilanssandmik_report (Nimetus c(120), regkood c(11), aadress c(120), kbmkood c(11),;
		tel c(60), email c(120), raama c(120), konto c(254), parentrea c(20),pidx n(12,3),;
		parentnimi c(120), REANR c(20),reaidx n(12,3), KirjeNimetus c(120), loppperiod y,;
		algperiod y, pLopp y, pAlg y,aktiva n(1) default 1)
	INDEX on val(alltrim(parentrea)) tag parentrea
	SET order to parentrea
	tnid = grekv
	.use('v_rekv')
	SELECT v_rekv
	cAadress = ''
	FOR i = 1 to memlines(v_rekv.aadress)
		cAadress = rtrim(cAadress) + space(1)+rtrim(mline(v_rekv.aadress,1))
	ENDFOR
*!*		.use('v_passiva')
*!*	&&Use v_passiva in 0
*!*		lnRea = val(alltrim(v_passiva.kood))
	lnrea = 11
*	USE in v_passiva
	SELECT v_bilanss
	SCAN

		lcParentNimi = ''
		lcReanr = v_bilanss.kood
		lnStart = at('.',lcReanr)-1
		IF lnStart > 0
			lcparentRea = left(lcReanr,lnStart)
&&			lcParentNimi = v_bilanss.Nimetus
			SELECT bilanssandmik_report
			LOCATE for alltrim(parentrea) = alltrim(lcparentRea)
			lcParentNimi = bilanssandmik_report.parentnimi
		ELSE
			lcparentRea = lcReanr
			lcParentNimi = v_bilanss.Nimetus
		ENDIF
		DO case
			CASE val(alltrim(lcparentRea)) < 11
				lnAktiva = 1
			CASE val(alltrim(lcparentRea)) > 10 AND val(alltrim(lcparentRea)) < 22
				lnAktiva = 2
			CASE val(alltrim(lcparentRea)) > 21
				lnAktiva = 3
		endcase
		WAIT window [Arvestan konto bilanssi rea ]+lcReanr nowait
		INSERT into bilanssandmik_report (Nimetus, regkood, kbmkood, aadress, tel,;
			email, raama,konto, parentrea, pidx, parentnimi, REANR, reaidx, KirjeNimetus,aktiva);
			values (v_rekv.Nimetus, v_rekv.regkood, v_rekv.kbmkood,cAadress,v_rekv.tel,;
			v_rekv.email,v_rekv.raama, v_bilanss.muud, lcparentRea, val(alltrim(lcparentRea)),lcParentNimi, lcReanr,;
			val(alltrim(lcReanr)), v_bilanss.Nimetus,lnAktiva)
	ENDSCAN
	SELECT parentrea, parentnimi from bilanssandmik_report;
		order by parentrea, parentnimi ;
		group by parentrea, parentnimi ;
		into cursor cursorParent1
	SELECT  cursorParent1
	SCAN
		WAIT window iif(config.keel = 2,'Arvestan bilanssi rea ','Расчет строки баланса:')+cursorParent1.parentrea nowait
		SELECT bilanssandmik_report
		lnrecno = recno()
		COUNT for parentrea = cursorParent1.parentrea to lnCount
		GO lnrecno
		IF lnCount > 1
			SCAN for parentrea = cursorParent1.parentrea and;
					bilanssandmik_report.parentrea <> bilanssandmik_report.REANR and;
					!empty (bilanssandmik_report.konto)
				SELECT bilanssandmik_report
				lnrecno = recno()
				lcFormula = rtrim(ltrim(bilanssandmik_report.konto))
				lnAlg = analise_formula(subst_macro(lcFormula,'algperiod'),fltrAruanne.kpv1,'cursorAlgSaldo')
				lnLopp = analise_formula(subst_macro(lcFormula,'loppperiod'),fltrAruanne.kpv2, 'cursorLoppSaldo')
				SELECT bilanssandmik_report
				IF !empty (lnrecno)
					GO lnrecno
				ENDIF
				REPLACE loppperiod with lnLopp,;
					algperiod with  lnAlg in bilanssandmik_report
			ENDSCAN
		ELSE
			SELECT bilanssandmik_report
			lnrecno = recno()
			lcFormula = rtrim(ltrim(bilanssandmik_report.konto))
			IF !empty (lcFormula)
				lnAlg = analise_formula(subst_macro(lcFormula,'algperiod'),fltrAruanne.kpv1,'cursorAlgSaldo')
				lnLopp = analise_formula(subst_macro(lcFormula,'loppperiod'),fltrAruanne.kpv2,'cursorLoppSaldo')
				SELECT bilanssandmik_report
				IF !empty (lnrecno)
					GO lnrecno
				ENDIF

				REPLACE loppperiod with lnLopp,;
					algperiod with  lnAlg in bilanssandmik_report
			ENDIF
		ENDIF
		SELECT bilanssandmik_report
		SUM algperiod for bilanssandmik_report.parentrea = cursorParent1.parentrea to lnAlg
		SUM loppperiod for bilanssandmik_report.parentrea = cursorParent1.parentrea to lnLopp
		UPDATE bilanssandmik_report set;
			parentnimi = cursorParent1.parentnimi,;
			pAlg =  lnAlg,;
			pLopp = lnLopp;
			where parentrea = cursorParent1.parentrea
*!*			UPDATE bilanssandmik_report set;
*!*				algperiod =  pAlg,;
*!*				loppperiod = pLopp;
*!*				where parentrea = bilanssandmik_report.REANR
	ENDSCAN
	USE in cursorParent1

	Clear
	USE in v_bilanss
	USE in v_rekv

	SELECT Nimetus, regkood, aadress, kbmkood, tel, email, raama, konto, parentrea,;
		parentnimi, REANR,KirjeNimetus, loppperiod, algperiod, sum(pLopp) as pLopp, sum(pAlg) as pAlg,aktiva ;
		from bilanssandmik_report ;
		order by pidx, reaidx;
		group by pidx, reaidx, Nimetus, regkood, aadress, kbmkood, tel, email, raama, konto, parentrea,;
		parentnimi, REANR,KirjeNimetus, loppperiod, algperiod, aktiva;
		into cursor bilanssandmik_report1
	USE in bilanssandmik_report
	SELECT bilanssandmik_report1

ENDWITH

FUNCTION subst_macro
	PARAMETER tcExpr, tcField
	LOCAL lcString
	IF  upper('rea(') $ upper(tcExpr)
&& есть макрос
		FOR i = 1 to occur (upper('rea('),upper(tcExpr))
			lnStart = at('REA(',upper(tcExpr))
			IF lnStart > 0
				lLopp = .f.
				lcExpr = ''
				DO while !lLopp
					lcBit = substr (tcExpr,lnStart+4,1)
					IF lcBit = ')'
						lLopp = .t.
					ELSE
						lcExpr = lcExpr + lcBit
						lnStart = lnStart + 1
					ENDIF

				ENDDO
				lcSubst = "?bilanssandmik_report.reanr='"+lcExpr+"',"+tcField
				tcExpr = strtran(upper(tcExpr),'REA('+lcExpr+')',lcSubst,1)
			ENDIF
		ENDFOR
	ENDIF
	RETURN tcExpr

