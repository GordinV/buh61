-- Table: hootehingud

-- DROP TABLE hootehingud;

 
ALTER TABLE hootaabel ADD COLUMN tuluarvId integer;
ALTER TABLE hootaabel ALTER COLUMN tuluarvId SET STORAGE PLAIN;
ALTER TABLE hootaabel ALTER COLUMN tuluarvId SET DEFAULT 0;


CREATE TABLE hoouhendused
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  dokid integer NOT NULL DEFAULT 0, -- seotud dokumendiga
  doktyyp character varying(20), -- kui dokid > 0, doktyyp = KASSA,PANK, ARVE
  CONSTRAINT hoouhendused_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hoouhendused OWNER TO vlad;
GRANT ALL ON TABLE hootehingud TO hkametnik;
GRANT ALL ON TABLE hootehingud TO soametnik;


-- Index: hootehingud_dokid

-- DROP INDEX hootehingud_dokid;

CREATE INDEX hoouhendused_dokid
  ON hoouhendused
  USING btree
  (doktyyp, dokid);


CREATE INDEX hoouhendused_isikid
  ON hoouhendused
  USING btree
  (isikid);

ALTER TABLE hoouhendused CLUSTER ON hoouhendused_isikid;


GRANT ALL ON TABLE hoouhendused_id_seq TO public;


CREATE OR REPLACE FUNCTION trigiu_hoouhendused_after()
  RETURNS trigger AS
$BODY$

declare 
	lnAsutusId int;

begin
	if new.doktyyp = 'ARVED' then
		select asutusId into lnAsutusId from arv where id = new.dokid;
		lnAsutusid = ifnull(lnAsutusId,0);
		if lnAsutusId > 0 then
			perform sp_arvesta_hoolepingujaak(lnAsutusId, new.isikId);
		end if;
	end if;

	return null;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_hoouhendused_after() OWNER TO vlad;



CREATE TRIGGER trigiu_hoouhendused_after
  AFTER INSERT OR UPDATE
  ON hoouhendused
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_hoouhendused_after();

/*
select * from hoouhendused

update  hoouhendused set isikid = 3 where isikid = 3

*/



-- Function: sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnIsikId alias for $2;
	tnEttemaksid alias for $3;
	tnDokId alias for $4;
	tcDokTyyp alias for $5;
	tdKpv alias for $6;
	tnSumma alias for $7;
	tcAllikas alias for $8;
	tcTyyp alias for $9;
	ttMuud alias for $10;

	lnId int; 
	lrCurRec record;
	lnTehinguSumma numeric;
	lnEttemaksuSumma numeric;
