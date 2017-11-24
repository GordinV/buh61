-- Table: hooettemaksud
/*

select id, isikid,aruanne, kellele, koostaja, muud::varchar(254) as muud from hootoendid

*/
-- DROP TABLE hooettemaksud;

CREATE TABLE hootoendid
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  kpv date NOT NULL,
  aruanne varchar(254) not null,	
  kellele varchar(254) not null,
  koostaja varchar(254) not null,
  muud text,
  CONSTRAINT hootoendid_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE hootoendid TO hkametnik;
GRANT ALL ON TABLE hootoendid TO soametnik;


CREATE INDEX hootoendid_isikid
  ON hootoendid
  USING btree
  (isikid);
ALTER TABLE hootoendid CLUSTER ON hootoendid_isikid;

