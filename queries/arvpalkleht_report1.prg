Parameter tcWhere
LOCAL lnJaak, lnSoodus
lnJaak = 0
lnSoodus = 0

If !Empty (fltrAruanne.asutusId)
	tnIsikId1 = fltrAruanne.asutusId
	tnIsikId2 = fltrAruanne.asutusId
	Select comAsutusremote
	Locate For Id = fltrAruanne.asutusId
	tcNimetus = Rtrim(comAsutusremote.nimetus)+'%'
Else
	tcNimetus = '%%'
	tnIsikId1 = 0
	tnIsikId2 = 999999999
Endif

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKuu1 = Month(fltrAruanne.kpv1)
tnKuu2 = Month(fltrAruanne.kpv2)
tnAasta1 = Year (fltrAruanne.kpv1)
tnAasta2 = Year (fltrAruanne.kpv2)
tnJaak1 = -999999999
tnJaak2 = 999999999
tnArv1 = -999999999
tnArv2 = 999999999
tnKinni1 = -999999999
tnKinni2 = 999999999
tnTulu1 = -999999999
tnTulu2 = 999999999
tnSots1 = -999999999
tnSots2 = 999999999

tcAmet = '%'
tcisik = tcNimetus
tnKokku1 = 0
tnKokku2 = 999
tnToo1 = 0
tnToo2 = 999
tnPuhk1 = 0
tnPuhk2 = 999
lnJaak = 0
tnParent = 3


tdKpv1_1 = fltrAruanne.kpv1
tdKpv1_2 = fltrAruanne.kpv2
tdKpv2_1 = fltrAruanne.kpv1
tdKpv2_2 = fltrAruanne.kpv2+30
tnpaevad1 = 0
tnpaevad2 = 9999
tcPohjus = '%'
tcLiik = '%'

If !Empty(fltrAruanne.osakondid)
	Select comOsakondAruanne
	Locate For Id = fltrAruanne.osakondid
	tcOsakond = Ltrim(Rtrim(comOsakondAruanne.kood))+'%'
Else
	tcOsakond = '%'
ENDIF

tnParentRekvId = gRekv
* GET month norm

WITH oDb
	.Use ('qryPalkArvLeht')
	tnParentRekvId = iif(!empty(fltrAruanne.kond),3,9)
	.Use ('curPalkJaak','qryPalkJaak')
	tcOsakond = IIF(!Empty(fltrAruanne.osakondid),Ltrim(Rtrim(comOsakondAruanne.nimetus))+'%',tcOsakond)
	.Use ('curTaabel1','qryTaabel')
	.Use ('curPuudumine','qryPuudumine')
ENDWITH


Delete From qryPalkArvLeht ;
	WHERE isikId Not In (Select I.Id From qryPalkJaak q inner Join comAsutusremote I On q.regkood = I.regkood WHERE jaak <> 0 or arvestatud <> 0 or kinni <> 0);
	or summa = 0

Delete From qryPuudumine ;
	WHERE  isikukood Not In (Select I.regkood From qryPalkJaak q inner Join comAsutusremote I On q.regkood = I.regkood )


Create Cursor arvleht_report1 (isik c(120), isikukood c(11), aadress c(254), tel c(40), kpv d, deebet Y, kreedit Y, sotsmaks Y,;
	liik c(1), nimetus c(120), jaak Y, aeg c(40) DEFAULT '0', norm c(40) DEFAULT '0',;
	period c(20) Default Str (Month (fltrAruanne.kpv2),2)+'/'+Str(Year (fltrAruanne.kpv2),4),;
	 tnorm y, pohipalk y, tohtu y, too y, tkokku y, ttahtpaev y, tpuhapaev y, kuurs n(14,4), valuuta c(20), dbKokku y, krKokku Y, sotsKokku y,;
	 soodus y, puhkus i, haigus i, komadeering i)

Index On Left (Upper(isik),40)+'-'+liik+'-'+LEFT(UPPER(nimetus),20) Tag isik
Set Order To isik

