DROP FUNCTION IF EXISTS eelarve_andmik(DATE, INTEGER, INTEGER);


DROP TYPE IF EXISTS EELARVE_ANDMIK_TYPE;
CREATE TYPE EELARVE_ANDMIK_TYPE AS (idx VARCHAR(20), is_e INTEGER, rekvid INTEGER, tegev VARCHAR(20), allikas VARCHAR(20), artikkel VARCHAR(20), nimetus VARCHAR(254), eelarve NUMERIC(14, 2), tegelik NUMERIC(14, 2), kassa NUMERIC(14, 2), saldoandmik NUMERIC(14, 2));


CREATE OR REPLACE FUNCTION eelarve_andmik(IN l_kpv DATE,
                                          IN l_rekvid INTEGER,
                                          IN l_kond INTEGER)
    RETURNS SETOF EELARVE_ANDMIK_TYPE
AS
$$
DECLARE
    is_kond   BOOLEAN = NOT empty(l_kond);
    l_kuu     INTEGER = month(l_kpv);
    l_aasta   INTEGER = year(l_kpv);
    la_kontod TEXT[]  = ARRAY ['100','1000','1001','15','1501','1502','1511','1512','1531','1532','2580','2581','2585','2586','3000','3030',
        '3034','3041','3044','3045','3047','32','3500','3502','352','35200','352001','381','3818','382','38250','38251',
        '38252','38254','3880','3882','3888','40','413','4500','4502','452','50','55','60','650','655','9100','9101'];
BEGIN

    -- will fill temp table with row data
    PERFORM eelarve_andmik_query(l_kpv, l_rekvid, l_kond);

