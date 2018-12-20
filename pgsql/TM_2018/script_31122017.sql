
drop table if exists taotlus_mvt;

CREATE TABLE taotlus_mvt
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  userid integer NOT NULL,
  kpv date NOT NULL,
  alg_kpv date NOT NULL,
  lopp_kpv date NOT NULL,
  lepingid integer NOT NULL,
  summa numeric(14,4) NOT NULL default 0,
  muud text,
  CONSTRAINT taotlus_mvt_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
GRANT SELECT ON TABLE taotlus_mvt TO dbvaatleja;
GRANT ALL ON TABLE taotlus_mvt TO dbpeakasutaja;
GRANT SELECT, INSERT, UPDATE ON TABLE taotlus_mvt TO dbkasutaja;


drop index if exists taotlus_mvt_rekvid;

CREATE INDEX taotlus_mvt_rekvid
  ON taotlus_mvt
  USING btree
  (rekvid);

drop index if exists taotlus_mvt_lepingid;

CREATE INDEX taotlus_mvt_lepingid
  ON taotlus_mvt
  USING btree
  (lepingid);

drop index if exists taotlus_mvt_kpv;

CREATE INDEX taotlus_mvt_kpv
  ON taotlus_mvt
  USING btree
  (alg_kpv, lopp_kpv);

GRANT ALL ON TABLE taotlus_mvt_id_seq TO public;
    

CREATE OR REPLACE FUNCTION trigd_palk_oper_after()
  RETURNS trigger AS
$BODY$
declare 
	curDokId record;	

	lnLiik int;

begin

IF old.Journalid > 0 then

	perform sp_del_journal(old.Journalid::int4,1::int4);

end if;

perform sp_update_palk_jaak(old.kpv, old.kpv, old.rekvid, old.lepingId);
--perform recalc_palk_saldo(old.lepingId::int4,month(old.kpv)::int2);

select liik into lnLiik from palk_lib where parentid = old.libid;

If lnliik = 6 then

	select * into curDokId from (

		select id as dokid, tyyp as doktyyp, dokid as parentid, doktyyp as parenttyyp 

		from korder1 where dokid >= old.Id 

		union 

		select id as dokid, 3 as doktyyp, dokid as parentid, doktyyp as parenttyyp 

		from MK  where dokid >= old.Id ) a;



	If found then 

		IF curdokid.doktyyp = 3 then

			perform sp_del_mk1(curdokid.dokid,1);

		ELSE

			perform sp_del_korderid(curdokid.dokid,1);

		END IF;		

	END IF;

END IF;
perform sp_register_oper(old.rekvid,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, old.rekvid));

return null;



end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbadmin;
GRANT EXECUTE ON FUNCTION trigd_palk_oper_after() TO dbvaatleja;  
  
  
CREATE OR REPLACE FUNCTION trigiu_palk_oper_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	-- muudetud 18/02/2005
	if year(new.kpv) > 2005 then
		perform sp_register_oper(new.rekvid,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, new.rekvid));
	end if;
	perform recalc_palk_saldo(new.lepingId, month(new.kpv)::smallint, year(new.kpv)::smallint);	
--	perform sp_update_palk_jaak(date(year(new.kpv), month(new.kpv), 1), godate(year(new.kpv), month(new.kpv), 1), new.rekvid, new.lepingId);

	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
drop function if exists trigd_taotlus_mvt_after();

