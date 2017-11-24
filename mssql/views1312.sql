SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



create view Kontodematrix
as
select curKuud.kuu, Kontod.konto, kontod.rekvId 
from (select rekvid, kood as konto from library where library = 'KONTOD') kontod, 
( select 1 as kuu union all select 2 as kuu union all select 3 as kuu union all select 4 as kuu union all select 5 as  kuu union all select 6 as kuu  
union all select 7 as kuu union all select 8 as kuu
union all select 9 as kuu union all select 10 as kuu 
union all select 11 as kuu union all
select 12 as kuu ) curKuud





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW SUBKONTOIDX
AS
select  DISTINCT curJournal.asutusId, konto.id as kontoid , curJournal.REKVID 
from curJournal inner join library konto on konto.kood = curJournal.deebet
where KONTO.library = 'KONTOD'
UNION
select DISTINCT curJournal.asutusId, konto.id as kontoid, curJournal.REKVID 
from curJournal inner join library konto on konto.kood = curJournal.kreedit
where KONTO.library = 'KONTOD'




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE view check_vertical_saldo
as
select _saldo.konto,  _saldo.kuu, _saldo.aasta,_saldo.rekvid,
_saldo.saldo, asaldo.saldo as saldo1
from (select rekvid, konto, datepart (month,period)+1 as kuu , datepart (year,period) as aasta, 
(saldo+dbkaibed - krkaibed) as saldo 
from saldo) asaldo ,
(select rekvId, konto, datepart (month,period) as kuu , datepart (year,period) as aasta,
saldo, (saldo+dbkaibed - krkaibed) as lsaldo 
from saldo) _saldo 
where _saldo.konto = asaldo.konto 
and _saldo.kuu = asaldo.kuu
and _saldo.saldo <> asaldo.saldo
and _saldo.rekvId = asaldo.rekvId
and _saldo.aasta = asaldo.aasta




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



create view check_vertical_subsaldo
as
select _saldo.konto,  _saldo.kuu, _saldo.aasta,_saldo.rekvid,
_saldo.saldo, asaldo.saldo as saldo1
from (select asutusId, rekvid, konto, datepart (month,period)+1 as kuu , datepart (year,period) as aasta, 
(saldo+dbkaibed - krkaibed) as saldo 
from saldo1) asaldo ,
(select asutusId, rekvId, konto, datepart (month,period) as kuu , datepart (year,period) as aasta,
saldo, (saldo+dbkaibed - krkaibed) as lsaldo 
from saldo1) _saldo 
where _saldo.konto = asaldo.konto 
and _saldo.kuu = asaldo.kuu
and _saldo.saldo <> asaldo.saldo
and _saldo.rekvId = asaldo.rekvId
and _saldo.aasta = asaldo.aasta
and _saldo.asutusId = asaldo.asutusId





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.comTooleping
AS
SELECT dbo.tooleping.id, dbo.asutus.nimetus AS isik, 
    dbo.asutus.regkood AS isikukood, 
    osakonnad.kood AS osakond, osakonnad.id as osakondid, Ametid.kood AS amet, Ametid.id as ametid,
    dbo.tooleping.algab, dbo.tooleping.lopp, 
    dbo.tooleping.toopaev, dbo.tooleping.palk, 
    dbo.tooleping.palgamaar, dbo.tooleping.pohikoht, 
    dbo.tooleping.koormus, dbo.tooleping.ametnik, 
    dbo.tooleping.pank, dbo.tooleping.aa, dbo.asutus.rekvid, 
    dbo.tooleping.parentid
FROM dbo.asutus INNER JOIN
    dbo.tooleping ON 
    dbo.asutus.id = dbo.tooleping.parentid INNER JOIN
    dbo.library osakonnad ON 
    dbo.tooleping.osakondid = osakonnad.id INNER JOIN
    dbo.library Ametid ON dbo.tooleping.ametid = Ametid.id



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curAmetid
AS
SELECT Ametid.id, Ametid.nimetus as amet, Osakond.nimetus AS osakond, 
    dbo.palk_asutus.rekvId, dbo.palk_asutus.kogus, 
    dbo.palk_asutus.vaba, dbo.palk_asutus.palgamaar
