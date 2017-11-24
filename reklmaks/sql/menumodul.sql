-- Index: public.leping_idx

-- DROP INDEX public.leping_idx;

CREATE INDEX leping_idx
  ON public.tooleping
  USING btree
  (osakondid, ametid);


CREATE INDEX parentid_idx
  ON public.tooleping
  USING btree
  (parentid);

CREATE INDEX "palk_kaart_lepingId_idx"
  ON public.palk_kaart
  USING btree
  (lepingid, libid);

CREATE INDEX palk_kaart_parentid_idx
  ON public.palk_kaart
  USING btree
  (parentid);

CREATE INDEX "palk_lib_parentId_idx"
  ON public.palk_lib
  USING btree
  (parentid);

CREATE INDEX eelarveklassif
   ON public.eelarve USING btree (kood1, kood2, kood3, kood4, kood5);

CREATE INDEX asutusaa_parentid_idx
   ON public.asutusaa USING btree (parentid);

CREATE INDEX asutus_kood
  ON public.asutus
  USING btree
  (regkood, nimetus);

CREATE INDEX "dokprop_parentId_idx"
   ON public.dokprop USING btree (parentid);

CREATE INDEX korder1_rekvtyyp_idx
   ON public.korder1 USING btree (rekvid, tyyp);

CREATE INDEX korder2_parentid_idx
   ON public.korder2 USING btree (parentid, nomid);

CREATE INDEX library_kood_idx
   ON public.library USING btree (kood, nimetus, library);

CREATE INDEX nomenklatuur_kood_idx
   ON public.nomenklatuur USING btree (kood, nimetus);

CREATE INDEX paalk_asutus_ametid_idx
   ON public.palk_asutus USING btree (rekvid, osakondid, ametid);

CREATE INDEX palk_jaak_idx
   ON public.palk_jaak USING btree (lepingid, kuu, aasta);

CREATE INDEX pv_kaart_parentid_idx
   ON public.pv_kaart USING btree (parentid, gruppid);

CREATE INDEX pv_oper_parentid_idx
   ON public.pv_oper USING btree (parentid, nomid, kpv);

CREATE INDEX puudumine_lepingid_idx
   ON public.puudumine USING btree (lepingid, kpv1, kpv2);

CREATE INDEX toograf_lepingid_idx
   ON public.toograf USING btree (lepingid, kuu, aasta);