CREATE OR REPLACE FUNCTION trigd_taotlus_mvt_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(0,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

drop function if exists trigiu_taotlus_mvt_after();

CREATE OR REPLACE FUNCTION trigiu_taotlus_mvt_after()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(0,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

drop trigger if exists trigd_taotlus_mvt_after ON taotlus_mvt;

CREATE TRIGGER trigd_taotlus_mvt_after
  AFTER DELETE
  ON taotlus_mvt
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_taotlus_mvt_after();

drop trigger if exists trigiu_taotlus_mvt_after ON taotlus_mvt;

CREATE TRIGGER trigiu_taotlus_mvt_after
  AFTER INSERT OR UPDATE
  ON taotlus_mvt
  FOR EACH ROW
  EXECUTE PROCEDURE trigiu_taotlus_mvt_after();


CREATE OR REPLACE VIEW curpalkoper AS 
 SELECT library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus, asutus.nimetus AS isik, asutus.id AS isikid, ifnull(journalid.number, 0) AS journalid, palk_oper.journal1id, palk_oper.kpv, palk_oper.summa, palk_oper.id, palk_oper.libid, palk_oper.rekvid, tooleping.pank, tooleping.aa, tooleping.osakondid, 
        CASE
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '1-0'::bpchar THEN '+'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '2-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '6-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '4-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '8-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '7-0'::bpchar THEN '-'::text::bpchar
            ELSE '%'::bpchar
        END AS liik, 
        CASE
            WHEN palk_lib.tund = 1 THEN 'KOIK'::text
            WHEN palk_lib.tund = 2 THEN 'PAEV'::text
            WHEN palk_lib.tund = 3 THEN 'OHT'::text
            WHEN palk_lib.tund = 4 THEN 'OO'::text
            WHEN palk_lib.tund = 5 THEN 'PUHKUS'::text
            WHEN palk_lib.tund = 6 THEN 'PUHA'::text
            WHEN palk_lib.tund = 7 THEN 'ULETOO'::text
            WHEN palk_lib.tund = 8 THEN 'HAIGUS'::text
            ELSE NULL::text
        END AS tund, 
        CASE
            WHEN palk_lib.maks = 1 THEN 'JAH'::text
            ELSE 'EI'::text
        END AS maks, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM palk_oper
   JOIN library ON palk_oper.libid = library.id
   JOIN palk_lib ON palk_lib.parentid = library.id
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   LEFT JOIN journalid ON palk_oper.journalid = journalid.journalid
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

GRANT SELECT ON TABLE curpalkoper TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper TO dbpeakasutaja;


DROP VIEW IF EXISTS v_isiku_mvt_taotlused;

CREATE VIEW v_isiku_mvt_taotlused AS
  SELECT
    sum(kuu_summa) AS summa,
    isikId,
    kuu,
    aasta
  FROM (
         SELECT
           tooleping.parentId AS isikId,
           t.lepingid,
           t.summa            AS summa,
           alg_kpv,
           lopp_kpv,
           v_month.kuu,
           year(lopp_kpv)     AS aasta,
           CASE WHEN month(alg_kpv) <= v_month.kuu AND month(lopp_kpv) >= v_month.kuu
             THEN t.summa
           ELSE 0 END         AS kuu_summa
         FROM taotlus_mvt t, (SELECT 1 AS kuu
                              UNION
                              SELECT 2 AS kuu
                              UNION
                              SELECT 3 AS kuu
                              UNION
                              SELECT 4 AS kuu
                              UNION
                              SELECT 5 AS kuu
                              UNION
                              SELECT 6 AS kuu
                              UNION
                              SELECT 7 AS kuu
                              UNION
                              SELECT 8 AS kuu
                              UNION
                              SELECT 9 AS kuu
                              UNION
                              SELECT 10 AS kuu
                              UNION
                              SELECT 11 AS kuu
                              UNION
                              SELECT 12 AS kuu
           ) v_month, tooleping
         WHERE tooleping.id = t.lepingId
               AND t.summa > 0
       ) qry
  GROUP BY isikid, aasta, kuu;


GRANT ALL ON TABLE v_isiku_mvt_taotlused TO dbkasutaja;
GRANT ALL ON TABLE v_isiku_mvt_taotlused TO dbpeakasutaja;
  
drop function if exists calc_mvt(numeric, date);
drop function if exists calc_mvt(numeric, numeric, date);


CREATE OR REPLACE FUNCTION calc_mvt(tulu numeric, mvt numeric, kpv date )
  RETURNS numeric AS
$BODY$

DECLARE 
	lnMVT numeric(14,4) = 0;
	lnMaxLubatatudMVT numeric(14,4) = 500;
	lnTaotlusedMVT numeric(14,4) = coalesce(mvt, 500);
	lnTuluMaxPiir numeric(14,4) = 1200;
	lnTuluMinPiir numeric(14,4) = 900;
	lnMaxMvt numeric(14,4) = lnMaxLubatatudMVT - lnMaxLubatatudMVT / lnTuluMinPiir * (tulu - lnTuluMaxPiir); 	--500 - 500 / 900 × 	(tulu - 1200) 
	lnArvestatudMVT numeric(14,4) = lnMaxMvt ;

begin
	if lnMaxMvt > mvt then
		--vottame nii palju kui lubatatud
		lnArvestatudMVT = mvt;
	END IF;

	if lnMaxMvt < mvt and lnArvestatudMVT < lnMaxMvt then
		-- vottame max lubatatud MVT
		lnArvestatudMVT = lnMaxMvt;
	end if;
	if lnArvestatudMVT < mvt then
		lnMVT = lnArvestatudMVT;
	else 
		lnMVT = mvt;
	end if;

	raise notice 'lnMVT: %, lnTaotlusedMVT %, lnTuluMinPiir %, lnMaxMvt %, lnArvestatudMVT %', lnMVT, lnTaotlusedMVT, lnTuluMinPiir, lnMaxMvt, lnArvestatudMVT;

	-- juhl kui «tulu – PM – TKI» < 500 EUR, siis kasutame teine arvestus ja võrdleme tulemus ja taotletud MVT

	if lnMVT >= tulu then 
		lnMVT = tulu;
	end if;

	if (lnMVT > mvt) then
		lnMVT = mvt;
	end if;

	if (lnMVT < 0) then
		lnMVT = 0;	
	end if;
	return lnMVT;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION calc_mvt(numeric, numeric, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION calc_mvt(numeric, numeric, date) TO dbpeakasutaja;


DROP FUNCTION IF EXISTS gen_palkoper( INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER );

CREATE OR REPLACE FUNCTION gen_palkoper(tnlepingid INTEGER, tnlibid INTEGER, tndoklausid INTEGER, tdkpv DATE,
                                        tnavans    INTEGER, tnminpalk INTEGER)
  RETURNS INTEGER AS
$BODY$
DECLARE
  l_sotsmaks_min_palk NUMERIC [];
  qrypalklib          RECORD;
  v_klassiflib        RECORD;
  v_palk_kaart        RECORD;
  v_dokprop           RECORD;
  lnAsutusest         INT;
  lnSumma             NUMERIC(12, 4) = 0;
  lcTunnus            VARCHAR = space(1);
  lnPalkOperId        INT;
  lcTp                VARCHAR = '800699';
  v_valuuta           RECORD;
  lnRekvId            INTEGER;
  lnParentId          INTEGER;
  l_pohikoht          INTEGER = 0;

  lcPref              VARCHAR;
  lcTimestamp         VARCHAR;
  v_palk_selg         RECORD;
  l_last_paev         DATE = (date(year(tdKpv), month(tdKpv), 1) + INTERVAL '1 month') :: DATE - 1;

  l_sotsmaks_min_id   INTEGER = 0;
  l_lepingId_min_sots INTEGER;
  l_libId_min_sots    INTEGER;


BEGIN
  lcPref = '';

  SELECT
    rekvid,
    parentId,
    pohikoht
  INTO lnrekvid, lnParentId, l_pohikoht
  FROM tooleping
  WHERE id = tnLepingId;

  SELECT
    Library.kood,
    ifnull((SELECT valuuta1.kuurs
            FROM valuuta1
            WHERE parentid = library.id
            ORDER BY Library.id DESC
            LIMIT 1), 0) AS kuurs
  INTO v_valuuta
  FROM Library
  WHERE library = 'VALUUTA' AND library.tun1 = 1;

  -- v_klassiflib init
  SELECT *
  INTO v_klassiflib
  FROM klassiflib
  WHERE libId = tnLibId
  ORDER BY id DESC
  LIMIT 1;

  -- v_palk_kaart init
  SELECT *
  INTO v_palk_kaart
  FROM palk_kaart
  WHERE libId = tnLibId AND lepingId = tnLepingId;

  -- qrypalklib init
  SELECT
    palk_lib.*,
    library.rekvId
  INTO qrypalklib
  FROM palk_lib
    INNER JOIN library ON library.id = palk_lib.parentid
  WHERE palk_lib.parentid = tnLibId;

  --v_dokprop init
  SELECT *
  INTO v_dokprop
  FROM dokprop
  WHERE id = tnDokLausId;

  --delete old calculations
  IF qryPalkLib.liik = 1 AND (SELECT count(id)
                              FROM palk_oper
                              WHERE kpv = tdKpv AND lepingId = tnLepingid AND libId = tnLibId AND period IS NOT NULL AND
                                    period <> tdKpv) > 0
  THEN
    --ei saa arvestada sest on parandusi
    RETURN 0;
  ELSE
    DELETE FROM journal
    WHERE id IN (SELECT journalId
                 FROM palk_oper
                 WHERE lepingid = tnLepingId AND libId = tnLibId AND kpv = tdKpv);
    DELETE FROM palk_oper
    WHERE lepingid = tnLepingId AND libId = tnLibId AND kpv = tdKpv AND summa <> 0;

  END IF;

  --calculation

  IF qryPalkLib.liik = 1
  THEN
    lnSumma = sp_calc_arv(tnLepingId, tnLibId, tdKpv, NULL, NULL, 0);
    lcPref = 'ARV';
  ELSEIF qryPalkLib.liik = 2
    THEN
      lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 3
    THEN
      lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 4
    THEN
      lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
      lcPref = 'TM';
  ELSEIF qryPalkLib.liik = 5
    THEN
      lcPref = 'SOTS';
      lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
  ELSEIF qryPalkLib.liik = 6
    THEN
      lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 7
    THEN
      lcPref = 'TK';
      IF lnAsutusest < 1
      THEN
        lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
      ELSE
        lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
      END IF;
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
  ELSEIF qryPalkLib.liik = 8
    THEN
      lcPref = 'PM';
      lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
  ELSE
    lnSumma = 0;
  END IF;


  IF coalesce(lnSumma, 0) <> 0 OR qryPalkLib.liik = 5
  THEN

    lnSumma = coalesce(lnSumma, 0);

    --find tunnus
    IF v_klassiflib.tunnusid > 0 AND empty(v_palk_kaart.tunnusid)
    THEN
      SELECT kood
      INTO lcTunnus
      FROM library
      WHERE id = v_klassiflib.tunnusId;
    END IF;

    IF v_palk_kaart.tunnusid > 0
    THEN
      SELECT kood
      INTO lcTunnus
      FROM library
      WHERE id = v_palk_kaart.tunnusId;
    END IF;

    lcTunnus = coalesce(lcTunnus, space(1));

    lcTimestamp = left(
        lcPref + LTRIM(RTRIM(str(tnLepingId))) + LTRIM(RTRIM(str(tnLibId))) + ltrim(rtrim(str(dateasint(tdKpv)))), 20);

    --get calculation details
    SELECT
      muud :: VARCHAR AS selg,
      volg1           AS tm,
      tasun1          AS tulubaas,
      volg2           AS sm,
      volg4           AS tki,
      volg5           AS pm,
      volg6           AS tka
    INTO v_palk_selg
    FROM tmp_viivis
    WHERE timestamp = lcTimestamp
    ORDER BY oid DESC
    LIMIT 1;


    IF qrypalklib.tululiik = ''
    THEN
      qrypalklib.tululiik = '0';
    END IF;

    --save palk_oper
    IF lnSumma <> 0
    THEN
      lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid,
                                           v_palk_selg.selg,
                                           ifnull(v_klassiflib.kood1, space(1)), ifnull(v_klassiflib.kood2, 'LE-P'),
                                           ifnull(v_klassiflib.kood3, space(1)),
                                           ifnull(v_klassiflib.kood4, space(1)), ifnull(v_klassiflib.kood5, space(1)),
                                           ifnull(v_klassiflib.konto, space(1)),
                                           lcTp, lcTunnus, v_valuuta.kood, v_valuuta.kuurs, v_klassiflib.proj,
                                           qrypalklib.tululiik :: INTEGER, ifnull(v_palk_selg.tm, 0),
                                           ifnull(v_palk_selg.sm, 0), ifnull(v_palk_selg.tki, 0),
                                           ifnull(v_palk_selg.pm, 0),
                                           ifnull(v_palk_selg.tulubaas, 0), coalesce(v_palk_selg.tka, 0), NULL :: DATE);

      --clean calc details
      DELETE FROM tmp_viivis
      WHERE rekvid = lnRekvid AND timestamp = lcTimestamp;


    END IF;

    --if calculation of sots.maks, will check sor min.sotsmaks
    IF qryPalkLib.liik = 5 AND NOT empty(tnMinPalk) AND (SELECT count(pk.id)
                                                         FROM palk_kaart pk
                                                           INNER JOIN palk_lib pl ON pl.parentid = pk.libId
                                                         WHERE pk.lepingid IN (SELECT id
                                                                               FROM tooleping
                                                                               WHERE
                                                                                 parentid = lnParentId AND pohikoht = 1
                                                                                 OR id = tnLepingid)
                                                               AND pl.liik = 5
                                                               AND coalesce(pk.minsots, 0) = 1) > 0 AND l_pohikoht = 1
    THEN

      SELECT
        po.id,
        po.libid,
        po.lepingId
      INTO l_sotsmaks_min_id, l_lepingId_min_sots, l_libId_min_sots
      FROM palk_oper po
      WHERE lepingid IN (SELECT id
                         FROM tooleping
                         WHERE parentid = lnParentId AND pohikoht = 1 AND rekvid = lnrekvid)
            AND kpv = l_last_paev
            AND libId = tnLibId
            AND id <> lnPalkOperId
            AND po.sotsmaks <> 0
      LIMIT 1;

      -- arvestame sotsmaks minpalgast
      l_sotsmaks_min_palk = sp_calc_min_sots(tnLepingid, l_last_paev);

      -- if min.sotsmaks, then save
      IF l_sotsmaks_min_palk IS NOT NULL
      THEN

        l_sotsmaks_min_id = sp_salvesta_palk_oper(coalesce(l_sotsmaks_min_id, 0), lnRekvid,
                                                  coalesce(l_libId_min_sots, tnLibId),
                                                  coalesce(l_lepingId_min_sots, tnlepingid), l_last_paev,
                                                  l_sotsmaks_min_palk [1], tnDoklausid,
                                                  ('SM min. palgast -> ' + ifnull(l_sotsmaks_min_palk [1], 0) :: TEXT +
                                                   ' SM summast -> ' + ifnull(l_sotsmaks_min_palk [2], 0) :: TEXT),
                                                  ifnull(v_klassiflib.kood1, space(1)),
                                                  ifnull(v_klassiflib.kood2, 'LE-P'),
                                                  ifnull(v_klassiflib.kood3, space(1)),
                                                  ifnull(v_klassiflib.kood4, space(1)),
                                                  ifnull(v_klassiflib.kood5, space(1)),
                                                  ifnull(v_klassiflib.konto, space(1)),
                                                  lcTp, lcTunnus, v_valuuta.kood, v_valuuta.kuurs, v_klassiflib.proj,
                                                  qrypalklib.tululiik :: INTEGER, 0, ifnull(l_sotsmaks_min_palk [2], 0),
                                                  0, 0,
                                                  0, 0, NULL :: DATE);
      ELSE
        IF coalesce(l_sotsmaks_min_id, 0) > 0
        THEN
          -- kustuta vana arvestus
          PERFORM sp_del_palk_oper(l_sotsmaks_min_id, 1);
        END IF;

      END IF;
    END IF;

    --		lisatud 31/12/2004
    IF tnAvans > 0 AND qryPalkLib.liik = 6
    THEN
      PERFORM sp_calc_avansimaksed(lnpalkOperId);
    END IF;

    -- umardamine
    IF qryPalkLib.liik = 1 AND lnSumma <> 0
       AND -- tulud rohkem kui 1
       (
         SELECT count(palk_oper.id)
         FROM palk_oper
         WHERE lepingId IN (SELECT id
                            FROM tooleping
                            WHERE parentId = lnParentId
         )
               AND rekvId = lnrekvid
               AND summa <> 0
               AND libId IN (SELECT l.id
                             FROM library l
                               INNER JOIN palk_lib pl
                                 ON pl.parentId = l.id AND pl.liik = 1)
               AND year(kpv) = year(tdKpv) AND month(kpv) = month(tdKpv)
       ) > 1


    THEN
      -- umardamine
      PERFORM sp_calc_umardamine(lnParentId, tdKpv, lnrekvid);
    END IF;

    /*-- miinus mvt check
    IF qryPalkLib.liik = 1 AND lnSumma <> 0 AND (SELECT count(id)
                                                 FROM palk_oper
                                                 WHERE lepingId IN (SELECT id
                                                                    FROM tooleping
                                                                    WHERE parentId = lnParentId
                                                 )
                                                       AND rekvId = lnrekvid
                                                       AND summa <> 0
                                                       AND year(kpv) = year(tdKpv) AND month(kpv) = month(tdKpv)
                                                       AND tulubaas < 0) > 0
    THEN
      PERFORM sp_paranda_mvt_miinus(lnParentId, lnrekvid, tdKpv);
    END IF;
*/

  END IF;
  RETURN lnpalkOperId;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbpeakasutaja;


DROP FUNCTION if exists recalc_palk_saldo(integer, smallint, smallint);

CREATE OR REPLACE FUNCTION recalc_palk_saldo(tnlepingid integer, tnmonth smallint, tnYear smallint)
  RETURNS integer AS
$BODY$
declare 

	lKpv1	date;
	lKpv2	date;
	lnrekvid int;
	lnAasta smallint = coalesce(tnYear, year());

begin
	
	If ifnull(tnMonth,0) = 0 then

		lKpv1 = date (year (), month (),1);
		
		lKpv2 = DATE(YEAR(),12,31);

	ELSE

		lKpv1 = DATE(lnAasta,tnMonth,1);

		--muudetud 03/01/2005
		lKpv2 = gomonth(lKpv1,1)  - 1; 

	end if;

	select t.rekvid into lnRekvid 
		from tooleping t
	where t.id = tnLepingId;


	return sp_update_palk_jaak(lKpv1,lKpv2, lnRekvId, tnlepingId);

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint, smallint) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint, smallint) TO dbpeakasutaja;



