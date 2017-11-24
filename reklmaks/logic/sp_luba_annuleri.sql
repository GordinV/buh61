-- View: "public.curkassakuludetaitmine"
--DROP VIEW public.curkassakuludetaitmine;

CREATE OR REPLACE VIEW public.curkassakuludetaitmine AS 
 SELECT kuu, aasta, curjournal.rekvid, sum(summa) AS summa, curjournal.kood5 AS kood, space(1)::bpchar AS eelarve, 
	curjournal.kood1 AS tegev, curjournal.tunnus AS tun
   FROM curjournal
   JOIN kassakulud ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
  GROUP BY aasta, kuu, curjournal.rekvid, curjournal.deebet, curjournal.kood1, curjournal.tunnus, curjournal.kood5
  ORDER BY aasta, kuu, curjournal.rekvid, curjournal.deebet, curjournal.kood1, curjournal.tunnus, curjournal.kood5;

GRANT ALL ON TABLE public.curkassakuludetaitmine TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curkassakuludetaitmine TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curkassakuludetaitmine TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curkassakuludetaitmine TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curkassakuludetaitmine TO GROUP dbvaatleja;