FROM dbo.library Ametid INNER JOIN
    dbo.palk_asutus ON 
    Ametid.id = dbo.palk_asutus.ametId INNER JOIN
    dbo.library Osakond ON palk_asutus.Osakondid = Osakond.id





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW curEelarve
	AS
	SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasId, eelarve.summa,
eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, rekv.nimetus,  allikad.kood AS allikas, 
allikad.nimetus AS allikanimi, rekv.nimetus as asutus, rekv.regkood, rekv.parentid,
isnull (parent.nimetus,space(254)) as parasutus, isnull ( parent.regkood, space(20)) as parregkood
From  eelarve INNER JOIN rekv ON eelarve.rekvid = rekv.id 
INNER JOIN library allikad ON eelarve.kood2 = allikad.id
left outer join rekv parent on parent.id = rekv.parentid






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW curEelarveKulud
AS
SELECT  eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasId, eelarve.summa, eelarve.kood1, eelarve.kood2,
eelarve.kood3, eelarve.kood4, rekv.nimetus, eelallikas.nimetus AS eelallikas, 
artikkel.kood AS artikkel, tegev.kood  AS tegev, tegev.nimetus as tegevnimi, artikkel.nimetus  AS artnimi,
rekv.nimetus as asutus, rekv.regkood, rekv.parentid,
isnull ( parent.nimetus, space(254)) as parasutus, isnull ( parent.regkood, space(20)) as parregkood
FROM   eelarve INNER JOIN  rekv ON eelarve.rekvid = rekv.id
INNER JOIN library eelallikas ON eelarve.allikasId = eelallikas.id 
INNER JOIN  library artikkel ON eelarve.kood3 = artikkel.id 
INNER JOIN library tegev ON eelarve.kood4 = tegev.id
left outer join rekv parent on parent.id = rekv.parentid






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




CREATE  VIEW dbo.curJournal
AS
SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, datepart (month, journal.kpv) as kuu, datepart (year, journal.kpv) as aasta,
    cast(journal.selg as char(120)) as selg, journal.dok, journal1.summa, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4,
    lausend.deebet, lausend.kreedit,  lausend.nimetus as lausend, lausend.Id as lausendid,
	left(rtrim(asutus.nimetus)+space(1)+rtrim(asutus.omvorm),120) as asutus
FROM journal INNER JOIN journal1 ON journal.id = journal1.parentId INNER JOIN
    lausend ON journal1.lausendid = lausend.id INNER JOIN
    asutus ON journal.asutusid = asutus.id











GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE view curKaibed
as
select isnull(curKreedit.rekvid,curDeebet.rekvid) as rekvid1,
isnull(curKreedit.rekvid,curDeebet.rekvid) as rekvid2,
isnull(curDeebet.kuu, curKreedit.kuu) as kuu1, 
isnull(curKreedit.kuu,curDeebet.kuu) as kuu2,
isnull(curDeebet.aasta, curKreedit.aasta) as aasta1, 
isnull(curKreedit.aasta, curDeebet.aasta) as aasta2,
isnull(curDeebet.konto,curKreedit.konto)  as konto1, 
isnull(curKreedit.konto, curDeebet.konto) as konto2,
isnull(curDeebet.summa,0) as deebet, 
isnull(curKreedit.summa,0) as kreedit
from 
(select rekvid, datepart (month, kpv) as kuu, datepart (year, kpv) as aasta,
sum(summa) as summa, deebet as konto from curJournal 
group by rekvid, datepart (year, kpv), datepart (month, kpv), deebet) curDeebet 
full outer join
(select rekvid, datepart (month, kpv) as kuu, datepart (year, kpv) as aasta,
sum(summa) as summa, kreedit as konto 
from curJournal 
group by rekvid, datepart (year, kpv), datepart (month, kpv), kreedit) curKreedit
on curDeebet.konto = curKreedit.konto and curDeebet.kuu = curKreedit.kuu 
and curDeebet.aasta = curKreedit.aasta





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE view curKuludeTaitmine
as
select kuu,  aasta, curJournal.rekvid, sum(summa) as summa,
artikkel.kood as artikkel, artikkel.nimetus, tegev.kood as tegev, rekv.parentid, rekv.nimetus as asutus, rekv.regkood	
from  curJournal inner join library artikkel on artikkel.id = curJournal.kood3
inner join library tegev on tegev.id = curJournal.kood4
inner join rekv on rekv.id = curJournal.rekvid
group by aasta, kuu , curJournal.rekvid, artikkel.kood,artikkel.nimetus, 
tegev.kood, tegev.nimetus, rekv.parentid, rekv.nimetus, rekv.regkood



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curKulum
AS
SELECT dbo.library.id, dbo.pv_oper.liik, dbo.pv_oper.summa, pv_oper.kpv, library.rekvId,
    GRUPP.nimetus AS grupp, 
	nomenklatuur.kood, nomenklatuur.nimetus as opernimi,
    dbo.pv_kaart.soetmaks, dbo.pv_kaart.soetkpv, 
    dbo.pv_kaart.kulum, dbo.pv_kaart.algkulum, 
    dbo.pv_kaart.gruppId, dbo.pv_kaart.konto, 
    dbo.pv_kaart.tunnus, dbo.asutus.nimetus AS vastisik, 
    dbo.library.kood AS ivnum,     dbo.library.kood AS invnum, 
    dbo.library.nimetus AS pohivara
FROM dbo.library INNER JOIN
    dbo.pv_oper ON 
    dbo.library.id = dbo.pv_oper.parentid INNER JOIN
    dbo.pv_kaart ON dbo.library.id = dbo.pv_kaart.parentid INNER JOIN
    dbo.library GRUPP ON 
    dbo.pv_kaart.gruppId = GRUPP.id INNER JOIN
    dbo.asutus ON dbo.pv_kaart.vastisikid = dbo.asutus.id inner join
dbo.nomenklatuur on pv_oper.nomId = nomenklatuur.id
	















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW curLaduJaak
AS
SELECT ladu_jaak.rekvid, ladu_jaak.hind, ladu_jaak.jaak as jaak, ladu_jaak.kpv,
    nomenklatuur.kood, nomenklatuur.nimetus, 
    nomenklatuur.uhik, grupp.nimetus as grupp,
    ladu_minkogus.kogus as minjaak
FROM ladu_jaak 
INNER JOIN nomenklatuur ON  ladu_jaak.nomid = dbo.nomenklatuur.id 
inner join ladu_grupp on ladu_grupp.nomId = nomenklatuur.id
inner join library grupp on grupp.id = ladu_grupp.parentid
inner join ladu_minkogus on  ladu_minkogus.parentid = nomenklatuur.id




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curLepingud
AS
SELECT dbo.leping1.id, dbo.leping1.rekvid, dbo.leping1.number, 
    dbo.leping1.kpv, isnull ( cast(dbo.leping1.tahtaeg as char(20) ), space(20) )   tahtaeg, cast ( dbo.leping1.selgitus as char(120) ) as selgitus, 
   left( rtrim(dbo.asutus.nimetus)+ space(1)+ rtrim(dbo.asutus.omvorm),120) as asutus, ASUTUS.ID as asutusid
FROM dbo.leping1 INNER JOIN
    dbo.asutus ON dbo.leping1.asutusid = dbo.asutus.id





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


create view curNomJaak
as
select ladu_jaak.nomid,  SUM (ladu_jaak.jaak) as kogus 
from ladu_jaak 
group by nomId





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curPalkJaak
AS
SELECT dbo.asutus.regkood, dbo.asutus.nimetus, 
    dbo.asutus.aadress, dbo.asutus.tel, dbo.palk_jaak.kuu, 
    dbo.palk_jaak.aasta, dbo.palk_jaak.id, dbo.palk_jaak.jaak, 
    dbo.palk_jaak.arvestatud, dbo.palk_jaak.kinni, palk_jaak.tka, palk_jaak.tki, palk_jaak.pm,
    dbo.palk_jaak.tulumaks, dbo.palk_jaak.sotsmaks, 
    dbo.palk_jaak.muud, dbo.asutus.rekvid