begin
if tnId = 0 then
	-- uus kiri
	insert into hootehingud (isikid, ettemaksid,dokid,doktyyp, kpv ,summa ,allikas,tyyp, muud) 
		values (tnIsikid, tnettemaksid,tndokid,tcdoktyyp, tdkpv ,tnsumma ,tcallikas,tctyyp, ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
--		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.hootehingud_id_seq') as int4);
--		raise notice 'lnaastaId %',lnaastaId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hootehingud set 
		isikid = tnIsikId, 
		ettemaksid = tnEttemaksId,
		dokid = tnDokId,
		doktyyp = tcDoktyyp, 
		kpv = tdKpv,
		summa = tnSumma,
		allikas = tcAllikas,
		tyyp = tcTyyp, 
		muud = ttMuud
	where id = tnId;
--	end if;
	lnId := tnId;
end if;

	-- kontrollime kas ettemaksu summa vordleb tehingusumma

	select sum(summa) into lnEttemaksuSumma from hooEttemaksud where id = tnEttemaksId;
	select sum(summa) into lnTehinguSumma from hootehingud where ettemaksid = tnEttemaksId;
	if ifnull(lnTehinguSumma,0) = ifnull(lnEttemaksuSumma,0) and ifnull(lnTehinguSumma,0) > 0 then
		-- ettemaks klassifitseeritud, staatus = 0
		update hooettemaksud set staatus = 0 where id = tnEttemaksId;
	end if;
	-- arvestame jaagid
	perform sp_calc_hoojaak(tnIsikId);

	-- uhendame arved ja isik
	if (select count(id) from hoouhendused where isikid = tnIsikId and dokid = tnDokId and doktyyp = tcDoktyyp) = 0 THEN
		insert into hoouhendused (isikid, dokid, doktyyp) values (tnIsikId, tnDokId, tcDoktyyp);
	end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO soametnik;


/*
select sp_salvesta_hooleping(        0,        1,      586,        7,'003','Narva-Joesuu',DATE(2012,12,01),DATE(2013,12,31),          100.00,         85.0000,'test')

select * from asutus
 select hl.id, hl.rekvid, hl.isikid, hl.hooldekoduid, hk.nimetus as hooldekodu, hl.number, kov.nimetus as omavalitsus,  hl.algkpv, ifnull(hl.loppkpv,DATE(2099,12,31))::DATE AS LOPPKPV, hl.jaak , hl.summa,  hl.muud::varchar(254) as selg, hl.muud   from hooleping hl inner join asutus hk on hk.id = hl.hooldekoduid  inner join asutus kov on hl.omavalitsusId = kov.id  where hl.isikId =          3
select sp_salvesta_hooleping(        3,        1,        3,        8,'002','       42',date(2013, 1, 1),date(2099,12,31),          100.00,           85.00,'TEST2')
*/

CREATE OR REPLACE FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnIsikId alias for $3;
	tnhooldekoduid alias for $4;
	tcNumber alias for $5;
	tnOmavalitsusId alias for $6;
	tdAlgkpv alias for $7;
	tdLoppkpv alias for $8;
	tnSumma alias for $9;
	tnOsa alias for $10;
	ttmuud alias for $11;

	lnId int; 
	lrCurRec record;

begin
raise notice 'tdAlgkpv %',tdAlgkpv;
if tnId = 0 then
	-- uus kiri
	insert into hooleping( rekvid,isikid, hooldekoduid,number, omavalitsus, omavalitsusId, algkpv,loppkpv, muud,summa,osa) 
		values (tnrekvid,tnisikid, tnhooldekoduid,tcnumber,space(1), tnomavalitsusId, tdalgkpv,tdloppkpv, ttmuud,tnsumma,tnosa);

	lnId:= cast(CURRVAL('public.hooleping_id_seq') as int4);

else
	-- muuda 
	update hooleping set 
		isikid = tnIsikId, 
		hooldekoduid = tnhooldekoduid,
		number = tcNumber, 
		omavalitsusid = tnomavalitsusId, 
		algkpv = tdalgkpv,
		loppkpv = tdloppkpv, 
		muud = ttMuud,
		summa = tnSumma,
		osa = tnOsa
	where id = tnId;

	lnId := tnId;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) TO hkametnik;


-- Function: sp_koosta_ettemaks(integer, integer)
/*
	Do Form (lcForm) With 'EDIT',curArved.id To lnNum

*/
-- DROP FUNCTION sp_koosta_ettemaks(integer, integer);

CREATE OR REPLACE FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnIsikid alias for $1;
	tnArvId alias for $2;
	tnAasta alias for $3;
	tnKuu alias for $4;

	lnreturn integer;
	lnIsikid integer;
	lcLisa varchar(120);
	lnArvLiik int;
begin
lnreturn = 0;
lnIsikId = tnIsikid;
if lnIsikId = 0 then
	select lisa into lcLisa from arv  where id = tnArvId;
	lcLisa = ifnull(lcLisa,space(1));
	lnIsikId = fnc_leiaisikukood(lcLisa);
end if;

select arv.liik into lnArvLiik from arv where id = tnArvId;
if lnArvLiik = 1 then
	if (select count(id) from hootaabel where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0) > 0 then
		update hootaabel set arvid = tnArvId where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0;
		lnReturn = 1;
	end if;
else
	if (select count(id) from hootaabel where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and tuluArvid = 0) > 0 then
		update hootaabel set tuluarvid = tnArvId where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and tuluarvid = 0;
		lnReturn = 1;
	end if;

end if;
-- uhendame arved ja isik
if (select count(id) from hoouhendused where isikid = lnIsikId and dokid = tnArvId and doktyyp = 'ARVED') = 0 THEN
	insert into hoouhendused (isikid, dokid, doktyyp) values (lnIsikId, tnArvId, 'ARVED');
