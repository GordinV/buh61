PARAMETER cWhere
IF isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
ENDIF
LOCAL lnDeebet, lnKreedit, lcParentnimi
lnDeebet = 0
lnKreedit = 0
lcparentnimi = ''
dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
REPLACE fltrAruanne.kpv1 with dKpv1,;
	fltrAruanne.kpv2 with dKpv2 in fltrAruanne
WITH oDb
	.Use ('v_tulem')
	INDEX ON VAL(ALLTRIM(KOOD)) TAG KOOD	
	SET ORDER TO KOOD
	IF reccount('v_tulem') = 0
		MESSAGEBOX(iif(config.keel = 2,'Tulemiaruanne kirjeldus ei leidnud','Описание отчета о прибыли не найдено'),'Kontrol')
		USE in v_tulem
		SELECT 0
		RETURN .f.
	ENDIF

	CREATE cursor tulemiaruanne_report1 (Nimetus c(120), regkood c(11), aadress c(120), kbmkood c(11),;
		tel c(60), email c(120), raama c(120), konto c(254), parentrea c(20),;
		parentnimi c(254), reanr c(20),KirjeNimetus c(120), loppperiod y,;
		algperiod y, pLopp y, pAlg y,aktiva n(1) default 1)
	INDEX on val(alltrim(parentrea)) tag parentrea
	SET order to parentrea
&& loading algsaldo tableid
	tnid = grekv

	.Use ('v_rekv')
&&	lError = .exec ("sp_saldo ",str(grekv)+", "+str(Month(dKpv1),2)+","+str(Year(dKpv1),4)+",'%'", 'cursorAlgSaldo' )
*	lError = .exec ("sp_saldo ",str(grekv)+", "+str(Month(dKpv2),2)+","+str(Year(dKpv2),4)+",'%'", 'cursorLoppSaldo' )
	REPLACE fltrAruanne.kpv1 with dKpv1,;
		fltrAruanne.kpv2 with dKpv2 in fltrAruanne
ENDWITH
SELECT v_rekv
cAadress = ltrim(rtrim(v_rekv.aadress))
SET STEP ON 
SELECT v_tulem
SCAN
	lcReanr = ltrim(rtrim(v_tulem.kood))
	lcFormula = ltrim(rtrim(v_tulem.muud))
&&	lcReanr = substr(v_tulem.library, 6,6)
	lnStart = at('.',lcReanr)-1
	IF lnStart > 0
		lcparentRea = left(lcReanr,lnStart)
&&		lcParentNimi = ''
	ELSE
		lcparentRea = lcReanr
		lcParentNimi = v_tulem.Nimetus
	ENDIF
	WAIT window [Arvestan konto tulemiaruanne rea ]+lcReanr nowait
	INSERT into tulemiaruanne_report1 (Nimetus, regkood, kbmkood, aadress, tel,;
		email, raama,konto, parentrea, parentnimi, reanr, KirjeNimetus);
		values (v_rekv.Nimetus, v_rekv.regkood, v_rekv.kbmkood,cAadress,v_rekv.tel,;
		v_rekv.email,v_rekv.raama, lcFormula, lcparentRea, lcParentNimi, lcReanr,;
		v_tulem.Nimetus)
ENDSCAN

CREATE CURSOR cursorParent1 (parentrea int, parentnimi c(254))
INDEX ON parentrea TAG parentrea
SET ORDER TO parentrea

INSERT INTO cursorParent1 (parentrea, parentnimi );
SELECT VAL(ALLTRIM(parentrea)), parentnimi from tulemiaruanne_report1;
	order by parentrea, parentnimi ;
	group by parentrea, parentnimi 
SELECT  cursorParent1

SCAN
	SELECT tulemiaruanne_report1
	lnrecno = recno('tulemiaruanne_report1')
	COUNT for ALLTRIM(tulemiaruanne_report1.parentrea) = ALLTRIM(STR(cursorParent1.parentrea)) to lnCount
	GO lnrecno
	IF lnCount > 1
		SCAN
			IF  ALLTRIM(tulemiaruanne_report1.parentrea) = ALLTRIM(STR(cursorParent1.parentrea)) and;
					tulemiaruanne_report1.parentrea <> tulemiaruanne_report1.reanr
				lnrecno = recno('tulemiaruanne_report1')
&&			lnAlg = analise_formula(alltrim(tulemiaruanne_report1.konto),fltrAruanne.kpv1, 'cursorAlgSaldo')
				lnAlg = 0
				lnLopp = analise_formula(subst_macro(alltrim(tulemiaruanne_report1.konto)),fltrAruanne.kpv2,'cursorLoppSaldo')
				IF !empty (lnrecno)
					SELECT tulemiaruanne_report1
					GO lnrecno
				ENDIF
				REPLACE loppperiod with lnLopp,;
					algperiod with  lnAlg in tulemiaruanne_report1

			ENDIF
		ENDSCAN
	ELSE
&&		lnAlg = analise_formula(alltrim(tulemiaruanne_report1.konto),fltrAruanne.kpv1, 'cursorAlgSaldo')
		lnAlg = 0
		lnLopp = analise_formula(subst_macro(alltrim(tulemiaruanne_report1.konto)),fltrAruanne.kpv2, 'cursorLoppSaldo')
		IF !empty (lnrecno)
			SELECT tulemiaruanne_report1
			GO lnrecno
		ENDIF

		REPLACE loppperiod with lnLopp,;
			algperiod with  lnAlg in tulemiaruanne_report1
	ENDIF
	SELECT tulemiaruanne_report1
	SUM algperiod for ALLTRIM(tulemiaruanne_report1.parentrea) = ALLTRIM(STR(cursorParent1.parentrea)) to lnAlg
	SUM loppperiod for ALLTRIM(tulemiaruanne_report1.parentrea) = ALLTRIM(STR(cursorParent1.parentrea)) to lnLopp
	UPDATE tulemiaruanne_report1 set;
		parentnimi = cursorParent1.parentnimi,;
		pAlg =  lnAlg,;
		pLopp = lnLopp;
		where ALLTRIM(parentrea) = ALLTRIM(STR(cursorParent1.parentrea))
	UPDATE tulemiaruanne_report1 set;
		Algperiod =  pAlg,;
		LoppPeriod = pLopp;
		where parentrea = tulemiaruanne_report1.reanr
	GO lnrecno
ENDSCAN
USE in cursorParent1
Clear
USE in v_tulem
USE in v_rekv
SELECT tulemiaruanne_report1



FUNCTION kontosaldo
	PARAMETER tcFormula, tdKpv
	LOCAL lnSaldo
	IF empty (tcFormula)
		RETURN 0
	ENDIF
	lnSaldo = 0
	lnSaldo = analise_formula(tcFormula, tdKpv)
	RETURN lnSaldo



FUNCTION subst_macro
	PARAMETER tcExpr
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
				lcSubst = "?tulemiaruanne_report1.reanr='"+lcExpr+"',loppperiod"
				tcExpr = strtran(upper(tcExpr),'REA('+lcExpr+')',lcSubst,1)
			ENDIF
		ENDFOR
	ENDIF
	RETURN tcExpr

