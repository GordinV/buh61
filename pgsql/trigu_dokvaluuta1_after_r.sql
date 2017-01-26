
CREATE OR REPLACE FUNCTION trigu_dokvaluuta1_after_r()
  RETURNS trigger AS
$BODY$
declare
	lcSql text;
	lnUsrID int;
	lnRekvId int;
begin

lcSql:=
	case when old.dokid <> new.dokid then 
		'dokid:' + old.dokid::text + '
'  else ''
	end +
	
	case when old.dokliik <> new.dokliik then 
		'dokliik:' + old.dokliik::text + '
'  else ''
	end +
	
	case when old.valuuta <> new.valuuta then 
		'valuuta:' + old.valuuta::text + '
'  else ''
	end +
	
	case when old.kuurs <> new.kuurs then 
		'kuurs:' + old.kuurs::text + '
'  else ''
	end +
	
	case when old.muud <> new.muud or (IfNull(old.muud,space(1)) <> IfNull(new.muud,space(1))) then 
		'muud:' + case when ifNull(old.muud,space(1)) = space(1) then space(1) + '
'  else old.muud::text + '
'  end else ''
	end;
	SELECT id, rekvid INTO lnUsrID, lnRekvId from userid WHERE kasutaja = CURRENT_USER::VARCHAR;
	INSERT INTO raamat (rekvid,userid,operatsioon,dokument,dokid,sql) 
		VALUES (lnRekvId,lnUsrId,TG_OP::VARCHAR,TG_RELNAME::VARCHAR,new.id,lcSql);
	return null;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigu_dokvaluuta1_after_r() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigu_dokvaluuta1_after_r() TO vlad;
GRANT EXECUTE ON FUNCTION trigu_dokvaluuta1_after_r() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigu_dokvaluuta1_after_r() TO dbpeakasutaja;



CREATE TRIGGER trigu_dokvaluuta1_after_r
  AFTER UPDATE
  ON dokvaluuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigu_dokvaluuta1_after_r();



-- DROP FUNCTION trigd_avans1_after_r();

CREATE OR REPLACE FUNCTION trigd_dokvaluuta1_after_r()
  RETURNS trigger AS
$BODY$
declare
	lcSql text;
	lnUsrID int;
	lnRekvId int;
begin

lcSql:='dokid:' + old.dokid::TEXT + '
' +
	'dokliik:' + old.dokliik::TEXT + '
' +
	'valuuta:' + old.valuuta::TEXT + '
' +
	'kuurs:'+ old.kuurs::TEXT + '
' +
	'muud:' + case when ifnull(old.muud,space(1))<>space(1) then 
		old.muud::TEXT + '
' else ' ' end;
	
	SELECT id, rekvid INTO lnUsrID, lnRekvId from userid WHERE kasutaja = CURRENT_USER::VARCHAR;
	INSERT INTO raamat (rekvid,userid,operatsioon,dokument,dokid,sql) 
		VALUES (lnrekvid,lnUsrId,TG_OP::VARCHAR,TG_RELNAME::VARCHAR,old.id,lcSql);
	return null;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_dokvaluuta1_after_r() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_dokvaluuta1_after_r() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_dokvaluuta1_after_r() TO dbpeakasutaja;

CREATE TRIGGER trigd_dokvaluuta1_after_r
  AFTER DELETE
  ON dokvaluuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_dokvaluuta1_after_r();



CREATE OR REPLACE FUNCTION trigi_dokvaluuta1_after()
  RETURNS trigger AS
$BODY$
declare 
	lnUsrId int;
	lnRekvId int;
begin
	SELECT id, rekvid INTO lnUsrID, lnRekvId from userid WHERE kasutaja = CURRENT_USER::VARCHAR;
	perform sp_register_oper(lnrekvid,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, lnUsrId);
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigi_dokvaluuta1_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigi_dokvaluuta1_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigi_dokvaluuta1_after() TO dbpeakasutaja;


CREATE TRIGGER trigi_dokvaluuta1_after
  AFTER INSERT
  ON dokvaluuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigi_dokvaluuta1_after();

