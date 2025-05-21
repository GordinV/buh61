Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
Local lnDeebet, lnKreedit, lnAlg, lcString
lnAlg = 0
lnDeebet = 0
lnKreedit = 0
lcString = ''
tcKasutaja = '%'
tcMuud = '%'
SET STEP ON 
* lisatud 22/05
IF USED ('curSaldo')
	USE IN curSaldo
ENDIF


If Empty(fltrAruanne.konto)
	Messagebox(Iif(config.keel = 2,'Puudub konto', 'Отсутствует счет'),'Kontrol')
	Select 0
	Return .F.
Endif

dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())
Replace fltrAruanne.kpv1 With dKpv1,;
	fltrAruanne.kpv2 With dKpv2 In fltrAruanne
dKpv = Date(Year(fltrAruanne.kpv1), Month(fltrAruanne.kpv1),1)
cKonto = Alltrim(fltrAruanne.konto)
If Used ('kontoandmik_report')
	Use In kontoandmik_report
Endif
lnLopp = 0
Create Cursor kontoandmik_report (pkonto c(20),deebet N(18,6), kreedit N(18,6),journalId Int,;
	kpv d, nimetus c(120), asutus c(120), konto c(20), dbkokku N(18,6), krKokku N(18,6), algs N(1) Default 1,;
	korkonto c(20), dok c(120), tp c(20),kood1 c(20), kood2 c(20), kood3 c(20), ;
	kood5 c(20), Id Int, tunnus c(20), lsaldo N(18,6) Default lnLopp)

Select comKontodRemote
If Tag() <> 'KOOD'
	Set Order To kood
Endif
Seek fltrAruanne.konto


If !Used('v_filter')
	Create Cursor v_filter (filtr m)
	Append Blank
ENDIF

If !Empty(fltrAruanne.tunnus)
	Select comTunnusremote
	If Tag() <> 'ID'
		Set Order To Id
	Endif
	Seek fltrAruanne.tunnus
Endif

lcString = lcString + Iif(!Empty(fltrAruanne.konto), ' konto = '+Upper(Ltrim(Rtrim(fltrAruanne.konto))),'')
lcString = lcString + Iif(!Empty(fltrAruanne.tunnus), ' ьksus = '+Upper(Ltrim(Rtrim(comTunnusRemote.kood))),'')
replace v_filter.filtr WITH lcstring


nAasta = Year (dKpv)
nKuu = Month (dKpv)
With odb
&& Alg.saldo arvestamine
	If !Empty(fltrAruanne.tunnus)
		tnid = comKontodRemote.Id
		.Use ('v_tunnusinf','qryTunnusInf')
		SELECT qryTunnusInf
		DELETE FOr tunnusId <> fltrAruanne.tunnus
		lnAlg = analise_formula('TSD('+cKonto+','+Alltrim(Str(fltrAruanne.tunnus))+')',fltrAruanne.kpv1-1)
		tcTunnus = Ltrim(Rtrim(comTunnusRemote.kood))+'%'
	Else
		tcTunnus = '%'
		lnAlg = analise_formula('SD('+cKonto+')',fltrAruanne.kpv1-1)
*		lnLopp = analise_formula('SD('+cKonto+')',fltrAruanne.kpv2+1)
	Endif

	tcKood1 = '%'
	tcKood2 = '%'
	tcKood3 = '%'
	tcKood4 = '%'
	tcKood5 = '%'
	cDeebet = cKonto+'%'
	cKreedit = '%%'
	cAsutus = '%%'
	cDok = '%%'
	cSelg = '%%'
	nSumma1 = -99999999
	nSumma2 = 999999999
	tcTpD = '%'
	tcTpK = '%'
	tcproj = '%'
	tcUritus = '%'
	tcValuuta = '%'

	cDeebet = Alltrim(cKonto)+'%'
	.Use('curJournal','queryDb')
	cDeebet = '%'
	cKreedit = Alltrim(cKonto)+'%'
	.Use('curJournal','queryKr')

	replace fltrPrinter.kuurs with 1 IN fltrPrinter

	
	lnAlg = ROUND(lnAlg / fltrPrinter.kuurs,2)
	
	
*	(journal_report1.summa*journal_report1.kuurs)/fltrPrinter.kuurs
	Insert Into kontoandmik_report (pkonto, deebet, kreedit, kpv, nimetus, algs, tunnus);
		values (cKonto, lnAlg , 0, dKpv1, 'Alg.saldo', 1, IIF(!EMPTY(fltrAruanne.tunnus),comTunnusremote.kood,''))
