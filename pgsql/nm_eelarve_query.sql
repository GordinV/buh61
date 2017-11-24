select sum(e.summa) as eelarve, sum(j.summa) as taitmine,  j.aasta, j.kuu, j.kood1, j.kood2, j.kood3, j.kood5,
j.deebet as korrkonto
from curJournal as j
left outer join eelarve e on e.aasta = j.aasta and e.kuu = j.kuu and e.kood1 = j.kood1 and e.kood2 = j.kood2 and  e.kood3 = j.kood3 and  e.kood5 = j.kood5
inner join kassakulud on ltrim(rtrim(j.deebet)) ~~ ltrim(rtrim(kassakulud.kood))
where j.aasta = 2015
and (not empty(j.kood5) or not empty(e.kood5))
and j.deebet in -- tegelik kulud
	(select l.kood
		from library l
		inner join faktkulud ON ltrim(rtrim(l.kood::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
		where library = 'KONTOD'
		)
			
group by j.aasta, j.kuu, j.kood1, j.kood2, j.kood3, j.kood5, j.deebet, j.kreedit
order by j.aasta, j.kuu, j.kood1, j.kood2, j.kood3, j.kood5, j.deebet, j.kreedit
limit 100

/*

or j.kreedit in (
		select l.kood
			from library l
			JOIN fakttulud ON ltrim(rtrim(l.kood::text)) ~~ ltrim(rtrim(fakttulud.kood::text))
			where library = 'KONTOD'
			)

and (j.deebet in (select l.kood 
	from library l
	inner join kassakulud on ltrim(rtrim(l.kood))  ~~ ltrim(rtrim(kassakulud.kood))
	where library = 'KONTOD'
	) 
or 


select * from kassakulud


and ltrim(rtrim(j.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))

*/