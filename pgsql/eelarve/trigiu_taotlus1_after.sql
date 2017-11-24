-- Function: trigiu_taotlus1_after()

-- DROP FUNCTION trigiu_taotlus1_after();

CREATE OR REPLACE FUNCTION trigiu_taotlus1_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	ldKpv date;
	lresult int;
	lcNotice varchar;
	lnKuurs numeric(16,4);
	lcValuuta varchar(20);
	lnId integer;
	lnRekvid integer;
	
begin
	
	select kpv, Rekvid into ldKpv, lnrekvId from taotlus where id = new.parentid;
	lcValuuta = fnc_currentvaluuta(ldKpv);
	lnKuurs = fnc_currentkuurs(ldKpv);

	select id into lnId from dokvaluuta1 where dokid = new.id and dokliik = 14;
	lnId = ifnull(lnId,0);

	if lnId = 0 then
		-- puudub, salvesta
		insert into dokvaluuta1 (dokid, dokliik, valuuta,kuurs, muud) values (new.id, 27, lcValuuta, lnKuurs, 'trigiu_taotlus1_after');
	else
		update dokvaluuta1 set 
			valuuta = lcValuuta,
			kuurs = lnKuurs
			where id = lnId;
	end if;

	perform sp_register_oper(lnrekvId,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, lnrekvId));
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_taotlus1_after() OWNER TO vlad;
