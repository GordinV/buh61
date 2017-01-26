-- View: curkuludetaitmine
/*
select * from curkuludetaitmine where rekvid = 6 and aasta = 2010
*/
 DROP VIEW curkuludetaitmine;

CREATE OR REPLACE VIEW curkuludetaitmine AS 
 SELECT month(journal.kpv)::integer as kuu, year(journal.kpv)::integer as aasta, journal.rekvid, sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)) AS summa, journal1.kood5 AS kood, 
	space(1) AS eelarve, journal1.kood1 AS tegev, journal1.tunnus AS tun, journal1.kood2
   FROM journal inner join journal1 on journal.id = journal1.parentId
   left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokliik = 1)
   JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2;

ALTER TABLE curkuludetaitmine OWNER TO vlad;
GRANT ALL ON TABLE curkuludetaitmine TO vlad;
GRANT SELECT ON TABLE curkuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkuludetaitmine TO dbvaatleja;
GRANT ALL ON TABLE curkuludetaitmine TO taabel;

