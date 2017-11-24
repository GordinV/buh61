
CREATE OR REPLACE VIEW public.curpalkoper3 AS 
 SELECT palk_oper.summa, palk_oper.kpv, palk_oper.rekvid, asutus.nimetus AS isik, asutus.regkood AS isikukood, palk_lib.liik, palk_lib.asutusest, osakond.kood AS okood, amet.kood AS akood
   FROM palk_oper
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   JOIN library osakond ON osakond.id = tooleping.osakondid
   JOIN library amet ON amet.id = tooleping.ametid;


GRANT ALL ON TABLE public.curpalkoper TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbvaatleja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbadmin;
