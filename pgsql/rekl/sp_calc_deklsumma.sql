-- Function: sp_calc_deklsumma(integer, date)

-- DROP FUNCTION sp_calc_deklsumma(integer, date);

CREATE OR REPLACE FUNCTION sp_calc_deklsumma(integer, date)
  RETURNS numeric AS
$BODY$

declare 

	tnId alias for $1;
	tdKpv alias for $2;
	v_luba record;

	lnPeriod int;
	lnKord int;
	ldKpv date;
	ldAlgKpv date;
	ldLoppKpv date;
	lnTPkord int;

	lnSumma numeric;
	lnPaevad int;
begin
	lnSumma = 0;
	select luba.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_luba 
		from luba left outer join dokvaluuta1 on (dokvaluuta1.dokid = luba.id and dokvaluuta1.dokliik = 23) where luba.id = tnId;

	if tdKpv >= v_luba.algkpv  and tdKpv <= v_luba.loppkpv   then
		lnSumma = v_luba.summa* v_luba.kuurs;
	else
		raise notice 'Vigane period %',tdKpv; 
	end if;
		raise notice 'Kuu %',v_luba.kord;

	if v_luba.kord = 'PAEV' then
		lnSumma = v_luba.summa * v_luba.kuurs;
		return lnSumma;	
	end if;
	if lnSumma > 0 then
		if v_luba.kord = 'NADAL' then
			raise notice 'nadal';
			-- diff >= 7
			-- OTSIME alg kpv 
			lnpaevad = tdKpv - v_luba.algkpv+1;
			ldAlgKpv = v_luba.algkpv + (floor(lnpaevad / 7)) * 7;
			lnSumma = (lnSumma / 7) * (tdKpv - ldAlgKpv);

		elseif ltrim(rtrim(v_luba.kord)) = 'KUU' then
		-- OTSIME alg kpv 
			raise notice 'Kuu';
			ldAlgKpv = date(year(v_luba.algkpv),month(v_luba.algkpv),1);
			ldLoppKpv = gomonth(ldAlgKpv, 1)-1;

			if v_luba.algkpv > ldAlgKpv and month(tdKpv) = month(v_luba.algkpv) and year(tdKpv) = year(v_luba.algkpv) then
				-- esimine kuu
				lnSumma = (lnSumma / 30) * (v_luba.algkpv - ldAlgKpv );
			elseif month(tdKpv) = month( v_luba.loppkpv) and year(tdKpv) = year(v_luba.loppkpv) then
				-- viimane kuu
				ldAlgKpv = date(year(v_luba.loppkpv),month(v_luba.loppkpv),1);
				lnpaevad = (v_luba.loppkpv - ldAlgKpv );
				raise notice 'ldAlgKpv %',ldAlgKpv;
				raise notice 'lnpaevad %',lnpaevad;
				if lnPaevad > 30 then
					lnPaevad = 30;
				end if;
			
				lnSumma = (lnSumma / 30) * lnPaevad ;
			end if; --alg lopp kpv
--		end if; -- kord
		elseif ltrim(rtrim(v_luba.kord)) = 'KVARTAL' then
		-- OTSIME alg kpv 
			raise notice 'Kvartal';

		-- kvartal number
			if (tdKpv - v_luba.algkpv) < 90 or (v_luba.loppkpv - tdKpv) < 90 then
				raise notice 'MEIE PERIOD';

				if month(tdKpv) < 4 then 
					ldAlgKpv = date(year(tdkpv),1,1);
					ldLoppKpv = date(year(tdkpv),3,31);
				elseif month(tdKpv) > 3 and month(tdKpv) < 7 then
					ldAlgKpv = date(year(tdkpv),4,1);
					ldLoppKpv = date(year(tdkpv),6,30);
				elseif month(tdKpv) > 6 and month(tdKpv) < 10 then
					ldAlgKpv = date(year(tdkpv),7,1);
					ldLoppKpv = date(year(tdkpv),9,30);
				else
					ldAlgKpv = date(year(tdkpv),10,1);
					ldLoppKpv = date(year(tdkpv),12,31);
				end if;
				raise notice 'ldalgkpv  %',ldalgkpv;
				raise notice 'ldLoppkpv  %',ldLoppkpv;
			if v_luba.loppkpv <= ldLoppKpv and  v_luba.algkpv >= ldAlgKpv then
					raise notice 'vaike period';
					lnSumma = (lnSumma / 90) * (v_luba.loppkpv - v_luba.algkpv + 1);
				elseif v_luba.algkpv > ldAlgKpv and ldLoppKpv < v_luba.loppkpv then
					-- esimine kvartal
					raise notice 'esimine';
					lnSumma = (lnSumma / 90) * (ldLoppKpv - v_luba.algkpv +1);
				elseif v_luba.loppkpv < ldLoppKpv and v_luba.algkpv < ldAlgKpv then
					-- viimane kvartal
					raise notice 'viimane';
					lnSumma = (lnSumma / 90) * (v_luba.loppkpv-ldAlgKpv + 1);
				end if; --alg lopp kpv
			end if; -- kvartal
		elseif ltrim(rtrim(v_luba.kord)) = 'AASTA' then
		-- OTSIME alg kpv 
			raise notice 'Aasta';

			ldAlgKpv = date(year(tdkpv),1,1);
			ldLoppKpv = date(year(tdkpv),12,31);
--			if year(v_luba.kpv) = year(tdKpv) and v_luba.loppkpv < tdKpv then
--				ldLoppKpv = v_luba.loppkpv;
--			end if;


			raise notice 'ldalgkpv  %',ldalgkpv;
			raise notice 'ldLoppkpv  %',ldLoppkpv;

			IF ldAlgKpv <> v_luba.algkpv or ldLoppKpv <> v_luba.loppkpv then
				if v_luba.loppkpv <= ldLoppKpv and  v_luba.algkpv >= ldAlgKpv then
					raise notice 'vaike period';
					lnSumma = (lnSumma / 360) * (v_luba.loppkpv - v_luba.algkpv);
				elseif v_luba.algkpv > ldAlgKpv and ldLoppKpv <= v_luba.loppkpv then
					-- esimine aasta
					raise notice 'esimine';
					lnSumma = (lnSumma / 360) * (ldLoppKpv - v_luba.algkpv);
				elseif v_luba.loppkpv < ldLoppKpv and v_luba.algkpv <= ldAlgKpv then
					-- viimane aasta
					raise notice 'viimane';
					lnSumma = (lnSumma / 360) * (v_luba.loppkpv-ldAlgKpv);
				end if; --alg lopp kpv
			end if; --aasta
		end if; -- kord
	end if; -- summa

	Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_deklsumma(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_deklsumma(integer, date) TO dbpeakasutaja;
