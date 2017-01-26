-- Function: sp_calc_tasu(int4, int4, date)

-- DROP FUNCTION sp_calc_tasu(int4, int4, date);

--muudetud 03/01/2005

CREATE OR REPLACE FUNCTION sp_calc_tasu(int4, int4, date)
  RETURNS "numeric" AS
'

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
	lnrekvId int;
	ldKpv1 date;
	ldKpv2 date;
	v_tooleping record;

begin



lnsUMMA :=0;



select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;




if v_palk_kaart.percent_ = 1 then

	SELECT Palk_jaak.lepingId, Palk_jaak.id, Palk_jaak.kuu, Palk_jaak.aasta,  Palk_jaak.jaak, Palk_jaak.arvestatud, Palk_jaak.kinni,  

	Palk_jaak.TKA, Palk_jaak.tki, Palk_jaak.pm, Palk_jaak.tulumaks, Palk_jaak.sotsmaks, Palk_jaak.muud 

	into v_palk_jaak

	FROM  Palk_jaak WHERE Palk_jaak.lepingId = tnLepingId   AND Palk_jaak.kuu = month(tdKpv)   

	AND Palk_jaak.aasta = year(tdKpv)  

	ORDER by kuu desc, aasta desc 

	limit 1;

--	muudetud 03/01/2005
	if ifnull(v_palk_jaak.jaak ,0) = 0 then

--	voib olla on vaja re-arvesta palgajaak (avada period)
		select * into v_tooleping from tooleping where id = tnLepingId;

		raise notice \'tdKpv %\',tdKpv;

		ldKpv1 := tdKpv - interval ''1 month'';
		raise notice \'ldKpv1 %\',ldKpv1;

		perform sp_calc_palgajaak(v_tooleping.rekvId, ldKpv1, tdKpv,v_tooleping.parentid, v_tooleping.parentid);		

		SELECT  Palk_jaak.jaak into v_palk_jaak
			FROM  Palk_jaak WHERE Palk_jaak.lepingId = tnLepingId   AND Palk_jaak.kuu = month(tdKpv)   
			AND Palk_jaak.aasta = year(tdKpv)  
			ORDER by kuu desc, aasta desc 
			limit 1;

	end if;

raise notice \'v_palk_jaak.jaak %\',v_palk_jaak.jaak;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * v_palk_jaak.jaak, qryPalkLib.round);


else


	lnSumma := f_round(v_palk_kaart.summa, qryPalkLib.round);


end if;




Return lnSumma;

end; 

'
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(int4, int4, date) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(int4, int4, date) TO GROUP dbpeakasutaja;