*SET STEP ON 
	Select Number As Id, kpv,asutus,selg As nimetus,cKonto As pkonto,;
		iif(deebet = cKonto,kreedit,deebet) As konto,;
		iif(deebet = cKonto,ROUND(queryDb.Summa ,2),000000000.00) As 'deebet',;
		iif(kreedit = cKonto,ROUND(queryDb.Summa ,2),000000000.00) As 'Kreedit', 0 As algs, dok,;
		lisa_d As tpd, lisa_k As tpk, kood1, kood2, kood3, kood4, kood5, tunnus ;
		from queryDb;
		where Rtrim(Ltrim(deebet)) = cKonto;
		into Cursor query1
*		brow
	If Reccount ('query1') > 0
		Select kontoandmik_report
*		Append From Dbf('query1')
		SELECT query1
*		brow
		SCAN


			INSERT into kontoandmik_report (pkonto,deebet , kreedit,kpv , nimetus, asutus, konto,  algs,;
				dok,kood1 , kood2, kood3,kood5, Id , tunnus) VALUES (;
				query1.pkonto, query1.deebet , query1.kreedit, query1.kpv , query1.nimetus, query1.asutus, query1.konto,; 
				 query1.algs,	query1.dok, query1.kood1 , query1.kood2, query1.kood3,query1.kood5, ;
				query1.Id , query1.tunnus)	
		ENDSCAN
		
		
	Endif

	Select Number As Id, kpv,asutus,selg As nimetus,cKonto As pkonto,;
		iif(deebet = cKonto,kreedit,deebet) As konto,;
		iif(deebet = cKonto,ROUND(Summa ,2) ,000000000.00) As 'deebet',;
		iif(kreedit = cKonto,ROUND(Summa ,2) ,000000000.00) As 'Kreedit', 0 As algs, dok,;
		lisa_d As tpd, lisa_k As tpk, kood1, kood2, kood3, kood4, kood5, tunnus ;
		from queryKr;
		where Rtrim(Ltrim(kreedit)) = cKonto;
		into Cursor query1
*brow
	If Reccount ('query1') > 0
		Select kontoandmik_report
*		Append From Dbf('query1')

		SELECT query1
		SCAN
			INSERT into kontoandmik_report (pkonto,deebet , kreedit,kpv , nimetus, asutus, konto, algs,;
				dok, kood1 , kood2, kood3,kood5, Id , tunnus) VALUES (;
				query1.pkonto, query1.deebet , query1.kreedit,query1.kpv , query1.nimetus, query1.asutus, query1.konto,; 
				query1.algs,query1.dok, query1.kood1 , query1.kood2, query1.kood3,query1.kood5, ;
				query1.Id , query1.tunnus)	
		
		ENDSCAN

	Endif

	Use In query1

	If !Empty(fltrAruanne.tunnus)
* удаляем операции не соответсвующие точному значения признаку
		Select kontoandmik_report
		Delete For tunnus <> comTunnusRemote.kood
	Endif

	Select Sum(deebet)  As dbkokku , Sum (kreedit) krKokku From kontoandmik_report ;
		where  nimetus <> 'Alg.saldo' ;
		and pkonto = cKonto;
		into Cursor qry1
	Update kontoandmik_report Set ;
		dbkokku = qry1.dbkokku, ;
		krKokku = qry1.krKokku, ;
		lsaldo = lnAlg + qry1.dbkokku -  qry1.krKokku;
	Where pkonto = cKonto
	Use In qry1

	SELECT kontoandmik_report 
*	brow
*!*	If Empty (fltrAruanne.konto)
*!*		Select pkonto From kontoandmik_report;
*!*			where (!Empty (deebet) And algs = 0) ;
*!*			or (!Empty (kreedit) And algs = 0);
*!*			into Cursor qryprelAruanne

*!*		Select * From kontoandmik_report;
*!*			where !Empty (pkonto);
*!*			and (!Empty (deebet) Or !Empty (kreedit));
*!*			and pkonto In (Select pkonto From qryprelAruanne);
*!*			order By pkonto, kpv, konto;
*!*			into Cursor kontoandmik_report1
*!*		Use In qryprelAruanne
*!*	ENDIF

	Select * From kontoandmik_report Where !Empty (pkonto) And;
		(!Empty (deebet) Or !Empty (kreedit));
		order By pkonto, kpv, konto, id;
		into Cursor kontoandmik_report1
	Use In kontoandmik_report
Endwith

Select kontoandmik_report1
