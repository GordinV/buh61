Lparameters tcWhere
If gVersia =  'PG'
	lError = oDb.Exec("sp_palkstat_aruanne21 ",Str(grekv)+","+;
		" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
		" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
		STR(fltrAruanne.osakondId,9)+","+ STR(fltrAruanne.ametnik,1),"qryStat")

	If Used('qryStat')
		tcTimestamp = Alltrim(qryStat.sp_palkstat_aruanne21)
		oDb.Use('TMPPALKSTAT_ARUANNE2','PalkStat_report1')
		Select PalkStat_report1
		If Reccount('PalkStat_report1') < 1
			Append Blank
		Endif
	Else


		Select 0
		Return
	Endif
Else

	tdKpv1 = fltrAruanne.kpv1
		tdKpv2 = fltrAruanne.kpv1

	If fltrAruanne.osakondId > 0 
		lnOsakond1 = fltrAruanne.osakondId
		lnOsakond2 = fltrAruanne.osakondId
	else
		lnOsakond1 = 0
		lnOsakond2 = 999999999
	endIf

	Create cursor PalkStat_report1 (nimetus c(254), rea c(20) , tbl c(254),;
			col1 n(14,2) Default 0, col2 n(14,2) Default 0, col3 n(14,2) Default 0,;
			col4 n(14,2) Default 0, col5 n(14,2) Default 0, col6 n(14,2) Default 0,;
			col7 n(14,2) Default 0, col8 n(14,2) Default 0, col9 n(14,2) Default 0,;
			col10 n(14,2) Default 0, col11 n(14,2) Default 0, col12 n(14,2) Default 0,;
			col13 n(14,2) Default 0, col14 n(14,2) Default 0, col15 n(14,2) Default 0,;
			col16 n(14,2) Default 0, col17 n(14,2) Default 0, col18 n(14,2) Default 0,;
			col19 n(14,2) Default 0, col20 n(14,2) Default 0, col21 n(14,2) Default 0,;
			col22 n(14,2) Default 0, col23 n(14,2) Default 0, col24 n(14,2) Default 0,;
			col25 n(14,2) Default 0, col26 n(14,2) Default 0, col27 n(14,2) Default 0, ametikood Int)  


		Select Count(*) as ln1 From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 15 And sp_vanus(asutus.regkood,Date())  <= 19;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct tooleping.parentid From tooleping inner Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where tooleping.rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And (algab <= tdKpv1 And (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1);
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku ;
			INTO CURSOR qryLn1


			Select Count(*) as ln2 From asutus ;
			Where sp_vanus(asutus.regkood,Date())  >= 15 And sp_vanus(asutus.regkood,Date())  <= 19;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping inner Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where tooleping.rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And (algab <= tdKpv1 And (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0);
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku ;
			into CURSOR qryLn2

			Select Count(*) as ln3 From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 15 And sp_vanus(asutus.regkood,Date())  <= 19;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping inner Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 And (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			into cursor qryLn3

			Select Count(*) as ln4 From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 15 And sp_vanus(asutus.regkood,Date())  <= 19;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping inner Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 And (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn4


			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Values ('1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'15-19','01',lcReturn, tnrekvId, qryln1.ln1, qryln2.ln2, qryln3.ln3,qryln4.ln4)


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 20 And sp_vanus(asutus.regkood,Date())  <= 24;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			into CURSOR qryLn1

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 20 And sp_vanus(asutus.regkood,Date())  <= 24;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And palk_taabel1.kuu = Month(tdKpv2);
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			into CURSOR qryLn2

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 20 And sp_vanus(asutus.regkood,Date())  <= 24;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			into CURSOR qryLn3


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 20 And sp_vanus(asutus.regkood,Date())  <= 24;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			into CURSOR qryLn4


			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Values ('1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'20-24','02',;
			lcReturn, tnrekvId, qryln1.ln, qryln2.ln, qryln3.ln,qryln4.ln)


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 25 And sp_vanus(asutus.regkood,Date())  <= 54;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And palk_taabel1.kuu = Month(tdKpv2);
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			into CURSOR qryLn1

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 25 And sp_vanus(asutus.regkood,Date())  <= 54;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn2

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 25 And sp_vanus(asutus.regkood,Date())  <= 54;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And palk_taabel1.kuu = Month(tdKpv2);
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			INTO CURSOR qryLn3


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 25 And sp_vanus(asutus.regkood,Date())  <= 54;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn4


			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Values ('1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'25-54','03',;
			lcReturn, tnrekvId, qryLn1.ln, qryLn2.ln, qryLn3.ln,qryLn4.ln)



			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 54 And sp_vanus(asutus.regkood,Date())  <= 59;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			INTO CURSOR qryLn1


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 54 And sp_vanus(asutus.regkood,Date())  <= 59;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn2

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 54 And sp_vanus(asutus.regkood,Date())  <= 59;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			INTO CURSOR qryLn


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 54 And sp_vanus(asutus.regkood,Date())  <= 59;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn.4

			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Values ('1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'54-59','04',;
			lcReturn, tnrekvId, qryLn1.ln, qryLn2.ln, qryLn3.ln,qryLn4.ln)


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 60;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			INTO CURSOR qryLn1


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 60;
			And Left(asutus.regkood,1) In ('3','5');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			INTO CURSOR qryLn2

			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 60;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 1 And rekvid = tnrekvId);
			INTO CURSOR qryLn3


			Select Count(*) as ln From asutus;
			Where sp_vanus(asutus.regkood,Date())  >= 60;
			And Left(asutus.regkood,1) In ('4','6');
			And Id In (;
			Select Distinct parentid From tooleping Join palk_taabel1 On tooleping.Id = palk_taabel1.toolepingId;
			Where rekvid = tnrekvId;
			And osakondId >= lnOsakond1 And osakondId <= lnOsakond2;
			And palk_taabel1.kuu = Month(tdKpv2);
			And palk_taabel1.aasta = Year(tdKpv2);
			And (tooleping.toopaev * sp_workdays(1, Month(tdKpv2), Year(tdKpv2), 31, tooleping.Id)) <=  palk_taabel1.kokku;
			And (algab <= tdKpv1 Or (Empty(lopp) Or lopp >= tdKpv2)) And pohikoht = 0 And rekvid = tnrekvId);
			into cursor qryLn4

			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Values ('1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'60 ja enam','05',;
			lcReturn, tnrekvId, qryln1.ln, qryln2.ln, qryln3.ln,qryln4.ln)

			Insert Into PalkStat_report1 (tbl, nimetus, rea, Timestamp,rekvid,col1, col2, col3, col4);
			Select '1. Tootajate arv soo ja vanusruhmade jargi 2003.aasta oktoobri lopul.',;
			'KOKKU','06',;
			lcReturn, tnrekvId, Sum(col1), Sum(col2), Sum(col3), Sum(col4) From PalkStat_report1 palk ;
			Where rea <> '06' 

		Endif


FUNCTION sp_vanus  
lParamete tcIsikukood, tdKpv 
LOCAL lcString , lnAasta , lnKuu , lnpaev ,	lnVanus ,ldKpv 
if len(tcIsikukood) <> 11 
	RETURN 0
endif
	if !ISDIGIT(left(tcIsikukood,1))  
		RETURN 0
	endif
	lnVanus = val(left(tcIsikukood,1))

	lnAasta = val(substr(tcIsikukood,2,2))
	if lnAasta < 10 and lnVanus < 5 
		lnAasta = 1900 + lnAasta	
	endif	
	if lnAasta < 10 and lnVanus > 4 		
		lnAasta = 2000 + lnAasta	
	endif	
	if lnAasta < 100 	
		lnAasta = 1900 + lnAasta	
	ENDIF

	lnKuu = val(substr(tcIsikukood,4,2))
	if lnKuu < 1 or lnKuu > 12 
		return 0
	endif
	lnPaev = val(substr(tcIsikukood,6,2))
	if lnPaev < 1 or lnPaev > 31 
		return 0
	endif;
	return (tdKpv - date(lnAasta,lnKuu,lnPaev)) / 365
ENDFUNC
