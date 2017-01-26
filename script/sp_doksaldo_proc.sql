CREATE OR REPLACE FUNCTION sp_doksaldo_report(integer,  date, date, character varying, interger)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tcKonto alias for $4;
	tnAsutusId alias for $5;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;

	lnAsutusId1 integer;
	lnAsutusId2 integer;
	lnreturn interger;
	LNcOUNT int;

	lcKonto varchar(20);
	tmpTasu record;
	tmpArvSaldo record;
	tmpGrKonto record;
begin

lnreturn = 0;
lnAsutusid1 = 0;
lnAsutusid2 = 999999;
 
IF not empty(tnAsutusid) then
	lnAsutusid1 = tnAsutusid;
	lnAsutusid2 = tnAsutusid;
END IF;

select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_DOKSALDO';
if ifnull(lnCount,0) < 1 then
	
	create table tmp_doksaldo (arvid integer not null default 0, number varchar (20) not null default space(1), arvkpv date, 
		asutus varchar (120) not null default space(1), asutusid int not null default 0, liik int not null default 0, 
		summa numeric (12,2) not null default 0, tasu numeric (12,2) not null default 0, jaak numeric (12,2) not null default 0, 
		konto varchar(20) not null default space(1), algdb numeric (12,2) not null default 0, algkr numeric (12,2) not null default 0, algjaak numeric (12,2) not null default 0, 
		timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_tmp_doksaldo TO GROUP public;

else
	delete from tmp_doksaldo where kpv < date() and rekvid = tnrekvId;
end if;

lcreturn := to_char(now(), 'YYYYMMDDMISS');

-- kaibed
-- arved

INSERT INTO tmp_doksaldo (arvid, number, kpv, asutus, asutusid, liik , summa, timestamp, rekvid  ) 
	SELECT arv.id as arvid, arv.number, arv.kpv, asutus.nimetus as asutus, arv.asutusid, arv.liik, arv.summa, lcReturn, tnRekvid
	FROM arv inner join asutus on arv.asutusId = asutus.id
	WHERE arv.rekvid = tnrekvid AND arv.kpv >= tdKpv1 AND arv.kpv <= tdKpv2 AND 
	arv.asutusid >= lnAsutusId1 AND arv.asutusid <= lnAsutusid2 and
	doklausid in (select dokprop.id FROM library inner join dokprop on 
	(library.id = dokprop.parentid AND library.library = 'DOK') 
	WHERE konto like tcKonto AND rekvId = tnRekvid);



-- tasu

for tmpTasu in
SELECT arvId, sum(summa) as summa FROM arvtasu 
	WHERE rekvid = tnRekvid AND kpv >= tdKpv1 AND kpv <= tdKpv2 AND arvid in (select arvid FROM  doksaldo_report)
	GROUP BY arvid 

loop
	update tmp_doksaldo set tasu = tmptasu.summa where arvId =  tmpTasu.arvid and timestamp = lcReturn and rekvid = tnRekvid;
END loop;


-- algsaldo
--koik arved where jaak <> 0 or tasud > tdKpv1

for tmpArvSaldo in
	SELECT arv.id as arvid, arv.number, arv.kpv, asutus.nimetus as asutus, arv.asutusid, arv.liik, 0 as summa,
	0 as tasu, arv.jaak as algjaak 
	FROM arv inner join asutus on arv.asutusId = asutus.id
	WHERE arv.rekvid = tnrekvid AND  (arv.jaak <> 0 AND arv.kpv < tdKpv1 or arv.tasud >= tdKpv1) AND 
	arv.asutusid >= lnAsutusId1 AND arv.asutusid <= lnAsutusid2 and
	doklausid in (select dokprop.id FROM library inner join dokprop on 
	(library.id = dokprop.parentid AND library.library = 'DOK') 
	WHERE konto like tcKonto AND rekvId = tnRekvid)
 
loop

	if (select count(*) from tmp_doksaldo where arvId =  tmpTasu.arvid and timestamp = lcReturn and rekvid = tnRekvid) > 0 then

		update tmp_doksaldo set algjaak = tmpArvSaldo.algjaak where arvId =  tmpTasu.arvid and timestamp = lcReturn and rekvid = tnRekvid;

	ELSE
		INSERT INTO tmp_doksaldo (arvid, number, kpv, asutus, asutusid, liik , algjaak, timestamp, rekvid  ) 
		SELECT arv.id as arvid, arv.number, arv.kpv, asutus.nimetus as asutus, arv.asutusid, arv.liik, arv.jaak, lcReturn , tnrekvid
  		FROM arv inner join asutus on arv.asutusId = asutus.id
 		WHERE arv.id = tmpArvSaldo.arvId;
	
	END IF;	
 END loop;
 

--- konto algsaldo

for tmpGrKonto in
SELECT konto  FROM tmp_doksaldo GROUP BY konto WHERE NOT EMPTY(konto) and timestamp = lcReturn and rekvid = tnRekvid
loop	
	lnAlg = sd(tmpGrKonto.Konto, tnRekvid, tdkpv1-1);
	IF lnAlg <> 0 then
		UPDATE tmp_doksaldo SET algdb = lnAlg WHERE konto = tmpGrKonto.Konto and timestamp = lcReturn and rekvid = tnRekvid;
	END IF;
	lnAlg = 0;		
END loop;
	
UPDATE tmp_doksaldo SET jaak = algjaak + summa - tasu WHERE  timestamp = lcReturn and rekvid = tnRekvid;


return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_doksaldo_report(integer,  date, date, character varying, interger) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_doksaldo_report(integer,  date, date, character varying, interger) TO vlad;
GRANT EXECUTE ON FUNCTION sp_doksaldo_report(integer,  date, date, character varying, interger) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_doksaldo_report(integer,  date, date, character varying, interger) TO dbpeakasutaja;
