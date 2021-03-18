Parameters tnid
Create Cursor tmpFilter (konto c(20));

Create Cursor palk_kaart_report1 (Id Int, lepingid Int, isikukood c(20), isik c(254), osakondId Int, osakond c(254), amet c(254), nimetus c(254), liik c(1), summa1 Y,;
	summa2 N(18,8), summa3 N(18,8),summa4 N(18,8),summa5 N(18,8),summa6 N(18,8),summa7 N(18,8),summa8 N(18,8),summa9 N(18,8),summa10 N(18,8),summa11 N(18,8),summa12 N(18,8),;
	aadress m, leping m, koormus N(12,4), palk N(18,8), toopaev Int, pohikoht c(20), ;
	haig1 Int, haig2 Int, haig3 Int,haig4 Int,haig5 Int,haig6 Int,haig7 Int,haig8 Int,haig9 Int,haig10 Int,haig11 Int,haig12 Int,;
	puhk11 Int, puhk12 Int,puhk13 Int,puhk14 Int,puhk15 Int,puhk16 Int,puhk17 Int,puhk18 Int,puhk19 Int,puhk110 Int,puhk111 Int,puhk112 Int,;
	puhk21 Int, puhk22 Int,puhk23 Int,puhk24 Int,puhk25 Int,puhk26 Int,puhk27 Int,puhk28 Int,puhk29 Int,puhk210 Int,puhk211 Int,puhk212 Int,;
	puhk31 Int, puhk32 Int,puhk33 Int,puhk34 Int,puhk35 Int,puhk36 Int,puhk37 Int,puhk38 Int,puhk39 Int,puhk310 Int,puhk311 Int,puhk312 Int,;
	puhk41 Int, puhk42 Int,puhk43 Int,puhk44 Int,puhk45 Int,puhk46 Int,puhk47 Int,puhk48 Int,puhk49 Int,puhk410 Int,puhk411 Int,puhk412 Int,;
	puhk51 Int, puhk52 Int,puhk53 Int,puhk54 Int,puhk55 Int,puhk56 Int,puhk57 Int,puhk58 Int,puhk59 Int,puhk510 Int,puhk511 Int,puhk512 Int, ;
	puhk61 Int, puhk62 Int,puhk63 Int,puhk64 Int,puhk65 Int,puhk66 Int,puhk67 Int,puhk68 Int,puhk69 Int,puhk610 Int,puhk611 Int,puhk612 Int, ;
	puukokku Int,;
	komm1 Int, komm2 Int, komm3 Int,komm4 Int,komm5 Int,komm6 Int,komm7 Int,komm8 Int,komm9 Int,komm10 Int,komm11 Int,komm12 Int,;
	muu1 Int, muu2 Int, muu3 Int,muu4 Int,muu5 Int,muu6 Int,muu7 Int,muu8 Int,muu9 Int,muu10 Int,muu11 Int,muu12 Int)

Index On Left(isik,40) Tag isik


tcNimetus = '%'+Rtrim(Ltrim(fltrPalkOper.nimetus))+'%'

If  .Not. Used('qryHoliday')
	lError = odB.Use('curHoliday','qryHoliday')
Endif
lnOsakondId1 = 0
lnOsakondId2 = 9999999
If fltrPalkOper.osakondId > 0
	lnOsakondId1 = fltrPalkOper.osakondId
	lnOsakondId2 = fltrPalkOper.osakondId

Endif

lcString = "select asutus.id, asutus.regkood, asutus.nimetus , tooleping.id as lepingid from asutus inner join tooleping on asutus.id = tooleping.parentid where tooleping.rekvid = "+Str(grekv) +;
	" and ifnull(tooleping.lopp,date("+Str(Year(fltrPalkOper.kpv1),4)+","+Str(Month(fltrPalkOper.kpv1),2)+",01)) >= DATE("+ Str(Year(fltrPalkOper.kpv1),4)+","+Str(Month(fltrPalkOper.kpv1),2)+","+;
	STR(Day(fltrPalkOper.kpv1),2) +") and "+;
	" UPPER(asutus.nimetus) like '" + Alltrim(Upper(fltrPalkOper.isik))+"%' and tooleping.osakondId >= "+Str(lnOsakondId1,9)+" and tooleping.osakondId <= "+Str(lnOsakondId2,9)

