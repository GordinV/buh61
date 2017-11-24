-- Table: tmp_viivis

-- DROP TABLE tmp_viivis;

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
  volg6 numeric(14,4) DEFAULT 0,
  tasud7 date,
  tasun7 numeric(14,4) DEFAULT 0,
  paev7 integer DEFAULT 0,
  volg7 numeric(14,4) DEFAULT 0,
  tasud8 date,
  tasun8 numeric(14,4) DEFAULT 0,
  paev8 integer DEFAULT 0,
  volg8 numeric(14,4) DEFAULT 0,
  tasud9 date,
  tasun9 numeric(14,4) DEFAULT 0,
  paev9 integer DEFAULT 0,
  volg9 numeric(14,4) DEFAULT 0,
  viivis1 numeric(18,8) DEFAULT 0,
  viivis2 numeric(18,8) DEFAULT 0,
  viivis3 numeric(18,8) DEFAULT 0,
  viivis4 numeric(18,8) DEFAULT 0,
  viivis5 numeric(18,8) DEFAULT 0,
  viivis6 numeric(18,8) DEFAULT 0,
  muud text
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tmp_viivis OWNER TO vlad;
GRANT ALL ON TABLE tmp_viivis TO vlad;
GRANT ALL ON TABLE tmp_viivis TO public;