end if;


return  lnReturn;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO soametnik;


-- Function: sp_salvesta_holidays(integer, integer, integer, integer, character varying, text)
/*
CREATE TABLE hootaabel
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  nomid integer NOT NULL DEFAULT 0,
  kpv date NOT NULL,
  kogus numeric(18,4) NOT NULL DEFAULT 0,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  arvid integer NOT NULL DEFAULT 0,
  muud 
*/
-- DROP FUNCTION sp_salvesta_holidays(integer, integer, integer, integer, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnIsikId alias for $2;
	tnNomId alias for $3;
	tdKpv alias for $4;
	tnKogus alias for $5;
	tnSumma alias for $6;
	ttmuud alias for $7;

	lnId int; 
	lrCurRec record;

begin

if tnId = 0 then
	-- uus kiri
	insert into hootaabel(isikid, nomid, kpv,kogus,summa, arvid,tuluarvid, muud) 
		values (tnisikid, tnnomid, tdkpv,tnkogus,tnsumma, 0,0, ttmuud);

	lnId:= cast(CURRVAL('public.hootaabel_id_seq') as int4);

else
	-- muuda 
	update hootaabel set 
		isikid = tnIsikId, 
		nomid = tnNomid, 
		kpv = tdKpv,
		kogus = tnKogus,
		summa = tnSumma, 
		muud = ttmuud
	where id = tnId;

	lnId := tnId;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO hkametnik;




ALTER TABLE hooleping
   ADD COLUMN omavalitsusid integer DEFAULT 0;

ALTER TABLE hootaabel
   ADD COLUMN "tuluarvId" integer DEFAULT 0;

ALTER TABLE hooleping
   ADD COLUMN kovjaak numeric(18,6) DEFAULT 0;


-- Function: sp_koosta_hooettemaks(integer, integer)

-- DROP FUNCTION sp_koosta_hooettemaks(integer, integer);

CREATE OR REPLACE FUNCTION sp_koosta_hooettemaks(integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnLiik alias for $2;
	lnId int; 
	lnisikId int; 
	v_journal record;
	
	lcSelg text;
begin
lnId = 0;
if tnLiik = 1 then
-- journal
	raise notice 'journal';
	for v_journal in 
		SELECT journal.id, ifnull(asutus.nimetus,'')::varchar(154) as asutus, journal1.id as journal1Id, journal.rekvid, journal.kpv, journal.dok,
			journal.asutusid, journal.selg, journal1.summa, journalid.number
			FROM journal left outer join asutus on journal.asutusid = asutus.id
			JOIN journal1 ON journal.id = journal1.parentid
			JOIN journalid ON journal.id = journalid.journalid
			where journal.id = tnId and journal1.kreedit = '203630'
	loop 
-- kontrollime kas ettemaks juba koostatud
		-- konto like 203630

		select id into lnId from hooettemaksud where dokid = v_journal.journal1Id and doktyyp = 'LAUSEND';
		lnId = ifnull(lnId,0);

		if lnId = 0 then
			-- otsime isik
			raise notice 'Otsime isik';
			raise notice 'v_journal.selg %',v_journal.selg;
			lnIsikId = fnc_LeiaIsikuKood(v_journal.selg);
			if lnIsikId = 0 then
				return 0;
			end if;
			-- koostame uus ettemaks
			lcSelg = ltrim(rtrim(v_journal.asutus))+',';
			if len(v_journal.dok) > 0 then
				lcSelg = lcSelg + ' Dok.nr.'+ltrim(rtrim(v_journal.dok));
			end if;
			lcSelg=lcSelg + ',' + v_journal.selg;
			insert into hooettemaksud (isikid, kpv, summa, dokid , doktyyp, selg , staatus)
				values (lnIsikId, v_journal.kpv, v_journal.summa, v_journal.id, 'LAUSEND', lcSelg,1);
			lnId:= cast(CURRVAL('public.hooettemaksud_id_seq') as int4);	

			if lnId > 0 then
				update journal set dokid = lnId where id = tnId;
			end if;		
		end if;
			
	end loop;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_hooettemaks(integer, integer) OWNER TO vlad;


-- Function: sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text)
/*

*/
-- DROP FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnLepingId alias for $2;
	tnNomId alias for $3;
	tnHind alias for $4;
	tdKehtivus alias for $5;
	ttMuud alias for $6;

	lnId int; 
	lrCurRec record;
begin
if tnId = 0 then
	-- uus kiri
	insert into hooteenused (Lepingid,  NomId, allikas, Hind,Kehtivus, muud) 
		values (tnLepingid, tnNomId,space(1), tnHind,tdKehtivus,ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
--		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.hooteenused_id_seq') as int4);
--		raise notice 'lnaastaId %',lnaastaId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hooteenused set 
		Lepingid = tnLepingId, 
		NomId = tnNomId,
		Hind = tnHind,
		Kehtivus= tdkehtivus,
		muud = ttMuud
	where id = tnId;
--	end if;
	lnId := tnId;
end if;

--	perform sp_calc_hoojaak(tnIsikId);
         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) TO soametnik;


-- Function: sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text)
/*
select * from hootaabel

 hooldajaid integer NOT NULL DEFAULT 0,
  isikid integer NOT NULL DEFAULT 0,
  kohtumaarus character varying(254) NOT NULL,
  algkpv date NOT NULL, -- alg.kpv
  loppkpv date,
  muud 
*/
-- DROP FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnhooldajaid alias for $2;
	tnisikId alias for $3;
	tcKohtumaarus alias for $4;
	tdAlgKpv alias for $5;
	tdLoppKpv alias for $6;
	ttMuud alias for $7;

	lnId int; 
	lrCurRec record;
