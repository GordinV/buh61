CREATE OR REPLACE FUNCTION trigd_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(old.rekvid, old.kpv)= 0) then
--			raise notice 'Viga: Perion on kinnitatud';
			raise exception 'Viga: Perion on kinnitatud';
--			return null;
	end if;

	return old;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_aasta_insert() TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION trigd_arv1_after()
  RETURNS trigger AS
$BODY$
declare
lnId		int;
recArv		record; 
begin
	select id into lnId from ladu_grupp where ladu_grupp.nomId = old.nomId;
	if not found then
		return null;
	end if;
	select * into recArv from arv where id = old.parentId;

--	if recArv.operId > 0  and recArv.liik = 1 then
	-- vara sisetulik
--		delete from ladu_jaak where dokItemId = old.id;
--	else
		perform sp_recalc_ladujaak(recArv.rekvId, old.nomId, 0);
--	end if;	

	-- kustutan valuuta info

	delete from dokvaluuta1 where dokid = old.id and dokliik = 2;

	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_arv1_after() OWNER TO vlad;

drop trigger trigd_arv1_after on arv1;

CREATE TRIGGER trigd_arv1_after
  AFTER DELETE
  ON arv1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_arv1_after();



CREATE OR REPLACE FUNCTION trigd_arved_after()
  RETURNS trigger AS
$BODY$
declare 
	lnCount int4;
	

begin
--	lnCount:=sp_recalc_ladujaak(old.RekvId,0,old.Id);


	IF old.JournalId > 0 then

		  lnCount:= sp_del_journal(old.journalId,1);

	end if;
	-- kustutan valuuta infot;
	delete from dokvaluuta1 where dokid = old.id and dokliik = 3;
	
	perform sp_register_oper(old.rekvid,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, old.rekvid));
	return NULL;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_arved_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbadmin;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbvaatleja;



CREATE OR REPLACE FUNCTION trigd_journal1_after()
  RETURNS trigger AS
$BODY$
declare 
	v_journal record;
begin

	select * into v_journal from journal where id = old.parentid;

	delete from dokvaluuta1 where dokid = old.id and dokliik = 1;
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_journal1_after() OWNER TO vlad;


drop trigger trigd_journal1_after on journal1;

CREATE TRIGGER trigd_journal1_after
  AFTER DELETE
  ON journal1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_journal1_after();



CREATE OR REPLACE FUNCTION trigiu_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(new.rekvid, new.kpv)= 0) then
			raise exception 'Viga:Perion on kinnitatud';
			return null;
	end if;

	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_aasta_insert() TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION trigiu_journal1_before()
  RETURNS trigger AS
$BODY$
declare 
	lnKuu int;
	lnAasta int;
	lnRekvId int;
	lcTP varchar(20);
	lnKinni int;
	lcViga text;
	ldKpv date;
begin
	
	select  rekvId,kpv into lnRekvid,ldKpv from journal where id = new.parentid;

-- otsin oma TP kood
	SELECT TP INTO lcTp FROM Aa WHERE Aa.parentid = lnRekviD   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
	lcTp = ifnull(lcTp,'');
/*
	select kinni into lnKinni from aasta where kuu = lnKuu and aasta = lnAasta 
			and rekvid = lnrekvId ;
		lnKinni :=ifnull(lnkinni,0);
		if lnKinni = 1 then
	 		raise exception 'Period on kinnitatud';
	        return null;	
*/

	if empty(new.deebet) then
 		raise exception 'Viga: Puudub vajalikud andmed: deebet';
	        return null;	
	end if;
	if empty (new.kreedit) then
 		raise exception 'Viga: Puudub vajalikud andmed: kreedit';
	        return null;	
        end if;		
-- lausendi kontrol

	lcViga = sp_lausendikontrol(new.deebet, new.kreedit, new.lisa_d, new.lisa_k, new.kood1, new.kood2, new.kood5, new.kood3, lcTP, ldkpv);
	if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
		raise exception ':%',lcViga;
	end if;


	return new;
	
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_journal1_before() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO public;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION trigu_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(old.rekvid, old.kpv)= 0) then
			raise exception 'Viga: Perion on kinnitatud';
			return null;
	end if;

	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigu_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION trigiu_journal1_before()
  RETURNS trigger AS
