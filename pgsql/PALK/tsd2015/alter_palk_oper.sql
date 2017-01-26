/*
alter table palk_oper add column tulumaks numeric (18,2),
	add column sotsmaks numeric(18,2),
	add column tootumaks numeric(18,2),
	add column pensmaks numeric (18,2);
alter table palk_oper add column tulubaas numeric(18,2);
alter table palk_oper add column tka numeric(18,2);
alter table palk_oper add column period date;

 DROP INDEX if exists ix_palk_oper_kpv;
 
CREATE INDEX ix_palk_oper_kpv
  ON palk_oper
  USING btree
  (kpv);

alter table palk_kaart add column minsots integer;


*/

CREATE OR REPLACE FUNCTION tmp_tsd_2015()
  RETURNS void AS
$BODY$
declare 
	l_id integer = 0;
begin
/*
	select id into l_id from menupohi where pad = 'Library' and bar = '63';
	l_id = 1
	if l_id is null or l_id = 0 then
		raise notice 'Lisame menu Maksukoodid';		
		insert into menupohi (omandus, level_, proc_, pad, bar, idx)
			values ('RUS CAPTION=Maksukoodid
				EST CAPTION=Maksukoodid
				', 1,'oMaksuKoodid = nObjekt("MaksuKoodid","oMaksuKoodid")','Library','63',3 );

		select id into l_id from menupohi order by id desc limit 1;

--		select * from menupohi order by id desc limit 10
	end if;
	if (select count(*) from menuisik where parentId = l_id) = 0 then
		insert into menuisik (parentid, gruppid, userid, jah, ei) 
			values (l_id, 'PEAKASUTAJA',0,1,0);
	end if;
	if (select count(*) from menumodul where parentId = l_id) = 0 then
		insert into menumodul (parentid, modul) 
			values (l_id, 'EELARVE');
		insert into menumodul (parentid, modul) 
			values (l_id, 'PALK');
	END IF;
	select id into l_id from menupohi where pad = 'MaksuKoodid' and bar is null;
	if l_id is null or l_id = 0 then
		insert into menupohi (omandus, level_, pad, idx)
			values ('RUS CAPTION=Maksukoodid
				EST CAPTION=Maksukoodid
				', 2,'Library',0 );

		select id into l_id from menupohi order by id desc limit 1;
	end if;

	if (select count(*) from menuisik where parentId = l_id) = 0 then
		insert into menuisik (parentid, gruppid, userid, jah, ei) 
			values (l_id, 'PEAKASUTAJA',0,1,0);
	end if;
	if (select count(*) from menumodul where parentId = l_id) = 0 then
		insert into menumodul (parentid, modul) 
			values (l_id, 'EELARVE');
		insert into menumodul (parentid, modul) 
			values (l_id, 'PALK');
	END IF;

*/
--	tulumaksu koodid
--	Tulumaks -> tun1, Sotsiaal-maks -> tun2, Sotsiaalmaks kuumääralt ->tun3, Töötuskind-lustusmakse-> tun4, Kogumispension -> tun5
	if (select count(*) from library where library = 'MAKSUKOOD') = 0 then
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'10','palgatulu', 'MAKSUKOOD', 20,1,1,1,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'11','palgatulu, töö välisriigis, Eesti A1/E101', 'MAKSUKOOD', 0,1,1,1,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'12','palgatulu, töö Eestis, välisriigi A1/E101', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'13','kõrgete ametiisikute palgatulu ', 'MAKSUKOOD', 20,1,1,0,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'14','öötajale lapse sünni puhul tulumaksuvaba piirmäära ulatuses ', 'MAKSUKOOD', 0,1,0,1,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'15','seaduse või muu õigusakti alusel töö tegemise eest makstud tasu', 'MAKSUKOOD', 20,1,0,0,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'16','muu väljamakse töötajale ja ametnikule, mida maksustatakse ainult TM', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'17','töövõtu-, käsundus või muu võlaõiguslik leping', 'MAKSUKOOD', 20,1,0,1,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'18','füüsilise isiku poolt VÕS lepingu alusel makstud töö- või teenustasu', 'MAKSUKOOD', 0,1,0,1,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'19','VÕS lepingu alusel makstud töö- või teenustasu, töö välisriigis, Eesti A1/E101', 'MAKSUKOOD', 0,1,0,1,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'20','VÕS alusel makstud töö- või teenustasu, töö Eestis, välisriigi A1/E101', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'21','juriidilise isiku juhtimis- või kontrollorgani liikme tasu', 'MAKSUKOOD', 20,1,0,0,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'22','juriidilise isiku juhtimis- või kontrollorgani liikme tasu, Eesti A1/E101', 'MAKSUKOOD', 0,1,0,0,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'23','juriidilise isiku juhtimis- või kontrollorgani liikme tasu, välisriigi A1/E101', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'24','tööandja makstud haigushüvitis', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'25','töötaja või ametniku eest tasutud III samba sissemakse', 'MAKSUKOOD', 20,1,1,1,1,'610,640');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'26','töötaja või ametniku eest tasutud III samba sissemakse, Eesti A1/E101', 'MAKSUKOOD', 0,1,1,1,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'27','töötaja või ametniku eest tasutud III samba sissemakse, välisriigi A1/E101, maksustatakse TM', 'MAKSUKOOD', 20,0,0,0,0, '610,640');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'28','kõrgete ametiisikute eest tasutud III samba sissemaksed', 'MAKSUKOOD', 20,1,1,0,1,'610,640');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'29','juriidilise isiku juhtimis- või kontrollorgani liikme eest tasutud III samba sissemakse', 'MAKSUKOOD', 20,1,0,0,1,'610,640');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'30','juriidilise isiku juhtimis- või kontrollorgani liikme eest tasutud III samba sissemakse, Eesti A1/E101', 'MAKSUKOOD', 0,1,0,0,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'31','juriidilise isiku juhtimis- või kontrollorgani liikme eest tasutud III samba sissemakse, välisriigi A1/E101', 'MAKSUKOOD', 20,0,0,0,0,'610,640');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'32','tööõnnetus- või kutsehaigushüviti', 'MAKSUKOOD', 20,0,0,0,0,'610,630');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'33','töötajale töölepingu ülesütlemisel või ametnikule teenistusest vabastamisel makstud hüvitis', 'MAKSUKOOD', 20,1,1,0,1,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values (63,'34','töötajale töölepingu ülesütlemisel või ametnikule teenistusest vabastamisel makstud hüvitis, töö välisriigis, Eesti A1/E101', 'MAKSUKOOD', 0,1,1,0,1);
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'35','töötajale töölepingu ülesütlemisel või ametnikule teenistusest vabastamisel makstav hüvitis, töö Eestis, välisriigi A1/E101', 'MAKSUKOOD', 20,0,0,0,0,'610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'45','täiendava kogumispensioni väljamakse (20% maksumäär)', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'46','täiendava kogumispensioni väljamakse (10% maksumäär)', 'MAKSUKOOD', 10,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'47','investeerimisriskiga elukindlustuslepingu alusel makstud summa', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'50','rendi- või üüritasu ning litsentsitasud, v.a põllumajandusmaa renditulu', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'51','Loovisikule ja spordiseaduse §-s 7 nimetatud isikule makstud lähetuskulude hüvitis ja päevaraha ning kolmanda isiku poolt makstud päevaraha, mis ületab piirmäära  ', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'54','intressid', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'55','muu tulu, k.a. stipendium, toetus, kultuuri., spordi- ja teaduspreemia, hasartmänguvõit', 'MAKSUKOOD', 20,0,0,0,0, '610');
		insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud) values (63,'56',' põllumajandusmaa renditulu', 'MAKSUKOOD', 20,0,0,0,0, '610');
	end if;
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select tmp_tsd_2015();

drop function if exists tmp_tsd_2015();
