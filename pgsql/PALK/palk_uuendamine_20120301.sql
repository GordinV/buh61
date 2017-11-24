-- Column: tulumaks

-- ALTER TABLE palk_config DROP COLUMN tulumaks;

ALTER TABLE palk_config ADD COLUMN tm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN pm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN tka numeric(14,2);
ALTER TABLE palk_config ADD COLUMN tki numeric(14,2);
ALTER TABLE palk_config ADD COLUMN sm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN muud1 numeric(14,2);
ALTER TABLE palk_config ADD COLUMN muud2 numeric(14,2);
update palk_config set tm = 21, pm = 2, tka = 1.4, tki = 2.8, sm = 33, muud1 = 0, muud2 = 0 

-- View: curtsd

DROP VIEW curtsd;

CREATE OR REPLACE VIEW curtsd AS 
 SELECT palk_oper.id, rekv.parentid, rekv.id AS rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, tooleping.resident, tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19a'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19a, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_21, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '22'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_22, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN rekv ON rekv.id = palk_oper.rekvid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid AND palk_kaart.parentid = asutus.id
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curtsd OWNER TO vlad;
GRANT ALL ON TABLE curtsd TO vlad;
GRANT SELECT ON TABLE curtsd TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd TO dbkasutaja;
GRANT SELECT ON TABLE curtsd TO dbvaatleja;

-- View: curtsd1

-- DROP VIEW curtsd1;

CREATE OR REPLACE VIEW curtsd1 AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '01'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_21, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '22'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_22, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curtsd1 OWNER TO vlad;
GRANT ALL ON TABLE curtsd1 TO vlad;
GRANT SELECT ON TABLE curtsd1 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbvaatleja;

-- Function: gen_palkoper(integer, integer, integer, date, integer)
/*
			select * from tmp_viivis where rekvid = 119  order by oid desc limit 1;

*/
-- DROP FUNCTION gen_palkoper(integer, integer, integer, date, integer);

CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;


	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	v_palk_kaart record;
	v_dokprop record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
	lcTp varchar;
	v_valuuta record;
	lnRekvId integer;

	lcPref varchar;
	lcTimestamp varchar;
	ltSelg varchar;

begin
	raise notice 'start';
	lcPref = '';
	select rekvid into lnrekvid from tooleping where id = tnLepingId;

	SELECT Library.kood, ifnull((select valuuta1.kuurs from valuuta1 
		where parentid = library.id order by Library.id desc limit 1),0) as kuurs into v_valuuta
		FROM Library WHERE  library = 'VALUUTA' and library.tun1 = 1;

	lcTp := '800699';
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId;
	select * into v_palk_kaart from palk_kaart where libId = tnLibId and lepingId = tnLepingId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where palk_lib.parentid = tnLibId;
	select * into v_dokprop from dokprop where id = tnDokLausId;

	if qryPalkLib.liik = 1 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
		raise notice 'summa %',lnSumma;
		lcPref = 'ARV';
	end if;		
	if qryPalkLib.liik = 2 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
		lcPref = 'TM';

	end if;		
	if qryPalkLib.liik = 5 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	raise notice 'lnSumma> %',lnSumma;
	
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		-- pohivaluuta
--		lnSumma = lnSumma / fnc_currentkuurs(tdKpv);
		lcTimestamp = '';
		if not empty(lcPref) then
			lcTimestamp = left(lcPref+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
--			raise notice 'timestamp'
			select muud::varchar into ltSelg from tmp_viivis where rekvid = lnRekvid and timestamp = lcTimestamp order by oid desc limit 1;
		end if;
		lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, ltSelg, 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj );


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO public;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbpeakasutaja;

