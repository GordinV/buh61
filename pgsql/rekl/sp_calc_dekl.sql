-- Function: sp_calc_dekl(integer)
/*
select gomonth(date(),1)
select * from toiming
*/
-- DROP FUNCTION sp_calc_dekl(integer);

CREATE OR REPLACE FUNCTION sp_calc_dekl(integer)
  RETURNS smallint AS
$BODY$

declare 

	tnId alias for $1;
	v_luba record;

	lnPeriod int;
	lnKord int;
	ldKpv date;
	ldAlgKpv date;
	ldLoppKpv date;
	ldtahtaeg date;
	lnSamm int;
	lnDokProp int;
	lnToimingId int;
	lnLen int;
	lnTPkord int;
	lnSumma numeric;
begin
	select luba.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_luba 
		from luba left outer join dokvaluuta1 on (dokvaluuta1.dokid = luba.id and dokvaluuta1.dokliik = 23) where luba.id = tnId;
	lnKord = 0;
	-- dok liik
	select dokprop.id into lnDokProp from library inner join dokprop on library.id = dokprop.parentid 
		where library.kood = 'DEKL' and library.library = 'DOK' and rekvid = v_luba.rekvid order by id desc limit 1; 
	lnDokProp = ifnull(lnDokProp,0);


	if v_luba.staatus = 0 then
		raise exception 'Luba anulleritud';
		return 0;
	end if;

	-- kustatme vana dekl

	delete from toiming where lubaid = v_luba.id and empty(saadetud) and staatus = 1 and tyyp = 'DEKL'; 

	ldAlgKpv = date(year(v_luba.algkpv), 1,1);
	ldLoppKpv = date(year(v_luba.algkpv), 12,31);
--	ldLoppKpv = date(year(v_luba.loppkpv), 12,31);

	if v_luba.kord = 'PAEV' then
		lnPeriod = ldLoppKpv - ldAlgKpv;
		lnKord = 1 ;
	elseif v_luba.kord = 'NADAL' then
		lnPeriod = ceil((ldLoppKpv - ldAlgKpv ) / 7);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 7) ;
	elseif v_luba.kord = 'KUU' then
		lnPeriod = ceil(month(ldLoppKpv) - month(ldAlgKpv) + 1);
		lnKord = month(v_luba.algkpv) - month(ldAlgKpv) ;
	elseif v_luba.kord = 'KVARTAL' then
		lnPeriod = floor((month(ldLoppKpv) - month(ldAlgKpv) + 1) / 3);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 90) ;
	elseif v_luba.kord = 'AASTA' then
		lnPeriod = 1;
		lnKord = 1;
		if v_luba.loppkpv > ldLoppKpv then
			-- teine aasta
			lnPeriod = year(v_luba.loppkpv) - year(v_luba.algkpv) + 1;
			lnKord = 0;
			ldLoppKpv = v_luba.loppkpv;
		end if;

	else
		lnPeriod = floor((month(ldLoppKpv) - month(ldAlgKpv) + 1) / 3);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 90) ;
	end if;
	if ldLoppKpv < v_luba.loppkpv then
		ldLoppKpv = v_luba.loppkpv;
	end if;
		raise notice 'LnPeriod: %',lnPeriod;
		raise notice 'ldalgkpv: %',ldalgkpv;
		raise notice 'ldloppkpv: %',ldloppkpv;

--	lnKord = 0;
	loop
		if empty(ldKpv) then
			-- esimine
			ldKpv = v_luba.algkpv;	
		end if;

		raise notice 'LnPeriod: %',lnPeriod;
		raise notice 'LnKord: %',lnKord;

		ldtahtaeg = ldKpv;
		if ldKpv > ldloppkpv then
			raise notice 'Exit: %',ldKpv;
			exit;
		end if;
		loop
			if sp_ifworkday(ldtahtaeg,v_luba.rekvid) = 1 then
				raise notice 'Exit sp_ifworkday';
				exit;
			end if;
			ldtahtaeg = ldtahtaeg + 1;
			lnTPkord = lnTPkord + 1;
			if lnTPkord > 5 then
				exit;
			end if;

		end loop;
		lnSumma = sp_calc_deklsumma(v_luba.id, ldKpv);
		if lnSumma = 0 then
			exit;
		end if;
		lnSumma = round(lnSumma / v_luba.kuurs,2);


		-- parandus 
		ldtahtaeg = DATE(YEAR(gomonth(ldKpv,1)),month(gomonth(ldKpv,1)),10);

		
		lnToimingId = sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, ldKpv, space(1),space(1), ldtahtaeg, lnsumma, 1, 'DEKL', space(1), 0, lnDokProp,lnKord, v_luba.valuuta, v_luba.kuurs);

		raise notice 'id: %',lnToimingId; 

		lnKord = lnKord + 1;
		if lnKord >= lnPeriod then
			raise notice 'exit period';
			exit;
		end if;

		lnLen = len(v_luba.kord);

--		raise notice 'v_luba.kord: %',v_luba.kord;
--		raise notice 'lnLen: %',lnlen;



		if v_luba.kord = 'PAEV' then
			raise notice 'PAEV';
			ldKpv = ldKpv + 1;
		end if;
		if v_luba.kord = 'NADAL' then
			raise notice 'NADAL';
			ldKpv = ldKpv + 7;
		end if;
		if v_luba.kord = 'KUU' then
			raise notice 'KUU';
			ldKpv = gomonth(ldKpv,1);
		end if;
		if v_luba.kord = 'KVARTAL' then
			raise notice 'KVARTAL';
			if month(ldKpv) < 4 then
				-- 1 kvartal
				ldKpv = date(year(ldKpv),04,01);
			elseif month(ldKpv) > 3 and month(ldKpv) < 7 then
				-- 2 kvartal
				ldKpv = date(year(ldKpv),07,01);
			elseif month(ldKpv) > 6 and month(ldKpv) < 10 then
				-- 3 kvartal
				ldKpv = date(year(ldKpv),10,01);
			else
				-- 4 kvartal
				ldKpv = date(year(ldKpv)+1,01,01);
			end if;
			-- toopaevi kontrol
			lnTPkord = 0;
			loop
				if sp_ifworkday(ldKpv,v_luba.rekvid) = 1 then
					exit;
				end if;
				ldKpv = ldKpv + 1;
				lnTPkord = lnTPkord + 1;
				if lnTPkord > 5 then
					exit;
				end if;
			end loop;


--			ldKpv = gomonth(ldKpv,3);
		end if;

		if v_luba.kord = 'PAEV' then
			exit;
		end if;
		if v_luba.kord = 'AASTA' then
			raise notice 'AASTA';
			ldKpv = gomonth(ldKpv,12);
			if year(v_luba.loppkpv) = year(ldKpv) and v_luba.loppkpv < ldKpv then
				ldKpv = v_luba.loppkpv;
			end if;

		end if;
		raise notice 'ldKpv: %',ldKpv;
	end loop;
	-- delete dekl where kpv > luba.loppkpv
	delete from toiming where lubaid = v_luba.id and kpv > v_luba.loppkpv and tyyp = 'DEKL';
	Return 1;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_dekl(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_dekl(integer) TO dbpeakasutaja;