lnDb = 0
lnKr = 0
lnSots = 0
Select  qryPalkArvLeht
Scan FOR AT(UPPER('Valjamaks'), UPPER(ALLTRIM(nimetus))) = 0                                                                                                                                                                                                                                         
*For liik = '+' Or liik = '-'
	If (fltrAruanne.osakondid > 0 And qryPalkArvLeht.osakondid = fltrAruanne.osakondid) OR qryPalkArvLeht.osakondid = 0 OR fltrAruanne.osakondid = 0
		Select arvleht_report1
		Append Blank
		Select qryPalkJaak
		
		SUM jaak TO lnJaak for qryPalkJaak.nimetus = qryPalkArvLeht.isik And qryPalkJaak.kuu = Month (fltrAruanne.kpv2);
			and aasta = Year (fltrAruanne.kpv2)

		SUM g31 TO lnSoodus for qryPalkJaak.nimetus = qryPalkArvLeht.isik And qryPalkJaak.kuu = Month (fltrAruanne.kpv2);
			and aasta = Year (fltrAruanne.kpv2)
		
		Locate For nimetus = qryPalkArvLeht.isik And kuu = Month (fltrAruanne.kpv2);
			and aasta = Year (fltrAruanne.kpv2)
		If Found ()
			lcKokku = ''
			lnPaev = 0
			SELECT qryTaabel 
			SCAN FOR ALLTRIM(ISIKUKOOD) = ALLTRIM(qryPalkJaak.regkood)
				IF !EMPTY(lcKokku)
					lcKokku = lcKokku + ','
				ENDIF
				 lcKokku = lcKokku + STR(kokku,4) 
				 								 
				 IF gVersia = 'PG'
					lcString = 'select sp_workdays(1,'+;
						STR(MONTH(tdKpv1),2)+','+STR(YEAR(tdKpv1),4)+',31,'+STR(qryTaabel.tooleping) +')' 
					lError = odb.execsql (lcString, 'qryNormAeg')
					IF !EMPTY(lError) and USED('qryNormAeg')
						lnPaev = qryNormAeg.sp_workdays
					ELSE
						lnpaev = 0
					ENDIF
					
				ELSE
					lnPaev =  sp_workdays(1,MONTH(tdKpv1),YEAR(tdKpv1),31,qryTaabel.tooleping) 
				ENDIF
				IF lnPaev > 0
					SELECT comTootajadAruanne
					LOCATE FOR lepingid = qryTaabel.tooleping
				ENDIF
				
				lcKokku = lcKokku +'/'+STR(lnPaev * comTootajadAruanne.toopaev,4)

				 replace arvleht_report1.tohtu WITH arvleht_report1.tohtu + qryTaabel.ohtu,;
				 	arvleht_report1.too WITH arvleht_report1.too + qryTaabel.oo,;
				 	arvleht_report1.ttahtpaev WITH arvleht_report1.ttahtpaev + qryTaabel.tahtpaev,;
				 	arvleht_report1.tkokku WITH arvleht_report1.tkokku + qryTaabel.kokku,;
				 	arvleht_report1.tnorm WITH arvleht_report1.tnorm + lnPaev * comTootajadAruanne.toopaev,;
				 	arvleht_report1.pohipalk WITH comTootajadAruanne.palk * IIF(comTootajadAruanne.tasuliik = 1,1,lnPaev),;				 	
				 	arvleht_report1.tpuhapaev WITH arvleht_report1.tpuhapaev + qryTaabel.puhapaev IN arvleht_report1
				 	
			ENDSCAN
			
			lnKuurs = fnc_currentValuuta('KUURS',fltrAruanne.kpv2)			
			lcValuuta = fnc_currentValuuta('VAL',fltrAruanne.kpv2)			

		
			Replace jaak With lnjaak,;
				soodus WITH lnSoodus,;
				isikukood With qryPalkJaak.regkood,;
				aadress With qryPalkJaak.aadress,;
				aeg WITH lcKokku,;
				tel With qryPalkJaak.tel, kuurs WITH lnKuurs, valuuta WITH lcValuuta  In arvleht_report1			
				
		Endif
		Replace isik With qryPalkArvLeht.isik,;
			kpv With qryPalkArvLeht.kpv,;
			deebet With Iif (qryPalkArvLeht.liik = '+',qryPalkArvLeht.Summa * qryPalkArvLeht.KUURS,0),;
			kreedit With Iif (qryPalkArvLeht.liik = '-',qryPalkArvLeht.Summa * qryPalkArvLeht.KUURS ,0),;
			sotsmaks With Iif (qryPalkArvLeht.liik = '%',qryPalkArvLeht.Summa * qryPalkArvLeht.KUURS,0),;
			liik With qryPalkArvLeht.liik,;
			nimetus With qryPalkArvLeht.nimetus, ;
			kuurs WITH qryPalkArvLeht.kuurs,;
			valuuta WITH qryPalkArvLeht.valuuta In arvleht_report1

		lnDb = lnDb + arvleht_report1.deebet
		lnKr = lnKr + arvleht_report1.kreedit
		lnSots  = lnSots + arvleht_report1.sotsmaks
			
		* update inf tootaabel	
