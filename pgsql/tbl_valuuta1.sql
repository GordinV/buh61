CREATE TABLE valuuta1
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  kuurs numeric(14,4) DEFAULT 1,
  alates date not null,
  kuni date not null,
  muud text,
  CONSTRAINT valuuta1_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE valuuta1 OWNER TO vlad;
GRANT ALL ON TABLE valuuta1 TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE valuuta1 TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE valuuta1 TO dbkasutaja;
GRANT SELECT ON TABLE valuuta1 TO dbvaatleja;


CREATE INDEX valuuta1_idx1
  ON valuuta1
  USING btree
  (parentid);



