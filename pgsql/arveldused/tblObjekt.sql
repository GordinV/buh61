
CREATE TABLE objekt
(
  id serial NOT NULL,
  libid integer NOT NULL,
  asutusid integer NOT NULL,
  parentid integer NOT NULL,
  nait01 numeric(14,4) NOT NULL DEFAULT 0,
  nait02 numeric(14,4) NOT NULL DEFAULT 0,
  nait03 numeric(14,4) NOT NULL DEFAULT 0,
  nait04 numeric(14,4) NOT NULL DEFAULT 0,
  nait05 numeric(14,4) NOT NULL DEFAULT 0,
  nait06 numeric(14,4) NOT NULL DEFAULT 0,
  nait07 numeric(14,4) NOT NULL DEFAULT 0,
  nait08 numeric(14,4) NOT NULL DEFAULT 0,
  nait09 numeric(14,4) NOT NULL DEFAULT 0,
  nait10 numeric(14,4) NOT NULL DEFAULT 0,
  nait11 numeric(14,4) NOT NULL DEFAULT 0,
  nait12 numeric(14,4) NOT NULL DEFAULT 0,
  nait13 numeric(14,4) NOT NULL DEFAULT 0,
  nait14 numeric(14,4) NOT NULL DEFAULT 0,
  nait15 numeric(14,4) NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT objekt_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE objekt OWNER TO vlad;
GRANT ALL ON TABLE objekt TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE objekt TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE objekt TO dbkasutaja;
GRANT SELECT ON TABLE objekt TO dbadmin;
GRANT SELECT ON TABLE objekt TO dbvaatleja;


CREATE INDEX objekt_parentid
  ON objekt
  USING btree
  (parentid);

CREATE INDEX objekt_libid
  ON objekt
  USING btree
  (libid);

CREATE INDEX objekt_asutusid
  ON objekt
  USING btree
  (asutusid);


GRANT ALL ON TABLE objekt_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE objekt_id_seq TO GROUP dbpeakasutaja;