lnError = SQLEXEC(gnHandle,lcString,'qryTooLepingud')
If lnError < 1 Or !Used('qryTooLepingud')
	Wait Window 'Päringu viga' Nowait
	Select 0
	Return
Endif
Select qryTooLepingud

lnRecno = Recno('qryTooLepingud')
Scan
	Wait Window 'Arvestan:'+Ltrim(Rtrim(qryTooLepingud.nimetus)) Nowait
	dKpv1 = Iif(Empty(fltrPalkOper.kpv1),Date(Year(Date()),Month(Date()),1),fltrPalkOper.kpv1)
	dKpv2 = Iif(Empty(fltrPalkOper.kpv2),Date(Year(Date()),Month(Date())+1,1),fltrPalkOper.kpv2)

	tnOsakondid1 = fltrPalkOper.osakondId
	tnOsakondid2 = Iif(Empty(fltrPalkOper.osakondId),999999999,fltrPalkOper.osakondId)
	tnIsik1 =  qryTooLepingud.Id
	tnIsik2 =  qryTooLepingud.Id
	lcLeping = ''
	With odB

		.Use('QRYPALKKAART','qryPO')

		Select kuu, Sum(Summa) As Summa, 'Põhipalk' As nimetus, '+' As liik,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE (Left(Alltrim(konto),8) In ('50000001','50010001','50012001','50014001',	'50021001',;
			'50024001',	'50025001',	'50026001',	'50027001',	'50028001',	'50029001');
			OR LEFT(ALLTRIM(konto),6) in ('500150','500200'));
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOPalk

		Select kuu, Sum(Summa) As Summa, 'Lisatasud' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE Left(Alltrim(konto),7) In ('5000001',;
			'5001001','5001201', '5001401','5002001','5002101','5002401','5002501','5002701','5002801', '5002601', '5002901');
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOLisa


		Delete From tmpFilter
		Insert Into tmpFilter (konto) Values ('50000301')
		Insert Into tmpFilter (konto) Values ('50000302')
		Insert Into tmpFilter (konto) Values ('50010301')
		Insert Into tmpFilter (konto) Values ('50010302')
		Insert Into tmpFilter (konto) Values ('50012301')
		Insert Into tmpFilter (konto) Values ('50012302')
		Insert Into tmpFilter (konto) Values ('50014301')
		Insert Into tmpFilter (konto) Values ('50014302')
		Insert Into tmpFilter (konto) Values ('50021301')
		Insert Into tmpFilter (konto) Values ('50021302')
		Insert Into tmpFilter (konto) Values ('50024301')
		Insert Into tmpFilter (konto) Values ('50024302')
		Insert Into tmpFilter (konto) Values ('50025301')
		Insert Into tmpFilter (konto) Values ('50025302')
		Insert Into tmpFilter (konto) Values ('50026301')
		Insert Into tmpFilter (konto) Values ('50026302')
		Insert Into tmpFilter (konto) Values ('50027301')
		Insert Into tmpFilter (konto) Values ('50027302')
		Insert Into tmpFilter (konto) Values ('50028301')
		Insert Into tmpFilter (konto) Values ('50028302')
		Insert Into tmpFilter (konto) Values ('50029301')
		Insert Into tmpFilter (konto) Values ('50029302')



		Select kuu, Sum(Summa) As Summa, 'Preemiad, tulemuspalk' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE konto In (Select konto From tmpFilter);
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOPreemia

* Toetused, mis ei tulene seadusest
		Select kuu, Sum(Summa) As Summa, 'Tööandja toetused' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE (konto In ('50000303','50010303','50012303','50014303','50021303','50024303','50025303','50026303','50027303','50028303','50029303');
			OR LEFT(konto,6) in ('500153','500203'));
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryMuudToetused


		Select kuu, Sum(Summa) As Summa, 'Puhkusetasud,ja -hüvitised' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE  Left(Alltrim(konto),7) In ('5000002','5002902','5001002','5001202','5001402','5002102',;
			'5002402','5002502','5002602','5002702','5002802');
			AND konto Not In ('50000023','50010023','50012023','50014023','50021023','50024023','50025023',;
			'50026023','50027023','50028023','50029023');
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOPuhkus

		Select kuu, Sum(Summa) As Summa, 'Õppepuhkusetasu' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE (Alltrim(konto)) In ('50000023','50010023','50012023','50014023','50021023','50024023','50025023',;
			'50026023','50027023','50028023','50029023');
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOOppePuhkus



		Select kuu, Sum(Summa) As Summa, 'Täiendavad puhkused' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE Left(Alltrim(konto),6) In ('103560');
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOlapsePuhkus


		l_kontod = '500007,500127,500127,500147,500217,500147,500257,500267,500277,500287,500297,500157,500207' 

		nRows = Alines(laData, l_kontod, .F., ",")

		Create Cursor tmp_kontod (konto c(20))
		For i = 1 To Alen(laData)
			Insert Into tmp_kontod(konto) Values (laData(i))
		Endfor

		Select kuu, Sum(Summa) As Summa, 'Hüvitised ja toetused' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE LEFT(Alltrim(konto),6) In (Select konto From tmp_kontod);
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOHuvitused

