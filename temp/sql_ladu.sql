-- Function: sp_recalc_ladujaak(integer, integer, integer)

-- DROP FUNCTION sp_recalc_ladujaak(integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_recalc_ladujaak(integer, integer, integer)
  RETURNS smallint AS
$BODY$

declare 

	tnrekvId	ALIAS FOR $1;
	tnNomid	ALIAS FOR $2;
	tnArveId	ALIAS FOR $3;	
	cur_ladusisearved record;
	cur_v_arved record;
	v_ladu_config record;
	cur_ladujaak_valja record;
	cur_ladujaak_sise record;
	recArv	record;
	recArv1	record;
	lnCount int;
	ldKpv date;

	lnNomid1 int;
	lnNomid2 int;
	lnArveId1 int;
	lnArveId2 int;

	lnId int;

begin



--raise notice ' alg  ';

lnNomId1 = 0;
lnNomid2 = 9999999;

if tnNomId > 0 then
	lnNomId1 = tnNomId;
	lnNomid2 = tnNomId;	
end if;
lnArveId1 = 0;
lnArveid2 = 9999999;

if tnArveId > 0 then
	lnArveId1 = tnArveId;
	lnArveid2 = tnArveId;	
end if;


select * into v_ladu_config from ladu_config where rekvid = tnrekvId;


-- clearn up old data
-- raise notice ' clearn up old data ';

delete from ladu_jaak 
	where rekvid = tnRekvId  
	and ladu_jaak.nomid >= lnNomId1 
	and ladu_jaak.nomid <= lnNomId2 
	and dokItemId in (select id from arv1 where parentid >= lnArveId1 and parentid <= lnArveid2);

-- delete compl. data
delete from ladu_jaak 
	where rekvid = tnRekvId  
	and ladu_jaak.nomid in (select nomid from varaitem where parentid  >= lnNomId1 and parentid <= lnNomId2) 
	and dokItemId in (select id from arv1 where parentid >= lnArveId1 and parentid <= lnArveid2);

-- insert new jaagid (+)
-- raise notice ' insert new jaagid (+) ';


insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak, tahtaeg  )
	SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, arv1.kogus, 0, arv1.kogus,
	arv2.tahtaeg
	from arv inner join arv1 on arv.id = arv1.parentid 
	left outer join arv2 on arv2.arv1id = arv1.id
	where arv.rekvid = tnRekvid
	and arv.liik = 1 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;

-- update arve status

update arv1 set maha = 0 
	where id in (	SELECT distinct arv1.Id
	from arv inner join arv1 on arv.id = arv1.parentid 
	where arv.rekvid = tnRekvid
	and arv.liik = 1 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2
	and arv.id >= lnArveId1 and arv.id <= lnArveid2);


-- insert new jaagid (-)
-- raise notice ' insert new jaagid (-) ';

insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak, tahtaeg  )
	SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, (-1 * arv1.kogus), 0, (-1 * arv1.kogus), arv2.tahtaeg
	from arv inner join arv1 on arv.id = arv1.parentid 
	left outer join arv2 on arv2.arv1id = arv1.id
	where arv.rekvid = tnRekvid
	and arv.liik = 0 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2 
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;


-- insert items for complex. prod (+)
-- raise notice ' insert items for complex. prod (+)';


insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak, tahtaeg  )
	SELECT arv.rekvid, arv1.Id, varaitem.nomId, arv.userId, arv.kpv, 
	nomenklatuur.hind, 
	(-1 * arv1.kogus * varaitem.kogus), 0, (-1 * arv1.kogus * varaitem.kogus), arv2.tahtaeg
	from arv inner join arv1 on arv.id = arv1.parentid 
	inner join varaitem on varaitem.parentid = arv1.nomid
	inner join nomenklatuur on varaitem.nomid = nomenklatuur.id
	left outer join arv2 on arv2.arv1id = arv1.id
	where arv.rekvid = tnRekvid
	and arv.liik = 1 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2 
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;

		
-- update dok. inform

update arv1 set maha = 0 where parentid in (select id from arv where arv.rekvid = tnRekvid and arv.liik = 1 and arv.operId > 0 and arv.id >= lnArveId1 and arv.id <= lnArveid2)
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2; 



--vara valjaminek
-- list of reduced items

for cur_ladujaak_valja  in 
	select   id, jaak, maha, kpv, dokItemId, kogus, nomid   
	from ladu_jaak
	where rekvid = tnrekvId
	and jaak < 0
	and ladu_jaak.nomid >= lnNomid1
	and ladu_jaak.nomid <= lnNomId2
	order by kpv

loop
--	raise notice 'cur_ladujaak_valja %',cur_ladujaak_valja.id;
	-- look for item 
	for cur_ladujaak_sise  in 
		select   id, jaak, maha, kpv, dokItemId, kogus, nomid   
			from ladu_jaak
			where rekvid = tnrekvId
			and jaak > 0
			and ladu_jaak.nomid = cur_ladujaak_valja.nomid
			order by kpv
	loop

