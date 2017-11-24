--DROP FUNCTION if exists sp_update_palk_jaak(date, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_update_palk_jaak(tdKpv1 date, tdKpv2 date, tnRekvId integer, tnlepingId integer)
  RETURNS integer AS
$BODY$
declare

	v_palk_jaak palk_jaak%rowtype;
	v_tooleping record ;
	v_palk_config record;
	lnKuu1 integer = month(tdKpv1);
	lnKuu2	integer = month(tdKpv2);
	lnAasta1 integer = year(tdKpv1);
	lnAasta2 integer = year(tdKpv2);	
	lnElatis numeric (12,4);
	lnTulubaas numeric(12,4);
	lnTookoht integer = 1;
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
	lnTulumaar int;
	l_tulubaas_2015 numeric(14,2);
	lnTuludPm numeric (12,4);

	l_jaak numeric (12,4) = 0;
	l_eelmine_jaak numeric (12,4) = 0;
	l_eelmine_kuu integer = case when (lnKuu1 - 1) < 1 then 12 else lnKuu1 - 1 end;
	l_eelmine_aasta integer = case when l_eelmine_kuu = 12 then lnAasta1 - 1 else lnAasta1 end;
	
begin
	select * into v_tooleping from tooleping where id = tnLepingId;
	
	lnTookoht = v_tooleping.pohikoht;

	select palk_config.*, ifnull(dokvaluuta1.kuurs,1) as kuurs  into v_palk_config
		from palk_config 
		left outer join dokvaluuta1 on (palk_config.id =dokvaluuta1.dokid and  dokvaluuta1.dokliik = 26) where palk_config.rekvid = tnrekvId;

	lnTulubaas = coalesce(v_palk_config.Tulubaas * v_palk_config.kuurs,180);	

	if lnTookoht = 0 then
		lnTulubaas := 0;
	end if;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric),  
		sum( coalesce(Palk_oper.tulubaas,0) * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.arvestatud , v_palk_jaak.g31
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 1    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.arvestatud  = coalesce(v_palk_jaak.arvestatud ,0);
	-- kontrollime PM

	select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1  
		AND Palk_oper.kpv >= tdKpv1   
		AND Palk_oper.kpv <= tdKpv2
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		And Palk_oper.rekvid =  tnRekvId
		And palk_kaart.lepingid = tnLepingid;

	lnTuludPm = coalesce(lnTuludPm,0);	
	if lnTuludPm > 0 then
		raise notice 'tulud Pm III samba: %',lnTuludPm;
		v_palk_jaak.arvestatud = v_palk_jaak.arvestatud - lnTuludPm;
	end if;

	raise notice 'v_palk_jaak.arvestatud: %',v_palk_jaak.arvestatud;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.kinni 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE (Palk_lib.liik = 2    or palk_lib.liik = 8 or palk_lib.liik = 6 or (palk_lib.liik = 7 and palk_lib.asutusest = 0))
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.kinni = coalesce(v_palk_jaak.kinni,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tki
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 0
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tki = coalesce (v_palk_jaak.tki,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tka
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 1
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tka = coalesce(v_palk_jaak.tka,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.pm
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE  palk_lib.liik = 8
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.pm = coalesce(v_palk_jaak.pm,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.tulumaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 4    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tulumaks = coalesce(v_palk_jaak.Tulumaks,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.sotsmaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 5
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.Sotsmaks = coalesce(v_palk_jaak.Sotsmaks,0);

	delete from palk_jaak 
		where  lepingId = tnlepingId 
		and kuu = lnkuu1
		and aasta = lnaasta1;

	select sum(palk_oper.summa * coalesce(dokvaluuta1.kuurs,1)::numeric) into lnElatis 
			from palk_oper 
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where libId in 
			(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.elatis = 1 AND p.liik = 2) 
			AND Palk_oper.kpv >= tdKpv1   
			AND Palk_oper.kpv <= tdKpv2
			AND Palk_oper.rekvId = tnRekvId
			AND palk_oper.lepingId	= tnLepingId;

        select sum(o.summa * coalesce(dokvaluuta1.kuurs,1)::numeric) into lnArv 
		from palk_oper o inner join palk_kaart  k on o.lepingid = k.lepingid and k.libId = o.libId
		left outer join dokvaluuta1 on (o.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where o.libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.liik = 1) 
		and k.tulumaks = 1
		AND o.kpv >= tdKpv1   
		AND o.kpv <= tdKpv2
		AND o.rekvId = tnRekvId
		AND o.lepingId	= tnLepingId;



	raise notice 'v_palk_jaak.g31 %', v_palk_jaak.g31;
		
	-- calc saldo
	-- 1. prev. saldo

	select jaak into l_eelmine_jaak from palk_jaak where lepingId = tnlepingId and kuu = l_eelmine_kuu and aasta = l_eelmine_aasta;
	l_jaak  = coalesce(l_eelmine_jaak,0) + coalesce(v_palk_jaak.arvestatud,0) - coalesce(v_palk_jaak.kinni,0) - coalesce(v_palk_jaak.tulumaks,0); 

	insert into palk_jaak ( lepingId, kuu, aasta, arvestatud, kinni, tulumaks, sotsmaks, tka, tki, pm, g31, jaak)
		values (tnlepingId, lnkuu1, lnaasta1, v_palk_jaak.arvestatud, v_palk_jaak.kinni, 
		v_palk_jaak.tulumaks, v_palk_jaak.sotsmaks, v_palk_jaak.tka, v_palk_jaak.tki, v_palk_jaak.pm, coalesce(v_palk_jaak.g31,0), l_jaak) ;

 return 1;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbpeakasutaja;

/*
select sp_update_palk_jaak(date(2018,01,01), date(2018,01,31),3, 135731);


select * from asutus where regkood = '38311043714'

select * from tooleping where parentid = 34206


select * from palk_jaak where aasta = 2018 and lepingid = 140885

delete from palk_jaak where aasta = 2018 and lepingid = 140885

SELECT regkood, nimetus, aadress,  tel, kuu, aasta, id,  jaak, arvestatud, kinni,  tki, tka, pm, tulumaks, sotsmaks, muud, G31, osakondid 
	FROM  curPalkJaak Curpalkjaak


select * from palk_oper where lepingid = 140885 and year(kpv) = 2018
delete from palk_oper where id = 4856476
*/