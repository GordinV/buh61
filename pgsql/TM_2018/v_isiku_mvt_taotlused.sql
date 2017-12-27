DROP VIEW IF EXISTS v_isiku_mvt_taotlused;

CREATE VIEW v_isiku_mvt_taotlused AS
  SELECT
    sum(kuu_summa) AS summa,
    isikId,
    kuu,
    aasta
  FROM (
         SELECT
           tooleping.parentId AS isikId,
           t.lepingid,
           t.summa            AS summa,
           alg_kpv,
           lopp_kpv,
           v_month.kuu,
           year(lopp_kpv)     AS aasta,
           CASE WHEN month(alg_kpv) <= v_month.kuu AND month(lopp_kpv) >= v_month.kuu
             THEN t.summa
           ELSE 0 END         AS kuu_summa
         FROM taotlus_mvt t, (SELECT 1 AS kuu
                              UNION
                              SELECT 2 AS kuu
                              UNION
                              SELECT 3 AS kuu
                              UNION
                              SELECT 4 AS kuu
                              UNION
                              SELECT 5 AS kuu
                              UNION
                              SELECT 6 AS kuu
                              UNION
                              SELECT 7 AS kuu
                              UNION
                              SELECT 8 AS kuu
                              UNION
                              SELECT 9 AS kuu
                              UNION
                              SELECT 10 AS kuu
                              UNION
                              SELECT 11 AS kuu
                              UNION
                              SELECT 12 AS kuu
           ) v_month, tooleping
         WHERE tooleping.id = t.lepingId
               AND t.summa > 0
       ) qry
  GROUP BY isikid, aasta, kuu;


GRANT ALL ON TABLE v_isiku_mvt_taotlused TO dbkasutaja;
GRANT ALL ON TABLE v_isiku_mvt_taotlused TO dbpeakasutaja;

/*

select * from asutus where regkood = '45909033718'

select * from taotlus_mvt where lepingid in (select id from tooleping where parentId = 34200)

select * from v_month

create view v_month as
select 1 as kuu
union
select 2 as kuu
union
select 3 as kuu
union
select 4 as kuu
union
select 5 as kuu
union
select 6 as kuu
union
select 7 as kuu
union
select 8 as kuu
union
select 9 as kuu
union
select 10 as kuu
union
select 11 as kuu
union
select 12 as kuu

 */