--		raise notice 'cur_ladujaak_sise %',cur_ladujaak_sise.id;

		-- check if avail. kogus >= reduced
		if cur_ladujaak_sise.jaak >= (-1 * cur_ladujaak_valja.jaak) then 
			-- update reduced item
			update ladu_jaak set jaak = 0 where id = cur_ladujaak_valja.id;
			-- update avail item
			update ladu_jaak set jaak = kogus +  cur_ladujaak_valja.jaak, maha = maha - cur_ladujaak_valja.jaak where id = cur_ladujaak_sise.id ;
			-- update arv1 rea status
			update arv1 set maha = 1 where id = cur_ladujaak_sise.dokitemid;

--			raise notice 'cur_ladujaak_sise.jaak >= (-1 * cur_ladujaak_valja.kogus';
--			raise notice 'cur_ladujaak_sise.jaak %',cur_ladujaak_sise.jaak;
--			raise notice 'cur_ladujaak_sise.kogus %',cur_ladujaak_sise.kogus;
			
			exit;

		else
			-- valja qantity more than avail.item
	
			-- update reduced item
			update ladu_jaak set jaak = jaak + cur_ladujaak_sise.jaak where id = cur_ladujaak_valja.id;
			-- update avail item
			update ladu_jaak set jaak = 0, maha = cur_ladujaak_sise.kogus where id = cur_ladujaak_sise.id;
			-- update arv1 rea status
			update arv1 set maha = 1 where id = cur_ladujaak_sise.dokitemid;

--			raise notice 'cur_ladujaak_sise.jaak %',cur_ladujaak_sise.jaak;
--			raise notice 'cur_ladujaak_sise.kogus %',cur_ladujaak_sise.kogus;

		end if;

	end loop;
	
end loop;

delete from ladu_jaak where jaak = 0;


return 1;