FROM dbo.palk_jaak INNER JOIN
    dbo.tooleping ON 
    dbo.palk_jaak.lepingId = dbo.tooleping.id INNER JOIN
    dbo.asutus ON dbo.tooleping.parentid = dbo.asutus.id




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curPalkOper
AS
SELECT   dbo.library.nimetus, dbo.asutus.nimetus AS isik, asutus.id as isikId, palk_oper.journalId, palk_oper.journal1Id,
    dbo.palk_oper.kpv, dbo.palk_oper.summa, palk_oper.id, palk_oper.libId, palk_oper.rekvId,
liik = 
	case
		when liik = 1 then '+'
		when liik = 2 then '-'
		when liik = 6 then '-'	
		when liik = 4 then '-'
		when liik = 8 then '-'
		when liik = 7 and asutusest = 0 then '-'
		else '%'
	end ,
tund = 
	case
		when tund = 1 then 'KOIK'
		when tund = 2 then 'PAEV'
		when tund = 3 then 'OHT'
		when tund = 4 then 'OO'
		when tund = 5 then 'PUHKUS'
		when tund = 6 then 'PUHA'
	end ,
maks = 
	case
		when maks = 1 then 'JAH'
		else 'EI'
	end
FROM dbo.palk_oper INNER JOIN
    dbo.library ON 
    dbo.palk_oper.libId = dbo.library.id INNER JOIN
    dbo.palk_lib ON 
    dbo.palk_lib.parentid = dbo.library.id INNER JOIN
    dbo.tooleping ON 
    dbo.palk_oper.Lepingid = dbo.tooleping.id INNER JOIN
    dbo.asutus ON dbo.tooleping.parentId = dbo.asutus.id











GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curPohiVara
AS
SELECT dbo.library.id, dbo.library.kood, dbo.library.nimetus, dbo.library.rekvId, 
    dbo.pv_kaart.vastisikId, dbo.asutus.nimetus AS vastisik, pv_kaart.algkulum,
    dbo.pv_kaart.soetmaks, dbo.pv_kaart.soetkpv, 
    grupp.nimetus AS grupp, dbo.pv_kaart.konto, pv_kaart.gruppId,
    dbo.pv_kaart.tunnus, dbo.pv_kaart.mahakantud,
  "liik" = 
	CASE 
	WHEN dbo.pv_kaart.tunnus = 1 THEN "Pohivara"
     	ELSE "Vaikevahendid" 
	end
FROM dbo.library INNER JOIN
    dbo.pv_kaart ON 
    dbo.library.id = dbo.pv_kaart.parentid INNER JOIN
    dbo.asutus ON 
    dbo.pv_kaart.vastisikid = dbo.asutus.id INNER JOIN
    dbo.library grupp ON dbo.pv_kaart.gruppid = grupp.id







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curSorder
AS
SELECT dbo.sorder1.id, dbo.sorder1.rekvid, dbo.sorder1.number, cast(dbo.sorder1.nimi as char(120)) as nimi,
    dbo.sorder1.kpv, dbo.sorder1.summa, dbo.sorder1.journalid, 
    dbo.aa.nimetus as kassa
FROM dbo.sorder1 INNER JOIN
    dbo.aa ON dbo.sorder1.kassaid = dbo.aa.id






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curTaabel1
AS
SELECT dbo.palk_taabel1.id, dbo.palk_taabel1.kokku, palk_taabel1.Toolepingid,
    dbo.palk_taabel1.ohtu, dbo.palk_taabel1.oo, dbo.palk_taabel1.too, dbo.palk_taabel1.paev, 
    dbo.palk_taabel1.tahtpaev, palk_taabel1.puhapaev, dbo.palk_taabel1.kuu, 
    dbo.palk_taabel1.aasta, amet.kood AS ametikood, 
    amet.nimetus AS amet, osakond.kood AS osakonnakood, 
    osakond.nimetus AS osakond, dbo.asutus.nimetus AS isik, 
    dbo.asutus.regkood AS isikukood, asutus.rekvId
