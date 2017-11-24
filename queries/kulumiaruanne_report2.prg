Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
Local lnDeebet, lnKreedit
lnDeebet = 0
lnKreedit = 0
Create cursor kuuaruanne_report2 (kood c(20), Nimetus c(254), loppperiod y,;
		algperiod y, pLopp y, pAlg y)


dKpv1 = date(year(fltrAruanne.kpv1),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
&& loading algsaldo tableid
lnYear = year (dKpv1)
lnMonth = month (dKpv1)
If lnMonth > 12
	lnMonth = 1
	lnYear = lnYear + 1
Endif
With odb
	lError = .exec ("sp_saldo ",str(grekv)+", "+str(lnMonth,2)+","+str(lnYear,4)+",'%'", 'cursorAlgSaldo' )
	lnYear = year (dKpv2)
	lnMonth = month (dKpv2)
	If lnMonth > 12
		lnMonth = 1
		lnYear = lnYear + 1
	Endif
	lError = .exec ("sp_saldo ",str(grekv)+", "+str(lnMonth,2)+","+str(lnYear,4)+",'%'", 'cursorLoppSaldo' )
	.use('v_kuuaruanne')
	If reccount('v_kuuaruanne') = 0
		Use in v_kuuaruanne
		Select 0
		Return .f.
	Endif
	Select v_kuuaruanne
	Scan
		lcReanr = substr(v_kuuaruanne.library, 4,8)
		Wait window [Arvestan konto kuuaruanne rea ]+lcReanr nowait
		lnAlg = kontosaldo(alltrim(v_kuuaruanne.kood),dkpv1)
		lnLopp = kontoloppsaldo(alltrim(v_kuuaruanne.kood),fltrAruanne.kpv2)
		Insert into kuuaruanne_report2 (kood, Nimetus, algperiod, loppperiod);
		 values (lcreanr, v_kuuaruanne.nimetus, lnAlg, lnLopp)
	Endscan
	Clear
	Use in v_kuuaruanne
Endwith
Select kuuaruanne_report2




Function kontosaldo
	Parameter cKontogrupp, tdKpv
	Local lnSaldo, lnDeebet, lnKreedit
	If empty (cKontogrupp)
		Return 0
	Endif
	lnSaldo = 0
	lnDeebet = 0
	lnKreedit = 0
	dKpv1 = tdKpv
	dKpv2 = tdKpv
	dKpv = date(year(tdKpv), month(tdKpv),1)
	nAasta = year(tdKpv)
	nKuu =  month(tdKpv)
	cKonto = alltrim(cKontogrupp)+'%'
	lnYear = year (tdKpv)
	lnMonth = month (tdKpv)
	If lnMonth > 12
		lnMonth = 1
		lnYear = lnYear + 1
	Endif
	If dKpv < dKpv1
		dKpv1 = dKpv
		cDeebet = cKonto
		cKreedit = '%%'
		cAsutus = '%%'
		cDok = '%%'
		cSelg = '%%'
		nSumma1 = -99999999
		nSumma2 = 999999999
		odb.use('curJournal','query1')
		Select query1
		Sum summa to lnDeebet
		cDeebet = '%%'
		cKreedit = cKonto
		odb.dbreq('query1',gnHandle,'curJournal')
		Sum summa to lnKreedit
	Endif
	Select cursorAlgsaldo
	Select iif (type = 1 or type = 3,deebet-kreedit,kreedit-deebet) as nSaldo ;
		from cursorAlgsaldo inner join comKontodRemote on comKontodRemote.kood = cursorAlgsaldo.konto;
		where left (alltrim(cursorAlgsaldo.konto),len(cKontogrupp))= cKontogrupp;
		into cursor tmpSaldo
&&	Sum (cursorAlgsaldo.deebet - cursorAlgsaldo.kreedit) for left (alltrim(konto),len(cKontogrupp))= cKontogrupp to lnSaldo
	If val(alltrim(cursorParent1.parentrea)) < lnRea
		lnSaldo = tmpSaldo.nSaldo + lnDeebet - lnKreedit
	Else
		lnSaldo = tmpSaldo.nSaldo - lnDeebet + lnKreedit
	Endif
	If used('query1')
		Use in query1
	Endif
	Use in tmpSaldo
	Return lnSaldo


Function kontoloppsaldo
	Parameter cKontogrupp, tdKpv
	Local lnSaldo, lnDeebet, lnKreedit
	If empty (cKontogrupp)
		Return 0
	Endif
	lnSaldo = 0
	lnDeebet = 0
	lnKreedit = 0
	dKpv1 = tdKpv
	dKpv2 = tdKpv
	dKpv = date(year(tdKpv), month(tdKpv),1)
	nAasta = year(tdKpv)
	nKuu =  month(tdKpv)
	cKonto = alltrim(cKontogrupp)+'%'
	lnYear = year (tdKpv)
	lnMonth = month (tdKpv)
	If lnMonth > 12
		lnMonth = 1
		lnYear = lnYear + 1
	Endif
	If dKpv < dKpv1
		dKpv1 = dKpv
		cDeebet = cKonto
		cKreedit = '%%'
		cAsutus = '%%'
		cDok = '%%'
		cSelg = '%%'
		nSumma1 = -99999999
		nSumma2 = 999999999
		odb.use('curJournal','query1')
		Select query1
		Sum summa to lnDeebet
		cDeebet = '%%'
		cKreedit = cKonto
		odb.dbreq('query1',gnHandle,'curJournal')
		Sum summa to lnKreedit
	Endif
	Select iif (type = 1 or type = 3,deebet-kreedit,kreedit-deebet) as nSaldo ;
		from cursorLoppSaldo inner join comKontodRemote on comKontodRemote.kood = cursorLoppSaldo.konto;
		where left (alltrim(cursorLoppSaldo.konto),len(cKontogrupp))= cKontogrupp;
		into cursor tmpSaldo
	Select cursorLoppSaldo
&&	Sum (cursorAlgsaldo.deebet - cursorAlgsaldo.kreedit) for left (alltrim(konto),len(cKontogrupp))= cKontogrupp to lnSaldo
&&	lnSaldo = lnSaldo + lnDeebet - lnKreedit
	If val(alltrim(cursorParent1.parentrea)) < lnRea
		lnSaldo = tmpSaldo.nSaldo + lnDeebet - lnKreedit
	Else
		lnSaldo = tmpSaldo.nSaldo - lnDeebet + lnKreedit
	Endif
	If used('query1')
		Use in query1
	Endif
	Use in tmpSaldo
	Return lnSaldo


