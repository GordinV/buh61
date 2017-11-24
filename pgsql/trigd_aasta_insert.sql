-- Function: trigd_aasta_insert()

-- DROP FUNCTION trigd_aasta_insert();

CREATE OR REPLACE FUNCTION trigd_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(old.rekvid, old.kpv)= 0) then
--			raise notice 'Viga: Perion on kinnitatud';
			raise exception 'Viga: Perion on kinnitatud';
--			return null;
	end if;

	return old;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO dbpeakasutaja;
