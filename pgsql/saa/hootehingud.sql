--drop table hootehingud;

CREATE TABLE hootehingud
(
   id serial NOT NULL, 
   isikid integer NOT NULL DEFAULT 0, 
   ettemaksid integer NOT NULL DEFAULT 0 , 
   journalid  integer NOT NULL DEFAULT 0,
   dokid integer NOT NULL DEFAULT 0  ,
   doktyyp character varying(20)  ,
   kpv date not null,
   summa numeric(18,6) NOT NULL DEFAULT 0, 
   allikas character varying(20) NOT NULL, 
   tyyp character varying(20) NOT NULL, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   muud text, 
    CONSTRAINT hootehingud_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

COMMENT ON COLUMN hootehingud.ettemaksid IS 'seotud ettemaksu kandega';
COMMENT ON COLUMN hootehingud.dokid IS 'seotud dokumendiga';
COMMENT ON COLUMN hootehingud.doktyyp IS 'kui dokid > 0, doktyyp = KASSA,PANK, ARVE';

CREATE INDEX hootehingud_isikid
  ON hootehingud
  USING btree
  (isikid);

ALTER TABLE hootehingud CLUSTER ON hootehingud_isikid;

CREATE INDEX hootehingud_ettemaksid
  ON hootehingud
  USING btree
  (ettemaksid);


CREATE INDEX hootehingud_journalid
  ON hootehingud
  USING btree
  (journalid);

CREATE INDEX hootehingud_dokid
  ON hootehingud
  USING btree
  (doktyyp,dokid);


GRANT ALL ON TABLE hootehingud TO GROUP hkametnik;
GRANT ALL ON TABLE hootehingud TO GROUP soametnik;


