
CREATE TABLE pakett
(
  id serial NOT NULL,
  libid integer NOT NULL,
  nomid integer NOT NULL,
  hind numeric(14,4) NOT NULL DEFAULT 0,
  status integer DEFAULT 1 NOT NULL,
  formula text,
  CONSTRAINT pakett_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pakett OWNER TO vlad;
GRANT ALL ON TABLE pakett TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE pakett TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE pakett TO dbkasutaja;
GRANT SELECT ON TABLE pakett TO dbadmin;
GRANT SELECT ON TABLE pakett TO dbvaatleja;


CREATE INDEX pakett_nomid
  ON pakett
  USING btree
  (nomid);

CREATE INDEX pakett_libid
  ON pakett
  USING btree
  (libid);


GRANT ALL ON TABLE pakett_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE pakett_id_seq TO GROUP dbpeakasutaja;
