-- View: curteenused

 DROP VIEW curteenused;

CREATE OR REPLACE VIEW curteenused AS 
 SELECT arv.id, arv.rekvid, arv.journalid, arv.liik, arv.number, arv.kpv, arv1.kogus, arv1.summa, asutus.regkood, asutus.nimetus AS asutus, nomenklatuur.kood, nomenklatuur.nimetus, nomenklatuur.uhik, arv1.hind, arv1.kbm, asutus.omvorm, arv1.summa - arv1.kbm AS kbmta, 
        CASE
            WHEN nomenklatuur.doklausid = 0 THEN 18
            ELSE 
            CASE
                WHEN nomenklatuur.doklausid = 1 OR nomenklatuur.doklausid = 3 THEN 0
                ELSE 
			CASE
				WHEN nomenklatuur.doklausid = 2 THEN 5
			ELSE 
			CASE
				WHEN nomenklatuur.doklausid = 5 THEN 20
                        ELSE 
			CASE
				WHEN nomenklatuur.doklausid = 4 THEN 9
                        ELSE
                        NULL::integer
			END
                    end
                END
            END
        END AS kaibemaks, arv1.kood4 AS uritus, arv1.proj, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, ifnull(arv.objekt::bpchar, space(20))::character varying AS objekt
   FROM arv
   JOIN arv1 ON arv.id = arv1.parentid
   JOIN asutus ON arv.asutusid = asutus.id
   JOIN nomenklatuur ON arv1.nomid = nomenklatuur.id
   LEFT JOIN dokvaluuta1 ON arv1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 2;

ALTER TABLE curteenused OWNER TO vlad;
GRANT ALL ON TABLE curteenused TO vlad;
GRANT SELECT ON TABLE curteenused TO dbpeakasutaja;
GRANT SELECT ON TABLE curteenused TO dbkasutaja;
GRANT SELECT ON TABLE curteenused TO dbvaatleja;

