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

ALTER TABLE dokvaluuta1_id_seq OWNER TO vlad;
GRANT ALL ON TABLE dokvaluuta1_id_seq TO vlad;
GRANT ALL ON TABLE dokvaluuta1_id_seq TO public;

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



ALTER TABLE valuuta1_id_seq OWNER TO vlad;
GRANT ALL ON TABLE valuuta1_id_seq TO vlad;
GRANT ALL ON TABLE valuuta1_id_seq TO public;

/*
CREATE ROLE saldoandmikkoostaja
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;


ALTER TABLE pv_kaart ADD COLUMN jaak numeric(14,2);
ALTER TABLE pv_kaart ALTER COLUMN jaak SET DEFAULT 0;

*/
ALTER TABLE raamat ADD COLUMN sql text;


