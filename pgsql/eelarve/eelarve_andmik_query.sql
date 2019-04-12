DROP FUNCTION IF EXISTS eelarve_andmik_query(DATE, INTEGER, INTEGER);
/*
DROP TYPE IF EXISTS EELARVE_ANDMIK_TYPE;
CREATE TYPE EELARVE_ANDMIK_TYPE AS (idx VARCHAR(20), is_e INTEGER, rekvid INTEGER, tegev VARCHAR(20), allikas VARCHAR(20), artikkel VARCHAR(20), nimetus VARCHAR(254), eelarve NUMERIC(14,2), tegelik NUMERIC(14,2), kassa NUMERIC(14,2), saldoandmik NUMERIC(14,2));
*/
CREATE OR REPLACE FUNCTION eelarve_andmik_query(IN l_kpv DATE,
                                                IN l_rekvid INTEGER,
                                                IN l_kond INTEGER)
  RETURNS BOOLEAN
AS
$$
declare 
	l_count integer = 0;
BEGIN


  DROP TABLE IF EXISTS tmp_andmik;

  CREATE TEMPORARY TABLE tmp_andmik (
    idx         TEXT,
    tyyp        INTEGER,
    rekvid      INTEGER,
    tegev       VARCHAR(20),
    allikas     VARCHAR(20),
    artikkel    VARCHAR(20),
    rahavoog    VARCHAR(20),
    nimetus     VARCHAR(254),
    eelarve     NUMERIC(14,2),
    tegelik     NUMERIC(14,2),
    kassa       NUMERIC(14,2),
    saldoandmik NUMERIC(14,2),
    db          NUMERIC(14,2),
    kr          NUMERIC(14,2),
    aasta       INTEGER,
    kuu         INTEGER
  );

