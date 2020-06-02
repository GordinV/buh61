

 DROP VIEW cureelarve;

CREATE OR REPLACE VIEW cureelarve AS 
 SELECT 
	eelarve.id, eelarve.rekvid, eelarve.aasta, 
	eelarve.summa, 
	eelarve.summa_k as summa_k, -- parandus 2020
	eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus AS tun, rekv.nimetus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(tunnus.kood, space(20)) AS tunnus, ifnull(parent.nimetus, space(254)) AS parasutus, ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   JOIN library ON eelarve.kood5::bpchar = library.kood AND library.library = 'TULUDEALLIKAD'::bpchar
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library tunnus ON eelarve.tunnusid = tunnus.id
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = eelarve.id AND dokvaluuta1.dokliik = 8
  WHERE library.tun5 = 1;

ALTER TABLE cureelarve OWNER TO vlad;
GRANT ALL ON TABLE cureelarve TO vlad;
GRANT SELECT ON TABLE cureelarve TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarve TO dbkasutaja;
GRANT SELECT ON TABLE cureelarve TO dbadmin;
GRANT SELECT ON TABLE cureelarve TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE cureelarve TO public;



DROP VIEW if exists cureelarvekulud;

CREATE OR REPLACE VIEW cureelarvekulud AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasid, 
	eelarve.summa, 
	eelarve.summa_k as summa_k,
	eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, ifnull(t.kood, space(20))::character varying AS tunnus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(parent.nimetus, space(254)) AS parasutus, ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, eelarve.tunnus AS tun
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   JOIN library ON eelarve.kood5::bpchar = library.kood AND library.library = 'TULUDEALLIKAD'::bpchar
   LEFT JOIN dokvaluuta1 ON eelarve.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 8
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library t ON t.id = eelarve.tunnusid
  WHERE library.tun5 = 2;

ALTER TABLE cureelarvekulud OWNER TO vlad;
GRANT ALL ON TABLE cureelarvekulud TO vlad;
GRANT SELECT ON TABLE cureelarvekulud TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbkasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbadmin;
GRANT SELECT ON TABLE cureelarvekulud TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE cureelarvekulud TO public;

