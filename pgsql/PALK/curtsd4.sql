-- View: curtsd4

-- DROP VIEW curtsd4;

CREATE OR REPLACE VIEW curtsd4 AS 
 SELECT rekv.parentid, palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, tooleping.resident, tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(IFNULL(palk_oper.summa,0)::numeric,0)
            ELSE 0::numeric
        END AS erisood_0110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0400, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0410, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0401, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0411, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0500, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0510, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0501, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0511, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0600, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0610, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0601, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0611, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_6311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0700, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0710, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0701, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0711, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_7311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0800, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0810, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0801, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0811, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_8311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0900, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0910, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0901, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_0911, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1000, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1010, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1001, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1011, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 0 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 AND palk_lib.sots = 0 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 AND palk_lib.sots = 1 AND palk_kaart.tulumaks = 1 THEN IFNULL(palk_oper.summa,0)::numeric
            ELSE 0::numeric
        END AS erisood_1111
   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid
   JOIN rekv ON palk_oper.rekvid = rekv.id
  WHERE palk_lib.liik = 9;

ALTER TABLE curtsd4 OWNER TO vlad;
GRANT ALL ON TABLE curtsd4 TO vlad;
GRANT SELECT ON TABLE curtsd4 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbvaatleja;
GRANT SELECT, REFERENCES, TRIGGER ON TABLE curtsd4 TO public;