end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_recalc_ladujaak(integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbpeakasutaja;


-- Table: nomenklatuur

сводная таблица запасов и услуг.

-- DROP TABLE nomenklatuur;



CREATE TABLE nomenklatuur
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  doklausid integer NOT NULL DEFAULT 0,
  dok character(20) NOT NULL DEFAULT space(1),
  kood character(20) NOT NULL DEFAULT space(1),
  nimetus character(254) NOT NULL DEFAULT space(1),
  uhik character(20) NOT NULL DEFAULT space(1),
  hind numeric(12,4) NOT NULL DEFAULT 0,
  muud text,
  ulehind numeric(12,4) NOT NULL DEFAULT 0,
  kogus numeric(12,3) NOT NULL DEFAULT 0,
  formula text NOT NULL DEFAULT space(1),
  vanaid integer,
  CONSTRAINT nomenklatuur_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE nomenklatuur OWNER TO vlad;
GRANT ALL ON TABLE nomenklatuur TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE nomenklatuur TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE nomenklatuur TO dbkasutaja;
GRANT SELECT ON TABLE nomenklatuur TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE nomenklatuur TO ladukasutaja;

-- Index: nomenklatuur_doklausid

-- DROP INDEX nomenklatuur_doklausid;

CREATE INDEX nomenklatuur_doklausid
  ON nomenklatuur
  USING btree
  (doklausid);

-- Index: nomenklatuur_kood_idx

-- DROP INDEX nomenklatuur_kood_idx;

CREATE INDEX nomenklatuur_kood_idx
  ON nomenklatuur
  USING btree
  (kood, nimetus);

-- Index: nomenklatuur_rekvid

-- DROP INDEX nomenklatuur_rekvid;

CREATE INDEX nomenklatuur_rekvid
  ON nomenklatuur
  USING btree
  (rekvid);


-- Trigger: trigd_nomenklatuur_after on nomenklatuur

-- DROP TRIGGER trigd_nomenklatuur_after ON nomenklatuur;

CREATE TRIGGER trigd_nomenklatuur_after
  AFTER DELETE
  ON nomenklatuur
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_nomenklatuur_after();

-- Trigger: trigd_nomenklatuur_after_r on nomenklatuur

-- DROP TRIGGER trigd_nomenklatuur_after_r ON nomenklatuur;

CREATE TRIGGER trigd_nomenklatuur_after_r
  AFTER DELETE
  ON nomenklatuur
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_nomenklatuur_after_r();

-- Trigger: trigd_nomenklatuur_before on nomenklatuur

-- DROP TRIGGER trigd_nomenklatuur_before ON nomenklatuur;

CREATE TRIGGER trigd_nomenklatuur_before
  BEFORE DELETE
  ON nomenklatuur
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_nomenklatuur_before();

-- Trigger: trigiu_nomenklatuur_after on nomenklatuur

-- DROP TRIGGER trigiu_nomenklatuur_after ON nomenklatuur;

CREATE TRIGGER trigiu_nomenklatuur_after
  AFTER INSERT OR UPDATE
  ON nomenklatuur
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_nomenklatuur_after();

-- Trigger: trigiu_nomenklatuur_before on nomenklatuur

-- DROP TRIGGER trigiu_nomenklatuur_before ON nomenklatuur;

CREATE TRIGGER trigiu_nomenklatuur_before
  BEFORE INSERT OR UPDATE
  ON nomenklatuur
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_nomenklatuur_before();



-- Table: ladu_grupp

таблица, связывающая конкретный запас с группой запасов + содержит специфические данные для запаса. Наличие записи в этой таблице отвечает на вопрос это услуга или запас. 

-- DROP TABLE ladu_grupp;

CREATE TABLE ladu_grupp
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  nomid integer NOT NULL DEFAULT 0,
  kalor numeric(14,4) NOT NULL DEFAULT 0,
  "valid" date,
  sahharid numeric(14,4) NOT NULL DEFAULT 0,
  rasv numeric(14,4) NOT NULL DEFAULT 0,
  vailkaine numeric(14,4) NOT NULL DEFAULT 0,
  staatus integer NOT NULL DEFAULT 0,
  CONSTRAINT ladu_grupp_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ladu_grupp OWNER TO vlad;
GRANT ALL ON TABLE ladu_grupp TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO dbkasutaja;
GRANT SELECT ON TABLE ladu_grupp TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_grupp TO ladukasutaja;

-- Index: ix_ladu_grupp

-- DROP INDEX ix_ladu_grupp;

CREATE INDEX ix_ladu_grupp
  ON ladu_grupp
  USING btree
  (parentid);

-- Index: ix_ladu_grupp_1

-- DROP INDEX ix_ladu_grupp_1;

CREATE INDEX ix_ladu_grupp_1
  ON ladu_grupp
  USING btree
  (nomid);


-- Trigger: trigd_ladu_grupp_before on ladu_grupp

-- DROP TRIGGER trigd_ladu_grupp_before ON ladu_grupp;

CREATE TRIGGER trigd_ladu_grupp_before
  BEFORE DELETE
  ON ladu_grupp
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_ladu_grupp_before();

-- Table: ladu_jaak

В этой таблице сохраняются записи, соответсвующие кол-ву запаса на складе. Т.е. 1 запись - один запас. При списании одного запаса - одна соответствующая запись удаляется и наоборот. При запросе о кол-ве запасов на складе будет выборка с этой таблицы. Я делаю с группировкой по цене и коду (nomid)


-- DROP TABLE ladu_jaak;

CREATE TABLE ladu_jaak
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  dokitemid integer NOT NULL DEFAULT 0,
  nomid integer NOT NULL DEFAULT 0,
  userid integer NOT NULL DEFAULT 0,
  kpv date NOT NULL DEFAULT ('now'::text)::date,
  hind numeric(12,4) NOT NULL DEFAULT 0,
  kogus numeric(18,3) NOT NULL DEFAULT 0,
  maha numeric(18,3) NOT NULL DEFAULT 0,
  jaak numeric(18,3) NOT NULL DEFAULT 0,
  tahtaeg date,
  CONSTRAINT ladu_jaak_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE ladu_jaak OWNER TO vlad;
GRANT ALL ON TABLE ladu_jaak TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_jaak TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_jaak TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_jaak TO dbadmin;
GRANT SELECT ON TABLE ladu_jaak TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ladu_jaak TO ladukasutaja;

-- Index: ix_ladu_jaak

-- DROP INDEX ix_ladu_jaak;

CREATE INDEX ix_ladu_jaak
  ON ladu_jaak
  USING btree
  (nomid);

-- Index: ix_ladu_jaak_1

-- DROP INDEX ix_ladu_jaak_1;

CREATE INDEX ix_ladu_jaak_1
  ON ladu_jaak
  USING btree
  (kpv);

-- Index: ix_ladu_jaak_2

-- DROP INDEX ix_ladu_jaak_2;

CREATE INDEX ix_ladu_jaak_2
  ON ladu_jaak
  USING btree
  (dokitemid);

-- Index: ix_ladu_jaak_3

-- DROP INDEX ix_ladu_jaak_3;

CREATE INDEX ix_ladu_jaak_3
  ON ladu_jaak
  USING btree
  (rekvid);


-- Table: varaitem

Эта таблица содержит сведения о составе продукта из других. 

-- DROP TABLE varaitem;

CREATE TABLE varaitem
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  nomid integer NOT NULL,
  kogus numeric(12,2) NOT NULL DEFAULT 0,
  muud text,
  rekvid integer DEFAULT 0,
  CONSTRAINT varaitem_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE varaitem OWNER TO vlad;
GRANT ALL ON TABLE varaitem TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbkasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO dbadmin;
GRANT SELECT ON TABLE varaitem TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE varaitem TO ladukasutaja;
