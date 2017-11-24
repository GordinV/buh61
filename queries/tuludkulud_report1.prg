Parameter tcWhere
Create cursor tuludKulud_report1 (pkonto c(20), konto c(20),liik c(20), nimetus c(254), kuu1 y, kuu2 y,;
	kuu3 y, kuu4 y, kuu5 y, kuu6 y, kuu7 y, kuu8 y, kuu9 y, kuu10 y, kuu11 y, kuu12 y, kokku y)
Index on liik+pkonto + konto tag konto
Set order to konto
Create cursor tkkontod (konto c(20), tyyp n(1), dbkogus int, krkogus int)
Index on konto tag konto
Set order to konto
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'

cDok = 'PERIOD'

With oDb
	.use('comDokLaus','qryTuLudKulud',.t.)
	.dbreq('qryTuLudKulud',0,'comDokLaus')
	.use ('v_tuludkulud')
	.use ('v_kasumkahju')
Endwith
&& анализируем структуру доходов и расходов
Select qryTuLudKulud
Scan
	tnId = qryTuLudKulud.id
	oDb.use ('v_doklausend','qrydoklausend')
	select distinc deebet as konto, 1 as tyyp from qrydoklausend; 
		where kreedit = v_kasumkahju.kood;
		and deebet not in (select konto from tkKontod);
		into cursor qryTulud2
	select tkKontod
	append from dbf('qryTulud2')
	use in qryTulud2
	select distinc kreedit as konto, 2 as tyyp from qrydoklausend ;
		where deebet = v_kasumkahju.kood ;
		and kreedit not in (select konto from tkKontod);
		into cursor qryKulud2
	select tkKontod
	append from dbf('qryKulud2')
	use in qryKulud2
Endscan
Select tkkontod
Scan 
	Select comKontodremote
	Locate for kood = tkkontod.konto
	nKuu1 = month(fltrAruanne.kpv1)
	nKuu2 = month (fltrAruanne.kpv2)
	cKonto = rtrim(tkkontod.konto)
	Select tuludKulud_report1
	Append blank
	Replace konto with tkkontod.konto,;
		pkonto with iif (comKontodremote.liik = 3, comKontodremote.pohikonto, comKontodremote.kood),;
		liik with iif (tkkontod.tyyp = 2, 'KULUD', 'TULUD'),;
		nimetus with comKontodremote.nimetus in tuludKulud_report1
	For nKuu = nKuu1 to nKuu2

		nAasta  = year (fltrAruanne.kpv1)
		If !used ('qrySaldo')
			oDb.use ('v_saldo','qrySaldo')
		Else
			oDb.dbreq('qrySaldo',gnHandle,'v_saldo')
		Endif

		If reccount ('qrySaldo') > 0
			cString = " replace kuu"+ alltrim(str (nKuu,2)) + " with "+ ;
				iif (tkkontod.tyyp = 1,str (qrySaldo.dbKaibed+;
				(-1 * (qrySaldo.saldo + qrySaldo.dbkaibed - qrySaldo.krKaibed)),12,2),;
				str (qrySaldo.krKaibed + (qrySaldo.saldo + qrySaldo.dbkaibed - qrySaldo.krKaibed),12,2)) + " in TuludKulud_report1 "
			&cString
		Endif
		Select v_tuludkulud
		Locate for alltrim(konto) == alltrim(tkkontod.konto)
		If found ()
&& есть проводка увуличивающая сумму
			tdKpv1 = date (year (fltrAruanne.kpv1),nKuu,1)
			tdKpv2 = gomonth(tdKpv1,1) - 1
			tnLausendId = v_tuludkulud.lausendId
			If !used ('qryTK')
				oDb.use ('qryTuludKulud', 'QRYTK')
			Else
				oDb.dbreq ('qryTuludKulud',gnHandle,'QRYTK')
			Endif
			If reccount ('QRYTK') > 0
				cString = " replace kuu"+ alltrim(str (nKuu,2)) + " with "+ ;
					"kuu"+ alltrim(str (nKuu,2))+ "-" + str (QRYTK.summa,12,2)+ " in TuludKulud_report1 "
				&cString
			Endif
			use in qrytk
		Endif

	Endfor
	Replace kokku with kuu1 + kuu2 + kuu3 + kuu4 + kuu5 + kuu6 + kuu7 + kuu8 + kuu9 + kuu10 + kuu11 + kuu12 in tuludKulud_report1
Endscan
If used ('qrySaldo')
	Use in qrySaldo
Endif
If used ('tkKontod')
	Use in tkkontod
Endif
If used ('v_tuludkulud')
	Use in v_tuludkulud
Endif
If used ('qrytuludkulud')
	Use in qrytuludkulud
Endif
Select tuludKulud_report1
