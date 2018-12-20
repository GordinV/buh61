-- Function: sp_check_twins(date, integer, integer, integer)

-- DROP FUNCTION sp_check_twins(date, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_check_twins(date, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tdKpv alias for $1;
	tnLibId alias for $2;
	tnlepingId alias for $3;
	tnId alias for $4;
	v_palk_oper record;
	lnError int;


begin

	for v_palk_oper in 
		SELECT Palk_oper.id, palk_oper.libId, palk_lib.liik , palk_oper.sotsmaks
		FROM Palk_oper 
		inner join palk_lib on palk_oper.libId = palk_lib.Parentid
		WHERE Palk_oper.libId = tnLibId   
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.LepingId = tnLepingId
		and palk_lib.liik not in (6,9) 
		and palk_oper.id <> tnid 
	loop
		raise notice 'Kustutan v_palk_oper.id %', v_palk_oper.id;
		lnError := sp_del_palk_oper(v_palk_oper.id,1);
	end loop;


	return lnError;


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_check_twins(date, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO taabel;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbvanemtasu;
