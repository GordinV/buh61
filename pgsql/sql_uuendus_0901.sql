-- View: curtsd1

-- View: curtsd

DROP VIEW curtsd;

CREATE OR REPLACE VIEW curtsd AS 
 SELECT palk_oper.id, rekv.parentid, rekv.id AS rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, 
	tooleping.resident, tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv,
	 palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric as summa, 
	 rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19a'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19a, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_21, 
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
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN rekv ON rekv.id = palk_oper.rekvid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid AND palk_kaart.parentid = asutus.id
 left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)   ;

ALTER TABLE curtsd OWNER TO vlad;
GRANT SELECT ON TABLE curtsd TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd TO dbkasutaja;
GRANT SELECT ON TABLE curtsd TO dbvaatleja;



 DROP VIEW curtsd1;

CREATE OR REPLACE VIEW curtsd1 AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, 
	palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric as summa, 
	rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '01'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric 
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid
   left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12);

ALTER TABLE curtsd1 OWNER TO vlad;
GRANT SELECT ON TABLE curtsd1 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbvaatleja;

-- Function: sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

/*

*/
CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric)
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

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu);


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
		 suurasu = tnSuurasu
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, tnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = tnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbpeakasutaja;

-- Function: sp_calc_tulumaks(integer, integer, date)
/*
select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  
	from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = 63;
select * from dokvaluuta1 order by id desc limit 3

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
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);


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
raise notice 'lnTulubaas %',lnTulubaas;
--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa * v_palk_kaart.kuurs;

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


	raise notice 'lnTulud %',lnTulud;

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
	else

		SELECT  sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		and palk_oper.kpv = tdKpv  
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;


--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

raise notice 'lnTulud %',lnTulud;


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
 

--	and tulumaar = v_palk_kaart.summa

	end if;
raise notice 'lnKulud %',lnKulud;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice 'lnTulubaas %',lnTulubaas;
		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv);

		lng31 := lng31_2005;

		raise notice 'lng31 %',lng31;
		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and date(aasta,kuu,1) >= qryTooleping.algab;


		raise notice 'lnCount %',lnCount;

		-- should be 1400 * periods
		ng31 := V_palk_config.tulubaas * v_palk_config.kuurs * lnCount_2005 ;
		raise notice 'ng31 %',ng31;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
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

	end if;

	lnSumma := v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)) / lnKuurs;
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;

-- muudetud 04/01/2005
	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnTulubaas 
			from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND palk_oper.MUUD = 'AVANS';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - (lnTulubaas / lnKuurs);
		END IF;
	END IF;

	lnSumma = f_round(lnSumma,qryPalkLib.Round);
	raise notice 'lnSumma %',lnSumma;
end if;
Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tulumaks(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbpeakasutaja;


-- Function: sp_calc_muuda(integer, integer, date)

-- DROP FUNCTION sp_calc_muuda(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_muuda(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (14,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTaabel1 record;
	nSumma numeric(14,4);
	nHours int4;
	lnBaas numeric(14,4);
	lnrekv int4;
	lnKulud numeric(14,4);
	lnKuurs numeric(12,4);
begin

lnSumma :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

select palk_kaart .*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)	
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	where tooleping.id = tnlepingId;

select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
	from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = qryTooleping.rekvid;
--select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId; 


nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev)::INT4;
If v_palk_kaart.percent_ = 1 then
	if  qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * 0.01 * qryTooleping.toopaev * (qryTaabel1.kokku / nHours) * qryTooleping.kuurs / lnKuurs;
	end if;
	if qryPalkLib.palgafond = 1 then
		if qryPalkLib.liik = 7  then
			raise notice '7';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1 
			and palk_lib.tululiik <> '13';
		end if;	
		if  qryPalkLib.liik = 8 then
			raise notice '8';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;
		end if;	
		if  qryPalkLib.liik <> 7 and qryPalkLib.liik <> 8 then
			raise notice 'muud';
			-- tulud
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
		end if;
	end if;
	if qryPalkLib.maks = 1 then
		-- Tulud - Kulud
		-- Arvestame kulud

		SELECT sum(palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_kaart.lepingId = tnLepingId
		AND Palk_oper.kpv = tdKpv  
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id where Palk_lib.liik in (2,4,7,8 ));
		lnSumma = lnSumma - ifnull(lnKulud,0);
		if lnSumma < 0 then
			lnSumma = 0;
		end if;		
	end if;

	
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnSumma / lnKuurs, qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
End if;

Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_muuda(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbpeakasutaja;


-- Function: sp_calc_sots(integer, integer, date)

-- DROP FUNCTION sp_calc_sots(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_sots(integer, integer, date)
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
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnKuurs numeric(12,4);
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);


select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

If v_palk_kaart.percent_ = 1 then

	select pohikoht into qryTooleping from tooleping where id = tnlepingId;
	select rekvId into lnrekv from library where id = qryPalkLib.parentId;

	select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
		from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = lnrekv;
	
--	select minpalk into v_palk_config from palk_config where rekvid = lnrekv;

	SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnBaas 
	FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_oper.id and dokvaluuta1.dokliik = 12) 
	WHERE  Palk_oper.kpv = tdKpv      
	AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk * v_palk_config.kuurs else 0 end;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnBaas / lnKuurs,qryPalkLib.round);
else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
end if;

Return lnSumma;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_sots(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbpeakasutaja;


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
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbpeakasutaja;
