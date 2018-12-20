drop function if exists tootajate_palga_andmed_kooperimine();

CREATE OR REPLACE FUNCTION tootajate_palga_andmed_kooperimine()
  RETURNS boolean AS
$BODY$
declare 
	v_leping record;
	v_mvt record;
	l_osakond integer = 672107;
	l_amet integer;
	l_leping integer;
	l_rekv integer = 71; --  Narva Muusikakooli (0951004)
	v_pk record;
	l_pk integer;
	l_tunnus integer;
begin
	for v_leping in 
		select t.*,
			a.kood as amet
			from tooleping t
			inner join library a on a.id = t.ametid
			where t.rekvid in (select id from rekv where nimetus like '0951001%' or nimetus like '0951003%') and (t.lopp is null or t.lopp = '2018-08-31')
	loop
		-- otsime ametid		
		l_amet = (select id from library where rekvid = l_rekv and library = 'AMET' and upper(ltrim(rtrim(kood))) = upper(ltrim(rtrim(v_leping.amet))) order by id desc limit 1);
--		raise notice 'amet %, id %', v_leping.amet, l_amet;
		if l_amet is null then
			raise exception 'Amet ei leidnud %', v_leping.amet;
		end if; 		

		-- kontrollime, kas leping juba oli salvestatud

		l_leping = (select id from tooleping where rekvid = l_rekv and osakondid = l_osakond and parentid = v_leping.parentid and algab = v_leping.algab order by id desc limit 1);
		if l_leping is null then
			insert into tooleping (parentid, osakondid, ametid, algab, palk, palgamaar, pohikoht, ametnik, tasuliik, pank, aa, muud, rekvid, resident, riik, toend, koormus, toopaev)
				select parentid, l_osakond, l_amet, algab, palk, palgamaar, pohikoht, ametnik, tasuliik, pank, aa, muud, l_rekv, resident, riik, toend, koormus, toopaev 
				from tooleping where id = v_leping.id returning id into l_leping;

			raise notice 'leping salvestatud vana % uus %', v_leping.id, l_leping;	
		end if;

		if l_leping is null then
			raise exception 'viga, tooleping % ', v_leping.id;
		end if;

		-- mvt

		for v_mvt in
			select * from taotlus_mvt where lepingid = v_leping.id
		loop
			if not exists (select id from taotlus_mvt where lepingid = l_leping and kpv = v_mvt.kpv and alg_kpv = '2018-01-09') then
				insert into taotlus_mvt (rekvid, lepingid, kpv, alg_kpv, lopp_kpv, summa, muud, userid) 
					values( l_rekv, l_leping, v_mvt.kpv, '2018-01-09', '2018-12-31', v_mvt.summa, v_mvt.muud, v_mvt.userid);

				update 	taotlus_mvt set lopp_kpv = '2018-08-31' where id = v_mvt.id;

				raise notice 'mvt saved';		
			end if;	
		end loop;

		-- palk_kaart

		for v_pk in 
			select pk.*, l.kood,
				t.kood as t_kood
				from palk_kaart pk 
				inner join library l on pk.libid = l.id
				left outer join library t on pk.tunnusid = t.id
				where pk.lepingid = v_leping.id 
		loop
			-- otsime vana kood ja teema analoog
			l_pk = (select l.id 
				from library l inner join palk_lib pl on pl.parentid = l.id
				where rekvid = l_rekv and kood = v_pk.kood order by id desc limit 1);
				
			if l_pk is null then
				raise exception 'palk lib kood puudub %', v_pk.kood;
			end if;	

				-- tunnus
			if v_pk.tunnusid <> 0 then
				l_tunnus = (select id from library where rekvid = l_rekv and library = 'TUNNUS' and kood = v_pk.t_kood order by id desc limit 1);
				
				if l_tunnus is null then
					raise notice 'tunnus puudub, lisame';
					insert into library (rekvid, kood, nimetus, library, muud) 
						select l_rekv, kood, nimetus, library, muud 
						from library where id = v_pk.tunnusid
						returning id into l_tunnus;
					raise notice 'tunnus lisatud %', l_tunnus;
				end if;

			else
				l_tunnus = 0;
			end if;
			if not exists (select id from palk_kaart where lepingid = l_leping and libid = l_pk ) then
				raise notice 'pk puudub, salvestame';
				insert into palk_kaart (parentid, lepingid, libid, summa, percent_, tulumaks, tulumaar, status, muud, alimentid, tunnusid, minsots)
					values (v_pk.parentid, l_leping, l_pk, v_pk.summa, v_pk.percent_, v_pk.tulumaks, v_pk.tulumaar, v_pk.status, 
					v_pk.muud, v_pk.alimentid,  l_tunnus, v_pk.minsots);
				raise notice 'palk_kaart lisatud';	
			else
				raise notice 'palk_kaart on olemas';	
				
			end if;
			
		end loop;
	end loop;
	return true;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

select tootajate_palga_andmed_kooperimine();

drop function if exists tootajate_palga_andmed_kooperimine();
