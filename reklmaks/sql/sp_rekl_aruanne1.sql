drop table if exists tmpReklAruanne1;

create table tmpReklAruanne1 (timestamp varchar(20), luba varchar(100), toiming_nr varchar(100), summa numeric(14,2), kpv date, staatus varchar(200), 
	lausend_nr varchar(10), volg numeric(14,2), tyyp varchar(100), tyypnimi varchar(100), tasukpv date, tasu_summa numeric(14,2), 
	jaak numeric(14,2), ettemaks numeric(14,2), Intressid numeric (14,2));

drop function if exists sp_rekl_aruanne1(integer,date,date,integer);

CREATE OR REPLACE FUNCTION sp_rekl_aruanne1(tnrekvid integer,tdKpv1 date, tdKpv2 date, tnAsutusId integer)
  RETURNS varchar  AS
$BODY$
DECLARE 
	lcReturn varchar = to_char(now(), 'YYYYMMDDMISSSS');
	v_toiming record;
	lnEttemaks numeric(14,2) = fncReklEttemaksJaak(tnAsutusId);
	lnIntressiJaak numeric(14,2) = fncReklIntressiJaak(tnAsutusId);
	lnJaak numeric(14,2) = 0;
begin
	lnJaak = (select sum(jaak) from luba where parentid = tnAsutusId and staatus > 0);
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

/*

create table tmpReklAruanne1 (timestamp varchar(20), luba varchar(100), toiming_nr varchar(100), summa numeric(14,2), kpv date, staatus varchar(20), 
	lausend_nr varchar(10), volg numeric(14,2), tyyp varchar(100), tyypnimi varchar(100), tasukpv date, tasu_summa numeric(14,2));
*/
	return lcReturn;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


/*
select * from tmpReklAruanne1 where timestamp = '201409033277555'

(select * from sp_rekl_aruanne1(28, date(2014,01,01), date(2014,31,08),19668)) 

select * from tmpReklAruanne1 where timestamp = '201409031372832' order by tyypnimi, toiming_nr, kpv
select * from tmpReklAruanne1

	select a.id, a.nimetus from asutus a where a.id in (select parentid from luba where staatus > 0)

*/
