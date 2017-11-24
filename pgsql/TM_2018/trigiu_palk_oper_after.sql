-- Function: trigiu_palk_oper_after()

--DROP FUNCTION if exists trigiu_palk_oper_after();

CREATE OR REPLACE FUNCTION trigiu_palk_oper_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	-- muudetud 18/02/2005
	if year(new.kpv) > 2005 then
		perform sp_register_oper(new.rekvid,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, new.rekvid));
	end if;
	perform recalc_palk_saldo(new.lepingId, month(new.kpv)::smallint, year(new.kpv)::smallint);	
--	perform sp_update_palk_jaak(date(year(new.kpv), month(new.kpv), 1), godate(year(new.kpv), month(new.kpv), 1), new.rekvid, new.lepingId);

	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
