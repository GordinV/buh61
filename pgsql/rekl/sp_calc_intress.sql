CREATE OR REPLACE FUNCTION sp_calc_intress(integer, date)
  RETURNS smallint AS
$BODY$

declare 

	tnLubaId alias for $1;
	tdKpv alias for $2;
	v_dekl record;
	v_luba record;
	v_tasu record;
	lcMarkused text;
	lnpaev int;
	lnAlgSaldo numeric(12,4);
	lnIntress numeric(12,4);
	lnpaev1 int;
	lnpaev2 int;
	lnpaev3 int;
	lnpaev4 int;
	lnpaev5 int;
	lntasu int;
	lnSumma0 numeric(12,2);
	lnSumma1 numeric(12,2);
	lnSumma2 numeric(12,2);
	lnSumma3 numeric(12,2);
	lnSumma4 numeric(12,2);
	lnSumma5 numeric(12,2);
	lnSumma numeric(12,2);
	
	lnreaSumma numeric(12,2);
	ldLaekKpv date;
	lnLaekSumma numeric(18,4);
	
	lnResult int;
	lnDokProp int;
	lnJaak numeric(12,2);
	lnEurKuurs numeric(12,4);
	lcValuuta varchar(20);
	lnpaevKokku int;
	lcDeklNumber varchar(20);
	lcPeriod varchar(40);
	lcLubaPeriod varchar(40);

	l_intress_Id integer;
	l_kpv date;

begin
	select * into v_luba from luba where id = tnLubaId;
	lnSumma = 0;
	lcMarkused = space(1);
	lnDokProp = 934;
	lnresult =  0;

	lnEurKuurs = 1;
	lcValuuta = 'EUR';

	lnEurKuurs = fnc_currentkuurs(tdKpv);
	lcValuuta = fnc_currentvaluuta(tdKpv); 

	lnLaekSumma = 0;

	lcDeklNumber = ltrim(rtrim(v_luba.number))+'-';
	lcPeriod = ltrim(rtrim(str(day(v_luba.algkpv))))+'.'+ltrim(rtrim(str(month(v_luba.algkpv))))+'.'+ltrim(rtrim(str(year(v_luba.algkpv))))+'-'+
		ltrim(rtrim(str(day(tdKpv))))+'.'+ltrim(rtrim(str(month(tdKpv))))+'.'+ltrim(rtrim(str(year(tdKpv))));


	lcLubaPeriod = ltrim(rtrim(str(day(v_luba.algkpv))))+'.'+ltrim(rtrim(str(month(v_luba.algkpv))))+'.'+ltrim(rtrim(str(year(v_luba.algkpv))))+'-'+
		ltrim(rtrim(str(day(v_luba.loppKpv))))+'.'+ltrim(rtrim(str(month(v_luba.loppKpv))))+'.'+ltrim(rtrim(str(year(v_luba.loppKpv))));
	
-- otsime intressi maar
	select hind into lnIntress from nomenklatuur 
		where dok = 'REKL' and upper(kood) like 'INTRESS%' and rekvid = v_luba.rekvid 
		order by upper(kood) desc limit 1;
	lnIntress = ifnull(lnIntress * 0.01,0.0006);
	lcmarkused = 'Luba. number: ' + v_luba.number + 'intress:'+ lnIntress::varchar +'
	';

