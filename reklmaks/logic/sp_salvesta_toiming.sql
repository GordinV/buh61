-- Function: sp_update_palk_jaak(date, date, int4, int4)

-- DROP FUNCTION sp_update_palk_jaak(date, date, int4, int4);
--muudetud 03/01/2004

CREATE OR REPLACE FUNCTION sp_update_palk_jaak(date, date, int4, int4)
  RETURNS int4 AS
'
declare
	tdKpv1 alias for $1;
	tdKpv2	alias for $2;
	tnRekvId alias for $3;
	tnlepingId alias for $4;
	v_palk_jaak palk_jaak%rowtype;
	v_tooleping record;
	lnKuu1 int4;
	lnKuu2	int4;
	lnAasta1 int4;
	lnAasta2 int4;	
	lnElatis numeric (12,4);
	lnTulubaas numeric(12,4);
	lnTookoht int;
	lnArv numeric (12,4);
	lnCount int;
	lnCount_2004 int;
	lnCount_2005 int;
	ng31 numeric (12,4);
	lng31 numeric (12,4);
	lng31_2004 numeric (12,4);
	lng31_2005 numeric (12,4);
	lnTuluArv numeric(12,4);
	lnArvJaak numeric(12,4);
begin

	lnkuu1 := month(tdKpv1); 
	lnkuu2 := month(tdKpv2);  
	lnAasta1 := year(tdKpv1);  
	lnAasta2 := year(tdKpv2);
	lnTookoht := 1; 

	select * into v_tooleping from tooleping where id = tnLepingId;
	
	lnTookoht := v_tooleping.pohikoht;
--	select pohikoht into lnTookoht from tooleping where id = tnLepingId;
--	select Tulubaas into lnTulubaas from palk_config where rekvid = tnRekvId;

-- muudetud 03/01/2004	
	if year (date()) <= 2004 then
		lnTulubaas := 1400;
	else
		lnTulubaas := 1700;
	end if;

	if lnTookoht = 0 then
		lnTulubaas := 0;
	end if;

	SELECT sum( Palk_oper.summa ) into v_palk_jaak.arvestatud 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE Palk_lib.liik = 1    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.arvestatud  := ifnull (v_palk_jaak.arvestatud ,0);

	SELECT sum( Palk_oper.summa ) into v_palk_jaak.kinni 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE (Palk_lib.liik = 2    or palk_lib.liik = 8 or palk_lib.liik = 6 or (palk_lib.liik = 7 and palk_lib.asutusest = 0))
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.kinni := ifnull (v_palk_jaak.kinni,0);

	SELECT sum( Palk_oper.summa ) into v_palk_jaak.tki
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 0
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tki := ifnull (v_palk_jaak.tki,0);

	SELECT sum( Palk_oper.summa ) into v_palk_jaak.tka
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 1
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tka := ifnull (v_palk_jaak.tka,0);

	SELECT  sum( Palk_oper.summa ) into v_palk_jaak.pm
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE  palk_lib.liik = 8
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.pm := ifnull (v_palk_jaak.pm,0);

	SELECT  sum( Palk_oper.summa ) into v_palk_jaak.tulumaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE Palk_lib.liik = 4    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tulumaks := ifnull (v_palk_jaak.Tulumaks,0);

	SELECT  sum( Palk_oper.summa ) into v_palk_jaak.sotsmaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	WHERE Palk_lib.liik = 5
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.Sotsmaks := ifnull (v_palk_jaak.Sotsmaks,0);

	select id into v_palk_jaak.id from palk_jaak 
	where lepingId = tnlepingId 
	and kuu = lnkuu1
	and aasta = lnaasta1;

	v_palk_jaak.id := ifnull(v_palk_jaak.id,0);


	if not found then
		v_palk_jaak.id := 0;
	end if;
	        select sum(palk_oper.summa) into lnElatis from palk_oper where libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.elatis = 1 AND p.liik = 2) 
		AND Palk_oper.kpv >= tdKpv1   
		AND Palk_oper.kpv <= tdKpv2
		AND Palk_oper.rekvId = tnRekvId
		AND palk_oper.lepingId	= tnLepingId;

        select sum(o.summa) into lnArv 
		from palk_oper o inner join palk_kaart  k on o.lepingid = k.lepingid and k.libId = o.libId
		where o.libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.liik = 1) 
		and k.tulumaks = 1
		AND o.kpv >= tdKpv1   
		AND o.kpv <= tdKpv2
		AND o.rekvId = tnRekvId
		AND o.lepingId	= tnLepingId;

	v_palk_jaak.g31 := lnArv - v_palk_jaak.tki - v_palk_jaak.pm;