-- data analise 
    RETURN QUERY
        SELECT idx::VARCHAR(20),
               CASE
                   WHEN is_e = 0 AND ARRAY [ltrim(rtrim(artikkel))::TEXT] <@ la_kontod THEN 1
                   ELSE is_e END:: INTEGER AS is_e,
               rekvid::INTEGER,
               tegev::VARCHAR(20),
               allikas::VARCHAR(20),
               artikkel::VARCHAR(20),
               nimetus::VARCHAR(254),
               eelarve::NUMERIC,
               tegelik::NUMERIC,
               kassa::NUMERIC,
               saldoandmik::NUMERIC
        FROM (
                 SELECT '2.1'::VARCHAR(20)                                     AS idx,
                        1                                                      AS is_e,
                        $2                                                     AS rekvid,
                        ''::VARCHAR(20)                                        AS tegev,
                        ''::VARCHAR(20)                                        AS allikas,
                        '32'::VARCHAR(20)                                      AS artikkel,
                        'Tulud kaupade ja teenuste müügist'::VARCHAR(254)      AS nimetus,
                        coalesce(sum(eelarve), 0)::NUMERIC(12, 2)              AS eelarve,
                        coalesce(coalesce(sum(tegelik), 0), 0)::NUMERIC(12, 2) AS tegelik,
                        coalesce(coalesce(sum(kassa), 0), 0)::NUMERIC(12, 2)   AS kassa,
                        get_saldo('KD', '32', NULL, NULL)::NUMERIC(12, 2)      AS saldoandmik
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '32%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        0                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '352'::VARCHAR(20)                    AS artikkel,
                        'Mittesihtotstarbelised toetused'     AS nimetus,
                        coalesce(sum(eelarve), 0)             AS eelarve,
                        coalesce(sum(tegelik), 0)             AS tegelik,
                        coalesce(sum(kassa), 0)               AS kassa,
                        get_saldo('KD', '352', NULL, NULL) -
                        get_saldo('KD', '352000', NULL, NULL) -
                        get_saldo('KD', '352001', NULL, NULL) AS saldoandmik
-- KD352-KD352000-KD352010
                 FROM tmp_andmik q
                 WHERE artikkel = '352'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        0                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '35200'::VARCHAR(20)                  AS artikkel,
                        'Tasandusfond'                        AS nimetus,
                        coalesce(sum(eelarve), 0)             AS eelarve,
                        coalesce(sum(tegelik), 0)             AS tegelik,
                        coalesce(sum(kassa), 0)               AS kassa,
                        get_saldo('KD', '352000', NULL, NULL) AS saldoandmik
-- KD352000
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '35200%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        0                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '352001'::VARCHAR(20)                 AS artikkel,
                        'Toetusfond '                         AS nimetus,
                        coalesce(sum(eelarve), 0)             AS eelarve,
                        coalesce(sum(tegelik), 0)             AS tegelik,
                        coalesce(sum(kassa), 0)               AS kassa,
                        get_saldo('KD', '352001', NULL, NULL) AS saldoandmik
-- KD352010
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '35201%'
                   AND tyyp = 1

                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        0                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '382'::VARCHAR(20)                    AS artikkel,
                        'Muud tulud varadelt'                 AS nimetus,
                        coalesce(sum(eelarve), 0)             AS eelarve,
                        coalesce(sum(tegelik), 0)             AS tegelik,
                        coalesce(sum(kassa), 0)               AS kassa,
                        get_saldo('KD', '382', NULL, NULL) +
                        get_saldo('KD', '382520', NULL, NULL) +
                        get_saldo('KD', '382560', NULL, NULL) AS saldoandmik
-- KD382+KD382520+KD382550+KD382560

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '382%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                                   AS is_e,
                        $2                                                  AS rekvid,
                        ''::VARCHAR(20)                                     AS tegev,
                        ''::VARCHAR(20)                                     AS allikas,
                        '40'::VARCHAR(20)                                   AS artikkel,
                        'Subsiidiumid ettevõtlusega tegelevatele isikutele' AS nimetus,
                        coalesce(sum(eelarve), 0)                           AS eelarve,
                        coalesce(sum(tegelik), 0)                           AS tegelik,
                        coalesce(sum(kassa), 0)                             AS kassa,
                        get_saldo('KD', '40', NULL, NULL)                   AS saldoandmik
-- KD40
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '40%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                                             AS is_e,
                        $2                                                            AS rekvid,
                        ''::VARCHAR(20)                                               AS tegev,
                        ''::VARCHAR(20)                                               AS allikas,
                        '413'::VARCHAR(20)                                            AS artikkel,
                        'Sotsiaalabitoetused ja muud toetused füüsilistele isikutele' AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                                AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                                AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                                  AS kassa,
                        get_saldo('KD', '413', NULL, NULL)                            AS saldoandmik
-- KD413
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '413%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                            AS is_e,
                        $2                                           AS rekvid,
                        ''::VARCHAR(20)                              AS tegev,
                        ''::VARCHAR(20)                              AS allikas,
                        '4500'::VARCHAR(20)                          AS artikkel,
                        'Sihtotstarbelised toetused tegevuskuludeks' AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)               AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)               AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                 AS kassa,
                        get_saldo('KD', '4500', NULL, NULL)          AS saldoandmik
-- KD4500
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '4500%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                  AS is_e,
                        $2                                 AS rekvid,
                        ''::VARCHAR(20)                    AS tegev,
                        ''::VARCHAR(20)                    AS allikas,
                        '452'::VARCHAR(20)                 AS artikkel,
                        'Mittesihtotstarbelised toetused'  AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)     AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)     AS tegelik,
                        -1 * coalesce(sum(kassa), 0)       AS kassa,
                        get_saldo('KD', '452', NULL, NULL) AS saldoandmik
-- KD452
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '452%'
                   AND tyyp = 1


                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                 AS is_e,
                        $2                                AS rekvid,
                        ''::VARCHAR(20)                   AS tegev,
                        ''::VARCHAR(20)                   AS allikas,
                        '50'::VARCHAR(20)                 AS artikkel,
                        'Tööjõukulud'                     AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)    AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)    AS tegelik,
                        -1 * coalesce(sum(kassa), 0)      AS kassa,
                        get_saldo('KD', '50', NULL, NULL) AS saldoandmik
