-- Function: sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)
/*
SELECT nomenklatuur.kood, nomenklatuur.nimetus, nomenklatuur.uhik, grupp.nimetus AS grupp
   FROM nomenklatuur 
   JOIN ladu_grupp ON ladu_grupp.nomid = nomenklatuur.id
   JOIN library grupp ON grupp.id = ladu_grupp.parentid;

select sp_ladu_aruanne1(1, date(), date(), '%', '%', 1)

select * from tmp_kaibeandmik_report where timestamp = '201209044856907KOKKU'


CREATE TABLE tmp_kaibeandmik_report
(
  asutusid integer DEFAULT 0,
  asutus character varying(254) DEFAULT space(1),
  regkood character varying(20) DEFAULT space(1),
  aadress text DEFAULT space(1),
  konto character varying(20) DEFAULT space(1),
  korkonto character varying(20) DEFAULT space(1),
  tunnus character varying(20) DEFAULT space(1),
  dokkpv date DEFAULT date(),
  algdb numeric(14,2) DEFAULT 0,
  algkr numeric(14,2) DEFAULT 0,
  db numeric(14,2) DEFAULT 0,
  kr numeric(14,2) DEFAULT 0,
  loppdb numeric(14,2) DEFAULT 0,
  loppkr numeric(14,2) DEFAULT 0,
  kood1 character varying(20) DEFAULT space(1),
  kood2 character varying(20) DEFAULT space(1),
  kood3 character varying(20) DEFAULT space(1),
  kood4 character varying(20) DEFAULT space(1),
  kood5 character varying(20) DEFAULT space(1),
  dok character varying(120) DEFAULT space(1),
  lausend integer DEFAULT 0,
  "timestamp" character varying(20),
  kpv date DEFAULT date(),
  rekvid integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tmp_kaibeandmik_report OWNER TO vlad;
GRANT ALL ON TABLE tmp_kaibeandmik_report TO vlad;
GRANT ALL ON TABLE tmp_kaibeandmik_report TO public;

		select  SUM(kogus) as kogus, sum(hind * kogus) as summa, nomid 
		from curladuarved  
		where kpv < date()
		and NomId IN (
			SELECT nomenklatuur.id 
				FROM nomenklatuur 
				JOIN ladu_grupp ON ladu_grupp.nomid = nomenklatuur.id
				JOIN library grupp ON grupp.id = ladu_grupp.parentid
			where ltrim(rtrim(upper(nomenklatuur.kood))) like upper('200%') and ltrim(rtrim(upper(grupp.kood))) like upper('%') and nomenklatuur.rekvid = 1
			) 
		and liik = 2
		 group by nomId, liik;


*/



CREATE OR REPLACE FUNCTION sp_ladu_aruanne1(integer, date, date, character varying, character varying, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tcgrupp alias for $4;
	tcNom alias for $5;
	tnTunnus alias for $6;

	lcReturn varchar;
	lcString varchar;

	lnAlg numeric(18,6);
	lnLopp numeric (18,6);

begin

	delete from tmp_kaibeandmik_report where kpv < date();
	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

if tnTunnus = 1 then 
-- kaupade jaak seisuga tdkpv1

-- kaupade algkaibed
	raise notice 'tcnom %',tcNom;

	insert into tmp_kaibeandmik_report (algdb,db, lausend, timestamp, rekvid )  
		select  SUM(kogus) as kogus, sum(hind * kogus) as summa, nomid , lcreturn, tnRekvid 
		from curladuarved  
		where kpv < tdKpv1 
		and NomId IN (
			SELECT nomenklatuur.id 
				FROM nomenklatuur 
				JOIN ladu_grupp ON ladu_grupp.nomid = nomenklatuur.id
				JOIN library grupp ON grupp.id = ladu_grupp.parentid
			where ltrim(rtrim(upper(nomenklatuur.kood))) like upper(tcNom) and ltrim(rtrim(upper(grupp.kood))) like upper(tcgrupp) and nomenklatuur.rekvid = tnRekvId
			) 
		and liik = 1 
		 group by nomId, liik;
	
	insert into tmp_kaibeandmik_report (algkr,kr, lausend, timestamp, rekvid )  
		select  SUM(kogus) as kogus, sum(hind * kogus) as summa, nomid , lcreturn, tnRekvid 
		from curladuarved  
		where kpv < tdKpv1 
		and NomId IN (
			SELECT nomenklatuur.id 
				FROM nomenklatuur 
				JOIN ladu_grupp ON ladu_grupp.nomid = nomenklatuur.id
				JOIN library grupp ON grupp.id = ladu_grupp.parentid
			where ltrim(rtrim(upper(nomenklatuur.kood))) like upper(tcNom) and ltrim(rtrim(upper(grupp.kood))) like upper(tcgrupp) and nomenklatuur.rekvid = tnRekvId
			) 
		and liik = 2 
		group by nomId, liik;

	insert into tmp_kaibeandmik_report (algdb, algkr,db,kr, lausend, timestamp, rekvid )  
		Select sum(algdb), sum(algkr), sum(db), sum(kr), lausend, lcreturn+'KOKKU',tnrekvid
		from tmp_kaibeandmik_report
		where timestamp = lcreturn and rekvid = tnrekvid
		group by lausend;
	

--	delete from tmp_kaibeandmik_report where timestamp = lcreturn and rekvid = tnrekvid;

	lcreturn = lcreturn+'KOKKU';

end if;



	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_ladu_aruanne1(integer, date, date, character varying, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_ladu_aruanne1(integer, date, date, character varying, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_ladu_aruanne1(integer, date, date, character varying, character varying, integer) TO dbpeakasutaja;
