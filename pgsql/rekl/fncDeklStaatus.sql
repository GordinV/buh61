-- Function: sp_tasu_dekl(integer)

-- DROP FUNCTION sp_tasu_dekl(integer);

CREATE OR REPLACE FUNCTION fncDeklStaatus(integer)
  RETURNS integer AS
$BODY$

declare
	tnDeklId alias for $1;

	v_dekl record;

	lnDeklStatus int;
	lnSumma numeric;
	lnStaatus int;
begin
	lnStaatus = 1;
	-- laekused

	select sum(summa) into lnSumma from dekltasu where deklid = tnDeklId;
	lnSumma = ifnull(lnSumma,0);

	-- deklsumma
	
	select toiming.id, toiming.summa, toiming.kpv, toiming.tahtaeg, toiming.staatus, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_dekl 
		from toiming left outer join dokvaluuta1 on (dokvaluuta1.dokid = toiming.id and dokliik = 24)
		where toiming.Id = tnDeklId;


	-- status	
	lnStaatus = v_dekl.staatus;

	
	if lnSumma > 0 then
		if round(ifnull(lnSumma,0),1) >= round(v_dekl.summa * v_dekl.kuurs,1) then
			-- tasud
			lnStaatus = 3;	
		else
			-- tasud osaline
			lnStaatus = 2;	
		end if;
	else	
		lnStaatus = 1;
	end if;

	if lnStaatus <> v_dekl.staatus then
		perform sp_muuda_deklstaatus(v_dekl.Id, lnStaatus);
	end if;

return  lnStaatus;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fncDeklStaatus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncDeklStaatus(integer) TO dbpeakasutaja;
