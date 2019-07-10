
--drop table arv_bpm cascade;

CREATE TABLE arv_bpm
(
  id serial NOT NULL,
  arvid integer NOT NULL,
  lastupd date NOT NULL DEFAULT date(),
  kpv date,
  isik varchar(254),
  rolli varchar(254),
  muud text,
  CONSTRAINT arv2_pkey_ PRIMARY KEY (id)
)
WITH (OIDS=FALSE);

GRANT ALL ON TABLE arv_bpm TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE arv_bpm TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE arv_bpm TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE arv_bpm TO ladukasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE arv_bpm TO dbadmin;
GRANT SELECT ON TABLE arv_bpm TO dbvaatleja;


-- Index: arv2_arvid

-- DROP INDEX arv2_arvid;

CREATE INDEX arv_bpm_arvid
  ON arv_bpm
  USING btree
  (arvid);

 GRANT ALL ON TABLE arv_bpm_id_seq TO public;
 

