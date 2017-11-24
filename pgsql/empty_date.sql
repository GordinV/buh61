-- Function: empty(date)

-- DROP FUNCTION empty(date);

CREATE OR REPLACE FUNCTION empty(date)
  RETURNS boolean AS
$BODY$

begin

	if $1 is null or year($1) <  year (now()::date)-100 then

		return true;

	else

		return false;

	end if;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION empty(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION empty(date) TO vlad;
GRANT EXECUTE ON FUNCTION empty(date) TO public;
GRANT EXECUTE ON FUNCTION empty(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION empty(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION empty(date) TO dbadmin;
GRANT EXECUTE ON FUNCTION empty(date) TO dbvaatleja;
