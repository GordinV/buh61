-- Function: sp_muuda_deklstaatus(integer, integer)

-- DROP FUNCTION sp_muuda_deklstaatus(integer, integer);

CREATE OR REPLACE FUNCTION sp_muuda_deklstaatus(integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnStaatus alias for $2;
	v_toiming record;
	lndekltasu numeric(12,2);
	lnResult int; 
begin
	lnresult = tnStaatus;
	raise notice 'status: %',tnStaatus;

	select * into v_toiming from toiming where id = tnId;

	if tnStaatus = 3 and empty(v_toiming.saadetud) then
		-- tasud but nor deklared
		lnResult = 1;
	end if;
	if tnStaatus = 1 and not empty(v_toiming.saadetud) then
		-- check for tasu
		select sum(summa) into lndekltasu from dekltasu where deklid = tnId;
		if ifnull(lnDeklTasu,0) > 0 then
			if lnDekltasu < v_toiming.summa then
				-- osamaks
				lnresult = 2;
			end if;
			if lnDekltasu >= v_toiming.summa then
				-- loppmaks
				lnresult = 3;
			end if;
		end if;
 
	end if;
	update toiming set staatus = lnResult where id = tnid;


return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_muuda_deklstaatus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_muuda_deklstaatus(integer, integer) TO dbpeakasutaja;