-- Function: sp_calc_tulumaks(integer, integer, date)
/*

select 'TM'::varchar+str(111)::varchar+22::varchar+date()::varchar

select * from asutus where regkood = '46407013725   '
select * from tooleping where parentid = 19603 and rekvid = 119
select * from library where kood = 'TMAKS-08600-5002    ' and library = 'PALK'
select sp_calc_tulumaks_(133147, 284343, date(2012,01,31))

select * from tmp_viivis order by id desc limit 1

select muud from tmp_viivis where dateasint(dkpv) = 20120131 and rekvid =        119 and timestamp = 'TM133147284343201201'

delete from tmp_viivis
select dateasint(date())
tmpPalkSelg
*/

-- DROP FUNCTION sp_calc_tulumaks(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_tulumaks(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTulumaks record;
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnTulud numeric (12,4);
	lnTuludPm numeric (12,4);
	lnKulud numeric (12,4);
	lnTulubaas numeric(12,4);	
	lnG31 numeric(12,4);
	lnG31_2004 numeric(12,4);
	lnG31_2005 numeric(12,4);

	nG31 numeric(12,4);
	lnCount	int;
	lnCount_2004	int;
	lnCount_2005	int;
	lnArvJaak numeric (12,4);
	lnKuurs  numeric(12,4);

	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);

	lnTkiPm numeric (12,4);
	lnPMPm numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);
