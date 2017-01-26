CREATE TABLE viiviseinfo
(
  id serial,
  rekvid integer,
  asutusid integer,
  IntressId integer,
  dokid integer,
  dokliik integer default 1, 
  doktahtaeg date,
  doksumma numeric(18,4) default 0,
  dokVolg numeric(18,4) default 0,
  dokPaevad integer default 0,
  intressimaar numeric (18,4) default 0,
  muudSumma numeric(18,4) default 0,
  muud text
)
WITH (
  OIDS=TRUE
);
ALTER TABLE viiviseinfo OWNER TO vlad;
GRANT ALL ON TABLE viiviseinfo TO vlad;
GRANT ALL ON TABLE viiviseinfo TO taabel;
GRANT ALL ON TABLE viiviseinfo TO public;


GRANT ALL ON TABLE viiviseinfo_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE viiviseinfo_id_seq TO GROUP dbpeakasutaja;
