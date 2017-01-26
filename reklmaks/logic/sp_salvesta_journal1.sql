-- View: "public.curpalkjaak"

-- DROP VIEW public.curpalkjaak;

CREATE OR REPLACE VIEW public.curpalkjaak AS 
 SELECT asutus.regkood, asutus.nimetus, asutus.aadress, asutus.tel, palk_jaak.kuu, palk_jaak.aasta, palk_jaak.id, palk_jaak.jaak, 
   palk_jaak.arvestatud, palk_jaak.kinni, palk_jaak.tka, palk_jaak.tki, palk_jaak.pm, palk_jaak.tulumaks, palk_jaak.sotsmaks, 
   palk_jaak.muud, tooleping.rekvid, library.kood as osakond
   FROM palk_jaak
   JOIN tooleping ON palk_jaak.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   join library on tooleping.osakondid = library.id;

GRANT ALL ON TABLE public.curpalkjaak TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curpalkjaak TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curpalkjaak TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curpalkjaak TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curpalkjaak TO GROUP dbvaatleja;
