-- Function: recalc_palk_saldo(integer, smallint)

-- DROP FUNCTION recalc_palk_saldo(integer, smallint);

CREATE OR REPLACE FUNCTION recalc_palk_saldo(integer, smallint)
  RETURNS integer AS
$BODY$
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION recalc_palk_saldo(integer, smallint) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO public;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbpeakasutaja;
