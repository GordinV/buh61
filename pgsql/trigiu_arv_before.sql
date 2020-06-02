-- Function: trigiu_arv_before()

-- DROP FUNCTION trigiu_arv_before();

CREATE OR REPLACE FUNCTION trigiu_arv_before()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	lnUserid = sp_currentuser(current_user::varchar, new.rekvid);
	select * into v_userid from userid where id = lnUserid;
	if v_userid.kasutaja_ = 0 and v_userid.peakasutaja_ = 0 then
			raise exception 'Ei ole õigused lisada/muudata/kustuta';
			return null;
	end if;

	 -- tahtaeg
	 
	if new.tahtaeg is null or empty(new.tahtaeg) then
		new.tahtaeg = new.kpv + 5;
	end if;
	return new;


	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_arv_before() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO public;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO taabel;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO dbvanemtasu;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_arv_before() TO dbpeakasutaja;
