Parameters tnid
CREATE CURSOR tmpFilter (konto c(20));

Create Cursor palk_kaart_report1 (Id Int, lepingid Int, isikukood c(20), isik c(254), osakondId Int, osakond c(254), amet c(254), nimetus c(254), liik c(1), summa1 Y,;
	summa2 n(18,8), summa3 n(18,8),summa4 n(18,8),summa5 n(18,8),summa6 n(18,8),summa7 n(18,8),summa8 n(18,8),summa9 n(18,8),summa10 n(18,8),summa11 n(18,8),summa12 n(18,8),;
	aadress m, leping m, koormus N(12,4), palk N(18,8), toopaev Int, pohikoht c(20), ;
	haig1 Int, haig2 Int, haig3 Int,haig4 Int,haig5 Int,haig6 Int,haig7 Int,haig8 Int,haig9 Int,haig10 Int,haig11 Int,haig12 Int,;
	puhk11 Int, puhk12 Int,puhk13 Int,puhk14 Int,puhk15 Int,puhk16 Int,puhk17 Int,puhk18 Int,puhk19 Int,puhk110 Int,puhk111 Int,puhk112 Int,;
	puhk21 Int, puhk22 Int,puhk23 Int,puhk24 Int,puhk25 Int,puhk26 Int,puhk27 Int,puhk28 Int,puhk29 Int,puhk210 Int,puhk211 Int,puhk212 Int,;
	puhk31 Int, puhk32 Int,puhk33 Int,puhk34 Int,puhk35 Int,puhk36 Int,puhk37 Int,puhk38 Int,puhk39 Int,puhk310 Int,puhk311 Int,puhk312 Int,;
	puhk41 Int, puhk42 Int,puhk43 Int,puhk44 Int,puhk45 Int,puhk46 Int,puhk47 Int,puhk48 Int,puhk49 Int,puhk410 Int,puhk411 Int,puhk412 Int,;
	puhk51 Int, puhk52 Int,puhk53 Int,puhk54 Int,puhk55 Int,puhk56 Int,puhk57 Int,puhk58 Int,puhk59 Int,puhk510 Int,puhk511 Int,puhk512 Int, puukokku Int,;
	komm1 Int, komm2 Int, komm3 Int,komm4 Int,komm5 Int,komm6 Int,komm7 Int,komm8 Int,komm9 Int,komm10 Int,komm11 Int,komm12 Int,;
	muu1 Int, muu2 Int, muu3 Int,muu4 Int,muu5 Int,muu6 Int,muu7 Int,muu8 Int,muu9 Int,muu10 Int,muu11 Int,muu12 Int)
	
INDEX ON LEFT(isik,40) TAG isik
	
	
tcNimetus = '%'+Rtrim(Ltrim(fltrPalkOper.nimetus))+'%'
*!*	Select Distinct Id, lepingId, nimetus From comTootajad ;
*!*	where osakondId >= Iif(Empty(fltrPalkOper.osakondId),0,fltrPalkOper.osakondId);
*!*	And	osakondId <= Iif(Empty(fltrPalkOper.osakondId),999999999,fltrPalkOper.osakondId);
*!*	Order By nimetus Into Cursor qryTootajad1

If  .Not. Used('qryHoliday')
		lError = odB.Use('curHoliday','qryHoliday')
Endif
lnOsakondId1 = 0
lnOsakondId2 = 9999999
IF fltrPalkOper.osakondId > 0
	lnOsakondId1 = fltrPalkOper.osakondId
	lnOsakondId2 = fltrPalkOper.osakondId