-- KD382+KD382520+KD382550+KD382560

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '50%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1',
                        1                                 AS is_e,
                        $2                                AS rekvid,
                        ''::VARCHAR(20)                   AS tegev,
                        ''::VARCHAR(20)                   AS allikas,
                        '55'::VARCHAR(20)                 AS artikkel,
                        'Majandamiskulud'                 AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)    AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)    AS tegelik,
                        -1 * coalesce(sum(kassa), 0)      AS kassa,
                        get_saldo('KD', '55', NULL, NULL) AS saldoandmik
-- KD382+KD382520+KD382550+KD382560

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '55%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.1'::VARCHAR(20),
                        1                                                                         AS is_e,
                        $2                                                                        AS rekvid,
                        ''::VARCHAR(20)                                                           AS tegev,
                        ''::VARCHAR(20)                                                           AS allikas,
                        '60'::VARCHAR(20)                                                         AS artikkel,
                        'Muud kulud'                                                              AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                                            AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                                            AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                                              AS kassa,
                        get_saldo('KD', '60', NULL, NULL) - get_saldo('KD', '601002', NULL, NULL) AS saldoandmik
-- KD382+KD382520+KD382550+KD382560

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '60%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4'::VARCHAR(20),
                        1                                  AS is_e,
                        $2                                 AS rekvid,
                        ''::VARCHAR(20)                    AS tegev,
                        ''::VARCHAR(20)                    AS allikas,
                        '381'::VARCHAR(20)                 AS artikkel,
                        'Põhivara müük (+)'                AS nimetus,
                        coalesce(sum(eelarve), 0)          AS eelarve,
                        coalesce(sum(tegelik), 0)          AS tegelik,
                        coalesce(sum(kassa), 0)            AS kassa,
                        get_saldo('KD', '381', NULL, NULL) -
                        get_saldo('KD', '3818', NULL, NULL) -
                        get_saldo('KD', '154', '02', NULL) -
                        get_saldo('KD', '155', '02', NULL) -
                        get_saldo('KD', '156', '02', NULL) -
                        get_saldo('KD', '157', '02', NULL) -
                        get_saldo('KD', '109', '02', NULL) AS saldoandmik
-- KD381-KD3818-KD154RV02-KD155RV02-KD156RV02-KD157RV02-KD109RV02

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '381%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.1'::VARCHAR(20),
                        1                                                  AS is_e,
                        $2                                                 AS rekvid,
                        ''::VARCHAR(20)                                    AS tegev,
                        ''::VARCHAR(20)                                    AS allikas,
                        '15'::VARCHAR(20)                                  AS artikkel,
                        'Põhivara soetus (-)'                              AS nimetus,
                        0                                                  AS eelarve,
                        0                                                  AS tegelik,
                        0                                                  AS kassa,
                        coalesce(get_saldo('KD', '154', '01', NULL) +
                                 get_saldo('KD', '155', '01', NULL) +
                                 get_saldo('KD', '156', '01', NULL) +
                                 get_saldo('KD', '157', '01', NULL) +
                                 get_saldo('KD', '601002', NULL, NULL), 0) AS saldoandmik
-- KD154RV01+KD155RV01+KD156RV01+KD157RV01+601002KD
                 UNION ALL
                 SELECT '2.4.1'::VARCHAR(20),
                        1                                                  AS is_e,
                        $2                                                 AS rekvid,
                        ''::VARCHAR(20)                                    AS tegev,
                        ''::VARCHAR(20)                                    AS allikas,
                        '3502'::VARCHAR(20)                                AS artikkel,
                        'Põhivara soetuseks saadav sihtfinantseerimine(+)' AS nimetus,
                        coalesce(sum(eelarve), 0)                          AS eelarve,
                        coalesce(sum(tegelik), 0)                          AS tegelik,
                        coalesce(sum(kassa), 0)                            AS kassa,
                        get_saldo('KD', '3502', '01', NULL) +
                        get_saldo('KD', '3502', '05', NULL)                AS saldoandmik
