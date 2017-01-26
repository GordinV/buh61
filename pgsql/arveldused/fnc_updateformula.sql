-- Function: fnc_avansijaak(integer)

-- DROP FUNCTION fnc_avansijaak(integer);

CREATE OR REPLACE FUNCTION fnc_updateformula(integer, integer, character varying)
  RETURNS integer AS
$BODY$


declare 
	tnId		ALIAS FOR $1;
	tnDokTyyp 	ALIAS FOR $2;
	tcFormula	ALIAS FOR $3;
	lnId int;
BEGIN

if tnDokTyyp = 1 then
	update nomenklatuur set formula = tcFormula where id = tnId;
end if;
if tnDokTyyp = 2 then
	update pakett set formula = tcFormula where libid = tnId;
end if;
if tnDokTyyp = 3 then
	update leping2 set formula = tcFormula where id = tnId;
end if;

GET DIAGNOSTICS lnId = ROW_COUNT;	

RETURN lnId;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_updateformula(integer, integer, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_updateformula(integer, integer, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_updateformula(integer, integer, character varying) TO dbpeakasutaja;