FROM dbo.palk_taabel1 INNER JOIN
    dbo.tooleping ON 
    dbo.palk_taabel1.toolepingid = dbo.tooleping.id INNER JOIN
    dbo.asutus ON 
    tooleping.Parentid = dbo.asutus.id INNER JOIN
    dbo.library amet ON tooleping.ametid = amet.id INNER JOIN
    dbo.library osakond ON tooleping.osakondid = osakond.id








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE view curTuludeTaitmine
as
select kuu, aasta, curJournal.rekvid, sum(summa) as summa,
allikad.kood as allikas, allikad.nimetus, rekv.parentid, rekv.nimetus as asutus, rekv.regkood
from curJournal inner join library allikad on allikad.id = curJournal.kood2
inner join rekv on rekv.id = curJournal.rekvid
group by kuu, aasta, curJournal.rekvid, allikad.nimetus, allikad.kood, rekv.parentid, rekv.nimetus, rekv.regkood




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curVara
AS
SELECT nomenklatuur.id, dbo.nomenklatuur.kood, nomenklatuur.rekvid,
    nomenklatuur.nimetus, gruppid.nimetus AS grupp, 
    nomenklatuur.uhik, nomenklatuur.hind
FROM nomenklatuur INNER JOIN
    ladu_grupp ON 
    nomenklatuur.id = ladu_grupp.nomid INNER JOIN
    library gruppid ON ladu_grupp.parentid = gruppid.id




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curVorder
AS
SELECT dbo.vorder1.id, dbo.vorder1.rekvid, dbo.vorder1.number, cast(dbo.vorder1.nimi as char(120)) as nimi,
    dbo.vorder1.kpv, dbo.vorder1.summa, dbo.vorder1.journalid, 
    dbo.aa.nimetus as kassa
FROM dbo.vorder1 INNER JOIN
    dbo.aa ON dbo.vorder1.kassaid = dbo.aa.id







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.cur_Doklausend
AS
SELECT dbo.doklausend.summa, dbo.doklausend.kood3, 
    dbo.doklausend.kood4, dbo.doklausend.kbm, 
    dbo.doklausheader.id, dbo.doklausheader.dok, 
    cast ( dbo. doklausheader.selg  as char(120)) selg, dbo.doklausheader.rekvid, 
    dbo.lausend.deebet, dbo.lausend.kreedit, 
    dbo.lausend.nimetus
FROM dbo.doklausend INNER JOIN
    dbo.lausend ON 
    dbo.doklausend.lausendid = dbo.lausend.id INNER JOIN
    dbo.doklausheader ON 
    dbo.doklausend.parentid = dbo.doklausheader.id




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE view curasutusKaibed 
as
select rekvid as rekvid1,
asutusId as asutusId1, kuu as kuu1, aasta as aasta1, konto  as konto1, deebet1 as deebet, 
kreedit1 as kreedit
from 
(select asutusId, rekvid, datepart (month, kpv) as kuu, datepart (year, kpv) as aasta,
sum(summa) as deebet1, 0 as kreedit1, deebet as konto from curJournal 
group by asutusid, rekvid, datepart (year, kpv), datepart (month, kpv), deebet
union all
select asutusid, rekvid, datepart (month, kpv) as kuu, datepart (year, kpv) as aasta,
0 as deebet1, sum(summa) as kreedit1, kreedit as konto 
from curJournal 
group by asutusId, rekvid, datepart (year, kpv), datepart (month, kpv), kreedit) tmpkaibed




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curladuArved
AS
SELECT arv.id, arv1.kogus, arv1.hind, arv.rekvid, arv.number,
    arv.kpv, arv1.summa, arv.journalid,
    ladu_oper.nimetus AS operatsioon, ladu_oper.liik, 
    nomenklatuur.kood,     nomenklatuur.id as nomid,  
    nomenklatuur.nimetus AS nimetus, 
    asutus.nimetus AS asutus,
