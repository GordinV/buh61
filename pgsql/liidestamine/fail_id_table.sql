-- Table: arv_bpm

-- DROP TABLE arv_bpm;

CREATE TABLE fail_id
(
  id serial NOT NULL,
  fail_id integer,
  dok_id integer,
  rekvid integer,
  kpv date NOT NULL DEFAULT date(),
  kasutaja_id integer,
  muud text,
  CONSTRAINT fail_id_pkey_ PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE fail_id OWNER TO vlad;
GRANT ALL ON TABLE fail_id TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE fail_id TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE fail_id TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE fail_id TO ladukasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE fail_id TO dbadmin;
GRANT SELECT ON TABLE fail_id TO dbvaatleja;

GRANT ALL ON TABLE fail_id_id_seq TO public;


 DROP INDEX if exists fail_id_dokid;

CREATE INDEX fail_id_dokid
  ON fail_id
  USING btree
  (dok_id);