DROP FUNCTION IF EXISTS sp_calc_arv( INTEGER, INTEGER, DATE, NUMERIC, DATE );
DROP FUNCTION IF EXISTS sp_calc_arv( INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER );

CREATE OR REPLACE FUNCTION sp_calc_arv(tnLepingid INTEGER, tnLibId INTEGER, tdKpv DATE, tnSumma NUMERIC,
                                       tdPeriod   DATE, tnUmardamine INTEGER)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  lnSumma              NUMERIC(18, 8);
  v_palk_kaart         RECORD;
  qrytooleping         RECORD;
  qryPalkLib           RECORD;
  qryTaabel1           RECORD;
  npalk                NUMERIC(20, 10);
  nHours               NUMERIC(20, 10);
  lnRate               NUMERIC(20, 10);
  nSumma               NUMERIC(20, 10);
  lnKuuSumma           NUMERIC(20, 10) = 0;
  lnBaas               NUMERIC(20, 10);
  lnKuurs              NUMERIC(12, 4);

  ltSelgitus           TEXT;
  ltEnter              CHARACTER(20);
  lcTimestamp          VARCHAR(20);

  lTKA                 NUMERIC(14, 4) = 0;
  lTKI                 NUMERIC(14, 4) = 0;
  lTM                  NUMERIC(14, 4) = 0;
  lSM                  NUMERIC(14, 4) = 0;
  lPM                  NUMERIC(14, 4) = 0;

  v_kaart              RECORD;
  l_tulubaas_kokku     NUMERIC(14, 4) = 0;
  l_tulubaas           NUMERIC(14, 4) = 0;
  l_kasutatud_tulubaas NUMERIC(14, 4) = 0;
  l_PM_maar            NUMERIC(8, 2) = 2;
  l_TKI_maar           NUMERIC(8, 2) = 1.6;
  l_TKA_maar           NUMERIC(8, 2) = 0.8;
  l_SM_maar            NUMERIC(8, 2) = 33;
  l_TM_maar            NUMERIC(8, 2) = 20;
  l_min_sots           NUMERIC(14, 4) = 0;
  v_maksud             RECORD;
  l_aasta_alg          DATE = date(year(tdKpv), 01, 01);
BEGIN

  nHours :=0;
  lnSumma := 0;
  nPalk:=0;
  lnBaas :=0;
  lnKuurs = fnc_currentkuurs(tdKpv);

  ltSelgitus = '';
  ltEnter = '
