


CREATE OR REPLACE FUNCTION trigd_holidays_after()
  RETURNS "trigger" AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	v_rekv record;
	lnid int;
	lnLibId int;
begin
	raise notice 'START';


	if old.rekvid = 119 then
		for v_rekv in 
			select id from rekv where parentid = 119 
		loop
			raise notice 'v_rekv.nimetus %',v_rekv.nimetus;
			delete from holidays 
				where paev = old.paev 
				and kuu = old.kuu
				and rekvid = v_rekv.id;

		end loop;


	end if;
	return null;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;


CREATE TRIGGER trigd_holidays_after
  AFTER DELETE
  ON holidays
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_holidays_after();