ltSelgitus = '';
ltEnter = '
';
lcTimestamp = left('TM'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
-- kustutame vana info
delete from tmp_viivis where timestamp = lcTimestamp;

select  palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;
	
select * into qryTooleping from tooleping where id = tnlepingId;

--muudetud 25/01/2005
IF v_palk_kaart.tulumaar = 0 AND qryTooleping.pohikoht = 0 then
	RETURN 0;
END IF;


select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
--select * into v_palk_config from palk_config where rekvid = lnrekv;

select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
	from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = lnrekv;



--muudetud 03/01/2005

if qryTooleping.pohikoht > 0  then
/*
	if year(date()) = 2004 then
		lnTulubaas := 1400;
	else
		lnTulubaas := 1700;
	end if;
*/
	lnTulubaas = V_palk_config.tulubaas * v_palk_config.kuurs;
else
	lnTulubaas :=0;	
end if;
--raise notice 'lnTulubaas %',lnTulubaas;

ltSelgitus = ltSelgitus + 'Maksuvaba tulu: '+ltrim(rtrim(lnTulubaas::varchar))+ltEnter;
--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa * v_palk_kaart.kuurs;
	ltSelgitus = ltSelgitus + ltrim(rtrim(v_palk_kaart.summa::varchar))+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

else
--	raise notice 'alg';


	--muudetud 25/01/2005
	If qryTooleping.pohikoht = 1 then

		Select  Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud		
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId 
		And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 	
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));


		-- otsime tululiik 22 (PM)

		select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(lnTulud::varchar);
		if ifnull(lnTuludPm,0) > 0 then
			ltSelgitus = ltSelgitus + ' s.h. PM III samba tulu: '+ltrim(rtrim(lnTuludPm::varchar));
		end if;
		ltSelgitus = ltSelgitus + ltEnter;

		Select Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud 	
		FROM palk_kaart inner Join Palk_oper On 	
		(palk_kaart.lepingid = Palk_oper.lepingid And palk_kaart.libId = Palk_oper.libId)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvid = lnrekv And palk_kaart.tulumaks = 1 
		and palk_kaart.libId In (Select Library.Id From Library inner Join palk_lib On palk_lib.parentId = Library.Id 	
		where palk_lib.liik = 2 Or palk_lib.liik = 7 Or palk_lib.liik = 8 )
		And palk_kaart.lepingid In (SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (id = tnlepingId  
		OR id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

		raise notice 'lnKulud %',lnKulud;
		ltSelgitus = ltSelgitus + 'Kulud:'+ltrim(lnKulud::varchar)+ltEnter;
	raise notice 'ltSelgitus %',ltSelgitus;

	else

		SELECT  sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;

		-- otsime tululiik 22 (PM)

		select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid = tnLepingid;

		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(lnTulud::varchar);
		if ifnull(lnTuludPm,0) > 0 then
			ltSelgitus = ltSelgitus + ' s.h. PM III samba tulu: '+ltrim(rtrim(lnTuludPm::varchar));
		end if;
		ltSelgitus = ltSelgitus + ltEnter;

--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

--		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(lnTulud::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;


		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKuluD  
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		where palk_kaart.lepingId = tnLepingid 
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvId = lnRekv and palk_kaart.tulumaks = 1 
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id 
		where Palk_lib.liik = 2 OR PALK_LIB.LIIK = 7 OR PALK_LIB.LIIK = 8 );
 
		ltSelgitus = ltSelgitus + 'Kulud:'+ltrim(lnKulud::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

--	and tulumaar = v_palk_kaart.summa

	end if;

--	arvestame (-) maksud PM-st
	lnTuludPm = ifnull(lnTuludPm,0);
	if lnTuludPm > 0 then
		-- tki, otsime maar
		select palk_kaart.summa into lnTKIPm from 
			palk_kaart INNER JOIN palk_lib on palk_kaart.libid = palk_lib.parentid
			where palk_kaart.lepingid = tnLepingId
			and palk_lib.liik = 7 and palk_lib.asutusest = 0;
		lnTKIPm = ifnull(lnTKIpm,0);

		-- pm, otsime maar
		select palk_kaart.summa into lnPmPm from 
			palk_kaart INNER JOIN palk_lib on palk_kaart.libid = palk_lib.parentid
			where palk_kaart.lepingid = tnLepingId
			and palk_lib.liik = 8;
		lnPmPm = ifnull(lnPmPm,0);	

		ltSelgitus = ltSelgitus + 'Parandame kulud(PM III):'+ltrim(lnKulud::varchar)+
			'+('+ltrim(lnTuludPM::varchar) +'-'+ltrim((lnTuludPm * 0.01 * lnTKIPM)::varchar)+'-'+ltrim((lnTuludPm * 0.01 * lnPmPm)::varchar)+')'+ltEnter;

		lnKulud = lnKulud + (lnTuludPm - lnTuludPm * 0.01 * lnTKIPM - lnTuludPm * 0.01 * lnPmPm);
	end if;
	
--raise notice 'lnKulud %',lnKulud;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice 'lnTulubaas %',lnTulubaas;
		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv);

		lng31 := lng31_2005;

--		raise notice 'lng31 %',lng31;
--		ltSelgitus = ltSelgitus + 'Soodus:'+ltrim(ifnull(lng31,0)::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		
		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and date(aasta,kuu,1) >= qryTooleping.algab;


--		raise notice 'lnCount %',lnCount;

		-- should be 1400 * periods
		ng31 := V_palk_config.tulubaas * v_palk_config.kuurs * lnCount_2005 ;
--		raise notice 'ng31 %',ng31;

--		ltSelgitus = ltSelgitus + 'Soodus kokku:'+ltrim(ng31::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
			lnTulubaas := lnArvJaak;
--			raise notice 'less then vaja %',lnTulubaas;
			ltSelgitus = ltSelgitus + 'Soodus arvestatud vaiksem :'+ltrim(lnTulubaas::varchar)+ltEnter;

		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);
--				raise notice 'with reserv  %',lnTulubaas;
				ltSelgitus = ltSelgitus + 'Soodus arvestatud suurem :'+ltrim(lnTulubaas::varchar)+'+('+ltrim(ng31::varchar)+'-'+ltrim(lng31_2005::varchar)+')'+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

			end if;
--			raise notice 'with reserv after %',lnTulubaas;
--			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
				ltSelgitus = ltSelgitus + 'Soodus parandatud :'+ltrim(lnTulubaas::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

			end if;
		end if;

	end if;

	lnSumma := v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)) / lnKuurs;
	ltSelgitus = ltSelgitus + 'Arvestus:'+ltrim(v_palk_kaart.summa::varchar)+'*0.01*('+ltrim(ifnull(lnTuluD,0)::varchar)+'-'+ltrim(ifnull(lnTulubaas,0)::varchar)+'-'+ltrim(ifnull(lnkuluD,0)::varchar)+')/'+ltrim(lnKuurs::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;
	
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;
	ltSelgitus = ltSelgitus + 'Summa parandatud:'+ltrim(lnSumma::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

-- muudetud 04/01/2005

	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnTulubaas 
			from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND palk_oper.MUUD = 'AVANS';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - (lnTulubaas / lnKuurs);
			ltSelgitus = ltSelgitus + 'Summa parandatud(avans):'+ltrim(lnSumma::varchar)+'-('+ltrim(lnTulubaas::varchar)+'/'+ltrim(lnKuurs::varchar)+')'+tlEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		END IF;
	END IF;

	lnSumma = f_round(lnSumma,qryPalkLib.Round);
--	raise notice 'lnSumma %',lnSumma;
	ltSelgitus = ltSelgitus +'Umardamine:'+ltrim(lnSumma::varchar);
--	raise notice 'ltSelgitus %',ltSelgitus;

	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);
	
end if;
Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tulumaks(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbpeakasutaja;

-- Function: recalc_palk_saldo(integer, smallint)

-- DROP FUNCTION recalc_palk_saldo(integer, smallint);

CREATE OR REPLACE FUNCTION recalc_palk_saldo(integer, smallint)
  RETURNS integer AS
$BODY$
declare 
	tnLepingId alias for $1;

	tnMonth alias for $2;

	lKpv1	date;

	lKpv2	date;

	lnrekvid int;

begin

	If ifnull(tnMonth,0) = 0 then

		lKpv1 := date (year (), month (),1);

		lKpv2 := DATE(YEAR(),12,31);

	ELSE

		lKpv1 = DATE(YEAR(),tnMonth,1);

		--muudetud 03/01/2005
		lKpv2 = gomonth(lKpv1,1)  - 1; 

	end if;

	select palk_asutus.rekvid into lnRekvid from palk_asutus 

	inner join tooleping on (tooleping.ametid = palk_asutus.ametid and tooleping.Osakondid = palk_asutus.osakondid)

	where tooleping.id = tnLepingId;



	return sp_update_palk_jaak(lKpv1,lKpv2, lnRekvId, tnlepingId);

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION recalc_palk_saldo(integer, smallint) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO public;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbpeakasutaja;

-- Function: sp_calc_arv(integer, integer, date)

-- DROP FUNCTION sp_calc_arv(integer, integer, date);

/*
select * from asutus where regkood = '47104013758'
select * from tooleping where rekvid = 119 and parentid = 2894

select * from library order by id desc limit 1

select sp_calc_arv(131844, 599509, date(2012,01,31))

*/

CREATE OR REPLACE FUNCTION sp_calc_arv(integer, integer, date)
  RETURNS numeric AS
$BODY$

declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	qryTaabel1 record;
	npalk	numeric(12,4);
	nHours NUMERIC(12,4);
	lnRate numeric (12,4);
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnKuurs numeric(12,4);

	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);


begin

nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

ltSelgitus = '';
ltEnter = '
';
lcTimestamp = left('ARV'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);


select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19) 
	where tooleping.id = tnLepingId; 


--raise notice 'Percent %',v_palk_kaart.percent_;

If v_palk_kaart.percent_ = 1 then
	-- calc based on taabel 
	raise notice 'calc based on taabel';
	If v_palk_kaart.alimentid = 0 then
		--raise notice 'alimentid = 0';		

		select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 
			and kuu = month(tdKpv) and aasta = year (tdKpv);

		if not found then
			--raise notice 'TAABEL1 NOT FOUND';
			return lnSumma;
		end if;

	SELECT tund into nHours FROM Toograf WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);
	IF ifnull(nHours,0) = 0 then
		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)::numeric(6,4) * qryTooleping.toopaev )::INT4;
		ltSelgitus = ltSelgitus + 'Kokku tunnid kuues:'+ltrim(rtrim(nHours::varchar))+ltEnter;

		nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
		ltSelgitus = ltSelgitus + 'Kokku tunnid kuues, parandatud:'+ltrim(rtrim(nHours::varchar))+ltEnter;

	END IF;

		--raise notice 'hOUR %',nHours;
		if qryTooleping.tasuliik = 1 then
			lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;
			--raise notice 'Rate %',lnrate;
			ltSelgitus = ltSelgitus + 'Tunni hind:'+ltrim(rtrim(lnRate::varchar))+ltEnter;

		end if;

		if qryTooleping.tasuliik = 2 then
			lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs,qryPalkLib.round);
			lnRate := qryTooleping.palk * qryTooleping.kuurs;
			ltSelgitus = ltSelgitus + 'arvestus:'+ltrim(rtrim(qryTooleping.palk::varchar))+'*'+ltrim(rtrim(qryTooleping.kuurs::varchar))+'*'+
				ltrim(rtrim(qryTaabel1.kokku::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;
			
			-- muudetud 01/02/2005
			if qryPalkLib.tund = 5 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev  / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.tahtpaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			If  qryPalkLib.tund = 6 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev  / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.puhapaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			End if;
			If  qryPalkLib.tund = 7 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.uleajatoo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			End if;
			if qryPalkLib.tund =3 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.ohtu::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			if qryPalkLib.tund =4 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.oo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			if qryPalkLib.tund =2 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.paev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			return lnSumma;

		end if;

		If  qryPalkLib.tund = 5 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs,qryPalkLib.round);
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.tahtpaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			lnBaas := qryTaabel1.tahtpaev;

		End if;

		If  qryPalkLib.tund = 6 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs,qryPalkLib.round);
			lnBaas := qryTaabel1.puhapaev;
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.puhapaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

		End if;

		If  qryPalkLib.tund = 7 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);

			lnBaas := qryTaabel1.uleajatoo;
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.uleajatoo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


		End if;

		If  qryPalkLib.tund < 5 then			

			if qryPalkLib.tund =3 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.ohtu::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


			end if;

			if qryPalkLib.tund =4 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.oo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			if qryPalkLib.tund =2 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.paev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			if qryPalkLib.tund =1 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.kokku::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

