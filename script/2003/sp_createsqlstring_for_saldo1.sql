CREATE OR REPLACE FUNCTION sp_createsqlstring_for_saldo1(integer,integer,date,date,bpchar,integer) returns bpchar as '
declare
	tnrekvid alias for $1;
	tnOpt alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tcKonto alias for $5;
	tnAsutusId alias for $6;
	lcString bpchar; 
	lnAlgKuu int4; 
	lnAasta int4;
	lcKpv1 varchar;
	lcKpv2 varchar;
begin
/*
	lcString:= space(1);
	tnAsutusId := ifnull(tnAsutusId,0);
	Select Top 1 aasta , kuu into lnAasta, lnAlgkuu From aasta Where kinni = 1 Order By kinni Desc, aasta Desc, kuu Desc;
	If not found then 
		Select Top 1 aasta, 1 into lnAasta, lnAlgkuu From aasta Order By aasta Asc, kuu Asc;
	End if;
	
	IF EMPTY(tdKpv1) OR tdKpv1 <= DATE(lnAasta, lnAlgKuu,1) AND tnOpt = 1 then
		if tnAsutusId = 0 then
			lcString := ''Select kontoinf.rekvid, Library.kood As konto, 
				case when kontoinf.algsaldo >= 0 then kontoinf.algsaldo, 0::numeric(12,4) end As deebet,
				case when kontoinf.algsaldo < 0 then -1 * kontoinf.algsaldo, 0::numeric(12,4) end As kreedit 
				from Library INNER Join kontoinf On Library.Id = kontoinf.parentId 
				where kontoinf.rekvid = ''+tnRekvid::varchar + '' And kood Like ''+tckonto+'';
		else
			lcString := ''Select subkonto.rekvid, Library.kood As konto,
				case when subkonto.algsaldo >= 0 then subkonto.algsaldo, 0::numeric(12,4) end As deebet,
				case when subkonto.algsaldo < 0 then -1 * subkonto.algsaldo, 0::numeric(12,4) end As kreedit 
				from Library INNER Join subkonto On Library.Id = subkonto.KontoId 
				where subkonto.rekvid = ''+tnRekvid::varchar + '' And kood Like ''+tckonto+''
				and subkonto.asutusId = ''+tnAsutusId::varchar ;
		end if;			
	end if;
	IF lnAlgKuu > 0 then
		lcString := lcString + case when not EMPTY(lcString) then '' union all '' else space(1) end +
			'' Select rekvid, konto, dbkaibed As deebet, krkaibed As kreedit 
			 from saldo Where konto Like ''+tckonto +'' And rekvid = ''+tnRekvid::varchar +
			'' and aasta::char(4)+kuu::char(2) < ''+lnAasta::char(4)+lnAlgkuu::char(2);
		IF tnAsutusId > 0 then
			lcString := lcString + '' and asutusId = ''+tnAsutusId::varchar;
		END IF;
	end if; 
	IF tnOpt = 2 then
		-- kaibed
		lcKpv1 := ''date (''+year (tdKpv1)::char(4)+'',''+month(tdKpv1)::char(2)+'',''+day(tdKpv1)::char(2)+'')'';
	else
		-- algsaldo
		lcKpv1 := ''date('' + lnAasta::char(4)+'',''+lnAlgKuu::char(2)+'',1)'';		
	end if;
	lcKpv2 := ''date (''+year (tdKpv2)::char(4)+'',''+month(tdKpv2)::char(2)+'',''+day(tdKpv2)::char(2)+'')'';
	lcString := lcString + case when not EMPTY(lcString) then '' union all '' then space(1) end +
		'' SELECT rekvid, deebet as konto, summa  as deebet,  0::numeric(12,4) as kreedit 
 		'' from curJournal_ where rekvId = ''+tnRekvid::varchar+ '' and deebet like ''+tcKonto+''+
 		'' and kpv >= ''+lcKpv1+ 
 		'' and kpv <= '' +lcKpv2+ '';
	IF tnAsutusId > 0 then
		lcString := lcString + '' and asutusId = ''+tnAsutusId::varchar;
	end if;
	lcString := lcString + case when not EMPTY(lcString) then '' union all '' else space(1) end +
		'' SELECT rekvid, kreedit as konto, 0::numeric(12,2) as deebet,  summa as kreedit 
 		 from curJournal where rekvId = ''+tnRekvid::varchar +'' and kreedit like ''+tcKonto+''
 		and kpv >= '' +lcKpv1 + ''
 		and kpv <= lcKpv2 + '';
	IF tnAsutusId > 0 then
		lcString := lcString + '' and asutusId = ''+tnAsutusId::numeric(12,2);
	end if;
	lcString = " SELECT rekvId, konto, sum(deebet) as deebet, sum(kreedit) as kreedit FROM "+lcCursor +;
		" ORDER BY rekvid, konto "+;
		" GROUP BY rekvid, konto "+;
		" INTO CURSOR sqlresult "
*/

	return lcString;
end;
'  LANGUAGE 'sql' VOLATILE;
