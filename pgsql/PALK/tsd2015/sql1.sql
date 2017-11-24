
select po.summa, tulumaks, sotsmaks, tootumaks, pensmaks, tulubaas, po.muud
from palk_oper po
inner join tooleping t on t.id = po.lepingId
where parentid = 33968
and po.kpv = date(2015,01,31)
order by po.id


--select sp_calc_arv(137886, 609832, date(2015,01,31))