-- KD3502RV01+KD3502RV05

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '3502%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.1'::VARCHAR(20),
                        1                                                 AS is_e,
                        $2                                                AS rekvid,
                        ''::VARCHAR(20)                                   AS tegev,
                        ''::VARCHAR(20)                                   AS allikas,
                        '4502'::VARCHAR(20)                               AS artikkel,
                        'Põhivara soetuseks antav sihtfinantseerimine(-)' AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                    AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                    AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                      AS kassa,
                        get_saldo('KD', '4502', NULL, NULL) +
                        get_saldo('KD', '1', '24', NULL)                  AS saldoandmik
-- KD4502+KD1RV24

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '4502%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.2'::VARCHAR(20),
                        1                                  AS is_e,
                        $2                                 AS rekvid,
                        ''::VARCHAR(20)                    AS tegev,
                        ''::VARCHAR(20)                    AS allikas,
                        '1502'::VARCHAR(20)                AS artikkel,
                        'Osaluste müük (+)'                AS nimetus,
                        coalesce(sum(eelarve), 0)          AS eelarve,
                        coalesce(sum(tegelik), 0)          AS tegelik,
                        coalesce(sum(kassa), 0)            AS kassa,
                        get_saldo('KD', '150', '02', NULL) AS saldoandmik
-- KD150RV02

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '1502%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.3',
                        1                                  AS is_e,
                        $2                                 AS rekvid,
                        ''::VARCHAR(20)                    AS tegev,
                        ''::VARCHAR(20)                    AS allikas,
                        '1501'::VARCHAR(20)                AS artikkel,
                        'Osaluste soetus (-)'              AS nimetus,
                        coalesce(sum(eelarve), 0)          AS eelarve,
                        coalesce(sum(tegelik), 0)          AS tegelik,
                        coalesce(sum(kassa), 0)            AS kassa,
                        get_saldo('KD', '150', '01', NULL) AS saldoandmik
-- KD150RV01
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '1501%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.3',
                        1                                                                             AS is_e,
                        $2                                                                            AS rekvid,
                        ''::VARCHAR(20)                                                               AS tegev,
                        ''::VARCHAR(20)                                                               AS allikas,
                        '1512'::VARCHAR(20)                                                           AS artikkel,
                        'Muude aktsiate ja osade müük (+)'                                            AS nimetus,
                        coalesce(sum(eelarve), 0)                                                     AS eelarve,
                        coalesce(sum(tegelik), 0)                                                     AS tegelik,
                        coalesce(sum(kassa), 0)                                                       AS kassa,
                        get_saldo('KD', '151910', '02', NULL) + get_saldo('KD', '101900', '02', NULL) AS saldoandmik
-- KD151910RV02+KD101900RV02
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '1512%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.4',
                        1                                                                             AS is_e,
                        $2                                                                            AS rekvid,
                        ''::VARCHAR(20)                                                               AS tegev,
                        ''::VARCHAR(20)                                                               AS allikas,
                        '1511'::VARCHAR(20)                                                           AS artikkel,
                        'Muude aktsiate ja osade soetus (-)'                                          AS nimetus,
                        coalesce(sum(eelarve), 0)                                                     AS eelarve,
                        coalesce(sum(tegelik), 0)                                                     AS tegelik,
                        coalesce(sum(kassa), 0)                                                       AS kassa,
                        get_saldo('KD', '151910', '01', NULL) + get_saldo('KD', '101900', '01', NULL) AS saldoandmik