';
  lcTimestamp = left(
      'ARV' + LTRIM(RTRIM(str(tnLepingId))) + LTRIM(RTRIM(str(tnLibId))) + ltrim(rtrim(str(dateasint(tdKpv)))), 20);

  --v_palk_kaart init
  SELECT
    palk_kaart.*,
    ifnull(dokvaluuta1.kuurs, 1) :: NUMERIC AS kuurs
  INTO v_palk_kaart
  FROM palk_kaart
    LEFT OUTER JOIN dokvaluuta1 ON (palk_kaart.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 20)
  WHERE lepingid = tnLepingid AND libId = tnLibId;

  --qryPalkLib init
  SELECT
    pl.*,
    l.muud AS lisa,
    l.tun1,
    l.tun2,
    l.tun3,
    l.tun4,
    l.tun5
  INTO qryPalkLib
  FROM palk_lib pl
    LEFT OUTER JOIN library l ON l.kood = pl.tululiik AND library = 'MAKSUKOOD'
  WHERE pl.parentId = tnLibId;

  --v_leping init
  SELECT
    tooleping.*,
    ifnull(dokvaluuta1.kuurs, 1) :: NUMERIC AS kuurs,
    pc.minpalk
  INTO qryTooleping
  FROM tooleping
    LEFT OUTER JOIN dokvaluuta1 ON (tooleping.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 19)
    LEFT OUTER JOIN palk_config pc ON pc.rekvid = tooleping.rekvid
  WHERE tooleping.id = tnLepingId;

  IF qryTooleping.algab > l_aasta_alg
  THEN
    l_aasta_alg = qryTooleping.algab;
  END IF;

  --check for "umardamine"
  IF tnSumma IS NULL
  THEN
    IF v_palk_kaart.percent_ = 1
    THEN
      -- calc based on taabel
      --		raise notice 'calc based on taabel';
      IF v_palk_kaart.alimentid = 0
      THEN
        --raise notice 'alimentid = 0';

        SELECT *
        INTO qryTaabel1
        FROM palk_taabel1
        WHERE toolepingId = tnlepingId
              AND kuu = month(tdKpv) AND aasta = year(tdKpv);

        IF NOT found
        THEN
          --raise notice 'TAABEL1 NOT FOUND';
          RETURN lnSumma;
        END IF;

        SELECT tund
        INTO nHours
        FROM Toograf
        WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);
        IF ifnull(nHours, 0) = 0
        THEN
          nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31, v_palk_kaart.lepingId) :: NUMERIC(6, 4) *
                     qryTooleping.toopaev) :: INT4;
          ltSelgitus = ltSelgitus + 'Kokku tunnid kuues,:' + ltrim(rtrim(round(nHours, 2) :: VARCHAR)) + ltEnter;

          nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
          ltSelgitus = ltSelgitus + 'Kokku tunnid kuues, parandatud:' + ltrim(rtrim(round(nHours, 2) :: VARCHAR)) +
                       ltEnter;

        END IF;

        --raise notice 'hOUR %',nHours;
        IF qryTooleping.tasuliik = 1
        THEN
          lnRate := (qryTooleping.palk * qryTooleping.kuurs) / nHours * 0.01 * qryTooleping.koormus;
          --raise notice 'Rate %',lnrate;
          ltSelgitus = ltSelgitus + 'Tunni hind:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + ltEnter;

        END IF;

        IF qryTooleping.tasuliik = 2
        THEN
          lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs, qryPalkLib.round);
          lnRate := qryTooleping.palk * qryTooleping.kuurs;
          ltSelgitus = ltSelgitus + 'arvestus:' + ltrim(rtrim(qryTooleping.palk :: VARCHAR)) + '*' +
                       ltrim(rtrim(qryTooleping.kuurs :: VARCHAR)) + '*' +
                       ltrim(rtrim(round(qryTaabel1.kokku, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                       ltEnter;

          -- muudetud 01/02/2005
          IF qryPalkLib.tund = 5
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.tahtpaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;
          IF qryPalkLib.tund = 6
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.puhapaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;
          IF qryPalkLib.tund = 7
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.uleajatoo, 3) :: VARCHAR)) + '/' +
                         ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;

          END IF;
          IF qryPalkLib.tund = 3
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(qryTaabel1.ohtu :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;

          END IF;
          IF qryPalkLib.tund = 4
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.oo, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                         ltEnter;

          END IF;
          IF qryPalkLib.tund = 2
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.paev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                         ltEnter;

          END IF;

        ELSE

          IF qryPalkLib.tund = 5
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.tahtpaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

            lnBaas := qryTaabel1.tahtpaev;

          END IF;

          IF qryPalkLib.tund = 6
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs, qryPalkLib.round);
            lnBaas := qryTaabel1.puhapaev;
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.puhapaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;

          IF qryPalkLib.tund = 7
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs, qryPalkLib.round);

            lnBaas := qryTaabel1.uleajatoo;
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.uleajatoo, 3) :: VARCHAR)) + '/' +
                         ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;


          END IF;

          IF qryPalkLib.tund < 5
          THEN

            IF qryPalkLib.tund = 3
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.ohtu, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;


            END IF;

            IF qryPalkLib.tund = 4
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.oo, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;

            END IF;

            IF qryPalkLib.tund = 2
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(v_palk_kaart.Summa :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.paev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;

            END IF;

            IF qryPalkLib.tund = 1
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.kokku, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                           + ltEnter;

            END IF;
            lnSumma := lnSumma + f_round(nSumma / lnKuurs, qryPalkLib.round);
            lnBaas := lnBaas + CASE WHEN qryPalkLib.tund = 3
              THEN qryTaabel1.ohtu
                               ELSE
                                 CASE WHEN qryPalkLib.tund = 4
                                   THEN qryTaabel1.oo
                                 ELSE qryTaabel1.paev END END;

          END IF;
        END IF;
      END IF;
    ELSE

      lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
      ltSelgitus =
      ltSelgitus + ltrim(rtrim(v_palk_kaart.Summa :: VARCHAR)) + '*' + ltrim(rtrim(v_palk_kaart.kuurs :: VARCHAR)) + '/'
      + ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;
      lnBaas := 0;
    END IF;
  ELSE
    ltSelgitus = ltSelgitus + ' Käsi arvestus või ümardamine ' + ltEnter;
    lnSumma = tnSumma;
  END IF;

  -- salvestame arvetuse analuus
  DELETE FROM tmp_viivis
  WHERE alltrim(timestamp) = alltrim(lcTimestamp);
  INSERT INTO tmp_viivis (rekvid, dkpv, timestamp, muud) VALUES (qryTooleping.rekvid, tdKpv, lcTimestamp, ltSelgitus);

  -- TSD 2015
  IF qryPalkLib.tululiik IS NOT NULL
  THEN
    --Tootuskind-lustusmakse-> tun4, Kogumispension -> tun5
    --selecting tax numbers
    SELECT
      sum(sm)  AS sm,
      sum(tki) AS tki,
      sum(tka) AS tka,
      sum(pm)  AS pm
    INTO v_kaart
    FROM (
           SELECT
             CASE WHEN pl.liik = 5
               THEN status
             ELSE 0 END AS sm,
             CASE WHEN pl.liik = 7 AND asutusest = 0
               THEN status
             ELSE 0 END AS tki,
             CASE WHEN pl.liik = 7 AND asutusest = 1
               THEN status
             ELSE 0 END AS tka,
             CASE WHEN pl.liik = 8
               THEN status
             ELSE 0 END AS pm
           FROM palk_kaart pk
             INNER JOIN palk_lib pl ON pl.parentid = pk.libid
           WHERE pk.lepingid = qryTooleping.id
         ) qry;

    --calculating all taxis
    FOR v_maksud IN
    SELECT
      pk.summa,
      pk.tulumaks,
      pl.liik,
      pl.asutusest,
      pk.minsots
    FROM palk_kaart pk
      INNER JOIN palk_lib pl ON pl.parentId = pk.libid
    WHERE pk.status = 1
          AND pk.lepingId = qryTooleping.id
          AND pl.liik IN (5, 7, 8)
    LOOP
      IF v_maksud.liik = 5
      THEN
        -- SM
        l_SM_maar = v_maksud.summa;
        l_min_sots = coalesce(v_maksud.minsots, 0);
      ELSIF v_maksud.liik = 7 AND v_maksud.asutusest = 0
        THEN
          -- TKI
          l_TKI_maar = v_maksud.summa;
      ELSIF v_maksud.liik = 7 AND v_maksud.asutusest = 1
        THEN
          -- TKA
          l_TKA_maar = v_maksud.summa;
      ELSIF v_maksud.liik = 8
        THEN
          -- PM
          l_PM_maar = v_maksud.summa;
      ELSE
      -- null
      END IF;
    END LOOP;
    l_TM_maar = qryPalkLib.tun1;

    -- kui period on eelmine aasta siis kasutame eelmise aasta maksumaarad
    IF tdPeriod IS NOT NULL AND year(tdPeriod) < year(tdKpv)
    THEN
      l_TKI_maar = 2;
      l_TKA_maar = 1;
      l_TM_maar = 21;
    END IF;

    lTKI = round(lnSumma * 0.01 * l_TKI_maar * qryPalkLib.tun4 * coalesce(CASE WHEN v_kaart.tki > 0
      THEN 1
                                                                          ELSE 0 END, 0), 2);

    ltSelgitus = ltSelgitus + 'TKI arvestus:' + round(lnSumma, 2) :: TEXT + '*' + (0.01 * l_TKI_maar) :: TEXT + '*' +
                 qryPalkLib.tun4 :: TEXT + ltEnter;

    lPM = round(lnSumma * 0.01 * l_PM_maar * qryPalkLib.tun5 * coalesce(CASE WHEN v_kaart.pm > 0
      THEN 1
                                                                        ELSE 0 END, 0), 2);
    ltSelgitus = ltSelgitus + 'PM arvestus:' + round(lnSumma, 2) :: TEXT + '*' + (0.01 * l_PM_maar) :: TEXT + '*' +
                 qryPalkLib.tun5 :: TEXT + ltEnter;
    /*
      if lnSumma < qryTooleping.minpalk * l_min_sots then
        ltSelgitus = ltSelgitus + 'SM kasutame min.palk ' + qryTooleping.minpalk::text + ltEnter;
      end if;
    */
    --	raise notice 'lnSumma %, l_SM_maar %, qryPalkLib.tun2 %, v_kaart.sm %', lnSumma, l_SM_maar, qryPalkLib.tun2, v_kaart.sm ;
    lSM = round(lnSumma * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(CASE WHEN v_kaart.sm > 0
      THEN 1
                                                                        ELSE 0 END, 0), 2);

    --lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

    ltSelgitus = ltSelgitus + 'SM arvestus: ' + (CASE WHEN lnSumma < qryTooleping.minpalk * l_min_sots
      THEN qryTooleping.minpalk
                                                 ELSE round(lnSumma, 2) END) :: TEXT +
                 '*' + (0.01 * l_SM_maar) :: TEXT + '*' + qryPalkLib.tun2 :: TEXT + ltEnter;


    lTKA = round(lnSumma * 0.01 * l_TKA_maar * qryPalkLib.tun4 * coalesce(CASE WHEN v_kaart.tka > 0
      THEN 1
                                                                          ELSE 0 END, 0), 2);
    --	lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

    ltSelgitus = ltSelgitus + 'TKA arvestus:' + round(lnSumma, 2) :: TEXT +
                 '*' + (0.01 * l_TKA_maar) :: TEXT + '*' + qryPalkLib.tun4 :: TEXT + ltEnter;


    IF year(tdKpv) < 2018
    THEN
      RAISE NOTICE '2017 arvestus';
      IF qryTooleping.pohikoht = 1
      THEN

        IF year(tdKpv) >= 2015
        THEN
          l_tulubaas_kokku = (SELECT month(tdKpv) - month(l_aasta_alg) + 1) *
                             (SELECT coalesce(tulubaas, 154)
                              FROM palk_config
                              WHERE rekvid = qryTooleping.rekvid
                              LIMIT 1);
        ELSE
          l_tulubaas_kokku = (144 * 11) + (SELECT coalesce(tulubaas, 154)
                                           FROM palk_config
                                           WHERE rekvid = qryTooleping.rekvid
                                           LIMIT 1);
        END IF;

        -- kasutatud tulubaas
        -- should be only for tululiik we calculate (if umardamine)
        SELECT sum(tulubaas) AS tulubaas
        INTO l_kasutatud_tulubaas
        FROM palk_oper po
          INNER JOIN tooleping t ON po.lepingid = t.id
        WHERE tulubaas IS NOT NULL
              AND tulubaas > 0
              AND kpv >= date(year(tdKpv), month(l_aasta_alg), 01) AND kpv <= tdKpv
              AND po.id NOT IN (SELECT id
                                FROM palk_oper
                                WHERE libId = tnLibId AND lepingId = tnLepingId AND kpv = tdKpv)
              AND po.libId IN (SELECT l.Id
                               FROM library l INNER JOIN palk_lib pl ON l.id = pl.parentId
                               WHERE rekvId = qryTooleping.rekvId AND pl.liik = 1)
              AND t.parentid = qryTooleping.parentid;

        IF year(tdKpv) < 2015
        THEN
          SELECT sum(g31)
          INTO l_tulubaas
          FROM palk_jaak
          WHERE lepingid IN (SELECT id
                             FROM tooleping
                             WHERE rekvid = qryTooleping.rekvid AND parentId = qryTooleping.parentId)
                AND kuu >= 1 AND kuu < month(tdKpv) AND aasta = year(tdKpv);

          l_kasutatud_tulubaas = coalesce(l_kasutatud_tulubaas, 0) + coalesce(l_tulubaas, 0);
        END IF;

        --			raise notice 'l_tulubaas_kokku %, l_kasutatud_tulubaas %, l_aasta_alg %', l_tulubaas_kokku, l_kasutatud_tulubaas, l_aasta_alg;

        -- periodi kogus
        --			raise notice 'tulubaasi kasutamine lnSumma %, tnSumma %', lnSumma, tnSumma;
        IF tnSumma IS NULL OR lnSumma != tnSumma
        THEN
          l_tulubaas = coalesce(l_tulubaas_kokku, 0) - coalesce(l_kasutatud_tulubaas, 0);
        ELSE
          SELECT sum(tulubaas)
          INTO l_tulubaas
          FROM palk_oper po
          WHERE po.lepingid IN (SELECT id
                                FROM tooleping
                                WHERE parentId = qryTooleping.parentid AND rekvId = qryTooleping.rekvId)
                AND kpv = tdKpv
                AND libId IN
                    (
                      SELECT l.id
                      FROM library l
                        INNER JOIN palk_lib pl ON l.id = pl.parentId
                      WHERE l.rekvId = qryTooleping.rekvId
                            AND pl.tululiik = qryPalkLib.tululiik
                            AND pl.liik = qryPalkLib.liik
                    );

          l_tulubaas = coalesce(l_tulubaas, 0);
          ltSelgitus = ltSelgitus + ' kasutame enne arvestatud kasutatud tulubaas ' + ltEnter;
        END IF;
      END IF;
    ELSE
      --	raise notice 'Tulubaas 2018 arvestus';
      -- TM 2018 arvestus
      l_tulubaas_kokku = coalesce((SELECT sum(summa)
                                   FROM taotlus_mvt mvt
                                     INNER JOIN tooleping t ON t.id = mvt.lepingId
                                   WHERE t.parentId = qryTooleping.parentId
                                         AND alg_kpv <= tdKpv
                                         AND lopp_kpv >= tdKpv), 0);
      -- 1.  arvestus
      -- arvestame kasutatud MVT

      l_kasutatud_tulubaas = (SELECT sum(po.tulubaas)
                              FROM palk_oper po
                                INNER JOIN tooleping t ON t.id = po.lepingId
                                INNER JOIN palk_lib pl ON pl.parentId = po.libId
                              WHERE t.parentid = qryTooleping.parentId
                                    AND po.period IS NULL
                                    AND pl.liik = 1
                                    AND (tnSumma IS NULL OR pl.tululiik = qryPalkLib.tululiik)
                                    -- calculate only 1 tululiik
                                    AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
                                    AND (tnSumma IS NOT NULL OR po.id NOT IN (SELECT id
                                                                              FROM palk_oper
                                                                              WHERE
                                                                                kpv = tdKpv
                                                                                AND lepingid = tnLepingid
                                                                                AND libid = tnLibId))
      );

      RAISE NOTICE 'l_kasutatud_tulubaas -> %', l_kasutatud_tulubaas;

      -- arvestame kuu tulud

      IF coalesce(tnSumma, 0) = 0
      THEN
        SELECT sum(po.summa)
        INTO lnKuuSumma
        FROM palk_oper po
          INNER JOIN tooleping t ON t.id = po.lepingId
          INNER JOIN palk_lib pl ON pl.parentId = po.libId
        WHERE t.parentid = qryTooleping.parentId
              AND pl.liik = 1
              AND po.period IS NULL -- ainult arvestuse period
              AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
              --            AND po.rekvId = qryTooleping.rekvId --Arvestame koik tulud seles kuu
              AND (tnSumma IS NOT NULL OR po.id NOT IN (SELECT id
                                                        FROM palk_oper
                                                        WHERE kpv = tdKpv AND lepingid = tnLepingid AND
                                                              libid =
                                                              tnLibId)); -- kui parandus siis v]ttame koik summad

        lnKuuSumma = coalesce(lnKuuSumma, 0) + (lnSumma - coalesce(tnSumma, 0));
      ELSE
        lnKuuSumma = tnSumma; --if umardamine then do not neccessory calculate kuu summa
      END IF;
      -- 2 kasutatud mvt


      l_tulubaas = calc_mvt(lnKuuSumma, l_tulubaas_kokku, tdkpv);

      RAISE NOTICE 'Tulubaas arvestus l_tulubaas ->>> %, lnKuuSumma %, l_tulubaas_kokku % ', l_tulubaas, lnKuuSumma, l_tulubaas_kokku;

      -- 3. parandus

      IF coalesce(tnUmardamine, 0) = 0
      THEN
        -- ei ole umardamine
        l_tulubaas = coalesce(l_tulubaas, 0) - coalesce(l_kasutatud_tulubaas, 0);
      END IF;

      IF l_tulubaas > lnSumma
      THEN
        l_tulubaas = lnSumma - lTKI - lPM;
      END IF;

      IF coalesce(tnUmardamine, 0) = 0 AND (l_kasutatud_tulubaas + l_tulubaas) > lnKuuSumma
      THEN
        -- liga palju
        l_tulubaas = (l_kasutatud_tulubaas + l_tulubaas) - lnKuuSumma;
      END IF;

    END IF;

    IF l_tulubaas < 0 AND (qryPalkLib.lisa IS NULL AND year(tdKpv) < 2018)
    THEN
      l_tulubaas = 0;
    END IF;

    IF lnSumma > 0
    THEN
      lTM = (lnSumma - lTKI - lPM);
    ELSE
      lTM = lnSumma;
    END IF;

    IF lTM > l_Tulubaas AND lTM > 0
    THEN
      lTM = lTM - l_tulubaas;
    ELSE
      l_tulubaas = CASE WHEN lTM > 0
        THEN lTM
                   ELSE 0 END;
      lTM = 0; -- parandus 28.10.2015 sest votab arvestus 1 euriost
    END IF;
    lTM = round(lTM * 0.01 * l_TM_maar, 2);

    ltSelgitus = ltSelgitus + 'TM arvestus:(' + round(lnSumma, 2) :: TEXT +
                 '-' + (CASE WHEN lTKI > 0
      THEN lTKI
                        ELSE 0 END) :: TEXT +
                 '-' + (CASE WHEN lPM > 0
      THEN lPM
                        ELSE 0 END) :: TEXT +
                 '-' + l_tulubaas :: TEXT + ') * ' + (0.01 * l_TM_maar) :: TEXT + ltEnter;

    -- tulumaks (tmp_viivis.volg1)
    --	if qryPalkLib.tun1 > 0 then
    UPDATE tmp_viivis
    SET volg1 = lTM,
      paev1   = CASE WHEN qryPalkLib.tululiik = ''
        THEN '0'
                ELSE qryPalkLib.tululiik END :: INTEGER,
      tasun1  = coalesce(l_Tulubaas, 0),
      volg2   = lSM,
      volg4   = lTKI,
      volg5   = lPM,
      volg6   = lTKA,
      muud    = ltSelgitus
    WHERE alltrim(timestamp) = alltrim(lcTimestamp);
    --	end if;
  END IF;

  RETURN lnSumma;