-- koostame deklaratsioonide nimekiri, kus on staatus < 3, tahtaeg < tdKpv and tyyp = 'DEKL'	
	for v_dekl in
		select toiming.*,ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs , ifnull(dokvaluuta1.valuuta,'EEK')::varchar(20) as valuuta
			from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24)
			where toiming.lubaid = tnLubaid 
			and toiming.tyyp in ('DEKL', 'ALGSALDO','PARANDUS') 
			and toiming.staatus <= 3 
			and not empty (toiming.saadetud) 
			and (toiming.tahtaeg + 1) < tdKpv
	loop
		lnJaak = fncDeklJaak(v_dekl.id);
		raise notice 'v_dekl.id %, lnJaak %',v_dekl.id, lnJaak;
		lnpaev = 0;
		lnSumma0 = 0;
		lnSumma1 = 0;
		lnSumma2 = 0;
		lnSumma3 = 0;
		lnSumma4 = 0;
		lnSumma5 = 0;
		lcMarkused = lcMarkused + ' dekl.nr.:'+ltrim(rtrim(str(v_dekl.number)))::varchar;

		raise notice 'arvestame viimane paev, default = tahtpaev ';
		-- arvestame viimane paev, default = tahtpaev
		select intressId into l_intress_Id 
			from viiviseinfo v
			inner join toiming t on t.id = v.intressId
			where dokid = v_dekl.id 
			and t.staatus > 0 
			order by t.kpv desc limit 1;

		if l_intress_Id is not null then
			-- parandame v_dekl.tahtaeg
			l_kpv = (select kpv from toiming where id = l_intress_Id and staatus > 0);
			if l_kpv is not null then
				v_dekl.tahtaeg  = l_kpv;
			end if;
			raise notice 'leitud vana intress l_intress_Id %,l_kpv % ', l_intress_Id, l_kpv;	
		end if;
		
		-- arvestame paevi arv
--		lcValuuta = v_dekl.valuuta;
		if v_dekl.staatus = 1 then
			raise notice 'staatus = 1, puudub tasumise info ';
			-- puudub tasumise info
			lnPaev = tdKpv - v_dekl.tahtaeg;
			raise notice ' lnPaev %', lnPaev;
