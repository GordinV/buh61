drop table counter cascade;


CREATE TABLE counter
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  kpv date NOT NULL default date(),
  algkogus numeric(14,4) NOT NULL DEFAULT 0,
  loppkogus numeric(14,4) NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT counter_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE counter OWNER TO vlad;
GRANT ALL ON TABLE counter TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE counter TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE counter TO dbkasutaja;
GRANT SELECT ON TABLE counter TO dbadmin;
GRANT SELECT ON TABLE counter TO dbvaatleja;



CREATE INDEX counter_parentid
  ON counter
  USING btree
  (parentid);


GRANT ALL ON TABLE counter_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE counter_id_seq TO GROUP dbpeakasutaja;
