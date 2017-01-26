-- Function: fncdekljaak(integer)

-- DROP FUNCTION fncdekljaak(integer);

CREATE OR REPLACE FUNCTION fncdekljaak(integer)
  RETURNS numeric AS
$BODY$

declare
	tnDeklId alias for $1;

	v_dekl record;

	lnDeklStatus int;
	lnSumma numeric(18,6);
	lnDeklSumma numeric(18,6) = 0;
	lnJaak numeric(18,6);

begin
	-- laekused

	select sum(summa * ifnull(dokvaluuta1.kuurs,1/15.6466)) into lnSumma 
		from dekltasu 
		left outer join dokvaluuta1  on (dokvaluuta1.dokid = dekltasu.deklid and dokliik = 24)
		where deklid = tnDeklId;
	lnSumma = ifnull(lnSumma,0);

	-- deklsumma

	select sum(t.summa * ifnull(dokvaluuta1.kuurs,1/15.6466)) into lnDeklSumma 
		from toiming t
		left outer join dokvaluuta1  on (dokvaluuta1.dokid = t.id and dokliik = 24)
		where t.id = tnDeklId 
		or t.id in (select id from toiming where deklId is not null and deklId = tnDeklId and tyyp = 'PARANDUS');
	
	select toiming.id, toiming.summa as summa, toiming.kpv, toiming.tahtaeg, toiming.staatus, toiming.tyyp,toiming.saadetud,
		ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1/15.6466)::numeric as kuurs into v_dekl 
		from toiming left outer join dokvaluuta1 on (dokvaluuta1.dokid = toiming.id and dokliik = 24)
		where toiming.Id  =  tnDeklId ;

	if lnDeklSumma is not null then
		v_dekl.summa = lnDeklSumma;
	end if;


	-- Jaak	
	lnJaak = round((v_dekl.summa * v_dekl.kuurs - lnSumma ),2);

	RAISE NOTICE 'v_dekl.id  %,v_dekl.valuuta %, v_dekl.kuurs %, v_dekl.summa %, lnSumma %, lnJaak %',v_dekl.id, v_dekl.valuuta, v_dekl.kuurs, v_dekl.summa, lnSumma, lnJaak;

	if v_dekl.tyyp = 'TASU' then
		lnJaak = 0;
	end if;
	if (v_dekl.tyyp = 'DEKL' and empty(v_dekl.saadetud)) then
		lnJaak = 0;
	end if;
return  lnJaak;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION fncdekljaak(integer)
  OWNER TO vlad;
