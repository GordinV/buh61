-- Function: sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)
/*
select sp_salvesta_journal1(0::int,1382::int,1.00::numeric,'v_journal1.dokument'::varchar,''::text,''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,'111'::varchar,''::varchar,'113'::varchar,''::varchar,'EEK'::varchar,1.00::numeric,0.00::numeric,''::varchar,''::varchar)
*/


-- DROP FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying,
                                                character varying, character varying, character varying,
                                                character varying, character varying, character varying,
                                                character varying, character varying, character varying, numeric,
                                                numeric, character varying, character varying)
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
    lnjournal1Id  int;
    lnId          int;
    lrCurRec      record;
    tmpJournal    record;
    lnKontrol     int;
    lnrekvid      int;
    lcViga        varchar;
    lcOmaTp       varchar;
    ldKpv         date;
    v_dokvaluuta  record;
    l_arve_number varchar(20);
    l_arve_id     integer;
begin

    select rekvid, kpv into lnrekvId, ldKpv from journal where id = tnparentid;
    select recalc into lnKontrol from rekv where id = lnrekvid;

    lcOmaTp = ltrim(rtrim(fnc_getomatp(lnrekvId, year(ldKpv))));

    if ifnull(lnKontrol, 0) = 1 then
        lcViga =
                sp_lausendikontrol(tcdeebet, tcKreedit, tclisa_d, tclisa_k, tckood1, tcKood2, tckood5, tckood3, lcOmaTP,
                                   ldKpv, tcvaluuta);
        if left(ltrim(rtrim(lcViga)), 4) = 'Viga' then
            raise exception ':%',lcViga;
            return 0;
        end if;
    end if;


    if tnId = 0 then
        -- uus kiri
        insert into
            journal1 (parentid, summa, dokument, muud, kood1, kood2, kood3, kood4, kood5, deebet, lisa_d, kreedit,
                      lisa_k, valuuta, kuurs, valsumma, tunnus, proj)
        values
            (tnparentid, tnsumma, tcdokument, ttmuud, tckood1, tckood2, tckood3, tckood4, tckood5, tcdeebet, tclisa_d,
             tckreedit, tclisa_k, tcvaluuta, tnkuurs, tnvalsumma, tctunnus, tcProj)
        returning id into lnjournal1Id;

        -- valuuta

        insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs)
        values (1, lnjournal1Id, tcValuuta, tnKuurs);

    else
        -- muuda
        select * into lrCurRec from journal1 where id = tnId;
        if lrCurRec.parentid <> tnparentid or lrCurRec.summa <> tnsumma or
           ifnull(lrCurRec.dokument, space(1)) <> ifnull(tcdokument, space(1)) or
           ifnull(lrCurRec.muud, space(1)) <> ifnull(ttmuud, space(1)) or lrCurRec.kood1 <> tckood1 or
           lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or
           lrCurRec.kood5 <> tckood5 or lrCurRec.deebet <> tcdeebet or lrCurRec.lisa_k <> tclisa_k or
           lrCurRec.kreedit <> tckreedit or lrCurRec.lisa_d <> tclisa_d or lrCurRec.valuuta <> tcvaluuta or
           lrCurRec.kuurs <> tnkuurs or lrCurRec.valsumma <> tnvalsumma or lrCurRec.tunnus <> tctunnus or
           lrCurRec.proj <> tcProj then
            update journal1
            set
                parentid = tnparentid,
                summa    = tnsumma,
                dokument = tcdokument,
                muud     = ttmuud,
                kood1    = tckood1,
                kood2    = tckood2,
                kood3    = tckood3,
                kood4    = tckood4,
                kood5    = tckood5,
                deebet   = tcdeebet,
                lisa_k   = tclisa_k,
                kreedit  = tckreedit,
                lisa_d   = tclisa_d,
                valuuta  = tcvaluuta,
                kuurs    = tnkuurs,
                valsumma = tnvalsumma,
                tunnus   = tctunnus,
                proj     = tcproj
            where
                id = tnId;
        end if;
        lnjournal1Id := tnId;


        -- valuuta
        if (
               select count(id) from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id
           ) = 0 then

            insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs)
            values (1, lnjournal1Id, tcValuuta, tnKuurs);
        else
            select * into v_dokvaluuta from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id;

            if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

                update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

            end if;

        end if;


    end if;

    select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;


--avans
    select
        avans1.id
    into lnId
    from
        avans1
            inner join dokprop on dokprop.id = avans1.dokpropid
    where
          ltrim(rtrim(number)) = ltrim(rtrim(tmpJournal.dok))
      and rekvid = tmpJournal.rekvid
      and avans1.asutusId = tmpJournal.asutusId
      and ltrim(rtrim(dokprop.konto)) = ltrim(rtrim(tcDeebet))
    order by avans1.kpv desc
    limit 1;

    if ifnull(lnId, 0) > 0 then
        perform fnc_avansijaak(lnId);
    end if;

-- если это оплата, то проверка и поиск номера не оплаченного счета
    if empty(coalesce(tmpJournal.dok, ''))
        and (
                select omvorm
                from asutus a
                where id = tmpJournal.asutusId
                limit 1
            ) <> 'E'
        and tcdeebet like '113%' then
        -- ищем номер не оплаченного счета
        select
            arve_number,
            arve_id
        into l_arve_number, l_arve_id
        from
            get_tasumata_arv_number(tmpJournal.asutusId, tnsumma, tckreedit);

        if l_arve_number is not null then
            -- found arve
            update journal set dok = l_arve_number where id = tmpJournal.id;

            -- tasumine
            perform sp_tasuarv(tmpJournal.id::integer, l_arve_id::integer, tmpJournal.rekvid:: integer,
                               tmpJournal.kpv:: date,
                               tnSumma:: numeric, 3::integer, 0:: integer);

        end if;

    end if;

    -- reklmaks
/*

if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;
*/

    return lnjournal1Id;
end;
$BODY$
    LANGUAGE 'plpgsql' VOLATILE
                       COST 100;
ALTER FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;
