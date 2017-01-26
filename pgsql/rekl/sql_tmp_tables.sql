-- Table: tmpreklaruanne2

-- DROP TABLE tmpreklaruanne2;

CREATE TABLE tmpreklaruanne2
(
  "timestamp" character varying(20),
  luba character varying(100),
  toiming_nr character varying(100),
  summa numeric(14,2),
  kpv date,
  volg numeric(14,2),
  tasukpv date,
  tasu_summa numeric(14,2),
  paevad integer,
  intressi_maar numeric(12,4),
  intress numeric(14,2),
  makstud_intress numeric(14,2),
  intressis_jaak numeric(14,2),
  period character varying(100)
)
WITH (
  OIDS=FALSE
);


CREATE TABLE tmpreklaruanne3
(
  "timestamp" character varying(20),
  regkood character varying(20),
  asutus character varying(254),
  d102060 numeric(14,2),
  d102095 numeric(14,2),
  k200060 numeric(14,2),
  volg numeric(14,2),
  ettemaks numeric(14,2),
  intress numeric(14,2)
)
WITH (
  OIDS=FALSE
);

