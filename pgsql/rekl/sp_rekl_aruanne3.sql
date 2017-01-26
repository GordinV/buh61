CREATE OR REPLACE FUNCTION sp_rekl_aruanne3(tnrekvid integer, tdkpv1 date, tdkpv2 date, tnasutusid integer)
  RETURNS character varying AS
$BODY$
DECLARE 
	lcReturn varchar = to_char(now(), 'YYYYMMDDMISSSS');
begin
	delete from tmpReklAruanne3  where left(timestamp,8)::integer < left(lcReturn,8)::integer;

	insert into tmpReklAruanne3
		select lcReturn, a.regkood, a.nimetus,
			asd('102060%',a.id, tnRekvId,  tdKpv2), asd('102095%',a.id, tnRekvId,  tdKpv2), ask('200060%',a.id, tnRekvId,  tdKpv2),
			(select sum(fncdekljaak(t.id)) from toiming t where parentid = a.id and tyyp in ('DEKL','PARANDUS') 
				and staatus > 0 
				and kpv <= tdKpv2 
				and year(kpv) = year(tdKpv2) ) as volg,
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
select sp_rekl_aruanne3(28, date(2014,09,01), date(), 1941 )

select * from asutus where regkood = '10717472'

select * from (
		select a.regkood, a.nimetus,
			asd('102060%',a.id, 28,  date()) as asd102060, asd('102095%',a.id, 28,  date()) as asd102095, ask('200060%',a.id, 28,  date()) as ask,
			(select sum(fncdekljaak(t.id)) from toiming t where parentid = a.id and tyyp in ('DEKL','PARANDUS') and staatus > 0 and kpv >= date(2014,01,01) and kpv <= date()) as volg,
			fncreklettemaksjaak(a.id) as ettemaks, fncreklintressijaak(a.id) as intress
			from asutus a 
			where id in (select parentId from luba l where l.staatus > 0) 
			and (a.id = 1941 or coalesce(1941 = 0))
) qry where qry.asd102060 <> 0 or volg <> 0

select * from tmpReklAruanne3 where timestamp = '201410152155312'

select * from curJournal where left(kreedit,3) = '258' and kood3 = '05'

*/