-- KD151910RV01+KD101900RV01
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '1511%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.4',
                        1                                                                         AS is_e,
                        $2                                                                        AS rekvid,
                        ''::VARCHAR(20)                                                           AS tegev,
                        ''::VARCHAR(20)                                                           AS allikas,
                        '1532'::VARCHAR(20)                                                       AS artikkel,
                        'Tagasilaekuvad laenud (+)'                                               AS nimetus,
                        coalesce(sum(eelarve), 0)                                                 AS eelarve,
                        coalesce(sum(tegelik), 0)                                                 AS tegelik,
                        coalesce(sum(kassa), 0)                                                   AS kassa,
                        get_saldo('KD', '1032', '02', NULL) + get_saldo('KD', '1532', '02', NULL) AS saldoandmik
-- KD1032RV02+KD1532RV02
                 FROM tmp_andmik q
                 WHERE left(artikkel, 4) IN ('1032', '1532')
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.5',
                        1                                                                         AS is_e,
                        $2                                                                        AS rekvid,
                        ''::VARCHAR(20)                                                           AS tegev,
                        ''::VARCHAR(20)                                                           AS allikas,
                        '1531'::VARCHAR(20)                                                       AS artikkel,
                        'Antavad laenud (-)'                                                      AS nimetus,
                        coalesce(sum(eelarve), 0)                                                 AS eelarve,
                        coalesce(sum(tegelik), 0)                                                 AS tegelik,
                        coalesce(sum(kassa), 0)                                                   AS kassa,
                        get_saldo('KD', '1032', '01', NULL) + get_saldo('KD', '1532', '01', NULL) AS saldoandmik
-- KD1032RV01+KD1532RV01
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '1531%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.5',
                        1                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '655'::VARCHAR(20)                    AS artikkel,
                        'Finantstulud (+)'                    AS nimetus,
                        coalesce(sum(eelarve), 0)             AS eelarve,
                        coalesce(sum(tegelik), 0)             AS tegelik,
                        coalesce(sum(kassa), 0)               AS kassa,
                        get_saldo('KD', '652', NULL, NULL) +
                        get_saldo('KD', '655', NULL, NULL) +
                        get_saldo('KD', '658', NULL, NULL) -
                        get_saldo('KD', '658950', NULL, NULL) AS saldoandmik
-- KD652+KD655+KD658-KD658950

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '655%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.5',
                        1                                                                          AS is_e,
                        $2                                                                         AS rekvid,
                        ''::VARCHAR(20)                                                            AS tegev,
                        ''::VARCHAR(20)                                                            AS allikas,
                        '650'::VARCHAR(20)                                                         AS artikkel,
                        'Finantstkulud (-)'                                                        AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                                             AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                                             AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                                               AS kassa,
                        get_saldo('KD', '650', NULL, NULL) + get_saldo('KD', '658950', NULL, NULL) AS saldoandmik
-- KD650+KD658950
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '650%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.6',
                        1                                                                       AS is_e,
                        $2                                                                      AS rekvid,
                        ''::VARCHAR(20)                                                         AS tegev,
                        ''::VARCHAR(20)                                                         AS allikas,
                        '2585'::VARCHAR(20)                                                     AS artikkel,
                        'Kohustuste võtmine (+)'                                                AS nimetus,
                        coalesce(sum(eelarve), 0)                                               AS eelarve,
                        coalesce(sum(tegelik), 0)                                               AS tegelik,
                        coalesce(sum(kassa), 0)                                                 AS kassa,
                        get_saldo('KD', '208', '05', NULL) + get_saldo('KD', '258', '05', NULL) AS saldoandmik
-- KD208RV05+KD258RV05
                 FROM tmp_andmik q
                 WHERE (left(artikkel, 3) = '255' OR left(artikkel, 4) = '2585')
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.6',
                        1                                                                       AS is_e,
                        $2                                                                      AS rekvid,
                        ''::VARCHAR(20)                                                         AS tegev,
                        ''::VARCHAR(20)                                                         AS allikas,
                        '2586'::VARCHAR(20)                                                     AS artikkel,
                        'Kohustuste tasumine (-)'                                               AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                                          AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                                          AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                                            AS kassa,
                        get_saldo('KD', '208', '06', NULL) + get_saldo('KD', '258', '06', NULL) AS saldoandmik
