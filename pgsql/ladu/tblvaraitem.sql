-- Table: varaitem

-- DROP TABLE varaitem;

CREATE TABLE varaitem
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  nomid integer NOT NULL,
  kogus numeric(12,2) NOT NULL DEFAULT 0,
  muud text,
  rekvid integer DEFAULT 0,
  CONSTRAINT varaitem_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE varaitem OWNER TO vlad;
GRANT ALL ON TABLE varaitem TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbadmin;
GRANT SELECT ON TABLE varaitem TO dbvaatleja;
