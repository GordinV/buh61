-- Table: hooldaja

-- DROP TABLE hooldaja;

CREATE TABLE hoojaak
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  pension85 numeric(16,2) not null default 0,
  pension15 numeric(16,2) not null default 0,
  toetus numeric(16,2) not null default 0,
  vara numeric(16,2) not null default 0,
  omavalitsus numeric(16,2) not null default 0,
  laen numeric(16,2) not null default 0,
  muud numeric(16,2) not null default 0,

  CONSTRAINT hoojaak_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hoojaak OWNER TO vlad;
GRANT ALL ON TABLE hoojaak TO hkametnik;
GRANT ALL ON TABLE hoojaak TO soametnik;


-- Index: hooldaja_isikid

-- DROP INDEX hooldaja_isikid;

CREATE INDEX hoojaak_isikid
  ON hoojaak
  USING btree
  (isikid);


GRANT ALL ON TABLE hoojaak_id_seq TO GROUP hkametnik;
GRANT ALL ON TABLE hoojaak_id_seq TO GROUP soametnik;
  