$BODY$
declare 
	lnKuu int;
	lnAasta int;
	lnRekvId int;
	lcTP varchar(20);
	lnKinni int;
	lcViga text;
	ldKpv date;
begin
	
	select  rekvId,kpv into lnRekvid,ldKpv from journal where id = new.parentid;

-- otsin oma TP kood
	SELECT TP INTO lcTp FROM Aa WHERE Aa.parentid = lnRekviD   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
	lcTp = ifnull(lcTp,'');
/*
	select kinni into lnKinni from aasta where kuu = lnKuu and aasta = lnAasta 
			and rekvid = lnrekvId ;
		lnKinni :=ifnull(lnkinni,0);
		if lnKinni = 1 then
	 		raise exception 'Period on kinnitatud';
	        return null;	
*/

	if empty(new.deebet) then
 		raise exception 'Viga: Puudub vajalikud andmed: deebet';
	        return null;	
	end if;
	if empty (new.kreedit) then
 		raise exception 'Viga: Puudub vajalikud andmed: kreedit';
	        return null;	
        end if;		
-- lausendi kontrol

	lcViga = sp_lausendikontrol(new.deebet, new.kreedit, new.lisa_d, new.lisa_k, new.kood1, new.kood2, new.kood5, new.kood3, lcTP, ldkpv);
	if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
		raise exception ':%',lcViga;
	end if;


	return new;
	
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_journal1_before() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO public;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION trigu_aasta_insert()
  RETURNS trigger AS
$BODY$
declare 
	lresult int;
	lcNotice varchar;
	lnuserId int4;
begin

	if (fnc_aasta_kontrol(old.rekvid, old.kpv)= 0) then
			raise exception 'Viga: Perion on kinnitatud';
			return null;
	end if;

	return new;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigu_aasta_insert() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO vlad;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO public;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigu_aasta_insert() TO dbpeakasutaja;



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




CREATE OR REPLACE FUNCTION trigu_valuuta1_after_r()
  RETURNS trigger AS
$BODY$
declare
	lcSql text;
	lnUsrID int;
	lnRekvId int;
begin

lcSql:=
	case when old.parentid <> new.parentid then 
		'parentid:' + old.parentid::text + '
'  else ''
	end +
		
	case when old.kuurs <> new.kuurs then 
		'kuurs:' + old.kuurs::text + '
'  else ''
	end +
		
	case when old.alates <> new.alates then 
		'alates:' + old.alates::text + '
'  else ''
	end +

	case when old.kuni <> new.kuni then 
		'Kuni:' + old.kuni::text + '
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
ALTER FUNCTION trigu_valuuta1_after_r() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigu_valuuta1_after_r() TO vlad;
GRANT EXECUTE ON FUNCTION trigu_valuuta1_after_r() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigu_valuuta1_after_r() TO dbpeakasutaja;



CREATE TRIGGER trigu_valuuta1_after_r
  AFTER UPDATE
  ON valuuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigu_valuuta1_after_r();



-- DROP FUNCTION trigd_avans1_after_r();

CREATE OR REPLACE FUNCTION trigd_valuuta1_after_r()
  RETURNS trigger AS
$BODY$
declare
	lcSql text;
	lnUsrID int;
	lnRekvId int;
begin

lcSql:='parentid:' + old.parentid::TEXT + '
' +
	'kuurs:'+ old.kuurs::TEXT + '
' +
	'alates:'+ old.alates::TEXT + '
' +
	'kuni:'+ old.kuni::TEXT + '
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
ALTER FUNCTION trigd_valuuta1_after_r() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_valuuta1_after_r() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_valuuta1_after_r() TO dbpeakasutaja;

CREATE TRIGGER trigd_valuuta1_after_r
  AFTER DELETE
  ON valuuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_valuuta1_after_r();



CREATE OR REPLACE FUNCTION trigi_valuuta1_after()
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
ALTER FUNCTION trigi_valuuta1_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigi_valuuta1_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigi_valuuta1_after() TO dbpeakasutaja;


CREATE TRIGGER trigi_valuuta1_after
  AFTER INSERT
  ON valuuta1
  FOR EACH ROW
  EXECUTE PROCEDURE trigi_valuuta1_after();