begin
if tnId = 0 then
	-- uus kiri
	insert into hooldaja (hooldajaid,  IsikId, Kohtumaarus, algkpv,loppkpv, muud) 
		values (tnhooldajaid,  tnIsikId, tcKohtumaarus, tdalgkpv,tdloppkpv,ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.hooldaja_id_seq') as int4);
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hooldaja set 
		hooldajaid = tnhooldajaid,  
		IsikId = tnIsikId, 
		Kohtumaarus = tcKohtumaarus, 
		algkpv = tdAlgKpv,
		loppkpv = tdLoppKpv,
		muud = ttMuud
	where id = tnId;
--	end if;
	lnId := tnId;
end if;

--	perform sp_calc_hoojaak(tnIsikId);
         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) TO soametnik;

/*
select * from hooleping

select sp_arvesta_hoolepingujaak(8, 3)
*/


CREATE OR REPLACE FUNCTION sp_arvesta_hoolepingujaak(integer, integer)
  RETURNS numeric AS
$BODY$
declare
	tnHooldekoduid alias for $1;
	tnIsikId alias for $2;

	lnId int; 
	curLeping record;
	lnDeebet numeric (16,2);
	lnKreedit numeric (16,2);
	lnDbKov numeric (16,2);
	lnKrKOV numeric (16,2);

begin
	select * into curLeping from hooLeping where isikId = tnIsikId and hooldekoduid = tnHooldekoduid order by algkpv desc limit 1;
	
	select sum(summa) into lnDeebet 
		from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = tnHooldekoduid and hu.isikId = tnIsikId;
	lnDeebet = ifnull(lnDeebet,0);

	select sum(summa) into lnDbKov 
		from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = curLeping.omavalitsusId and hu.isikId = tnIsikId;
	lnDbKov = ifnull(lnDbKov,0);

	select sum(summa) into lnKreedit from arvtasu 
		where arvid in (select arv.id from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = tnHooldekoduid and hu.isikId = tnIsikId);	
	lnKreedit = ifnull(lnKreedit,0);

	select sum(summa) into lnKrKov from arvtasu 
		where arvid in (select arv.id from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = curLeping.omavalitsusId and hu.isikId = tnIsikId);	
	lnKrKov = ifnull(lnKrKov,0);

	-- uuendame lepingujaak

	update hooleping set jaak = lnDeebet - lnKreedit, kovjaak = lnDbKov - lnKrKov where hooldekoduid = tnHooldekoduid and isikid = tnIsikId;
	
return  (lnDeebet - lnKreedit);

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_arvesta_hoolepingujaak(integer, integer) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_arvesta_hoolepingujaak(integer, integer) TO hkametnik;


