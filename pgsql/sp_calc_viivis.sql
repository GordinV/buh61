-- Function: sp_calc_viivis(integer, integer, date, integer)

-- DROP FUNCTION sp_calc_viivis(integer, integer, date, integer);

CREATE OR REPLACE FUNCTION sp_calc_viivis(integer, integer, date, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tnAsutusId alias for $2;
	tdKpv alias for $3;
	tnKoikArved alias for $4;
	
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;
	lnCount int;
	lnCountV int;
	qryArved record;
	qryTasud record;
	lnAlgsaldo numeric (14,4);
	lnVolg numeric (14,4);
	lcKonto varchar;
	ldKpv date;
	ldKpvViimane date;
	lnPaevad int;
	lnVolgKokku numeric(14,2);
	lnPaevadInString integer;
	lnPaevadInStringLopp integer; 
	lcArveString varchar;
	lnJaak numeric(14,2);

	

begin

lnJaak = 999999999.99;

	select count(*) into lnCount from pg_class where relname = 'tmp_viivis';

	if lnCount = 0 then
		CREATE TABLE tmp_viivis (  dkpv date DEFAULT date(), Timestamp varchar(20),  id int4, rekvid int4,  asutusid int4,  konto varchar(20),
		  algjaak numeric(14,4), algkpv date,  arvnumber varchar(20), tahtaeg date, summa numeric(14,4), 
		  tasud1 date,  tasun1 numeric(14,4) default 0,  paev1 int4 default 0,  volg1 numeric(14,4) default 0,  
		  tasud2 date,  tasun2 numeric(14,4) default 0,  paev2 int4 default 0,  volg2 numeric(14,4) default 0, 
		  tasud3 date,  tasun3 numeric(14,4) default 0,  paev3 int4 default 0,   volg3 numeric(14,4) default 0,   
		  tasud4 date,   tasun4 numeric(14,4) default 0,   paev4 int4 default 0,  volg4 numeric(14,4) default 0,
		  tasud5 date,   tasun5 numeric(14,4) default 0,  paev5 int4 default 0,  volg5 numeric(14,4) default 0,  
		  tasud6 date,  tasun6 numeric(14,4) default 0,  paev6 int4 default 0,  volg6 numeric(14,4) default 0
		) WITH OIDS;

		GRANT ALL ON TABLE public.toograf TO vlad WITH GRANT OPTION;
		GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.toograf TO GROUP dbpeakasutaja;
		GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.toograf TO GROUP dbkasutaja;
		GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.toograf TO GROUP dbadmin;
		GRANT SELECT ON TABLE public.toograf TO GROUP dbvaatleja;


	end if;
	
	delete from tmp_viivis where dkpv < date() and rekvid = tnrekvId;

	lcreturn := to_char(now(), 'YYYYMMDDMISS');
	lcKonto := space(1);
	lnAlgsaldo := 0;
	lnVolg := 0;

	if tnKoikArved = 0 then
		lnJaak = 0;
	end if;
	

	for qryArved in 
		select ARV.id, arv.number, (arv.summa * ifnull(dokvaluuta1.kuurs,1)) as summa, arv.kpv, arv.tahtaeg, ifnull(dokprop.konto, space(20))::varchar(20) as konto 
		from arv inner join dokprop on arv.doklausId = dokprop.id 
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
		where arv.rekvId = tnrekvid and kpv <= tdKpv and arv.asutusId = tnAsutusId 
		and year(arv.kpv) >= 2011
		and arv.objektid = 0
		and arv.jaak <= lnJaak
		and arv.id not in (select distinct a1.id from arv a1 inner join arv1 a2 on (a1.id = a2.parentid) 
			where a2.muud like '%viivis%' and a1.asutusid = tnAsutusId and a1.rekvid = tnRekvid) 
		order by dokprop.konto, arv.kpv

--		and left(dokprop.konto,6) = '103000'

	loop
--		if qryarved.number = '458r8' then
			raise notice 'qryarved.number:%',qryarved.number;
			raise notice 'qryarved.kpv:%',qryarved.kpv;
--		end if;
		ldKpvViimane = qryArved.tahtaeg + 1;
		if lcKonto <> qryArved.konto and not empty (qryArved.konto) then
			lcKonto:= qryArved.konto;
			ldKpv := qryArved.kpv - 1;
			lnAlgsaldo := asd(lckonto, tnrekvid, tnAsutusId, ldkpv);
		end if;


			lnVolg := qryArved.summa;
			lnVolgKokku = lnVolg;
			insert into tmp_viivis (Timestamp, id, rekvId , asutusId , konto , algjaak , algkpv , arvnumber , tahtaeg , summa, volg1, paev1)
				values (lcreturn, qryArved.id, tnRekvId, tnAsutusId, lcKonto, lnAlgsaldo, qryArved.kpv-1,  qryArved.number, qryArved.tahtaeg, 
				qryArved.summa, qryArved.summa, tdKpv - ldKpvViimane+1);

			lnCount := 0;


--			raise notice 'otsime viivise tasumise info';
			lnPaevad = tdKpv - ldKpvViimane+1;

			select count(arv.jaak * ifnull(dokvaluuta1.kuurs,1)) into lnCount
					from arv inner join arv1 on arv.id = arv1.parentid 
					left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
					where rekvid = tnRekvId and arv1.muud like '%Arve nr.:'+ltrim(rtrim(qryArved.number))+'%' and arv1.muud like '%viivis%'; 

--			raise notice 'otsime viivise tasumise info, count: %',lnCount;

									
			if lnCount > 0 then
				raise notice 'start';			
					raise notice 'leitud tasud viivise arve nr  valastame paevade arv uuendatud%',qryArved.number;

					select arv1.muud::varchar into 	lcArveString from arv1 inner join arv on arv.id = arv1.parentid 
						where arv.rekvid = tnrekvId and arv.asutusid = tnAsutusId  and arv1.muud like '%Arve nr.:'+ltrim(rtrim(qryArved.number))+'%' 
						and arv1.muud like '%viivis%' order by arv.id desc limit 1;


					lcArveString = ifnull(lcArveString,'');
					raise notice 'lcArveString uuendatud %',lcArveString;
					lnPaevadInString = position('Päevad:' in lcArveString);
					lnPaevadInStringLopp = position('viivis:' in lcArveString);
					raise notice 'Position lnPaevadInString %',lnPaevadInString;
					raise notice 'Position lnPaevadInStringLopp %',lnPaevadInStringLopp;
					if lnPaevadInString > 0 then
						raise notice 'lcArveString: %',lcArveString;
						lcArveString = ltrim(rtrim(substring(lcArveString,lnPaevadInString+7,lnPaevadInStringLopp-(lnPaevadInString+7))));
--						lcArveString = ltrim(rtrim(substring(lcArveString,lnPaevadInString+7,lnPaevadInStringLopp-(lnPaevadInString+7))))::integer;
						raise notice 'val 111';
						raise notice 'lcArveString: %',lcArveString;
						if empty(lcArveString) then
							lcArveString = '0';
						end if;
						lnPaevadInString = val(lcArveString);
					end if;
				--	raise notice 'substring lnPaevadInString %',lnPaevadInString;
					lnPaevad = lnPaevad - lnPaevadInString;
					if lnPaevad < 0 then
						lnPaevad = 0;
					end if;					
--					raise notice ' lnPaevad %',lnPaevad;

					if lnPaevad > 0 then

					update tmp_viivis set tasud1 = tdkpv,
						tasun1 = 0,
						paev1 = lnPaevad
						where id = qryArved.id
						and Timestamp = lcreturn;
						
--						raise notice 'Updated 1 viivsed miinus';

					end if;
				end if;

			lnCount := 0;

			for qryTasud in select kpv, (arvtasu.summa *  ifnull(dokvaluuta1.kuurs,1)) as summa 
				from arvtasu left outer join dokvaluuta1 on (dokvaluuta1.dokid = arvtasu.id and dokvaluuta1.dokliik = 21)
				where arvtasu.arvId = qryArved.id  
				order by kpv
			loop
--				if qryarved.number = '458r8' then

				raise notice 'Tasud %',qryTasud.summa;
				raise notice 'qryTasud.kpv %',qryTasud.kpv;
--				end if;
				lnCount := lnCount + 1;

				-- arvestame paevad
				if qryTasud.kpv >= ldKpvViimane then
					if lnCount = 1 then
						lnPaevad = qryTasud.kpv - ldKpvViimane + 1;
					else
						lnPaevad = qryTasud.kpv - ldKpvViimane ;
					end if;
					ldKpvViimane = qryTasud.kpv;
				else	
					lnVolg = lnVolg - qryTasud.summa;
					lnPaevad = 0;
				end if;
--				if qryarved.number = '458r8' then
					raise notice 'lnVolg %',lnVolg;
					raise notice 'lnPaevad %',lnPaevad;
--				end if;
				if lnVolg <= 0 and lnPaevad <= 0 then
					-- volad ei ole, kustutame eelinfo
					delete from tmp_viivis where timestamp = lcreturn and id = qryArved.id;

				end if;
				
				if lnVolg > 0 and lnPaevad <= 0 then
					-- tasud varem, aga mitte kokku 
--					raise notice 'tasud varem, aga mitte kokku ';
					lnPaevad = 0;
				end if;
				if lnVolg <= 0 and lnPaevad > 0 then
					-- tasud hiljem
--					raise notice 'tasud hiljem ';
					lnVolg = qryArved.summa ;
				end if;
--				if qryarved.number = '458r8' then
					raise notice 'lnPaevad:%',lnPaevad;
					raise notice 'lnVolg:%',lnVolg;
--				end if;
				if lnVolg < 0 then
					lnVolg = 0;
				end if;

--				raise notice 'otsime viivise tasumise info';
				select count(arv.jaak * ifnull(dokvaluuta1.kuurs,1)) into lnCountV
					from arv inner join arv1 on arv.id = arv1.parentid 
					left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
					where rekvid = tnRekvId and arv1.muud like '%Arve nr.:'+ltrim(rtrim(qryArved.number))+'%' and arv1.muud like '%viivis%'; 
/*
				if (select sum(arv.jaak * ifnull(dokvaluuta1.kuurs,1)) as jaak 
					from arv inner join arv1 on arv.id = arv1.parentid 
					left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
					where rekvid = tnRekvId and arv1.muud like '%Arve nr.:'+ltrim(rtrim(qryArved.number))+'%' and arv1.muud like '%viivis%') = 0 then

*/
				raise notice 'viivised count %',lnCountV;					
				if lnCountV > 0 	then
--					if qryarved.number = '458r8' then
						raise notice 'leitud tasud viivise arve nr  valastame paevade arv %',qryArved.number;
--					end if;
					select arv1.muud::varchar into 	lcArveString from arv1 inner join arv on arv.id = arv1.parentid 
						where arv.rekvid = tnrekvId and arv.asutusId = tnAsutusId and  arv1.muud like '%Arve nr.:'+ltrim(rtrim(qryArved.number))+'%' 
						and arv1.muud like '%viivis%' order by arv.id desc limit 1;

					raise notice 'Start 2 ';


					lcArveString = ifnull(lcArveString,'null');
					raise notice 'lcArveString %',lcArveString;

					if lcArveString = 'null' or empty(lcArveString) then
						raise notice 'String = null';
						lcArveString = 'null';
					end if;
					lnPaevadInString = position('Päevad:' in lcArveString);
					lnPaevadInStringLopp = position('viivis:' in lcArveString);

					
					raise notice 'Position lnPaevadInString %',lnPaevadInString;
					raise notice 'Position lnPaevadInStringLopp %',lnPaevadInStringLopp;
					if lnPaevadInString > 0 then
						lcArveString = ltrim(rtrim(substring(lcArveString,lnPaevadInString+7,lnPaevadInStringLopp-(lnPaevadInString+7))));
						if empty(lcArveString) then
							lcArveString = '0';
						end if;
						lnPaevadInString = val(lcArveString);
					end if;
					raise notice 'substring lnPaevadInString %',lnPaevadInString;
					RAISE NOTICE 'Parandetud paevad %',lnPaevad;
					lnPaevad = lnPaevad - lnPaevadInString;
					if lnPaevad < 0 then
						lnPaevad = 0;
					end if;
					if qryarved.number = '1216r10' then
						RAISE NOTICE 'Parandetud paevad %',lnPaevad;
						RAISE NOTICE 'lnCount %',lnCount;
						RAISE NOTICE 'lnCountV %',lnCountV;
					end if;
				end if;


				if lnCount = 1 then
					update tmp_viivis set tasud1 = qryTasud.kpv,
						tasun1 = qryTasud.summa,
						paev1 = lnPaevad
						where id = qryArved.id
						and Timestamp = lcreturn;
--					if qryarved.number = '458r8' then
						raise notice 'Updated 1';
--					end if;
				end if;


				if lnCount = 2 then

					update tmp_viivis set tasud2 = qryTasud.kpv,
						tasun2 = qryTasud.summa,
						paev2 = lnPaevad,
						volg2 = volg1 - tasun1
						where id = qryArved.id
						and Timestamp = lcreturn;

				end if;

--				raise notice 'Updated 2';
				if lnCount = 3 then
					update tmp_viivis set tasud3 = qryTasud.kpv,
						tasun3 = qryTasud.summa,
						paev3 = lnPaevad,
						volg3 = volg2 - tasun2
						where id = qryArved.id
						and Timestamp = lcreturn;
				end if;
--				raise notice 'Updated 3';
				if lnCount = 4 then
					update tmp_viivis set tasud4 = qryTasud.kpv,
						tasun4 = qryTasud.summa,
						paev4 = lnPaevad,
						volg4 = volg3 - tasun3
						where id = qryArved.id
						and Timestamp = lcreturn;
--					raise notice 'Updated 4';
				end if;
				--lnVolg = lnVolg - qryTasud.summa;
--				lnVolgKokku = lnVolgKokku - lnVolg;
			end loop;

			select summa - (tasun1+tasun2+tasun3+tasun4) into lnVolg from tmp_viivis where Timestamp = lcreturn and id = qryArved.id;

			lnVolg = ifnull(lnVolg,0);
/*
			if lnVolg > 0 then
				lnCount = 0;
			end if;
*/
			if lnVolg > lnVolgKokku then
				-- tasud hiljem
				lnVolg = lnVolgKokku;
			end if;


			--raise notice 'lnCount:%',lnCount;
			--raise notice 'lnVolg:%',lnVolg;
			--raise notice 'ldKpvViimane %',ldKpvViimane;
			--raise notice 'tdKpv %',tdKpv;
			if lnCount > 0 and lnVolg > 0 then
				lnPaevad := qryTasud.kpv - (qryArved.tahtaeg + 1);

					update tmp_viivis set 
						paev6 = tdKpv - ldKpvViimane+1,
						volg6 = lnVolg
						where id = qryArved.id
						and Timestamp = lcreturn;
				
--					raise notice 'Updated 6';
			end if;
-- kustutame kõik kirjad kus on volg vaikesem < 50 EEK			
--			delete from tmp_viivis where Timestamp = lcreturn  and (volg1+volg2+volg3+volg4+volg5+volg6) < 50;			

	end loop;


	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_viivis(integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_viivis(integer, integer, date, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_viivis(integer, integer, date, integer) TO vlad;