grupp.nimetus as grupp
FROM arv INNER JOIN    arv1 ON arv.id = arv1.parentid 
INNER JOIN ladu_oper ON arv.operid = ladu_oper.id 
INNER JOIN   nomenklatuur ON    arv1.nomid = nomenklatuur.id 
INNER JOIN    asutus ON arv.asutusid = asutus.id
inner join ladu_grupp on ladu_grupp.nomid = nomenklatuur.id
inner join library grupp on grupp.id = ladu_grupp.parentid







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.curtsd
AS
SELECT asutus.rekvid, asutus.regkood as isikukood, asutus.nimetus as isik, comTooleping.pohikoht, comTooleping.osakondId, palk_lib.liik, palk_lib.asutusest, 
    palk_lib.algoritm, palk_oper.kpv,
palk26 = case
	when palk_lib.liik = 1 and palk_kaart.tulumaar >= 26 then palk_oper.summa else 0
end,
palk15 = case
	when palk_lib.liik = 1 and palk_kaart.tulumaar >= 15 and palk_kaart.tulumaar < 26  then palk_oper.summa else 0
end,
palk10 = case
	when palk_lib.liik = 1 and palk_kaart.tulumaar >= 10 and palk_kaart.tulumaar < 15  then palk_oper.summa else 0
end,
palk5 = case
	when palk_lib.liik = 1 and palk_kaart.tulumaar > 0 and palk_kaart.tulumaar < 10  then palk_oper.summa else 0
end,
palk0 = case
	when palk_lib.liik = 1 and palk_kaart.tulumaar = 0   then palk_oper.summa else 0
end,
TM = case
	when palk_lib.liik = 7 and palk_lib.asutusest = 0  then palk_oper.summa else 0
end,
ATM = case
	when palk_lib.liik = 7 and palk_lib.asutusest = 1  then palk_oper.summa else 0
end,
PM = case
	when palk_lib.liik = 8   then palk_oper.summa else 0
end,
TULUMAKS = case
	when palk_lib.liik = 4   then palk_oper.summa else 0
end,
SOTSMAKS = case
	when palk_lib.liik = 5   then palk_oper.summa else 0
end

FROM comTooleping INNER JOIN palk_oper ON comTooleping.id = palk_oper.lepingid 
inner join asutus on asutus.id = comTooleping.parentid
INNER JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
INNER JOIN palk_kaart on palk_kaart.lepingId = comTooleping.id






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



create view curvaravendor
as
select asutus.*, arv1.nomid
from buhdata5.dbo.asutus inner join arv on arv.asutusid = asutus.id
inner join buhdata5.dbo.arv1 on arv1.parentid = arv.id
where arv.liik = 1
and arv1.nomId in (select nomid from curNomJaak)



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.qryPeriods
AS
SELECT DISTINCT rekvid, DATEPART(month, kpv) AS kuu, DATEPART(year, kpv) AS aasta
FROM         dbo.journal





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE view subkontodematrix
as
select curKuud.kuu, kontod.asutusId, Kontod.konto, kontod.rekvId 
from (select asutusId, subkonto.rekvid, kood as konto from library inner join subkonto on subkonto.kontoid = library.id 
where library = 'KONTOD') kontod, 
( select 1 as kuu union all select 2 as kuu union all select 3 as kuu union all select 4 as kuu union all select 5 as  kuu union all select 6 as kuu  
union all select 7 as kuu union all select 8 as kuu
union all select 9 as kuu union all select 10 as kuu 
union all select 11 as kuu union all
select 12 as kuu ) curKuud






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.wizLepingud
AS
SELECT dbo.leping1.id, dbo.leping1.rekvId, dbo.leping1.number AS kood, 
    dbo.leping2.nomid, cast ( dbo.leping1.selgitus AS char(120) ) 
    AS nimetus, asutus.nimetus as asutus
FROM dbo.leping1 INNER JOIN
    dbo.leping2 ON dbo.leping1.id = dbo.leping2.parentid
inner join asutus on asutus.id = leping1.asutusid
where leping2.status = 1







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

