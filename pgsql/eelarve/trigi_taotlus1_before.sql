-- Function: trigiu_taotlus1_after()

-- DROP FUNCTION trigiu_taotlus1_after();

CREATE OR REPLACE FUNCTION trigi_taotlus1_before()
  RETURNS trigger AS
$BODY$
	
begin
	IF new.eelarveId > 0 then
		new.eelarveId = 0;
	end if;
	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigi_taotlus1_before() OWNER TO vlad;




CREATE TRIGGER trigi_taotlus1_before
  BEFORE INSERT 
  ON taotlus1
  FOR EACH ROW
  EXECUTE PROCEDURE trigi_taotlus1_before();
