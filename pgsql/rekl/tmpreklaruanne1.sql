-- Table: tmpreklaruanne1

DROP TABLE if exists tmpreklaruanne1;

CREATE TABLE tmpreklaruanne1
(
  "timestamp" character varying(20),
  luba character varying(100),
  toiming_nr character varying(100),
  summa numeric(14,2),
  kpv date,
  staatus character varying(200),
  lausend_nr character varying(10),
  volg numeric(14,2),
  tyyp character varying(100),
  tyypnimi character varying(100),
  tasukpv date,
  tasu_summa numeric(14,2),
  jaak numeric(14,2),
  ettemaks numeric(14,2),
  intressid numeric(14,2),
  alg_intressid numeric(14,2),
  alg_ettemaks numeric(14,2),
  alg_jaak numeric(14,2)

)
WITH (
  OIDS=FALSE
);
