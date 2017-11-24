-- Function: recalc_palk_saldo(integer, smallint)

-- DROP FUNCTION recalc_palk_saldo(integer, smallint);

CREATE OR REPLACE FUNCTION recalc_palk_saldo(integer, smallint, smallint)
  RETURNS integer AS
$BODY$
declare 
	tnLepingId alias for $1;
	tnMonth alias for $2;
	tnYear alias for $3;

	lKpv1	date;
	lKpv2	date;

	lnrekvid int;

begin

	If ifnull(tnMonth,0) = 0 then

		lKpv1 := date (coalesce(tnYear,year()), month (),1);

		lKpv2 := DATE(coalesce(tnYear,year()),12,31);

	ELSE

		lKpv1 = DATE(coalesce(tnYear,year()),tnMonth,1);

		--muudetud 03/01/2005
		lKpv2 = gomonth(lKpv1,1)  - 1; 

	end if;

	select rekvid into lnRekvid 
		from tooleping 
		where tooleping.id = tnLepingId;
	raise notice 'lKpv1 %,lKpv2 %, lnRekvId %, tnlepingId %',lKpv1,lKpv2, lnRekvId, tnlepingId;	
	return sp_update_palk_jaak(lKpv1,lKpv2, lnRekvId, tnlepingId);

end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION recalc_palk_saldo(integer, smallint)
  OWNER TO vlad;
