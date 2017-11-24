-- View: "public.curkassatuludetaitmine"

--DROP VIEW public.curkassatuludetaitmine;

CREATE OR REPLACE VIEW public.curkassatuludetaitmine AS 
 SELECT kuu, aasta, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun, sum(summa) AS summa, curjournal.kood5 AS kood, space(1)::bpchar AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
  inner join rekv on curJournal.rekvid = rekv.id
  GROUP BY aasta, kuu, curjournal.rekvid, rekv.nimetus, curjournal.kreedit, curjournal.kood1, curjournal.kood5, curjournal.tunnus
  ORDER BY aasta, kuu, curjournal.rekvid, rekv.nimetus, curjournal.kreedit, curjournal.kood1, curjournal.kood5, curjournal.tunnus;

GRANT ALL ON TABLE public.curkassatuludetaitmine TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curkassatuludetaitmine TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curkassatuludetaitmine TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curkassatuludetaitmine TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curkassatuludetaitmine TO GROUP dbvaatleja;