*!*			SELECT comTootajadAruanne
*!*			SCAN FOR kood = arvleht_report1.isikukood
*!*				IF gVersia = 'PG'
*!*				ELSE
*!*					
*!*				ENDIF
*!*				
*!*				
*!*			endscan
	Endif
ENDSCAN
SELECT sum(deebet) as db, sum(kreedit) as kr, sum(sotsmaks) as sots, isikukood FROM arvleht_report1 GROUP BY isikukood INTO CURSOR tmpKokku
SELECT tmpKokku
SCAN
	UPDATE arvleht_report1 SET dbkokku = tmpKokku.Db, krKokku = tmpKokku.Kr, sotsKokku = tmpKokku.Sots WHERE isikukood = tmpKokku.isikukood
ENDSCAN
USE IN tmpKokku

=get_algJaak()
=fncPuudumine()
Use In qryPalkArvLeht
Use In qryPalkJaak
Use In qryPuudumine

Select arvleht_report1
GO top

FUNCTION fncPuudumine
SELECT sum(paevad) as paevad, isikukood, isik, pohjus FROM qryPuudumine GROUP BY isikukood, isik, pohjus INTO CURSOR qryPuudu
SELECT qryPuudu
SCAN
	lnPuhkus = 0
	lnHaigus = 0
	lnMuud = 0
	DO case
		case qryPuudu.pohjus = 'PUHKUS'
			lnPuhkus = qryPuudu.paevad
		CASE ALLTRIM(qryPuudu.pohjus) = 'HAIGUS'
			lnHaigus = qryPuudu.paevad
		OTHERWISE
			lnMuud = qryPuudu.paevad
	ENDCASE

	SELECT arvleht_report1	
	LOCATE FOR isikukood =  qryPuudu.isikukood
	IF FOUND()
		IF lnPuhkus > 0 
			replace puhkus WITH lnPuhkus IN arvleht_report1
		ENDIF
		IF lnHaigus > 0 
			replace haigus WITH lnHaigus IN arvleht_report1		
		ENDIF
		IF lnHaigus > 0 
			replace komadeering WITH lnMuud IN arvleht_report1		
		ENDIF
		
*		UPDATE arvleht_report1 SET puhkus = lnPuhkus, haigus = lnHaigus, komadeering = lnMuud WHERE isikukood = qryPuudu.isikukood
	ELSE
		INSERT INTO arvleht_report1 (isikukood, isik, puhkus, haigus, komadeering) VALUES (qryPuudu.isikukood, qryPuudu.isik, ;
			lnPuhkus, lnHaigus, lnMuud)
	ENDIF
	
ENDSCAN
IF USED('qryPuudu')
	USE IN qryPuudu
ENDIF

ENDFUNC



Function get_algJaak
			lnKuurs = fnc_currentValuuta('KUURS',fltrAruanne.kpv2)			
			lcValuuta = fnc_currentValuuta('VAL',fltrAruanne.kpv2)			


	Select Distinc isik From arvleht_report1 Into Cursor qryIsikud
	Scan
		Select qryPalkJaak
		Locate For nimetus = qryIsikud.isik And kuu = Month (Gomonth(fltrAruanne.kpv1,-1));
			and aasta = Year (Gomonth(fltrAruanne.kpv2,-1))
		If Found () And qryPalkJaak.jaak <> 0
			Select arvleht_report1
			Append Blank
			Replace jaak With qryPalkJaak.jaak,;
				soodus WITH qryPalkJaak.g31,;
				isikukood With qryPalkJaak.regkood,;
				aadress With qryPalkJaak.aadress,;
				tel With qryPalkJaak.tel,;
				isik With qryPalkJaak.nimetus,;
				deebet With Iif (qryPalkJaak.jaak >0,qryPalkJaak.jaak,0),;
				kreedit With Iif (qryPalkJaak.jaak < 0,qryPalkJaak.jaak,0),;
				liik With Space(1),;
				nimetus With 'Alg.saldo',;
				kuurs WITH lnKuurs,;
				valuuta WITH lcValuuta In arvleht_report1

		Endif
	Endscan
	Use In qryIsikud
	Return
