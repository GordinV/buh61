
CREATE OR REPLACE FUNCTION sp_arvede_kooperime()
  RETURNS integer AS
$BODY$
declare 
	l_count integer = 0;
	v_arv record;
	v_arv1 record;
	v_arvtasu record;
	v_nom record;
	l_arv_id integer;
	l_nom_id integer;
	l_arv1_id integer;
begin
-- услуги
	for v_nom in 
		select * from nomenklatuur 
			where rekvid = 28 
			and id in (
				select distinct nomid from arv1 where parentid in (select distinct id from arv 
					where rekvid = 28 
					and number ilike 'r%')
			)
	loop
		raise notice 'v_nom.kood %, v_nom.nimetus %',v_nom.kood , v_nom.nimetus;
		if (select count(*) from nomenklatuur  where rekvid = 29 and kood = v_nom.kood and nimetus = v_nom.nimetus and dok = 'ARV') = 0 then
			raise notice 'Nomenclatuur ei leidnud, lisame';
			insert into nomenklatuur  (rekvid, kood, nimetus, uhik, hind, muud, dok) 
				values (29, v_nom.kood,v_nom.nimetus, v_nom.uhik, v_nom.hind, v_nom.muud, v_nom.dok );
				
			l_count = l_count + 1;
		end if;
	end loop;
	raise notice 'Kokku noms : %', l_count;
	l_count = 0;

-- списко счетов
	for v_arv in 
		select *
			from arv 
			where rekvid = 28 
			and number ilike 'r%'
--			limit 10
	loop
		raise notice 'arv.id %, v_arv.number %, v_arv.kpv %', v_arv.id, v_arv.number, v_arv.kpv;
		-- otsime arve selle numbriga
		if (select count(*) from arv where rekvid = 29 and number = v_arv.number and kpv = v_arv.kpv) = 0 then
			raise notice 'Arv ei leidnud, lisame';
			insert into arv (rekvid, userid, liik, operid, number, kpv, asutusid, lisa, tahtaeg, kbmta,kbm,  summa,  tasud, tasudok, muud,jaak, objekt )
				values (29, v_arv.userid, v_arv.liik, v_arv.operid, v_arv.number, v_arv.kpv, v_arv.asutusid, v_arv.lisa, v_arv.tahtaeg, 
					v_arv.kbmta, v_arv.kbm,  v_arv.summa,  v_arv.tasud, v_arv.tasudok, v_arv.muud,v_arv.jaak, v_arv.objekt );

			l_arv_id := cast(CURRVAL('public.arv_id_seq') as int4);


			for v_arv1 in 
				select arv1.*, n.kood
				from arv1 
				inner join nomenklatuur n on n.id = arv1.nomid
				where parentid = v_arv.id
			loop
				delete from arv1 where parentid = l_arv_id;
				-- otsime noim
				select id into l_nom_id from nomenklatuur where rekvid = 29 and kood = v_arv1.kood and dok = 'ARV';

				insert into arv1 ( parentid,  nomid ,kogus,hind ,soodus ,kbm , maha , summa , muud , kood1 , kood2 ,kood3 , kood4 ,kood5 ,konto , tp ,
					kbmta ,isikid,tunnus , proj ,tahtaeg) 
				values (l_arv_id,  l_nom_id ,v_arv1.kogus, v_arv1.hind ,v_arv1.soodus ,v_arv1.kbm , v_arv1.maha , v_arv1.summa , v_arv1.muud , 
					v_arv1.kood1 , v_arv1.kood2 ,v_arv1.kood3 , v_arv1.kood4 ,v_arv1.kood5 ,v_arv1.konto , v_arv1.tp ,
					v_arv1.kbmta ,v_arv1.isikid,v_arv1.tunnus , v_arv1.proj ,v_arv1.tahtaeg);

				l_arv1_id := cast(CURRVAL('public.arv1_id_seq') as int4);
 

				-- valuuta

				delete from dokvaluuta1 where dokid = l_arv1_id and dokliik = 2;
				
				insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
					select  l_arv1_id, dokliik, valuuta, kuurs from dokvaluuta1 where dokid = v_arv1.id and dokliik = 2;
	
			
			end loop;
			-- arvtasu
			for v_arvtasu in 
				select * from arvtasu 
				where arvid = v_arv.id
			loop
				delete from arvtasu where arvid = l_arv_id;
				insert into arvtasu (rekvid,  arvid,  kpv ,  summa ,  dok ,  nomid ,  pankkassa ,  journalid ,  sorderid ,  muud,  doklausid)
					values (29, l_arv_id, v_arvtasu.kpv ,  v_arvtasu.summa ,  v_arvtasu.dok ,  v_arvtasu.nomid ,  v_arvtasu.pankkassa , 
					v_arvtasu.journalid ,  v_arvtasu.sorderid , v_arvtasu.muud,  v_arvtasu.doklausid);
					
			end loop;

			PERFORM sp_updateArvJaak(l_arv_id, date());
			
			l_count = l_count +1;
		end if;
	end loop;


         return  l_count;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select sp_arvede_kooperime();


