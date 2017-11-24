select * from (

select sk.db, sa.db,sk.db-sa.db as dbvord, sk.kr, sa.kr,sk.kr-sa.kr as krvord, sk.rekvid, sk.konto, sk.tp, sk.tegev, sk.allikas, sk.rahavoo 
from saldoandmik sk
left outer join saldoandmik sa on (sk.konto = sa.konto and sk.tp = sa.tp and sk.tegev = sa.tegev and sk.allikas = sa.allikas and sk.rahavoo = sa.rahavoo and sk.rekvid = sa.rekvid) 
where sk.aasta = 3011 and sk.kuu = 10 
and sa.aasta = 2011 and sa.kuu = 10
order by sk.rekvid, sk.konto, sk.tp, sk.tegev, sk.allikas, sk.rahavoo
) tmp
where dbvord <> 0 or krvord <> 0


select sum(db) as db, sum(kr) as kr from saldoandmik where aasta = 2011 and kuu = 10 and rekvid = 999


select * from saldoandmik where aasta = 3011 and kuu = 10 and rekvid = 63
 and left(konto,1) = '7' 