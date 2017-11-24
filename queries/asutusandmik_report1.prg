Parameter cWhere
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif

Local lnDeebet, lnKreedit
lnDeebet = 0
lnKreedit = 0
dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
Replace fltrAruanne.kpv1 with dKpv1,;
	fltrAruanne.kpv2 with dKpv2 in fltrAruanne
&&dKpv2 = date(year(dkpv2), month(dkpv2),1)
If !empty(fltrAruanne.Asutusid)
	tnId = fltrAruanne.Asutusid
	oDb.use('v_asutus','query1')
&&	Use v_asutus in 0 alias query1
	cAsutus = ltrim(rtrim(upper(query1.nimetus)))
Else
	cAsutus = '%%'
Endif
Create cursor KaibeAsutusAndmik_report1 (algsaldo n(12,2),deebet n(12,2),;
	kreedit n(12,2),konto c(20), nimetus c(120), asutus c(120), Asutusid int)
index on asutusid tag asutusId
set order to asutusid
&& algsaldo arvestused
dKpv2 = dKpv1
dKpv1 = date(year(dKpv1), month(dKpv1),1)
If used('cursorSaldod1')
	Use in cursorSaldod1
Endif
Wait window [Arvestan alg.saldo ..] nowait
tcKonto = iif(empty(fltrAruanne.konto),'%%',fltrAruanne.konto)
tnAasta = year(dKpv1)
&&Use querySubKontod in 0 alias 'kontonimetused'
oDb.use('querySubKontod','kontonimetused')
oDb.use('v_saldod1','cursorSaldod')
&&Use v_saldod1 in 0 alias 'cursorSaldod'
Select cursorSaldod
If dKpv1 < fltrAruanne.kpv1
	cDeebet = '%%'
	cKreedit = '%%'
	cDok = '%%'
	cSelg = '%%'
	nSumma1 = -99999999
	nSumma2 = 999999999
&&	dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
&&	Use curJournal in 0 alias Journalquery1
	oDb.use('curJournal','JournalQuery1')
	Select cursorSaldod
	Scan for iif(!empty(fltrAruanne.konto),cursorSaldod.konto,fltrAruanne.konto) = fltrAruanne.konto;
			and iif(!empty(fltrAruanne.Asutusid),cursorSaldod.Asutusid,fltrAruanne.Asutusid) = fltrAruanne.Asutusid
		Select Journalquery1
		Sum summa for alltrim(deebet) = alltrim(cursorSaldod.konto) and;
			Journalquery1.Asutusid = cursorSaldod.Asutusid  to lnDeebet
		Sum summa for alltrim(kreedit) = alltrim(cursorSaldod.konto) and;
			Journalquery1.Asutusid = cursorSaldod.Asutusid to lnKreedit
		Select kontonimetused
		Locate for kood = cursorSaldod.konto and Asutusid = cursorSaldod.Asutusid
		Insert into KaibeAsutusAndmik_report1 (algsaldo,  konto, nimetus,Asutusid, asutus);
			values (cursorSaldod.saldo+lnDeebet-lnKreedit, cursorSaldod.konto,;
			kontonimetused.nimetus,cursorSaldod.Asutusid,kontonimetused.nimetus)
	Endscan
Else
	Select cursorSaldod
	Scan for iif(!empty(fltrAruanne.konto),cursorSaldod.konto,fltrAruanne.konto) = fltrAruanne.konto
		Select kontonimetused
		Locate for kood = cursorSaldod.konto and Asutusid = cursorSaldod.Asutusid
		Insert into KaibeAsutusAndmik_report1 (algsaldo,  konto, nimetus,Asutusid, asutus);
			values (cursorSaldod.saldo, cursorSaldod.konto,;
			kontonimetused.nimetus,cursorSaldod.Asutusid,kontonimetused.nimetus)
	Endscan
Endif
Use in kontonimetused
Wait window [Arvestan kaibed ..] nowait

&& обороты
dKpv1 = fltrAruanne.kpv1
dKpv2 = fltrAruanne.kpv2
cDeebet = '%%'
cKreedit = '%%'
cDok = '%%'
cSelg = '%%'
nSumma1 = -99999999
nSumma2 = 999999999
oDb.use('curJournal','JournalQuery1')
*!*	If used('Journalquery1')
*!*		=requery('Journalquery1')
*!*	Else
*!*		Use curJournal in 0 alias Journalquery1
*!*	Endif
Select cursorSaldod
Scan for iif(!empty(fltrAruanne.konto),cursorSaldod.konto,fltrAruanne.konto) = fltrAruanne.konto;
		and iif(!empty(fltrAruanne.Asutusid),cursorSaldod.Asutusid,fltrAruanne.Asutusid) = fltrAruanne.Asutusid
	Select Journalquery1
	Sum summa for alltrim(deebet) = alltrim(cursorSaldod.konto) and;
		Journalquery1.Asutusid = cursorSaldod.Asutusid  to lnDeebet
	Sum summa for alltrim(kreedit) = alltrim(cursorSaldod.konto) and;
		Journalquery1.Asutusid = cursorSaldod.Asutusid to lnKreedit
	Update KaibeAsutusAndmik_report1 set;
		deebet = lnDeebet,;
		kreedit = lnKreedit;
		where konto = cursorSaldod.konto;
		and Asutusid = cursorSaldod.Asutusid
Endscan

If used('Journalquery1')
	Use in Journalquery1
Endif
If used('cursorSaldod')
	Use in cursorSaldod
Endif
clear
Select KaibeAsutusAndmik_report1

