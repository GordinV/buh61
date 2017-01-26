Parameter tcWhere
Local lcGrupp1, lcNimetus1, lcGrupp2, lcNimetus2
lcGrupp1 = ''
lcNimetus1 = ''
lcGrupp2 = ''
lcNimetus2 = ''
Create Cursor kuuaruanne_report1 (Order Int, ;
	grupp1 c(20) Default lcGrupp1, gr1Nimi c(254) Default lcNimetus1, aastagr1 Y, eelarvegr1 Y, kuugr1 Y, ;
	grupp2 c(20) Default lcGrupp2 ,gr2Nimi c(254) Default lcNimetus2, aastagr2 Y, eelarvegr2 Y, kuugr2 Y, ;
	kood c(20), nimetus c(254), eelarve Y, aasta Y ,kuu Y)
*!*	Index On grupp1+'-'+grupp2+'-'+kood Tag indx
*!*	Index On kood Tag kood Additive
*!*	Set Order To kood

tdKpv1 = Date(Year(fltrAruanne.kpv1),1,1)
tdKpv2 = fltrAruanne.kpv2
tcEelAllikas = '%'
tnRekv1 = grekv
tnRekv2 = grekv
nSamm = 1

With oDb
&& ÎÁÎÐÎÒÛ
	TcKonto = '%'
	tnAsutusId1 = 0
	tnAsutusId2 = 999999999
	tdKpv1 = Date(Year(fltrAruanne.kpv1),1,1)
	tdKpv2 = fltrAruanne.kpv2
	oDb.Use ('qrySaldo1','qryKuuAasta')
&& eelarve
	tcAsutus = Ltrim(Rtrim(qryRekv.nimetus))+'%'
	tcKood1 = '%'
	tcKood4 = '%'
	tcKood5 = '%'
	tnSumma1 = 	-999999999
	tnSumma2 = 	999999999
	tnAasta1 = 	Year(fltrAruanne.kpv1)
	tnAasta2 = 	tnAasta1
	tcTunnus = '%'
	tnTunnus = 1
	.Use ('CUREELARVE','qryKuuTulud')
	.Use ('CUREELARVEKULUD','qryKuuKulud')

&& kuu eest
*!*		tdKpv1 = fltrAruanne.kpv1
*!*		tdKpv2 = fltrAruanne.kpv2
*!*		oDb.use ('qrySaldo1','CursorKuuaruanneKuu')
Endwith

&& Tulud
lcGrupp1 = '3'
lcNimetus1 = 'TULUD'
lcGrupp2 = '30'
lcNimetus2 = 'Maksud'
lcKood = '3000'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Füüsilise isiku tulumaks',getEelarveKood (lcKood,'qryKuuTulud'), getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3030'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maamaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3032'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Mootorsõidukimaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3033'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Paadimaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3034'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Loomapidamismaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3041'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Müügimaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3044'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Reklaamimaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3045'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Teede ja tänavate sulgemise maks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3046'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Lõbustusmaks',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3047'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Parkimistasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcGrupp2 = '32'
lcNimetus2 = 'Riigilõivud'
lcKood = '322, 323'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kaupade ja teenuste müük',0, 0)
lcKood = '3220'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised haridusasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3221'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised kultuuri-ja kunstiasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3222'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised spordi-ja puhkeasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3223'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised tervishoiuasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3224'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised sotsiaalasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3225'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised elamu- ja kommunaalasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3226'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised keskkonnaasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3227'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised korrakaitseasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3228'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised riigikaitseasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3229'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised uldvalitsemisasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3230'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised transpordi- ja sideasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3231'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised põllumajandusasutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3232'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised muude maj.-küsimustega tegelevate asutuste majandustegevusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3233'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Üüri  ja renditulud',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3237'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumised õiguste müügist',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3238'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muu kaupade ja teenuste müük',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))

