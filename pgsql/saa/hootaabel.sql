-- Table: hooettemaksud

-- DROP TABLE hooettemaksud;

CREATE TABLE hootaabel
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  nomid integer not null default 0,
  kpv date NOT NULL,
  kogus numeric(18,4) NOT NULL DEFAULT 0,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  arvid integer NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT hootaabel_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE hootaabel TO hkametnik;
GRANT ALL ON TABLE hootaabel TO soametnik;


CREATE INDEX hootaabel_arvid
  ON hootaabel
  USING btree
  (arvid);

CREATE INDEX hootaabel_nomid
  ON hootaabel
  USING btree
  (nomid);

-- Index: hooettemaksud_isikid

-- DROP INDEX hooettemaksud_isikid;

CREATE INDEX hootaabel_isikid
  ON hootaabel
  USING btree
  (isikid);
ALTER TABLE hootaabel CLUSTER ON hootaabel_isikid;

GRANT ALL ON TABLE hootaabel_id_seq TO GROUP soametnik;
GRANT ALL ON TABLE hootaabel_id_seq TO GROUP hkametnik;


