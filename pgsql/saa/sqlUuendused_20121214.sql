CREATE ROLE HKametnik
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE SOAmetnik
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE TABLE hooteenused
(
   id serial NOT NULL, 
   lepingid integer NOT NULL DEFAULT 0, 
   nomid integer NOT NULL DEFAULT 0, 
   hind numeric(18,6) NOT NULL DEFAULT 0, 
   allikas character varying(20) NOT NULL, 
   tuluosa numeric(6,2) NOT NULL DEFAULT 0, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   muud text, 
   kehtivus date,
    CONSTRAINT hooteenused_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

CREATE INDEX hooteenused_lepingid
  ON hooteenused
  USING btree
  (lepingid);

ALTER TABLE hooteenused CLUSTER ON hooteenused_lepingid;

CREATE INDEX hooteenused_nomid
  ON hooteenused
  USING btree
  (nomid);


GRANT ALL ON TABLE hooteenused TO GROUP hkametnik;
GRANT ALL ON TABLE hooteenused TO GROUP soametnik;


CREATE TABLE hooldaja	
(
   id serial NOT NULL, 
   hooldajaid integer NOT NULL DEFAULT 0, 
   isikid integer NOT NULL DEFAULT 0, 
   kohtumaarus character varying(254) not null, 
   algkpv date not null,
   loppkpv date,
   muud text, 
    CONSTRAINT hooldaja_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

CREATE INDEX hooldaja_isikid
  ON hooldaja
  USING btree
  (isikid, hooldajaid);


GRANT ALL ON TABLE hooldaja TO GROUP hkametnik;
GRANT ALL ON TABLE hooldaja TO GROUP soametnik;


--drop table hootehingud;

CREATE TABLE hootehingud
(
   id serial NOT NULL, 
   isikid integer NOT NULL DEFAULT 0, 
   ettemaksid integer NOT NULL DEFAULT 0 , 
   journalid  integer NOT NULL DEFAULT 0,
   dokid integer NOT NULL DEFAULT 0  ,
   doktyyp character varying(20)  ,
   kpv date not null,
   summa numeric(18,6) NOT NULL DEFAULT 0, 
   allikas character varying(20) NOT NULL, 
   tyyp character varying(20) NOT NULL, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   muud text, 
    CONSTRAINT hootehingud_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;

COMMENT ON COLUMN hootehingud.ettemaksid IS 'seotud ettemaksu kandega';
COMMENT ON COLUMN hootehingud.dokid IS 'seotud dokumendiga';
COMMENT ON COLUMN hootehingud.doktyyp IS 'kui dokid > 0, doktyyp = KASSA,PANK, ARVE';

CREATE INDEX hootehingud_isikid
  ON hootehingud
  USING btree
  (isikid);

ALTER TABLE hootehingud CLUSTER ON hootehingud_isikid;

CREATE INDEX hootehingud_ettemaksid
  ON hootehingud
  USING btree
  (ettemaksid);


CREATE INDEX hootehingud_journalid
  ON hootehingud
  USING btree
  (journalid);

CREATE INDEX hootehingud_dokid
  ON hootehingud
  USING btree
  (doktyyp,dokid);


GRANT ALL ON TABLE hootehingud TO GROUP hkametnik;
GRANT ALL ON TABLE hootehingud TO GROUP soametnik;


--drop table hootehingud;

CREATE TABLE hooettemaksud
(
  id serial NOT NULL,
  isikid integer NOT NULL default 0,
  kpv date NOT NULL,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  dokid integer NOT NULL default 0,
  doktyyp character varying(20) NOT NULL DEFAULT space(20),
  selg text,
  muud text,
  staatus integer NOT NULL DEFAULT 1,
  CONSTRAINT hooettemaksud_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

COMMENT ON COLUMN hooettemaksud.doktyyp IS 'kui dokid > 0, doktyyp = LAUSEND,KASSA,PANK';
COMMENT ON COLUMN hooettemaksud.staatus IS '0 - klassifitseeritud, 1 - klassifitseerimata';

CREATE INDEX hooettemaksud_isikid
  ON hooettemaksud
  USING btree
  (isikid);

ALTER TABLE hooettemaksud CLUSTER ON hooettemaksud_isikid;


CREATE INDEX hooettemaksud_dokid
  ON hooettemaksud
  USING btree
  (doktyyp,dokid);


GRANT ALL ON TABLE hooettemaksud TO GROUP hkametnik;
GRANT ALL ON TABLE hooettemaksud TO GROUP soametnik;


-- Table: hooettemaksud
/*

select id, isikid,aruanne, kellele, koostaja, muud::varchar(254) as muud from hootoendid

*/
-- DROP TABLE hooettemaksud;

CREATE TABLE hootoendid
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  kpv date NOT NULL,
  aruanne varchar(254) not null,	
  kellele varchar(254) not null,
  koostaja varchar(254) not null,
  muud text,
  CONSTRAINT hootoendid_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE hootoendid TO hkametnik;
GRANT ALL ON TABLE hootoendid TO soametnik;


CREATE INDEX hootoendid_isikid
  ON hootoendid
  USING btree
  (isikid);
ALTER TABLE hootoendid CLUSTER ON hootoendid_isikid;

-- Function: fnc_asutusestaatus(integer)
/*
SELECT SUBSTRING('1234567890hgh', ' *([0-9]{1,11})');

select fnc_LeiaIsikuKood('Pank, 37303023721')

*/
-- DROP FUNCTION fnc_asutusestaatus(integer);

CREATE OR REPLACE FUNCTION fnc_LeiaIsikuKood(text)
  RETURNS integer AS
$BODY$

DECLARE 
	tcText alias for $1;
	
	lnisikId integer;
	lcIsikukood varchar(20);
begin
	lnisikId = 0;
	lcIsikukood =  SUBSTRING(tcText, ' *([0-9]{1,11})');
	raise notice 'lcIsikukood: %',lcIsikukood;
	if ifnull(lcIsikukood,'null') <> 'null' then
		select id into lnIsikId from asutus where regkood = lcIsikukood;
	end if;	
	lnisikId = ifnull(lnIsikId,0);
	return lnisikId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_asutusestaatus(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_LeiaIsikuKood(text) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_LeiaIsikuKood(text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_LeiaIsikuKood(text) TO dbvaatleja;

GRANT ALL ON TABLE hooettemaksud_id_seq TO postgres;
GRANT ALL ON TABLE hooettemaksud_id_seq TO public;

-- Function: sp_koosta_ettemaks(integer, integer)

-- DROP FUNCTION sp_koosta_ettemaks(integer, integer);

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
	for v_journal in 
		SELECT journal.id, ifnull(asutus.nimetus,'')::varchar(154) as asutus, journal1.id as journal1Id, journal.rekvid, journal.kpv, journal.dok,
			journal.asutusid, journal.selg, journal1.summa, journalid.number
			FROM journal left outer join asutus on journal.asutusid = asutus.id
			JOIN journal1 ON journal.id = journal1.parentid
			JOIN journalid ON journal.id = journalid.journalid
			where journal.id = tnId and journal1.kreedit = '136'
	loop 
-- kontrollime kas ettemaks juba koostatud
		-- konto like 203630

		select id into lnId from hooettemaksud where dokid = v_journal.journal1Id and doktyyp = 'LAUSEND';
		lnId = ifnull(lnId,0);

		if lnId = 0 then
			-- otsime isik
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
ALTER FUNCTION sp_koosta_ettemaks(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbpeakasutaja;

--DROP TABLE hooleping

CREATE TABLE hooleping
(
   id serial NOT NULL, 
   rekvid integer NOT NULL DEFAULT 0, 
   isikid integer NOT NULL DEFAULT 0, 
   hooldekoduid integer NOT NULL DEFAULT 0, 
   "number" character varying(20) NOT NULL, 
   omavalitsus character varying(120) NOT NULL, 
   algkpv date NOT NULL DEFAULT date(), 
   loppkpv date, 
   jaak numeric(18,6) NOT NULL DEFAULT 0, 
   summa numeric(18,2) NOT NULL DEFAULT 0,
   osa numeric(6,4) NOT NULL DEFAULT 85,
   muud text,
    CONSTRAINT hooleping_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)

;
ALTER TABLE hooleping OWNER TO vlad;



CREATE INDEX hooleping_isikid
  ON hooleping
  USING btree
  (isikid);


CREATE INDEX hooleping_hooldekoduid
  ON hooleping
  USING btree
  (hooldekoduid);
ALTER TABLE hooleping CLUSTER ON hooleping_hooldekoduid;


GRANT ALL ON TABLE hooleping TO GROUP hkametnik;
GRANT ALL ON TABLE hooleping TO GROUP soametnik;

GRANT ALL ON TABLE hootehingud_id_seq TO GROUP hkametnik;
GRANT ALL ON TABLE hootehingud_id_seq TO GROUP soametnik;

-- Table: hooldaja

-- DROP TABLE hooldaja;

CREATE TABLE hoojaak
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  pension85 numeric(16,2) not null default 0,
  pension15 numeric(16,2) not null default 0,
  toetus numeric(16,2) not null default 0,
  vara numeric(16,2) not null default 0,
  omavalitsus numeric(16,2) not null default 0,
  laen numeric(16,2) not null default 0,
  muud numeric(16,2) not null default 0,

  CONSTRAINT hoojaak_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hoojaak OWNER TO vlad;
GRANT ALL ON TABLE hoojaak TO hkametnik;
GRANT ALL ON TABLE hoojaak TO soametnik;


-- Index: hooldaja_isikid

-- DROP INDEX hooldaja_isikid;

CREATE INDEX hoojaak_isikid
  ON hoojaak
  USING btree
  (isikid);


GRANT ALL ON TABLE hoojaak_id_seq TO GROUP hkametnik;
GRANT ALL ON TABLE hoojaak_id_seq TO GROUP soametnik;
  

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
/*
 id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  ettemaksid integer NOT NULL DEFAULT 0, -- seotud ettemaksu kandega
  dokid integer NOT NULL DEFAULT 0, -- seotud dokumendiga
  doktyyp character varying(20), -- kui dokid > 0, doktyyp = KASSA,PANK, ARVE
  kpv date NOT NULL,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  allikas character varying(20) NOT NULL,
  tyyp character varying(20) NOT NULL,
  jaak numeric(18,6) NOT NULL DEFAULT 0,
  muud 
*/
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
         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO soametnik;

-- Function: sp_calc_palk_jaak(integer, integer, integer)
-- DROP FUNCTION sp_calc_palk_jaak(integer, integer, integer);
/*
select sp_calc_hoojaak(3)

update hoojaak set pension85 = 85 where isikid = 3

		select sum(summa) as summa, allikas 
			from 
				(select tyyp, case when ltrim(rtrim(tyyp)) = 'TULUD' then summa else -1*summa end as summa, allikas 
				from hootehingud where isikid = 3) tmp 
			group by allikas


*/

CREATE OR REPLACE FUNCTION sp_calc_hoojaak(integer)
  RETURNS smallint AS
$BODY$

declare 
	tnisikId alias for $1;
	lnpension85 numeric(16,2);
	lnpension15 numeric(16,2);
	lntoetus numeric(16,2);
	lnvara numeric(16,2);
	lnomavalitsus numeric(16,2);
	lnlaen numeric(16,2);
	lnmuud numeric(16,2);
	lnid int;
	v_hoojaak record;


begin
	-- leiame jaagirea
	if (select count(id) from hoojaak where isikid = tnIsikId) = 0 then
		insert into hoojaak (isikid,pension85,pension15,toetus,vara,omavalitsus,laen, muud) 
			values (tnIsikid,0,0,0,0,0,0,0);
	end if;

	lnpension85 = 0;
	lnPension15 = 0;
	lnToetus = 0;
	lnVara = 0;
	lnOmavalitsus = 0;
	lnLaen = 0;
	lnMuud = 0;	
	for v_hoojaak in
		select sum(summa) as summa, allikas 
			from 
				(select tyyp, case when ltrim(rtrim(tyyp)) = 'TULUD' then summa else -1*summa end as summa, allikas 
				from hootehingud where isikid = tnIsikId) tmp 
			group by allikas

	loop
		if ltrim(rtrim(v_hoojaak.allikas)) = 'PENSION85' then
			raise notice ' leitud 85';
			lnpension85 = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'PENSION15' then
			raise notice ' leitud 15 ';
			lnpension15 = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'TOETUS' then
			lnToetus = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'VARA' then
			lnVara = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'OMAVALITSUS' then
			lnOmavalitsus = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'LAEN' then
			lnlaen = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'MUUD' then
			lnMuud = v_hoojaak.summa;
		end if;
	end loop;
	raise notice 'lnpension85 %',lnpension85;
	raise notice 'tnisikId %',tnisikId;
	update hoojaak set pension85 = lnpension85,
		pension15 = lnPension15,
		toetus = lnToetus,
		vara = lnVara,
		omavalitsus = lnOmavalitsus,
		laen = lnLaen, 
		muud = lnMuud 
		where isikId = tnisikId;
	return 1;
end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_hoojaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_hoojaak(integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_calc_hoojaak(integer) TO soametnik;

-- Function: sp_del_mk1(integer, integer)
/*
select * from mk order by id desc limit 1
select * from hoojaak
DELETE FROM HOOJAAK 	where id = 4
delete from hootehingud where id in (11, 12)
select sp_del_mk1(83, 0)
select sp_calc_hoojaak(3)
*/
-- DROP FUNCTION sp_del_mk1(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_mk1(integer, integer)
  RETURNS smallint AS
$BODY$


declare 


	tnId alias for $1;
	tnOpt alias for $2;

	lnisikId integer;


begin

	Delete From mk Where Id = tnid;

	if found then
		delete from mk1 where parentid = tnId;
		delete from arvtasu where pankkassa = 1 and sorderid = tnid;
		select isikid into lnIsikId from hootehingud where ltrim(rtrim(doktyyp)) = 'PANK' and dokid = tnId order by id desc limit 1;
		delete from hootehingud where ltrim(rtrim(doktyyp)) = 'PANK' and dokid = tnId;

		if ifnull(lnIsikId,0) > 0 then
			perform sp_calc_hoojaak(lnIsikId);
		end if;
		Return 1;
	else
		Return 0;
	end if;





end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_mk1(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO dbkasutaja;


-- Table: hooettemaksud

-- DROP TABLE hooettemaksud;

CREATE TABLE hootaabel
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  nomid integer not null default 0,
  kpv date NOT NULL,
  kogus numeric(18,4) NOT NULL DEFAULT 0,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  arvid integer NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT hootaabel_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE hootaabel TO hkametnik;
GRANT ALL ON TABLE hootaabel TO soametnik;


CREATE INDEX hootaabel_arvid
  ON hootaabel
  USING btree
  (arvid);

CREATE INDEX hootaabel_nomid
  ON hootaabel
  USING btree
  (nomid);

-- Index: hooettemaksud_isikid

-- DROP INDEX hooettemaksud_isikid;

CREATE INDEX hootaabel_isikid
  ON hootaabel
  USING btree
  (isikid);
ALTER TABLE hootaabel CLUSTER ON hootaabel_isikid;

GRANT ALL ON TABLE hootaabel_id_seq TO GROUP soametnik;
GRANT ALL ON TABLE hootaabel_id_seq TO GROUP hkametnik;




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
	insert into hootaabel(isikid, nomid, kpv,kogus,summa, arvid,muud) 
		values (tnisikid, tnnomid, tdkpv,tnkogus,tnsumma, 0,ttmuud);

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


-- Function: sp_salvesta_holidays(integer, integer, integer, integer, character varying, text)
/*
select sp_salvesta_hootaabel(0,        3,        1,date(2012,12, 1),        0,        0,'')

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
	insert into hootaabel(isikid, nomid, kpv,kogus,summa, arvid,muud) 
		values (tnisikid, tnnomid, tdkpv,tnkogus,tnsumma, 0,ttmuud);

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

-- Function: sp_koosta_ettemaks(integer, integer)

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
begin
lnreturn = 0;

if (select count(id) from hootaabel where isikid = tnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0) > 0 then
	update hootaabel set arvid = tnArvId where isikid = tnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0;
	lnReturn = 1;
end if;

return  lnReturn;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO soametnik;

-- Function: sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)

-- DROP FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnsumma alias for $3;
	tcdokument alias for $4;
	ttmuud alias for $5;
	tckood1 alias for $6;
	tckood2 alias for $7;
	tckood3 alias for $8;
	tckood4 alias for $9;
	tckood5 alias for $10;
	tcdeebet alias for $11;
	tclisa_d alias for $12;
	tckreedit alias for $13;
	tclisa_k alias for $14;
	tcvaluuta alias for $15;
	tnkuurs alias for $16;
	tnvalsumma alias for $17;
	tctunnus alias for $18;
	tcProj alias for $19;
	lnjournal1Id int;
	lnId int; 
	lrCurRec record;

	tmpJournal record;
	lnKontrol int;
	lnrekvid int;
	lcViga varchar;
	lcOmaTp varchar;
	ldKpv date;

	v_dokvaluuta record;
begin

select rekvid, kpv into lnrekvId, ldKpv from journal where id = tnparentid;
select recalc into lnKontrol from rekv where id = lnrekvid;
raise notice 'ldKpv %',ldKpv;
lcOmaTp = ltrim(rtrim(fnc_getomatp(lnrekvId,year(ldKpv))));		
lnKontrol = 0;
		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(tcdeebet, tcKreedit,  tclisa_d, tclisa_k, tckood1, tcKood2, tckood5, tckood3, lcOmaTP, ldKpv, tcvaluuta);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
				return 0;
			end if;
		end if;


if tnId = 0 then
	-- uus kiri
	insert into journal1 (parentid,summa,dokument,muud,kood1,kood2,kood3,kood4,kood5,deebet,lisa_d,kreedit,lisa_k,valuuta,kuurs,valsumma,tunnus, proj) 
		values (tnparentid,tnsumma,tcdokument,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tcdeebet,tclisa_d,tckreedit,tclisa_k,tcvaluuta,tnkuurs,tnvalsumma,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournal1Id:= cast(CURRVAL('public.journal1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournal1Id = 0;
	end if;

	if lnjournal1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (1, lnjournal1Id,tcValuuta, tnKuurs);

else
	-- muuda 
	select * into lrCurRec from journal1 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.dokument,space(1)) <> ifnull(tcdokument,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or lrCurRec.deebet <> tcdeebet or lrCurRec.lisa_k <> tclisa_k or lrCurRec.kreedit <> tckreedit or lrCurRec.lisa_d <> tclisa_d or lrCurRec.valuuta <> tcvaluuta or 
		lrCurRec.kuurs <> tnkuurs or lrCurRec.valsumma <> tnvalsumma or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update journal1 set 
		parentid = tnparentid,
		summa = tnsumma,
		dokument = tcdokument,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		deebet = tcdeebet,
		lisa_k = tclisa_k,
		kreedit = tckreedit,
		lisa_d = tclisa_d,
		valuuta = tcvaluuta,
		kuurs = tnkuurs,
		valsumma = tnvalsumma,
		tunnus = tctunnus,
		proj = tcproj
	where id = tnId;
	end if;
	lnjournal1Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (1, lnjournal1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			
	
end if;

select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;


--avans
select avans1.id into lnId from avans1 inner join dokprop on dokprop.id = avans1.dokpropid
	where ltrim(rtrim(number)) = ltrim(rtrim(tmpJournal.dok)) 
	and rekvid = tmpJournal.rekvid 
	and avans1.asutusId = tmpJournal.asutusId
	and ltrim(rtrim(dokprop.konto)) = ltrim(rtrim(tcDeebet))
	order by avans1.kpv desc limit 1;

	if ifnull(lnId,0) > 0 then
		perform fnc_avansijaak(lnId);
	end if;

-- reklmaks
--select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;
if tckreedit = '200060' then
	perform sp_koosta_ettemaks(tnParentId, 1);
end if;

-- hooldekodu
if tckreedit = '203630' then
	perform sp_koosta_hooettemaks(tnParentId, 1);
end if;


/*

if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;



if (select count(toiming.id) from luba inner join toiming on luba.id = toiming.lubaid 
	where ltrim(rtrim(luba.number))+'-'+ltrim(rtrim(toiming.number::varchar)) like ltrim(rtrim(tmpJournal.dok))+'%' 
		and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	if left(ltrim(rtrim(tcdeebet)),6) = '100100' or left(ltrim(rtrim(tckreedit)),6) = '100100' then 	
	--	raise notice 'see on dekl.tasu %',new.deebet;
--		perform sp_tasu_dekl(tmpJournal.id);
	end if;


	
end if;
*/




         return  lnjournal1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO taabel;

