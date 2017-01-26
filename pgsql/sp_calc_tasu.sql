-- Function: sp_calc_tasu(integer, integer, date)

-- DROP FUNCTION sp_calc_tasu(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_tasu(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	v_palk_jaak record;
	nSumma numeric (12,4);
	lnKuurs numeric(12,4);
begin

lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;


if v_palk_kaart.percent_ = 1 then
	SELECT Palk_jaak.lepingId, Palk_jaak.id, Palk_jaak.kuu, Palk_jaak.aasta,  Palk_jaak.jaak, Palk_jaak.arvestatud, Palk_jaak.kinni,  
	Palk_jaak.TKA, Palk_jaak.tki, Palk_jaak.pm, Palk_jaak.tulumaks, Palk_jaak.sotsmaks, Palk_jaak.muud 
	into v_palk_jaak
	FROM  Palk_jaak WHERE Palk_jaak.lepingId = tnLepingId   AND Palk_jaak.kuu = month(tdKpv)   
	AND Palk_jaak.aasta = year(tdKpv)  
	ORDER by kuu desc, aasta desc 
	limit 1;

	lnSumma := f_round(v_palk_kaart.summa * 0.01 * v_palk_jaak.jaak * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);


else

	lnSumma := f_round(v_palk_kaart.summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);

end if;


Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tasu(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO taabel;
