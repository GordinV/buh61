-- Function: sp_koosta_saldoandmik(integer, date, integer, integer)

-- DROP FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE tnRekvId alias for $1;
	tdKpv alias for $2;
	tnAasta alias for $3;
	tnTyyp alias for $4;
	lcReturn varchar;
	lcString varchar;
	lcOmaTp varchar;
	v_rekv record;
	lnTulemus integer;


begin

lnTulemus = 0;
if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'SALDOANDMIK')  < 1 then
	
	CREATE TABLE saldoandmik
	(
	id serial NOT NULL,
	nimetus character varying(254) NOT NULL DEFAULT space(1),
	db numeric(12,2) NOT NULL DEFAULT 0,
	kr numeric(12,2) NOT NULL DEFAULT 0,
	konto character varying(20) NOT NULL DEFAULT space(1),
	tegev character varying(20) NOT NULL DEFAULT space(1),
	tp character varying(20) NOT NULL DEFAULT space(1),
	allikas character varying(20) NOT NULL DEFAULT space(1),
	rahavoo character varying(20) NOT NULL DEFAULT space(1),
	kpv date DEFAULT date(),
	aasta integer DEFAULT year(date()),
	kuu integer default month(date()),
	rekvid integer,
	omatp character varying(20) NOT NULL DEFAULT space(1),
	tyyp integer DEFAULT 0
	) ;

	ALTER TABLE saldoandmik OWNER TO vlad;
	GRANT ALL ON TABLE saldoandmik TO vlad;
	GRANT SELECT ON TABLE saldoandmik TO dbvaatleja;
	GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE saldoandmik TO saldoandmikkoostaja;
		
end if;

if tnTyyp = 1 then
	-- re-arvesta saldoandmik
	raise notice 'Kustutan vana andmed ';
	delete from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) ;
end if;


-- Kontrolin kas arvestame saldoandmik uuesti

if (select count(*) from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) ) = 0 then
	raise notice 'Andmed puuduvad, siis arvestame saldoandmik uuesti ';
	lnTulemus = 1;
else
	lnTulemus = 0;
end if;


if lnTulemus > 0 then

-- Saldoandmik koostamine
	lnTulemus = 0;

	for v_rekv in 
		select id from rekv where parentid <> 9999 and id not in (123,116,122)

	loop
		raise notice 'Toimub %', v_rekv.id;

		-- otsin oma TP kood
/*		
		SELECT TP INTO lcOmaTp FROM Aa WHERE Aa.parentid = v_rekv.id   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
		lcOmaTp = ifnull(lcOmaTp,'');
		if v_rekv.id = 63 and tnAasta = 2010 then
			lcOmaTp = '185101';
		end if;
*/

		lcOmaTp = fnc_getomatp(v_rekv.id,tnAasta);		

		lcreturn = sp_saldoandmik_report(v_rekv.id, tdKpv, 0, 0, 0);

		lcReturn = ifnull(lcReturn,'TUHI');

		if (not empty(lcReturn) and lcReturn <> 'TUHI') then

			raise notice 'Saldoandmik arvestatud, salvestamine ... %', v_rekv.id;

			insert into saldoandmik (nimetus, db,kr,konto,tegev,tp,	allikas,rahavoo ,kpv,aasta,kuu, rekvid,omatp,tyyp)
			select nimetus, db,kr,konto,tegev,tp,	allikas,rahavoo ,tdkpv, year(tdKpv), month(tdKpv), v_rekv.id,lcOmatp,0 
			from tmp_saldoandmik
			where timestamp = lcreturn;
	
			lnTulemus = lnTulemus + 1;

			raise notice 'Saldoandmik salvestatud ... %', v_rekv.id;
-- kassakulud
			raise notice 'Kassakulud arvestus alustatud ... %', v_rekv.id;

			perform sp_koosta_kassakulud(v_rekv.id, tdKpv, year(tdKpv), tnTyyp);
			raise notice 'Kassakulud salvestatud ... %', v_rekv.id;

		end if;

	end loop;

end if; -- saldoandmik koostamine

RETURN lnTulemus;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer) TO saldoandmikkoostaja;
