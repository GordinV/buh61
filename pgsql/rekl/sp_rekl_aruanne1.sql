-- Function: sp_rekl_aruanne1(integer, date, date, integer)

-- DROP FUNCTION sp_rekl_aruanne1(integer, date, date, integer);

CREATE OR REPLACE FUNCTION sp_rekl_aruanne1(tnrekvid integer, tdkpv1 date, tdkpv2 date, tnasutusid integer)
  RETURNS character varying AS
$BODY$
DECLARE 
	lcReturn varchar = to_char(now(), 'YYYYMMDDMISSSS');
	v_toiming record;
	lnEttemaks numeric(14,2) = fncReklEttemaksJaak(tnAsutusId, tdKpv2);
	lnIntressiJaak numeric(14,2) = fncReklIntressiJaak(tnAsutusId, tdKpv2);
	lnJaak numeric(14,2) = 0;
	lnAlgJaak numeric (14,2) = 0;
	lnAlgEttemaks numeric (14,2) = fncReklEttemaksJaak(tnAsutusId, tdKpv1);
	lnAlgIntress numeric (14,2) = fncReklIntressiJaak(tnAsutusId, tdKpv1);

begin

	select sum(fncdekljaak(t.id)) into lnAlgJaak from toiming t
		where parentId = tnAsutusId and staatus > 0 
		and tyyp in ('ALGSALDO','DEKL','PARANDUS') and kpv <= tdKpv1;

	select sum(fncdekljaak(t.id)) into lnJaak from toiming t
		where parentId = tnAsutusId and staatus > 0 
		and tyyp in ('ALGSALDO','DEKL','PARANDUS') and kpv <= tdKpv2;
		
	delete from tmpReklAruanne1  where left(timestamp,8)::integer < left(lcReturn,8)::integer;
-- deklaratsioonid
	insert into tmpReklAruanne1
	select lcReturn, 
	(case when length(trim(both ' ' from l.number)) = 1 then '0' else '' end + trim(both ' ' from l.number))::varchar(100) as luba,
		(case when t.number < 10 then '0' else '' end + t.number::text)::varchar(100) as number, t.summa, t.tahtaeg as kpv, 
		case when t.staatus = 0 then 'Anuleeritud' when t.staatus > 0 then 'Kehtiv' end::varchar(100), 
		coalesce(j.number::varchar(10),'')::varchar(10) as lausend_nr,fncDeklJaak(t.id) as volg, t.tyyp, 
		case when t.tyyp  = 'DEKL' or t.tyyp  = 'PARANDUS' or t.tyyp  = 'ALGSALDO' then 'Arvestus ' 
			when tyyp = 'INTRESS' then 'Intresside arvestus' end::varchar(100) as tyypnimi,
		tasud.kpv, coalesce(tasud.summa,0), lnJaak, lnEttemaks, lnIntressiJaak
	from luba l
		inner join toiming t on l.id = t.lubaId
		left outer join journalId j on j.journalId = t.journalId
		left outer join (select max(tasukpv) as kpv, sum(summa) as summa, deklId from dekltasu group by deklid) tasud on tasud.deklId = t.id
	where l.rekvid = tnrekvid
	and t.kpv >= tdKpv1 and t.kpv <= tdkpv2
	and l.parentId = tnAsutusId
	and t.summa <> 0
	and t.tyyp <> 'TASU'
	union all
	select  lcReturn,'Luba: ' as luba, ''::varchar(100), e.summa, e.kpv, 
		e.selg::varchar(200) as staatus,
		case when e.number = 0 then '' else e.number::varchar(100) end as lausend_nr, 0 as volg, 'Ettemaks' as tyyp, 'Laekumised' as tyypnimi, null, 0,
		lnJaak, lnEttemaks, lnIntressiJaak
		from ettemaksud e
		left outer join journalId j on j.journalId = e.journalId
		where e.asutusid = tnAsutusId and e.kpv >= tdKpv1 and e.kpv <= tdkpv2;

	update tmpReklAruanne1 set 
		alg_intressid = lnAlgIntress,
		alg_ettemaks = lnAlgEttemaks,
		alg_jaak = lnAlgJaak
		where timestamp = lcReturn;

/*

create table tmpReklAruanne1 (timestamp varchar(20), luba varchar(100), toiming_nr varchar(100), summa numeric(14,2), kpv date, staatus varchar(20), 
	lausend_nr varchar(10), volg numeric(14,2), tyyp varchar(100), tyypnimi varchar(100), tasukpv date, tasu_summa numeric(14,2));

  alg_intressid numeric(14,2),
  alg_ettemaks numeric(14,2),
  alg_jaak numeric(14,2)

*/
	return lcReturn;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

/*
select * from asutus where nimetus ilike '%aikomus%'
select * from  sp_rekl_aruanne1(28, date(2014,08,01), date(), 35400)



*/