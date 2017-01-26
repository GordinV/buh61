-- View: cureelarvekulud

-- DROP VIEW cureelarvekulud;

CREATE OR REPLACE VIEW cureelarvekulud AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasid, eelarve.summa, eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, ifnull(t.kood, space(20))::character varying AS tunnus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(parent.nimetus, space(254)) AS parasutus, ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, eelarve.tunnus AS tun
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   INNER JOIN LIBRARY ON (eelarve.kood5 = library.kood and library.library = 'TULUDEALLIKAD') 
   LEFT JOIN dokvaluuta1 ON eelarve.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 8
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library t ON t.id = eelarve.tunnusid
   where library.tun5 = 2;

ALTER TABLE cureelarvekulud OWNER TO vlad;
GRANT ALL ON TABLE cureelarvekulud TO vlad;
GRANT SELECT ON TABLE cureelarvekulud TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbkasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbadmin;
GRANT SELECT ON TABLE cureelarvekulud TO dbvaatleja;