-- KD208RV06+KD258RV06

                 FROM tmp_andmik q
                 WHERE (left(artikkel, 3) = '206' OR left(artikkel, 4) = '2586')
                   AND tyyp = 1
                 UNION ALL
                 SELECT '2.4.7',
                        1                                                         AS is_e,
                        $2                                                        AS rekvid,
                        ''::VARCHAR(20)                                           AS tegev,
                        ''::VARCHAR(20)                                           AS allikas,
                        '100'::VARCHAR(20)                                        AS artikkel,
                        'LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)' AS nimetus,
                        -1 * coalesce(sum(eelarve), 0)                            AS eelarve,
                        -1 * coalesce(sum(tegelik), 0)                            AS tegelik,
                        -1 * coalesce(sum(kassa), 0)                              AS kassa,
                        get_saldo('DK', '100', NULL, NULL) - get_saldo('MDK', '100', NULL, NULL) +
                        get_saldo('DK', '101', NULL, NULL) - get_saldo('MDK', '101', NULL, NULL) -
                        get_saldo('DK', '1019', NULL, NULL) - get_saldo('MDK', '1019', NULL, NULL) +
                        get_saldo('DK', '151', NULL, NULL) - get_saldo('MDK', '151', NULL, NULL) +
                        get_saldo('DK', '1519', NULL, NULL) - get_saldo('MDK', '1519', NULL, NULL)
                                                                                  AS saldoandmik
-- DK100-MDK100+DK101-MDK101-DK1019+MDK1019+DK151-MDK151-DK1519+MDK1519
-- @TODO oodan selesused

                 FROM tmp_andmik q
                 WHERE artikkel LIKE '100%'
                   AND tyyp = 1
                 UNION ALL
                 SELECT '8.1',
                        1                                                                         AS is_e,
                        $2                                                                        AS rekvid,
                        ''::VARCHAR(20)                                                           AS tegev,
                        ''::VARCHAR(20)                                                           AS allikas,
                        '2580'::VARCHAR(20)                                                       AS artikkel,
                        'Volakohustused'                                                          AS nimetus,
                        coalesce(sum(eelarve), 0)                                                 AS eelarve,
                        coalesce(sum(tegelik), 0)                                                 AS tegelik,
                        coalesce(sum(kassa), 0)                                                   AS kassa,
                        get_saldo('MKD', '208', NULL, NULL) + get_saldo('MKD', '258', NULL, NULL) AS saldoandmik
                 FROM tmp_andmik q
                 WHERE artikkel LIKE '2580%'
                   AND tyyp = 1

-- MKD208+MKD258
                 UNION ALL
                 SELECT '8.1',
                        1                                      AS is_e,
                        $2                                     AS rekvid,
                        ''::VARCHAR(20)                        AS tegev,
                        ''::VARCHAR(20)                        AS allikas,
                        '9100'::VARCHAR(20)                    AS artikkel,
                        'sh sildfinantseering'                 AS nimetus,
                        0                                      AS eelarve,
                        0                                      AS tegelik,
                        0                                      AS kassa,
                        get_saldo('MKD', '910090', NULL, NULL) AS saldoandmik
-- MKD910090
                 UNION ALL
                 SELECT '8.1',
                        1                   AS is_e,
                        $2                  AS rekvid,
                        ''::VARCHAR(20)     AS tegev,
                        ''::VARCHAR(20)     AS allikas,
                        '1000'::VARCHAR(20) AS artikkel,
                        'Likviidsed varad'  AS nimetus,
                        0                   AS eelarve,
                        0                   AS tegelik,
                        0                   AS kassa,
                        get_saldo('MDK', '100', NULL, NULL) +
                        get_saldo('MDK', '101', NULL, NULL) -
                        get_saldo('MDK', '1019', NULL, NULL) +
                        get_saldo('MDK', '151', NULL, NULL) -
                        get_saldo('MDK', '1519', NULL, NULL)
                                            AS saldoandmik
