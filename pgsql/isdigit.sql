-- Function: isdigit(character varying)

-- DROP FUNCTION isdigit(character varying);

CREATE OR REPLACE FUNCTION isdigit(character varying)
  RETURNS integer AS
$BODY$
DECLARE tcChar alias for $1;
	lnresult int;
	lnCount int;
begin
	lnresult = 0;
	lnCount = 0;
	loop
		if lnCount::varchar(1) = left(ltrim(rtrim(tcChar)),1)::varchar(1) then
--			raise notice 'digit';
			lnresult = 1;
		end if;
		if lnCount = 9 or lnresult = 1 then
			exit;
		end if;
		
		lnCount = lnCount + 1;
	end loop;

         return  lnResult;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION isdigit(character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbadmin;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbvaatleja;
