-- Function: recalc_palk_saldo(int4, int2)

-- DROP FUNCTION recalc_palk_saldo(int4, int2);
--muudetud 03/01/2005

CREATE OR REPLACE FUNCTION recalc_palk_saldo(int4, int2)
  RETURNS int4 AS
'
declare 
	tnLepingId alias for $1;

	tnMonth alias for $2;

	lKpv1	date;

	lKpv2	date;

	lnrekvid int;

begin

	If ifnull(tnMonth,0) = 0 then

		lKpv1 := date (year (), month (),1);

		lKpv2 := DATE(YEAR(),12,31);

	ELSE

		lKpv1 = DATE(YEAR(),tnMonth,1);

		--muudetud 03/01/2005
		lKpv2 = gomonth(lKpv1,1)  - 1; 

	end if;

	select palk_asutus.rekvid into lnRekvid from palk_asutus 

	inner join tooleping on (tooleping.ametid = palk_asutus.ametid and tooleping.Osakondid = palk_asutus.osakondid)

	where tooleping.id = tnLepingId;



	return sp_update_palk_jaak(lKpv1,lKpv2, lnRekvId, tnlepingId);

end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(int4, int2) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(int4, int2) TO GROUP dbpeakasutaja;
