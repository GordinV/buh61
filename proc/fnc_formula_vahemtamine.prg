gnHandle = SQLCONNECT('avpsoft2005','vlad','490710')

IF gnHandle > 0
	WAIT WINDOW 'connected..' TIMEOUT 1
ELSE
	WAIT WINDOW 'viga..' TIMEOUT 1
	return
ENDIF

gRekv = 1
gUser = 1
CREATE CURSOR v_journal (kpv d, asutusId int)
APPEND BLANK
replace asutusId WITH 1, kpv WITH DATE()
CREATE CURSOR v_journal1 (deebet c(20), kreedit c(20), summa n(12,2))
APPEND BLANK
replace deebet WITH '122',kreedit WITH '113',summa WITH 100
lcString = 'SD(DB) * 10 '
lFound = .t.
lnCount = 10
DO WHILE lFound
	WAIT WINDOW lcString TIMEOUT 3
	lnCount = lnCount - 1
	DO case
	
		CASE 'ASD(DB)' $ UPPER(lcString) OR 'ASD(DEEBET)' $ UPPER(lcString)	
			lnSumma = analise_formula('ASD('+Ltrim(Rtrim(v_journal1.deebet))+','+Alltrim(Str(v_journal.Asutusid))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('ASD(DB)',lnSumma)
			lcString = fnc_formula_vahemtamine('ASD(DEEBET)',lnSumma)
				
		CASE 'ASD(KR)' $ UPPER(lcString) OR 'ASD(KREEDIT)' $ UPPER(lcString)					
			lnSumma = analise_formula('ASD('+Ltrim(Rtrim(v_journal1.kreedit))+','+Alltrim(Str(v_journal.Asutusid))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('ASD(KR)',lnSumma)
			lcString = fnc_formula_vahemtamine('ASD(KREEDIT)',lnSumma)
		CASE 'ASK(DB)' $ UPPER(lcString) OR 'ASK(DEEBET)' $ UPPER(lcString)			
			lnSumma = analise_formula('ASK('+Ltrim(Rtrim(v_journal1.deebet))+','+Alltrim(Str(v_journal.Asutusid))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('ASK(DB)',lnSumma)
			lcString = fnc_formula_vahemtamine('ASK(DEEBET)',lnSumma)
		CASE 'ASK(KR)' $ UPPER(lcString) OR 'ASK(KREEDIT)' $ UPPER(lcString)					
			lnSumma = analise_formula('ASK('+Ltrim(Rtrim(v_journal1.kreedit))+','+Alltrim(Str(v_journal.Asutusid))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('ASK(KR)',lnSumma)
			lcString = fnc_formula_vahemtamine('ASK(KREEDIT)',lnSumma)
		CASE 'SD(DB)' $ UPPER(lcString) OR 'SD(DEEBET)' $ UPPER(lcString)			
			lnSumma = analise_formula('SD('+Ltrim(Rtrim(v_journal1.deebet))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('SD(DB)',100)
			lcString = fnc_formula_vahemtamine('SD(DEEBET)',100)
		CASE 'SD(KR)' $ UPPER(lcString) OR 'SD(KREEDIT)' $ UPPER(lcString)					
			lnSumma = analise_formula('SD('+Ltrim(Rtrim(v_journal1.kreedit))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('SD(KR)',100)
			lcString = fnc_formula_vahemtamine('SD(KREEDIT)',100)
		CASE 'SK(DB)' $ UPPER(lcString) OR 'SK(DEEBET)' $ UPPER(lcString)			
			lnSumma = analise_formula('SK('+Ltrim(Rtrim(v_journal1.deebet))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('SK(DB)',100)
			lcString = fnc_formula_vahemtamine('SK(DEEBET)',100)
		CASE 'SK(KR)' $ UPPER(lcString) OR 'SK(KREEDIT)' $ UPPER(lcString)					
			lnSumma = analise_formula('SK('+Ltrim(Rtrim(v_journal1.kreedit))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('SK(KR)',100)
			lcString = fnc_formula_vahemtamine('SK(KREEDIT)',100)
		CASE 'DK(DB)' $ UPPER(lcString) OR 'DK(DEEBET)' $ UPPER(lcString)			
			IF !USED('fltrAruanne')
				CREATE CURSOR fltrAruanne (kpv1 d DEFAULT DATE(YEAR(DATE()),MONTH(DATE()),1), kpv2 d DEFAULT DATE())
				APPEND blank
				IF USED('fltrJournal')
					replace kpv1 WITH fltrJournal.kpv1,;
						kpv2 WITH fltrJournal.kpv2 IN fltrAruanne
				ELSE
				endif
			endif
			lnSumma = analise_formula('DK('+Ltrim(Rtrim(v_journal1.kreedit))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('DK(DB)',100)
			lcString = fnc_formula_vahemtamine('DK(DEEBET)',100)
			
		CASE 'KK(KR)' $ UPPER(lcString) OR 'KK(KREEDIT)' $ UPPER(lcString)					
			IF !USED('fltrAruanne')
				CREATE CURSOR fltrAruanne (kpv1 d DEFAULT DATE(YEAR(DATE()),MONTH(DATE()),1), kpv2 d DEFAULT DATE())
				APPEND blank
				IF USED('fltrJournal')
					replace kpv1 WITH fltrJournal.kpv1,;
						kpv2 WITH fltrJournal.kpv2 IN fltrAruanne
				ELSE
				endif
			endif

			lnSumma = analise_formula('KK('+Ltrim(Rtrim(v_journal1.kreedit))+')', v_journal.kpv )
			lcString = fnc_formula_vahemtamine('KK(KR)',100)
			lcString = fnc_formula_vahemtamine('KK(KREEDIT)',100)
	OTHERWISE
		lFound = .f.
		

	ENDCASE
	
	IF lnCount = 0
		exit
	ENDIF
	

ENDDO

lnResult = EVALUATE(lcString)
WAIT WINDOW STR(lnresult) TIMEOUT 1

=SQLDISCONNECT(gnHandle)

FUNCTION fnc_formula_vahemtamine
LPARAMETERS tcFormula, tnSumma
IF EMPTY(tnSumma)
	tnSumma = 0
ENDIF

lnAlg = AT(tcFormula,lcString)
IF lnAlg > 0
	RETURN STUFF(UPPER(lcString),lnAlg,LEN(tcFormula), ALLTRIM(STR(tnSumma,12,2)))
ELSE
	RETURN lcString
ENDIF

ENDFUNC


