-- Function: trigi_palk_oper_before()

-- DROP FUNCTION trigi_palk_oper_before();

CREATE OR REPLACE FUNCTION trigi_palk_oper_before()
  RETURNS trigger AS
$BODY$
declare 
	ldLopp date;
	n_liik integer;
begin

	if empty (new.kpv) or empty (new.libId) or empty (new.lepingId)   then
		raise notice ' Puudub andmed';
		return null;
	end if;
	
	select lopp into ldLopp from tooleping where id = new.lepingId;
	if ifnull(ldLopp,new.kpv) < new.kpv then
		raise notice ' Tooleping on loppetatud';
		return null;
	end if;

	if new.summa <> 0 then
		select liik into n_liik from palk_lib where parentId = new.libId;
		if n_liik = 5 and coalesce(new.sotsmaks ,0) <> 0  then
			raise notice 'sotsmaks min. palgagast.';
		else 	
			perform sp_check_twins(new.kpv, new.libId, new.lepingId, new.id);
		
		end if;
	end if;
	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigi_palk_oper_before() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO vlad;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO public;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO dbadmin;
GRANT EXECUTE ON FUNCTION trigi_palk_oper_before() TO dbvaatleja;
