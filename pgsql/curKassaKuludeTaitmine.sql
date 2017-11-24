-- View: curkassakuludetaitmine

-- DROP VIEW curkassakuludetaitmine;

CREATE OR REPLACE VIEW curkassakuludetaitmine AS 
 SELECT month(journal.kpv)::integer as kuu, year(journal.kpv)::integer as aasta, journal.rekvid, 
	sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1))::numeric AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, 
	journal1.tunnus AS tun, journal1.kood2
   FROM journal inner join journal1 on journal1.parentid = journal.id 
   left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
   JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2;

ALTER TABLE curkassakuludetaitmine OWNER TO vlad;
GRANT ALL ON TABLE curkassakuludetaitmine TO vlad;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbvaatleja;

