-- View: "public.curtaabel1"

-- DROP VIEW public.curtaabel1;

CREATE OR REPLACE VIEW public.curtaabel1 AS 
 SELECT palk_taabel1.id, palk_taabel1.kokku, palk_taabel1.toolepingid, palk_taabel1.ohtu, palk_taabel1.oo, palk_taabel1.too, 
 palk_taabel1.paev, palk_taabel1.tahtpaev, palk_taabel1.puhapaev, palk_taabel1.kuu, palk_taabel1.aasta, amet.kood AS ametikood, 
amet.nimetus AS amet, osakond.kood AS osakonnakood, osakond.nimetus AS osakond, asutus.nimetus AS isik, asutus.regkood AS isikukood, 
tooleping.rekvid
   FROM palk_taabel1
   JOIN tooleping ON palk_taabel1.toolepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   JOIN library amet ON tooleping.ametid = amet.id
   JOIN library osakond ON tooleping.osakondid = osakond.id;

GRANT ALL ON TABLE public.curtaabel1 TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curtaabel1 TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curtaabel1 TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curtaabel1 TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curtaabel1 TO GROUP dbvaatleja;
