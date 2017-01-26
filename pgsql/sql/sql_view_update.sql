DROP VIEW cureelarve;

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


 DROP VIEW cureelarvekulud;

CREATE OR REPLACE VIEW cureelarvekulud AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasid, eelarve.summa, eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, 
 ifnull(t.kood, space(20))::character varying AS tunnus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(parent.nimetus, space(254)) AS parasutus,
  ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud,
  ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   LEFT JOIN dokvaluuta1 ON (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library t ON t.id = eelarve.tunnusid;

ALTER TABLE cureelarvekulud OWNER TO vlad;
GRANT SELECT ON TABLE cureelarvekulud TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbkasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbadmin;
GRANT SELECT ON TABLE cureelarvekulud TO dbvaatleja;

 DROP VIEW curkassakuludetaitmine;

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

 DROP VIEW curkassatuludetaitmine;

CREATE OR REPLACE VIEW curkassatuludetaitmine AS 
 SELECT month(journal.kpv)::integer as kuu, year(journal.kpv)::integer as aasta, journal.rekvid, rekv.nimetus, journal1.tunnus AS tun, 
	sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.kood2
   FROM journal inner join journal1 on journal.id = journal1.parentid
   left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
   JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON journal.rekvid = rekv.id
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus;

ALTER TABLE curkassatuludetaitmine OWNER TO vlad;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbvaatleja;


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



 DROP VIEW curpalkoper;

CREATE OR REPLACE VIEW curpalkoper AS 
 SELECT library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus, asutus.nimetus AS isik, asutus.id AS isikid, ifnull(journalid.number, 0) AS journalid, palk_oper.journal1id, palk_oper.kpv, palk_oper.summa, palk_oper.id, palk_oper.libid, palk_oper.rekvid, tooleping.pank, tooleping.aa, tooleping.osakondid, 
        CASE
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '1-0'::bpchar THEN '+'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '2-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '6-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '4-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '8-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '7-0'::bpchar THEN '-'::text::bpchar
            ELSE '%'::bpchar
        END AS liik, 
        CASE
            WHEN palk_lib.tund = 1 THEN 'KOIK'::text
            WHEN palk_lib.tund = 2 THEN 'PAEV'::text
            WHEN palk_lib.tund = 3 THEN 'OHT'::text
            WHEN palk_lib.tund = 4 THEN 'OO'::text
            WHEN palk_lib.tund = 5 THEN 'PUHKUS'::text
            WHEN palk_lib.tund = 6 THEN 'PUHA'::text
            WHEN palk_lib.tund = 7 THEN 'ULETOO'::text
            ELSE NULL::text
        END AS tund, 
        CASE
            WHEN palk_lib.maks = 1 THEN 'JAH'::text
            ELSE 'EI'::text
        END AS maks,
        ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
   FROM palk_oper
   JOIN library ON palk_oper.libid = library.id
   JOIN palk_lib ON palk_lib.parentid = library.id
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   LEFT JOIN journalid ON palk_oper.journalid = journalid.journalid
   left join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokliik = 12);

ALTER TABLE curpalkoper OWNER TO vlad;
GRANT SELECT ON TABLE curpalkoper TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper TO dbpeakasutaja;



DROP VIEW curpalkoper3;

CREATE OR REPLACE VIEW curpalkoper3 AS 
 SELECT palk_oper.summa, palk_oper.kpv, palk_oper.rekvid, asutus.nimetus AS isik, asutus.id AS isikid, asutus.regkood AS isikukood, palk_lib.liik, 
	palk_lib.asutusest, osakond.kood AS okood, amet.kood AS akood, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta
   FROM palk_oper
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN library lib ON lib.id = palk_lib.parentid
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   JOIN library osakond ON osakond.id = tooleping.osakondid
   JOIN library amet ON amet.id = tooleping.ametid
left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
   ;

ALTER TABLE curpalkoper3 OWNER TO vlad;
GRANT SELECT ON TABLE curpalkoper3 TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper3 TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper3 TO dbpeakasutaja;

DROP VIEW curpohivara;

CREATE OR REPLACE VIEW curpohivara AS 
 SELECT library.id, library.kood, library.nimetus, library.rekvid, pv_kaart.vastisikid, ifnull(asutus.nimetus, space(254)) AS vastisik, pv_kaart.algkulum, pv_kaart.kulum, pv_kaart.soetmaks, pv_kaart.parhind, pv_kaart.soetkpv, grupp.nimetus AS grupp, pv_kaart.konto, pv_kaart.gruppid, pv_kaart.tunnus, pv_kaart.mahakantud, pv_kaart.muud::character varying(254) AS rentnik, 
        CASE
            WHEN pv_kaart.kulum > 0::numeric THEN 'Pohivara'::text
            ELSE 'Vaikevahendid'::text
        END AS liik,
        ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs
   FROM library
   JOIN pv_kaart ON library.id = pv_kaart.parentid
   left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokvaluuta1.dokliik = 18)
   JOIN library grupp ON pv_kaart.gruppid = grupp.id AND library.rekvid = grupp.rekvid
   LEFT JOIN asutus ON pv_kaart.vastisikid = asutus.id;

ALTER TABLE curpohivara OWNER TO vlad;
GRANT SELECT ON TABLE curpohivara TO dbpeakasutaja;
GRANT SELECT ON TABLE curpohivara TO dbkasutaja;
GRANT SELECT ON TABLE curpohivara TO dbvaatleja;


DROP VIEW cursaldo;

CREATE OR REPLACE VIEW cursaldo AS 
	SELECT journal.kpv, journal.rekvid,   journal1.deebet AS KONTO, 
	(journal1.summa * ifnull(dokvaluuta1.kuurs,1))::numeric as deebet, 0::numeric(12,4) AS kreedit, 
	 4 AS opt, journal.asutusid    
	 FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid   
	 LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
UNION ALL 
	SELECT journal.kpv, journal.rekvid,   journal1.kreedit AS KONTO, 
	0::numeric(12,4) AS deebet, (journal1.summa * ifnull(dokvaluuta1.kuurs,1))::numeric as kreedit,  
	 4 AS opt, journal.asutusid     
	 FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid   
	 LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1);

ALTER TABLE cursaldo OWNER TO vlad;
GRANT ALL ON TABLE cursaldo TO vlad;
GRANT SELECT ON TABLE cursaldo TO dbpeakasutaja;
GRANT SELECT ON TABLE cursaldo TO dbkasutaja;
GRANT SELECT ON TABLE cursaldo TO dbadmin;
GRANT SELECT ON TABLE cursaldo TO dbvaatleja;

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