END;

$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER) TO dbpeakasutaja;
COMMENT ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE,
                                INTEGER) IS 'Muudetud 01/02/2005 lisatud ohtu-uletoo tunni alusel tootajad';


								
DROP FUNCTION if exists sp_calc_palgajaak(integer, date, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_palgajaak(tnRekvId integer, tdKpv1 date, tdKpv2 date, tnIsik1 integer, tnIsik2 integer)
  RETURNS smallint AS
$BODY$
declare 
tnid	int4;

ldKpv2 	date;
lnKuu	int4 = month(tdkpv1);
lnAasta int4 = year (tdKpv1) ;
ldKpv1	date = date(lnAasta, lnKuu, 1);
v_tooleping	record;

BEGIN
for v_tooleping in select   tooleping.id from asutus inner join tooleping on tooleping.parentId = asutus.id
	where asutus.id >= tnIsik1
	and  asutus.id <= tnIsik2
	and tooleping.rekvid = tnrekvid
 

loop
-- muudetud 03/01/2004
	while tdkpv2 >= ldKpv1
		loop
			ldKpv1 := date(lnAasta, lnKuu, 1);

			ldkpv2 := ldKpv1 + INTERVAL ' 1 month ' - INTERVAL '1 DAY ';
	--		raise notice 'ldKpv2 %',ldKpv2;
			perform sp_update_palk_jaak (ldKpv1,ldKpv2, tnRekvId, v_tooleping.id); 					
			lnKuu := lnkuu+1;

			if lnkuu > 12 THEN
				lnkuu := 1; 
				lnaasta := lnaasta + 1;	

			end if;	
		end loop;	
end loop; 
return 1;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO dbpeakasutaja;


DROP FUNCTION IF EXISTS sp_calc_umardamine( INTEGER, DATE, INTEGER );

CREATE OR REPLACE FUNCTION sp_calc_umardamine(tnisikid INTEGER, tdkpv DATE, tnrekvid INTEGER)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_tululiik       RECORD;
  lnSumma          NUMERIC(14, 4);
  v_leping         RECORD;
  lcTimestamp      VARCHAR(20);
  v_arv            RECORD;
  v_fakt_arv       RECORD;
  ldKpv            DATE = gomonth(DATE(year(tdKpv), month(tdKpv), 1), 1) - 1;
  l_tulubaas       NUMERIC(14, 4); --mvt
  l_tulubaas_kokku NUMERIC(14, 4);

  l_mvt_kokku      NUMERIC(14, 4) = 0;
  l_pm_kokku       NUMERIC(14, 4) = 0;
  l_tk_kokku       NUMERIC(14, 4) = 0;
  l_tm_kokku       NUMERIC(14, 4) = 0;
  l_tulu_kokku     NUMERIC(14, 4) = 0;
  l_mvt_diff       NUMERIC(14, 4) = 0;
  l_id             INTEGER;

BEGIN
  --assign default value to v_leping
  v_leping = ROW (NULL);

  -- kustutame eelamise arvestus
/*
  DELETE FROM palk_oper po
  WHERE po.lepingId IN (
    SELECT id
    FROM tooleping
    WHERE parentId = tnIsikId
  )
        AND po.kpv = tdKpv
        AND po.rekvId = tnRekvId
        AND po.summa = 0;
*/

  -- arvestame, loop for each tululiik
  FOR v_tululiik IN
  SELECT
    pl.tululiik,
    sum(po.summa)     AS summa,
    count(po.id)      AS arv_count,
    sum(po.tulubaas)  AS mvt,
    sum(po.tootumaks) AS tki,
    sum(po.pensmaks)  AS pm,
    sum(tulumaks)     AS tm
  FROM palk_oper po
    INNER JOIN library l ON l.id = po.libid
    INNER JOIN palk_lib pl ON pl.parentid = l.id
  WHERE po.lepingId IN (
    SELECT id
    FROM tooleping
    WHERE parentId = tnIsikId
  )
        AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
        --and po.kpv = tdKpv
        AND po.rekvId = tnRekvId
        AND pl.liik = 1
  GROUP BY pl.tululiik, pl.liik
  ORDER BY pl.liik
  LOOP

    IF v_tululiik.arv_count > 1
    THEN
      SELECT
        po.*,
        pl.tululiik
      INTO v_leping
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
        INNER JOIN tooleping t ON t.id = po.lepingId
      WHERE t.parentId = tnIsikId
            AND po.kpv = tdKpv
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_tululiik.tululiik
      ORDER BY t.pohikoht DESC, po.summa DESC
      LIMIT 1;


      IF lcTimestamp IS NULL
      THEN
        lcTimestamp = left('ARV' + LTRIM(RTRIM(str(v_leping.LepingId))) + LTRIM(RTRIM(str(v_leping.LibId))) +
                           ltrim(rtrim(str(dateasint(tdKpv)))), 20);
      END IF;

      IF v_leping.lepingId IS NULL
      THEN
        RETURN 0;
      END IF;

      --calculate full summa for this tululiik
      raise notice 'start arv for summa-> %, lcTimestamp -> %',v_tululiik.summa, lcTimestamp;
      lnSumma = sp_calc_arv(v_leping.lepingId, v_leping.libId, v_leping.kpv, v_tululiik.summa, NULL, 1);

      SELECT
        round(tasun1, 2)    AS tulubaas,
        round(volg1, 2)     AS tm,
        round(volg2, 2)     AS sm,
        round(volg4, 2)     AS tki,
        round(volg5, 2)     AS pm,
        round(volg6, 2)     AS tka,
        muud,
        0 :: NUMERIC(14, 4) AS mvt
      INTO v_arv
      FROM tmp_viivis
      WHERE alltrim(timestamp) = alltrim(lcTimestamp);

      raise notice 'got arvestus -> %',v_arv;

-- get fact summa done before
      SELECT
        sum(summa)     AS arv,
        sum(tulumaks)  AS tm,
        sum(sotsmaks)  AS sm,
        sum(tootumaks) AS tki,
        sum(pensmaks)  AS pm,
        sum(tka)       AS tka,
        sum(tulubaas)  AS mvt
      INTO v_fakt_arv
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
      WHERE po.lepingId IN (
        SELECT id
        FROM tooleping
        WHERE parentId = tnIsikId
      )
            --	and po.kpv = tdKpv
            AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_tululiik.tululiik;

      -- kontrollime MVT
      l_tulubaas_kokku = coalesce((SELECT sum(mvt.summa)
                                   FROM taotlus_mvt mvt
                                     INNER JOIN tooleping t ON t.id = mvt.lepingId
                                   WHERE t.parentId = tnIsikId AND alg_kpv <= tdKpv AND lopp_kpv >= tdKpv), 0);

      -- calculate basis MVT full fact summa according to MVT
      l_tulubaas = calc_mvt(v_fakt_arv.arv, l_tulubaas_kokku, tdKpv);

      -- calc MVT to round it or update it
      IF v_fakt_arv.mvt - (v_arv.tm - round(v_fakt_arv.tm, 2) - (v_arv.pm - round(v_fakt_arv.pm, 2)) - v_arv.tki -
                           round(v_fakt_arv.tki, 2)) > l_tulubaas
      THEN
        v_arv.mvt = l_tulubaas - v_fakt_arv.mvt;
      END IF;

      -- check if we need to round taxes
      IF v_arv.tm - round(v_fakt_arv.tm, 2) <> 0 OR
         v_arv.sm - round(v_fakt_arv.sm, 2) <> 0 OR
         v_arv.tki - round(v_fakt_arv.tki, 2) <> 0 OR
         v_arv.tka - round(v_fakt_arv.tka, 2) <> 0 OR
         v_arv.pm - round(v_fakt_arv.pm, 2) <> 0
      THEN
        --saving diff
        raise notice 'v_arv.mvt  %',v_arv.mvt;

        l_id = sp_salvesta_palk_oper(0, tnRekvId, v_leping.libId, v_leping.lepingId, tdKpv, 0, v_leping.Doklausid,
                                     'Ümardamine' + v_arv.muud,
                                     ifnull(v_leping.kood1, space(1)), ifnull(v_leping.kood2, 'LE-P'),
                                     ifnull(v_leping.kood3, space(1)),
                                     ifnull(v_leping.kood4, space(1)), ifnull(v_leping.kood5, space(1)),
                                     ifnull(v_leping.konto, space(1)),
                                     v_leping.tp, v_leping.tunnus, 'EUR', 1, v_leping.proj,
                                     v_tululiik.tululiik :: INTEGER, ifnull(v_arv.tm - round(v_fakt_arv.tm, 2), 0),
                                     ifnull(v_arv.sm - round(v_fakt_arv.sm, 2), 0),
                                     ifnull(v_arv.tki - round(v_fakt_arv.tki, 2), 0),
                                     ifnull(v_arv.pm - round(v_fakt_arv.pm, 2), 0),
                                     v_arv.mvt, coalesce(v_arv.tka - round(v_fakt_arv.tka, 2), 0), NULL :: DATE);

        -- if mvt was not used in full permited
        IF v_fakt_arv.mvt < 500
        THEN
          -- select used MVT in period for isik in all departments
          SELECT
            sum(summa)     AS arv,
            sum(tulumaks)  AS tm,
            sum(tootumaks) AS tki,
            sum(pensmaks)  AS pm,
            sum(tulubaas)  AS mvt
          INTO l_tulu_kokku, l_tm_kokku, l_tk_kokku, l_pm_kokku, l_mvt_kokku
          FROM palk_oper po
            INNER JOIN library l ON l.id = po.libid
            INNER JOIN palk_lib pl ON pl.parentid = l.id
          WHERE po.lepingId IN (
            SELECT id
            FROM tooleping
            WHERE parentId = tnIsikId
          )
                AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
                AND po.rekvId = tnRekvId
                AND pl.liik = 1;

          -- get mvt diff from palk_oper
          l_mvt_diff = coalesce(l_mvt_kokku, 0) - (coalesce(l_tulu_kokku, 0) -
                                                   (coalesce(l_tm_kokku, 0) + coalesce(l_tk_kokku, 0) +
                                                    coalesce(l_pm_kokku, 0)));

          -- if diff is bigger than 0< then saving mvt diff
          IF l_mvt_diff > 0
          THEN
            UPDATE palk_oper
            SET Tulubaas = Tulubaas - l_mvt_diff
            WHERE id = l_id;
          END IF;
        END IF;
      END IF;

    END IF; -- arv count peaks rohkem kui 1

  END LOOP;

  RETURN 0;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION sp_calc_umardamine( INTEGER, DATE, INTEGER ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_umardamine( INTEGER, DATE, INTEGER ) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_check_twins(date, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tdKpv alias for $1;
	tnLibId alias for $2;
	tnlepingId alias for $3;
	tnId alias for $4;
	v_palk_oper record;
	lnError int;


begin

	for v_palk_oper in 
		SELECT Palk_oper.id, palk_oper.libId, palk_lib.liik , palk_oper.sotsmaks
		FROM Palk_oper 
		inner join palk_lib on palk_oper.libId = palk_lib.Parentid
		WHERE Palk_oper.libId = tnLibId   
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.LepingId = tnLepingId
		and palk_lib.liik not in (6,9) 
		and palk_oper.id <> tnid 
	loop
		raise notice 'Kustutan v_palk_oper.id %', v_palk_oper.id;
		lnError := sp_del_palk_oper(v_palk_oper.id,1);
	end loop;


	return lnError;


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbpeakasutaja;

DROP FUNCTION if exists sp_del_taotlus_mvt(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_taotlus_mvt(tnId integer, force integer)
  RETURNS integer AS
$BODY$
declare
	v_taotlus record;
begin

	DELETE FROM taotlus_mvt WHERE Id = tnId;

	if found then

		return 1;

	else

		return 0;

	end if;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_del_taotlus_mvt(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_taotlus_mvt(integer, integer) TO dbpeakasutaja;

--DROP AGGREGATE IF EXISTS array_agg( ANYELEMENT );

CREATE AGGREGATE array_agg( ANYELEMENT ) (
SFUNC = array_append,
STYPE = ANYARRAY,
INITCOND = '{}'
);

CREATE OR REPLACE FUNCTION sp_paranda_mvt_miinus(tnIsikId INTEGER, tnRekvId INTEGER, tdKpv DATE)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  qrypalklib         RECORD;
  v_miinus_mvt       RECORD;
  v_leping           RECORD;
  v_palk_oper        RECORD;
  l_uus_tm           NUMERIC(14, 4);
  l_tm_miinus_kokku  NUMERIC(14, 4) = 0;
  l_mvt_miinus_kokku NUMERIC(14, 4) = 0;
  l_id               INTEGER;

BEGIN
  --v_leping init
  SELECT *
  INTO v_leping
  FROM tooleping t
  WHERE parentid = tnIsikId AND rekvid = tnRekvId AND (t.lopp IS NULL OR t.lopp <= tdKpv)
  ORDER BY pohikoht DESC
  LIMIT 1;

  --kustutame eelmine arvestus
  DELETE FROM palk_oper
  WHERE summa = 0 AND lepingid IN (SELECT id
                                   FROM tooleping
                                   WHERE parentId = tnIsikId)
        AND kpv = tdKpv
        AND rekvId = tnRekvId
        AND muud LIKE 'MVT miinus parandus%';

  -- SQL looking for MVT < 0
  FOR v_miinus_mvt IN
  SELECT
    sum(po.summa)          AS tulu,
    sum(po.tootumaks)      AS tki,
    sum(po.pensmaks)       AS pm,
    sum(po.tulubaas)       AS mvt,
    sum(po.tulumaks)       AS tm,
    array_agg(po.libid)    AS libs,
    array_agg(po.lepingid) AS lepings,
    pl.tululiik
  FROM palk_oper po
    INNER JOIN palk_lib pl ON pl.parentid = po.libid AND NOT empty(pl.tululiik)
  WHERE lepingId IN (SELECT id
                     FROM tooleping
                     WHERE parentid = tnIsikId AND rekvId = tnRekvId)
        AND month(kpv) = month(tdKpv)
        AND year(kpv) = year(tdKpv)
        AND po.tulubaas IS NOT NULL
  GROUP BY kpv, tululiik
  ORDER BY pl.tululiik DESC

  LOOP
    IF (v_miinus_mvt.mvt) < 0
    THEN
      -- found mvt < 0, shoul create po with miinus

      -- find po with miinus MVT
      SELECT po.*
      INTO v_palk_oper
      FROM palk_oper po
      WHERE lepingid = v_miinus_mvt.lepings [1]
            AND libid = v_miinus_mvt.libs [1]
            AND month(kpv) = month(tdKpv)
            AND year(kpv) = year(tdKpv)
            AND tulubaas < 0
      ORDER BY kpv DESC
      LIMIT 1;

      -- calculate new TM
      -- arvestame tm diff
      l_uus_tm = ((v_miinus_mvt.tulu - v_miinus_mvt.tki - v_miinus_mvt.pm) * 0.20) - v_miinus_mvt.tm;

      --save new PO with miinus
      l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libs [1], v_miinus_mvt.lepings [1], tdKpv, 0,
                                   0,
                                   'MVT miinus parandus, tululiik ' + v_miinus_mvt.tululiik,
                                   space(1), 'LE-P', space(1), space(1), space(1), space(1), space(1), space(1), 'EUR',
                                   1, space(1),
                                   v_miinus_mvt.tululiik :: INTEGER, l_uus_tm, 0, 0, 0,
                                   -1 * v_miinus_mvt.mvt, 0, NULL :: DATE);

      --store summa into vars
      l_mvt_miinus_kokku = l_mvt_miinus_kokku + v_miinus_mvt.mvt;
      l_tm_miinus_kokku = l_tm_miinus_kokku + l_uus_tm;

    END IF;

  END LOOP;

  IF (l_mvt_miinus_kokku <> 0)
  THEN
    -- find max + tululiik summa
    SELECT po.*
    INTO v_palk_oper
    FROM palk_oper po
      INNER JOIN palk_lib pl ON pl.parentid = po.libid AND NOT empty(pl.tululiik)
    WHERE lepingId IN (SELECT id
                       FROM tooleping
                       WHERE parentid = tnIsikId AND rekvId = tnRekvId)
          AND month(kpv) = month(tdKpv)
          AND year(kpv) = year(tdKpv)
          AND po.tulubaas > 0
    ORDER BY po.tulubaas DESC;

    --save new PO with max tululiik
    l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libs [1], v_miinus_mvt.lepings [1], tdKpv, 0,
                                 0,
                                 'MVT miinus parandus, tululiik ' + v_miinus_mvt.tululiik,
                                 space(1), 'LE-P', space(1), space(1), space(1), space(1), space(1), space(1), 'EUR',
                                 1, space(1),
                                 v_miinus_mvt.tululiik :: INTEGER, -1 * l_tm_miinus_kokku, 0, 0, 0,
                                 l_mvt_miinus_kokku, 0, NULL :: DATE);


  END IF;

  RETURN 0;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbpeakasutaja;


DROP FUNCTION if exists sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(tnid integer, tnrekvid integer, tnlibid integer, tnlepingid integer, tdkpv date, tnsumma numeric, tndoklausid integer, ttmuud text, 
	tckood1 character varying, tckood2 character varying, tckood3 character varying, tckood4 character varying, tckood5 character varying, tckonto character varying, 
	tctp character varying, tctunnus character varying, tcValuuta character varying, tnKuurs numeric, tcProj character varying, tnTululiik integer, tnTulumaks numeric, 
	tnSotsmaks numeric, tnTootumaks numeric, tnPensmaks numeric, tnTulubaas numeric, tnTKA numeric, tdPeriod date)
  RETURNS integer AS
$BODY$

declare
	lnpalk_operId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;

	ldKpv1 date = DATE(YEAR(tdKpv),month(tdKpv),1);
	ldKpv2 date = gomonth(ldKpv1,1)  - 1; 
begin


raise notice 'start';

	if tnId = 0 then
		-- uus kiri
		insert into palk_oper (rekvid,libid,lepingid,kpv,summa,doklausid,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj, journal1id,
			tulumaks, sotsmaks, tootumaks, pensmaks, tulubaas, tka, period) 
			values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,
				ifnull(tcProj,space(1)), tnTuluLiik, 
				ifnull(tnTulumaks,0), ifnull(tnSotsmaks,0), ifnull(tnTootumaks,0), ifnull(tnPensmaks,0), ifnull(tnTulubaas,0), coalesce(tnTKA,0),tdPeriod) 
				returning id into lnpalk_operId;


		if lnpalk_operId = 0 then
			raise exception 'Ei saa lisada kiri %', lnId ;
		end if;
		-- valuuta
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (lnpalk_operId,12,tcValuuta, tnKuurs);
	else
		-- muuda 
	--	select * into lrCurRec from palk_oper where id = tnId;
		/*
		if  lrCurRec.libid <> tnlibid or lrCurRec.lepingid <> tnlepingid or lrCurRec.kpv <> tdkpv or lrCurRec.summa <> tnsumma or 
			lrCurRec.doklausid <> tndoklausid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or 
			lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or 
			lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or ifnull(lrCurRec.proj,'tuhi') <> tcProj then 
	*/
		update palk_oper set 
			libid = tnlibid,
			lepingid = tnlepingid,
			kpv = tdkpv,
			summa = tnsumma,
			doklausid = tndoklausid,
			muud = ttmuud,
			kood1 = tckood1,
			kood2 = tckood2,
			kood3 = tckood3,
			kood4 = tckood4,
			kood5 = tckood5,
			konto = tckonto,
			tp = tctp,
			proj = ifnull(tcProj,space(1)),
			journal1id = tnTululiik,
			tunnus = tctunnus,
			tulumaks = ifnull(tnTulumaks,0),
			Sotsmaks = ifnull(tnSotsmaks,0), 
			Tootumaks = ifnull(tnTootumaks,0), 
			Pensmaks = ifnull(tnPensmaks,0), 
			Tulubaas = ifnull(tnTulubaas,0),
			tka = coalesce(tnTKA,0),
			period = tdPeriod
		where id = tnId
		returning id into lnpalk_operId;
	--	end if;

		raise notice 'updated';
		-- valuuta
		if (select count(id) from dokvaluuta1 where dokliik = 12 and dokid =lnpalk_operId ) = 0 then

			insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
				values (12, lnpalk_operId ,tcValuuta, tnKuurs);
		else
			select * into v_dokvaluuta from dokvaluuta1 where dokliik = 12 and dokid = lnpalk_operId  ;
			if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then
				update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;						
			end if;
		end if;
	end if;
	
	-- perform sp_update_palk_jaak(ldKpv1::date,ldKpv2::date, lnRekvId::integer, tnlepingId::integer);
	
--	perform recalc_palk_saldo(tnlepingid::integer ,month(tdkpv)::int2);	
	perform gen_lausend_palk(lnpalk_operId);


	
        return  lnpalk_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date) TO dbpeakasutaja;

DROP FUNCTION if exists sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text);