/*
			-- parandame paevade arv

			select dokpaevad into lnPaevKokku from viiviseinfo where dokliik = 1 and dokid = v_dekl.id;
			lnPaevKokku = ifnull(lnPaevKokku,0);
			if lnPaevKokku > 0 then
				lnPaev = lnPaev - lnPaevKokku;
			end if;
			if lnPaev < 0 then
				lnPaev = 0;
			end if;
			raise notice 'lnPaevKokku %, lnPaev %', lnPaevKokku, lnPaev;
*/
			
			lnSumma1 = lnIntress * v_dekl.summa  * v_dekl.kuurs * lnPaev;
			lcmarkused = lcMarkused + ' tahtaeg '+ v_dekl.tahtaeg::varchar(10) + ' paevad:' + lnPaev::varchar +'Volg:'+ round(v_dekl.summa  * v_dekl.kuurs/lnEurKuurs,2)::varchar+ ' Intress:' + round(lnSumma1/lnEurKuurs,2)::varchar; 
			raise notice 'lnSumma1 %',lnSumma1;
			raise notice 'v_dekl.summa %',v_dekl.summa;
			raise notice 'lnIntress %',lnIntress;
			raise notice 'lnPaev %',lnPaev;
			raise notice 'Kuurs %',v_dekl.kuurs;

			-- salvestame arvestuse info
			insert into viiviseinfo (deklnumber, period,lubaperiod, rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
				dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
				(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod, lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(v_dekl.summa  * v_dekl.kuurs/lnEurKuurs,2), 
				lnPaev, lnIntress, round(lnSumma1/lnEurKuurs,2), null, 0);
				
		else
			raise notice 'staatus =  %',v_dekl.staatus;
			lntasu = 0;
			lnJaak = v_dekl.summa * v_dekl.kuurs;
			lcmarkused =  lcmarkused + ' tahtaeg '+ v_dekl.tahtaeg::varchar(10);
			raise notice 'tahtaeg  %',v_dekl.tahtaeg;

			for v_tasu in 
				select dekltasu.id, dekltasu.tasuid, dekltasu.summa, dekltasu.tasukpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
					from dekltasu left outer join dokvaluuta1 on (dekltasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 7)
					where dekltasu.deklId = v_dekl.id 
					order by dekltasu.tasukpv 
			loop
		
				raise notice 'tasu.id =  %',v_tasu.id;
				raise notice 'tasu valuuta =  %',v_tasu.kuurs;
				lntasu = lntasu + 1;
				-- paevad
				if lntasu = 1 then
					lnpaev1 = v_tasu.tasukpv - v_dekl.tahtaeg;
					if lnpaev1 > 0 then
						lnSumma1 = lnJaak * lnIntress * lnPaev1;
						lnJaak = lnJaak - v_tasu.summa * v_tasu.kuurs;
						lcmarkused =  lcMarkused + ' tasu kpv '+ v_tasu.tasukpv::varchar(10) + ' paevad:' + lnPaev1::varchar +'Volg: '+ round(lnJaak/lnEurKuurs,2)::varchar +' Intress:' + round(lnSumma1/lnEurKuurs,2)::varchar; 
					end if;
					ldLaekKpv = v_tasu.tasukpv;
					lnLaekSumma = v_tasu.summa;
					raise notice 'lnpaev1 =  %',lnpaev1;
					raise notice 'lnJaak1 =  %',lnJaak;
					
			-- salvestame arvestuse info
			insert into viiviseinfo (deklnumber, period, lubaperiod, rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
				dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
				(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod,lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(lnJaak/lnEurKuurs,2), 
				lnPaev1, lnIntress, round(lnSumma1/lnEurKuurs,2), ldLaekKpv, lnLaekSumma);


				elseif lntasu = 2 then
					lnpaev2 = v_tasu.tasukpv - v_dekl.tahtaeg;
					if lnpaev2 > 0 then
						lnSumma2 = (lnJaak - v_tasu.summa * v_tasu.kuurs) * lnIntress * lnPaev2;
						lnJaak = lnJaak - v_tasu.summa * v_tasu.kuurs;
						lcmarkused =  lcMarkused + ' tasu kpv '+ v_tasu.tasukpv::varchar(10) + ' paevad:' + lnPaev2::varchar + 'Volg: '+ round(lnJaak/lnEurKuurs,2)::varchar +' Intress:' + round(lnSumma2/lnEurKuurs,2)::varchar; 

						ldLaekKpv = v_tasu.tasukpv;
						lnLaekSumma = v_tasu.summa;

					raise notice 'lnpaev2 =  %',lnpaev2;
					raise notice 'lnSumma2 =  %',lnSumma2;
					raise notice 'lnJaak1 =  %',lnJaak;

					-- salvestame arvestuse info
					insert into viiviseinfo (DeklNumber, Period, LubaPeriod,  rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
						dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
						(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod,lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(lnJaak/lnEurKuurs,2), 
						lnPaev2, lnIntress, round(lnSumma2/lnEurKuurs,2), ldLaekKpv, lnLaekSumma);

					end if;
				elseif lntasu = 3 then
					lnpaev3 = v_tasu.tasukpv - v_dekl.tahtaeg;
					if lnpaev3 > 0 then
						lnSumma3 = (lnJaak - v_tasu.summa * v_tasu.kuurs) * lnIntress * lnPaev3;
						lnJaak = lnJaak - v_tasu.summa * v_tasu.kuurs;
						lcmarkused =  lcMarkused + ' tasu kpv '+ v_tasu.tasukpv::varchar(10) + ' paevad:' + lnPaev3::varchar + 'Volg: '+ round(lnJaak/lnEurKuurs,2)::varchar+' Intress:' + round(lnSumma3/lnEurKuurs,2)::varchar; 

						ldLaekKpv = v_tasu.tasukpv;
						lnLaekSumma = v_tasu.summa;
					-- salvestame arvestuse info
					insert into viiviseinfo (deklnumber, period,LubaPeriod, rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
						dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
						(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod,lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(lnJaak/lnEurKuurs,2), 
						lnPaev3, lnIntress, round(lnSumma3/lnEurKuurs,2), ldLaekKpv, lnLaekSumma);


					end if;
				elseif lntasu = 4 then
					lnpaev4 = v_tasu.tasukpv - v_dekl.tahtaeg;
					if lnpaev4 > 0 then
						lnSumma4 = (lnJaak - v_tasu.summa * v_tasu.kuurs) * lnIntress * lnPaev4;
						lnJaak = lnJaak - v_tasu.summa * v_tasu.kuurs;
						lcmarkused =  lcMarkused + ' tasu kpv '+ v_tasu.tasukpv::varchar(10) + ' paevad:' + lnPaev4::varchar + 'Volg: '+ round(lnJaak/lnEurKuurs,2)::varchar+ ' Intress:' + round(lnSumma4/lnEurKuurs,2)::varchar; 

						ldLaekKpv = v_tasu.tasukpv;
						lnLaekSumma = v_tasu.summa;

					-- salvestame arvestuse info
					insert into viiviseinfo (deklnumber, period, LubaPeriod, rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
						dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
						(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod, lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(lnJaak/lnEurKuurs,2), 
						lnPaev4, lnIntress, round(lnSumma4/lnEurKuurs,2), ldLaekKpv, lnLaekSumma);

					end if;
				else
					lnpaev5 = v_tasu.tasukpv - v_dekl.tahtaeg;
					if lnpaev5 > 0 then
						lnSumma5 = (lnJaak - v_tasu.summa * v_tasu.kuurs) * lnIntress * lnPaev5;
						lnJaak = lnJaak - v_tasu.summa * v_tasu.kuurs;
						lcmarkused =  lcMarkused + ' tasu kpv '+ v_tasu.tasukpv::varchar(10) + ' paevad:' + lnPaev5::varchar + 'Volg: '+ round(lnJaak/lnEurKuurs,2)::varchar+' Intress:' + round(lnSumma5/lnEurKuurs,2)::varchar; 

						ldLaekKpv = v_tasu.tasukpv;
						lnLaekSumma = v_tasu.summa;

					-- salvestame arvestuse info
					insert into viiviseinfo (deklnumber, period, LubaPeriod, rekvid, asutusId, intressId, dokid, dokliik, doktahtaeg, doksumma, dokvolg, 
						dokpaevad, intressimaar, muudsumma, laekkpv, laeksumma) VALUES 
						(lcDeklNumber+ltrim(rtrim(str(v_dekl.number))), lcPeriod, lcLubaPeriod, v_luba.rekvid, v_luba.parentid,0,v_dekl.id,1,v_dekl.tahtaeg, v_dekl.summa, round(lnJaak/lnEurKuurs,2), 
						lnPaev5, lnIntress, round(lnSumma5/lnEurKuurs,2), ldLaekKpv, lnLaekSumma);

					end if;
				end if;
				if lnjaak <= 0 then
					raise notice 'jaak = 0';
--					exit;
					
				end if;

			end loop;

		end if;
		if (lnSumma1+lnSumma2+lnSumma3 + lnSumma4 + lnSumma5) > 0 then
			-- intress suurem kui 0
			lnreaSumma = (lnSumma1+lnSumma2+lnSumma3 + lnSumma4 + lnSumma5);
			lnSumma = lnSumma + (lnSumma1+lnSumma2+lnSumma3 + lnSumma4 + lnSumma5);
		end if;
		-- salvestame viivise info
		--dokliik = 1 (dekl)
		lnpaevKokku = lnPaev;
		if lnPaev1 > 0 then
			lnpaevKokku = lnPaev1;
		end if;
		if lnPaev1 > 0 then
			lnpaevKokku = lnPaev1;
		end if;
		if lnPaev2 > 0 then
			lnpaevKokku = lnPaev2;
		end if;
		if lnPaev3 > 0 then
			lnpaevKokku = lnPaev3;
		end if;
		if lnPaev4 > 0 then
			lnpaevKokku = lnPaev4;
		end if;
		if lnPaev5 > 0 then
			lnpaevKokku = lnPaev5;
		end if;
		
		lnreaSumma = 0;
		lcmarkused = ltrim(rtrim(lcmarkused)) +'
	';
	end loop;
	
	if lnSumma > 0 and v_luba.parentid > 0 then
		raise notice 'lnEurKuurs %',lnEurKuurs;
		lnSumma = round(lnSumma / lnEurKuurs,2);
		lnresult =  sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, tdKpv, '', '', tdKpv, lnSumma, 0, 'INTRESS', lcmarkused, 0, lnDokProp,0,lcValuuta,lnEURKuurs);
		-- salvestame intressi doki infot
		update 	viiviseinfo set intressId = lnresult 
			where intressId = 0 and asutusid = v_luba.parentid 
			and dokliik = 1 and dokid in (select id from toiming where lubaid = v_luba.id);
	end if;

	Return lnresult;


end; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_intress(integer, date)
  OWNER TO vlad;
