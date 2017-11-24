CREATE OR REPLACE FUNCTION tmp_import_data_from_rekv29()
  RETURNS character varying AS
$BODY$
declare
	lcReturnString varchar = 'Ok';
	newRekvId = 130;
	oldRekvId = 29; 
begin
-- import noms
	
	insert into nomenklatuur (rekvid, doklausid, dok, kood, nimetus, uhik, hind, muud, ulehind, kogus, formula, vanaid)
	select newRekvId as rekvid, doklausid, dok, kood, nimetus, uhik, hind, muud, ulehind, kogus, formula, id
		from nomenklatuur n
		where rekvid = oldRekvId
		and n.id not in (select coalesce(vanaid,0) from nomenklatuur where rekvid = newRekvId);

     return lcReturnString;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

select tmp_import_data_from_rekv29();