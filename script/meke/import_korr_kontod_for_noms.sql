CREATE OR REPLACE FUNCTION import_korr_kontod_for_noms()
  RETURNS integer AS
$BODY$
declare 	
	l_nom_id integer = 20676; -- example
	v_nom record;	
	l_klassif_id integer;
	l_new_dokprop integer;
begin	

	for v_nom in
		select n.*
			from nomenklatuur n 
			where dok = 'ARV'
			and n.id not in (select nomid from klassiflib where not empty_(konto)) 
			and n.id <> l_nom_id
	loop
		raise notice 'nomid %', v_nom.id;
		-- find dok

		select k.id into l_klassif_id from klassiflib k where nomid = v_nom.id and tyyp = 1;
		if l_klassif_id is null then
			insert into klassiflib (nomid, tyyp, konto)
				select v_nom.id, 1, konto from klassiflib where nomid = l_nom_id and tyyp = 1 
				returning id into l_klassif_id;
			raise notice 'saved 1 %', l_klassif_id; 
		end if;

		select k.id into l_klassif_id from klassiflib k where nomid = v_nom.id and tyyp = 2;
		if l_klassif_id is null then
			insert into klassiflib (nomid, tyyp, konto)
				select v_nom.id, 2, konto from klassiflib where nomid = l_nom_id and tyyp = 2 
				returning id into l_klassif_id;
			raise notice 'saved 2 %', l_klassif_id; 
		end if;
		
	end loop;

	
	return 1;
end; 
	
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

select import_korr_kontod_for_noms();
drop function if exists import_korr_kontod_for_noms();