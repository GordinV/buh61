-- Function: sp_calc_min_sots(integer, date)

-- DROP FUNCTION sp_calc_min_sots(integer, date);

CREATE OR REPLACE FUNCTION sp_calc_min_sots(integer, date)
  RETURNS numeric[] AS
$BODY$
declare
	tnLepingid alias for $1;
	tdKpv alias for $2;
	lnSumma numeric (12,4) = 0;
	lnKuurs numeric (14,4) = fnc_currentkuurs(tdKpv);
	l_last_paev date = (date(year(tdKpv), month(tdKpv),1) + interval '1 month')::date  - 1;
	l_return_value numeric[];	
	v_arvestus record;
	v_tooleping record;
	v_puhkus record;
	v_po record;
	lopp_kpv date;
	l_paevad integer = 30;
	l_min_sots numeric (14,4);
	l_korr_sm numeric (14,4);
	l_korr_summa numeric (14,4);
	l_enne_arvestatud_min_sotsmaks numeric(12,4) = 0;
begin
	select * into v_tooleping from tooleping where id = tnLepingid;
	lopp_kpv = (select max(coalesce(lopp, date(2099,12,31))) from tooleping where parentid = v_tooleping.parentid and rekvid = v_tooleping.rekvid);
	-- ei arvestame, kui see ei ole pohi koht 

/*
	if v_tooleping.pohikoht = 0 then
		raise notice 'Ei ole pohi tookoht';
		return null;
	end if; 
*/
	-- voi sotsmsks min palgast ei arvestatakse (palk_kaart)

	if (select count(pk.id) 
		from palk_kaart pk 
		inner join palk_lib pl on pl.parentid = pk.libId
		where pk.lepingid in (select id from tooleping where parentid = v_tooleping.parentid and pohikoht = 1) 
		and pl.liik = 5
		and status = 1
		and coalesce(pk.minsots,0) = 1) = 0 then

		raise notice 'Ei arvestame sots.maks min.palgast';
		return null;

	end if;	
-- puhkusepaevad arvestame
	select sum(sp_puudumise_paevad(tdKpv::date, tooleping.id))::numeric as puhkuse_paevad into v_puhkus 
		from tooleping 
		where tooleping.parentid = v_tooleping.parentid and tooleping.rekvid = v_tooleping.rekvid and pohikoht = 1;

-- palgaoperatsioonid		

	select sum(po.summa) as summa, 
		sum(case when pl.liik = 1 and po_kood.kood ilike '%PUHKUS%' then po.summa else 0 end) as puhkused,
		sum(case when pl.liik = 1 and po_kood.kood ilike '%HAIGUS%' then po.summa else 0 end) as haigused,
		sum(case when pl.liik = 1 and po_kood.kood ilike '%PUHKUS%' then po.sotsmaks else 0 end) as sm_puhkused,
		sum(case when pl.liik = 1 and po_kood.kood ilike '%HAIGUS%' then po.sotsmaks else 0 end) as sm_haigused,
		sum(po.sotsmaks) as sm into v_po
		from palk_oper po 
		inner join palk_lib pl on po.libid = pl.parentid
		inner join library po_kood on po_kood.id = pl.parentid and pl.liik = 1
		inner join palk_kaart pk on pk.libid = po.libid and pk.lepingid = po.lepingid
		inner join library l on l.kood = pl.tululiik and l.library = 'MAKSUKOOD' and coalesce(l.tun2,0) = 1
		where po.lepingid in (select id from tooleping where parentid = v_tooleping.parentid and tooleping.rekvid = v_tooleping.rekvid)  
		and month(kpv) = month(tdKpv) and year(kpv) = year(tdKpv) 
		and period is null;

	SELECT  coalesce(v_po.summa,0) as summa, coalesce(v_po.puhkused,0) as puhkused, coalesce(v_po.haigused,0) as haigused, coalesce(v_po.sm,0) as sm,
		coalesce(v_po.sm_puhkused,0) as sm_puhkused, coalesce(v_po.sm_haigused,0) as sm_haigused,
		coalesce(v_puhkus.puhkuse_paevad, 0) as puhkused_paevad,
		lopp_kpv as lopp,	 	
		(pc.minpalk  * pc.sm / 100) as minsots,  pc.minpalk, day(gomonth(date(year(tdKpv), month(tdKpv), 1),1) - 1) - coalesce(v_puhkus.puhkuse_paevad,0) as paevad
			into v_arvestus
		from palk_config pc 
		where pc.rekvid = v_tooleping.rekvid; 


	l_paevad = (case when coalesce(v_puhkus.puhkuse_paevad, 0) = 0 then 30 else  v_arvestus.paevad end);
	
	if l_paevad < 0 then 
		l_paevad = 0;
	end if;

	l_min_sots = v_arvestus.minsots / 30 * l_paevad; 

	raise notice ' l_min_sots % l_paevad % v_arvestus.paevad %', l_min_sots, l_paevad, v_arvestus.paevad;

	l_korr_sm = v_arvestus.sm - (v_arvestus.sm_puhkused + v_arvestus.sm_haigused);
	l_korr_summa = v_arvestus.summa - (v_arvestus.puhkused + v_arvestus.haigused);


	if (l_min_sots - l_korr_sm) > 0 then		
		l_return_value = ARRAY[l_min_sots - l_korr_sm, v_arvestus.minpalk / 30 * l_paevad - l_korr_summa];
	end if;

Return l_return_value;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_min_sots(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_min_sots(integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_min_sots(integer, date) TO vlad;
