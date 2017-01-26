-- Table: ettemaksud

-- DROP TABLE ettemaksud;

CREATE TABLE ettemaksud
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  kpv date NOT NULL,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  "number" integer NOT NULL DEFAULT 0,
  asutusid integer NOT NULL,
  dokid integer NOT NULL,
  doktyyp integer NOT NULL DEFAULT 1,
  selg text,
  muud text,
  staatus integer NOT NULL DEFAULT 1,
  journalid integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ettemaksud OWNER TO postgres;
GRANT ALL ON TABLE ettemaksud TO postgres;
GRANT ALL ON TABLE ettemaksud TO dbkasutaja;
GRANT ALL ON TABLE ettemaksud TO dbpeakasutaja;
GRANT SELECT, REFERENCES, TRIGGER ON TABLE ettemaksud TO dbvaatleja;


-- Sequence: ettemaksud_id_seq

-- DROP SEQUENCE ettemaksud_id_seq;

CREATE SEQUENCE ettemaksud_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 16
  CACHE 1;
ALTER TABLE ettemaksud_id_seq OWNER TO postgres;
GRANT ALL ON TABLE ettemaksud_id_seq TO postgres;
GRANT SELECT, USAGE ON TABLE ettemaksud_id_seq TO public;
GRANT ALL ON TABLE ettemaksud_id_seq TO dbkasutaja;
GRANT ALL ON TABLE ettemaksud_id_seq TO dbpeakasutaja;
