CREATE OR REPLACE FUNCTION import_dokprop()
  RETURNS integer AS
$BODY$
declare 	
	l_dokprop_id integer = 76; -- example
	v_rekv record;	
	l_dok integer;
	l_new_dokprop integer;
begin	

	for v_rekv in
		select ID from rekv 
		where id not in (
		select l.rekvid
		from dokprop d
		inner join library l ON l.id = d.parentid
		where l.LIBRARY = 'DOK' and l.kood = 'ARV')
	loop
		raise notice 'rekvid %', v_rekv.id;
		-- find dok
		select id into l_dok from library where library = 'DOK' and kood = 'ARV' and rekvid = v_rekv.id;
		if l_dok is null then
			-- create
			insert into library (rekvid, kood, nimetus, library) 
				select v_rekv.id, kood, nimetus, library from library l inner join dokprop d on d.parentid = l.id where d.id = l_dokprop_id
				returning id into l_dok;
			raise notice 'saved dok %', l_dok;	
		end if;

		select id into l_new_dokprop from dokprop where parentid = l_dok limit 1;

		if l_new_dokprop is null then
			-- insert
			insert into dokprop (parentid, registr, vaatalaus, selg, muud, konto, kbmkonto, asutusid)
				select l_dok, 1, 1, selg, muud, konto, kbmkonto, asutusid from dokprop where id = l_dokprop_id
				returning id into l_new_dokprop;

			raise notice 'dokprop saved %', l_new_dokprop;	
		end if; 
		
	end loop;

	
	return 1;
end; 
	
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

select import_dokprop();
drop function if exists import_dokprop();