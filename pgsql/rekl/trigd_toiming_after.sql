-- Function: trigd_toiming_after()

-- DROP FUNCTION trigd_toiming_after();

CREATE OR REPLACE FUNCTION trigd_toiming_after()
  RETURNS trigger AS
$BODY$
declare 
	lnCount int4;
	lnSumma numeric(12,2);
	lnStaatus int;
begin

	if old.tyyp = 'TASU' then
		if (select count(*) from dekltasu where tasuid = old.id) > 0 then
			raise notice 'kustame tasu info';
			delete from dekltasu where tasuid = old.id;
			delete from ettemaksud where dokid = old.id;
			perform sp_recalc_rekljaak(old.lubaId); 
			perform fncReklEttemaksStaatusRecalc(old.parentid);
		end if;
	end if;
	if old.tyyp = 'ANULLERI' then
		select staatus into lnStaatus from luba where id = old.lubaid;
		if ifnull(lnStaatus,0) = 0 then
			perform sp_muuda_lubastaatus(old.lubaid, 1);
		end if;
	end if;
	perform sp_register_oper(0,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));

	return NULL;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_toiming_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO taabel;
GRANT EXECUTE ON FUNCTION trigd_toiming_after() TO dbvanemtasu;
