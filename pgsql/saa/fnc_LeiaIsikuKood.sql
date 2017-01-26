-- Function: fnc_leiaisikukood(text)

-- DROP FUNCTION fnc_leiaisikukood(text);

CREATE OR REPLACE FUNCTION fnc_leiaisikukood(text)
  RETURNS integer AS
$BODY$

DECLARE 
	tcText alias for $1;
	
	lnisikId integer;
	lcIsikukood varchar(20);
	lnTulemus integer;
	lctext text;
	lnPos integer;
	x integer;
	fa text[];
begin
lnisikId = 0;
--raise notice 'rea 1';
	fa = regexp_split_to_array(tcText, E'\\s+');
      	x=1;
     	for x in COALESCE(array_lower(fa,1),0) .. array_upper(fa,1) loop
		raise notice 'values , %',fa[x];
		lcIsikukood = left(fa[x]::varchar,20);
		raise notice 'lcIsikukood , %',lcIsikukood;
		if ifnull(lcIsikukood,'null') <> 'null' and len(lcIsikukood) = 11 then
		
		raise notice 'lcIsikukood otsime , %',lcIsikukood;
			select id into lnIsikId from asutus where regkood = lcIsikukood;
			lnisikId = ifnull(lnIsikId,0);
			if lnIsikId > 0 then
				exit;
			end if;
		end if;	
		x=x+1;
	end loop;
	return lnisikId;
return 1;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_leiaisikukood(text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_leiaisikukood(text) TO public;
GRANT EXECUTE ON FUNCTION fnc_leiaisikukood(text) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_leiaisikukood(text) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_leiaisikukood(text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_leiaisikukood(text) TO dbvaatleja;
