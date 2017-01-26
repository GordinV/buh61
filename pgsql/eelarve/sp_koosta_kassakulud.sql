-- Function: sp_koosta_kassakulud(integer, date, integer, integer)
/*
select sp_koosta_kassakulud(rekv.id,date(2012,09,01),2012,0) from rekv where parentid < 999
*/
-- DROP FUNCTION sp_koosta_kassakulud(integer, date, integer, integer);

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

	lnSummaDb numeric (18,6);
	lnSummaKr numeric (18,6);
	lnEEKKuurs numeric(18,6);
	


begin
lnTulemus = 0;
lnEEKKuurs = fnc_valuutakuurs('EEK');

--if tnTyyp = 1 then
	-- re-arvesta kassakulud
--	raise notice 'Kustutan vana andmed ';	
	delete from aastakassakulud where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvid;
	delete from eeltaitmine where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvid;

--end if;


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
--	lcReturn =  sp_eelarve_aruanne1(tnRekvId, ldKpv1, tdKpv, 0, '', '', '', '', '', '', '', 501, 0);

--	lcReturn = ifnull(lcReturn,'TUHI');

--	if (not empty(lcReturn) and lcReturn <> 'TUHI') then

--		raise notice 'Kassakulud arvestatud, salvestamine ... %', v_rekv.id;

		for v_kulud in
			select * from curkassakuludetaitmine where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnRekvId and left(kood,1) <> '3'
		loop
			lnId = sp_salvesta_aastakassakulud(0, v_kulud.summa, 'EEK', lnEEKKuurs, v_kulud.tegev, v_kulud.kood2, v_kulud.kood, date(), 
				year(tdKpv), month(tdKpv), tnRekvId);

			lnTulemus = lnTulemus + 1;
			raise notice 'Kassakulud salvestatud salvestatud ... %', v_kulud.eelarve;

		end loop;
	
		for v_kulud in
			select * from curkassatuludetaitmine 
				where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnRekvId
				and kood not in (select distinct kood5 from eeltaitmine where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnRekvId)

		loop
			lnId = sp_salvesta_aastakassakulud(0, v_kulud.summa, 'EEK', lnEEKKuurs, v_kulud.tegev, v_kulud.kood2, v_kulud.kood, date(), 
				year(tdKpv), month(tdKpv), tnRekvId);

			lnTulemus = lnTulemus + 1;
			raise notice 'Kassatulud salvestatud salvestatud ... %', v_kulud.eelarve;

		end loop;


		select sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1)) into lnSummaDb 
			from Journal inner join journal1 on journal.id = journal1.parentid
			LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
			where Journal.rekvid = tnRekvid 
			and year(Journal.kpv) = year(tdKpv) and month(Journal.kpv) = month(tdKpv)
			and deebet like '710000%' and lisa_d <> '18510101';

		select sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1)) into lnSummaKr 
			from journal1 inner join journal on journal.id = journal1.parentid
			LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
			where Journal.rekvid = tnRekvid 
			and year(Journal.kpv) = year(tdKpv) and month(Journal.kpv) = month(tdKpv)
			and (kreedit in ('203850','350000') or kreedit like '103%') 
			and kood5 = '3500.00';

		lnId = sp_salvesta_aastakassakulud(0, ifnull(lnSummaDb,0) - ifnull(lnSummaKr,0), 'EEK', lnEEKKuurs, '', '', '3500, 352', date(), 
			year(tdKpv), month(tdKpv), tnRekvId);
	
 			

--	end if;
end if; 

RETURN lnTulemus;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_kassakulud(integer, date, integer, integer) TO saldoandmikkoostaja;