--			raise notice 'nSumma %',nSumma;


--			raise notice 'lnSumma %',lnSumma;


			lnSumma := lnSumma + f_round( nSumma / lnKuurs, qryPalkLib.round);
--			ltSelgitus = ltSelgitus + 'parandamine(kokku):'+ltrim(rtrim(lnSumma::varchar))+'+'+ltrim(rtrim((nSumma / lnKuurs)::varchar))+ltEnter;


--			raise notice 'LnSumma %',lnSumma;


--			raise notice '	qryPalklib.round %',qrypalklib.round;

			lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 

				case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 

		End if;

	Else

--		lnBaas := calc_alimentid ();

--		lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)

	End if;



Else

	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs,qryPalkLib.round);
	ltSelgitus = ltSelgitus +ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*'+ltrim(rtrim(v_palk_kaart.kuurs::varchar))+ '/' +ltrim(rtrim(lnKuurs::varchar))+ltEnter;

	lnBaas := 0;

End if;


	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);

Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_arv(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbpeakasutaja;

-- Function: sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric)

-- DROP FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnMinpalk alias for $3;
	tntulubaas alias for $4;
	tnround alias for $5;
	tnjaak alias for $6;
	tngenlausend alias for $7;
	tnsuurasu alias for $8;
	tcvaluuta alias for $9;
	tnKuurs alias for $10;
	tnTm alias for $11;
	tnPm alias for $12;
	tnTka alias for $13;
	tnTki alias for $14;
	tnSm alias for $15;

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu, tm, pm, tka, tki, sm) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu, tnTm, tnPm, tnTka, tnTki, tnSm);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.palk_config_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (26, lnId,tcValuuta, tnKuurs);