CREATE OR REPLACE FUNCTION sp_salvesta_taotlus_mvt(tn_id integer, tn_rekvid integer, tn_userid integer, td_kpv date, td_alg_kpv date, td_lopp_kpv date, tn_lepingid integer, tn_summa numeric(14,4),  tt_muud text)
  RETURNS integer AS
$BODY$

declare
	lnId int = 0; 
begin

if tn_id = 0 then
	-- uus kiri
	insert into taotlus_mvt (rekvid, userid, kpv, alg_kpv, lopp_kpv, lepingid, summa, muud) 
		values (tn_rekvid, tn_userid, td_kpv, td_alg_kpv, td_lopp_kpv, tn_lepingid, tn_summa, tt_muud)
		returning id into lnId;

else
	-- muuda 
	update taotlus_mvt set 
		kpv = td_kpv,
		alg_kpv = td_alg_kpv , 
		lopp_kpv = td_lopp_kpv, 
		lepingid = tn_lepingid, 
		summa = tn_summa, 
		muud = tt_muud
	where id = tn_id
	returning id into lnId;
	
end if;

         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_update_palk_jaak(tdKpv1 date, tdKpv2 date, tnRekvId integer, tnlepingId integer)
  RETURNS integer AS
$BODY$
declare

	v_palk_jaak palk_jaak%rowtype;
	v_tooleping record ;
	v_palk_config record;
	lnKuu1 integer = month(tdKpv1);
	lnKuu2	integer = month(tdKpv2);
	lnAasta1 integer = year(tdKpv1);
	lnAasta2 integer = year(tdKpv2);	
	lnElatis numeric (12,4);
	lnTulubaas numeric(12,4);
	lnTookoht integer = 1;
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
	l_tulubaas_2015 numeric(14,2);
	lnTuludPm numeric (12,4);

	l_jaak numeric (12,4) = 0;
	l_eelmine_jaak numeric (12,4) = 0;
	l_eelmine_kuu integer = case when (lnKuu1 - 1) < 1 then 12 else lnKuu1 - 1 end;
	l_eelmine_aasta integer = case when l_eelmine_kuu = 12 then lnAasta1 - 1 else lnAasta1 end;
	