ENDIF
lcString = "select asutus.id, asutus.regkood, asutus.nimetus , tooleping.id as lepingid from asutus inner join tooleping on asutus.id = tooleping.parentid where tooleping.rekvid = "+STR(grekv) +;
" and ifnull(tooleping.lopp,date("+STR(YEAR(fltrPalkOper.kpv1),4)+","+STR(MONTH(fltrPalkOper.kpv1),2)+",01)) >= DATE("+ STR(YEAR(fltrPalkOper.kpv1),4)+","+STR(MONTH(fltrPalkOper.kpv1),2)+","+;
	STR(DAY(fltrPalkOper.kpv1),2) +") and "+;
	" UPPER(asutus.nimetus) like '" + ALLTRIM(UPPER(fltrPalkOper.isik))+"%' and tooleping.osakondId >= "+STR(lnOsakondId1,9)+" and tooleping.osakondId <= "+STR(lnOsakondId2,9)
	
*_cliptext = lcString	
lnError = SQLEXEC(gnHandle,lcString,'qryTooLepingud')
IF lnError < 1 OR !USED('qryTooLepingud')
	WAIT WINDOW 'P�ringu viga' nowait
	SELECT 0
	RETURN 
endif
SELECT qryTooLepingud
*Select comTootajad
lnRecno = RECNO('qryTooLepingud')
Scan
	Wait Window 'Arvestan:'+Ltrim(Rtrim(qryTooLepingud.nimetus)) Nowait
	dKpv1 = Iif(Empty(fltrPalkOper.kpv1),Date(Year(Date()),Month(Date()),1),fltrPalkOper.kpv1)
	dKpv2 = Iif(Empty(fltrPalkOper.kpv2),Date(Year(Date()),Month(Date())+1,1),fltrPalkOper.kpv2)

		tnOsakondid1 = fltrPalkOper.osakondId
		tnOsakondid2 = IIF(EMPTY(fltrPalkOper.osakondId),999999999,fltrPalkOper.osakondId)
		tnIsik1 =  qryTooLepingud.Id
		tnIsik2 =  qryTooLepingud.Id
		lcLeping = ''
		With odb
*		SET STEP ON 
			.Use('QRYPALKKAART','qryPO')

				Select kuu, Sum(Summa) As Summa, 'P�hipalk' As nimetus, '+' As liik,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				  From qryPO ;
					WHERE LEFT(alltrim(konto),7) In ('5000000','5001000','5001200','5001400','5001500','5002000','5002100','5002400','5002500',;
						'5002800', '5002600', '5002700','5002900' );
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOPalk
					
			*		CREATE CURSOR qryPO (liik int, konto c(20), kuu int, summa n(14,2), isikid int, lepingid int, onimi c(120), animi c(120), pohikoht int, palk n(14,2), koormus int, toopaev int)
					
				Select kuu, Sum(Summa) As Summa, 'Lisatasud' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE LEFT(alltrim(konto),7) In ('5000001',;
					'5001001','5001201', '5001401','5001501','5002001','5002101','5002401','5002501','5002701','5002801', '5002601', '5002901');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOLisa
				
				DELETE FROM tmpFilter
				INSERT INTO tmpFilter (konto) VALUES ('50000301')
				INSERT INTO tmpFilter (konto) VALUES ('50000302')
				INSERT INTO tmpFilter (konto) VALUES ('50010301')
				INSERT INTO tmpFilter (konto) VALUES ('50010302')
				INSERT INTO tmpFilter (konto) VALUES ('50012301')
				INSERT INTO tmpFilter (konto) VALUES ('50012302')
				INSERT INTO tmpFilter (konto) VALUES ('50014301')
				INSERT INTO tmpFilter (konto) VALUES ('50014302')
				INSERT INTO tmpFilter (konto) VALUES ('50015301')
				INSERT INTO tmpFilter (konto) VALUES ('50015302')
				INSERT INTO tmpFilter (konto) VALUES ('50020301')
				INSERT INTO tmpFilter (konto) VALUES ('50020302')
				INSERT INTO tmpFilter (konto) VALUES ('50021301')
				INSERT INTO tmpFilter (konto) VALUES ('50021302')
				INSERT INTO tmpFilter (konto) VALUES ('50024301')
				INSERT INTO tmpFilter (konto) VALUES ('50024302')
				INSERT INTO tmpFilter (konto) VALUES ('50025301')
				INSERT INTO tmpFilter (konto) VALUES ('50025302')
				INSERT INTO tmpFilter (konto) VALUES ('50026301')
				INSERT INTO tmpFilter (konto) VALUES ('50026302')
				INSERT INTO tmpFilter (konto) VALUES ('50027301')
				INSERT INTO tmpFilter (konto) VALUES ('50027302')
				INSERT INTO tmpFilter (konto) VALUES ('50028301')
				INSERT INTO tmpFilter (konto) VALUES ('50028302')
				INSERT INTO tmpFilter (konto) VALUES ('50029301')
				INSERT INTO tmpFilter (konto) VALUES ('50029302')
				
				Select kuu, Sum(Summa) As Summa, 'Preemiad, tulemuspalk' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE konto In (select konto FROM tmpFilter);
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOPreemia
* 500003 01-500003 02	500103 01-500103 02	500123 01-500123 02	500143 01-500143 02	500153 01-500153 02	500203 01-500203 02	500213 01-500213 02	500243 01-500243 02	500253 01-500253 02	500263 01-500263 02	500273 01-500273 02	500283 01-500283 02	500293 01-500293 02
					