else
	-- muuda 
	update palk_config set 
		 rekvid = tnRekvId, 
		 minpalk = tnMinPalk, 
		 tulubaas = tnTulubaas, 
		 round = tnRound, 
		 jaak = tnJaak, 
		 genlausend = tnGenLausend, 
		 suurasu = tnSuurasu,
		 tm = tnTm, 
		 pm = tnPm,
		 tka = tnTka,
		 tki = tnTki,
		 sm = tnSm
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, lnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = lnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) TO dbpeakasutaja;

-- Table: tmp_viivis

-- DROP TABLE tmp_viivis;

CREATE TABLE tmp_viivis
(
  dkpv date DEFAULT date(),
  "timestamp" character varying(20),
  id integer,
  rekvid integer,
  asutusid integer,
  konto character varying(20),
  algjaak numeric(14,4),
  algkpv date,
  arvnumber character varying(20),
  tahtaeg date,
  summa numeric(14,4),
  tasud1 date,
  tasun1 numeric(14,4) DEFAULT 0,
  paev1 integer DEFAULT 0,
  volg1 numeric(14,4) DEFAULT 0,
  tasud2 date,
  tasun2 numeric(14,4) DEFAULT 0,
  paev2 integer DEFAULT 0,
  volg2 numeric(14,4) DEFAULT 0,
  tasud3 date,
  tasun3 numeric(14,4) DEFAULT 0,
  paev3 integer DEFAULT 0,
  volg3 numeric(14,4) DEFAULT 0,
  tasud4 date,
  tasun4 numeric(14,4) DEFAULT 0,
  paev4 integer DEFAULT 0,
  volg4 numeric(14,4) DEFAULT 0,
  tasud5 date,
  tasun5 numeric(14,4) DEFAULT 0,
  paev5 integer DEFAULT 0,
  volg5 numeric(14,4) DEFAULT 0,
  tasud6 date,
  tasun6 numeric(14,4) DEFAULT 0,
  paev6 integer DEFAULT 0,
  volg6 numeric(14,4) DEFAULT 0,
  tasud7 date,
  tasun7 numeric(14,4) DEFAULT 0,
  paev7 integer DEFAULT 0,
  volg7 numeric(14,4) DEFAULT 0,
  tasud8 date,
  tasun8 numeric(14,4) DEFAULT 0,
  paev8 integer DEFAULT 0,
  volg8 numeric(14,4) DEFAULT 0,
  tasud9 date,
  tasun9 numeric(14,4) DEFAULT 0,
  paev9 integer DEFAULT 0,
  volg9 numeric(14,4) DEFAULT 0,
  viivis1 numeric(18,8) DEFAULT 0,
  viivis2 numeric(18,8) DEFAULT 0,
  viivis3 numeric(18,8) DEFAULT 0,
  viivis4 numeric(18,8) DEFAULT 0,
  viivis5 numeric(18,8) DEFAULT 0,
  viivis6 numeric(18,8) DEFAULT 0,
  muud text
)
WITH (
  OIDS=TRUE
);
ALTER TABLE tmp_viivis OWNER TO vlad;
GRANT ALL ON TABLE tmp_viivis TO vlad;
GRANT ALL ON TABLE tmp_viivis TO public;

