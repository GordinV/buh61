-- Function: fnc_getomatp(integer, integer)

-- DROP FUNCTION fnc_getomatp(integer, integer);

CREATE OR REPLACE FUNCTION fnc_getomatp(integer, integer)
  RETURNS character AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tnAasta alias for $2;
	lcOmaTp character(20);
begin
lcOmaTp = '185101';

--	if empty (tnAasta)  or tnAasta = year(date()) then
		-- otsin oma TP kood
		SELECT TP INTO lcOmaTp FROM Aa WHERE Aa.parentid = tnrekvid  AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
		lcOmaTp = ifnull(lcOmaTp,'');
/*
	else
		if tnAasta < 2010 then
			if tnRekvId = 63 then
				lcOmaTp = '185101';
			end if;
			if tnRekvId = 3 then
				lcOmaTp = '185102';
			end if;
			if tnRekvId = 10 then
				lcOmaTp = '185103';
			end if;
			if tnRekvId = 28 then
				lcOmaTp = '185105';
			end if;
			if tnRekvId = 6 then
				lcOmaTp = '185106';
			end if;
			if tnRekvId = 29 then
				lcOmaTp = '185107';
			end if;
			if tnRekvId = 119 or tnRekvId in (select id from rekv where parentid = 119) then
				lcOmaTp = '185130';
			end if;
			if tnRekvId = 15 then
				lcOmaTp = '185131';
			end if;
			if tnRekvId = 64 then
				lcOmaTp = '185140';
			end if;
			if tnRekvId = 21 then
				lcOmaTp = '185116';
			end if;
			if tnRekvId = 27 then
				lcOmaTp = '185132';
			end if;
		
		end if;
	end if;
	*/
	return lcOmaTp;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_getomatp(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbvaatleja;