-- muudetud 03/01/2005

	if v_palk_jaak.g31 > lnTulubaas then
		v_palk_jaak.g31 := lnTulubaas;
	end if;
	
	if v_tooleping.pohikoht > 0 then
		select sum(palk_jaak.g31) into lng31_2004 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and aasta = 2004 
			and kuu < lnKuu1;

		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and aasta >= 2005
			and kuu < lnKuu1;

--	raise notice \'lng31 %\',lng31;

	select count(*) into lnCount_2004 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1
			and aasta = 2004 
			and date(aasta,kuu,1) >= v_tooleping.algab;
			
	select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1
			and aasta >= 2005 
			and date(aasta,kuu,1) >= v_tooleping.algab;

--		raise notice \'lnCount %\',lnCount;

		-- should be 1400 * periods
		ng31 := 1400 * lnCount_2004 + 1700 * lnCount_2005 ;
--		raise notice \'lnKuu1 %\',lnKuu1;
--		raise notice \'ng31 %\',ng31;
--		raise notice \'lng31 %\',lng31;

		lnArvJaak := v_palk_jaak.arvestatud - v_palk_jaak.pm - v_palk_jaak.tki;
		if lnArvJaak < lnTulubaas  then
			lnTulubaas := lnArvJaak;
			raise notice \'less then vaja %\',lnTulubaas;
		else

			if ng31 > lng31 and (lnCount_2004 +lnCount_2005) > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - (lng31_2004+lng31_2005));
				raise notice \'with reserv  %\',lnTulubaas;
			end if;
--			raise notice \'with reserv after %\',lnTulubaas;
--			raise notice \'limited lnArvJaak%\',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
		
			end if;

		end if;
	else
		lnTulubaas:= 0;
	end if;

--raise notice \'lnTulubaas %\',lnTulubaas;		

if v_palk_jaak.id = 0 then

	insert into palk_jaak ( lepingId, kuu, aasta, arvestatud, kinni, tulumaks, sotsmaks, tka, tki, pm, g31)
		values (tnlepingId, lnkuu1, lnaasta1, v_palk_jaak.arvestatud, v_palk_jaak.kinni, 
		v_palk_jaak.tulumaks, v_palk_jaak.sotsmaks, v_palk_jaak.tka, v_palk_jaak.tki, v_palk_jaak.pm, ifnull(lnTulubaas,0));
else
--raise notice \'v_palk_jaak.id %\',v_palk_jaak.id;
	update palk_jaak set 
		arvestatud = v_palk_jaak.arvestatud,
		kinni = v_palk_jaak.kinni,
		tka = v_palk_jaak.tka,
		tki = v_palk_jaak.tki,
		pm = v_palk_jaak.pm,
		tulumaks = v_palk_jaak.tulumaks,
		sotsmaks = v_palk_jaak.sotsmaks,
		g31 = ifnull(lnTulubaas,0)
		where id = v_palk_jaak.id;
end if;

 return sp_calc_palk_jaak (lnKuu1, lnaasta1, tnlepingId);

end; 
'
  LANGUAGE 'plpgsql' VOLATILE;

GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, int4, int4) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, int4, int4) TO GROUP dbpeakasutaja;
