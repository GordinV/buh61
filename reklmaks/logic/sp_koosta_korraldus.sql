-- View: "public.comtooleping"

-- DROP VIEW public.comtooleping;

CREATE OR REPLACE VIEW public.comtooleping AS 
 SELECT tooleping.id, asutus.nimetus AS isik, asutus.regkood AS isikukood, osakonnad.kood AS osakond, osakonnad.id AS osakondid, 
	ametid.kood AS amet, ametid.id AS ametid, tooleping.algab, tooleping.lopp, tooleping.toopaev, tooleping.palk, 
	tooleping.palgamaar, tooleping.pohikoht, tooleping.koormus, tooleping.ametnik, tooleping.pank, tooleping.aa, tooleping.rekvid, 
	tooleping.parentid
   FROM asutus
   JOIN tooleping ON asutus.id = tooleping.parentid
   JOIN library osakonnad ON tooleping.osakondid = osakonnad.id
   JOIN library ametid ON tooleping.ametid = ametid.id;

GRANT ALL ON TABLE public.comtooleping TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.comtooleping TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.comtooleping TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.comtooleping TO GROUP dbadmin;
GRANT SELECT ON TABLE public.comtooleping TO GROUP dbvaatleja;
