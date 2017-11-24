Create Sql View cursaldo As  ;
	Select Date(2000,01,01) As kpv, kontoinf.rekvid, Library.kood As konto, ;
	IIF( kontoinf.algsaldo >= 0, Val(Str(kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As deebet, ;
	IIF( kontoinf.algsaldo < 0 , Val(Str(-1 * kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As kreedit, ;
	1 As OPT, 000000000 As asutusId  From Library INNER Join kontoinf On Library.Id = kontoinf.parentid ;
	where algsaldo <> 0;
	union All  ;
	Select Date(Iif(Empty(aasta),1999,aasta), Iif(Empty(kuu),1,kuu),1) As kpv, rekvid, konto,  ;
	VAL(Str(dbkaibed,12,4))  As deebet, Val(Str(krkaibed,12,4)) As kreedit, 3 As OPT, asutusId  ;
	from saldo  Where saldo.asutusId > 0 And !Empty(kuu) And !Empty(aasta);
	AND dbkaibed <> 0 And krkaibed <> 0;
	union All  ;
	SELECT kpv, rekvid, deebet As konto, Val(Str(Summa,12,4)) As deebet,  Val(Str(000000000.0000,12,4)) As kreedit,;
	4 As OPT, asutusId  From curJournal_  ;
	union All  ;
	SELECT kpv, rekvid, kreedit As konto, ;
	VAL(Str(000000000.0000,12,4)) As deebet, Val(Str(Summa,12,4))  As kreedit, 4 As OPT, asutusId ;
	from curJournal_

Create Sql View qrySaldoAruanne;
	AS;
	SELECT deebet As konto, kreedit As korkonto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo,;
	VAL(Str(Summa,12,2)) As deebet, Val('000000000.00') As kreedit, rekvid, tunnus, kpv, kood5 ;
	FROM curJournal_ ;
	UNION All;
	SELECT kreedit As konto, deebet As korkonto, lisa_k As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo, ;
	VAL('000000000.00')  As deebet,  Val(Str(Summa,12,2)) As kreedit, rekvid, tunnus, kpv, kood5 ;
	FROM curJournal_


Create Sql View fakttulud As  ;
	SELECT Distinct Left(Ltrim(Rtrim(Library.kood))+ '%', 20) As kood   ;
	FROM Library  Where Library.Library = 'TULUKONTOD'

Create Sql View faktkulud As  ;
	SELECT Distinct Left(Ltrim(Rtrim(Library.kood)) + '%', 20) As kood   ;
	FROM Library  Where Library.Library = 'KULUKONTOD'

Create Sql View curkuludetaitmine_ As  ;
	SELECT kuu, aasta, curJournal_.rekvid, Sum(Summa) As Summa, curJournal_.kood5 As kood, Space(1) As eelarve, ;
	curJournal_.kood1 As tegev, curJournal_.tunnus As tun, curJournal_.kood2   ;
	FROM curJournal_  INNER Join faktkulud On Ltrim(Rtrim(curJournal_.deebet)) Like Ltrim(Rtrim(faktkulud.kood))  ;
	GROUP By aasta, kuu, curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus, ;
	curJournal_.kood5, curJournal_.kood2  ;
	ORDER By aasta, kuu, curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus, ;
	curJournal_.kood5, curJournal_.kood2


	Create Sql View curkassakuludetaitmine_;
		AS;
		SELECT kuu, aasta, curJournal_.rekvid, Sum(Summa) As Summa, curJournal_.kood5 As kood, Space(1) As eelarve,;
		curJournal_.kood1 As tegev, curJournal_.tunnus As tun, curJournal_.kood2   ;
		FROM curJournal_   Join kassakulud On Trim(deebet) Like Rtrim(kassakulud.kood);
		INNER  Join kassakontod On Rtrim(curJournal_.kreedit) Like Rtrim(kassakontod.kood);
		GROUP By aasta, kuu, curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus,;
		curJournal_.kood5, curJournal_.kood2

	Create Sql View curKassaTuludeTaitmine_;
		as;
		select kuu, aasta, curJournal_.rekvid, curJournal_.tunnus As tun, Sum(Summa) As Summa,;
		curJournal_.kood5 As kood, curJournal_.kood5 As eelarve, curJournal_.kood1 As tegev, curJournal_.kood2;
		from curJournal_ ;
		INNER Join kassatulud On Ltrim(Rtrim(curJournal_.kreedit)) Like Ltrim(Rtrim(kassatulud.kood));
		INNER Join kassakontod On Ltrim(Rtrim(curJournal_.deebet)) Like Ltrim(Rtrim(kassakontod.kood));
		group By aasta, kuu , curJournal_.rekvid, curJournal_.kood1, curJournal_.kood2, curJournal_.kood5, curJournal_.tunnus;
		order By aasta, kuu , curJournal_.rekvid, curJournal_.kood1, curJournal_.kood2,  curJournal_.kood5, curJournal_.tunnus;



Set Data To buhdata5
lnViews = Adbobject (laView,'VIEW')
For i = 1 To lnViews
	lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
Endfor
