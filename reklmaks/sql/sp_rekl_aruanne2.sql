drop table if exists tmpReklAruanne2;

create table tmpReklAruanne2 (timestamp varchar(20), luba varchar(100), toiming_nr varchar(100), summa numeric(14,2), kpv date, 
	volg numeric(14,2), tasukpv date, tasu_summa numeric(14,2), paevad integer, intressi_maar numeric(12,4),
	intress numeric (14,2), makstud_intress numeric (14,2), intressis_jaak numeric(14,2), period varchar(100));

drop function if exists sp_rekl_aruanne2(integer,date,date,integer);

CREATE OR REPLACE FUNCTION sp_rekl_aruanne2(tnrekvid integer,tdKpv1 date, tdKpv2 date, tnAsutusId integer)
  RETURNS varchar  AS
$BODY$
DECLARE 
	lcReturn varchar = to_char(now(), 'YYYYMMDDMISSSS');
	v_toiming record;
begin
	delete from tmpReklAruanne2  where left(timestamp,8)::integer < left(lcReturn,8)::integer;

	insert into tmpReklAruanne2
	select lcReturn, 
	(case when length(trim(both ' ' from l.number)) = 1 then '0' else '' end + trim(both ' ' from l.number))::varchar(100) + ', Reklaami eksponeerimise period: ' + ltrim(rtrim(v.lubaperiod)) as luba,
		v.deklnumber,  
		v.doksumma, v.doktahtaeg, v.dokvolg, v.laekkpv, v.laeksumma, v.dokpaevad, v.intressimaar,v.muudsumma,
		coalesce(tasud.summa,0), 
		coalesce((select sum(fncDeklJaak(id)) as intress_kokku from toiming where parentId = tnAsutusId and tyyp = 'INTRESS' and staatus > 0),0) as intressi_jaak,
		v.period
	from luba l
		inner join toiming t on l.id = t.lubaId and t.tyyp = 'INTRESS'
		inner join viiviseinfo v on v.intressid = t.id
		left outer join (select max(tasukpv) as kpv, sum(summa) as summa, deklId from dekltasu group by deklid) tasud on tasud.deklId = t.id
		
	where l.rekvid = tnrekvid
	and t.kpv >= tdKpv1 and t.kpv <= tdkpv2
	and l.parentId = tnAsutusId
	and t.staatus > 0
	and t.summa <> 0;

	return lcReturn;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


/*

select sp_rekl_aruanne2(28,date(2014,09,01),date(),35400);
select sum(fncDeklJaak(id)) as intress_kokku from toiming where parentId = 35400 and tyyp = 'INTRESS' and staatus > 0
select * from tmpReklAruanne2 where timestamp = '201409045832285'
 
select * from tmpReklAruanne2 where timestamp = '201409044034822' order by luba, toiming_nr, kpv

select * from tmpReklAruanne1

	select a.id, a.nimetus from asutus a where a.id in (select parentid from luba where staatus > 0)

select * from asutus where regkood = '12173303   '
select * from viiviseinfo where asutusId = 35400


	select
	(case when length(trim(both ' ' from l.number)) = 1 then '0' else '' end + trim(both ' ' from l.number))::varchar(100) as luba,
		v.deklnumber,  
		v.doksumma, v.doktahtaeg, v.dokvolg, v.laekkpv, v.laeksumma, v.dokpaevad, v.intressimaar,v.muudsumma,
		coalesce(tasud.summa,0), fncDeklJaak(t.id)

	select t.kpv,l.parentId,*
	from luba l
		inner join toiming t on l.id = t.lubaId and t.tyyp = 'INTRESS'
		inner join viiviseinfo v on v.intressid = t.id
		left outer join (select max(tasukpv) as kpv, sum(summa) as summa, deklId from dekltasu group by deklid) tasud on tasud.deklId = t.id
	where l.rekvid = 28
	and t.kpv >= date(2014,01,01) and t.kpv <= date()
	and l.parentId = 35400
	and t.summa <> 0;

select * from tmpReklAruanne2

*/