/*
  CREATE INDEX tyyp_tmp_andmik
    ON tmp_andmik
      USING btree
      (tyyp);


  CREATE INDEX artikkel_tmp_andmik
    ON tmp_andmik
      USING btree
      (artikkel);


  CREATE INDEX rahavoog_tmp_andmik
    ON tmp_andmik
      USING btree
      (rahavoog);

*/
  INSERT INTO tmp_andmik (idx, tyyp, rekvid, tegev, allikas, artikkel, nimetus, eelarve, tegelik, kassa, aasta, kuu)
  SELECT
    '2.1'                       AS idx,
    1                           AS tyyp,
    qry.rekvid,
    qry.tegev::VARCHAR(20)      AS tegev,
    qry.allikas::VARCHAR(20)    AS allikas,
    qry.artikkel::VARCHAR(20)   AS artikkel,
    l.nimetus::VARCHAR(254),
    sum(eelarve)::NUMERIC(14,2) AS eelarve,
    sum(tegelik)::NUMERIC(14,2) AS tegelik,
    sum(kassa)::NUMERIC(14,2)   AS kassa,
    year(l_kpv)                 AS aasta,
    month(l_kpv)
  FROM (
         SELECT
           rekvid,
           summa        AS eelarve,
           0 :: NUMERIC AS tegelik,
           0 :: NUMERIC AS kassa,
           kood1        AS tegev,
           kood2        AS allikas,
           kood5        AS artikkel
         FROM eelarve e
         WHERE
             rekvid = (CASE
                         WHEN $3 = 1
                           THEN rekvid
                         ELSE $2 END)
           AND e.rekvid IN (SELECT rekv_id
                            FROM get_asutuse_struktuur($2))
           AND aasta = year($1)
           AND (e.kpv IS NULL OR e.kpv <= $1)
         UNION ALL
         SELECT
           rekvid,
           0 :: NUMERIC           AS eelarve,
           summa                  AS tegelik,
           0 :: NUMERIC           AS kassa,
           COALESCE(ft.tegev, '') AS tegev,
           COALESCE(ft.kood2, '') AS allikas,
           COALESCE(ft.kood, '')  AS artikkel
         FROM curkuludetaitmine ft
         WHERE
             ft.rekvid = (CASE
                            WHEN $3 = 1
                              THEN rekvid
                            ELSE $2 END)
           AND ft.rekvid IN (SELECT rekv_id
                             FROM get_asutuse_struktuur($2))
           AND ft.kuu <= MONTH($1)
           AND ft.aasta = year($1)
           AND ft.kood IS NOT NULL
           AND NOT empty(ft.kood)
         UNION ALL
         SELECT
           rekvid,
           0 :: NUMERIC           AS eelarve,
           summa                  AS tegelik,
           0 :: NUMERIC           AS kassa,
           COALESCE(tt.tegev, '') AS tegev,
           COALESCE(tt.kood2, '') AS allikas,
           COALESCE(tt.kood, '')  AS artikkel
         FROM curtuludetaitmine tt
         WHERE
             tt.rekvid = (CASE
                            WHEN $3 = 1
                              THEN rekvid
                            ELSE $2 END)
           AND tt.rekvid IN (SELECT rekv_id
                             FROM get_asutuse_struktuur($2))
           AND tt.kuu <= MONTH($1)
           AND tt.aasta = year($1)
           AND tt.kood IS NOT NULL
           AND NOT empty(tt.kood)
         UNION ALL
         SELECT
           rekvid,
           0 :: NUMERIC AS eelarve,
           0 :: NUMERIC AS tegelik,
           summa        AS kassa,
           tegev,
           kood2,
           kood
         FROM curkassakuludetaitmine kt
         WHERE
             kt.rekvid = (CASE
                            WHEN $3 = 1
                              THEN rekvid
                            ELSE $2 END)

           AND kt.rekvid IN (SELECT rekv_id
                             FROM get_asutuse_struktuur($2))
           AND kt.aasta = year($1)
           AND kt.kuu <= MONTH($1)
           AND kt.kood IS NOT NULL
           AND NOT empty(kt.kood)
         and kood in (SELECT kood FROM library WHERE library.library = 'TULUDEALLIKAD' AND tun5 = 2)
         UNION ALL
         SELECT
           rekvid,
           0 :: NUMERIC AS eelarve,
           0 :: NUMERIC AS tegelik,
           summa        AS kassa,
           tegev,
           kood2,
           kood
         FROM (
                SELECT journal.rekvid,
                       sum(journal1.summa) AS summa,
                       journal1.kood5      AS kood,
                       journal1.kood1      AS tegev,
                       journal1.kood2
                FROM journal
                       JOIN journal1 ON journal1.parentid = journal.id
                       JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::TEXT)) ~~ ltrim(rtrim(kassatulud.kood::TEXT))
                       JOIN kassakontod ON ltrim(rtrim(journal1.deebet::TEXT)) ~~ ltrim(rtrim(kassakontod.kood::TEXT))
                WHERE
                    journal.rekvid = (CASE
                                        WHEN $3 = 1
                                          THEN journal.rekvid
                                        ELSE $2 END)

                  AND journal.rekvid IN (SELECT rekv_id
                                         FROM get_asutuse_struktuur($2))
                  AND year(journal.kpv) = year($1)
                  AND JOURNAL.KPV < $1
                  AND journal1.kood5 IN (SELECT kood FROM library WHERE library.library = 'TULUDEALLIKAD' AND tun5 = 1)
                GROUP BY journal.rekvid, journal1.kood5, journal1.kood1, journal1.kood2
              ) tt
         WHERE tt.kood IS NOT NULL
           AND NOT empty(tt.kood)

         UNION ALL

           -- kassatulud (art.jargi) miinus
         SELECT kassakulu.rekvid,
                0::NUMERIC   AS eelarve,
                0::NUMERIC   AS tegelik,
                -1 * (summa) AS kassa,
                kassakulu.tegev::VARCHAR(20),
                kassakulu.allikas::VARCHAR(20),
                kassakulu.artikkel::VARCHAR(20)
         FROM (
                SELECT journal.rekvid,
                       sum(journal1.summa) AS summa,
                       journal1.kood1      AS tegev,
                       journal1.kood2      AS allikas,
                       journal1.kood5      AS artikkel
                FROM journal
                       JOIN journal1 ON journal1.parentid = journal.id
                       JOIN kassakulud ON ltrim(rtrim(journal1.deebet::TEXT)) ~~ ltrim(rtrim(kassakulud.kood::TEXT))
                       JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::TEXT)) ~~ ltrim(rtrim(kassakontod.kood::TEXT))
                WHERE journal.kpv <= $1
                  AND YEAR(journal.kpv) = YEAR($1)
                  AND journal.rekvid = (CASE
                                          WHEN $3 = 1
                                            THEN rekvid
                                          ELSE $2 END)
                  AND journal.rekvid IN (SELECT rekv_id
                                         FROM get_asutuse_struktuur($2))
                  AND journal1.kood5 IS NOT NULL
                  AND NOT empty(journal1.kood5)
                  AND journal1.kood5 IN (SELECT kood FROM library WHERE library.library = 'TULUDEALLIKAD' AND tun5 = 1)
                GROUP BY journal.rekvid, journal1.kood1, journal1.kood2, journal1.kood5
              ) kassakulu
         UNION ALL

           -- kassatulud (art.jargi), kulud
         SELECT kassatulu.rekvid,
                0::NUMERIC   AS eelarve,
                0::NUMERIC   AS tegelik,
                -1 * (summa) AS kassa,
                kassatulu.tegev::VARCHAR(20),
                kassatulu.allikas::VARCHAR(20),
                kassatulu.artikkel::VARCHAR(20)
         FROM (
                SELECT journal.rekvid,
                       sum(journal1.summa) AS summa,
                       journal1.kood1      AS tegev,
                       journal1.kood2      AS allikas,
                       journal1.kood5      AS artikkel
                FROM journal
                       JOIN journal1 ON journal1.parentid = journal.id
                       JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::TEXT)) ~~ ltrim(rtrim(kassatulud.kood::TEXT))
                       JOIN kassakontod ON ltrim(rtrim(journal1.deebet::TEXT)) ~~ ltrim(rtrim(kassakontod.kood::TEXT))
                WHERE journal.kpv <= $1
                  AND YEAR(journal.kpv) = YEAR($1)
                  AND journal.rekvid = (CASE
                                          WHEN $3 = 1
                                            THEN rekvid
                                          ELSE $2 END)
                  AND journal.rekvid IN (SELECT rekv_id
                                         FROM get_asutuse_struktuur($2))
                  AND journal1.kood5 IS NOT NULL
                  AND NOT empty(journal1.kood5)
                  AND journal1.kood5 IN (SELECT kood FROM library WHERE library.library = 'TULUDEALLIKAD' AND tun5 = 2)
                GROUP BY journal.rekvid, journal1.kood1, journal1.kood2, journal1.kood5
              ) kassatulu
       ) qry
         LEFT OUTER JOIN library l ON l.
                                        kood = qry.artikkel AND l.library = 'TULUDEALLIKAD'
  GROUP BY qry.rekvid, qry.tegev, qry.allikas, qry.artikkel, l.nimetus;

  raise notice 'start saldoandmik kpv %, kond %', $1, $3;

  INSERT INTO tmp_andmik (idx,  tyyp, rekvid, tegev, artikkel, rahavoog, nimetus, saldoandmik, db, kr, aasta, kuu)
  SELECT 2, 2,
