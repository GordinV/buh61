-- View: "public.curvaravendor"

-- DROP VIEW public.curvaravendor;

CREATE OR REPLACE VIEW public.qryKassaTulutaitm  AS 
SELECT   curjournal.KPV, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun, summa, curjournal.kood5 AS kood, space(1) AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id;

GRANT ALL ON TABLE public.qryKassaTulutaitm TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.qryKassaTulutaitm TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.qryKassaTulutaitm TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.qryKassaTulutaitm TO GROUP dbadmin;
GRANT SELECT ON TABLE public.qryKassaTulutaitm TO GROUP dbvaatleja;
