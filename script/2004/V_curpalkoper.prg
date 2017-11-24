CREATE SQL VIEW CURPALKOPER_ AS;
SELECT Library.tun1, Library.tun2, Library.tun3, Library.tun4,;
  Library.tun5, Library.nimetus, Asutus.nimetus AS isik,;
  Asutus.id AS isikid,;
  IIF(ISNULL(Journalid.number),0,Journalid.number) AS journalid,;
  Palk_oper.journal1id, Palk_oper.kpv, Palk_oper.summa, Palk_oper.id,;
  Palk_oper.libid, Palk_oper.rekvid, Tooleping.pank, Tooleping.aa,;
  Tooleping.osakondid,;
  IIF(liik=1,"+",IIF(liik=2.OR.liik=6.OR.liik=4.OR.liik=8,"-",IIF(liik=7.AND.asutusest=0,"-","%"))) AS liik,;
  IIF(tund=1,"KOIK",IIF(tund=2,"PAEV",IIF(tund=3,"OHT",IIF(tund=4,"OO",IIF(tund=5,"PUHKUS",IIF(tund=6,"PUHA","ULETOO")))))) AS tund,;
  IIF(maks=1,"JAH","EI ") AS maks;
 FROM ;
     buhdata5!palk_oper ;
    INNER JOIN buhdata5!Library ;
   ON  Palk_oper.libid = Library.id ;
    INNER JOIN buhdata5!palk_lib ;
   ON  Palk_lib.parentid = Library.id ;
    INNER JOIN buhdata5!tooleping ;
   ON  Palk_oper.lepingid = Tooleping.id ;
    INNER JOIN buhdata5!asutus ;
   ON  Tooleping.parentid = Asutus.id ;
    LEFT OUTER JOIN buhdata5!journalid ;
   ON  Palk_oper.journalid = Journalid.journalid


lError = DBSetProp('CURPALKOPER_','View','FetchAsNeeded',.T.)
