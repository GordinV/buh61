CREATE OR REPLACE FUNCTION sp_saldoaruanne(int4, date, date)
  RETURNS setof v_saldoaruanne AS
'
SELECT konto, tp, tegev, allikas, rahavoo, sum(deebet) as db, sum (kreedit) as kr
from (SELECT deebet as konto, lisa_d as tp, kood1 as tegev, kood2 as allikas, kood3 as rahavoo,
	summa::numeric(12,4) as deebet, 0::numeric(12,4) as kreedit 
	FROM curJournal WHERE rekvid = $1 AND kpv >= $2 and kpv <= $3
	UNION all
	SELECT kreedit as konto, lisa_d as tp, kood1 as tegev, kood2 as allikas, kood3 as rahavoo, 
	0::numeric(12,4)  as deebet,  summa::numeric(12,4) as kreedit 
	FROM curJournal WHERE rekvid = $1 AND kpv >= $2 and kpv <= $3) qrySaldoAruanne
group BY konto, tp, tegev, allikas, rahavoo
ORDER BY konto, tp, tegev, allikas, rahavoo;
'
  LANGUAGE 'sql' VOLATILE;
