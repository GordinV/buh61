-- Function: fnc_ntod(integer)
/*
select  fnc_AsutuseStaatus(id),	regkood, omvorm, nimetus from asutus
select  regkood, omvorm, nimetus from asutus

*/
-- DROP FUNCTION fnc_ntod(integer);

CREATE OR REPLACE FUNCTION fnc_AsutuseStaatus(integer)
  RETURNS integer AS
$BODY$

DECLARE 
	tnId alias for $1;
	
	v_asutus record;
	lnStaatus integer;
begin
	lnStaatus = 1;
	select regkood, omvorm, nimetus into v_asutus from asutus where id = tnId;
	lnStaatus = case 
		when  isdigit(ltrim(rtrim(v_asutus.regkood))) = 0 then  0
		when  len(ltrim(rtrim(v_asutus.regkood))) not in (8,11) then 0
		when (empty(v_asutus.regkood) or empty(v_asutus.omvorm) or empty(v_asutus.nimetus)) then  0
		when upper(v_asutus.omvorm) not in ('AS','OU','OÜ','KU','KÜ','SA','KOV','ISIK','GOV','RIIK','TU','TÜ','FIE','ERAISIK') THEN 0
		else 1
	end;

	return lnStaatus;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_AsutuseStaatus(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_AsutuseStaatus(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_AsutuseStaatus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_AsutuseStaatus(integer) TO dbvaatleja;
