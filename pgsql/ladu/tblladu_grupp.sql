-- Table: ladu_grupp

ALTER TABLE ladu_grupp ADD COLUMN staatus integer;
ALTER TABLE ladu_grupp ALTER COLUMN staatus SET STORAGE PLAIN;
update ladu_grupp set staatus = 0;
ALTER TABLE ladu_grupp ALTER COLUMN staatus SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN staatus SET DEFAULT 0;


/*
 DROP TABLE ladu_grupp;

CREATE TABLE ladu_grupp
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  nomid integer NOT NULL DEFAULT 0,
  "valid" date,
  kalor integer NOT NULL DEFAULT 0,
  sahharid integer NOT NULL DEFAULT 0,
  rasv integer NOT NULL DEFAULT 0,
  vailkaine integer NOT NULL DEFAULT 0,
  staatus integer NOT NULL DEFAULT 0,
  CONSTRAINT ladu_grupp_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ladu_grupp OWNER TO vlad;
GRANT ALL ON TABLE ladu_grupp TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO dbadmin;
GRANT SELECT ON TABLE ladu_grupp TO dbvaatleja;

-- Index: ix_ladu_grupp

-- DROP INDEX ix_ladu_grupp;

CREATE INDEX ix_ladu_grupp
  ON ladu_grupp
  USING btree
  (parentid);

-- Index: ix_ladu_grupp_1

-- DROP INDEX ix_ladu_grupp_1;

CREATE INDEX ix_ladu_grupp_1
  ON ladu_grupp
  USING btree
  (nomid);


-- Trigger: trigd_ladu_grupp_after_r on ladu_grupp

-- DROP TRIGGER trigd_ladu_grupp_after_r ON ladu_grupp;

CREATE TRIGGER trigd_ladu_grupp_after_r
  AFTER DELETE
  ON ladu_grupp
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_ladu_grupp_after_r();

-- Trigger: trigd_ladu_grupp_before on ladu_grupp

-- DROP TRIGGER trigd_ladu_grupp_before ON ladu_grupp;

CREATE TRIGGER trigd_ladu_grupp_before
  BEFORE DELETE
  ON ladu_grupp
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_ladu_grupp_before();

-- Trigger: trigu_ladu_grupp_after_r on ladu_grupp

-- DROP TRIGGER trigu_ladu_grupp_after_r ON ladu_grupp;

CREATE TRIGGER trigu_ladu_grupp_after_r
  AFTER UPDATE
  ON ladu_grupp
  FOR EACH ROW
  EXECUTE PROCEDURE trigu_ladu_grupp_after_r();

*/