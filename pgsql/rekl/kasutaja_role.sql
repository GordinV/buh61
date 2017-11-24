CREATE OR REPLACE FUNCTION kasutaja_role(in role_tegevus text, in role_nimi text, in kasutaja text default CURRENT_USER::text)
  RETURNS boolean AS
$BODY$
declare
	l_tulemus boolean = false;
	l_rea text
begin
	select muud into l_rea from userid where kasutaja = 
	if role_tegevus = 'lisa' then
	
		
	elsif role_tegevus = 'kaivita' then
	else 
	end if;
         return  l_tulemus;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION date(integer, integer, integer)
  OWNER TO vlad;
GRANT EXECUTE ON FUNCTION date(integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION date(integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION date(integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION date(integer, integer, integer) TO taabel;
GRANT EXECUTE ON FUNCTION date(integer, integer, integer) TO dbvanemtasu;