begin
	select * into v_tooleping from tooleping where id = tnLepingId;
	
	lnTookoht = v_tooleping.pohikoht;

	select palk_config.*, ifnull(dokvaluuta1.kuurs,1) as kuurs  into v_palk_config
		from palk_config 
		left outer join dokvaluuta1 on (palk_config.id =dokvaluuta1.dokid and  dokvaluuta1.dokliik = 26) where palk_config.rekvid = tnrekvId;

	lnTulubaas = coalesce(v_palk_config.Tulubaas * v_palk_config.kuurs,180);	

	if lnTookoht = 0 then
		lnTulubaas := 0;
	end if;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric),  
		sum( coalesce(Palk_oper.tulubaas,0) * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.arvestatud , v_palk_jaak.g31
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 1    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.arvestatud  = coalesce(v_palk_jaak.arvestatud ,0);
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

	lnTuludPm = coalesce(lnTuludPm,0);	
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

	v_palk_jaak.kinni = coalesce(v_palk_jaak.kinni,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tki
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 0
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tki = coalesce (v_palk_jaak.tki,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tka
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 1
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tka = coalesce(v_palk_jaak.tka,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.pm
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE  palk_lib.liik = 8
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.pm = coalesce(v_palk_jaak.pm,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.tulumaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 4    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tulumaks = coalesce(v_palk_jaak.Tulumaks,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.sotsmaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 5
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.Sotsmaks = coalesce(v_palk_jaak.Sotsmaks,0);

	delete from palk_jaak 
		where  lepingId = tnlepingId 
		and kuu = lnkuu1
		and aasta = lnaasta1;

	select sum(palk_oper.summa * coalesce(dokvaluuta1.kuurs,1)::numeric) into lnElatis 
			from palk_oper 
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where libId in 
			(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.elatis = 1 AND p.liik = 2) 
			AND Palk_oper.kpv >= tdKpv1   
			AND Palk_oper.kpv <= tdKpv2
			AND Palk_oper.rekvId = tnRekvId
			AND palk_oper.lepingId	= tnLepingId;

        select sum(o.summa * coalesce(dokvaluuta1.kuurs,1)::numeric) into lnArv 
		from palk_oper o inner join palk_kaart  k on o.lepingid = k.lepingid and k.libId = o.libId
		left outer join dokvaluuta1 on (o.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where o.libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.liik = 1) 
		and k.tulumaks = 1
		AND o.kpv >= tdKpv1   
		AND o.kpv <= tdKpv2
		AND o.rekvId = tnRekvId
		AND o.lepingId	= tnLepingId;



	raise notice 'v_palk_jaak.g31 %', v_palk_jaak.g31;
		
	-- calc saldo
	-- 1. prev. saldo

	select jaak into l_eelmine_jaak from palk_jaak where lepingId = tnlepingId and kuu = l_eelmine_kuu and aasta = l_eelmine_aasta;
	l_jaak  = coalesce(l_eelmine_jaak,0) + coalesce(v_palk_jaak.arvestatud,0) - coalesce(v_palk_jaak.kinni,0) - coalesce(v_palk_jaak.tulumaks,0); 

	insert into palk_jaak ( lepingId, kuu, aasta, arvestatud, kinni, tulumaks, sotsmaks, tka, tki, pm, g31, jaak)
		values (tnlepingId, lnkuu1, lnaasta1, v_palk_jaak.arvestatud, v_palk_jaak.kinni, 
		v_palk_jaak.tulumaks, v_palk_jaak.sotsmaks, v_palk_jaak.tka, v_palk_jaak.tki, v_palk_jaak.pm, coalesce(v_palk_jaak.g31,0), l_jaak) ;

 return 1;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbpeakasutaja;


update palk_config set tulubaas = 500 where rekvid < 999;


  