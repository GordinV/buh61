delete from palk_oper where lepingid in (select id from tooleping where parentid = 33968) and kpv = date(2015,01,31);
select liik, tululiik, summa, gen_palkoper(id, libId, 0,  date(2015,01,31),0) from (
select liik, pl.tululiik, pk.summa, t.id, pk.libId
	FROM Library l 
	inner join Palk_kaart  pk on pk.libId = l.id  
	inner join   Palk_lib pl on pl.parentId = l.id  
	inner join tooleping t on pk.lepingId = t.id 
	left outer join dokvaluuta1 on (pk.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where t.parentid = 33968
and pk.status = 1	
order by liik, case when coalesce(pl.tululiik,'99') = '' then '99' else tululiik end, Pk.percent_ desc, pk.summa desc
) qry


select liik, case when coalesce(pl.tululiik,'99') = '' then '99' else tululiik end,  Pk.percent_ , pk.summa
	FROM Library l 
	inner join Palk_kaart  pk on pk.libId = l.id  
	inner join   Palk_lib pl on pl.parentId = l.id  
	inner join tooleping t on pk.lepingId = t.id 
	left outer join dokvaluuta1 on (pk.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where t.parentid = 33968
and pk.status = 1	
order by liik, case when coalesce(pl.tululiik,'99') = '' then '99' else tululiik end, Pk.percent_ desc, pk.summa desc