(CASE
                    WHEN $3 = 1
                      THEN 999
                    ELSE $2 END),  
         tegev,
         konto,
         rahavoo,
         nimetus,
         sum(CASE WHEN db = 0 THEN (kr - db) ELSE (db - kr) END),
         sum(db),
         sum(kr),
         year($1),
         month($1)
  FROM saldoandmik
  WHERE aasta = year($1)
    AND kuu = month($1)
    AND rekvid = (CASE
                    WHEN $3 = 1
                      THEN 999
                    ELSE $2 END)
  GROUP BY tegev, konto, rahavoo, nimetus;

GET DIAGNOSTICS l_count= ROW_COUNT;
raise notice 'inserted kokku %', l_count;

  -- eelmise periodi andmed
  INSERT INTO tmp_andmik (idx, tyyp,rekvid, tegev, artikkel, rahavoog, nimetus, saldoandmik, db, kr, aasta, kuu)
  SELECT 2, 
	2,
(CASE
                    WHEN $3 = 1
                      THEN 999
                    ELSE $2 END),  
	
         tegev,
         konto,
         rahavoo,
         nimetus,
         sum(CASE WHEN db = 0 THEN (kr - db) ELSE (db - kr) END),
         sum(db),
         sum(kr),
         year($1) - 1, -- year(($1 - interval '3 month')::date),
         12            --month(($1 - interval '3 month')::date)
  FROM saldoandmik
  WHERE aasta = year($1) - 1 --year(($1 - interval '3 month')::date)
    AND kuu = 12             -- month(($1 - interval '3 month')::date)
    AND rekvid = (CASE
                    WHEN $3 = 1
                      THEN 999
                    ELSE $2 END)
  GROUP BY tegev, allikas, konto, rahavoo, nimetus;


GET DIAGNOSTICS l_count= ROW_COUNT;
raise notice 'inserted kokku 2%', l_count;
  
  RETURN TRUE;


END;
$$
  LANGUAGE 'plpgsql'
  VOLATILE
  COST 100;


GRANT EXECUTE ON FUNCTION eelarve_andmik_query(DATE, INTEGER, INTEGER ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik_query(DATE, INTEGER, INTEGER ) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik_query(DATE, INTEGER, INTEGER ) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION eelarve_andmik_query(DATE, INTEGER, INTEGER ) TO dbvaatleja;


SELECT eelarve_andmik_query(DATE(2019,01,31), 63, 0);

SELECT *
FROM tmp_andmik
where rekvid = 63
and tyyp = 2;
