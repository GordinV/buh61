CREATE TABLE dokvaluuta1
(
  id serial NOT NULL,
  dokid integer NOT NULL,
  dokliik integer NOT NULL,
  valuuta character varying(20) NOT NULL DEFAULT space(1),
  kuurs numeric(14,4) DEFAULT 1,
  muud text,
  CONSTRAINT dokvaluuta1_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE dokvaluuta1 OWNER TO vlad;
GRANT ALL ON TABLE dokvaluuta1 TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dokvaluuta1 TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dokvaluuta1 TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dokvaluuta1 TO dbadmin;
GRANT SELECT ON TABLE dokvaluuta1 TO dbvaatleja;


CREATE INDEX dokvaluuta1_idx1
  ON dokvaluuta1
  USING btree
  (dokid, dokliik);


