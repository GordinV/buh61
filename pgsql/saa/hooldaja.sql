CREATE TABLE hooldaja	
(
   id serial NOT NULL, 
   hooldajaid integer NOT NULL DEFAULT 0, 
   isikid integer NOT NULL DEFAULT 0, 
   kohtumaarus character varying(254) not null, 
   algkpv date not null,
   loppkpv date,
   muud text, 
    CONSTRAINT hooldaja_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

CREATE INDEX hooldaja_isikid
  ON hooldaja
  USING btree
  (isikid, hooldajaid);


GRANT ALL ON TABLE hooldaja TO GROUP hkametnik;
GRANT ALL ON TABLE hooldaja TO GROUP soametnik;


