
drop table if exists taotlus_mvt;

CREATE TABLE taotlus_mvt
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  userid integer NOT NULL,
  kpv date NOT NULL,
  alg_kpv date NOT NULL,
  lopp_kpv date NOT NULL,
  lepingid integer NOT NULL,
  summa numeric(14,4) NOT NULL default 0,
  muud text,
  CONSTRAINT taotlus_mvt_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
GRANT SELECT ON TABLE taotlus TO dbvaatleja;
GRANT ALL ON TABLE taotlus TO dbpeakasutaja;
GRANT SELECT, INSERT, UPDATE ON TABLE taotlus TO dbkasutaja;

drop index if exists taotlus_mvt_rekvid;

CREATE INDEX taotlus_mvt_rekvid
  ON taotlus_mvt
  USING btree
  (rekvid);

drop index if exists taotlus_mvt_lepingid;

CREATE INDEX taotlus_mvt_lepingid
  ON taotlus_mvt
  USING btree
  (lepingid);

drop index if exists taotlus_mvt_kpv;

CREATE INDEX taotlus_mvt_kpv
  ON taotlus_mvt
  USING btree
  (alg_kpv, lopp_kpv);

drop function if exists trigd_taotlus_mvt_after();

CREATE OR REPLACE FUNCTION trigd_taotlus_mvt_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(0,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

drop function if exists trigiu_taotlus_mvt_after();

CREATE OR REPLACE FUNCTION trigiu_taotlus_mvt_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(0,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

drop trigger if exists trigd_taotlus_mvt_after ON taotlus_mvt;

CREATE TRIGGER trigd_taotlus_mvt_after
  AFTER DELETE
  ON taotlus_mvt
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_taotlus_mvt_after();

drop trigger if exists trigiu_taotlus_mvt_after ON taotlus_mvt;

CREATE TRIGGER trigiu_taotlus_mvt_after
  AFTER INSERT OR UPDATE
  ON taotlus_mvt
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_taotlus_mvt_after();