-- Function: sp_update_palk_jaak(date, date, integer, integer)

-- DROP FUNCTION sp_update_palk_jaak(date, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_update_palk_jaak(date, date, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tdKpv1 alias for $1;
	tdKpv2	alias for $2;
	tnRekvId alias for $3;
	tnlepingId alias for $4;
	v_palk_jaak palk_jaak%rowtype;
	v_tooleping record;
	lnKuu1 int4;
	lnKuu2	int4;
	lnAasta1 int4;
	lnAasta2 int4;	
	lnElatis numeric (12,4);
	lnTulubaas numeric(12,4);
	lnTookoht int;
	lnArv numeric (12,4);
	lnCount int;
	lnCount_2004 int;
	lnCount_2005 int;
	ng31 numeric (12,4);
	lng31 numeric (12,4);
	lng31_2004 numeric (12,4);
	lng31_2005 numeric (12,4);
	lnTuluArv numeric(12,4);
	lnArvJaak numeric(12,4);
	lnTulumaar int;
	
	lnTuludPm numeric (12,4);
begin

	lnkuu1 := month(tdKpv1); 
	lnkuu2 := month(tdKpv2);  
	lnAasta1 := year(tdKpv1);  
	lnAasta2 := year(tdKpv2);
	lnTookoht := 1; 

	select * into v_tooleping from tooleping where id = tnLepingId;
	
	lnTookoht := v_tooleping.pohikoht;
--	select pohikoht into lnTookoht from tooleping where id = tnLepingId;
--	select Tulubaas into lnTulubaas from palk_config where rekvid = tnRekvId;

	select palk_config.tulubaas * ifnull(dokvaluuta1.kuurs,1) into lnTulubaas 
		from palk_config left outer join dokvaluuta1 on (palk_config.id =dokvaluuta1.dokid and  dokvaluuta1.dokliik = 26) where palk_config.rekvid = tnrekvId;

	lnTulubaas = ifnull(lnTulubaas,2250);	

	if lnTookoht = 0 then
		lnTulubaas := 0;
	end if;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.arvestatud 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 1    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.arvestatud  := ifnull (v_palk_jaak.arvestatud ,0);

	-- kontrollime PM

	select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1  
		AND Palk_oper.kpv >= tdKpv1   
		AND Palk_oper.kpv <= tdKpv2
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		And Palk_oper.rekvid =  tnRekvId
		And palk_kaart.lepingid = tnLepingid;

	lnTuludPm = ifnull(lnTuludPm,0);	
	if lnTuludPm > 0 then
		raise notice 'tulud Pm III samba: %',lnTuludPm;
		v_palk_jaak.arvestatud = v_palk_jaak.arvestatud - lnTuludPm;
	end if;

	raise notice 'v_palk_jaak.arvestatud: %',v_palk_jaak.arvestatud;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.kinni 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE (Palk_lib.liik = 2    or palk_lib.liik = 8 or palk_lib.liik = 6 or (palk_lib.liik = 7 and palk_lib.asutusest = 0))
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.kinni := ifnull (v_palk_jaak.kinni,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tki
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 0
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tki := ifnull (v_palk_jaak.tki,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tka
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 1
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tka := ifnull (v_palk_jaak.tka,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.pm
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE  palk_lib.liik = 8
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.pm := ifnull (v_palk_jaak.pm,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.tulumaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 4    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tulumaks := ifnull (v_palk_jaak.Tulumaks,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.sotsmaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 5
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.Sotsmaks := ifnull (v_palk_jaak.Sotsmaks,0);

	select id into v_palk_jaak.id from palk_jaak 
	where lepingId = tnlepingId 
	and kuu = lnkuu1
	and aasta = lnaasta1;

	v_palk_jaak.id := ifnull(v_palk_jaak.id,0);


	if not found then
		v_palk_jaak.id := 0;
	end if;
	        select sum(palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into lnElatis 
			from palk_oper 
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where libId in 
			(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.elatis = 1 AND p.liik = 2) 
			AND Palk_oper.kpv >= tdKpv1   
			AND Palk_oper.kpv <= tdKpv2
			AND Palk_oper.rekvId = tnRekvId
			AND palk_oper.lepingId	= tnLepingId;

        select sum(o.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into lnArv 
		from palk_oper o inner join palk_kaart  k on o.lepingid = k.lepingid and k.libId = o.libId
		left outer join dokvaluuta1 on (o.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where o.libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.liik = 1) 
		and k.tulumaks = 1
		AND o.kpv >= tdKpv1   
		AND o.kpv <= tdKpv2
		AND o.rekvId = tnRekvId
		AND o.lepingId	= tnLepingId;

	v_palk_jaak.g31 := lnArv - v_palk_jaak.tki - v_palk_jaak.pm;

-- muudetud 03/01/2005

	if v_palk_jaak.g31 > lnTulubaas then
		v_palk_jaak.g31 := lnTulubaas;
	end if;
	
	if v_tooleping.pohikoht > 0 then

		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1;

	raise notice 'lng31 %',lng31_2005;

	select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1
			and date(aasta,kuu,1) >= v_tooleping.algab;

		raise notice 'lnCount %',lnCount_2005;

		-- should be 1400 * periods
		ng31 :=  lnTulubaas * lnCount_2005 ;
		raise notice 'lnKuu1 %',lnKuu1;
		raise notice 'ng31 %',ng31;
		raise notice 'v_palk_jaak.arvestatud %',v_palk_jaak.arvestatud;
		raise notice 'lnTulubaas %',lnTulubaas;

		lnArvJaak := v_palk_jaak.arvestatud - v_palk_jaak.pm - v_palk_jaak.tki;
		raise notice 'lnArvJaak %',lnArvJaak;

		if lnArvJaak < lnTulubaas  then
			-- muudetud 25/01/2005
			-- kontrollime teised lepingud
			select count(*) into lnTulumaar from palk_kaart 
				where lepingId in (select id from tooleping where parentid = v_tooleping.parentId 
				and pohikoht = 0)
				and tulumaar = 0 
				and libId in (select parentid from palk_lib where liik = 4);
			if ifnull(lnTulumaar,0) > 0 then
				-- > 2 lepingud ja vahemalkt uks ei arvesta
				select sum(arvestatud) - sum(pm) - sum(tki) into lnArvJaak from palk_jaak 
					where aasta = lnAasta1 
					and kuu = lnKuu1
					and date(aasta,kuu,1) >= v_tooleping.algab
					and (lepingId = v_tooleping.id or lepingId in 
					(select distinct palk_kaart.lepingid from palk_kaart inner join tooleping on palk_kaart.lepingId = tooleping.id 
						where tooleping.parentid = v_tooleping.parentId and pohikoht = 0
						and tulumaar = 0 		
						and libId in (select parentid from palk_lib where liik = 4)));
			end if;
		end if;	
		raise notice 'parast lnArvJaak %',lnArvJaak;

		if lnArvJaak < lnTulubaas  then

			lnTulubaas := lnArvJaak;
			raise notice 'less then vaja %',lnTulubaas;
		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);
				raise notice 'with reserv  %',lnTulubaas;
			end if;
			raise notice 'with reserv after %',lnTulubaas;
			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
		
			end if;

		end if;
	else
		lnTulubaas:= 0;
	end if;

raise notice 'lnTulubaas %',lnTulubaas;		

if v_palk_jaak.id = 0 then

	insert into palk_jaak ( lepingId, kuu, aasta, arvestatud, kinni, tulumaks, sotsmaks, tka, tki, pm, g31)
		values (tnlepingId, lnkuu1, lnaasta1, v_palk_jaak.arvestatud, v_palk_jaak.kinni, 
		v_palk_jaak.tulumaks, v_palk_jaak.sotsmaks, v_palk_jaak.tka, v_palk_jaak.tki, v_palk_jaak.pm, ifnull(lnTulubaas,0));
else
--raise notice 'v_palk_jaak.id %',v_palk_jaak.id;
	update palk_jaak set 
		arvestatud = v_palk_jaak.arvestatud,
		kinni = v_palk_jaak.kinni,
		tka = v_palk_jaak.tka,
		tki = v_palk_jaak.tki,
		pm = v_palk_jaak.pm,
		tulumaks = v_palk_jaak.tulumaks,
		sotsmaks = v_palk_jaak.sotsmaks,
		g31 = ifnull(lnTulubaas,0)
		where id = v_palk_jaak.id;
end if;

 return sp_calc_palk_jaak (lnKuu1, lnaasta1, tnlepingId);

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_palk_jaak(date, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbpeakasutaja;
