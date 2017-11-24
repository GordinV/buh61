CREATE OR REPLACE FUNCTION trigiu_hoouhendused_after()
  RETURNS trigger AS
$BODY$

declare 
	lnAsutusId int;

begin
	if new.doktyyp = 'ARVED' then
		select asutusId into lnAsutusId from arv where id = new.dokid;
		lnAsutusid = ifnull(lnAsutusId,0);
		if lnAsutusId > 0 then
			perform sp_arvesta_hoolepingujaak(lnAsutusId, new.isikId);
		end if;
	end if;

	return null;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_hoouhendused_after() OWNER TO vlad;



CREATE TRIGGER trigiu_hoouhendused_after
  AFTER INSERT OR UPDATE
  ON hoouhendused
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_hoouhendused_after();

/*
select * from hoouhendused

update  hoouhendused set isikid = 3 where isikid = 3

*/