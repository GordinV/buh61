PROCEDURE sp_ASUTUSkaibed 
lParameter trekv, tkuu1, tKuu2, taasta,tkonto,tAsutus

select top 1 kuu from aasta where kinni = 1 order by kuu desc into cursor qryTmp
lnAlgKuu = qryTmp.kuu
use in qryTmp
if lnalgKuu < tkuu1 
	select curkaibed.asutusId, asutus.nimetus as asutus, curkaibed.rekvid , curkaibed.kuu,; 
		curKaibed.aasta,	curkaibed.konto, sum(curKaibed.deebet) as deebet, sum(curKaibed.kreedit) as kreedit ;
		from curAsutusKaibed curkaibed inner join asutus on asutus.id = curkaibed.asutusId1;
		where rekvid1 = trekv; 
		and kuu1 >= tkuu1;
		and kuu1 <= tkuu2;
		and aasta1 = taasta;
		and konto1 like tkonto;
		and asutus.nimetus like tasutus;
		order by asutusId, rekvId, kuu, aasta;
		group by asutusId, rekvId, kuu, aasta;	
		union ;
	select asutusId, asutus.nimetus as asutus, km.rekvid, km.kuu, taasta as aasta, km.konto, 0 as deebet, 0 as kreedit;
		from subkontodematrix km inner join asutus on asutus.id = km.asutusId;
		where km.rekvid = trekv;
		and kuu >= tKuu1;
		and kuu <= tkuu2;
		and konto like tkonto;	
		and asutus.nimetus like tasutus;
	into cursor sqlresult
	
endif
if lnalgkuu >= tkuu1 AND tkuu2 > tkuu1
		select asutusid, asutus, rekvid, kuu, aasta, konto, deebet as deebet, kreedit as kreedit from 
			(select asutusId, asutus.nimetus as asutus, saldo1.rekvid, datepart(month,period) as kuu, datepart (year, period) as aasta, konto, dbkaibed as deebet, krkaibed as kreedit 
				from saldo1 inner join asutus on asutus.id = saldo1.asutusId
				where datepart(month,period) >= @kuu1 and datepart (year, period) = @aasta and datepart (month, period) <= @algkuu
			union 			
			select curkaibed.asutusId1 as asutusId, asutus.nimetus as asutus, curkaibed.rekvid1 as rekvid, curkaibed.kuu1 as kuu, curKaibed.aasta1 as aasta,
				curkaibed.konto1 as konto, curKaibed.deebet, curKaibed.kreedit from curAsutuskaibed curkaibed inner join asutus on asutus.id = curKaibed.asutusId1
				where rekvid1 = @rekv 
				and kuu1 >= @Algkuu + 1
				and kuu1 <= @kuu2
				and aasta1 = @aasta
			union
			select asutusId, asutus.nimetus as asutus, km.rekvid, km.kuu, @aasta as aasta, km.konto, 0 as deebet, 0 as kreedit
				from subkontodematrix km inner join asutus on asutus.id = km.asutusid
				where km.rekvid = @rekv
				and kuu >= @Kuu1
				and kuu <= @kuu2 ) tmpSaldo
		WHERE konto like @konto
		and  asutus like @asutus

endif

if @algkuu >= @kuu1 AND @kuu2 = @kuu1
	begin
		select asutusid, asutus, rekvid, kuu, aasta, konto, sum(deebet) as deebet, sum(kreedit) as kreedit from 
			(select curkaibed.asutusId1 as asutusId, asutus.nimetus as asutus, curkaibed.rekvid1 as rekvid, curkaibed.kuu1 as kuu, curKaibed.aasta1 as aasta,
				curkaibed.konto1 as konto, curKaibed.deebet, curKaibed.kreedit from curAsutuskaibed curkaibed inner join asutus on asutus.id = curKaibed.asutusId1
				where rekvid1 = @rekv 
				and kuu1 >= @kuu1
				and kuu1 <= @kuu2
				and aasta1 = @aasta
			union
			select asutusId, asutus.nimetus as asutus, km.rekvid, km.kuu, @aasta as aasta, km.konto, 0 as deebet, 0 as kreedit
				from subkontodematrix km inner join asutus on asutus.id = km.asutusid
				where km.rekvid = @rekv
				and kuu >= @Kuu1
				and kuu <= @kuu2 ) tmpSaldo
		WHERE konto like @konto
		and  asutus like @asutus
		group by asutusId, asutus, rekvid, kuu, aasta, konto

	end
