drop table if exists tmpReklAruanne3;

create table tmpReklAruanne3 (timestamp varchar(20), regkood varchar(20), asutus varchar(254),
	D102060 numeric (14,2), D102095 numeric (14,2), K200060 numeric(14,2), volg numeric(14,2), ettemaks numeric(14,2), intress numeric(14,2));

drop function if exists sp_rekl_aruanne3(integer,date,date,integer);

CREATE OR REPLACE FUNCTION sp_rekl_aruanne3(tnrekvid integer,tdKpv1 date, tdKpv2 date, tnAsutusId integer)
  RETURNS varchar  AS
$BODY$
DECLARE 
	lcReturn varchar = to_char(now(), 'YYYYMMDDMISSSS');
begin
	delete from tmpReklAruanne3  where left(timestamp,8)::integer < left(lcReturn,8)::integer;

	insert into tmpReklAruanne3
		select lcReturn, a.regkood, a.nimetus,
			asd('102060%',a.id, tnRekvId,  tdKpv2), asd('102095%',a.id, tnRekvId,  tdKpv2), ask('200060%',a.id, tnRekvId,  tdKpv2),
			(select sum(fncdekljaak(t.id)) from toiming t where parentid = a.id and tyyp in ('DEKL','PARANDUS') and staatus > 0 and kpv <= tdKpv2) as volg,
			fncreklettemaksjaak(a.id) as ettemaks, fncreklintressijaak(a.id) as intress
			from asutus a 
			where id in (select parentId from luba l where l.staatus > 0) 
			and (a.id = tnAsutusId or coalesce(tnAsutusId = 0));
	return lcReturn;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


/*

select sp_rekl_aruanne3(28,date(),date(),29940);
select sum(fncDeklJaak(id)) as intress_kokku from toiming where parentId = 35400 and tyyp = 'INTRESS' and staatus > 0
select * from tmpReklAruanne3 where timestamp = '201409044242171'
 
select * from tmpReklAruanne2 where timestamp = '201409044034822' order by luba, toiming_nr, kpv

select * from tmpReklAruanne1

	select a.id, a.nimetus from asutus a where a.id in (select parentid from luba where staatus > 0)

select * from asutus where regkood = '10451293'
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