lcGrupp2 = '35'
lcNimetus2 = 'Toetused'
lcKood = '3500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sihtotstarbelised toetused jooksvateks kuludeks',0,0)
lcKood = '3500.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused mitteresidentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Valitsussektorisisesed toetused',0,0)
lcKood = '3500.00'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused riigilt ja riigiasutustelt',0,0)
lcKood = '3500.00.07'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Haridus- ja teadusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.09'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kaitseministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.10'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Keskkonnaministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.11'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kultuuriministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.12'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Majandus- ja kommunikatsiooniministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.13'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Põllumajandusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.14'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rahandusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.15'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Siseministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.16'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sotsiaalministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.20-34'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maavalitsused',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.01'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Riigikogu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.16'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Vabariigi Valitsuse reserv',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.00.06'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Vabariigi Valitsus sh.',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.01'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused kohaliku omavalitsuse üksustelt ja omavalitsusasutustelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.02'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused  valitsussektorisse kuuluvatelt av.-õig.-likelt jur.-telt isikutelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.03'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused valitsussektorisse kuuluvatelt sihtasutustelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3500.08'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused muudelt residentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sihtotstarbelised toetused põhivara soetamiseks (RIP)',0,0)
lcKood = '3502.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused muudelt residentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Valitsussektorisisesed toetused',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused riigilt ja riigiasutustelt',0,0)
lcKood = '3502.00.02'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Haridus- ja teadusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.05'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Keskkonnaministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.06'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kultuuriministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.07'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Majandus- ja kommunikatsiooniministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.08'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Põllumajandusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.09'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rahandusministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.10'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Siseministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.11'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sotsiaalministeerium',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.14'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maavalitsused',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.00.16'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Vabariigi Valitsuse reserv',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3502.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused muudelt residentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '352'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Mittesihtotstarbelised toetused',0,0)
lcKood = '352.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused mitteresidentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '352.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Valitsussektorisisesed toetused',0,0)
lcKood = '352.00'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused riigilt ja riigiasutustelt',0,0)
lcKood = '352.00.17'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Vabariigi Valitsus, s.h.',0,0)
lcKood = '352.00.17 '
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'       Tasandusfond § 5 lg 1 ',0,0)
lcKood = '352.00.17 '
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'       Tasandusfond § 5 lg 2 ',0,0)
lcKood = '352.01'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused kohaliku omavalitsuse üksustelt ja omavalitsusasutustelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '352.02'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused  valitsussektorisse kuuluvatelt av.-õig.-likelt jur.-telt isikutelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '352.03'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused valitsussektorisse kuuluvatelt sihtasutustelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '352.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused muudelt residentidelt',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))

lcGrupp2 = '38'
lcNimetus2 = 'Muud tulud '
lcKood = '381'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Materiaalsete ja immateriaalsete varade müük',0,0)
lcKood = '3810'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maa müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3811'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rajatiste ja hoonete müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3812'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muude materiaalsete pohivarade müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3813'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Immateriaalse pohivara müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3814'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Bioloogiliste varade müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3818'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Varude müük',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Tulud varadelt',0,0)
lcKood = '3820'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisetulud hoiustelt',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3821'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisetulud hoiustelt ostetud väärtpaberitelt',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3822'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi-, viivise- ja kohustistasutulud antud laenudelt',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3823'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisetulud muudelt finantsvaradelt',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3824'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Omanikutulud',0,getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3825'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rendi- ja üüritulud mittetoodetud põhivaradelt',0,0)
lcKood = '382500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Üleriigilise tähtsusega maardlate kaevandamisoiguse tasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382510'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kohaliku tähtsusega maardlate kaevandamisõiguse tasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382520'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maa-aines kaevandamisõiguse tasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382530'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Metsatulu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382540'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laekumine vee erikasutusest',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382550'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Jahipiirkonna kasutusõiguse tasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '382560'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kalapüügiüiguse tasu',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '388'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud tulud ',0,0)
lcKood = '3880'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Trahvid',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))
lcKood = '3888'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Eespool nimetemata muud tulud',getEelarveKood (lcKood,'qryKuuTulud'),getkaibed(lcKood,'qryKuuAasta','KR'))


&& Kulud
lcGrupp1 = '4, 5, 6, 15'
lcNimetus1 = 'KULUD MAJANDUSLIKU SISU JARGI'
lcGrupp2 = '4'
lcNimetus2 = 'Eraldised'
lcKood = '40'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Subsiidiumid ettevõtlusega tegelevatele isikutele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '41'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sotsiaaltoetused ',0, 0)
lcKood = '413'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sotsiaalabitoetused ja muud eraldised füüsilistele isikutele',0, 0)
lcKood = '4130'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Peretoetused',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4131'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toimetulekutoetus',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4132'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused töötutele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4133'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused puuetega inimestele ja nende hooldajatele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4134'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Õppetoetused ( toitlustustoetused ka siin)',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4138'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud sotsiaalabitoetused ja eraldised füüsilistele isikutele(ravitoetus ka siin)',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '414'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sotsiaaltoetused endistele valitsussektori töövõtjatele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '450'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sihtotstarbelised eraldised',0, 0)
lcKood = '4500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sihtotstarbelised eraldised jooksvateks kuludeks',0, 0)
lcKood = '4500.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused mitteresidentidele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Valitsussektorisisesed eraldised',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.00'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused riigile ja riigiasutustele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.01'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused kohaliku omavalitsuse üksustele ja omavalitsusasutustele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.02'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused  valitsussektorisse kuuluvatele av.-õig.-likelt jur.-telt isikutele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.03'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused valitsussektorisse kuuluvatele sihtasutustele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4500.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toetused muudele residentidele',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '4502'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sihtotstarbelised eraldised põhivara soetamiseks',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '452'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Mittesihtotstarbelised eraldised',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))

