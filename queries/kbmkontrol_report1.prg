Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
cAsutus = ''
	if !empty (fltrAruanne.asutusId)
		tnId = fltrAruanne.asutusId
		oDb.use('v_asutus','qryAsutus')
		cAsutus = rtrim(ltrim(qryAsutus.nimetus))
		use in qryAsutus
	endif
Local lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
lnDeebet = 0
lnKreedit = 0
tcKasutaja = '%'

dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
cDeebet = '%'
cKreedit = '%'
cAsutus = cAsutus+'%'
cSelg = '%'
cDok = '%%'
nSumma1 = -999999999
nSumma2 = 999999999
tcTpD = '%'
tcTpK = '%'

odb.use('curJournal','qryJournal')
create cursor kbmkontrol_report1 (kpv d, id int, asutus c(120), selg c(254), deebet c(20), kreedit c(20),;
	 dok c(120), summa y)
select * from qryJournal where id in (select id from qryJournal qryJournal_; 
	where deebet like alltrim(fltrAruanne.deebet)+'%'; 
	and  kreedit like alltrim(fltrAruanne.kreedit)+'%'); 
	and summa <> 0;
	order by id;
	into cursor kbmkontrol_report1
use in qryJournal
if used('qryJournal_')
	use in qryJournal_
endif
Select kbmkontrol_report1
