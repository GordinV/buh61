-- Function: sp_koosta_saldoandmik(integer, date, integer, integer)

-- DROP FUNCTION sp_koosta_saldoandmik(integer, date, integer, integer);

/*
select fnc_getomatp(63,2011);		
select * from eeltaitmine where aasta = 2011
select * from aastakassakulud
select sp_koosta_kassakulud(63, date(2011,09,30), 2011, 1)
*/

CREATE OR REPLACE FUNCTION sp_koosta_kassakulud(integer, date, integer, integer)
  RETURNS integer AS
$BODY$
DECLARE tnRekvId alias for $1;
	tdKpv alias for $2;
	tnAasta alias for $3;
	tnTyyp alias for $4;
	lcReturn varchar;
	lcString varchar;
	lcOmaTp varchar;
	v_kulud record;
	lnTulemus integer;
	ldKpv1 date;
	lnId integer;
	


begin
lnTulemus = 0;

if tnTyyp = 1 then
	-- re-arvesta kassakulud
	raise notice 'Kustutan vana andmed ';	
	delete from aastakassakulud where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvid;
	delete from eeltaitmine where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvid;

end if;


-- Kontrolin kas arvestame saldoandmik uuesti

if (select count(*) from aastakassakulud where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnRekvid) = 0 then
	raise notice 'Andmed puuduvad, siis arvestame kassakulud uuesti ';
	lnTulemus = 1;
else
	lnTulemus = 0;
end if;

lcOmaTp = fnc_getomatp(tnRekvId,tnAasta);		

if lnTulemus > 0 then

-- Kassakulud koostamine
	lnTulemus = 0;


--	lcreturn = sp_saldoandmik_report(v_rekv.id, tdKpv, 0, 0, 0);
	ldKpv1 = date(year(tdKpv),01,01);
	lcReturn =  sp_eelarve_aruanne1(tnRekvId, ldKpv1, tdKpv, 0, '', '', '', '', '', '', '', 501, 0);

	lcReturn = ifnull(lcReturn,'TUHI');

	if (not empty(lcReturn) and lcReturn <> 'TUHI') then

--		raise notice 'Kassakulud arvestatud, salvestamine ... %', v_rekv.id;

		for v_kulud in
			select * from tmp_eelproj_aruanne1 where timestamp = lcReturn		
		loop
			lnId = sp_salvesta_aastakassakulud(0, v_kulud.summa3, 'EEK', 1, v_kulud.tegev, v_kulud.allikas, v_kulud.eelarve, date(), 
				year(tdKpv), month(tdKpv), tnRekvId);

			lnTulemus = lnTulemus + 1;
			raise notice 'Kassakulud salvestatud salvestatud ... %', v_kulud.eelarve;

		end loop;
	



	end if;
end if; 

RETURN lnTulemus;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO saldoandmikkoostaja;
