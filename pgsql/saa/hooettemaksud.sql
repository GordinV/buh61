--drop table hootehingud;

CREATE TABLE hooettemaksud
(
  id serial NOT NULL,
  isikid integer NOT NULL default 0,
  kpv date NOT NULL,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  dokid integer NOT NULL default 0,
  doktyyp character varying(20) NOT NULL DEFAULT space(20),
  selg text,
  muud text,
  staatus integer NOT NULL DEFAULT 1,
  CONSTRAINT hooettemaksud_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

COMMENT ON COLUMN hooettemaksud.doktyyp IS 'kui dokid > 0, doktyyp = LAUSEND,KASSA,PANK';
COMMENT ON COLUMN hooettemaksud.staatus IS '0 - klassifitseeritud, 1 - klassifitseerimata';

CREATE INDEX hooettemaksud_isikid
  ON hooettemaksud
  USING btree
  (isikid);

ALTER TABLE hooettemaksud CLUSTER ON hooettemaksud_isikid;


CREATE INDEX hooettemaksud_dokid
  ON hooettemaksud
  USING btree
  (doktyyp,dokid);


GRANT ALL ON TABLE hooettemaksud TO GROUP hkametnik;
GRANT ALL ON TABLE hooettemaksud TO GROUP soametnik;


