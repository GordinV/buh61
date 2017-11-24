-- View: curkulum

-- DROP VIEW curkulum;

CREATE OR REPLACE VIEW curkulum AS 
 SELECT library.id, pv_oper.liik, (pv_oper.summa * IFNULL(dokvaluuta1.kuurs,1))::numeric(12,4) as summa, pv_oper.kpv, library.rekvid, grupp.nimetus AS grupp, nomenklatuur.kood, 
	nomenklatuur.nimetus AS opernimi, pv_kaart.soetmaks, pv_kaart.soetkpv, pv_kaart.kulum, pv_kaart.algkulum, pv_kaart.gruppid, 
	pv_kaart.konto, pv_kaart.tunnus, ifnull(asutus.nimetus, space(254)) AS vastisik, library.kood AS ivnum, library.kood AS invnum, 
	library.nimetus AS pohivara
   FROM library
   JOIN pv_oper ON library.id = pv_oper.parentid
   JOIN pv_kaart ON library.id = pv_kaart.parentid
   JOIN library grupp ON pv_kaart.gruppid = grupp.id
   LEFT JOIN asutus ON pv_kaart.vastisikid = asutus.id
   left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
   JOIN nomenklatuur ON pv_oper.nomid = nomenklatuur.id;

ALTER TABLE curkulum OWNER TO vlad;
GRANT ALL ON TABLE curkulum TO vlad;
GRANT SELECT ON TABLE curkulum TO public;
GRANT SELECT ON TABLE curkulum TO dbpeakasutaja;
GRANT SELECT ON TABLE curkulum TO dbkasutaja;
GRANT SELECT ON TABLE curkulum TO dbadmin;
GRANT SELECT ON TABLE curkulum TO dbvaatleja;
GRANT ALL ON TABLE curkulum TO taabel;

