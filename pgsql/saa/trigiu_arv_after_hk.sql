-- Function: trigiu_arv_after()

-- DROP FUNCTION trigiu_arv_after();

CREATE OR REPLACE FUNCTION trigiu_arv_after_hk()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
	lnisikId integer;
begin
	if not empty(new.lisa) then
		lnIsikId = fnc_LeiaIsikuKood(new.lisa);
		if lnIsikId > 0 then
			-- see on hooarve, teeme kirja uhendus
			if (select count(id) from hoouhendused where isikid = lnIsikId and dokid = new.id) = 0 then
				insert into hoouhendused (isikid, dokid, doktyyp) values (lnIsikId, new.id,'ARVED');
			end if;			
		end if;
	end if;
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;



CREATE TRIGGER trigiu_arv_after_hk
  AFTER INSERT OR UPDATE
  ON arv
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_arv_after_hk();
