Parameter cWhere

CREATE CURSOR Laduraamat_report1 (nomid int,kood c(20), nimetus c(254), uhik c(20), asutus c(254) null,tunnus c(20) null,;
	number c(20), kpv d null, akogus n(14,2), asumma n(18,6), ssumma n(18,6), skogus n(12,4), shind n(18,2),;
	vsumma n(18,6), vkogus n(12,4), vhind n(18,6), lsumma n(18,6), lkogus n(14,2), skbm n(18,6), vkbm n(18,8), aKogusKokku n(18,6), aSummaKokku n(18,6),;
	lKogusKokku n(18,4), lSummaKokku n(18,4))
INDEX ON (kood+DTOC(kpv)) TAG kood
SET ORDER TO kood

*!*	tcOper = '%'+rtrim(ltrim(fltrLaduArved.oper))+'%'
tcKood = '%'+rtrim(ltrim(fltrLaduArved.kood))+'%'
*!*	tcNumber = '%'+rtrim(ltrim(fltrLaduArved.number))+'%'
tcAsutus = '%'+rtrim(ltrim(fltrLaduArved.asutus))+'%'
tdKpv1 = iif(empty(fltrLaduArved.kpv1),date(year(date()),1,1),fltrLaduArved.kpv1)
tdKpv2 = iif(empty(fltrLaduArved.kpv2),date(year(date()),12,31),fltrLaduArved.kpv2)
*!*	tnKogus1 = iif(empty(fltrLaduArved.kogus1),-999999999,fltrLaduArved.kogus1)
*!*	tnKogus2 = iif(empty(fltrLaduArved.kogus2),999999999,fltrLaduArved.kogus2)
*!*	tnSumma1 = iif(empty(fltrLaduArved.Summa1),-999999999,fltrLaduArved.Summa1)
*!*	tnSumma2 = iif(empty(fltrLaduArved.Summa2),999999999,fltrLaduArved.Summa2)

TEXT TO lcSqlString noshow
select q.nomId, algkogus, dbKogus, krKogus, db, kr, qH.hind,
n.kood, n.nimetus, n.uhik,
coalesce(a.number,'') as number, a.kpv, coalesce(q.tunnus,'') as tunnus,
coalesce(c.nimetus,'') as asutus
from (
select sum(algkogus) as algkogus, 
	sum(dbKogus) as dbKogus, sum(krKogus) as krKogus, 
	sum(db) as db,
	sum(kr) as kr,
	nomId, arvid, tunnus
	from (
		-- alg.jaak
			select  SUM(kogus * (case when a.liik = 1 then 1 else -1 end)) as algkogus, 
				0 as dbKogus, 0 as krKogus, 0 as db, 0 as kr, 
				nomid, 0 as arvId, null::text as tunnus
				from curladuarved a 
				where a.kpv < ?tdKpv1 -- algkpv 
				and a.rekvId = ?gRekv
			 	group by a.nomId
		union all
			--kaibed
			select  0 as algkogus,
				(kogus * (case when a.liik = 1 then 1 else 0 end)) as dbKogus,
				(kogus * (case when a.liik = 2 then 1 else 0 end)) as krKogus, 
				(hind * kogus * (case when a.liik = 1 then 1 else 0 end)) as db, 
				(hind * kogus * (case when a.liik = 2 then 1 else 0 end)) as kr, 
				nomid,
				a.id as arvId, a.tunkood::text as tunnus
			from curladuarved a 
			where a.kpv >= ?tdKpv1 -- algkpv 
			and a.kpv <= ?tdKpv2 -- lookpv 
			and a.rekvId = ?gRekv
	--		 group by a.nomId
	) as qry
--where algkogus <> 0 or dbKogus <> 0 or krKogus <> 0
group by nomId, arvid, tunnus
order by arvid, nomId
) as q
inner join (
	select (summaKokku / kogusKokku) as hind, nomId
			from (
				select  SUM(kogus * hind) as summaKokku, sum(kogus) as kogusKokku,
				nomid
				from curladuarved a 
				where a.liik = 1 -- ainult sissetuliku hind 
				and a.kpv < DATE()  
				and a.rekvId = ?gRekv
				 group by a.nomId
				 ) qryHind1
			where qryHind1.kogusKokku > 0
) qH on qH.nomId = q.nomid

inner join nomenklatuur n on n.id  = q.nomid
JOIN ladu_grupp ON ladu_grupp.nomid = n.id
JOIN library grupp ON grupp.id = ladu_grupp.parentid
left outer join arv a on a.id = q.arvid
left outer join asutus c on c.id = a.asutusid
where (algkogus <> 0 or dbKogus <> 0 or krKogus <> 0)
and n.kood ilike ?tcKood
ENDTEXT
lnError = SQLEXEC(gnhandle,lcSqlString,'query')

If lnError < 0
	_cliptext = lcSqlString
	SELECT 0
	RETURN
ENDIF

SELECT max(hind) as hind, nomid ;
	FROM query ;
	WHERE hind > 0;
	group by nomId ;
	INTO CURSOR qryHind

INSERT into Laduraamat_report1 (nomid, kood, nimetus, uhik, asutus, tunnus, number, kpv, akogus, asumma, skogus, shind, ssumma, vkogus, vsumma, lkogus,lsumma );
	SELECT query.nomid, query.kood, query.nimetus, query.uhik,query.asutus, query.tunnus,query.number,IIF(ISNULL(query.kpv),{},query.kpv),; 
		query.algKogus,  algKogus * getAverageHind(query.nomId),  ;
		query.dbkogus, getAverageHind(query.nomId), query.db, ;
		query.krKogus, query.kr, ;
		loopKogus(query.nomId),;
		loopKogus(query.nomId) * getAverageHind(query.nomId) ;
	FROM query 


SELECT sum(algKogus) as algKogus, sum(algKogus * getAverageHind(query.nomId)) as algJaak,;
	sum(dbkogus) as skogus,;
	sum(krKogus) as vkogus,;
	sum(algKogus + dbkogus - krkogus) as lkogus,;
	sum((algKogus + dbkogus - krkogus) * getAverageHind(query.nomId)) as lsumma;
	FROM query ;
	INTO CURSOR queryTotal
	

UPDATE Laduraamat_report1 SET ;
		aKogusKokku = queryTotal.algKogus ,;
		aSummaKokku = queryTotal.algJaak,;
		lKogusKokku = queryTotal.lKogus ,;
		lSummaKokku = queryTotal.lsumma

SELECT Laduraamat_report1
return


FUNCTION getAverageHind
LPARAMETERS tnNomId
LOCAL lnHind
lnHind = 0

SELECT qryHind
LOCATE FOR nomId = tnNomid
IF !EOF()
	lnHind = qryHind.hind
ENDIF


RETURN lnHind


FUNCTION loopKogus 
LPARAMETERS tnNomId
LOCAL jaak
jaak = 0

SELECT sum(algKogus) as algKogus,;
	sum(dbkogus) as skogus,;
	sum(krKogus) as vkogus;
	FROM query ;
	WHERE nomid = tnNomId;
	INTO CURSOR queryJaak

IF RECCOUNT('queryJaak') > 0 
	jaak = queryJaak.algKogus + queryJaak.skogus - queryJaak.vkogus
ENDIF

RETURN jaak