-- MDK100+MDK101-MDK1019+MDK151-MDK1519
                 UNION ALL
                 SELECT '8.2',
                        1                                                                       AS is_e,
                        $2                                                                      AS rekvid,
                        ''::VARCHAR(20)                                                         AS tegev,
                        ''::VARCHAR(20)                                                         AS allikas,
                        '2581'::VARCHAR(20)                                                     AS artikkel,
                        'Võlakohustused'                                                        AS nimetus,
                        0                                                                       AS eelarve,
                        0                                                                       AS tegelik,
                        0                                                                       AS kassa,
                        get_saldo('KD', '208', NULL, NULL) + get_saldo('KD', '258', NULL, NULL) AS saldoandmik
-- KD208+KD258
                 UNION ALL
                 SELECT '8.2',
                        1                                     AS is_e,
                        $2                                    AS rekvid,
                        ''::VARCHAR(20)                       AS tegev,
                        ''::VARCHAR(20)                       AS allikas,
                        '9101'::VARCHAR(20)                   AS artikkel,
                        'sh sildfinantseering'                AS nimetus,
                        0                                     AS eelarve,
                        0                                     AS tegelik,
                        0                                     AS kassa,
                        get_saldo('KD', '910090', NULL, NULL) AS saldoandmik
-- KD910090
                 UNION ALL
                 SELECT '8.2',
                        1                                   AS is_e,
                        $2                                  AS rekvid,
                        ''::VARCHAR(20)                     AS tegev,
                        ''::VARCHAR(20)                     AS allikas,
                        '1001'::VARCHAR(20)                 AS artikkel,
                        'Likviidsed varad'                  AS nimetus,
                        0                                   AS eelarve,
                        0                                   AS tegelik,
                        0                                   AS kassa,
                        get_saldo('DK', '100', NULL, NULL) +
                        get_saldo('DK', '101', NULL, NULL) -
                        get_saldo('DK', '1019', NULL, NULL) +
                        get_saldo('DK', '151', NULL, NULL) -
                        get_saldo('DK', '1519', NULL, NULL) AS saldoandmik
-- DK100+DK101-DK1019+DK151-DK1519

-- pohi osa
                 UNION ALL
                 SELECT idx,
                        CASE WHEN artikkel IN ('3880', '3818', '3888') THEN 0 ELSE 1 END AS is_e,
                        l_rekvid                                                         AS rekvid,
                        ''::VARCHAR(20)                                                  AS tegev,
                        ''::VARCHAR(20)                                                  AS allikas,
                        artikkel,
                        nimetus,
                        coalesce(sum(eelarve), 0)                                        AS eelarve,
                        coalesce(sum(tegelik), 0)                                        AS tegelik,
                        coalesce(sum(kassa), 0)                                          AS kassa,
                        get_saldo('KD', artikkel, NULL, NULL)                            AS saldoandmik
                 FROM tmp_andmik q
                 WHERE left(artikkel, 2) NOT IN ('32', '15', '40', '50', '55', '60')
                   AND left(artikkel, 4) NOT IN ('3502', '3823', '2585', '2586', '1001', '4500', '4502')
                   AND left(artikkel, 3) NOT IN ('655', '650', '352', '381', '413', '452')
                   AND tyyp = 1
                 GROUP BY q.idx, artikkel, nimetus
                 UNION ALL
                 SELECT '3.1'::VARCHAR(20)                     AS idx,
                        1                                      AS is_e,
                        l_rekvid                               AS rekvid,
                        qry.tegev,
                        ''::VARCHAR(20)                        AS allikas,
                        ''::VARCHAR(20)                        AS artikkel,
                        l.nimetus,
                        coalesce(sum(eelarve), 0)              AS eelarve,
                        coalesce(sum(tegelik), 0)              AS tegelik,
                        coalesce(sum(kassa), 0)                AS kassa,
                        get_saldo('DK', '4', NULL, qry.tegev) +
                        get_saldo('DK', '5', NULL, qry.tegev) +
                        get_saldo('DK', '6', NULL, qry.tegev) +
                        get_saldo('DK', '15', NULL, qry.tegev) AS saldoandmik
                 FROM tmp_andmik qry
                          LEFT OUTER JOIN library l ON l.kood = qry.tegev AND l.library = 'TEGEV'
                 WHERE tyyp = 1
                   AND not empty(qry.is_kulud)
                   AND qry.artikkel <> '2586'
                   AND qry.tegev NOT IN ('03600', '07210', '07220', '07230', '07240', '07310', '07320', '07340')
                 GROUP BY tegev, l.nimetus
             ) qry;
