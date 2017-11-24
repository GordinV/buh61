-- Table: hootehingud

-- DROP TABLE hootehingud;

CREATE TABLE hoouhendused
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  dokid integer NOT NULL DEFAULT 0, -- seotud dokumendiga
  doktyyp character varying(20), -- kui dokid > 0, doktyyp = KASSA,PANK, ARVE
  CONSTRAINT hoouhendused_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hoouhendused OWNER TO vlad;
GRANT ALL ON TABLE hootehingud TO hkametnik;
GRANT ALL ON TABLE hootehingud TO soametnik;


-- Index: hootehingud_dokid

-- DROP INDEX hootehingud_dokid;

CREATE INDEX hoouhendused_dokid
  ON hoouhendused
  USING btree
  (doktyyp, dokid);


CREATE INDEX hoouhendused_isikid
  ON hoouhendused
  USING btree
  (isikid);

ALTER TABLE hoouhendused CLUSTER ON hoouhendused_isikid;


GRANT ALL ON TABLE hoouhendused_id_seq TO public;


