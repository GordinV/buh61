-- Function: trigd_palk_oper_after()

-- DROP FUNCTION trigd_palk_oper_after();

CREATE OR REPLACE FUNCTION trigd_palk_oper_after()
  RETURNS trigger AS
$BODY$
declare 
	curDokId record;	

	lnLiik int;

begin

IF old.Journalid > 0 then

	perform sp_del_journal(old.Journalid::int4,1::int4);

end if;

perform sp_update_palk_jaak(old.kpv, old.kpv, old.rekvid, old.lepingId);
--perform recalc_palk_saldo(old.lepingId::int4,month(old.kpv)::int2);

select liik into lnLiik from palk_lib where parentid = old.libid;

If lnliik = 6 then

	select * into curDokId from (

		select id as dokid, tyyp as doktyyp, dokid as parentid, doktyyp as parenttyyp 

		from korder1 where dokid >= old.Id 

		union 

		select id as dokid, 3 as doktyyp, dokid as parentid, doktyyp as parenttyyp 

		from MK  where dokid >= old.Id ) a;



	If found then 

		IF curdokid.doktyyp = 3 then

			perform sp_del_mk1(curdokid.dokid,1);

		ELSE

			perform sp_del_korderid(curdokid.dokid,1);

		END IF;		

	END IF;

END IF;
perform sp_register_oper(old.rekvid,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, old.rekvid));

return null;



end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_palk_oper_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbadmin;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbvaatleja;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO taabel;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbvanemtasu;
