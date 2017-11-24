
CREATE OR REPLACE FUNCTION sp_rekl_aruanne2(tnrekvid integer, tdkpv1 date, tdkpv2 date, tnasutusid integer)
  RETURNS character varying AS
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
