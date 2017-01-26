-- View: curtuludetaitmine

 DROP VIEW curtuludetaitmine;

CREATE OR REPLACE VIEW curtuludetaitmine AS 
 SELECT month(journal.kpv)::integer as kuu, year(journal.kpv)::integer as aasta, journal.rekvid, rekv.nimetus, journal1.tunnus AS tun, 
	sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.kood2
   FROM journal inner join journal1 on journal.id = journal1.parentid
   left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
   JOIN fakttulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(fakttulud.kood::text))
   JOIN rekv ON journal.rekvid = rekv.id
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus;

ALTER TABLE curtuludetaitmine OWNER TO vlad;
GRANT SELECT ON TABLE curtuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curtuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curtuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curtuludetaitmine TO dbvaatleja;

