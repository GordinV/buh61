--DROP TABLE hooleping

CREATE TABLE hooleping
(
   id serial NOT NULL, 
   rekvid integer NOT NULL DEFAULT 0, 
   isikid integer NOT NULL DEFAULT 0, 
   hooldekoduid integer NOT NULL DEFAULT 0, 
   "number" character varying(20) NOT NULL, 
   omavalitsus character varying(120) NOT NULL, 
   algkpv date NOT NULL DEFAULT date(), 
   loppkpv date, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   summa numeric(18,2) NOT NULL DEFAULT 0,
   osa numeric(6,4) NOT NULL DEFAULT 85,
   muud text,
    CONSTRAINT hooleping_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)

;
ALTER TABLE hooleping OWNER TO vlad;



CREATE INDEX hooleping_isikid
  ON hooleping
  USING btree
  (isikid);


CREATE INDEX hooleping_hooldekoduid
  ON hooleping
  USING btree
  (hooldekoduid);
ALTER TABLE hooleping CLUSTER ON hooleping_hooldekoduid;


GRANT ALL ON TABLE hooleping TO GROUP hkametnik;
GRANT ALL ON TABLE hooleping TO GROUP soametnik;

