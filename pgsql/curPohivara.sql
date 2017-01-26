-- View: curpohivara

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

