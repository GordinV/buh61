-- View: curtsd
/*
DROP VIEW curtsd4;

select * from curtsd4

SELECT sum(Curtsd4.erisood_0100) as eris0100,sum(Curtsd4.erisood_0101) as eris0101,sum(Curtsd4.erisood_0110) as eris0110,sum(Curtsd4.erisood_0111) as eris0111,
 sum(Curtsd4.erisood_0200) as eris0200,  sum(Curtsd4.erisood_0201) as eris0201,  sum(Curtsd4.erisood_0210) as eris0210,  sum(Curtsd4.erisood_0211) as eris0211,  
 sum(Curtsd4.erisood_0300) as eris0300, sum(Curtsd4.erisood_0301) as eris0301, sum(Curtsd4.erisood_0310) as eris0310, sum(Curtsd4.erisood_0311) as eris0311, 
 sum(Curtsd4.erisood_0400) as eris0400, sum(Curtsd4.erisood_0401) as eris0401, sum(Curtsd4.erisood_0410) as eris0410, sum(Curtsd4.erisood_0411) as eris0411, 
  sum(Curtsd4.erisood_0500) as eris0500, sum(Curtsd4.erisood_0501) as eris0501, sum(Curtsd4.erisood_0510) as eris0510, sum(Curtsd4.erisood_0511) as eris0511, 
   sum(Curtsd4.erisood_0600) as eris0600,sum(Curtsd4.erisood_0601) as eris0601, sum(Curtsd4.erisood_0610) as eris0610, sum(Curtsd4.erisood_0611) as eris0611,  
   sum(Curtsd4.erisood_0700) as eris0700, sum(Curtsd4.erisood_0701) as eris0701, sum(Curtsd4.erisood_0710) as eris0710, sum(Curtsd4.erisood_0711) as eris0711, 
 sum(Curtsd4.erisood_0800) as eris0800, sum(Curtsd4.erisood_0801) as eris0801, sum(Curtsd4.erisood_0810) as eris0810, sum(Curtsd4.erisood_0811) as eris0811,  
 sum(Curtsd4.erisood_0900) as eris0900, sum(Curtsd4.erisood_0901) as eris0901, sum(Curtsd4.erisood_0910) as eris0910, sum(Curtsd4.erisood_0911) as eris0911,  
 sum(Curtsd4.erisood_1000) as eris1000,sum(Curtsd4.erisood_1001) as eris1001, sum(Curtsd4.erisood_1010) as eris1010, sum(Curtsd4.erisood_1011) as eris1011,  
 sum(Curtsd4.erisood_1100) as eris1100, sum(Curtsd4.erisood_1101) as eris1101, sum(Curtsd4.erisood_1110) as eris1110, sum(Curtsd4.erisood_1111) as eris1111 
 FROM  curtsd4  
 WHERE  rekvid = ?gRekv  or parentid = ?tnParentRekvId)  AND CAST(osakondId AS INT) >= ?tnOsakondId1   AND CAST(osakondId AS INT) <= ?tnOsakondId2   AND kpv >= ?tdKpv1   AND kpv <= ?tdKpv2
*/
CREATE OR REPLACE VIEW curtsd4 AS 
 SELECT rekv.parentid, palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, tooleping.resident,
	tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, 
	palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 0  and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0110, 
       CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 0  and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0   THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0400, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0410, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1   THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0401, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0411, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0500, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0510, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0501, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0511, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0600, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0610, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0601, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0611, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0700, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0710, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0701, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0711, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7110, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7210, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7310, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0800, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0810, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0801, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0811, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8110, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8210, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8310, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0900, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0910, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0901, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0911, 
 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1000, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1010, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1001, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1011, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1100,
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1110, 
               CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1101,
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1111

   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid
   Join rekv on palk_oper.rekvid = rekv.id
   where palk_lib.liik = 9;

ALTER TABLE curtsd4 OWNER TO vlad;
GRANT SELECT ON TABLE curtsd4 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbvaatleja;

