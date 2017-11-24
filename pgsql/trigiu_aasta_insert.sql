-- Function: trigiu_aasta_insert()

-- DROP FUNCTION trigiu_aasta_insert();

CREATE OR REPLACE FUNCTION trigiu_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(new.rekvid, new.kpv)= 0) then
			raise exception 'Viga:Perion on kinnitatud';
			return null;
	end if;

	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO dbpeakasutaja;
