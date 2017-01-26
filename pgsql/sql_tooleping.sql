ALTER TABLE tooleping
   ADD COLUMN vanatoopaev integer;

update tooleping set vanatoopaev = toopaev;

ALTER TABLE tooleping DROP COLUMN toopaev CASCADE;

ALTER TABLE tooleping ADD COLUMN toopaev numeric(12,4);
ALTER TABLE tooleping ALTER COLUMN toopaev SET STORAGE PLAIN;
ALTER TABLE tooleping ALTER COLUMN toopaev SET DEFAULT 0;

update tooleping set toopaev = vanatoopaev;

ALTER TABLE tooleping ALTER COLUMN toopaev SET NOT NULL;


CREATE OR REPLACE VIEW comtooleping AS 
 SELECT tooleping.id, asutus.nimetus AS isik, asutus.regkood AS isikukood, osakonnad.kood AS osakond, osakonnad.id AS osakondid, ametid.kood AS amet, ametid.id AS ametid, tooleping.algab, tooleping.lopp, tooleping.toopaev, tooleping.palk, tooleping.palgamaar, tooleping.pohikoht, tooleping.koormus, tooleping.ametnik, tooleping.pank, tooleping.aa, tooleping.rekvid, tooleping.parentid
   FROM asutus
   JOIN tooleping ON asutus.id = tooleping.parentid
   JOIN library osakonnad ON tooleping.osakondid = osakonnad.id
   JOIN library ametid ON tooleping.ametid = ametid.id;

ALTER TABLE comtooleping OWNER TO vlad;
GRANT ALL ON TABLE comtooleping TO vlad;
GRANT SELECT ON TABLE comtooleping TO dbpeakasutaja;
GRANT SELECT ON TABLE comtooleping TO dbkasutaja;
GRANT SELECT ON TABLE comtooleping TO dbadmin;
GRANT SELECT ON TABLE comtooleping TO dbvaatleja;


CREATE OR REPLACE VIEW curtoograafik AS 
 SELECT comtooleping.isik, comtooleping.osakond, comtooleping.amet, toograf.id, toograf.lepingid, toograf.kuu, toograf.aasta, toograf.tund, comtooleping.rekvid, comtooleping.parentid AS asutusid
   FROM comtooleping
   JOIN toograf ON comtooleping.id = toograf.lepingid;

ALTER TABLE curtoograafik OWNER TO vlad;
GRANT ALL ON TABLE curtoograafik TO vlad;
GRANT ALL ON TABLE curtoograafik TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE curtoograafik TO dbpeakasutaja;
GRANT SELECT ON TABLE curtoograafik TO dbkasutaja;
GRANT SELECT ON TABLE curtoograafik TO dbadmin;
GRANT SELECT ON TABLE curtoograafik TO dbvaatleja;

-- View: curtsd1

-- DROP VIEW curtsd1;

CREATE OR REPLACE VIEW curtsd1 AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '01'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid;

ALTER TABLE curtsd1 OWNER TO vlad;
GRANT ALL ON TABLE curtsd1 TO vlad;
GRANT SELECT ON TABLE curtsd1 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbadmin;
GRANT SELECT ON TABLE curtsd1 TO dbvaatleja;


-- Function: sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)

-- DROP FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnosakondid alias for $3;
	tnametid alias for $4;
	tdalgab alias for $5;
	tdlopp alias for $6;
	tntoopaev alias for $7;
	tnpalk alias for $8;
	tnpalgamaar alias for $9;
	tnpohikoht alias for $10;
	tnkoormus alias for $11;
	tnametnik alias for $12;
	tntasuliik alias for $13;
	tnpank alias for $14;
	tcaa alias for $15;
	ttmuud alias for $16;
	tnrekvid alias for $17;
	tnresident alias for $18;
	tcriik alias for $19;
	tdtoend alias for $20;
	tcValuuta alias for $21;
	tnKuurs alias for $22;
	lntoolepingId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into tooleping (parentid,osakondid,ametid,algab,lopp,toopaev,palk,palgamaar,pohikoht,koormus,ametnik,tasuliik,pank,aa,muud,rekvid,resident,riik,toend) 
		values (tnparentid,tnosakondid,tnametid,tdalgab,tdlopp,tntoopaev,tnpalk,tnpalgamaar,tnpohikoht,tnkoormus,tnametnik,tntasuliik,tnpank,tcaa,ttmuud,tnrekvid,tnresident,tcriik,tdtoend);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lntoolepingId:= cast(CURRVAL('public.tooleping_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lntoolepingId = 0;
	end if;

	if lntoolepingId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lntoolepingId,19,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from tooleping where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.osakondid <> tnosakondid or lrCurRec.ametid <> tnametid or lrCurRec.algab <> tdalgab 
		or ifnull(lrCurRec.lopp,date(1900,01,01)) <> ifnull(tdlopp,date(1900,01,01)) or lrCurRec.toopaev <> tntoopaev or lrCurRec.palk <> tnpalk 
		or lrCurRec.palgamaar <> tnpalgamaar or lrCurRec.pohikoht <> tnpohikoht or lrCurRec.koormus <> tnkoormus or lrCurRec.ametnik <> tnametnik 
		or lrCurRec.tasuliik <> tntasuliik or lrCurRec.pank <> tnpank or lrCurRec.aa <> tcaa or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.rekvid <> tnrekvid or lrCurRec.resident <> tnresident or lrCurRec.riik <> tcriik 
		or ifnull(lrCurRec.toend,date(1900,01,01)) <> ifnull(tdtoend,date(1900,01,01)) then 

	update tooleping set 
		parentid = tnparentid,
		osakondid = tnosakondid,
		ametid = tnametid,
		algab = tdalgab,
		lopp = tdlopp,
		toopaev = tntoopaev,
		palk = tnpalk,
		palgamaar = tnpalgamaar,
		pohikoht = tnpohikoht,
		koormus = tnkoormus,
		ametnik = tnametnik,
		tasuliik = tntasuliik,
		pank = tnpank,
		aa = tcaa,
		muud = ttmuud,
		rekvid = tnrekvid,
		resident = tnresident,
		riik = tcriik,
		toend = tdtoend		
	where id = tnId;
	end if;
	lntoolepingId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (19, lntoolepingId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
						
		end if;
	
	end if;


	
end if;

         return  lntoolepingId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbpeakasutaja;
