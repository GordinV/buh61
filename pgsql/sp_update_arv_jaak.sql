-- Function: sp_update_arv_jaak(integer)

-- DROP FUNCTION sp_update_arv_jaak(integer);

CREATE OR REPLACE FUNCTION sp_update_arv_jaak(integer)
  RETURNS numeric AS
$BODY$
declare 
	tnId alias for $1;
	lnJaak numeric;
	lnSumma numeric;
	v_arv record;
	ldTasud date;

begin
-- arv jaak
	select arv.summa * ifnull(dokvaluuta1.kuurs,1) , arv.tasud, arv.jaak, ifnull(dokvaluuta1.kuurs,1) into v_arv  from arv left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3) where arv.id = tnId;
	
-- tasu summa 	
	SELECT sum(Arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)) into lnsumma FROM Arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		WHERE Arvtasu.arvid = tnId;
		
	lnJaak := ifnull(v_arv.summa,0) - ifnull(lnSumma,0) / v_arv.kuurs;
	if lnJaak <> ifnull(v_arv.jaak,0) then
		-- uuendame tasu info

		select kpv into ldTasud from arvtasu where arvid = tnId order by kpv desc limit 1;
		update arv set jaak = lnJaak, tasud = ldTasud where id = tnId;
 
	end if;
	
        return  lnJaak;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_arv_jaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO taabel;