* Toetused, mis ei tulene seadusest					
				Select kuu, Sum(Summa) As Summa, 'T��andja toetused' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE konto In ('50000303','50010303','50012303','50014303','50015303','50020303',	'50021303','50024303','50025303','50026303','50027303','50028303','50029303');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryMuudToetused

* 500003 03	500103 03	500123 03	500143 03	500153 03	500203 03	500213 03	500243 03	500253 03	500263 03	500273 03	500283 03	500293 03
					
*!*	/*
*!*					Select kuu, Sum(Summa) As Summa, 'Boonused, toetused' As nimetus, '+' As liik ,;
*!*						isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
*!*					 From qryPO ;
*!*						WHERE konto In ('50000303','50010303', '50012303', '50014303', '50015303', '50020303', '50021303', '50024303',; 
*!*							'50025303', '50026303', '50027303', '50028303', '50029303');
*!*						and lepingid = qryTooLepingud.lepingid ;
*!*						AND liik = '1';
*!*						GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
*!*						INTO Cursor qryPOBoonused
*!*	 
				Select kuu, Sum(Summa) As Summa, 'Puhkusetasud,ja -h�vitised' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE  (LEFT(ALLTRIM(konto),7) in ('5002902','5001002','5001202','5001402','5001502','5002002','50020102','5002102',;
					'5002402','5002502','5002602','5002702','5002802');
					OR LEFT(ALLTRIM(konto),8) in ('50000021','50000022'));
					AND konto NOT in ('50000023','50010023','50012023','50014023','50015023','50020023','50021023','50024023','50025023',;
						'50026023','50027023','50028023','50029023');					
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOPuhkus
						
 				Select kuu, Sum(Summa) As Summa, '�ppepuhkusetasu' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE (alltrim(konto)) In ('50000023','50010023','50012023','50014023','50015023','50020023','50021023','50024023','50025023',;
						'50026023','50027023','50028023','50029023');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOOppePuhkus



				Select kuu, Sum(Summa) As Summa, 'T�iendavad puhkused' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE LEFT(alltrim(konto),6) In ('103560');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOlapsePuhkus


				Select kuu, Sum(Summa) As Summa, 'H�vitised ja toetused' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE alltrim(konto) In ('413320','500005','500105','500145','500155','500215','500245','500255','500285','500265', '500205',;
					'50000701','50010701','50012701','50014701','50015701','50020701','50021701','50024701','50025701','50026701',;
					'50027701',	'50028701',	'50029701');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOToetus

				Select kuu, Sum(Summa) As Summa, 'H�vitised ja toetused' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE alltrim(konto) In ('500007','50029701','50000701','500107','500147','500157','500217','500247','500257','500287', '500267', '500207');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOHuvitused

				Select kuu, Sum(Summa) As Summa, 'V�la�iguslikud lepingud' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE konto in ('500500','500298');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '1';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOAju

* T��tasu ettemaks
				Select kuu, Sum(Summa) As Summa, 'Tootasu ettemaks' As nimetus, '+' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE konto in ('103930');
					and lepingid = qryTooLepingud.lepingid ;
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryTootajaEttemaks

				Select kuu, Sum(Summa) As Summa, 'Sotsiaalmaks' As nimetus, '%' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE konto in ('506000','103931');
					and lepingid = qryTooLepingud.lepingid ;
					AND liik = '5';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOSots

				Select kuu, Sum(Summa) As Summa, 'T��TUSKINDLUSTUSMAKS' As nimetus, '-' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '7';
					AND asutusest = 0;
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOTookindlIsik

				Select kuu, Sum(Summa) As Summa, 'T��TUSKINDLUSTUSMAKS' As nimetus, '%' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '7';
					AND asutusest = 1;
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOTookindlAsu

				Select kuu, Sum(Summa) As Summa, 'Pensioonimaks' As nimetus, '-' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '8';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOPens

				Select kuu, Sum(Summa) As Summa, 'Tasu' As nimetus, '-' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '6';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOTasu

				Select kuu, Sum(Summa) As Summa, 'Tulumaks' As nimetus, '-' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '4';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOTulumaks

				Select kuu, Sum(Summa) As Summa, 'Muud' As nimetus, '-' As liik ,;
					isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
				 From qryPO ;
					WHERE lepingid = qryTooLepingud.lepingid ;
					AND liik = '2';
					GROUP By kuu, liik, isikId, lepingId, onimi, animi, pohikoht, palk, koormus, toopaev;
					INTO Cursor qryPOKinni


				Insert Into palk_kaart_report1 (Id, lepingid,isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)) as summa1,;
					sum(Iif(kuu = 2,Summa,000000000.000000)) as summa2,;
					sum(Iif(kuu = 3,Summa,000000000.000000)) as summa3,;
					sum(Iif(kuu = 4,Summa,000000000.000000)) as summa4,;
					sum(Iif(kuu = 5,Summa,000000000.000000)) as summa5,;
					sum(Iif(kuu = 6,Summa,000000000.000000)) as summa6,;
					sum(Iif(kuu = 7,Summa,000000000.000000)) as summa7,;
					sum(Iif(kuu = 8,Summa,000000000.000000)) as summa8,;
					sum(Iif(kuu = 9,Summa,000000000.000000)) as summa9,;
					sum(Iif(kuu = 10,Summa,000000000.000000)) as summa10,;
					sum(Iif(kuu = 11,Summa,000000000.000000)) as summa11,;
					sum(Iif(kuu = 12,Summa,000000000.000000)) as summa12, ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei') as pohikoht;
					FROM qryPOPalk p ;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid,isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					p.nimetus,  onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000 )),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOLisa p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
					


				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000)),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOPreemia p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000)),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryMuudToetused p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 


*!*					Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
*!*						 amet, liik, summa1,;
*!*						summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
*!*						koormus, palk , toopaev , pohikoht);
*!*						SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
*!*						 p.nimetus, onimi, animi, liik,;
*!*						sum(Iif(kuu = 1,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 2,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 3,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 4,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 5,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 6,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 7,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 8,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 9,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 10,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 11,Summa,000000000.000000)),;
*!*						sum(Iif(kuu = 12,Summa,000000000.000000)), ;
*!*						koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
*!*						FROM qryPOBoonused p;
*!*						inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
*!*						group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
*!*						 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					 koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000)),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOPuhkus p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					 koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000)),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOOppePuhkus p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 


				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					 koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.000000)),;
					sum(Iif(kuu = 2,Summa,000000000.000000)),;
					sum(Iif(kuu = 3,Summa,000000000.000000)),;
					sum(Iif(kuu = 4,Summa,000000000.000000)),;
					sum(Iif(kuu = 5,Summa,000000000.000000)),;
					sum(Iif(kuu = 6,Summa,000000000.000000)),;
					sum(Iif(kuu = 7,Summa,000000000.000000)),;
					sum(Iif(kuu = 8,Summa,000000000.000000)),;
					sum(Iif(kuu = 9,Summa,000000000.000000)),;
					sum(Iif(kuu = 10,Summa,000000000.000000)),;
					sum(Iif(kuu = 11,Summa,000000000.000000)),;
					sum(Iif(kuu = 12,Summa,000000000.000000)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOlapsePuhkus p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
					

				Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOToetus p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
					

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOHuvitused p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
					

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOAju p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
* qryTootajaEttemaks					
				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryTootajaEttemaks p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOSots p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 
					

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOTookindlIsik p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOPens p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOTulumaks p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid, comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOTasu p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
					 amet, liik, summa1,;
					summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
					koormus, palk , toopaev , pohikoht);
					SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus as isik,;
					 p.nimetus, onimi, animi, liik,;
					sum(Iif(kuu = 1,Summa,000000000.00)),;
					sum(Iif(kuu = 2,Summa,000000000.00)),;
					sum(Iif(kuu = 3,Summa,000000000.00)),;
					sum(Iif(kuu = 4,Summa,000000000.00)),;
					sum(Iif(kuu = 5,Summa,000000000.00)),;
					sum(Iif(kuu = 6,Summa,000000000.00)),;
					sum(Iif(kuu = 7,Summa,000000000.00)),;
					sum(Iif(kuu = 8,Summa,000000000.00)),;
					sum(Iif(kuu = 9,Summa,000000000.00)),;
					sum(Iif(kuu = 10,Summa,000000000.00)),;
					sum(Iif(kuu = 11,Summa,000000000.00)),;
					sum(Iif(kuu = 12,Summa,000000000.00)), ;
					koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei');
					FROM qryPOKinni p;
					inner join comAsutusRemote on p.isikId = comAsutusRemote.id;
					group by isikId, lepingid,  comAsutusRemote.regkood, comAsutusremote.nimetus ,;
					 p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht 

				USE IN qryPoPalk
				USE IN qryPoLisa
				USE IN qryPoPreemia
				USE IN qryPoToetus
				USE IN qryPOHuvitused
				USE IN qryPoAju
				USE IN qryPoSots
				USE IN qryPoTookindlIsik
				USE IN qryPoTookindlAsu
				USE IN qryPoPens
				USE IN qryPoTasu
				USE IN qryPoTulumaks
				USE IN qryPoKinni

				SELECT comAsutusremote
				LOCATE FOR id = qryTooLepingud.id
				UPDATE palk_kaart_report1 SET aadress = comAsutusremote.aadress WHERE Id = qryTooLepingud.id
				
				tdKpv1_1 = fltrPalkOper.kpv1
				tdKpv1_2 = fltrPalkOper.kpv2
				tdKpv2_1 = fltrPalkOper.kpv1
				tdKpv2_2 = fltrPalkOper.kpv2+365
				tnpaevad1 = 0
				tnpaevad2 = 9999
				tcAmet = '%'
				tcIsik = Ltrim(Rtrim(qryTooLepingud.nimetus))+'%'
				tcPohjus = '%'
				tcLiik = '%'


				.Use('curpuudumine','qryPuudu')

				Delete From QRYpUUDU Where lepingid <> qryTooLepingud.lepingid


* arvestame haigus
*		USE curPuudumine_ ALIAS qryPuudu


		Endwith

		Use In qryPO
		

		For i = 1 To 5
			lnPuhk1 = 0
			lnPuhk2 = 0
			lnPuhk3 = 0
			lnPuhk4 = 0
			lnPuhk5 = 0
			lnPuhk6 = 0
			lnPuhk7 = 0
			lnPuhk8 = 0
			lnPuhk9 = 0
			lnPuhk10 = 0
			lnPuhk11 = 0
			lnPuhk12 = 0




			select QRYpUUDU
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 1, Year(fltrPalkOper.kpv1),1) to lnPuhk1 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 2, Year(fltrPalkOper.kpv1),1) to lnPuhk2 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 3, Year(fltrPalkOper.kpv1),1) to lnPuhk3 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 4, Year(fltrPalkOper.kpv1),1) to lnPuhk4 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 5, Year(fltrPalkOper.kpv1),1) to lnPuhk5 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 6, Year(fltrPalkOper.kpv1),1) to lnPuhk6 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 7, Year(fltrPalkOper.kpv1),1) to lnPuhk7 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 8, Year(fltrPalkOper.kpv1),1) to lnPuhk8 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 9, Year(fltrPalkOper.kpv1),1) to lnPuhk9 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 10, Year(fltrPalkOper.kpv1),1) to lnPuhk10 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 11, Year(fltrPalkOper.kpv1),1) to lnPuhk11 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
			sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 12, Year(fltrPalkOper.kpv1),1) to lnPuhk12 for lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i

		create cursor qryPuu (puhk1 n(14,2), puhk2 n(14,2), puhk3 n(14,2), puhk4 n(14,2), puhk5 n(14,2), puhk6 n(14,2),;
			puhk7 n(14,2), puhk8 n(14,2), puhk9 n(14,2), puhk10 n(14,2), puhk11 n(14,2), puhk12 n(14,2))


		append blank

			replace qryPuu.puhk1 with lnPuhk1,;
					qryPuu.puhk2 with lnPuhk2,;
					qryPuu.puhk3 with lnPuhk3,;
					qryPuu.puhk4 with lnPuhk4,;
					qryPuu.puhk5 with lnPuhk5,;
					qryPuu.puhk6 with lnPuhk6,;
					qryPuu.puhk7 with lnPuhk7,;
					qryPuu.puhk8 with lnPuhk8,;
					qryPuu.puhk9 with lnPuhk9,;
					qryPuu.puhk10 with lnPuhk10,;
					qryPuu.puhk11 with lnPuhk11,;
					qryPuu.puhk12 with lnPuhk12 in qryPuu

			If Used('qryPuu') And Reccount('qryPuu') > 0

				lcString = 'UPDATE palk_kaart_report1 SET '+;
					'puhk'+Str(i,1)+'1 = qryPuu.puhk1,'+;
					'puhk'+Str(i,1)+'2 = qryPuu.puhk2,'+;
					'puhk'+Str(i,1)+'3 = qryPuu.puhk3,'+;
					'puhk'+Str(i,1)+'4 = qryPuu.puhk4,'+;
					'puhk'+Str(i,1)+'5 = qryPuu.puhk5,'+;
					'puhk'+Str(i,1)+'6 = qryPuu.puhk6,'+;
					'puhk'+Str(i,1)+'7 = qryPuu.puhk7,'+;
					'puhk'+Str(i,1)+'8 = qryPuu.puhk8,'+;
					'puhk'+Str(i,1)+'9 = qryPuu.puhk9,'+;
					'puhk'+Str(i,1)+'10 = qryPuu.puhk10,'+;
					'puhk'+Str(i,1)+'11 = qryPuu.puhk11,'+;
					'puhk'+Str(i,1)+'12 = qryPuu.puhk12 '+;
					'WHERE lepingid = qryTooLepingud.lepingId'

				&lcString

			Endif

		Endfor

		Select 	Sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 1, Year(fltrPalkOper.kpv1),0)) As puhk1,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 2, Year(fltrPalkOper.kpv1),0)) As puhk2,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 3, Year(fltrPalkOper.kpv1),0)) As puhk3,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 4, Year(fltrPalkOper.kpv1),0)) As puhk4,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 5, Year(fltrPalkOper.kpv1),0)) As puhk5,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 6, Year(fltrPalkOper.kpv1),0)) As puhk6,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 7, Year(fltrPalkOper.kpv1),0)) As puhk7,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 8, Year(fltrPalkOper.kpv1),0)) As puhk8,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 9, Year(fltrPalkOper.kpv1),0)) As puhk9,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 10, Year(fltrPalkOper.kpv1),0)) As puhk10,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 11, Year(fltrPalkOper.kpv1),0)) As puhk11,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 12, Year(fltrPalkOper.kpv1),0)) As puhk12;
			FROM QRYpUUDU ;
			WHERE lepingid = qryTooLepingud.lepingid And tunnus = 3 ;
			INTO Cursor qryPuu

		If Used('qryPuu') And Reccount('qryPuu') > 0

			Update palk_kaart_report1 Set ;
				komm1 = qryPuu.puhk1,;
				komm2 = qryPuu.puhk2,;
				komm3 = qryPuu.puhk3,;
				komm4 = qryPuu.puhk4,;
				komm5 = qryPuu.puhk5,;
				komm6 = qryPuu.puhk6,;
				komm7 = qryPuu.puhk7,;
				komm8 = qryPuu.puhk8,;
				komm9 = qryPuu.puhk9,;
				komm10 = qryPuu.puhk10,;
				komm11 = qryPuu.puhk11,;
				komm12 = qryPuu.puhk12;
				WHERE lepingid = qryTooLepingud.lepingid


			Use In qryPuu

		Endif

		Select 	Sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 1, Year(fltrPalkOper.kpv1),0)) As puhk1,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 2, Year(fltrPalkOper.kpv1),0)) As puhk2,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 3, Year(fltrPalkOper.kpv1),0)) As puhk3,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 4, Year(fltrPalkOper.kpv1),0)) As puhk4,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 5, Year(fltrPalkOper.kpv1),0)) As puhk5,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 6, Year(fltrPalkOper.kpv1),0)) As puhk6,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 7, Year(fltrPalkOper.kpv1),0)) As puhk7,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 8, Year(fltrPalkOper.kpv1),0)) As puhk8,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 9, Year(fltrPalkOper.kpv1),0)) As puhk9,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 10, Year(fltrPalkOper.kpv1),0)) As puhk10,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 11, Year(fltrPalkOper.kpv1),0)) As puhk11,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 12, Year(fltrPalkOper.kpv1),0)) As puhk12;
			FROM QRYpUUDU ;
			WHERE lepingid = qryTooLepingud.lepingid And tunnus = 2 ;
			INTO Cursor qryPuu

		If Used('qryPuu') And Reccount('qryPuu') > 0

			Update palk_kaart_report1 Set ;
				haig1 = qryPuu.puhk1,;
				haig2 = qryPuu.puhk2,;
				haig3 = qryPuu.puhk3,;
				haig4 = qryPuu.puhk4,;
				haig5 = qryPuu.puhk5,;
				haig6 = qryPuu.puhk6,;
				haig7 = qryPuu.puhk7,;
				haig8 = qryPuu.puhk8,;
				haig9 = qryPuu.puhk9,;
				haig10 = qryPuu.puhk10,;
				haig11 = qryPuu.puhk11,;
				haig12 = qryPuu.puhk12;
				WHERE lepingid = qryTooLepingud.lepingid


			Use In qryPuu

		Endif

		Select 	Sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 1, Year(fltrPalkOper.kpv1),0)) As puhk1,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 2, Year(fltrPalkOper.kpv1),0)) As puhk2,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 3, Year(fltrPalkOper.kpv1),0)) As puhk3,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 4, Year(fltrPalkOper.kpv1),0)) As puhk4,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 5, Year(fltrPalkOper.kpv1),0)) As puhk5,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 6, Year(fltrPalkOper.kpv1),0)) As puhk6,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 7, Year(fltrPalkOper.kpv1),0)) As puhk7,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 8, Year(fltrPalkOper.kpv1),0)) As puhk8,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 9, Year(fltrPalkOper.kpv1),0)) As puhk9,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 10, Year(fltrPalkOper.kpv1),0)) As puhk10,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 11, Year(fltrPalkOper.kpv1),0)) As puhk11,;
			sum(f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 12, Year(fltrPalkOper.kpv1),0)) As puhk12;
			FROM QRYpUUDU ;
			WHERE lepingid = qryTooLepingud.lepingid And tunnus = 4 ;
			INTO Cursor qryPuu

		If Used('qryPuu') And Reccount('qryPuu') > 0

			Update palk_kaart_report1 Set ;
				muu1 = qryPuu.puhk1,;
				muu2 = qryPuu.puhk2,;
				muu3 = qryPuu.puhk3,;
				muu4 = qryPuu.puhk4,;
				muu5 = qryPuu.puhk5,;
				muu6 = qryPuu.puhk6,;
				muu7 = qryPuu.puhk7,;
				muu8 = qryPuu.puhk8,;
				muu9 = qryPuu.puhk9,;
				muu10 = qryPuu.puhk10,;
				muu11 = qryPuu.puhk11,;
				muu12 = qryPuu.puhk12;
				WHERE lepingid = qryTooLepingud.lepingid

			Use In qryPuu

		Endif


Endscan

Select qryTooLepingud
USE IN qryTooLepingud

SELECT palk_kaart_report1
SET ORDER TO isik

*!*	Use In qryTootajad1



Function f_interval
	Lparameters tdKpv1, tdKpv2, tnKuu, tnAasta, tlKontrol
	Local ldKpv2, ldKpv1, lnPaev
	lcAlias = alias()
	If Empty(tdKpv1) And Empty(tdKpv2)
		Return 0
	Endif
	If Empty(tdKpv2)
		tdKpv2 = Date()
	Endif
	If Empty(tdKpv1)
		tdKpv1 = Date()
	Endif
	If Empty(tnAasta)
		tnAasta = Year(tdKpv1)
	Endif
	If Empty(tnKuu)
		tnKuu = Month(tdKpv2)
	Endif
	ldKpv1 = Iif(tdKpv1 < Date(tnAasta, tnKuu,1),Date(tnAasta, tnKuu,1),tdKpv1)
	ldKpv2 = Iif(tdKpv2 > Gomonth(Date(tnAasta, tnKuu,1),1)-1,Gomonth(Date(tnAasta, tnKuu,1),1)-1,tdKpv2)
	lnPaev = (ldKpv2 - ldKpv1)+1
	if lnPaev < 0
		return 0
	endif
	If Gomonth(Date(tnAasta, tnKuu,1),1)-1 < tdKpv1
*	Or Date(tnAasta, tnKuu,1) < tdKpv2
		Return 0
	Endif
	
	if !empty(tlKontrol) 	
		lnPuhapaevad = 0
		If used('qryHoliday') and Reccount('qryHoliday') > 0
			select qryHoliday
			
*		select * from holidays where rekvid = 119 and date(2008,kuu,paev) >= date(2008,03,01) and date(2008,kuu,paev) <= date(2008,03,31)	
*		select count(*) from holidays where date(2008,kuu,paev) >= date(2008,08,01) and date(2008,kuu,paev) <= date(2008,08,31) and rekvid = 119

			count to lnPuhapaevad for date(year(ldKpv1),kuu,paev) >= ldKpv1 and date(year(ldKpv1),kuu,paev) <= ldKpv2
		endif
		if lnPuhapaevad > 0 
			lnPaev = lnPaev - lnPuhapaevad
			if lnPaev < 0 
				lnpaev = 0
			endif
			
		endif					
	endif	
	select (lcAlias)
	
Return lnPaev