lcGrupp2 = '5'
lcNimetus2 = 'Tegevuskulud'
lcKood = '50'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Personalikulud',0, 0)
lcKood = '500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Töötasud ',0, 0)
lcKood = '5000'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Valitavate ja ametisse nimetatavate ametnike töötasu',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5001'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Avaliku teenistuse ametnike töötasu',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5002'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Töötajate töötasu',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5005'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Töövõtulepingu alusel töötajatele makstav tasu',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5008'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud tasud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '505'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Erisoodustused',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '506'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Personalikuludega kaasnevad maksud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '55'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Majandamiskulud',0,0)
lcKood = '5500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Administreerimiskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5501'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Uurimis- ja arendustööde ostukulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5502'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Uurimis- ja arendustööde ostukulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5503'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Lähetuskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5504'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Koolituskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5511'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kinnistute, hoonete ja ruumide majandamiskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5512'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rajatiste majandamiskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5513'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Sõidukite ulalpidamise kulud, v.a kaitseotstarbelised kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5514'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Info- ja kommunikatsioonitehnoloogia kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5515'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Inventari kulud, v.a IT- ja kaitseotstarbelised kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5516'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Masinate ja seadmete ülalpidamise kulud, v.a IT- ja kaitseotstarbelised kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5521'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Toiduained ja toitlustusteenused',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5522'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Meditsiinikulud ja hügieenitarbed',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5523'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Teavikud ja kunstiesemed',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5524'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Õppevahendite ja koolituse kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5525'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kommunikatsiooni-, kultuuri- ja vaba aja sisustamise kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5529'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Tootmiskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5531'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kaitseotstarbeline varustus ja materjalid',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5532'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Eri- ja vormiriietus, v.a kaitseotstarbelised kulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5533'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muu erivarustus ja erimaterjalid',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '5540'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud mitmesugused majanduskulud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcGrupp2 = '6'
lcNimetus2 = 'Muud kulud'
lcKood = '60'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud kulud (va. intressid ja kohustistasud)',0, 0)
lcKood = '601'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maksu-, riigilõivu- ja trahvikulud',0, 0)
lcKood = '601'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maksu-, riigilõivu- ja trahvikulud',0, 0)
lcKood = '601000'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Käibemaks',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '601010'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maamaks',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '601060'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud maksud',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '601070'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Riigilõivukulu',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '601090'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Trahvid',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '608'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muud tegevuskulud, sh.',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '608099'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Reservfond',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '65'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi-, viivise- ja kohustistasukulud',0, 0)
lcKood = '6500'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisekulud emiteeritud väärtpaberitelt',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '6501'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi-, viivise- ja kohustistasukulud võetud laenudelt',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '6502'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisekulud kapitaliliisingult',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '6503'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Intressi- ja viivisekulud muudelt kohustustelt',0, getkaibed(lcKood,'qryKuuAasta','DB'))

lcGrupp2 = '15'
lcNimetus2 = 'Materiaalsete ja immateriaalsete varade soetamine ja renoveerimine'
lcKood = '155'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Materiaalsete pohivarade soetamine ja renoveerimine',0, 0)
lcKood = '1550'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Maa soetamine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1551'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Rajatiste ja hoonete soetamine ja renoveerimine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1554'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Masinate ja seadmete,sh.trp.vahendite soetamine ja renoveerimine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1555'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Info- ja kommunikatsioonitehnoloogia seadmete soet. ja renov.',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1556'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Inventari soetamine ja renoveerimine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1557'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Mitteamortiseeruvate väärtuste soetamine ja renoveerimine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '156'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Immateriaalsete põhivarade soetamine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '157'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Bioloogiliste ressursside soetamine',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '158'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Varude soetamine',0, getkaibed(lcKood,'qryKuuAasta','DB'))

&&lcGrupp1 = '4, 5, 6, 15'