USE IN tmp_kontod

		Select kuu, Sum(Summa) As Summa, 'Võlaõiguslikud lepingud' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE (konto In ('50026801','50029801') ;
			OR LEFT(konto,6) in ('500500','500298','500268'));
			and lepingid = qryTooLepingud.lepingid ;
			AND liik = '1';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOAju

* Töötasu ettemaks
		Select kuu, Sum(Summa) As Summa, 'Töötasu ettemaks' As nimetus, '+' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE konto In ('103930');
			and lepingid = qryTooLepingud.lepingid ;
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryTootajaEttemaks

		Select kuu, Sum(Summa) As Summa, 'Sotsiaalmaks' As nimetus, '%' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '5';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOSots
* konto in ('506000','203010','103931','202001');

		Select kuu, Sum(Summa) As Summa, 'TÖÖTUSKINDLUSTUSMAKS' As nimetus, '-' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '7';
			AND asutusest = 0;
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOTookindlIsik

		Select kuu, Sum(Summa) As Summa, 'TÖÖTUSKINDLUSTUSMAKS' As nimetus, '%' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '7';
			AND asutusest = 1;
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOTookindlAsu

		Select kuu, Sum(Summa) As Summa, 'Pensioonimaks' As nimetus, '-' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '8';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOPens

		Select kuu, Sum(Summa) As Summa, 'Tasu' As nimetus, '-' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '6';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOTasu

		Select kuu, Sum(Summa) As Summa, 'Tulumaks' As nimetus, '-' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '4';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOTulumaks

		Select kuu, Sum(Summa) As Summa, 'Muud' As nimetus, '-' As liik ,;
			isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			From qryPO ;
			WHERE lepingid = qryTooLepingud.lepingid ;
			AND liik = '2';
			GROUP By kuu, liik, isikId, lepingid, onimi, animi, pohikoht, palk, koormus, toopaev;
			INTO Cursor qryPOKinni

		Insert Into palk_kaart_report1 (Id, lepingid,isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
			p.nimetus, onimi, animi, liik,;
			sum(Iif(kuu = 1,Summa,000000000.000000)) As summa1,;
			sum(Iif(kuu = 2,Summa,000000000.000000)) As summa2,;
			sum(Iif(kuu = 3,Summa,000000000.000000)) As summa3,;
			sum(Iif(kuu = 4,Summa,000000000.000000)) As summa4,;
			sum(Iif(kuu = 5,Summa,000000000.000000)) As summa5,;
			sum(Iif(kuu = 6,Summa,000000000.000000)) As summa6,;
			sum(Iif(kuu = 7,Summa,000000000.000000)) As summa7,;
			sum(Iif(kuu = 8,Summa,000000000.000000)) As summa8,;
			sum(Iif(kuu = 9,Summa,000000000.000000)) As summa9,;
			sum(Iif(kuu = 10,Summa,000000000.000000)) As summa10,;
			sum(Iif(kuu = 11,Summa,000000000.000000)) As summa11,;
			sum(Iif(kuu = 12,Summa,000000000.000000)) As summa12, ;
			koormus, palk, toopaev, Iif(pohikoht = 1,'Jah','Ei') As pohikoht;
			FROM qryPOPalk p ;
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid,isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht



		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht


		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht


		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht


		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht


		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht
* qryTootajaEttemaks
		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht


		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid, isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid, comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Insert Into palk_kaart_report1 (Id, lepingid,  isikukood, isik, nimetus , osakond,;
			amet, liik, summa1,;
			summa2, summa3 ,summa4,summa5 ,summa6 ,summa7 ,summa8 ,summa9 ,summa10 ,summa11 ,summa12 ,;
			koormus, palk , toopaev , pohikoht);
			SELECT isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus As isik,;
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
			inner Join comAsutusRemote On p.isikId = comAsutusRemote.Id;
			group By isikId, lepingid,  comAsutusRemote.regkood, comAsutusRemote.nimetus ,;
			p.nimetus, onimi, animi, liik, koormus, palk, toopaev, pohikoht

		Use In qryPOPalk
		Use In qryPOLisa
		Use In qryPOPreemia
		Use In qryPOHuvitused
		Use In qryPOAju
		Use In qryPOSots
		Use In qryPOTookindlIsik
		Use In qryPOTookindlAsu
		Use In qryPOPens
		Use In qryPOTasu
		Use In qryPOTulumaks
		Use In qryPOKinni

		Select comAsutusRemote
		Locate For Id = qryTooLepingud.Id
		Update palk_kaart_report1 Set aadress = comAsutusRemote.aadress Where Id = qryTooLepingud.Id

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


	For i = 1 To 6
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

		is_check_holidays = 1
		If i = 4
* oma arvelt
			is_check_holidays = 0
		Else
			is_check_holidays = 1
		Endif



		Select QRYpUUDU
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 1, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk1 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 2, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk2 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 3, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk3 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 4, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk4 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 5, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk5 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 6, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk6 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 7, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk7 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 8, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk8 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 9, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk9 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 10, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk10 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 11, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk11 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i
		Sum f_interval(QRYpUUDU.kpv1,QRYpUUDU.kpv2, 12, Year(fltrPalkOper.kpv1),is_check_holidays) To lnPuhk12 For lepingid = qryTooLepingud.lepingid And tunnus = 1 And tyyp = i

		Create Cursor qryPuu (puhk1 N(14,2), puhk2 N(14,2), puhk3 N(14,2), puhk4 N(14,2), puhk5 N(14,2), puhk6 N(14,2),;
			puhk7 N(14,2), puhk8 N(14,2), puhk9 N(14,2), puhk10 N(14,2), puhk11 N(14,2), puhk12 N(14,2))


		Append Blank

		Replace qryPuu.puhk1 With lnPuhk1,;
			qryPuu.puhk2 With lnPuhk2,;
			qryPuu.puhk3 With lnPuhk3,;
			qryPuu.puhk4 With lnPuhk4,;
			qryPuu.puhk5 With lnPuhk5,;
			qryPuu.puhk6 With lnPuhk6,;
			qryPuu.puhk7 With lnPuhk7,;
			qryPuu.puhk8 With lnPuhk8,;
			qryPuu.puhk9 With lnPuhk9,;
			qryPuu.puhk10 With lnPuhk10,;
			qryPuu.puhk11 With lnPuhk11,;
			qryPuu.puhk12 With lnPuhk12 In qryPuu

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
Use In qryTooLepingud

Select palk_kaart_report1
Set Order To isik

*!*	Use In qryTootajad1



Function f_interval
	Lparameters tdKpv1, tdKpv2, tnKuu, tnAasta, tlKontrol
	Local ldKpv2, ldKpv1, lnPaev
	lcAlias = Alias()
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
	If lnPaev < 0
		Return 0
	Endif
	If Gomonth(Date(tnAasta, tnKuu,1),1)-1 < tdKpv1
*	Or Date(tnAasta, tnKuu,1) < tdKpv2
		Return 0
	Endif

	If !Empty(tlKontrol)
		lnPuhapaevad = 0
		If Used('qryHoliday') And Reccount('qryHoliday') > 0
			Select qryHoliday

*		select * from holidays where rekvid = 119 and date(2008,kuu,paev) >= date(2008,03,01) and date(2008,kuu,paev) <= date(2008,03,31)
*		select count(*) from holidays where date(2008,kuu,paev) >= date(2008,08,01) and date(2008,kuu,paev) <= date(2008,08,31) and rekvid = 119

			Count To lnPuhapaevad For Date(Year(ldKpv1),kuu,paev) >= ldKpv1 And Date(Year(ldKpv1),kuu,paev) <= ldKpv2
		Endif
		If lnPuhapaevad > 0
			lnPaev = lnPaev - lnPuhapaevad
			If lnPaev < 0
				lnPaev = 0
			Endif

		Endif
	Endif
	Select (lcAlias)

	Return lnPaev

