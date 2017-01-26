-- Function: fncviivisetahtajastepaevad(integer, date, character varying)
/*

select * from arv where number = '466r12 '

select fncviivisearvekpv(id) from arv where number = '466r12 '

*/
-- DROP FUNCTION fncviivisetahtajastepaevad(integer, date, character varying);

CREATE OR REPLACE FUNCTION fncviivisearvekpv(integer)
  RETURNS date AS
$BODY$


declare 
	tnArveId ALIAS FOR $1;
	ldKpv date;
	v_arv record;
	
BEGIN

	select id, rekvid, number, asutusId into v_arv from arv where id = tnArveId;

-- otsime enne valjastatud viivise arved

	select kpv into ldKpv from arv inner join arv1 on arv.id = arv1.parentid 
		where rekvid = v_arv.RekvId 
		and asutusId = v_arv.asutusId 
		and arv1.muud like '%Arve nr.:'+ltrim(rtrim(v_Arv.number))+'%' 
		and arv1.muud like '%viivis%'
		order by arv.kpv desc limit 1; 
									


	return ldKpv;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncviivisearvekpv(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncviivisearvekpv(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncviivisearvekpv(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncviivisearvekpv(integer) TO dbvaatleja;
