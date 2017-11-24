--ALTER TABLE tmp_viivis ADD COLUMN viivis1 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN viivis2 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN viivis3 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN viivis4 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN viivis5 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN viivis6 numeric(18,8) DEFAULT 0;
--ALTER TABLE tmp_viivis ADD COLUMN muud text;



CREATE TABLE tmp_viivis
(
  dkpv date DEFAULT date(),
  "timestamp" character varying(20),
  id integer,
  rekvid integer,
  asutusid integer,
  konto character varying(20),
  algjaak numeric(14,4),
  algkpv date,
  arvnumber character varying(20),
  tahtaeg date,
  summa numeric(14,4),
  tasud1 date,
  tasun1 numeric(14,4) DEFAULT 0,
  paev1 integer DEFAULT 0,
  volg1 numeric(14,4) DEFAULT 0,
  tasud2 date,
  tasun2 numeric(14,4) DEFAULT 0,
  paev2 integer DEFAULT 0,
  volg2 numeric(14,4) DEFAULT 0,
  tasud3 date,
  tasun3 numeric(14,4) DEFAULT 0,
  paev3 integer DEFAULT 0,
  volg3 numeric(14,4) DEFAULT 0,
  tasud4 date,
  tasun4 numeric(14,4) DEFAULT 0,
  paev4 integer DEFAULT 0,
  volg4 numeric(14,4) DEFAULT 0,
  tasud5 date,
  tasun5 numeric(14,4) DEFAULT 0,
  paev5 integer DEFAULT 0,
  volg5 numeric(14,4) DEFAULT 0,
  tasud6 date,
  tasun6 numeric(14,4) DEFAULT 0,
  paev6 integer DEFAULT 0,
  volg6 numeric(14,4) DEFAULT 0
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tmp_viivis OWNER TO postgres;
GRANT ALL ON TABLE tmp_viivis TO postgres;
GRANT ALL ON TABLE tmp_viivis TO public;
