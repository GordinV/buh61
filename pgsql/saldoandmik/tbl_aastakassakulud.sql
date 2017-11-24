-- Table: saldoandmik

-- DROP TABLE saldoandmik;

CREATE TABLE aastakassakulud
(
  id serial NOT NULL,
  summa numeric (18,8) not null default 0,
  valuuta character varying(20) NOT NULL DEFAULT 'EEK',
  kuurs numeric (8,4) not null default 1,
  tegev character varying(20) NOT NULL DEFAULT space(1),
  allikas character varying(20) NOT NULL DEFAULT space(1),
  art character varying(20) NOT NULL DEFAULT space(1),
  kpv date DEFAULT date(),
  aasta integer DEFAULT year(date()),
  rekvid integer,
  omatp character varying(20) NOT NULL DEFAULT space(1),
  tyyp integer DEFAULT 0,
  kuu integer DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aastakassakulud OWNER TO vlad;
GRANT ALL ON TABLE aastakassakulud TO vlad;
GRANT SELECT ON TABLE aastakassakulud TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aastakassakulud TO saldoandmikkoostaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aastakassakulud TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aastakassakulud TO dbkasutaja;

-- Index: ix_saldoandmik_period

-- DROP INDEX ix_saldoandmik_period;

CREATE INDEX ix_aastakassakulud_period
  ON aastakassakulud
  USING btree
  (kuu, aasta);

