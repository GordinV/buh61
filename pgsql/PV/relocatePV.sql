
CREATE OR REPLACE FUNCTION relocatePV(varchar(20))
  RETURNS integer AS
$BODY$

declare
	tcInventar alias for $1;
	ln_result integer = 0;
	ln_source_rekv integer = 29;
	ln_dest_rekv integer = 130;

	v_card record;
	l_card_id integer;
	l_mahakandmine_source_id integer = (select id from nomenklatuur where ltrim(rtrim(kood)) = 'MAHAKANDMINE' and rekvid = ln_source_rekv and ltrim(rtrim(dok)) = 'MAHAKANDMINE');
	l_paigutus_dest_id integer = (select id from nomenklatuur where ltrim(rtrim(kood)) = 'PVPAIG' and rekvid = ln_dest_rekv and ltrim(rtrim(dok)) = 'PAIGUTUS');
	l_oper_summa numeric(14,2) = 0;
	l_konto varchar(20);
	l_oper_id  integer;
	l_lausend_id integer;
	l_doklaus_mahakandmine_id integer = 130; --rekvid = 29
	l_new_card_id integer;
	l_kulum_total numeric (14,2) = 0;
	l_dest_gruppId integer;
	v_grupp record;
	v_err_grupp record;
begin
	-- select data from source
/*
	select l.id, k.parhind, k.konto,  konto.kood as kulumkonto, k.tunnus, k.vastisikid, k.soetkpv, k.algkulum, k.kulum, l.muud as selg, k.muud as rentnik, l.kood, l.nimetus, k.gruppid   
		into v_card
		from library l 
		inner join pv_kaart k on l.id = k.parentid
		inner join library grupp ON k.gruppid = grupp.id AND l.rekvid = grupp.rekvid
		left outer join library konto on konto.id = grupp.tun2 
	where l.rekvid = 29 --ln_source_rekv
	and ltrim(rtrim(l.kood)) = ltrim(rtrim(tcInventar))
	order by l.id desc
	limit 1;

	if v_card.tunnus = 0 then
		raise notice 'PV kaart juba mahakantud';
		return 0;
	end if;

	raise notice 'select data from source %', v_card.id;
	-- mahakandmine

	l_oper_id =  sp_salvesta_pv_oper(0, v_card.id, l_mahakandmine_source_id, l_doklaus_mahakandmine_id, 4, date(2017,01,01), v_card.parhind, 'Mahakandmine', '', '', '12', '', '', ifnull(v_card.kulumkonto,''), '', 0, '', '', 'EUR', 1);

	raise notice 'Mahakandmine, salvestatud %', l_oper_id;

	--konteerimine
--	l_lausend_id =  gen_lausend_mahakandmine(l_oper_id);
	raise notice 'Konteerimine %', l_lausend_id;
	
	-- create new card

	-- grupp
	select * into v_grupp from library where id = v_card.gruppid;

	select id into l_dest_gruppId from library 
		where rekvid = ln_dest_rekv 
		and kood = v_grupp.kood 
		and nimetus = v_grupp.nimetus 
		and library = v_grupp.library 
		and rekvid = v_grupp.rekvid;

	if l_dest_gruppId is null then 
		raise notice 'pv grupp puudub';
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud, vanaid)
			values (ln_dest_rekv, v_grupp.kood, v_grupp.nimetus, v_grupp.library, v_grupp.tun1, v_grupp.tun2, v_grupp.tun3, v_grupp.tun4, v_grupp.tun5, v_grupp.muud, v_grupp.id)
		returning id into l_dest_gruppId;

		raise notice 'PV grupp salvetatud %', l_dest_gruppId;
	else 
		raise notice 'PV grupp found %', l_dest_gruppId;		
	end if;	
	
	select sum(summa) into l_kulum_total from pv_oper where parentid = v_card.id and liik = 2;

	l_new_card_id = sp_salvesta_pv_kaart(0, v_card.vastisikid,  v_card.soetkpv, v_card.kulum, ifnull(l_kulum_total,0) + v_card.algkulum, l_dest_gruppId, v_card.konto, 
		1, v_card.selg, v_card.rentnik, v_card.kood, v_card.nimetus, ln_dest_rekv);

	update library set vanaid = v_card.id where id = l_new_card_id;

	-- paigaldus
	l_oper_id =  sp_salvesta_pv_oper(0, l_new_card_id, l_paigutus_dest_id, 0, 1, date(2017,01,01), v_card.parhind, 'Paigaldamine', '', '', '', '', '', '', '', 0, '', '', 'EUR', 1);

	raise notice 'kaart paigaldatud %', l_oper_id ;
*/
	for v_grupp in 
		select distinct vanaid as id 	
			from library 
			where library = 'PVGRUPP' 
			and rekvid = 130 
			and not empty(vanaid) 
	loop
		select id into l_dest_gruppId from library where vanaid = v_grupp.id and library = 'PVGRUPP' order by id limit 1;
		raise notice 'received right grupp Id %', l_dest_gruppId;

		-- select pv_cards with wrong gruppid and change it
		for  v_card in
			select id, kood, nimetus, gruppid  from curPohivara 
				where id in (select parentid from pv_kaart 
					where gruppid in (select id from library where vanaid = v_grupp.id and id <> l_dest_gruppId))
		loop
			raise notice 'vigane PV kaart id new_id, old_id: v_card.id %, l_dest_gruppId %, v_card.gruppid %', v_card.id, l_dest_gruppId, v_card.gruppid;
			update pv_kaart set gruppId = l_dest_gruppId where parentId = v_card.id and gruppid = v_card.gruppid;
			if (select count(id) from pv_kaart where gruppid = v_card.gruppid) > 0 then
				raise exception 'more then one PV card found, process stoped v_card.gruppid %, l_dest_gruppId %';
			end if;
			delete from library where id = v_card.gruppid and library = 'PVGRUPP' and rekvid = 130 and vanaid = v_grupp.id;
			raise notice 'PV kaart % finished',v_card.id;
		end loop;			

	end loop;			


         return  ln_result;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
ALTER FUNCTION relocatePV(varchar(20)) OWNER TO vlad;

select relocatePV('H155100-250');
/*
select * from rekv where parentid = 63

select id from nomenklatuur where ltrim(rtrim(kood)) = 'MAHAKANDMINE' and rekvid = 29 and ltrim(rtrim(dok)) = 'MAHAKANDMINE'

select * from pv_kaart order by id desc limit 10

select l.id, k.parhind, grupp.tun2 , konto.kood as kulumkonto
		from library l 
		inner join pv_kaart k on l.id = k.parentid
		inner join library grupp ON k.gruppid = grupp.id AND l.rekvid = grupp.rekvid
		left outer join library konto on konto.id = grupp.tun2 
	where l.rekvid = 29 --ln_source_rekv
--	and ltrim(rtrim(l.kood)) = ltrim(rtrim(tcInventar))
	order by l.id desc
	limit 100;

	select id from nomenklatuur where ltrim(rtrim(kood)) = 'PVPAIG' and rekvid = 130 and ltrim(rtrim(dok)) = 'PAIGUTUS'

*/