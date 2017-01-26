-- Table: config_

-- DROP TABLE config_;

CREATE TABLE config_
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  userid integer NOT NULL,
  keel integer NOT NULL DEFAULT 1,
  toolbar1 integer NOT NULL DEFAULT 0,
  toolbar2 integer NOT NULL DEFAULT 0,
  toolbar3 integer NOT NULL DEFAULT 0,
  uuenda integer NOT NULL DEFAULT 1,
  register integer NOT NULL DEFAULT 1,
  encr integer NOT NULL DEFAULT 0,
  "number" character varying(20) NOT NULL DEFAULT space(1),
  arvround numeric(5,2) NOT NULL DEFAULT 0.1,
  viga character varying(254) NOT NULL DEFAULT 'raama.vigad@avpsoft.ee'::character varying,
  www character varying(254) NOT NULL DEFAULT 'http://www.avpsoft.ee/downloads/buh50/uuendus.dbf'::character varying,
  asutusid integer NOT NULL DEFAULT 0,
  CONSTRAINT config__pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE config_ OWNER TO vlad;
GRANT ALL ON TABLE config_ TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE config_ TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE config_ TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE config_ TO dbadmin;
GRANT SELECT ON TABLE config_ TO dbvaatleja;


ALTER TABLE config_ ADD COLUMN tahtpaev integer DEFAULT 0;
ALTER TABLE config_ ADD COLUMN www1 character varying(254) DEFAULT '';