END;
$$
    LANGUAGE 'plpgsql'
    VOLATILE
    COST 100;


GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbvaatleja;

/*

SELECT *
FROM eelarve_andmik(DATE(2019,03,31), 63, 0)
where (not empty(tegev) or not empty(artikkel))
and tegev = '01112'


select * from tmp_andmik
select * from eelarve where rekvid = 63 and aasta = 2019 and kood1 = '01112'


select get_saldo('MDK','50', null, null)


select * from tmp_andmik where artikkel like '50%'

select coalesce((SELECT sum(case 
	when 'KD' like '%KD' then (kr - db) when 'KD' like '%DK' then (db - kr) 
	else  saldoandmik end) 
			from tmp_andmik s,
			(select min(aasta) as eelmine_aasta, max(aasta) as aasta, min(kuu) as eelmine_kuu, max(kuu) as kuu from tmp_andmik) aasta			
			where s.tyyp = 2
			and s.aasta = case when left('KD',1) = 'M' then aasta.eelmine_aasta else  aasta.aasta end
			and ('50' is null or s.artikkel like trim('50'::text ||  '%'))
						 and (null is null or trim(s.rahavoog) = null)
				and (null is null or trim(s.tegev) = null)
)
			,0)


CREATE TYPE eelarve_andmik_type AS (idx varchar(20), is_e integer, rekvid integer, tegev varchar(20), allikas varchar(20), artikkel varchar(20), nimetus varchar(254), eelarve numeric(14,2), tegelik numeric(14,2), kassa numeric(14,2), saldoandmik numeric(14,2));


--and tegev = '03600'
order by tegev, artikkel


select sum(saldoandmik)  from tmp_andmik where artikkel like '352010%'


select get_saldo('MKD','208', null, null), get_saldo('MKD','258', null, null)

SELECT *
FROM eelarve_andmik(DATE(2019,01,31), 63, 0)
where (not empty(tegev) or not empty(artikkel))
and artikkel = '2580'

SELECT s.aasta, eelmine_aasta, (case f
	when 'KD' like '%KD' then (kr - db) when 'KD' like '%DK' then (db - kr) 
	else  saldoandmik end) 
			from tmp_andmik s,
			(select min(aasta) as eelmine_aasta, max(aasta) as aasta, min(kuu) as eelmine_kuu, max(kuu) as kuu from tmp_andmik) aasta			
			where s.tyyp = 2
			and s.aasta = case when left('KD',1) = 'M' then aasta.eelmine_aasta else  aasta.aasta end
			and s.kuu = case when left('KD',1) = 'M' then aasta.eelmine_kuu else  aasta.kuu end
			and ('30' is null or s.artikkel like trim('30'::text ||  '%'))
			 and (null is null or trim(s.rahavoog) = null)
			 and (null is null or trim(s.tegev) = null)
*/
