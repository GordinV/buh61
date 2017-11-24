-- View: qrykassatulutaitm

 DROP VIEW qrykassatulutaitm;

CREATE OR REPLACE VIEW qrykassatulutaitm AS 
 SELECT curjournal.kpv, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun,  curjournal.summa * curjournal.kuurs::numeric as summa, curjournal.kood5 AS kood, space(1) AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id;

ALTER TABLE qrykassatulutaitm OWNER TO vlad;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbpeakasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbkasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbadmin;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbvaatleja;