&& Kulud
lcGrupp1 = '8'
lcNimetus1 = 'ÜLEJÄÄK (+) / PUUDUJÄÄK (-)'
lcGrupp2 = '1'
lcNimetus2 = 'FINANTSEERIMISTEHINGUD'
lcKood = '10'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Finantsvarade suurenemine (-)',0,0)
lcKood = '1009.1'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Hoiuste suurendamine(-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '101.1'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Väärtpaberite ost   (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1011.1'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Aktsiate ja osade ost (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1032.1'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laenude andmine  (õppelaenud) (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '10.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Finantsvarade vähenemine (+)',0,0)
lcKood = '1009.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Hoiuste vähendamine (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1009.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Hoiuste vähendamine (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '101.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Väärtpaberite müük  (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1011.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Aktsiate ja osade müük (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1032.2'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Antud laenude tagasimaksed (õppelaenud)(+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '20.5'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kohustuste suurenemine (+)',0,0)
lcKood = '2080.5.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade emiteerimine valitsussektorisiseselt (+)',getEelarveKood (lcKood,'qryKuuKulud'), getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2080.5.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade emiteerimine muudele residentidele (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2080.5.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade emiteerimine mitteresidentidele (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.5.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laenude võtmine valitsussektorisiseselt (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.5.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laenude votmine muudelt residentidelt (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.5.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Laenude võtmine mitteresidentidelt (+)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '20.6'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kohustuste vähenemine (-)',0,0)
lcKood = '2080.6.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade tagasiostmine valitsussektorisiseselt (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2080.6.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade tagasiostmine muudelt residentidelt (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2080.6.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võlakirjade tagasiostmine mitteresidentidelt (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.6.0'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võetud laenude tagasimaksmine valitsussektorisiseselt (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.6.8'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võetud laenude tagasimaksmine muudele residentidele (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2081.6.9'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Võetud laenude tagasimaksmine mitteresidentidele (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '2082.6'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Kapitaliliisingu maksed  (-)',0, getkaibed(lcKood,'qryKuuAasta','DB'))
lcKood = '1001'
Insert Into kuuaruanne_report1 (kood , nimetus, eelarve, aasta) Values (lcKood,'Muutus kassas ja hoiustes (suurenemine "-", vähenemine "+"), sh.muutused kassatagavaras ja vabas jäägis',0, 0)




Select grupp2, Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1 Group By grupp2 Into Cursor qryGrupp2
Select grupp1, Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1 Group By grupp1 Into Cursor qryGrupp1
Select qryGrupp2
Scan
	Update kuuaruanne_report1 Set ;
		aastagr2 = qryGrupp2.aasta,;
		eelarvegr2 = qryGrupp2.eelarve ;
		WHERE grupp2 = qryGrupp2.grupp2
Endscan
Select qryGrupp1
Scan
	Update kuuaruanne_report1 Set ;
		aastagr1 = qryGrupp1.aasta,;
		eelarvegr1 = qryGrupp1.eelarve ;
		WHERE grupp1 = qryGrupp1.grupp1
Endscan

Use In qryGrupp1
Use In qryGrupp2

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,3) = '155';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '155'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('601','608');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '60'


Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,3) = '601';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '601'


Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,2) = '65';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '65'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,2) = '55';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '55'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('500','505', '506');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '50'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,3) = '500';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '500'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('4500','4502');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '450'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('4500.9','4500.0','4500.8');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '4500'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where Left(kood,3) = '322' Or Left(kood,3) = '323';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '322, 323'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('3500.00','3500.01','3500.02','3500.03');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '3500.0'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where LEFT(kood,7) = '3500.00';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '3500.00'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where LEFT(kood,7) = '3502.00';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '3502.00'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('3502.9','3502.0','3500.8');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '3502'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('352.00','352.01','352.02','352.03');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '352.0'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where kood in ('352.9','352.0','352.8');
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '352'

Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where LEFT(kood,3) = '388';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '388'
Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where LEFT(kood,3) = '382';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '382'
Select Sum(eelarve) As eelarve, Sum(aasta) As aasta From kuuaruanne_report1;
	where LEFT(kood,3) = '381';
	INTO Cursor qrySumma
Update kuuaruanne_report1 Set ;
	aasta = qrySumma.aasta,;
	eelarve = qrySumma.eelarve ;
	WHERE kood = '381'




Use In qrySumma



Select kuuaruanne_report1

Function getkaibed
	Lparameters TcKonto, tcCursor, tcOpt
	Local lnSumma, lcAlias
	lcAlias = Alias()
	lnSumma = 0
	Select (tcCursor)
	lnLen = Len(Alltrim(TcKonto))
	If tcOpt = 'DB'
		Sum deebet For Left(Alltrim(konto),lnLen) = TcKonto To lnSumma
	Else
		Sum kreedit For Left(Alltrim(konto),lnLen) = TcKonto To lnSumma
	Endif
	Select (lcAlias)
	Return lnSumma

Function getEelarveKood
	Lparameters tcKood, tcCursor
	Local lnSumma, lcAlias
	lcAlias = Alias()
	lnSumma = 0
	Select (tcCursor)
	lnLen = Len(Alltrim(tcKood))
	Sum Summa For Left(Alltrim(kood4),lnLen) = tcKood To lnSumma
	Select (lcAlias)
	Return lnSumma
