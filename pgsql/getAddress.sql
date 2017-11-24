
CREATE OR REPLACE FUNCTION getAdress(tcAddress)
  RETURNS text[] AS
$BODY$
declare
	c_return text[];
	l_address_part text[];
	c_adress text = tcAddress;
	c_city text = '';
	c_postnumber text = '';
	c_address_part text;
begin
	l_address_part =  string_to_array(tcAddress, ',');

	if array_length(l_address_part) = 0 then
		return null;
	end if;

	FOREACH l_address_part  IN ARRAY l_address_part LOOP
	    raise notice 'l_address_part %', l_address_part; 
	END LOOP [ label ];	
	return c_return;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


select getAdress(tcAddress)
