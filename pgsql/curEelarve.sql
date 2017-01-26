-- View: cureelarve

--DROP VIEW cureelarve;

CREATE OR REPLACE VIEW cureelarve AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.summa, eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus AS tun, 
	rekv.nimetus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(tunnus.kood, space(20)) AS tunnus, ifnull(parent.nimetus, space(254)) AS parasutus, 
	ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, 
	ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library tunnus ON eelarve.tunnusid = tunnus.id
   LEFT JOIN dokvaluuta1 ON (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8);

ALTER TABLE cureelarve OWNER TO vlad;
GRANT ALL ON TABLE cureelarve TO vlad;
GRANT SELECT ON TABLE cureelarve TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarve TO dbkasutaja;
GRANT SELECT ON TABLE cureelarve TO dbadmin;
GRANT SELECT ON TABLE cureelarve TO dbvaatleja;

