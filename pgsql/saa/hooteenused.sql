CREATE TABLE hooteenused
(
   id serial NOT NULL, 
   lepingid integer NOT NULL DEFAULT 0, 
   nomid integer NOT NULL DEFAULT 0, 
   hind numeric(18,6) NOT NULL DEFAULT 0, 
   allikas character varying(20) NOT NULL, 
   tuluosa numeric(6,2) NOT NULL DEFAULT 0, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   muud text, 
   kehtivus date,
    CONSTRAINT hooteenused_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

CREATE INDEX hooteenused_lepingid
  ON hooteenused
  USING btree
  (lepingid);

ALTER TABLE hooteenused CLUSTER ON hooteenused_lepingid;

CREATE INDEX hooteenused_nomid
  ON hooteenused
  USING btree
  (nomid);


GRANT ALL ON TABLE hooteenused TO GROUP hkametnik;
GRANT ALL ON TABLE hooteenused TO GROUP soametnik;


